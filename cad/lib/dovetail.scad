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

// Where the tongue's sloped end starts at its outer face. Above it the
// tongue, and the slot, end in a 45 degree plane that reaches the plate
// edge dovetail_d higher, dovetail_stop below the top.
function dovetail_end_z(h) = h - dovetail_stop - dovetail_d;

// Section c grown, run up to the 45 degree plane x + z = k. Only the end
// is sloped: the flanks stay straight, so the tongue's end is never wider
// than the slot it slides through. Tongue and slot use the same plane,
// so their ends meet face to face exactly when the plates are level.
module dovetail_bar(k, c = 0) {
    intersection() {
        // a cutter (c > 0) overruns the plate bottom, a tongue starts on it
        translate([0, 0, c > 0 ? -eps : 0]) linear_extrude(k + 2 + c) dovetail_profile(c);
        // half space x + z <= k, only as big as the bar: a huge cube
        // flickers in the F5 preview (depth buffer precision)
        let (s = k + 10)
            translate([0, 0, k]) rotate([0, 45, 0]) translate([-s, -s, -s]) cube([2 * s, 2 * s, s]);
    }
}

// Tongue on the right edge x1, its end sloped at 45 degrees.
module dovetail_male(x1, h) {
    translate([x1, 0, 0]) dovetail_bar(dovetail_end_z(h) + dovetail_d);
}

// Slot cutter for the left edge x0, open at the bottom, closed at the top
// by the same 45 degree plane as the tongue's end, so it prints without
// bridging and the tongue seats on it with the plates level.
module dovetail_female(x0, h) {
    assert(dovetail_end_z(h) > dovetail_clearance, "plate too short for the dovetail");
    translate([x0, 0, 0]) dovetail_bar(dovetail_end_z(h) + dovetail_d, dovetail_clearance);
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
