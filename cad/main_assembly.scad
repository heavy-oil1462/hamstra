// Gun safe scene: every safe model on a stretch of safe wall, with stand-in
// suppressors and barrels. Visual fit check only, renders to
// main_assembly.png. Not a printable part.
//
// The suppressors and barrels come from the cad/my_safe builds; the gun
// rack uses its defaults. Stand-ins are placed with the models' own layout
// functions.

include <design_params.scad>
use <lib/holders.scad>
use <safe/suppressor_holder.scad>
use <safe/barrel_holder.scad>
use <safe/gun_rack.scad>
use <my_safe/suppressors.scad>
use <my_safe/barrels.scad>


// the safe's back wall and floor; the floor top is z = 0
module safe_wall() {
    color("dimgray") translate([-260, 0, 0]) cube([520, 2, 700]);
    color("gray") translate([-260, -150, -2]) cube([520, 152, 2]);
}

module stand_in(d, h) {
    color("black") cylinder(d = d, h = h);
}

safe_wall();

// gun rack along the top, model defaults, slid together from modules
color("peru") translate([-107, 0, 560]) rotate([90, 0, 0]) gun_rack(modular = true, spacing = 0);

// my suppressors, left: the cad/my_safe build with stand-ins at their
// measured diameters and lengths
translate([-150, 0, 120]) {
    data = my_suppressors_data();
    sd = data[0];
    sl = data[1];
    layout = suppressor_layout(suppressor_d = sd, wall_offset = data[2], gaps = data[3]);
    color("peru") rotate([90, 0, 0]) my_suppressors(modular = false);
    for (i = [0 : len(sd) - 1])
        translate([layout[0][i], -layout[1][i], suppressor_floor_t()]) stand_in(sd[i], sl[i]);
}

// my spare barrels, right: the cup row stands on the safe floor (z = 0),
// each clip sits just below its barrel's muzzle; right of the gun rack so
// the long barrel clears it
translate([195, 0, 0]) {
    data = my_barrels_data();
    bd = data[0];
    md = data[1];
    bl = data[2];
    layout = barrel_layout(breech_d = bd, barrel_d = md, wall_offset = data[3],
                           gaps = data[4]);
    color("peru") my_barrels(part = "cup", modular = false);
    for (i = [0 : len(bd) - 1]) {
        color("peru") translate([0, 0, barrel_floor_t() + bl[i] - 30 - 15])
            my_barrels(part = "clip", print_slot = i + 1);
        translate([layout[0][i], -layout[1][i], barrel_floor_t()])
            color("black") cylinder(d1 = bd[i], d2 = md[i], h = bl[i]);
    }
}
