// Suppressor holder: one tall back plate per row of suppressors. Each
// suppressor stands on the floor plate of a cradle at the bottom and
// snaps into an open-front clip near the top, so it can neither tip out
// nor slide off. Cradle and clip share one slot layout, so each
// suppressor stands plumb. Insert the bottom into the cradle, then push
// the top into the clip.
//
// Every slot has its own diameter, wall offset and gap to the next one.
// Per-slot knobs take one entry per slot, or a single number for all
// (a short list repeats its last entry).
//
// Prints lying on its back: back plate flat on the bed, magnet pockets
// opening downward, the cradle and clip as open troughs standing up from
// it. Both are open at the front, so no part of them overhangs: the snap
// arms curl in by less than 45 degrees for any snap above 0.71. The
// module builds it upright (wall at y = 0, like the other holders) and
// lays it down at the end; the assembly stands it back up.

include <../design_params.scad>
use <../lib/magnets.scad>
use <../lib/holders.scad>

/* [Slots] */
// Outer diameter of each suppressor, measured. One entry per slot.
suppressor_d = [50, 44];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0];
// Space between neighbouring holders, one entry per pair
gaps = [6];

/* [Bottom cradle] */
// Cradle height above the floor, how far the suppressor sits down in it
cup_depth = 20;
// Floor thickness, the plate the suppressor stands on
floor_t = 3;
// Drain hole in the floor (0 for none)
drain_d = 10;
// Cradle front opening as a fraction of the suppressor diameter (1 = no snap)
cup_snap = 0.95;

/* [Top clip] */
// Height of the clip's top edge above the bed. Put it above the
// suppressor's middle, below its top.
clip_top = 130;
// Clip ring height
clip_h = 15;
// Clip ring wall, thicker snaps harder
clip_wall = 3;
// Snap opening as a fraction of the suppressor diameter (below 1 snaps)
snap = 0.85;
// Clearance added to the suppressor diameter in the clip (small, it should hug)
clip_clearance = 0.6;

/* [Modular] */
// Print one module per slot, joined side by side with sliding dovetails
modular = false;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

/* [Magnets] */
// Magnet columns (per module when modular)
magnets_x = 2;
// Magnet rows
magnets_z = 3;

module suppressor_holder(suppressor_d = suppressor_d, wall_offset = wall_offset,
                         gaps = gaps, cup_depth = cup_depth, floor_t = floor_t,
                         drain_d = drain_d, cup_snap = cup_snap,
                         clip_top = clip_top, clip_h = clip_h,
                         clip_wall = clip_wall, snap = snap,
                         clip_clearance = clip_clearance,
                         magnets_x = magnets_x, magnets_z = magnets_z,
                         modular = modular, print_slot = print_slot,
                         spacing = 12) {
    sd = as_list(suppressor_d);
    n = len(sd);
    cup_ds = [for (d = sd) d + item_clearance];
    clip_ds = [for (d = sd) d + clip_clearance];
    layout = holder_pair_layout(cup_ds, wall, clip_ds, clip_wall, gaps, wall_offset);
    xs = layout[0];
    axes = layout[1];
    cup_h = cup_depth + floor_t;
    assert(clip_top - clip_h >= cup_h, "the clip overlaps the cradle, raise clip_top");
    rotate([-90, 0, 0])
        wall_row(layout[2], clip_top, magnets_x, magnets_z, teardrop = false,
                 modular = modular, print_slot = print_slot, spacing = spacing) {
            holder_row(pick(cup_ds, $slots), cup_h, pick(xs, $slots), pick(axes, $slots),
                       bottom = drain_d > 0 ? "lip" : "closed", floor_t = floor_t,
                       lips = [for (i = $slots) (cup_ds[i] - drain_d) / 2],
                       front_gaps = [for (i = $slots) sd[i] * cup_snap]);
            translate([0, 0, clip_top - clip_h])
                holder_row(pick(clip_ds, $slots), clip_h, pick(xs, $slots),
                           pick(axes, $slots), w = clip_wall, bottom = "open",
                           front_gaps = [for (i = $slots) sd[i] * snap], chamfer = 0.6);
        }
}

suppressor_holder();
