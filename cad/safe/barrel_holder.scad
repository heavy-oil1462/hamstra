// Spare barrel holder: a row of cups for the breech ends, standing on the
// floor of the safe, and a snap clip for each barrel higher up, all from
// one slot layout so every barrel stands plumb.
//
// Barrels are heavy and safe walls are slippery, so the cup row stands
// on the safe floor and carries the weight there: cup floors and back
// plate share one flat bottom. Its magnets only hold it to the wall, and
// the clips only keep the barrels upright.
//
// Barrels differ in length, so by default each clip is its own piece
// with its own plate and magnets, mounted just below its barrel's muzzle
// straight above its cup. clip_row = true joins the clips in one row for
// barrels of about the same length.
//
// Every slot has its own size, wall offset and gap to the next one.
// Per-slot knobs take one entry per slot, or a single value for all (a
// short list repeats its last entry). A size is a diameter, or
// [width, depth] for an oblong item such as an over and under barrel set
// stacked front to back: breech_d = [27, [42, 50]] is a round breech and
// an O/U monoblock, barrel_d = [17.5, [21, 42]] the matching tops. The
// layout is spaced by whichever is bigger per slot, breech or barrel.
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
// Breech end size per slot, measured (stands in the cup)
breech_d = [32, 30];
// Barrel size per slot where the clip grips it, measured. Tapered
// barrels: measure where the clip will sit, or mount it just below the
// muzzle and use the muzzle diameter.
barrel_d = [20, 18];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0];
// Space between neighbouring cups, one entry per pair
gaps = [8];
// Clip position per slot: 0 centered over the cup (round barrels), 1 back
// flush with the cup's back (an O/U set flush with its monoblock's back)
clip_align = [0, 0];

/* [Cup] */
// Cup depth, inside
cup_depth = 40;
// Cup floor thickness, it carries the barrel onto the safe floor
floor_t = 3;
// Drain hole in the floor (0 for none)
drain_d = 0;
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
// Join the clips in one row (only for barrels of about the same length)
clip_row = false;

/* [Modular] */
// Print one module per slot, joined side by side with sliding dovetails
modular = false;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

/* [Magnets] */
// Magnet columns (per module when modular)
magnets_x = 2;
// Magnet rows
magnets_z = 2;

// Slot layout [xs, axes, bounds] for these knobs: the holder uses it, and
// so does the assembly to stand barrels in it.
function barrel_layout(breech_d = breech_d, barrel_d = barrel_d,
                       wall_offset = wall_offset, gaps = gaps,
                       clip_wall = clip_wall, clip_clearance = clip_clearance,
                       clip_align = clip_align) =
    let (bd = as_list(breech_d))
    holder_pair_layout([for (d = bd) grow(d, item_clearance)], wall,
                       [for (i = [0 : len(bd) - 1]) grow(per(barrel_d, i), clip_clearance)],
                       clip_wall, gaps, wall_offset, clip_align);

// Height of the cup floor the barrels stand on.
function barrel_floor_t() = floor_t;

module barrel_holder(part = part, breech_d = breech_d, barrel_d = barrel_d,
                     wall_offset = wall_offset, gaps = gaps,
                     clip_align = clip_align, cup_depth = cup_depth, floor_t = floor_t,
                     drain_d = drain_d, cup_plate_h = cup_plate_h,
                     clip_h = clip_h, clip_wall = clip_wall, snap = snap,
                     clip_clearance = clip_clearance,
                     clip_plate_h = clip_plate_h, clip_row = clip_row,
                     magnets_x = magnets_x,
                     magnets_z = magnets_z, modular = modular,
                     print_slot = print_slot, spacing = 12) {
    bd = as_list(breech_d);
    n = len(bd);
    cup_clip_part(part, barrel_layout(breech_d, barrel_d, wall_offset, gaps, clip_wall,
                                      clip_clearance, clip_align),
                  [for (d = bd) grow(d, item_clearance)],
                  [for (i = [0 : n - 1]) grow(per(barrel_d, i), clip_clearance)],
                  cup_depth + floor_t, floor_t, drain_d, 0, cup_plate_h,
                  clip_h, clip_wall, [for (i = [0 : n - 1]) sx(per(barrel_d, i)) * snap],
                  clip_plate_h, clip_row, magnets_x, magnets_z, modular, print_slot,
                  spacing);
}

barrel_holder();
