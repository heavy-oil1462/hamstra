// Magnet pocket gauge: find magnet_clearance for your printer, profile and
// filament before printing the real models.
//
// Two separate plates, one per orientation the models print their
// pockets in, each a real back plate (back_t thick, pockets with the
// back_skin floor), with one pocket per candidate clearance:
//   - the flat plate lies on the bed, pockets opening downward, like
//     the gun rack; labels on top
//   - the standing plate prints on its edge like the upright holders,
//     teardrop pockets in its back face; labels on its front face
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

// Lying on the bed: x along, y across, pockets open at z = 0.
module flat_plate() {
    difference() {
        cube([gauge_l, plate_w, back_t]);
        for (i = [0 : len(clearances) - 1]) {
            translate([gauge_x(i), pocket_m, 0])
                magnet_pocket(teardrop = false, clearance = clearances[i]);
            translate([gauge_x(i), plate_w - 5, back_t - label_depth]) label(str(clearances[i]));
        }
    }
}

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
    flat_plate();
    translate([0, -10, 0]) standing_plate();
}

magnet_pocket_gauge();
