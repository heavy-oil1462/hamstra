// Holder helpers shared by the safe models. Lives under cad/lib/ so
// regen_all.py does not export it as a printable model.
//
// Same convention as magnets.scad: wall at y = 0, back plate in
// [-back_t, 0], holders stick out toward -y, z up, bottom on the bed.
//
// Holder rows are configured per slot. Every per-slot argument takes a
// list (one entry per slot) or a single number for all slots; a list
// shorter than the slot count repeats its last entry. The slot count
// comes from the size list.

include <../design_params.scad>
use <magnets.scad>

// Per-slot value i from a number or a list (last entry repeats).
function per(v, i) = is_list(v) ? v[min(i, len(v) - 1)] : v;

// Diameter list from a number or a list.
function as_list(v) = is_list(v) ? v : [v];

// Holder shapes. A slot's size is a number (a round item of that
// diameter) or [width, depth]: an oblong item, width along the wall and
// depth away from it, such as an over and under barrel pair stacked
// front to back ([21, 42] for two 21 mm barrels), or a side by side
// pair along the wall ([43, 21.5]). An oblong item may add a third
// value, the corner radius of its front end (away from the wall), for a
// part that is round toward the wall and squarer at the front: an over
// and under monoblock, [28, 67, 3]. Without it both ends are round.
// A third kind is a figure 8 from eight(): two round lobes stacked away
// from the wall, for a clip that grips both barrels of an over and under
// pair, see eight().
function sx(s) = is8(s) ? max(s[1], s[2]) : is_list(s) ? s[0] : s;   // width along the wall
function sy(s) = is8(s) ? s[3] + (s[1] + s[2]) / 2 : is_list(s) ? s[1] : s;   // depth away from the wall
function grow(s, c) = is8(s) ? ["8", s[1] + c, s[2] + c, s[3], s[4] + c]
    : !is_list(s) ? s + c
    : len(s) > 2 ? [s[0] + c, s[1] + c, s[2] + c / 2] : [s[0] + c, s[1] + c];

// Figure 8 shape: an inner lobe of d_in (toward the wall) and an outer
// lobe of d_out, centers pitch apart, joined by a waist of width waist.
// pitch is the barrel center distance (one barrel diameter for touching
// barrels). A waist below the lobes pinches in between the barrels, so
// the inner barrel snaps past it like through a snap opening; a smaller
// outer lobe wraps the outer barrel tighter.
function eight(d_in, d_out, pitch, waist) = ["8", d_in, d_out, pitch, waist];
function is8(s) = is_list(s) && s[0] == "8";

// Diameter of the front end of shape s (away from the wall), where a snap
// opening goes.
function front_d(s) = is8(s) ? s[2] : sx(s);
function shape_max(a, b) = [max(sx(a), sx(b)), max(sy(a), sy(b))];

// Bore outline of shape s centered on the origin: a circle, or a stadium
// along its longer side (y for an over and under, x for a side by side).
// With a front corner radius the front half (-y, away from the wall) is
// a rounded rectangle instead. A figure 8 is not convex: hull its
// convex pieces one at a time (bore_pieces, bore2d(s, k)).
module bore2d(s, k = -1) {
    if (is8(s)) {
        assert(s[4] <= min(s[1], s[2]), "figure 8 waist wider than a lobe");
        y_in = sy(s) / 2 - s[1] / 2;
        y_out = -(sy(s) / 2 - s[2] / 2);
        if (k < 0 || k == 0) translate([0, y_in]) circle(d = s[1]);
        if (k < 0 || k == 1) translate([0, y_out]) circle(d = s[2]);
        if (k < 0 || k == 2) translate([-s[4] / 2, y_out]) square([s[4], y_in - y_out]);
    } else _bore2d_convex(s);
}

// How many convex pieces bore2d(s, k) draws.
function bore_pieces(s) = is8(s) ? 3 : 1;

