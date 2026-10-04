#!/usr/bin/env python3
"""Regenerate all derived artifacts for Hamstra in one command.

Run after any change to cad/ (see the regen-outputs skill). Never
hand-compose openscad command lines for this.

Pipeline:
  1. scripts/check_params.py     shared dimensions are never shadowed
  2. every model under cad/      -> stl/<category>/<name>.stl
  3. cad/main_assembly.scad      -> main_assembly.png (README image)

A model is any .scad under cad/ except cad/lib/ (helpers),
design_params.scad (data) and main_assembly.scad (the scene). Each model
must render warning-free with manifold status NoError.

A file that prints as several parts declares a Customizer dropdown on
one line, `part = "cup"; // [cup, clip]`, and gets one STL per option:
stl/<category>/<name>_<option>.stl.

A file with a `modular = false;` line also gets every output rendered
with modular = true (all modules laid out for printing) as
<name>[_<option>]_modular.stl, so the modular path is gated too.

Prototyping phase: stl/ and main_assembly.png are gitignored while the
models are iterated by eye in OpenSCAD. When designs settle they become
committed build products and --check gains a byte comparison against
them, the way skua does it.

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
PART_DROPDOWN = re.compile(r'(?m)^part\s*=\s*"\w+"\s*;\s*//\s*\[([^\]]+)\]')
MODULAR = re.compile(r"(?m)^modular\s*=\s*false\s*;")


def models():
    for p in sorted(CAD.rglob("*.scad")):
        rel = p.relative_to(CAD)
        if rel.parts[0] != "lib" and p.stem not in NON_MODELS:
            yield p


def outputs(scad: Path):
    """(stl path, extra openscad args) per printed part of a model."""
    base = ROOT / "stl" / scad.relative_to(CAD).with_suffix("")
    text = scad.read_text()
    m = PART_DROPDOWN.search(text)
    parts = ([("", [])] if not m else
             [(f"_{o.strip()}", ["-D", f'part="{o.strip()}"']) for o in m.group(1).split(",")])
    modes = [("", [])] + ([("_modular", ["-D", "modular=true"])] if MODULAR.search(text) else [])
    for part, part_args in parts:
        for mode, mode_args in modes:
            yield base.with_name(f"{base.name}{part}{mode}.stl"), part_args + mode_args


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
            for stl, extra in outputs(scad):
                ok &= run_one(scad, target(stl), stl, extra)

        if not stl_only and (not only or "main_assembly" in only):
            png = ROOT / "main_assembly.png"
            ok &= run_one(ASSEMBLY, target(png), png)

    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
