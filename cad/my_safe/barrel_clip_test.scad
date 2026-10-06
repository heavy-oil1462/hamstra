// My safe: test slices of the spare barrel clips. The first printed clips
// were all too loose, so this prints three sizes of each barrel's clip as
// short slices: the real clip ring (holder_row with the barrel holder's
// wall, clearance, snap and chamfer) on a thin bar in place of the back
// plate, no magnets. One print, a row per barrel, each slice engraved on
// its bar: 9 for the 9.3, 6 for the 6 mm Creedmoor, B for the B25, then
// a dash and the variant 1 to 3 (B-2). Snap each barrel into its three,
// then copy the winning size into barrel_d in barrels.scad (the middle
// ones are there).
//
// The rings stretch a lot, so the sizes run well under the barrels. The
// round barrels try 15, 20 and 25 percent under the barrel size (18.6 and
// 25.2). The B25 figure 8 keeps the 21 mm barrel spacing and steps the
// inner lobe 18, 17, 16 (about 15, 20 and 25 percent under 21), the outer
// lobe 2 mm smaller and the waist about 0.85 of the inner lobe.

include <../design_params.scad>
use <../safe/barrel_holder.scad>
use <../lib/holders.scad>

/* [Sizes] */
// 9.3 clip sizes to try (barrel 18.6)
sizes_9_3 = [15.8, 14.9, 14];
// 6 mm Creedmoor clip sizes to try (barrel 25.2)
sizes_6mm = [21.4, 20.2, 18.9];
// B25 clips to try, eight(inner lobe, outer lobe, barrel center distance,
// waist)
sizes_b25 = [eight(18, 16, 21, 15.5), eight(17, 15, 21, 14.5), eight(16, 14, 21, 13.5)];

/* [Slices] */
// Slice height
slice_h = 6;
// Space between slices
spacing = 6;
// Label engraving on top of the bar
label_size = 4;
// Engraving depth
label_depth = 0.6;

// One clip slice for barrel size s, the bar along x at y in [-back_t, 0],
// the ring toward -y.
module clip_slice(s, txt) {
    fit = barrel_clip_fit();
    w = fit[0];
    g = grow(s, fit[1]);
    difference() {
        union() {
            holder_row([g], slice_h, [0], [holder_min_axis(g, 0.6)], w = w, bottom = "open",
                       front_gaps = front_d(s) * fit[2], chamfer = 0.6);
            translate([-sx(g) / 2 - w, -back_t, 0]) cube([sx(g) + 2 * w, back_t, slice_h]);
        }
        translate([0, -back_t / 2, slice_h - label_depth])
            linear_extrude(label_depth + eps)
                text(txt, size = label_size, halign = "center", valign = "center");
    }
}

// Depth of a slice from the back of the bar to the front of the ring.
function slice_depth(s) = let (g = grow(s, barrel_clip_fit()[1]))
    holder_min_axis(g, 0.6) + sy(g) / 2 + barrel_clip_fit()[0];

// Width of a slice.
function slice_w(s) = sx(grow(s, barrel_clip_fit()[1])) + 2 * barrel_clip_fit()[0];

// Sum of the first n entries of v.
function sum(v, n) = n <= 0 ? 0 : v[n - 1] + sum(v, n - 1);

module barrel_clip_test() {
    rows = [sizes_9_3, sizes_6mm, sizes_b25];
    names = ["9", "6", "B"];
    depths = [for (r = rows) max([for (s = r) slice_depth(s)])];
    for (j = [0 : len(rows) - 1]) {
        r = rows[j];
        ws = [for (s = r) slice_w(s)];
        // rows stack toward -y, the bar at the back of each row
        translate([0, -(sum(depths, j) + j * spacing), 0])
            for (i = [0 : len(r) - 1])
                translate([sum(ws, i) + i * spacing + ws[i] / 2, 0, 0])
                    clip_slice(r[i], str(names[j], "-", i + 1));
    }
}

barrel_clip_test();