module _bore2d_convex(s) {
    d = min(sx(s), sy(s));
    module stadium()
        hull() for (k = [-1, 1])
            translate([k * (sx(s) - d) / 2, k * (sy(s) - d) / 2]) circle(d = d);
    // a radius of half the width or more is the round end (and would
    // shrink the rounded rectangle below to nothing)
    if (is_list(s) && len(s) > 2 && s[2] < d / 2 - eps) {
        r = s[2];
        hull() {
            intersection() {
                stadium();
                translate([-sx(s), 0]) square([2 * sx(s), sy(s)]);
            }
            intersection() {
                offset(r = r) offset(delta = -r) square([sx(s), sy(s)], center = true);
                translate([-sx(s), -sy(s)]) square([2 * sx(s), sy(s)]);
            }
        }
    } else stadium();
}

// Closest distance from the wall to the axis of a holder of shape s: the
// bore and its entry chamfer stay 1 mm clear of the back plate.
function holder_min_axis(s, chamfer) = back_t + chamfer + 1 + sy(s) / 2;

// Wall to axis distance per slot: the closest allowed plus the offset.
function holder_axes(ds, chamfer, offsets) =
    [for (i = [0 : len(ds) - 1]) holder_min_axis(ds[i], chamfer) + per(offsets, i)];

// Uncentered holder centers: neighbours sit gap apart, wall to wall.
function _holder_xs(ds, w, gaps, i = 0, x = 0) =
    i >= len(ds) ? [] :
    concat([x], i + 1 < len(ds)
        ? _holder_xs(ds, w, gaps, i + 1,
                     x + sx(ds[i]) / 2 + 2 * w + per(gaps, i) + sx(ds[i + 1]) / 2)
        : []);

// Width of a holder row from outer wall to outer wall.
function holder_row_w(ds, w, gaps) =
    let (xs = _holder_xs(ds, w, gaps), n = len(ds))
    xs[n - 1] + sx(ds[n - 1]) / 2 + sx(ds[0]) / 2 + 2 * w;

// Holder centers, the row centered on x = 0.
function holder_xs(ds, w, gaps) =
    let (xs = _holder_xs(ds, w, gaps), x0 = -holder_row_w(ds, w, gaps) / 2 + sx(ds[0]) / 2 + w)
    [for (x = xs) x + x0];

// Shared layout for two holder rows that must keep each item plumb (a cup
// low on the wall, a clip higher up): spaced and set off the wall by the
// bigger of the two per slot. Returns [xs, axes, bounds, axes2]: bounds
// are the n + 1 slot boundaries along x for wall_row (row ends and gap
// middles), axes2 the second row's axes. align per slot: 0 puts the
// second row on the same axis (a tapered round barrel), 1 puts the backs
// of both bores flush, toward the wall (an over and under set whose
// barrels run flush with the back of its deeper monoblock).
function holder_pair_layout(ds1, w1, ds2, w2, gaps, offsets, align = 0) =
    let (w = max(w1, w2),
         ds = [for (i = [0 : len(ds1) - 1]) shape_max(ds1[i], ds2[i])],
         xs = holder_xs(ds, w, gaps),
         axes = holder_axes(ds, 1, offsets))
    [xs, axes, holder_bounds(xs, ds, w),
     [for (i = [0 : len(ds1) - 1])
         axes[i] - per(align, i) * (sy(ds1[i]) - sy(ds2[i])) / 2]];

// Slot boundaries for a holder row: the outer walls at both ends and the
// middle of every gap in between.
function holder_bounds(xs, ds, w) =
    let (n = len(ds))
    concat([xs[0] - sx(ds[0]) / 2 - w],
           [for (i = [1 : max(n - 1, 1)]) if (i < n)
               (xs[i - 1] + sx(ds[i - 1]) / 2 + xs[i] - sx(ds[i]) / 2) / 2],
           [xs[n - 1] + sx(ds[n - 1]) / 2 + w]);

