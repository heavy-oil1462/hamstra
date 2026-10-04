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
use <dovetail.scad>

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

// How many pockets fit in a span of length l with margin m at both ends
// and 2 mm of plastic between pockets; asking for more caps at this.
function pockets_fit(n, l, m) =
    min(n, max(1, floor((l - 2 * m) / (magnet_d + magnet_clearance + 2)) + 1));

// Pocket grid for the back face of a wall-mounted model. The plate spans
// x in [x0, x1], z in [0, h]; nx by nz pockets, axes along y. Upright
// prints want the teardrop roof; models modeled upright but printed on
// their back (rotated so the back face lies on the bed) pass false.
module magnet_pockets_wall(x0, x1, h, nx, nz, teardrop = true) {
    m = (magnet_d + magnet_clearance) / 2 + magnet_edge;
    for (x = spread(pockets_fit(nx, x1 - x0, m), x0 + m, x1 - m),
         z = spread(pockets_fit(nz, h, m), m, h - m))
        translate([x, 0, z]) rotate([90, 0, 0]) magnet_pocket(teardrop = teardrop);
}

// Pocket grid for a back face lying on the print bed (z = 0). The plate
// spans x in [x0, x1], y in [0, h].
module magnet_pockets_flat(x0, x1, h, nx, ny) {
    m = (magnet_d + magnet_clearance) / 2 + magnet_edge;
    for (x = spread(pockets_fit(nx, x1 - x0, m), x0 + m, x1 - m),
         y = spread(pockets_fit(ny, h, m), m, h - m))
        translate([x, y, 0]) magnet_pocket(teardrop = false);
}

// Upright back plate solid: x in [x0, x1], z in [0, h], y in [-back_t, 0].
module wall_plate(x0, x1, h, r = plate_r) {
    rotate([90, 0, 0])
        linear_extrude(back_t)
            translate([x0, 0])
                offset(r = r) offset(delta = -r) square([x1 - x0, h]);
}

// Upright wall-mounted model: back plate plus children, magnet pockets
// cut last so nothing the children add can fill them. joints = [left,
// right] adds the module joint on those side edges (lib/dovetail.scad).
module wall_mount(x0, x1, h, nx, nz, teardrop = true, joints = [false, false]) {
    difference() {
        union() {
            wall_plate(x0, x1, h);
            dovetail_joints(x0, x1, h, joints);
            children();
        }
        magnet_pockets_wall(x0, x1, h, nx, nz, teardrop);
        dovetail_cuts(x0, h, joints);
    }
}

// A row of slots on the wall, one piece or one module per slot.
//   bounds      slot boundaries along x, n + 1 of them (module i spans
//               bounds[i] to bounds[i + 1])
//   modular     false: one plate for the whole row. true: one plate per
//               slot, joined with dovetails between slots (the row's
//               outer ends stay plain).
//   print_slot  modular only: 0 lays out every module, spacing apart;
//               1..n just that module
//   nx          magnet columns per row, or per module when modular;
//               capped at what fits without pockets touching
// Children draw the holders for the slot indices in $slots.
module wall_row(bounds, h, nx, nz, teardrop = true, modular = false,
                print_slot = 0, spacing = 12) {
    n = len(bounds) - 1;
    assert(print_slot >= 0 && print_slot <= n, str("print_slot must be 0..", n));
    // regen_all.py reads this to export every module to its own STL
    if (modular) echo(modules = n);
    if (!modular)
        let ($slots = [for (i = [0 : n - 1]) i])
            wall_mount(bounds[0], bounds[n], h, nx, nz, teardrop) children();
    else
        for (i = print_slot == 0 ? [0 : n - 1] : [print_slot - 1])
            let ($slots = [i])
                translate([print_slot == 0 ? i * spacing : 0, 0, 0])
                    wall_mount(bounds[i], bounds[i + 1], h, nx, nz, teardrop,
                               joints = [i > 0, i < n - 1])
                        children();
}
