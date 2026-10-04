# Hamstra

Open source, 3D printable, parametric OpenSCAD models for organizing guns,
hunting gear and later reloading equipment. The first set is for the gun
safe: suppressor holder, spare barrel holder and gun rack, all mounted with
neodymium magnets on the back so nothing is drilled into the safe.

## Core design ideas (do not design against these)

- Everything is configurable. Each model exposes its knobs at the top of
  its file in OpenSCAD Customizer sections (`/* [Section] */`, one comment
  line above each knob). A hard-coded number inside a module that a user
  could reasonably want to change is a finding.
- Safe models mount with magnets, never screws. Disc magnets are glued
  into pockets in a flat back plate with their face flush with the back:
  pull force collapses with any gap, so a magnet is never buried behind a
  printed skin. On a vertical wall the load is shear, roughly a quarter of
  the rated pull, so magnet counts are generous and configurable.
- Models are modeled in their print orientation and print without
  support. Upright models (back plate vertical, holders standing on the
  bed) use horizontal teardrop magnet pockets; models printed on their
  back (the gun rack) use plain pockets opening onto the bed. Features
  start at the bed rather than float above it.
- Two models that must agree on a dimension read it from
  `cad/design_params.scad`. Example: barrel_cup and barrel_clip share
  barrel_pitch and barrel_axis_y so a barrel stands plumb in both.

## Layout

- `cad/design_params.scad`: single source of truth for every value two
  models share (magnet size and fit, back plate, barrel pair spacing,
  print rules). Models `include` it; `check_params.py` fails the build if
  any file re-declares one of its names.
- `cad/<category>/`: one .scad per printable model. Categories so far:
  `safe/` (gun safe organizers). Future: `reloading/`, and so on. Each
  model defines a module of the same name with every knob as an argument
  defaulting to the file's Customizer value, then calls it once, so the
  assembly can `use` it and pass overrides.
- `cad/calibration/`: gauges for calibrated fits (magnet_pocket_gauge).
  Print, pick the best fit, type it into design_params.
- `cad/lib/`: shared helpers, not printable (magnets.scad: pockets and
  back plate; holders.scad: round sleeves, cups and snap clips).
- `cad/main_assembly.scad`: a stretch of safe wall with every safe model
  and stand-in items, renders to `main_assembly.png`.
- `scripts/`: Python tools, stdlib only.

## Tools and workflow

Everything runs headless through nix (`nix build` / `nix shell` only,
never download binaries). OpenSCAD comes from the nixpkgs pin in
`render_scad.py`. No-nix escape hatch: set `OPENSCAD=/path/to/openscad`.

- `python3 scripts/regen_all.py`: the single entry point. Shared-param
  gate, then every model to `stl/<category>/<name>.stl`, then
  `main_assembly.png`. `--check` is the read-only gate (the verify skill
  and CI).
- `python3 scripts/check_params.py`: no file may shadow a design_params name.
- `python3 scripts/render_scad.py <file.scad> <out.png|stl> [args]`:
  one-off headless renders (see the openscad-review skill).

## Prototyping phase

The models are being iterated by eye: the user opens them in OpenSCAD
and judges them there. Until they settle:

- `stl/` and `main_assembly.png` are gitignored, not committed.
- verify gates on the shared-param check plus every model rendering
  warning-free and manifold. No geometry or byte-drift gates yet.

When a model is accepted, the plan is to follow skua: commit the STLs
and assembly image as build products, add a byte comparison to
`--check`, and add a geometry check script for fits that matter (pocket
walls, holder clearances, bed size).

Conventions:
- Review CAD by rendering and looking at the PNG, never from source alone.
- Keep top-level `name = value;` parameters on one line so the tooling
  and the Customizer can parse them.
- magnet_clearance is MEASURED with the gauge, never tuned by eye. It is
  printer, profile and filament specific.

## Key off-the-shelf parts

- Neodymium disc magnets, default 12x3 mm (magnet_d, magnet_h). Glue
  them in with epoxy or CA; mind the polarity only if two models should
  stick to each other.
