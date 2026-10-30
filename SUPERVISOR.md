# Supervisor notes

How the podium team works on this repository. Written and kept by the
supervisor.

## Team

Up to two workers (the project limit). One is usually enough: changes
are small and many touch the shared libs, so two at once tend to
conflict in `cad/lib/` and `main_assembly.png`. Start a second only for
work in a separate model or in scripts. Remove a worker once it has had
nothing to do for a day.

## Cutting issues

- One model or one feature per issue. Name the file it goes in, the lib
  helpers to build on, the Customizer knobs with defaults, the print
  orientation and the magnet count with the load reasoning.
- Acceptance criteria are checkable: `regen_all.py --check` passes, a
  render from a named angle shows the feature, knob X changes Y, magnet
  count from `count_magnets.py`, README and assembly image updated.
- Owner measurements go into `cad/my_safe/` wrappers; say so in the
  issue when the owner has given numbers.
- There is no CI workflow in the repository; the worker runs verify.

## Review

- Render the changed models yourself (openscad-review skill) and look:
  support-free in print orientation, nothing floating, magnets not
  buried, pad output present.
- Check for hard-coded numbers inside modules and for values copied from
  design_params or from another model instead of shared.
- Check the single-slot case of any loop over gaps.
- `main_assembly.png` regenerated when a model or the scene changed.

## Lessons

- 2026-10-27: there is no CI workflow, so the runner reports "no CI ran"
  for every pull request. Run `regen_all.py --check` on the named head
  commit yourself before merging (`git fetch origin <sha>` and check it
  out; `gh pr checkout` can leave you on main).
- 2026-10-27: `gh pr edit` fails on this token (no read:org scope). Move
  labels with the REST API:
  `gh api -X DELETE repos/OWNER/REPO/issues/N/labels/status:review` and
  `gh api repos/OWNER/REPO/issues/N/labels -f "labels[]=status:changes"`.
- 2026-10-30: the owner also opens and merges pull requests themselves
  (#29). Before reviewing a worker's branch, check main for their changes.
