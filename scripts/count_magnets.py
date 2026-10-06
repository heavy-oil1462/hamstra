#!/usr/bin/env python3
"""Count the mounting magnets a set of models needs.

Renders each model the way its file is set up (its own modular and
print_slot settings), once per option of its `part` dropdown, and adds
up the `magnets = n` lines the pocket grids in cad/lib/magnets.scad echo.
So the count always matches what the models actually cut.

Usage:
    scripts/count_magnets.py                  # every build in cad/my_safe
                                              # (test prints, *_test.scad, left out)
    scripts/count_magnets.py cad/safe/*.scad  # any models
"""

import re
import sys
import tempfile
from pathlib import Path

from render_scad import render, openscad_binary  # noqa: F401  (resolves openscad)

ROOT = Path(__file__).resolve().parent.parent
PART_DROPDOWN = re.compile(r'(?m)^part\s*=\s*"\w+"\s*;\s*//\s*\[([^\]]+)\]')
MAGNETS = re.compile(r"ECHO: magnets = (\d+)")


def count(scad: Path, args, td: str) -> int:
    echo = Path(td) / "magnets.echo"
    proc = render(str(scad), str(echo), args)
    if proc.returncode != 0 or not echo.exists():
        raise SystemExit(f"{scad}: render failed\n{proc.stderr[-500:]}")
    return sum(int(n) for n in MAGNETS.findall(echo.read_text()))


def main(argv):
    files = [Path(a) for a in argv[1:]] or sorted(
        p for p in (ROOT / "cad" / "my_safe").glob("*.scad") if not p.stem.endswith("_test"))
    total = 0
    with tempfile.TemporaryDirectory() as td:
        for scad in files:
            m = PART_DROPDOWN.search(scad.read_text())
            parts = [o.strip() for o in m.group(1).split(",")] if m else [None]
            for part in parts:
                n = count(scad, ["-D", f'part="{part}"'] if part else [], td)
                total += n
                label = scad.stem + (f" {part}" if part else "")
                print(f"{n:4d}  {label}")
    print(f"{total:4d}  total")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
