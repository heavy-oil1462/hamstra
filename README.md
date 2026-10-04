# Hamstra

Parametric, 3D printable organizers for guns and hunting gear, written in
OpenSCAD. The first set lives in the gun safe and holds on with neodymium
magnets, so nothing is drilled into the safe:

- Suppressor holder: upright sleeves, the suppressor rests on a bottom lip
- Spare barrel holder: a cup for the breech end plus a snap clip higher up
- Gun rack: a comb shelf for the top of the safe, modules tile edge to edge

Reloading equipment and other gear will follow.

Status: early prototypes. Dimensions are still being tuned.

## Models

| Model | File | Prints |
| --- | --- | --- |
| Suppressor holder | `cad/safe/suppressor_holder.scad` | upright, as modeled |
| Barrel cup | `cad/safe/barrel_cup.scad` | upright, as modeled |
| Barrel clip | `cad/safe/barrel_clip.scad` | upright, as modeled |
| Gun rack | `cad/safe/gun_rack.scad` | on its back, as modeled |
| Magnet pocket gauge | `cad/calibration/magnet_pocket_gauge.scad` | as modeled |

None of them need support.

## Customizing

Open a model in OpenSCAD and use the Customizer (Window, Customizer). Every
model lists its knobs there: item diameters, counts, heights, magnet rows
and columns. Measure your suppressor, barrel or breech with calipers and
type the measured diameter in; the models add the clearance themselves.

A few values are shared by several models and live in
`cad/design_params.scad` instead: the magnet size and pocket fit, the back
plate thickness, and the spacing the barrel cup and barrel clip must agree
on so a barrel stands plumb.

## Magnets

The defaults use 12x3 mm neodymium disc magnets. Change `magnet_d` and
`magnet_h` in `cad/design_params.scad` for other sizes.

1. Print `magnet_pocket_gauge` first, press a magnet into each pocket and
   set `magnet_clearance` to the tightest one that seats fully flush.
2. Glue the magnets in with epoxy or CA, face flush with the back.
3. A magnet holds far less sideways on a vertical wall than its rated
   pull, about a quarter. Raise the magnet rows and columns for heavy
   items. A felt or carpet lined safe wall weakens the hold further.

## Working on the design

Everything is driven from one script:

```bash
python3 scripts/regen_all.py           # gates, every STL, the assembly image
python3 scripts/regen_all.py --check   # read-only gate, what CI runs
```

It fetches OpenSCAD through nix. Without nix, point `OPENSCAD` at your own
binary. The scripts are standard library Python.

## License

MIT, see `LICENSE`.
