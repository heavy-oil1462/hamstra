// Gun rack: a comb shelf for the top of the safe. Long guns stand butt
// down on the safe floor and lean their barrels into the slots. Gussets
// under the shelf carry it from the back plate.
//
// Every slot has its own width, wall offset and gap (the finger between
// it and the next slot). Per-slot knobs take one entry per slot, or a
// single number for all (a short list repeats its last entry). Example
// default: three break action shotguns tight to the wall and close
// together, then a scoped bolt action further out with more room.
//
// Each slot's stretch of shelf is only as deep as that slot needs
// (its wall offset plus slot_depth); a finger takes the depth of its
// deeper neighbour, so depth only steps at slot edges.
// With equal gaps and edge = gap / 2, racks placed edge to edge continue
// the slot pattern.
//
// modular = true prints one module per slot, joined with the sliding
// dovetail between slots (the rack's outer ends stay plain); modules
// split at the middle of each finger and carry a gusset at both edges.
//
// Prints shelf down: the shelf's top face on the bed, the back plate
// standing up from its back edge, gussets rising between them. Nothing
// floats: the magnet pockets are teardrops in the standing plate, the
// dovetail rises straight off the bed with the slot's closed end on it,
// and the fingers lie in the layers, so a gun pushing one sideways loads
// it along the layers, not across them.
//
// Built lying on its back, then turned shelf down at the end:
//   x  along the rack
//   y  height on the safe wall (the comb is at the top, y = plate_h)
//   z  out from the wall
// The printed part: x along, y out from the wall, z down the wall from
// the shelf top (z = 0) to the plate bottom (z = plate_h).

include <../design_params.scad>
use <../lib/magnets.scad>
use <../lib/holders.scad>
use <../lib/dovetail.scad>

/* [Slots] */
// Slot width per slot: barrel diameter where it rests plus some room
slot_w = [24, 24, 24, 28];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0, 0, 25];
// Finger width between neighbouring slots, one entry per pair
gaps = [20, 20, 45];
// Finger width at each end of the rack
edge = 15;
// Shelf in front of each slot's barrel resting point (retention); each
// slot's stretch of shelf is only as deep as that slot needs
slot_depth = 40;

/* [Shelf] */
// Shelf thickness
shelf_t = 8;
// Plastic between the back plate and the bottom of a 0 offset slot
root = 4;
// Finger tip rounding
tip_r = 5;

/* [Back plate] */
// Back plate height on the wall
plate_h = 70;
// Gusset thickness
gusset_t = 5;
// Gusset height below the shelf
gusset_h = 45;

/* [Modular] */
// Print one module per slot, joined side by side with sliding dovetails
modular = false;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

/* [Friction pad] */
// Show the friction pad instead (print in TPU, or use as the template
// to cut silicone sheet; pad_t in design_params.scad)
pad = false;

/* [Magnets] */
// Magnet columns (per module when modular)
magnets_x = 4;
// Magnet rows
magnets_y = 2;

// Slot centers along x, starting after the first edge finger.
function slot_xs(ws, gaps, edge, i = 0, x = undef) =
    let (x = is_undef(x) ? edge + ws[0] / 2 : x)
    i >= len(ws) ? [] :
    concat([x], i + 1 < len(ws)
        ? slot_xs(ws, gaps, edge, i + 1, x + ws[i] / 2 + per(gaps, i) + ws[i + 1] / 2)
        : []);

// Comb outline in the x / out-from-wall plane. segs: [[x_left, x_right,
// depth], ...] covering the piece left to right. joints = [left, right]:
// a jointed edge is not rounded, so the two half fingers of neighbouring
// modules join into one finger with the one-piece rack's rounded tip.
module comb_profile(segs, ws, xs, bottoms, tip_r, joints = [false, false]) {
    top = max([for (g = segs) g[2]]);
    n = len(segs);
    ext = tip_r + 1;
    // jointed edges run on past the piece before rounding
    open = [for (k = [0 : n - 1])
        [segs[k][0] - (k == 0 && joints[0] ? ext : 0),
         segs[k][1] + (k == n - 1 && joints[1] ? ext : 0), segs[k][2]]];
    // opening rounds the finger tips; the profile overruns below z = 0
    // so the base corners stay square, then gets clipped back
    intersection() {
        offset(r = tip_r) offset(r = -tip_r)
            difference() {
                for (g = open) translate([g[0], -tip_r - 1]) square([g[1] - g[0], g[2] + tip_r + 1]);
                for (i = [0 : len(ws) - 1])
                    translate([xs[i], bottoms[i] + ws[i] / 2])
                        hull() {
                            circle(d = ws[i]);
                            translate([-ws[i] / 2, 0]) square([ws[i], top]);
                        }
            }
        for (g = segs) translate([g[0], 0]) square([g[1] - g[0], g[2]]);
    }
}

