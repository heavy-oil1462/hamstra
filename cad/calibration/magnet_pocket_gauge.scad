// Magnet pocket gauge: find magnet_clearance for your printer, profile and
// filament before printing the real models.
//
// A standing plate printed on its edge exactly like every model's back
// plate (back_t thick, teardrop pockets with the back_skin floor in its
// back face), one pocket per candidate clearance, labels on the front.
// Every model prints its pockets this way, the gun rack included, so this
// one orientation is all that needs calibrating.
// Press a magnet into each until it stops on the floor. Pick the
// tightest clearance a magnet goes into fully by hand (it gets glued
// anyway, but a sloppy pocket lets the glue set crooked) and type it into
// design_params.scad.

include <../design_params.scad>
use <../lib/magnets.scad>

clearances = [0, 0.1, 0.2, 0.3, 0.4];

gauge_pitch = magnet_d + 6;
gauge_l = len(clearances) * gauge_pitch + 4;
pocket_m = magnet_d / 2 + 4;           // pocket center from the plate edge
plate_w = 2 * pocket_m + 8;            // pockets plus a label strip
label_depth = 0.6;

module label(txt) {
    linear_extrude(label_depth + eps)
        text(txt, size = 4, halign = "center", valign = "center");
}

function gauge_x(i) = 2 + (i + 0.5) * gauge_pitch;

// Standing on its edge, modeled like a holder's back plate: back face at
// y = 0, plate toward -y, pockets in the back face with their roof up.
module standing_plate() {
    difference() {
        translate([0, -back_t, 0]) cube([gauge_l, back_t, plate_w]);
        for (i = [0 : len(clearances) - 1]) {
            translate([gauge_x(i), 0, pocket_m]) rotate([90, 0, 0])
                magnet_pocket(teardrop = true, clearance = clearances[i]);
            // label on the front face, reading from the front
            translate([gauge_x(i), -back_t + label_depth, plate_w - 5]) rotate([90, 0, 0])
                label(str(clearances[i]));
        }
    }
}

module magnet_pocket_gauge() {
    standing_plate();
}

magnet_pocket_gauge();
