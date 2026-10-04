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
// front to back ([21, 42] for two 21 mm barrels).
function sx(s) = is_list(s) ? s[0] : s;   // width along the wall
function sy(s) = is_list(s) ? s[1] : s;   // depth away from the wall
function grow(s, c) = is_list(s) ? [s[0] + c, s[1] + c] : s + c;
function shape_max(a, b) = [max(sx(a), sx(b)), max(sy(a), sy(b))];

// Bore outline of shape s centered on the origin: a circle, or a stadium
// running along y. Convex, so hulls of it stay true.
module bore2d(s) {
    hull() for (y = [-1, 1]) translate([0, y * (sy(s) - sx(s)) / 2]) circle(d = sx(s));
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
//              oblong bore it wraps the front item
//   chamfer    entry chamfer at the top of the bore
module holder_row(ds, h, xs, axes, w = wall, bottom = "closed", floor_t = 2,
                  lips = 4, front_gaps = 0, chamfer = 1) {
    for (i = [0 : len(ds) - 1])
        assert(axes[i] >= holder_min_axis(ds[i], chamfer) - eps,
               str("slot ", i + 1, ": holder bore would cut into the back plate"));
    difference() {
        union()
            for (i = [0 : len(ds) - 1]) translate([xs[i], -axes[i], 0]) {
                linear_extrude(h) offset(r = w) bore2d(ds[i]);
                // web tying the holder into the plate
                translate([-sx(ds[i]) * 0.35, 0, 0])
                    cube([sx(ds[i]) * 0.7, axes[i] - back_t / 2, h]);
            }
        for (i = [0 : len(ds) - 1]) translate([xs[i], -axes[i], 0]) {
            s = ds[i];
            z0 = bottom == "open" ? -eps : floor_t;
            translate([0, 0, z0]) linear_extrude(h - z0 + eps) bore2d(s);
            hull() {
                translate([0, 0, h - chamfer]) linear_extrude(eps) bore2d(s);
                translate([0, 0, h]) linear_extrude(2 * eps) offset(delta = chamfer) bore2d(s);
            }
            if (bottom == "lip")
                translate([0, 0, -eps]) linear_extrude(floor_t + 2 * eps)
                    offset(delta = -per(lips, i)) bore2d(s);
            if (per(front_gaps, i) > 0)
                translate([0, -(sy(s) - sx(s)) / 2, 0])
                    snap_opening(sx(s) / 2, w, per(front_gaps, i),
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
module cup_clip_part(part, layout, cup_ds, clip_ds, cup_h, floor_t, drain_d,
                     cup_gaps, cup_plate_h, clip_h, clip_wall, clip_gaps,
                     clip_plate_h, clip_row, magnets_x, magnets_z, modular,
                     print_slot, spacing) {
    xs = layout[0];
    axes = layout[1];
    bounds = layout[2];
    if (part == "cup")
        wall_row(bounds, max(cup_plate_h, cup_h), magnets_x, magnets_z,
                 modular = modular, print_slot = print_slot, spacing = spacing)
            holder_row(pick(cup_ds, $slots), cup_h, pick(xs, $slots), pick(axes, $slots),
                       bottom = drain_d > 0 ? "lip" : "closed", floor_t = floor_t,
                       lips = [for (i = $slots) (sx(cup_ds[i]) - drain_d) / 2],
                       front_gaps = pick(cup_gaps, $slots));
    else if (part == "clip")
        wall_row(bounds, max(clip_plate_h, clip_h), magnets_x, magnets_z,
                 modular = clip_row ? modular : true, joined = clip_row,
                 print_slot = print_slot, spacing = spacing)
            holder_row(pick(clip_ds, $slots), clip_h, pick(xs, $slots),
                       pick(layout[3], $slots), w = clip_wall, bottom = "open",
                       front_gaps = pick(clip_gaps, $slots), chamfer = 0.6);
    else
        assert(false, str("unknown part: ", part));
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
