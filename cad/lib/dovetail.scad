// Sliding dovetail between neighbouring modules. Lives under cad/lib/ so
// regen_all.py does not export it as a printable model.
//
// Upright convention (as magnets.scad): wall at y = 0, model toward -y,
// z up. The joint runs along a module's side edge for the plate height h:
// the tongue sticks out of the right edge (+x), the slot is cut into the
// left edge. Both sit centered in a thickened edge strip (the spine) so
// the plate's back face stays flat on the wall. Models printed on their
// back rotate these parts with the rest of the model.

include <../design_params.scad>

// Tongue cross-section on the edge x = 0, reaching toward +x. The root
// runs 1 mm back into the module so it always merges. c grows it all
// round for the slot.
module dovetail_profile(c = 0) {
    yc = -dovetail_spine_t / 2;
    n = dovetail_neck / 2;
    d = dovetail_d;
    offset(delta = c)
        polygon([[-1, yc - n], [0, yc - n], [d, yc - n - d],
                 [d, yc + n + d], [0, yc + n], [-1, yc + n]]);
}

// Where the full tongue section ends: above it the tongue and the slot
// both close in on the plate edge at 45 degrees (dovetail_end), reaching
// the edge dovetail_stop below the top.
function dovetail_end_z(h) = h - dovetail_stop - dovetail_d;

// 45 degree end from section z0 up: the profile (grown by c) closing in
// on its root at the plate edge, dovetail_d + c higher. Tongue and slot
// share it, so their ends meet face to face and seat level.
module dovetail_end(z0, c = 0) {
    hull() {
        translate([0, 0, z0 - eps]) linear_extrude(eps) dovetail_profile(c);
        translate([0, 0, z0 + dovetail_d + c]) linear_extrude(eps)
            intersection() {
                dovetail_profile(c);
                translate([-10, -50]) square([10, 100]);
            }
    }
}

// Tongue on the right edge x1, its end sloped so it seats on the slot's
// sloped end with the plates level.
module dovetail_male(x1, h) {
    e = dovetail_end_z(h);
    translate([x1, 0, 0]) {
        linear_extrude(e) dovetail_profile();
        dovetail_end(e);
    }
}

// Slot cutter for the left edge x0, open at the bottom, closed at the
// top. Its sloped end sits a clearance lower than the tongue's, so with
// the plates level the two slopes touch and nothing else does; it also
// prints without bridging.
module dovetail_female(x0, h) {
    c = dovetail_clearance;
    e = dovetail_end_z(h) - c;
    assert(e > 0, "plate too short for the dovetail");
    translate([x0, 0, 0]) {
        translate([0, 0, -eps]) linear_extrude(e + eps) dovetail_profile(c);
        dovetail_end(e, c);
    }
}

// Upside down about the plate's mid height when flip is set.
module dovetail_flip(h, flip) {
    if (flip) translate([0, 0, h]) mirror([0, 0, 1]) children();
    else children();
}

// Joint parts for a module spanning x in [x0, x1]. joints = [left, right]
// says which edges join a neighbour: the outer ends of a row get none.
// Each jointed edge gets a thickened strip (the spine) and squares the
// plate corner so neighbours close up; the right edge carries the tongue.
// The tongue must start on the bed: plates printed upright keep it from
// the bottom and the slot closed at the top. flip = true is for a plate
// printed top down (the gun rack): the tongue runs from the top edge and
// the slot is closed at the bottom, so the module with the slot goes on
// the wall first and its neighbour drops in from above.
module dovetail_joints(x0, x1, h, joints, flip = false) {
    for (side = [0, 1]) if (joints[side])
        translate([side == 0 ? x0 : x1 - dovetail_spine_w, -dovetail_spine_t, 0])
            cube([dovetail_spine_w, dovetail_spine_t, h]);
    if (joints[1]) dovetail_flip(h, flip) dovetail_male(x1, h);
}

// Slot cut for a module whose left edge joins a neighbour.
module dovetail_cuts(x0, h, joints, flip = false) {
    if (joints[0]) dovetail_flip(h, flip) dovetail_female(x0, h);
}