// The entries of list v at the indices ix (per-slot list v, or a number).
function pick(v, ix) = is_list(v) ? [for (i = ix) per(v, i)] : v;

// A row of holders from z = 0 to z = h, each merged into the back plate
// by a web. Positions are explicit so two parts can share a layout.
//   ds         bore shape per slot (item size plus clearance), see sx/sy
//   xs         center x per slot
//   axes       wall to axis distance per slot
//   w          holder wall
//   bottom     "closed": floor of floor_t
//              "lip":    floor_t ring the item rests on, open center
//              "open":   no floor at all (clips)
//   lips       ring width per slot for "lip"
//   front_gaps snap opening width per slot toward -y, 0 for none; it
//              starts above the floor so the floor stays whole, and on an
//              oblong or figure 8 bore it wraps the front item
//   chamfer    entry chamfer at the top of the bore
//   groove     [width, depth] of a drain groove in the top of the floor,
//              from the middle of the bore out through the front wall,
//              for a row standing on the safe floor where a hole would
//              be blocked. [0, 0] for none.
module holder_row(ds, h, xs, axes, w = wall, bottom = "closed", floor_t = 2,
                  lips = 4, front_gaps = 0, chamfer = 1, groove = [0, 0]) {
    assert(groove[0] == 0 || (bottom != "open" && groove[1] < floor_t),
           "the drain groove must leave some floor under it");
    for (i = [0 : len(ds) - 1])
        assert(axes[i] >= holder_min_axis(ds[i], chamfer) - eps,
               str("slot ", i + 1, ": holder bore would cut into the back plate"));
    difference() {
        union()
            for (i = [0 : len(ds) - 1]) translate([xs[i], -axes[i], 0]) {
                linear_extrude(h) offset(r = w) bore2d(ds[i]);
                // web tying the holder into the plate
                translate([-sx(ds[i]) * 0.35, 0, 0])
                    cube([sx(ds[i]) * 0.7, axes[i] - plate_t / 2, h]);
            }
        for (i = [0 : len(ds) - 1]) translate([xs[i], -axes[i], 0]) {
            s = ds[i];
            z0 = bottom == "open" ? -eps : floor_t;
            translate([0, 0, z0]) linear_extrude(h - z0 + eps) bore2d(s);
            for (k = [0 : bore_pieces(s) - 1]) hull() {
                translate([0, 0, h - chamfer]) linear_extrude(eps) bore2d(s, k);
                translate([0, 0, h]) linear_extrude(2 * eps)
                    offset(delta = chamfer) bore2d(s, k);
            }
            if (bottom == "lip")
                translate([0, 0, -eps]) linear_extrude(floor_t + 2 * eps)
                    offset(delta = -per(lips, i)) bore2d(s);
            // runs from the bore's back half out past the front wall; the
            // wall above it bridges groove[0] when printed upright
            if (groove[0] > 0)
                translate([-groove[0] / 2, -(sy(s) / 2 + w + 1), floor_t - groove[1]])
                    cube([groove[0], sy(s) + w + 1 - groove[0], groove[1] + eps]);
            if (per(front_gaps, i) > 0)
                translate([0, -(sy(s) - front_d(s)) / 2, 0])
                    snap_opening(front_d(s) / 2, w, per(front_gaps, i),
                                 bottom == "open" ? -eps : floor_t, h);
        }
    }
}

