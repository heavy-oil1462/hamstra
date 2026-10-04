// Magnet pocket gauge: find magnet_clearance for your printer, profile and
// filament before printing the real models.
//
// One pocket per candidate clearance in both orientations the models use:
//   - the flat bar's pockets open onto the print bed (gun rack style)
//   - the standing fin's pockets are horizontal teardrops (upright models)
// Press a magnet into each. Pick the tightest clearance a magnet goes into
// fully flush by hand (it gets glued anyway, but a sloppy pocket lets the
// glue set crooked) and type it into design_params.scad.

include <../design_params.scad>
use <../lib/magnets.scad>

clearances = [0, 0.1, 0.2, 0.3, 0.4];

gauge_pitch = magnet_d + 8;
gauge_l = len(clearances) * gauge_pitch;
gauge_w = magnet_d + 18;        // flat bar depth: pockets plus labels
fin_h = back_t + magnet_d + 10; // standing fin height

module label(txt) {
    linear_extrude(0.6 + eps)
        text(txt, size = 4, halign = "center", valign = "center");
}

module magnet_pocket_gauge() {
    difference() {
        union() {
            cube([gauge_l, gauge_w, back_t]);
            cube([gauge_l, back_t, fin_h]);
        }
        for (i = [0 : len(clearances) - 1]) {
            x = (i + 0.5) * gauge_pitch;
            c = clearances[i];
            // flat pocket, opening on the bed
            translate([x, back_t + 2 + magnet_d / 2, 0])
                magnet_pocket(teardrop = false, clearance = c);
            // horizontal pocket into the fin's outer face (y = 0), roof up
            translate([x, 0, back_t + 2 + magnet_d / 2]) rotate([-90, 0, 0]) rotate([0, 0, 180])
                magnet_pocket(teardrop = true, clearance = c);
            translate([x, gauge_w - 5, back_t - 0.6]) label(str(c));
        }
    }
}

magnet_pocket_gauge();
