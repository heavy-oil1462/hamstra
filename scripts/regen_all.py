#!/usr/bin/env python3
"""Regenerate all derived artifacts for Hamstra in one command.

Run after any change to cad/ (see the regen-outputs skill). Never
hand-compose openscad command lines for this.

Pipeline:
  1. scripts/check_params.py     shared dimensions are never shadowed
  2. every model under cad/      -> stl/<category>/<name>.stl
  3. scripts/check_joints.py     neighbouring modules must not overlap
  4. cad/main_assembly.scad      -> main_assembly.png (README image)

A model is any .scad under cad/ except cad/lib/ (helpers),
design_params.scad (data) and main_assembly.scad (the scene). Each model
must render warning-free with manifold status NoError.

A file that prints as several parts declares a Customizer dropdown on
one line, `part = "cup"; // [cup, clip]`, and gets one STL per option:
stl/<category>/<name>_<option>.stl.

A file with a `modular = ...;` line also gets every module exported to
its own STL, <name>[_<option>]_modular_<n>.stl, rendered with
modular = true and print_slot = n. The module count comes from the
model itself: it echoes `modules = n` when modular, read from a cheap
echo-only pass, so it always matches the slot lists in the file.

Prototyping phase: stl/ is gitignored while the models are iterated by
eye in OpenSCAD. main_assembly.png is committed as the README image, so
regenerate it in the same change as the models it shows. When designs
settle the STLs become committed build products too and --check gains a
byte comparison against them, the way skua does it.

Usage:
    scripts/regen_all.py [model ...]   # no args = everything
    scripts/regen_all.py --stl-only    # skip the assembly PNG
    scripts/regen_all.py --check       # read-only gate (the verify skill and
                                       # CI): render everything to a temp dir,
                                       # touch nothing in the tree
"""

import re
import subprocess
import sys
import tempfile
from pathlib import Path

from render_scad import render

ROOT = Path(__file__).resolve().parent.parent
CAD = ROOT / "cad"
NON_MODELS = {"design_params", "main_assembly"}
ASSEMBLY = CAD / "main_assembly.scad"
# README image: front three-quarter view, supersampled for smooth edges
ASSEMBLY_VIEW = ["--colorscheme=Tomorrow", "--imgsize=1200,1000",
                 "--camera=60,-75,500,72,0,18,2800", "--supersample=2"]
PART_DROPDOWN = re.compile(r'(?m)^part\s*=\s*"\w+"\s*;\s*//\s*\[([^\]]+)\]')
MODULAR = re.compile(r"(?m)^modular\s*=\s*(true|false)\s*;")
MODULE_COUNT = re.compile(r"ECHO: modules = (\d+)")


def models():
    for p in sorted(CAD.rglob("*.scad")):
        rel = p.relative_to(CAD)
        if rel.parts[0] != "lib" and p.stem not in NON_MODELS:
            yield p


def module_count(scad: Path, args, td: str) -> int:
    """How many modules the model makes with these args and modular on."""
    echo = Path(td) / "modules.echo"
    render(str(scad), str(echo), args + ["-D", "modular=true"])
    m = MODULE_COUNT.search(echo.read_text()) if echo.exists() else None
    if not m:
        raise SystemExit(f"{scad.relative_to(ROOT)} has a modular flag but echoed"
                         " no module count (see wall_row in lib/magnets.scad)")
    return int(m.group(1))


def outputs(scad: Path, td: str):
    """(stl path, extra openscad args) per printed part of a model: the
    one-piece part, then each module on its own when the model is modular."""
    base = ROOT / "stl" / scad.relative_to(CAD).with_suffix("")
    text = scad.read_text()
    m = PART_DROPDOWN.search(text)
    parts = ([("", [])] if not m else
             [(f"_{o.strip()}", ["-D", f'part="{o.strip()}"']) for o in m.group(1).split(",")])
    modular = bool(MODULAR.search(text))
    for part, args in parts:
        yield (base.with_name(f"{base.name}{part}.stl"),
               args + (["-D", "modular=false"] if modular else []))
        if modular:
            for i in range(1, module_count(scad, args, td) + 1):
                yield (base.with_name(f"{base.name}{part}_modular_{i}.stl"),
                       args + ["-D", "modular=true", "-D", f"print_slot={i}"])


def run_one(scad: Path, out: Path, shown: Path, extra=None) -> bool:
    """Render scad -> out and report. shown is the path to print (the
    real target when out is a temp file in check mode)."""
    out.parent.mkdir(parents=True, exist_ok=True)
    proc = render(str(scad), str(out), extra)
    warnings = sorted({l.strip() for l in proc.stderr.splitlines()
                       if "WARNING" in l or "ERROR" in l})
    # Manifold backend reports geometry health as "Status: NoError"
    geom = re.search(r"Status:\s+(\w+)", proc.stderr)
    geom_ok = geom is None or geom.group(1) == "NoError"
    ok = proc.returncode == 0 and not warnings and geom_ok
    print(f"[{'ok' if ok else 'FAIL'}] {scad.relative_to(ROOT)} -> {shown.relative_to(ROOT)}")
    for w in warnings:
        print(f"        {w}")
    if not geom_ok:
        print(f"        geometry status: {geom.group(1)}, model is not cleanly manifold")
    if proc.returncode != 0 and not warnings:
        print("        " + "\n        ".join(proc.stderr.strip().splitlines()[-5:]))
    return ok


def main(argv):
    stl_only = "--stl-only" in argv
    check = "--check" in argv
    only = {a for a in argv[1:] if not a.startswith("--")}

    ok = subprocess.run([sys.executable, str(ROOT / "scripts" / "check_params.py")]).returncode == 0

    with tempfile.TemporaryDirectory() as td:
        def target(real: Path) -> Path:
            return Path(td) / real.relative_to(ROOT) if check else real

        for scad in models():
            if only and scad.stem not in only:
                continue
            for stl, extra in outputs(scad, td):
                ok &= run_one(scad, target(stl), stl, extra)

        # joint gate on the module STLs just rendered (temp dir in check mode)
        stl_root = Path(td) / "stl" if check else ROOT / "stl"
        ok &= subprocess.run([sys.executable, str(ROOT / "scripts" / "check_joints.py"),
                              str(stl_root)]).returncode == 0

        if not stl_only and (not only or "main_assembly" in only):
            png = ROOT / "main_assembly.png"
            ok &= run_one(ASSEMBLY, target(png), png, ASSEMBLY_VIEW)

    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
