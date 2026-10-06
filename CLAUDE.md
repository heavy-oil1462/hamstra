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
- Multi-slot models are configured per slot: diameter (or slot width),
  wall_offset (extra distance from the safe wall, 0 = tight) and gaps
  (edge to edge, one per neighbouring pair). Each per-slot knob takes a
  list or a single number; a short list repeats its last entry
  (`per()` in lib/holders.scad). The slot count comes from the diameter
  list. Example: a gun rack with three break actions tight and close
  and a scoped bolt action set out from the wall with a wide gap.
- Safe models mount with magnets, never screws. Disc magnets are glued
  into pockets in a flat back plate: pull force collapses with any gap,
  so a magnet is never buried behind a printed skin. On a vertical wall
  the load is shear, roughly a quarter of the rated pull, so magnet
  counts are generous and configurable.
- A friction pad (pad_t thick, TPU printed from the model's `pad = true`
  output or silicone sheet cut to it) sits between plate and wall. The
  magnets stand magnet_out out of the back through holes in the pad and
  stop pad_air short of the wall: the pad, not the magnet, takes the
  friction, and only air sits in front of a magnet. The pad is not
  glued, the magnets press it to the wall where they pull hardest.
  pad_t = 0 gives flush magnets and no pad. Models build the pad from
  back_pad in lib/magnets.scad (wall_mount does it when `$pad` is set).
- Models are modeled in their print orientation and print without
  support. Upright models (back plate vertical, holders standing on the
  bed) use horizontal teardrop magnet pockets. The gun rack prints shelf
  down for the same reason: its plate stands, so its pockets are
  teardrops too, its fingers lie in the layers (sideways loads run along
  them) and the dovetail tongue rises straight off the bed, its joint
  flipped so the slot closes at the plate bottom. No model bridges a
  pocket floor. Features
  start at the bed rather than float above it: a holder high up a tall
  plate cannot print upright. Prefer splitting into short pieces (cup
  row plus clip row, as the barrel and suppressor holders do, sharing
  cup_clip_part in lib/holders.scad) over one tall plate: far less
  print time.
- Rows can print as one piece or, with `modular = true`, as one module
  per slot. Modules split at the middle of each gap (so a joined row has
  exactly the one-piece layout), carry their own magnets, and join with
  a sliding dovetail along the plate side edges between slots
  (lib/dovetail.scad, shared values in design_params): tongue right,
  slot left, slot closed at the far end from the bed (top on upright
  prints, bottom on the rack). Tongue and slot end in matching 45 degree
  planes (dovetail_bar), flanks straight, that meet when the plates are
  level, so modules stop level and nothing bridges. Outer row ends
  plain. regen exports each module to its own STL. `print_slot` picks
  one module or lays them all out. New multi-slot models build on `wall_row` in
  lib/magnets.scad, which handles both modes.
- Holder slot sizes are a diameter or [width, depth] for oblong items
  (an over and under pair stacked front to back), via sx/sy/bore2d in
  lib/holders.scad. Round and oblong slots mix in one row.
- Efficiency: print time, plastic and magnets no more than needed, no
  fewer. Back plates are one solid back_t thick (the magnet plus a
  back_skin floor to glue and index against, thicker by magnet_out), so
  the front never shows the magnets; that is the user's choice over
  saving plastic. plate_t
  below back_t switches to a thin plate with bosses (pointed underside
  on upright prints);
  rack shelf depth is per slot; cups only locate, clips hold. Magnet
  counts follow the load: a row carrying weight gets enough for about
  2x margin at ~0.8 kg shear per 12x5 magnet on bare steel; rows that
  stand on the floor or only keep items in get 2 (one per rack module,
  the dovetails tie the row together). `scripts/count_magnets.py`
  checks the total; measure part volumes before and after a change.
- Heavy items stand on the safe floor, they do not hang on magnets: the
  barrel holder's cup row has one flat bottom on the safe floor and
  carries the weight; magnets only hold it to the wall. A hole in a
  floor standing cup is blocked by the safe floor, so its drain is a
  groove in the cup floor out through the front wall (holder_row
  groove), and its pad output adds a base pad under the row's footprint
  with a lip the row sits in (the row's underside prints on the bed, so
  the locating feature belongs on the pad). Barrel clips are
  separate pieces by default (barrels differ in length, each clip sits
  below its own muzzle); only base rows dovetail.
