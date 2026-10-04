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
