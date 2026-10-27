# Direction

Set by the owner, heavy-oil1462. The supervisor reads this at the start of
every session. Change it through a pull request, or ask on the board issue.

## Goal

Hamstra is a set of open source, parametric OpenSCAD models that organize
guns and hunting gear, 3D printed at home. The first set organizes the
gun safe without drilling it: suppressor holder, barrel holder, gun rack
and bolt holder, all held on with magnets. The models should reach the
point where the owner prints them for their own safe from
`cad/my_safe/`, and anyone else can set them up for theirs in the
Customizer. Reloading equipment comes later.

## Guiding principles

The design rules are in CLAUDE.md under "Core design ideas"; they are
binding. In short, a change that breaks one of these is rejected:

- Every dimension a user could want to change is a Customizer knob at the
  top of the model file, never a number inside a module.
- Multi-slot models are configured per slot (size, wall_offset, gaps),
  each knob a list or a single number, via `per()`.
- Safe models mount with magnets in a flat back plate, never screws, and
  never with plastic between magnet and wall.
- Every part is modeled in its print orientation and prints without
  support; prefer several short pieces over one tall plate.
- Print time, plastic and magnet count are no more than the load needs:
  about 2x margin at 0.8 kg shear per 12x5 magnet.
- A value two models share lives in `cad/design_params.scad` and nowhere
  else (`check_params.py` enforces it).
- The owner's measured values live in `cad/my_safe/` wrappers, never in a
  generic model's defaults.
- Python tooling is standard library only; OpenSCAD comes through nix.

## Architecture

- `cad/design_params.scad`: shared values (magnets, pad, plates,
  dovetail, print rules). Included by everything.
- `cad/lib/`: helpers, not printable. `magnets.scad` (pockets, plate,
  pad, `wall_row` for one-piece or modular rows), `holders.scad` (per-slot
  layout, sleeves, cups, snap clips, `cup_clip_part`), `dovetail.scad`
  (module joint). Libraries may use each other and design_params, never a
  model.
- `cad/<category>/<model>.scad`: one printable model per file, a module
  of the same name with every knob as an argument, called once. Built on
  `cad/lib`; a new multi-slot model builds on `wall_row`. Models do not
  `use` other models.
- `cad/calibration/`: gauges. `fit_gauge` reuses the real holder and rack
  profiles, never copies.
- `cad/my_safe/`: the owner's builds, thin wrappers that `use` one model.
- `cad/main_assembly.scad`: the README scene; `use`s models and my_safe.
- `scripts/`: `regen_all.py` is the one entry point for derived files
  (STLs, `main_assembly.png`); `--check` is the gate.

Details are in CLAUDE.md under "Layout". Decisions that change this
structure get an ADR in `docs/adr` (none yet; the first one creates the
directory).

## Priorities, in order

1. Bolt holder (board, 2026-10-27): a straight tube per bolt with a slot
   at the top that the bolt handle indexes into, sized loosely for a
   normal bolt, magnet count per holder configurable.
2. Keep the existing safe models printable and tuned to the owner's
   measurements as they report back from test prints.

## Not now

- Reloading equipment and other categories.
- Committing STLs and byte or geometry gates: that waits until the
  models are accepted (CLAUDE.md, "Prototyping phase").

## How to work

- `python3 scripts/regen_all.py --check` (the verify skill) passes before
  a pull request: every model warning-free and manifold.
- Review CAD by rendering it and looking at the PNG, not from source.
- A change to a model or the scene regenerates `main_assembly.png` in the
  same pull request. New models get a row in the README models table.
- Measured fits (`magnet_clearance`, `dovetail_clearance`) are never
  tuned by eye.

## Ask the owner first

- Changing a value in `cad/my_safe/` that the owner measured.
- Changing a shared value in `design_params.scad` that alters already
  printed parts (magnet size, dovetail, back plate).
