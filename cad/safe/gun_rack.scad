// Gun rack: a comb shelf for the top of the safe. Long guns stand butt
// down on the safe floor and lean their barrels into the slots. Gussets
// under the shelf carry it from the back plate.
//
// Every module is count * pitch wide with half fingers at both ends, so
// several printed racks placed edge to edge continue the slot pattern.
//
// Prints lying on its back: back plate flat on the bed with the magnet
// pockets opening downward, the comb standing up from it. Modeled in
// that print orientation:
//   x  along the rack
//   y  height on the safe wall (the comb is at the top, y = plate_h)
//   z  out from the wall

include <../design_params.scad>
use <../lib/magnets.scad>

/* [Slots] */
// Number of slots
count = 3;
// Slot width, barrel diameter where it rests plus some room
slot_w = 28;
// Slot pitch, wide enough for scopes to sit side by side
pitch = 75;
// Slot depth from the shelf edge
slot_depth = 60;

/* [Shelf] */
// How far the shelf sticks out from the wall
shelf_depth = 85;
// Shelf thickness
shelf_t = 8;
// Finger tip rounding
tip_r = 6;

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

module comb_profile(count, slot_w, pitch, slot_depth, shelf_depth, tip_r) {
    l = count * pitch;
    // opening rounds the finger tips; the profile overruns below z = 0
    // so the base corners stay square, then gets clipped back
    intersection() {
        offset(r = tip_r) offset(r = -tip_r)
            difference() {
                translate([0, -tip_r - 1]) square([l, shelf_depth + tip_r + 1]);
                for (i = [0 : count - 1])
                    translate([(i + 0.5) * pitch, shelf_depth - slot_depth + slot_w / 2])
                        hull() {
                            circle(d = slot_w);
                            translate([-slot_w / 2, 0]) square([slot_w, slot_depth]);
                        }
            }
        square([l, shelf_depth]);
    }
}

module gun_rack(count = count, slot_w = slot_w, pitch = pitch,
                slot_depth = slot_depth, shelf_depth = shelf_depth,
                shelf_t = shelf_t, tip_r = tip_r, plate_h = plate_h,
                gusset_t = gusset_t, gusset_h = gusset_h,
                magnets_x = magnets_x, magnets_y = magnets_y) {
    l = count * pitch;
    y_shelf = plate_h - shelf_t;   // underside of the shelf
    // gussets at every full finger plus the two half fingers at the ends
    gx = concat([gusset_t / 2], [for (i = [1 : count - 1]) i * pitch], [l - gusset_t / 2]);
    difference() {
        union() {
            linear_extrude(back_t)
                offset(r = plate_r) offset(delta = -plate_r) square([l, plate_h]);
            translate([0, plate_h, 0]) rotate([90, 0, 0])
                linear_extrude(shelf_t)
                    comb_profile(count, slot_w, pitch, slot_depth, shelf_depth, tip_r);
            for (x = gx)
                translate([x - gusset_t / 2, 0, 0]) rotate([90, 0, 90])
                    linear_extrude(gusset_t)
                        polygon([[y_shelf + eps, back_t - eps],
                                 [y_shelf + eps, shelf_depth - tip_r],
                                 [y_shelf - gusset_h, back_t - eps]]);
        }
        magnet_pockets_flat(l, y_shelf, magnets_x, magnets_y);
    }
}

gun_rack();
