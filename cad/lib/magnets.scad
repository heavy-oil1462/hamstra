// Magnet mounting helpers. Lives under cad/lib/ so regen_all.py does not
// export it as a printable model.
//
// Coordinate convention for wall-mounted models (modeled as used, which
// for upright models is also how they print):
//   - the safe wall is the plane y = 0, the wall itself is y > 0
//   - the model sticks out toward -y, z is up
//   - the back plate occupies y in [-back_t, 0]
// Models that print lying on their back use magnet_pockets_flat instead
// and are rotated into place by the assembly.

include <../design_params.scad>

// Evenly spread n positions over [a, b]; one position sits in the middle.
function spread(n, a, b) =
    n <= 1 ? [(a + b) / 2] : [for (i = [0 : n - 1]) a + (b - a) * i / (n - 1)];

// One pocket cutter. Opening on the plane z = 0, depth toward +z.
// teardrop = true adds a 45 degree roof toward +y so the pocket prints
// without support when its axis is horizontal.
module magnet_pocket(teardrop = false, clearance = magnet_clearance) {
    d = magnet_d + clearance;
    depth = magnet_h + magnet_recess;
    translate([0, 0, -eps]) {
        linear_extrude(depth + eps)
            hull() {
                circle(d = d);
                if (teardrop) translate([0, d / 2 * sqrt(2)]) square(eps, center = true);
            }
        cylinder(d1 = d + 2 * magnet_chamfer + 2 * eps, d2 = d,
                 h = magnet_chamfer + eps);
    }
}

// Pocket grid for the back face of a wall-mounted model. The plate spans
// x in [-w/2, w/2], z in [0, h]; nx by nz pockets, axes along y. Upright
// prints want the teardrop roof; models modeled upright but printed on
// their back (rotated so the back face lies on the bed) pass false.
module magnet_pockets_wall(w, h, nx, nz, teardrop = true) {
    m = (magnet_d + magnet_clearance) / 2 + magnet_edge;
    for (x = spread(nx, -w / 2 + m, w / 2 - m), z = spread(nz, m, h - m))
        translate([x, 0, z]) rotate([90, 0, 0]) magnet_pocket(teardrop = teardrop);
}

// Pocket grid for a back face lying on the print bed (z = 0). The plate
// spans x in [0, w], y in [0, h].
module magnet_pockets_flat(w, h, nx, ny) {
    m = (magnet_d + magnet_clearance) / 2 + magnet_edge;
    for (x = spread(nx, m, w - m), y = spread(ny, m, h - m))
        translate([x, y, 0]) magnet_pocket(teardrop = false);
}

// Upright back plate solid: x in [-w/2, w/2], z in [0, h], y in [-back_t, 0].
module wall_plate(w, h, r = plate_r) {
    rotate([90, 0, 0])
        linear_extrude(back_t)
            translate([-w / 2, 0])
                offset(r = r) offset(delta = -r) square([w, h]);
}

// Upright wall-mounted model: back plate plus children, magnet pockets
// cut last so nothing the children add can fill them.
module wall_mount(w, h, nx, nz, teardrop = true) {
    difference() {
        union() {
            wall_plate(w, h);
            children();
        }
        magnet_pockets_wall(w, h, nx, nz, teardrop);
    }
}
