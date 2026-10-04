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
// Prints lying on its back: back plate flat on the bed with the magnet
// pockets opening downward, the comb standing up from it. Modeled in
// that print orientation:
//   x  along the rack
//   y  height on the safe wall (the comb is at the top, y = plate_h)
//   z  out from the wall

include <../design_params.scad>
use <../lib/magnets.scad>
use <../lib/holders.scad>

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

/* [Magnets] */
// Magnet columns
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

module comb_profile(ws, xs, bottoms, l, shelf_depth, tip_r) {
    // opening rounds the finger tips; the profile overruns below z = 0
    // so the base corners stay square, then gets clipped back
    intersection() {
        offset(r = tip_r) offset(r = -tip_r)
            difference() {
                translate([0, -tip_r - 1]) square([l, shelf_depth + tip_r + 1]);
                for (i = [0 : len(ws) - 1])
                    translate([xs[i], bottoms[i] + ws[i] / 2])
                        hull() {
                            circle(d = ws[i]);
                            translate([-ws[i] / 2, 0]) square([ws[i], shelf_depth]);
                        }
            }
        square([l, shelf_depth]);
    }
}

module gun_rack(slot_w = slot_w, wall_offset = wall_offset, gaps = gaps,
                edge = edge, slot_depth = slot_depth, shelf_t = shelf_t,
                root = root, tip_r = tip_r, plate_h = plate_h,
                gusset_t = gusset_t, gusset_h = gusset_h,
                magnets_x = magnets_x, magnets_y = magnets_y) {
    ws = as_list(slot_w);
    n = len(ws);
    xs = slot_xs(ws, gaps, edge);
    l = xs[n - 1] + ws[n - 1] / 2 + edge;
    // distance from the wall to the bottom of each slot
    bottoms = [for (i = [0 : n - 1]) back_t + root + per(wall_offset, i)];
    shelf_depth = max([for (i = [0 : n - 1]) bottoms[i] + ws[i] / 2]) + slot_depth;
    fingers = concat([edge], [for (i = [0 : n - 2]) per(gaps, i)], [edge]);
    r = min(tip_r, min(fingers) / 2 - 0.5);
    y_shelf = plate_h - shelf_t;   // underside of the shelf
    // a gusset under the middle of every finger, flush with both ends
    gx = concat([gusset_t / 2],
                [for (i = [0 : n - 2]) (xs[i] + ws[i] / 2 + xs[i + 1] - ws[i + 1] / 2) / 2],
                [l - gusset_t / 2]);
    for (f = fingers)
        assert(f > gusset_t, "a finger is narrower than gusset_t, widen the gap or edge");
    difference() {
        union() {
            linear_extrude(back_t)
                offset(r = plate_r) offset(delta = -plate_r) square([l, plate_h]);
            translate([0, plate_h, 0]) rotate([90, 0, 0])
                linear_extrude(shelf_t)
                    comb_profile(ws, xs, bottoms, l, shelf_depth, r);
            for (x = gx)
                translate([x - gusset_t / 2, 0, 0]) rotate([90, 0, 90])
                    linear_extrude(gusset_t)
                        polygon([[y_shelf + eps, back_t - eps],
                                 [y_shelf + eps, shelf_depth - r],
                                 [y_shelf - gusset_h, back_t - eps]]);
        }
        magnet_pockets_flat(l, y_shelf, magnets_x, magnets_y);
    }
}

gun_rack();
