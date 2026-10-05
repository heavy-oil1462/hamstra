---
name: openscad-review
description: Render and review Hamstra's OpenSCAD models headlessly (via nix, no GUI). Checks warnings, manifold geometry, visual correctness and the project's design rules. Use after any .scad change, or when asked to review or check the CAD.
---

# OpenSCAD review

Review by rendering and looking, never from source alone.

```bash
scripts/render_scad.py cad/safe/<model>.scad "$SCRATCH/<model>.png" \
    --imgsize=900,700 --camera=0,0,0,60,0,320,0 --viewall --autocenter
```

`--camera=0,0,0,60,0,320,0` is a front three-quarter view of an upright
model; `...,60,0,150,0` shows the back with the magnet pockets.

## Procedure

1. Run `python3 scripts/regen_all.py --check` first (the verify skill).
   It gates params, warnings and manifold status for every model.
2. Render each changed model front and back into the scratchpad and look
   at the PNGs with the Read tool.
3. For models used by the assembly, regenerate and look at
   `main_assembly.png` too.

## Design rules to check

- Every knob a user might change is a Customizer parameter at the top of
  the model file and an argument of the model's module.
- Shared values come from cad/design_params.scad, never a local copy.
- Multi-slot models take per-slot lists (diameter, wall_offset, gaps)
  through lib/holders.scad's `per()`; render with uneven values
  (`-D 'wall_offset=[0,15]'`) to check slots stay independent.
- Modular joints: neighbouring modules at their row positions must not
  overlap. `scripts/check_joints.py` gates this (regen_all runs it).
- Magnet pockets: magnet face magnet_out proud of the back, pad_air
  short of the pad face (flush when pad_t = 0), pad holes lined up,
  teardrop roof pointing up on vertical faces, at least magnet_edge from
  the plate edge.
- Prints without support in the modeled orientation: nothing starts
  above the bed with a flat underside, no horizontal round holes without
  a teardrop roof, chamfers widen upward.
- Holders: bore and its entry chamfer stay out of the back plate (the
  holders.scad asserts guard this; never loosen them).

## Notes

- The sandbox's `LD_LIBRARY_PATH=/lib` crashes nix binaries; render_scad.py
  overrides it. Do the same if running openscad manually via `nix shell`.
- PNGs use Mesa software GL via `EGL_PLATFORM=surfaceless`, no X needed.
  `libEGL warning: Not allowed to force software rendering` is benign.
- `Fontconfig error: Cannot load default config file` is benign too:
  OpenSCAD falls back to its bundled font and text() still renders (the
  gauge labels show up). It is lowercase, so regen_all does not flag it.
- `nixpkgs#openscad-unstable` on the unstable registry has no hydra cache
  and its source build fails at link after an hour. render_scad.py pins a
  release branch that ships the same snapshot prebuilt. Probe a new pin
  with `--max-jobs 0` before switching.
- Section views need `--render`: the OpenCSG preview mis-draws a
  difference against a huge half-space cube. In model code, size a
  half-space cutter to the part (dovetail_bar uses k + 10), never 1e4:
  the user's F5 preview flickers and hides the cut otherwise.
- A model used as a library is `use`d with a path relative to the using
  file; top-level variables of a `use`d file are not visible to the user
  of it, so the assembly passes overrides as module arguments.
- hull() of a non-convex 2D profile (a dovetail: narrow neck, wide
  outside) fills the concave parts. A hulled tongue end came out wider
  than its slot and could not slide in. Cut ends with a half space
  (intersection with a rotated cube) so the flanks stay as profiled.
- Test a sliding fit over its whole travel, not just near the seated
  position: intersect the two parts at offsets from fully apart down to
  seated and past it (volume() in scripts/check_joints.py). Zero overlap
  everywhere above seated, growing overlap just past it.
