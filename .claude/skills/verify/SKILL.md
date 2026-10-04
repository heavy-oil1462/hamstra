---
name: verify
description: Read-only commit gate for Hamstra. Runs the shared-param check and renders every model and the assembly to a temp dir, failing on warnings or non-manifold geometry. Use when about to commit, before opening a PR, or when asked whether the repo is consistent.
---

# Verify

```bash
python3 scripts/regen_all.py --check
```

Read-only: nothing in the working tree is touched. Every line must be
`[ok]` and the exit code 0 before committing. CI runs exactly this.

What it checks, in order:

1. `check_params.py`: no file shadows a design_params.scad name
2. every model under cad/ (lib excluded) renders warning-free with
   manifold status NoError
3. `check_joints.py`: neighbouring modules of every modular row share no
   volume (only the joint plane may touch)
4. `main_assembly.scad` renders warning-free

Prototyping phase: there is no byte comparison against committed STLs
yet, because stl/ is not committed while the models are iterated by eye.
See CLAUDE.md for the plan once models settle.

## When it fails

- `[FAIL]` on check_params: a model re-declares a shared name. Delete
  the local copy and use the value in cad/design_params.scad. Never
  rename the local copy to dodge the check.
- `[FAIL]` with warnings: read them. An `assert` message from
  lib/holders.scad means the knobs ask for impossible geometry (bore into
  the plate, overlapping holders); fix the knob, never the assert.
- `[FAIL] joint ...`: two neighbouring modules overlap, usually a
  tongue, edge strip or shelf running past the module edge. Fix the
  geometry; never raise MAX_OVERLAP.
- `[FAIL]` with a geometry status: the model is not cleanly manifold,
  usually coincident faces in a `difference()`. Extend the cutter by eps
  past both surfaces. See the openscad-review skill.

## Notes

- The sandbox PAT has no workflow scope, so it cannot push changes to
  .github/workflows/. Commit those on their own local branch (for now
  `ci-workflow`) and leave the push to the user. Never keep such a
  commit on the working branch: every later push then needs a commit
  reorder, which already cost time twice.
