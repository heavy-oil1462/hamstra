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
// All slots open at the same shelf edge. The slot furthest from the wall
// gets slot_depth; slots closer to the wall are deeper by the difference.
// With equal gaps and edge = gap / 2, racks placed edge to edge continue
// the slot pattern.
//
// modular = true prints one module per slot, joined with the sliding
// dovetail between slots (the rack's outer ends stay plain); modules
// split at the middle of each finger and carry a gusset at both edges.
//
// Prints lying on its back: back plate flat on the bed with the magnet
// pockets opening downward, the comb standing up from it. Modeled in
// that print orientation:
//   x  along the rack
//   y  height on the safe wall (the comb is at the top, y = plate_h)
//   z  out from the wall

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
// Slot depth for the slot furthest from the wall (retention)
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

// Comb outline in the x / out-from-wall plane for x in [x0, x1].
module comb_profile(x0, x1, ws, xs, bottoms, shelf_depth, tip_r) {
    // opening rounds the finger tips; the profile overruns below z = 0
    // so the base corners stay square, then gets clipped back
    intersection() {
        offset(r = tip_r) offset(r = -tip_r)
            difference() {
                translate([x0, -tip_r - 1]) square([x1 - x0, shelf_depth + tip_r + 1]);
                for (i = [0 : len(ws) - 1])
                    translate([xs[i], bottoms[i] + ws[i] / 2])
                        hull() {
                            circle(d = ws[i]);
                            translate([-ws[i] / 2, 0]) square([ws[i], shelf_depth]);
                        }
            }
        translate([x0, 0]) square([x1 - x0, shelf_depth]);
    }
}

// One printed piece spanning x in [x0, x1] with the given slots. Gussets
// sit at both edges and under every finger between the piece's slots.
module rack_piece(x0, x1, ws, xs, bottoms, shelf_depth, r, shelf_t, plate_h,
                  gusset_t, gusset_h, magnets_x, magnets_y, joints) {
    n = len(ws);
    y_shelf = plate_h - shelf_t;   // underside of the shelf
    gx = concat([x0 + gusset_t / 2],
                [for (i = [0 : n - 1]) if (i < n - 1)
                    (xs[i] + ws[i] / 2 + xs[i + 1] - ws[i + 1] / 2) / 2],
                [x1 - gusset_t / 2]);
    difference() {
        union() {
            translate([x0, 0, 0]) linear_extrude(back_t)
                offset(r = plate_r) offset(delta = -plate_r) square([x1 - x0, plate_h]);
            translate([0, plate_h, 0]) rotate([90, 0, 0])
                linear_extrude(shelf_t)
                    comb_profile(x0, x1, ws, xs, bottoms, shelf_depth, r);
            for (x = gx)
                translate([x - gusset_t / 2, 0, 0]) rotate([90, 0, 90])
                    linear_extrude(gusset_t)
                        polygon([[y_shelf + eps, back_t - eps],
                                 [y_shelf + eps, shelf_depth - r],
                                 [y_shelf - gusset_h, back_t - eps]]);
            // the joint is modeled upright; lay it down like the rack
            rotate([-90, 0, 0]) dovetail_joints(x0, x1, plate_h, joints);
        }
        magnet_pockets_flat(x0, x1, y_shelf, magnets_x, magnets_y);
        rotate([-90, 0, 0]) dovetail_cuts(x0, plate_h, joints);
    }
}

module gun_rack(slot_w = slot_w, wall_offset = wall_offset, gaps = gaps,
                edge = edge, slot_depth = slot_depth, shelf_t = shelf_t,
                root = root, tip_r = tip_r, plate_h = plate_h,
                gusset_t = gusset_t, gusset_h = gusset_h,
                magnets_x = magnets_x, magnets_y = magnets_y,
                modular = modular, print_slot = print_slot, spacing = 12) {
    ws = as_list(slot_w);
    n = len(ws);
    xs = slot_xs(ws, gaps, edge);
    l = xs[n - 1] + ws[n - 1] / 2 + edge;
    // distance from the wall to the bottom of each slot
    bottoms = [for (i = [0 : n - 1]) back_t + root + per(wall_offset, i)];
    shelf_depth = max([for (i = [0 : n - 1]) bottoms[i] + ws[i] / 2]) + slot_depth;
    // modules split each finger in half
    fingers = concat([edge], [for (i = [0 : n - 1]) if (i < n - 1)
                                  per(gaps, i) / (modular ? 2 : 1)], [edge]);
    r = min(tip_r, min(fingers) / 2 - 0.5);
    for (f = fingers)
        assert(f > gusset_t, "a finger is narrower than gusset_t, widen the gap or edge");
    // slot boundaries: rack ends and finger middles
    bounds = concat([0], [for (i = [0 : n - 1]) if (i < n - 1)
                              xs[i] + ws[i] / 2 + per(gaps, i) / 2], [l]);
    assert(print_slot >= 0 && print_slot <= n, str("print_slot must be 0..", n));
    // regen_all.py reads this to export every module to its own STL
    if (modular) echo(modules = n);
    if (!modular)
        rack_piece(0, l, ws, xs, bottoms, shelf_depth, r, shelf_t, plate_h,
                   gusset_t, gusset_h, magnets_x, magnets_y, [false, false]);
    else
        for (i = print_slot == 0 ? [0 : n - 1] : [print_slot - 1])
            translate([print_slot == 0 ? i * spacing : 0, 0, 0])
                rack_piece(bounds[i], bounds[i + 1], [ws[i]], [xs[i]], [bottoms[i]],
                           shelf_depth, r, shelf_t, plate_h, gusset_t, gusset_h,
                           magnets_x, magnets_y, [i > 0, i < n - 1]);
}

gun_rack();
