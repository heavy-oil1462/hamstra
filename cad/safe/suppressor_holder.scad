// Suppressor holder: a row of upright sleeves on a magnet back plate.
// The suppressor stands in its sleeve resting on a bottom lip; the open
// center lets the thread end and any moisture through.
//
// Every slot has its own diameter, wall offset and gap to the next one.
// Per-slot knobs take one entry per slot, or a single number for all
// (a short list repeats its last entry).
//
// Prints as modeled: back plate vertical, sleeves standing on the bed.

include <../design_params.scad>
use <../lib/magnets.scad>
use <../lib/holders.scad>

/* [Slots] */
// Outer diameter of each suppressor, measured. One entry per slot.
suppressor_d = [50, 44];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0];
// Space between neighbouring sleeves, one entry per pair
gaps = [4];

/* [Holder] */
// Sleeve height, how much of the suppressor it hugs
sleeve_h = 60;
// Width of the bottom lip the suppressor rests on
lip = 5;

/* [Magnets] */
// Back plate height (at least sleeve_h)
plate_h = 60;
// Magnet columns
magnets_x = 2;
// Magnet rows
magnets_z = 2;

module suppressor_holder(suppressor_d = suppressor_d, wall_offset = wall_offset,
                         gaps = gaps, sleeve_h = sleeve_h, lip = lip,
                         plate_h = plate_h, magnets_x = magnets_x,
                         magnets_z = magnets_z) {
    ds = [for (d = as_list(suppressor_d)) d + item_clearance];
    wall_mount(holder_row_w(ds, wall, gaps), max(plate_h, sleeve_h),
               magnets_x, magnets_z)
        holder_row(ds, sleeve_h, holder_xs(ds, wall, gaps),
                   holder_axes(ds, 1, wall_offset), bottom = "lip", lips = lip);
}

suppressor_holder();
