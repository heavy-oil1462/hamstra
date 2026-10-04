#!/usr/bin/env python3
"""Modular joint gate: neighbouring modules must not overlap.

For every model exported as modules (<name>_modular_<n>.stl, each at
its row position), intersects module n with module n + 1 and measures
the shared volume. Joined modules may only touch on the joint plane, so
anything above a hair of volume means a tongue, edge strip or shelf
runs into its neighbour.

Usage:
    scripts/check_joints.py [stl_dir]    # default: stl/
regen_all.py runs it after the STL stage (on the temp dir in --check).
"""

import re
import sys
import tempfile
from collections import defaultdict
from pathlib import Path

from render_scad import render

ROOT = Path(__file__).resolve().parent.parent
MODULE = re.compile(r"^(.*)_modular_(\d+)\.stl$")
VERTEX = re.compile(rb"vertex\s+(\S+)\s+(\S+)\s+(\S+)")
MAX_OVERLAP = 0.01  # mm3


def volume(stl: Path) -> float:
    if not stl.exists():
        return 0.0  # OpenSCAD writes nothing for an empty result
    p = [tuple(map(float, m)) for m in VERTEX.findall(stl.read_bytes())]
    v = 0.0
    for a, b, c in zip(p[0::3], p[1::3], p[2::3]):
        v += (a[0] * (b[1] * c[2] - b[2] * c[1]) - a[1] * (b[0] * c[2] - b[2] * c[0])
              + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6
    return abs(v)


def overlap(a: Path, b: Path, td: str) -> float:
    scad = Path(td) / "joint.scad"
    out = Path(td) / "joint.stl"
    out.unlink(missing_ok=True)
    scad.write_text(f'intersection() {{ import("{a}"); import("{b}"); }}\n')
    render(str(scad), str(out))
    return volume(out)


def main(argv):
    stl_dir = Path(argv[1]) if len(argv) > 1 else ROOT / "stl"
    rows = defaultdict(dict)
    for f in stl_dir.rglob("*_modular_*.stl"):
        m = MODULE.match(f.name)
        if m:
            rows[f.parent / m.group(1)][int(m.group(2))] = f
    ok = True
    with tempfile.TemporaryDirectory() as td:
        for row, mods in sorted(rows.items()):
            for n in sorted(mods):
                if n + 1 not in mods:
                    continue
                v = overlap(mods[n], mods[n + 1], td)
                bad = v > MAX_OVERLAP
                ok &= not bad
                tag = "FAIL" if bad else "ok"
                print(f"[{tag}] joint {row.name} {n}|{n + 1}: overlap {v:.3f} mm3")
    if not rows:
        print("[ok] no modular rows found")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
