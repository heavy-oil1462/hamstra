// My safe: test clips for the spare barrel holder. The first printed
// clips were all too loose, so this prints three sizes of each barrel's
// clip, side by side on one bed, from the real clip geometry of
// barrels.scad (same breech, wall distance, snap and clearance). Each
// clip is engraved on top of its plate with its variant number, 1 to 3
// from left to right as printed. Snap each barrel into its three, then
// copy the winning size into barrel_d in barrels.scad.
//
// The round barrels try 15, 20 and 25 percent under the barrel size (18.6
// and 25.2): the printed rings stretch a lot, so an undersized ring still
// snaps on and then grips. The B25 figure 8 keeps the inner lobe at the measured 21 mm
// (the web holds it rigid, an undersized inner lobe would not let the
// barrel seat) and steps the outer lobe and the waist down 1 mm at a time:
// a tighter wrap on the outer barrel, a harder snap past the waist.
// Magnet pockets are as on the real clips; a winner can be glued up and
// used as is.

include <../design_params.scad>
use <../safe/barrel_holder.scad>
use <../lib/holders.scad>
use <barrels.scad>

// Which barrel's test clips to show
part = "b25"; // [9_3, 6mm, b25]

/* [Sizes] */
// 9.3 clip sizes to try (barrel 18.6)
sizes_9_3 = [15.8, 14.9, 14];
// 6 mm Creedmoor clip sizes to try (barrel 25.2)
sizes_6mm = [21.4, 20.2, 18.9];
// B25 clips to try, eight(inner lobe, outer lobe, barrel center distance,
// waist)
sizes_b25 = [eight(21, 20, 21, 18.5), eight(21, 19, 21, 17.5), eight(21, 18, 21, 16.5)];

/* [Layout] */
// Space between the clips on the bed
spacing = 8;
// Variant number engraving on top of the plate
label_size = 4;
// Engraving depth
label_depth = 0.6;

module barrel_clip_test(part = part) {
    data = my_barrels_data();
    slot = part == "9_3" ? 0 : part == "6mm" ? 1 : part == "b25" ? 2 : -1;
    assert(slot >= 0, str("unknown part: ", part));
    sizes = [sizes_9_3, sizes_6mm, sizes_b25][slot];
    breech = [per(data[0], slot)];
    align = [per(data[5], slot)];
    // one clip piece per size, its plate spanning bounds[0] to bounds[1]
    bounds = [for (s = sizes) barrel_layout(breech_d = breech, barrel_d = [s], wall_offset = 0,
                                            gaps = 0, clip_align = align)[2]];
    widths = [for (b = bounds) b[1] - b[0]];
    xs = [for (i = [0 : len(sizes) - 1])
              (i == 0 ? 0 : sum(widths, i) + i * spacing) - bounds[i][0]];
    for (i = [0 : len(sizes) - 1]) translate([xs[i], 0, 0]) difference() {
        barrel_holder(part = "clip", breech_d = breech, barrel_d = [sizes[i]],
                      wall_offset = 0, gaps = 0, clip_align = align, clip_row = false,
                      modular = false, print_slot = 0, pad = false);
        // on top of the plate, centered on the clip
        translate([(bounds[i][0] + bounds[i][1]) / 2, -back_t / 2,
                   barrel_clip_plate_h() - label_depth])
            linear_extrude(label_depth + eps)
                text(str(i + 1), size = label_size, halign = "center", valign = "center");
    }
}

// Sum of the first n entries of v.
function sum(v, n) = n <= 0 ? 0 : v[n - 1] + sum(v, n - 1);

barrel_clip_test();
