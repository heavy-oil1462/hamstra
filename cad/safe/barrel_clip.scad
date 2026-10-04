// Barrel clip: the top half of a spare barrel holder. Open-front snap
// rings that the barrel presses into; pair it with barrel_cup.scad.
//
// Barrel spacing and wall offset are shared with the cup, see
// barrel_pitch and barrel_axis_y in design_params.scad.
//
// Prints as modeled: back plate vertical, rings standing on the bed. The
// rings sit at the bottom of the plate so nothing overhangs.

include <../design_params.scad>
use <../lib/magnets.scad>
use <../lib/holders.scad>

/* [Barrel] */
// Barrel diameter where the clip grips it, measured
barrel_d = 20;
// Number of barrels side by side
count = 2;

/* [Clip] */
// Clip ring height
clip_h = 15;
// Clip ring wall, thicker snaps harder
clip_wall = 3;
// Snap opening as a fraction of the barrel diameter (below 1 snaps)
snap = 0.85;
// Clearance added to the barrel diameter (small, the clip should hug)
clip_clearance = 0.4;

/* [Magnets] */
// Back plate height
plate_h = 40;
// Magnet columns
magnets_x = 2;
// Magnet rows
magnets_z = 2;

module barrel_clip(barrel_d = barrel_d, count = count, clip_h = clip_h,
                   clip_wall = clip_wall, snap = snap,
                   clip_clearance = clip_clearance,
                   plate_h = plate_h, magnets_x = magnets_x,
                   magnets_z = magnets_z) {
    d = barrel_d + clip_clearance;
    wall_mount(holder_row_w(count, d, clip_wall, barrel_pitch), max(plate_h, clip_h),
               magnets_x, magnets_z)
        holder_row(count, d, clip_h, w = clip_wall, pitch = barrel_pitch,
                   axis_y = barrel_axis_y,
                   bottom = "open", front_gap = barrel_d * snap, chamfer = 0.6);
}

barrel_clip();
