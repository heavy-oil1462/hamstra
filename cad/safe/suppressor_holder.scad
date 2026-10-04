// Suppressor holder, two pieces from one slot layout: a cradle row low on
// the wall that the suppressors stand in, and a clip row higher up that
// they snap into, so they can neither tip out nor slide off. Two short
// pieces print far faster than one tall plate. Mount the clip row
// straight above the cradle row; one clip height for all slots is fine,
// a clip set for the shortest suppressor still holds the long ones.
// Insert the bottom into the cradle, then push the top into the clip.
//
// Every slot has its own diameter, wall offset and gap to the next one.
// Per-slot knobs take one entry per slot, or a single number for all
// (a short list repeats its last entry).
//
// Prints as modeled: back plate vertical, cradles and clips standing on
// the bed. The cradle is open at the front like the clip, its floor
// whole. Pick the piece with `part`; regen_all.py exports both.

include <../design_params.scad>
use <../lib/magnets.scad>
use <../lib/holders.scad>

// Which piece to show
part = "cradle"; // [cradle, clip]

/* [Slots] */
// Outer diameter of each suppressor, measured. One entry per slot.
suppressor_d = [50, 44];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0];
// Space between neighbouring holders, one entry per pair
gaps = [6];

/* [Cradle] */
// Cradle height above the floor, how far the suppressor sits down in it
cup_depth = 20;
// Floor thickness, the plate the suppressor stands on
floor_t = 3;
// Drain hole in the floor (0 for none)
drain_d = 10;
// Cradle front opening as a fraction of the suppressor diameter (1 = no snap)
cup_snap = 0.95;
// Cradle back plate height (at least cup depth plus floor)
cup_plate_h = 40;

/* [Clip] */
// Clip ring height
clip_h = 15;
// Clip ring wall, thicker snaps harder
clip_wall = 3;
// Snap opening as a fraction of the suppressor diameter (below 1 snaps)
snap = 0.85;
// Clearance added to the suppressor diameter in the clip (small, it should hug)
clip_clearance = 0.6;
// Clip back plate height
clip_plate_h = 40;
// Clips in one row; false prints each clip as its own piece
clip_row = true;

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
// so does the assembly to stand suppressors in it.
function suppressor_layout(suppressor_d = suppressor_d, wall_offset = wall_offset,
                           gaps = gaps, clip_wall = clip_wall,
                           clip_clearance = clip_clearance) =
    let (sd = as_list(suppressor_d))
    holder_pair_layout([for (d = sd) d + item_clearance], wall,
                       [for (d = sd) d + clip_clearance], clip_wall, gaps, wall_offset);

// Height of the cradle floor the suppressors stand on.
function suppressor_floor_t() = floor_t;

// Height of the clip ring, at the bottom of the clip piece.
function suppressor_clip_h() = clip_h;

module suppressor_holder(part = part, suppressor_d = suppressor_d,
                         wall_offset = wall_offset, gaps = gaps,
                         cup_depth = cup_depth, floor_t = floor_t,
                         drain_d = drain_d, cup_snap = cup_snap,
                         cup_plate_h = cup_plate_h, clip_h = clip_h,
                         clip_wall = clip_wall, snap = snap,
                         clip_clearance = clip_clearance,
                         clip_plate_h = clip_plate_h, clip_row = clip_row,
                         magnets_x = magnets_x, magnets_z = magnets_z,
                         modular = modular, print_slot = print_slot,
                         spacing = 12) {
    sd = as_list(suppressor_d);
    assert(part == "cradle" || part == "clip", str("unknown part: ", part));
    cup_clip_part(part == "cradle" ? "cup" : "clip",
                  suppressor_layout(sd, wall_offset, gaps, clip_wall, clip_clearance),
                  [for (d = sd) d + item_clearance], [for (d = sd) d + clip_clearance],
                  cup_depth + floor_t, floor_t, drain_d, [for (d = sd) d * cup_snap],
                  cup_plate_h, clip_h, clip_wall, [for (d = sd) d * snap],
                  clip_plate_h, clip_row, magnets_x, magnets_z, modular, print_slot,
                  spacing);
}

suppressor_holder();