// One part of a cup and clip pair: a row of cups low on the wall and a
// row of snap clips higher up, both from one slot layout so every item
// stands plumb. Used by the barrel and suppressor holders.
//   part        "cup" or "clip"
//   layout      [xs, axes, bounds, clip axes] from holder_pair_layout
//   cup_ds      cup bore per slot; clip_ds clip bore per slot
//   cup_h       cup height including its floor_t floor
//   drain_d     drain hole in the cup floor, 0 for none
//   cup_gaps    front opening per cup (0 = closed cup)
//   clip_gaps   snap opening per clip
//   clip_row    true: clips in one row that follows modular. false: each
//               clip a separate piece with its own plate and magnets
//   magnets_x   magnet columns and magnets_z rows on the cup row (it
//               carries the load); clip_magnets_x and clip_magnets_z on
//               the clip row (it only keeps items in)
//   groove      cup floor drain groove [width, depth], see holder_row
//   base_pad    the cup row stands on the safe floor: with $pad set, its
//               friction pad also gets a second pad for under the row,
//               laid out in front of the wall pad. It covers the row's
//               footprint and rises base_rim_h around it so the row sits
//               in it, open on the wall side where the wall pad is.
module cup_clip_part(part, layout, cup_ds, clip_ds, cup_h, floor_t, drain_d,
                     cup_gaps, cup_plate_h, clip_h, clip_wall, clip_gaps,
                     clip_plate_h, clip_row, magnets_x, magnets_z, modular,
                     print_slot, spacing, clip_magnets_x = 2, clip_magnets_z = 1,
                     groove = [0, 0], base_pad = false) {
    xs = layout[0];
    axes = layout[1];
    bounds = layout[2];
    n = len(bounds) - 1;
    module cup_row(modular = modular, print_slot = print_slot)
        wall_row(bounds, max(cup_plate_h, cup_h), magnets_x, magnets_z,
                 modular = modular, print_slot = print_slot, spacing = spacing)
            holder_row(pick(cup_ds, $slots), cup_h, pick(xs, $slots), pick(axes, $slots),
                       bottom = drain_d > 0 ? "lip" : "closed", floor_t = floor_t,
                       lips = [for (i = $slots) (sx(cup_ds[i]) - drain_d) / 2],
                       front_gaps = pick(cup_gaps, $slots), groove = groove);
    if (part == "cup") {
        cup_row();
        // one base pad per module, cut square at its joints so the
        // neighbours' pads meet there; i = -1 is the one-piece row
        if (base_pad && !is_undef($pad) && $pad)
            for (i = !modular ? [-1] : print_slot == 0 ? [0 : n - 1] : [print_slot - 1])
                translate([modular && print_slot == 0 ? i * spacing : 0, -base_pad_gap, 0])
                    intersection() {
                        base_pad_for() projection(cut = true) translate([0, 0, -1])
                            let ($pad = false) if (i < 0) cup_row(); else cup_row(true, i + 1);
                        x0 = i > 0 ? bounds[i] : -1e4;
                        x1 = i >= 0 && i < n - 1 ? bounds[i + 1] : 1e4;
                        translate([x0, -1e4, -1]) cube([x1 - x0, 2e4, 1e4]);
                    }
    }
    else if (part == "clip")
        wall_row(bounds, max(clip_plate_h, clip_h), clip_magnets_x, clip_magnets_z,
                 modular = clip_row ? modular : true, joined = clip_row,
                 print_slot = print_slot, spacing = spacing)
            holder_row(pick(clip_ds, $slots), clip_h, pick(xs, $slots),
                       pick(layout[3], $slots), w = clip_wall, bottom = "open",
                       front_gaps = pick(clip_gaps, $slots), chamfer = 0.6);
    else
        assert(false, str("unknown part: ", part));
}

// Base pad for the footprint given as the 2D child (wall at y = 0, the
// row toward -y): pad_t thick, with a base_rim_h lip around the
// footprint, cut off at the wall line.
module base_pad_for() {
    c = base_rim_clearance;
    intersection() {
        union() {
            linear_extrude(pad_t) offset(r = c + base_rim_w) children();
            if (base_rim_h > 0) linear_extrude(pad_t + base_rim_h) difference() {
                offset(r = c + base_rim_w) children();
                offset(r = c) children();
            }
        }
        translate([-1e4, -1e4, -1]) cube([2e4, 1e4, 1e4]);
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
