// Round holder helpers shared by the safe models. Lives under cad/lib/ so
// regen_all.py does not export it as a printable model.
//
// Same convention as magnets.scad: wall at y = 0, back plate in
// [-back_t, 0], holders stick out toward -y, z up, bottom on the bed.

include <../design_params.scad>

// Distance from the back plate's front face to a holder bore. Keeps the
// bore and its entry chamfer out of the plate.
function holder_standoff(chamfer) = chamfer + 1;

// Center y of a holder with bore diameter d.
function holder_y(d, chamfer) = -(back_t + holder_standoff(chamfer) + d / 2);

// Center-to-center pitch of a row of holders.
function holder_pitch(d, w, gap) = d + 2 * w + gap;

// Total width of a row of n holders at pitch p.
function holder_row_w(n, d, w, p) = (n - 1) * p + d + 2 * w;

// A row of n round holders, centered on x = 0, merged into the plate by a
// web, from z = 0 to z = h.
//   d        bore diameter (item diameter plus clearance)
//   w        holder wall
//   gap      plastic-free space between neighbouring holders
//   bottom   "closed": floor of floor_t
//            "lip":    floor_t ring the item rests on, open center
//            "open":   no floor at all (clips, sleeves)
//   lip      ring width for "lip"
//   front_gap  > 0 cuts a snap opening of that width toward -y
//   chamfer  entry chamfer at the top of the bore
//   pitch    center to center, defaults to touching walls plus gap
//   axis_y   distance from the wall to the holder axis, defaults to the
//            closest the bore may come to the plate
module holder_row(n, d, h, w = wall, gap = 4, bottom = "closed", floor_t = 2,
                  lip = 4, front_gap = 0, chamfer = 1, pitch, axis_y) {
    p = is_undef(pitch) ? holder_pitch(d, w, gap) : pitch;
    y0 = is_undef(axis_y) ? holder_y(d, chamfer) : -axis_y;
    assert(-y0 >= -holder_y(d, chamfer), "holder bore would cut into the back plate");
    assert(p >= d + w, "holders overlap, raise the pitch");
    xs = [for (i = [0 : n - 1]) (i - (n - 1) / 2) * p];
    r = d / 2;
    difference() {
        union()
            for (x = xs) translate([x, 0, 0]) {
                translate([0, y0, 0]) cylinder(r = r + w, h = h);
                // web tying the holder into the plate
                translate([-r * 0.7, y0, 0]) cube([r * 1.4, -y0 - back_t / 2, h]);
            }
        for (x = xs) translate([x, y0, 0]) {
            z0 = bottom == "open" ? -eps : floor_t;
            translate([0, 0, z0]) cylinder(r = r, h = h - z0 + eps);
            translate([0, 0, h - chamfer]) cylinder(r1 = r, r2 = r + chamfer + eps, h = chamfer + eps);
            if (bottom == "lip") translate([0, 0, -eps]) cylinder(r = r - lip, h = floor_t + 2 * eps);
            if (front_gap > 0) snap_opening(r, w, front_gap, h);
        }
    }
}

// Cutter for a snap opening toward -y, flared outward so the item is
// guided in. Origin at the holder center.
module snap_opening(r, w, g, h) {
    flare = w;
    yc = -sqrt(max(r * r - g * g / 4, 0));   // where the slot meets the bore
    translate([0, 0, -eps])
        linear_extrude(h + 2 * eps)
            polygon([[-g / 2, 0], [g / 2, 0], [g / 2, yc],
                     [g / 2 + flare, -r - w - eps], [-g / 2 - flare, -r - w - eps],
                     [-g / 2, yc]]);
}
