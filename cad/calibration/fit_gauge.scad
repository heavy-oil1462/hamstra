// Fit gauge: cheap test slices of the real holder geometry, to find the
// diameters, clearances and snap openings that hold your own suppressors,
// barrels and rifles before printing full holders. No back plate, no
// magnets, a few grams each.
//
//   rings  a grid of thin snap clip slices: columns step the clearance,
//          rows step the snap opening (fraction of the clip bore). A
//          clip ring's bore is ring_d times clip_fit plus the clearance,
//          as in the holders. A snap of 1 or more prints a closed ring at
//          ring_d plus the clearance, which tests the fit of a cup or
//          cradle. Measure the item, set ring_d, press the item into each
//          ring. Use the winning clearance and snap in the model.
//   slots  a thin slice of the gun rack comb with one slot per width,
//          made by the rack's own profile code. Drop the muzzle end of
//          each gun into the slots to pick its slot_w.
//   cups   thin slices of a cup bore for an oblong breech (an over and
//          under monoblock), wall toward the label tab: columns step
//          the clearance, rows step the front corner radius (half the
//          width = round). Push the breech in from the top, back to the
//          tab, and use the winning [width, depth, radius] and clearance
//          in the model. cup_gauge() is also used by cad/my_safe.
//
// Every ring and slot is labelled. Prints flat as modeled.

include <../design_params.scad>
use <../lib/holders.scad>
use <../safe/gun_rack.scad>

// Which gauge to show
part = "rings"; // [rings, slots, cups]

/* [Rings] */
// Measured diameter of the suppressor, barrel or breech
ring_d = 50;
// Clearances to try, added to the bore (one column each)
clearances = [0.2, 0.6, 1.0];
// Snap openings to try as a fraction of the clip bore, 1 = closed (one row each)
snaps = [0.8, 0.85, 0.9, 1];
// Ring wall, as clip_wall in the models
ring_wall = 3;
// Ring height
ring_h = 5;

/* [Rack slots] */
// Slot widths to try
slot_widths = [20, 22, 38, 42];
// Finger between slots
slot_gap = 10;
// Slot depth
slot_depth = 30;
// Gauge thickness
slot_t = 4;

/* [Cup slices] */
// Oblong breech to test, measured: [width along the wall, depth]
cup_shape = [30, 60];
// Front corner radii to try, one row each (half the width = round)
front_radii = [15, 6, 2];
// Clearances to try, added like item_clearance (one column each)
cup_clearances = [0.6, 1.0, 1.4];
// Slice height
cup_h = 4;

label_size = 3.5;
label_depth = 0.6;

module label(txt) {
    linear_extrude(label_depth + eps)
        text(txt, size = label_size, halign = "center", valign = "center");
}

// One clip slice: the bore and snap opening of holder_row, a label tab
// where the web would meet the back plate.
module gauge_ring(d, c, s) {
    fd = s < 1 ? d * clip_fit : d;
    r = (fd + c) / 2;
    tab = [22, 13];
    difference() {
        union() {
            cylinder(r = r + ring_wall, h = ring_h);
            translate([-tab[0] / 2, r, 0]) cube([tab[0], tab[1], ring_h]);
        }
        translate([0, 0, -eps]) cylinder(r = r, h = ring_h + 2 * eps);
        if (s < 1) snap_opening(r, ring_wall, fd * s, -eps, ring_h);
        translate([0, r + ring_wall + 6.5, ring_h - label_depth]) label(str("c", c));
        translate([0, r + ring_wall + 1.5, ring_h - label_depth]) label(str("s", s));
    }
}

module ring_gauge() {
    pitch_x = ring_d + max(clearances) + 2 * ring_wall + 4;
    pitch_y = ring_d + max(clearances) + ring_wall + 13 + 4;
    for (i = [0 : len(clearances) - 1], j = [0 : len(snaps) - 1])
        translate([i * pitch_x, j * pitch_y, 0])
            gauge_ring(ring_d, clearances[i], snaps[j]);
}

// One cup slice: the holder_row bore of shape s grown by c, wall thick,
// with a label tab on the wall side.
module gauge_cup(s, c, h = cup_h) {
    g = grow(s, c);
    tab = [22, 13];
    difference() {
        union() {
            linear_extrude(h) offset(r = wall) bore2d(g);
            translate([-tab[0] / 2, sy(g) / 2, 0]) cube([tab[0], tab[1], h]);
        }
        translate([0, 0, -eps]) linear_extrude(h + 2 * eps) bore2d(g);
        translate([0, sy(g) / 2 + wall + 6.5, h - label_depth]) label(str("c", c));
        translate([0, sy(g) / 2 + wall + 1.5, h - label_depth]) label(str("r", s[2]));
    }
}

// Grid of cup slices for an oblong [width, depth]: a column per
// clearance, a row per front corner radius.
module cup_gauge(shape = cup_shape, radii = front_radii, clearances = cup_clearances,
                 h = cup_h) {
    assert(is_list(shape), "cup_shape is [width, depth]");
    pitch_x = sx(shape) + max(clearances) + 2 * wall + 4;
    pitch_y = sy(shape) + max(clearances) + wall + 13 + 4;
    for (i = [0 : len(clearances) - 1], j = [0 : len(radii) - 1])
        translate([i * pitch_x, j * pitch_y, 0])
            gauge_cup([shape[0], shape[1], radii[j]], clearances[i], h);
}

module slot_gauge() {
    ws = slot_widths;
    n = len(ws);
    base = 10;   // strip under the deepest slot, carries the labels
    edge = slot_gap;
    xs = slot_xs(ws, slot_gap, edge);
    l = xs[n - 1] + ws[n - 1] / 2 + edge;
    depth = base + max(ws) / 2 + slot_depth;
    difference() {
        linear_extrude(slot_t)
            comb_profile([[0, l, depth]], ws, xs, [for (w = ws) base], 3);
        for (i = [0 : n - 1])
            translate([xs[i], base / 2, slot_t - label_depth]) label(str(ws[i]));
    }
}

if (part == "rings") ring_gauge();
else if (part == "slots") slot_gauge();
else if (part == "cups") cup_gauge();
else assert(false, str("unknown part: ", part));
