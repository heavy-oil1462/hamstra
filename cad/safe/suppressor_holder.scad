// Suppressor holder: a row of upright sleeves on a magnet back plate.
// The suppressor stands in its sleeve resting on a bottom lip; the open
// center lets the thread end and any moisture through.
//
// Prints as modeled: back plate vertical, sleeves standing on the bed.

include <../design_params.scad>
use <../lib/magnets.scad>
use <../lib/holders.scad>

/* [Suppressor] */
// Outer diameter of the suppressor, measured
suppressor_d = 50;
// Number of suppressors side by side
count = 2;

/* [Holder] */
// Sleeve height, how much of the suppressor it hugs
sleeve_h = 60;
// Width of the bottom lip the suppressor rests on
lip = 5;
// Space between neighbouring sleeves
gap = 4;

/* [Magnets] */
// Back plate height (at least sleeve_h)
plate_h = 60;
// Magnet columns
magnets_x = 2;
// Magnet rows
magnets_z = 2;

module suppressor_holder(suppressor_d = suppressor_d, count = count,
                         sleeve_h = sleeve_h, lip = lip, gap = gap,
                         plate_h = plate_h, magnets_x = magnets_x,
                         magnets_z = magnets_z) {
    d = suppressor_d + item_clearance;
    wall_mount(holder_row_w(count, d, wall, holder_pitch(d, wall, gap)), max(plate_h, sleeve_h),
               magnets_x, magnets_z)
        holder_row(count, d, sleeve_h, gap = gap, bottom = "lip", lip = lip);
}

suppressor_holder();
