#!/usr/bin/env python3
"""Plastic per part: the volume of each model part, as its file is set up.

Renders each model once per option of its `part` dropdown, like
count_magnets.py, and prints the volume of the resulting STL. Use it to
compare plastic before and after a change.

Usage:
    scripts/part_volumes.py                  # every build in cad/my_safe
    scripts/part_volumes.py cad/safe/*.scad  # any models
"""

import sys
import tempfile
from pathlib import Path

from check_joints import volume
from count_magnets import PART_DROPDOWN
from render_scad import render

ROOT = Path(__file__).resolve().parent.parent


def main(argv):
    files = [Path(a) for a in argv[1:]] or sorted((ROOT / "cad" / "my_safe").glob("*.scad"))
    total = 0.0
    with tempfile.TemporaryDirectory() as td:
        out = Path(td) / "part.stl"
        for scad in files:
            m = PART_DROPDOWN.search(scad.read_text())
            parts = [o.strip() for o in m.group(1).split(",")] if m else [None]
            for part in parts:
                out.unlink(missing_ok=True)
                proc = render(str(scad), str(out), ["-D", f'part="{part}"'] if part else [])
                if proc.returncode != 0:
                    raise SystemExit(f"{scad}: render failed\n{proc.stderr[-500:]}")
                v = volume(out) / 1000
                total += v
                label = scad.stem + (f" {part}" if part else "")
                print(f"{v:8.1f} cm3  {label}")
    print(f"{total:8.1f} cm3  total")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