// One printed piece spanning x in [x0, x1] with the given slots. depths:
// shelf depth per slot; dl / dr: depth of the piece's edge fingers.
// Gussets sit at both edges and under every finger between the slots.
// With $pad set it draws the piece's friction pad instead.
module rack_piece(x0, x1, ws, xs, bottoms, depths, dl, dr, r, shelf_t, plate_h,
                  gusset_t, gusset_h, magnets_x, magnets_y, joints) {
    n = len(ws);
    y_shelf = plate_h - shelf_t;   // underside of the shelf
    fd = [for (k = [0 : n - 1]) if (k < n - 1) max(depths[k], depths[k + 1])];
    segs = concat(
        [[x0, xs[0] - ws[0] / 2, dl]],
        [for (k = [0 : n - 1]) each concat(
            [[xs[k] - ws[k] / 2, xs[k] + ws[k] / 2, depths[k]]],
            k < n - 1 ? [[xs[k] + ws[k] / 2, xs[k + 1] - ws[k + 1] / 2, fd[k]]] : [])],
        [[xs[n - 1] + ws[n - 1] / 2, x1, dr]]);
    // [x, depth] per gusset
    gs = concat([[x0 + gusset_t / 2, dl]],
                [for (k = [0 : n - 1]) if (k < n - 1)
                    [(xs[k] + ws[k] / 2 + xs[k + 1] - ws[k + 1] / 2) / 2, fd[k]]],
                [[x1 - gusset_t / 2, dr]]);
    if (!is_undef($pad) && $pad)
        back_pad(x0, x1, plate_h, magnets_x, magnets_y, joints, gh = y_shelf);
    else difference() {
        union() {
            linear_extrude(plate_t) plate2d(x0, x1, plate_h);
            magnet_bosses_flat(x0, x1, y_shelf, magnets_x, magnets_y, roof_down = true);
            translate([0, plate_h, 0]) rotate([90, 0, 0])
                linear_extrude(shelf_t) comb_profile(segs, ws, xs, bottoms, r, joints);
            for (g = gs)
                translate([g[0] - gusset_t / 2, 0, 0]) rotate([90, 0, 90])
                    linear_extrude(gusset_t)
                        polygon([[y_shelf + eps, plate_t - eps],
                                 [y_shelf + eps, g[1] - r],
                                 [y_shelf - gusset_h, plate_t - eps]]);
            // the joint is modeled upright; lay it down like the rack
            rotate([-90, 0, 0]) dovetail_joints(x0, x1, plate_h, joints);
        }
        magnet_pockets_flat(x0, x1, y_shelf, magnets_x, magnets_y, roof_down = true);
        rotate([-90, 0, 0]) dovetail_cuts(x0, plate_h, joints);
    }
}

// Slot layout [xs, bottoms, length] for these knobs: slot centers along
// the rack, wall to slot bottom per slot, rack length. The rack uses it,
// and so does the assembly to put guns in the slots.
function gun_rack_layout(slot_w = slot_w, wall_offset = wall_offset, gaps = gaps,
                         edge = edge, root = root) =
    let (ws = as_list(slot_w), n = len(ws), xs = slot_xs(ws, gaps, edge))
    // slot bottoms clear the magnet bosses and the dovetail edge strip
    [xs, [for (i = [0 : n - 1]) max(back_t + root, dovetail_spine_t + 1) + per(wall_offset, i)],
     xs[n - 1] + ws[n - 1] / 2 + edge];

// Back plate height: the shelf top sits this far above the plate bottom.
// The printed rack stands upright again with
// translate([0, 0, gun_rack_plate_h()]) rotate([180, 0, 0]).
function gun_rack_plate_h() = plate_h;

module gun_rack(slot_w = slot_w, wall_offset = wall_offset, gaps = gaps,
                edge = edge, slot_depth = slot_depth, shelf_t = shelf_t,
                root = root, tip_r = tip_r, plate_h = plate_h,
                gusset_t = gusset_t, gusset_h = gusset_h,
                magnets_x = magnets_x, magnets_y = magnets_y,
                modular = modular, print_slot = print_slot, spacing = 12, pad = pad) {
    ws = as_list(slot_w);
    n = len(ws);
    layout = gun_rack_layout(ws, wall_offset, gaps, edge, root);
    xs = layout[0];
    bottoms = layout[1];   // distance from the wall to the bottom of each slot
    l = layout[2];
    depths = [for (i = [0 : n - 1]) bottoms[i] + ws[i] / 2 + slot_depth];
    // tips round like the one-piece rack even when modular (joint sides
    // stay square), but a module's half finger still carries a gusset
    fingers = concat([edge], [for (i = [0 : n - 1]) if (i < n - 1) per(gaps, i)], [edge]);
    r = min(tip_r, min(fingers) / 2 - 0.5);
    for (f = fingers)
        assert(f / (modular && f != edge ? 2 : 1) > gusset_t,
               "a finger is narrower than gusset_t, widen the gap or edge");
    // slot boundaries: rack ends and finger middles
    bounds = concat([0], [for (i = [0 : n - 1]) if (i < n - 1)
                              xs[i] + ws[i] / 2 + per(gaps, i) / 2], [l]);
    assert(print_slot >= 0 && print_slot <= n, str("print_slot must be 0..", n));
    // regen_all.py reads this to export every module to its own STL
    if (modular) echo(modules = n);
    // turn the on-its-back build shelf down for printing; the pad
    // prints as built, flat
    let ($pad = pad)
    translate([0, 0, pad ? 0 : plate_h]) rotate([pad ? 0 : -90, 0, 0])
    if (!modular)
        rack_piece(0, l, ws, xs, bottoms, depths, depths[0], depths[n - 1], r, shelf_t,
                   plate_h, gusset_t, gusset_h, magnets_x, magnets_y, [false, false]);
    else
        for (i = print_slot == 0 ? [0 : n - 1] : [print_slot - 1])
            translate([print_slot == 0 ? i * spacing : 0, 0, 0])
                rack_piece(bounds[i], bounds[i + 1], [ws[i]], [xs[i]], [bottoms[i]],
                           [depths[i]],
                           i > 0 ? max(depths[i - 1], depths[i]) : depths[i],
                           i < n - 1 ? max(depths[i], depths[i + 1]) : depths[i],
                           r, shelf_t, plate_h, gusset_t, gusset_h,
                           magnets_x, magnets_y, [i > 0, i < n - 1]);
}

gun_rack();
