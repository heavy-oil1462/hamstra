// Spare barrel holder: a cup for the breech end at the bottom of the wall
// and a snap clip higher up, two parts printed from this one file. Both
// come from the same slot layout, so every barrel stands plumb.
//
// Every slot has its own breech and barrel diameter, wall offset and gap
// to the next one. Per-slot knobs take one entry per slot, or a single
// number for all (a short list repeats its last entry). The layout is
// spaced by whichever is fatter per slot, breech or barrel.
//
// Prints as modeled: back plate vertical, cups and rings standing on the
// bed. Pick the part to show or export with `part`; regen_all.py exports
// every option of the dropdown.

include <../design_params.scad>
use <../lib/magnets.scad>
use <../lib/holders.scad>

// Which part to show
part = "cup"; // [cup, clip]

/* [Slots] */
// Breech end diameter per slot, measured (stands in the cup)
breech_d = [32, 30];
// Barrel diameter per slot where the clip grips it, measured
barrel_d = [20, 18];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0];
// Space between neighbouring cups, one entry per pair
gaps = [8];

/* [Cup] */
// Cup depth, inside
cup_depth = 40;
// Cup floor thickness
floor_t = 2;
// Drain hole in the floor (0 for none)
drain_d = 6;
// Cup back plate height (at least cup depth plus floor)
cup_plate_h = 50;

/* [Clip] */
// Clip ring height
clip_h = 15;
// Clip ring wall, thicker snaps harder
clip_wall = 3;
// Snap opening as a fraction of the barrel diameter (below 1 snaps)
snap = 0.85;
// Clearance added to the barrel diameter (small, the clip should hug)
clip_clearance = 0.4;
// Clip back plate height
clip_plate_h = 40;

/* [Magnets] */
// Magnet columns
magnets_x = 2;
// Magnet rows
magnets_z = 2;

module barrel_holder(part = part, breech_d = breech_d, barrel_d = barrel_d,
                     wall_offset = wall_offset, gaps = gaps,
                     cup_depth = cup_depth, floor_t = floor_t,
                     drain_d = drain_d, cup_plate_h = cup_plate_h,
                     clip_h = clip_h, clip_wall = clip_wall, snap = snap,
                     clip_clearance = clip_clearance,
                     clip_plate_h = clip_plate_h, magnets_x = magnets_x,
                     magnets_z = magnets_z) {
    bd = as_list(breech_d);
    n = len(bd);
    cup_ds = [for (d = bd) d + item_clearance];
    clip_ds = [for (i = [0 : n - 1]) per(barrel_d, i) + clip_clearance];
    // shared layout: spaced and set off the wall by the fatter part per slot
    lay_w = max(wall, clip_wall);
    lay_ds = [for (i = [0 : n - 1]) max(cup_ds[i], clip_ds[i])];
    xs = holder_xs(lay_ds, lay_w, gaps);
    axes = holder_axes(lay_ds, 1, wall_offset);
    plate_w = holder_row_w(lay_ds, lay_w, gaps);

    if (part == "cup")
        wall_mount(plate_w, max(cup_plate_h, cup_depth + floor_t), magnets_x, magnets_z)
            holder_row(cup_ds, cup_depth + floor_t, xs, axes,
                       bottom = drain_d > 0 ? "lip" : "closed", floor_t = floor_t,
                       lips = [for (d = cup_ds) (d - drain_d) / 2]);
    else if (part == "clip")
        wall_mount(plate_w, max(clip_plate_h, clip_h), magnets_x, magnets_z)
            holder_row(clip_ds, clip_h, xs, axes, w = clip_wall, bottom = "open",
                       front_gaps = [for (i = [0 : n - 1]) per(barrel_d, i) * snap],
                       chamfer = 0.6);
    else
        assert(false, str("unknown part: ", part));
}

barrel_holder();
