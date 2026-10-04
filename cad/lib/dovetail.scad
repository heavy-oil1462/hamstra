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

// Tongue on the right edge x1. Stops short of the top by dovetail_stop.
module dovetail_male(x1, h) {
    translate([x1, 0, 0]) linear_extrude(h - dovetail_stop) dovetail_profile();
}

// Slot cutter for the left edge x0, open at the bottom, closed at the top.
module dovetail_female(x0, h) {
    translate([x0, 0, -eps])
        linear_extrude(h - dovetail_stop + dovetail_clearance + eps)
            dovetail_profile(dovetail_clearance);
}

// Joint parts for a module spanning x in [x0, x1]. joints = [left, right]
// says which edges join a neighbour: the outer ends of a row get none.
// Each jointed edge gets a thickened strip (the spine) and squares the
// plate corner so neighbours close up; the right edge carries the tongue.
module dovetail_joints(x0, x1, h, joints) {
    for (side = [0, 1]) if (joints[side])
        translate([side == 0 ? x0 : x1 - dovetail_spine_w, -dovetail_spine_t, 0])
            cube([dovetail_spine_w, dovetail_spine_t, h]);
    if (joints[1]) dovetail_male(x1, h);
}

// Slot cut for a module whose left edge joins a neighbour.
module dovetail_cuts(x0, h, joints) {
    if (joints[0]) dovetail_female(x0, h);
}
