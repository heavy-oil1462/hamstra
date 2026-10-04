// Round holder helpers shared by the safe models. Lives under cad/lib/ so
// regen_all.py does not export it as a printable model.
//
// Same convention as magnets.scad: wall at y = 0, back plate in
// [-back_t, 0], holders stick out toward -y, z up, bottom on the bed.
//
// Holder rows are configured per slot. Every per-slot argument takes a
// list (one entry per slot) or a single number for all slots; a list
// shorter than the slot count repeats its last entry. The slot count
// comes from the diameter list.

include <../design_params.scad>

// Per-slot value i from a number or a list (last entry repeats).
function per(v, i) = is_list(v) ? v[min(i, len(v) - 1)] : v;

// Diameter list from a number or a list.
function as_list(v) = is_list(v) ? v : [v];

// Closest distance from the wall to the axis of a holder with bore d:
// the bore and its entry chamfer stay 1 mm clear of the back plate.
function holder_min_axis(d, chamfer) = back_t + chamfer + 1 + d / 2;

// Wall to axis distance per slot: the closest allowed plus the offset.
function holder_axes(ds, chamfer, offsets) =
    [for (i = [0 : len(ds) - 1]) holder_min_axis(ds[i], chamfer) + per(offsets, i)];

// Uncentered holder centers: neighbours sit gap apart, wall to wall.
function _holder_xs(ds, w, gaps, i = 0, x = 0) =
    i >= len(ds) ? [] :
    concat([x], i + 1 < len(ds)
        ? _holder_xs(ds, w, gaps, i + 1, x + ds[i] / 2 + 2 * w + per(gaps, i) + ds[i + 1] / 2)
        : []);

// Width of a holder row from outer wall to outer wall.
function holder_row_w(ds, w, gaps) =
    let (xs = _holder_xs(ds, w, gaps), n = len(ds))
    xs[n - 1] + ds[n - 1] / 2 + ds[0] / 2 + 2 * w;

// Holder centers, the row centered on x = 0.
function holder_xs(ds, w, gaps) =
    let (xs = _holder_xs(ds, w, gaps), x0 = -holder_row_w(ds, w, gaps) / 2 + ds[0] / 2 + w)
    [for (x = xs) x + x0];

// Shared layout for two holder rows that must keep each item plumb (a cup
// low on the wall, a clip higher up): spaced and set off the wall by the
// fatter of the two per slot. Returns [xs, axes, row width].
function holder_pair_layout(ds1, w1, ds2, w2, gaps, offsets) =
    let (w = max(w1, w2),
         ds = [for (i = [0 : len(ds1) - 1]) max(ds1[i], ds2[i])])
    [holder_xs(ds, w, gaps), holder_axes(ds, 1, offsets), holder_row_w(ds, w, gaps)];

// A row of round holders from z = 0 to z = h, each merged into the back
// plate by a web. Positions are explicit so two parts can share a layout.
//   ds         bore diameter per slot (item diameter plus clearance)
//   xs         center x per slot
//   axes       wall to axis distance per slot
//   w          holder wall
//   bottom     "closed": floor of floor_t
//              "lip":    floor_t ring the item rests on, open center
//              "open":   no floor at all (clips)
//   lips       ring width per slot for "lip"
//   front_gaps snap opening width per slot toward -y, 0 for none; it
//              starts above the floor so the floor stays whole
//   chamfer    entry chamfer at the top of the bore
module holder_row(ds, h, xs, axes, w = wall, bottom = "closed", floor_t = 2,
                  lips = 4, front_gaps = 0, chamfer = 1) {
    for (i = [0 : len(ds) - 1])
        assert(axes[i] >= holder_min_axis(ds[i], chamfer) - eps,
               str("slot ", i + 1, ": holder bore would cut into the back plate"));
    difference() {
        union()
            for (i = [0 : len(ds) - 1]) translate([xs[i], -axes[i], 0]) {
                r = ds[i] / 2;
                cylinder(r = r + w, h = h);
                // web tying the holder into the plate
                translate([-r * 0.7, 0, 0]) cube([r * 1.4, axes[i] - back_t / 2, h]);
            }
        for (i = [0 : len(ds) - 1]) translate([xs[i], -axes[i], 0]) {
            r = ds[i] / 2;
            z0 = bottom == "open" ? -eps : floor_t;
            translate([0, 0, z0]) cylinder(r = r, h = h - z0 + eps);
            translate([0, 0, h - chamfer]) cylinder(r1 = r, r2 = r + chamfer + eps, h = chamfer + eps);
            if (bottom == "lip")
                translate([0, 0, -eps]) cylinder(r = r - per(lips, i), h = floor_t + 2 * eps);
            if (per(front_gaps, i) > 0) snap_opening(r, w, per(front_gaps, i), bottom == "open" ? -eps : floor_t, h);
        }
    }
}

// Cutter for a snap opening toward -y, flared outward so the item is
// guided in. Origin at the holder center, runs from z0 to h.
module snap_opening(r, w, g, z0, h) {
    flare = w;
    yc = -sqrt(max(r * r - g * g / 4, 0));   // where the slot meets the bore
    translate([0, 0, z0])
        linear_extrude(h - z0 + eps)
            polygon([[-g / 2, 0], [g / 2, 0], [g / 2, yc],
                     [g / 2 + flare, -r - w - eps], [-g / 2 - flare, -r - w - eps],
                     [-g / 2, yc]]);
}