- Two models that must agree on a dimension read it from
  `cad/design_params.scad`. Parts that must agree per slot (the barrel
  cup and clip) live in one file with a `part` dropdown instead, so one
  slot layout drives both and the whole layout stays in the Customizer.

## Layout

- `cad/design_params.scad`: single source of truth for every value two
  models share (magnet size and fit, back plate, barrel pair spacing,
  print rules). Models `include` it; `check_params.py` fails the build if
  any file re-declares one of its names.
- `cad/<category>/`: one .scad per printable model. Categories so far:
  `safe/` (gun safe organizers). Future: `reloading/`, and so on. Each
  model defines a module of the same name with every knob as an argument
  defaulting to the file's Customizer value, then calls it once, so the
  assembly can `use` it and pass overrides. A file printing several
  parts declares `part = "a"; // [a, b]` on one line and regen_all
  exports `<name>_<option>.stl` for every option. A `pad = false;` line
  makes regen export each part's friction pad too (`..._pad.stl`).
- `cad/my_safe/`: the maintainer's own builds, thin wrappers that `use`
  a generic model and pass measured values (one file per model, values
  redeclared as Customizer knobs). regen exports them like any model.
  Keep personal values here, never in a generic model's defaults.
  Customizer presets (.json) cannot do this job: a preset must match the
  type and list length of the model's defaults and is silently ignored
  otherwise, so it cannot change the slot count.
- `cad/calibration/`: gauges for calibrated fits (magnet_pocket_gauge,
  dovetail_gauge) and fit_gauge, which slices the real holder and rack
  geometry so users can test their own gear cheaply. fit_gauge reuses
  snap_opening and the rack's comb_profile: keep it on those, never a
  copy, so a gauge always matches what the holders print.
  Print, pick the best fit, type it into design_params.
- `cad/lib/`: shared helpers, not printable (magnets.scad: pockets,
  back plate, wall_row; holders.scad: per-slot layout and round
  sleeves, cups and snap clips; dovetail.scad: the module joint).
- `cad/main_assembly.scad`: a stretch of safe wall with every safe model
  and stand-in items, renders to `main_assembly.png`, the README image.
  Its camera, size and supersampling live in `ASSEMBLY_VIEW` in
  `regen_all.py`; colors and the `show_wall` toggle at the top of the
  scene.
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
- `python3 scripts/check_joints.py [stl_dir]`: neighbouring module STLs
  must share no volume; regen_all runs it as a gate.
- `python3 scripts/count_magnets.py [files]`: magnets a set of models
  needs (default: the cad/my_safe builds), summed from the `magnets = n`
  the pocket grids echo, each part rendered as its file is set up.
- `python3 scripts/render_scad.py <file.scad> <out.png|stl> [args]`:
  one-off headless renders (see the openscad-review skill).
  `--supersample=N` renders N times larger and averages down, since
  OpenSCAD has no antialiasing.

## Prototyping phase

The models are being iterated by eye: the user opens them in OpenSCAD
and judges them there. Until they settle:

- `stl/` is gitignored, not committed. `main_assembly.png` is committed
  as the README image: regenerate it in the same change as any model
  or scene change it shows.
- verify gates on the shared-param check plus every model rendering
  warning-free and manifold. No geometry or byte-drift gates yet.

When a model is accepted, the plan is to follow skua: commit the STLs
as build products, add a byte comparison to
`--check`, and add a geometry check script for fits that matter (pocket
walls, holder clearances, bed size).

Conventions:
- Review CAD by rendering and looking at the PNG, never from source alone.
- Keep top-level `name = value;` parameters on one line so the tooling
  and the Customizer can parse them.
- The OpenSCAD Customizer edits lists of up to 4 numbers. Longer
  per-slot lists are edited in the file (or with a scalar for all slots).
- magnet_clearance and dovetail_clearance are MEASURED with their
  gauges, never tuned by eye. They are printer, profile and filament
  specific.
- OpenSCAD iterates a reversed range (`[1 : 0]`) backwards with a
  warning instead of skipping it. Loops over "the gaps between slots"
  must survive a single slot: `[for (i = [0 : n - 1]) if (i < n - 1) ...]`.

## Key off-the-shelf parts

- Neodymium disc magnets, default 12x5 mm (magnet_d, magnet_h). Glue
  them in with epoxy or CA; mind the polarity only if two models should
  stick to each other.
