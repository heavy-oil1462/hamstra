// Barrel cup: the bottom half of a spare barrel holder. The breech end of
// a switch barrel stands in a closed cup; barrel_clip.scad holds the
// barrel upright further up the wall.
//
// Barrel spacing and wall offset are shared with the clip, see
// barrel_pitch and barrel_axis_y in design_params.scad.
//
// Prints as modeled: back plate vertical, cups standing on the bed.

include <../design_params.scad>
use <../lib/magnets.scad>
use <../lib/holders.scad>

/* [Barrel] */
// Diameter of the breech end that stands in the cup, measured
breech_d = 32;
// Number of barrels side by side
count = 2;

/* [Holder] */
// Cup depth, inside
cup_depth = 40;
// Cup floor thickness
floor_t = 2;
// Drain hole in the floor (0 for none)
drain_d = 6;

/* [Magnets] */
// Back plate height (at least cup depth plus floor)
plate_h = 50;
// Magnet columns
magnets_x = 2;
// Magnet rows
magnets_z = 2;

module barrel_cup(breech_d = breech_d, count = count, cup_depth = cup_depth,
                  floor_t = floor_t, drain_d = drain_d,
                  plate_h = plate_h, magnets_x = magnets_x,
                  magnets_z = magnets_z) {
    d = breech_d + item_clearance;
    h = cup_depth + floor_t;
    wall_mount(holder_row_w(count, d, wall, barrel_pitch), max(plate_h, h),
               magnets_x, magnets_z)
        holder_row(count, d, h, pitch = barrel_pitch, axis_y = barrel_axis_y,
                   bottom = drain_d > 0 ? "lip" : "closed",
                   floor_t = floor_t, lip = (d - drain_d) / 2);
}

barrel_cup();
