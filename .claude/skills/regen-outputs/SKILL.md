---
name: regen-outputs
description: Regenerate all derived artifacts for Hamstra in one command (shared-param gate, every model STL, main_assembly.png). Use after any change under cad/, or when the user wants fresh STLs to print. Never hand-run individual openscad commands for this.
---

# Regenerate derived outputs

```bash
python3 scripts/regen_all.py                 # everything
python3 scripts/regen_all.py gun_rack        # just these models
python3 scripts/regen_all.py --stl-only      # every STL, skip the assembly PNG
```

Pipeline:
1. `scripts/check_params.py`: no file may shadow a design_params.scad name
2. every model in cad/ (lib excluded) -> `stl/<category>/<name>.stl`;
   a model with a `part = "a"; // [a, b]` dropdown line exports
   `<name>_a.stl` and `<name>_b.stl` instead, and a model with a
   `modular = ...;` line also exports every module to its own file,
   `..._modular_<n>.stl`. The module count comes from the model's
   `echo(modules = n)` (wall_row and gun_rack emit it when modular), so
   a new modular model must echo it too or regen stops with an error.
   A model with a `pad = ...;` line also exports the friction pad of
   every one of those as `..._pad.stl` / `..._pad_modular_<n>.stl`.
3. `cad/main_assembly.scad` -> `main_assembly.png`

## Rules

- A new model is picked up automatically: put it under
  `cad/<category>/`. A new non-model .scad (helper) goes in `cad/lib/`.
  A new artifact type gets added to `regen_all.py`, never a side script.
- Every line must be `[ok]`. A FAIL is a modeling error; see the verify
  skill's failure section.
- Finish by looking at `main_assembly.png` with the Read tool: parts
  floating off the wall or stand-ins missing their holders are findings
  even when everything compiles.
- Prototyping phase: the STLs are gitignored. `main_assembly.png` is
  committed as the README image, so a change to a model or the scene
  commits the regenerated PNG with it. Its view is `ASSEMBLY_VIEW` in
  regen_all.py; never hand-render it with other settings.

## Notes

- When a model makes fewer modules than before (a slot removed, or the
  rack's module_slots grouping changed), regen deletes the leftover
  `..._modular_<n>.stl` files of that part, so check_joints never
  compares a new module with a stale one. Before 2026-10-10 it left them.

- A model filter is the file's bare name: `regen_all.py
  suppressor_clip_test`. A path such as `cad/my_safe/x.scad` matches
  nothing and exits clean without exporting anything.
