// Dovetail gauge: find dovetail_clearance for your printer, profile and
// filament before printing modular rows.
//
// One key with the tongue and one slotted block per candidate clearance,
// all short slices of the real joint (same profile, same spine). Slide
// the key down into each block from the open bottom. Pick the tightest
// clearance that slides home by hand without wobble and type it into
// design_params.scad. Prints standing as modeled, like the upright models.

include <../design_params.scad>
use <../lib/dovetail.scad>

clearances = [0.1, 0.2, 0.3, 0.4];

gauge_h = 20;               // joint length
gauge_w = 14;               // block width
gauge_pitch = gauge_w + dovetail_d + 6;

module label(txt) {
    translate([gauge_w / 2, -dovetail_spine_t / 2, gauge_h - 0.6])
        linear_extrude(0.6 + eps)
            text(txt, size = 3.5, halign = "center", valign = "center");
}

// Same joint as dovetail_female, but with clearance c and a full-length
// slot so it reads at a glance which one fits.
module gauge_slot(c) {
    translate([0, 0, -eps]) linear_extrude(gauge_h + 2 * eps) dovetail_profile(c);
}

module dovetail_gauge() {
    // the key: a block with the tongue on its right edge
    translate([-gauge_pitch, 0, 0]) {
        translate([0, -dovetail_spine_t, 0]) cube([gauge_w, dovetail_spine_t, gauge_h]);
        translate([gauge_w, 0, 0]) linear_extrude(gauge_h) dovetail_profile();
    }
    for (i = [0 : len(clearances) - 1])
        translate([i * gauge_pitch, 0, 0])
            difference() {
                translate([0, -dovetail_spine_t, 0]) cube([gauge_w, dovetail_spine_t, gauge_h]);
                gauge_slot(clearances[i]);
                label(str(clearances[i]));
            }
}

dovetail_gauge();
