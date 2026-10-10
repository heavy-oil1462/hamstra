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
// Snap opening as a fraction of the clip bore (below 1 snaps); the bore
// is the suppressor diameter times clip_fit (design_params.scad)
snap = 0.85;
// Clearance added to the clip bore
clip_clearance = 0.6;
// Clip back plate height
clip_plate_h = 40;
// Clips in one row; false prints each clip as its own piece
clip_row = true;

/* [Back plate] */
// End the back plate flush with the web of the outer holder at both row
// ends, so the outer holders overhang it (for a tight spot on the wall;
// magnets move in with the ends)
plate_to_webs = false;

/* [Modular] */
// Print one module per slot, joined side by side with sliding dovetails
modular = false;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

/* [Friction pad] */
// Show this part's friction pad instead (print in TPU, or use as the
// template to cut silicone sheet; pad_t in design_params.scad)
pad = false;

/* [Magnets] */
// Magnet columns on the cradle row (the cradle carries the suppressors' weight; per module when modular)
magnets_x = 4;
// Magnet columns on the clip row (it only keeps items in)
clip_magnets_x = 2;
// Magnet rows on the cradle row
magnets_z = 2;
// Magnet rows on the clip row
clip_magnets_z = 1;

// Slot layout [xs, axes, bounds] for these knobs: the holder uses it, and
// so does the assembly to stand suppressors in it.
function suppressor_layout(suppressor_d = suppressor_d, wall_offset = wall_offset,
                           gaps = gaps, clip_wall = clip_wall,
                           clip_clearance = clip_clearance) =
    let (sd = as_list(suppressor_d))
    holder_pair_layout([for (d = sd) d + item_clearance], wall,
                       [for (d = sd) d * clip_fit + clip_clearance], clip_wall, gaps,
                       wall_offset);

// Height of the cradle floor the suppressors stand on.
function suppressor_floor_t() = floor_t;

// Height of the clip ring, at the bottom of the clip piece.
function suppressor_clip_h() = clip_h;

// Clip ring [clearance, snap, wall], for test slices of the clip.
function suppressor_clip_ring() = [clip_clearance, snap, clip_wall];

module suppressor_holder(part = part, suppressor_d = suppressor_d,
                         wall_offset = wall_offset, gaps = gaps,
                         cup_depth = cup_depth, floor_t = floor_t,
                         drain_d = drain_d, cup_snap = cup_snap,
                         cup_plate_h = cup_plate_h, clip_h = clip_h,
                         clip_wall = clip_wall, snap = snap,
                         clip_clearance = clip_clearance,
                         clip_plate_h = clip_plate_h, clip_row = clip_row,
                         magnets_x = magnets_x, clip_magnets_x = clip_magnets_x,
                         magnets_z = magnets_z, clip_magnets_z = clip_magnets_z,
                         plate_to_webs = plate_to_webs,
                         modular = modular, print_slot = print_slot,
                         spacing = 12, pad = pad) {
    sd = as_list(suppressor_d);
    assert(part == "cradle" || part == "clip", str("unknown part: ", part));
    layout = suppressor_layout(sd, wall_offset, gaps, clip_wall, clip_clearance);
    xs = layout[0];
    b = layout[2];
    n = len(b) - 1;
    cup_ds = [for (d = sd) d + item_clearance];
    clip_ds = [for (d = sd) d * clip_fit + clip_clearance];
    // this piece's own outer webs: the cup and the clip differ in size
    ds = part == "cradle" ? cup_ds : clip_ds;
    bounds = !plate_to_webs ? b
        : [for (i = [0 : n]) i == 0 ? xs[0] - holder_web_w(ds[0]) / 2
                           : i == n ? xs[n - 1] + holder_web_w(ds[n - 1]) / 2 : b[i]];
    // a modular end module must keep some plate
    assert(bounds[0] < bounds[1] - 2 * magnet_edge && bounds[n] > bounds[n - 1] + 2 * magnet_edge,
           "plate_to_webs leaves an end module without a plate");
    let ($pad = pad, $square_bottom = plate_to_webs) cup_clip_part(part == "cradle" ? "cup" : "clip",
                  [xs, layout[1], bounds, layout[3]], cup_ds, clip_ds,
                  cup_depth + floor_t, floor_t, drain_d, [for (d = sd) d * cup_snap],
                  cup_plate_h, clip_h, clip_wall, [for (d = sd) d * clip_fit * snap],
                  clip_plate_h, clip_row, magnets_x, magnets_z, modular, print_slot,
                  spacing, clip_magnets_x, clip_magnets_z);
}

suppressor_holder();
