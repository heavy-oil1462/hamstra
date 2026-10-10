// Gun safe scene: every safe model on a stretch of safe wall, with stand-in
// suppressors and barrels. Visual fit check only, renders to
// main_assembly.png. Not a printable part.
//
// Everything comes from the cad/my_safe builds. Stand-ins are placed with the models' own layout
// functions.
// Every model stands pad_t off the wall on its friction pad (not drawn).

include <design_params.scad>
use <lib/holders.scad>
use <safe/suppressor_holder.scad>
use <safe/barrel_holder.scad>
use <safe/gun_rack.scad>
use <my_safe/suppressors.scad>
use <my_safe/barrels.scad>
use <my_safe/rifles.scad>

// Show the safe wall and floor behind the parts
show_wall = true;

part_color = "#d9822b";  // printed parts
item_color = "#34383d";  // stand-in guns, barrels and suppressors

// the safe's back wall and floor; the floor top is z = 0
module safe_wall() {
    color("#c3c7cc") translate([-280, 0, 0]) cube([680, 2, 1000]);
    color("#9ea3a9") translate([-280, -150, -2]) cube([680, 152, 2]);
}

module stand_in(d, h) {
    color(item_color) cylinder(d = d, h = h);
}

// A round barrel tapers from breech to muzzle; an over and under set is
// its monoblock with the stacked barrels above it, flush with the round
// front of the monoblock (the square lump faces the wall). a: wall to
// axis of the breech.
module barrel_stand_in(breech, muzzle, l, a) {
    color(item_color)
        if (is_list(breech)) {
            translate([0, -a, 0]) linear_extrude(80) bore2d(breech);
            translate([0, -(a + (sy(breech) - sy(muzzle)) / 2), 0]) linear_extrude(l) bore2d(muzzle);
        } else {
            translate([0, -a, 0]) cylinder(d1 = breech, d2 = muzzle, h = l);
        }
}

if (show_wall) safe_wall();

// my long guns: the cad/my_safe gun rack, slid together from modules,
// with a stand-in muzzle resting in each slot (the guns themselves stand
// on the floor in front of everything else, left out to keep it legible)
let (data = my_rifles_data(),
     layout = gun_rack_layout(slot_w = data[0], wall_offset = data[1], gaps = data[2],
                              edge = data[3]),
     l = layout[2])
    translate([-l / 2 - 30, -pad_t, data[5] - gun_rack_plate_h()]) {
        color(part_color) translate([0, 0, gun_rack_plate_h()]) rotate([180, 0, 0])
            my_rifles(modular = true, spacing = 0);
        for (i = [0 : len(data[0]) - 1])
            let (s = data[4][i])
                translate([layout[0][i], -(layout[1][i] + sy(s) / 2), gun_rack_plate_h() - 140])
                    color(item_color) linear_extrude(200) bore2d(s);
    }

// my suppressors, left: the cad/my_safe build, two sets side by side,
// each a cradle row with its clip row mounted above it, stand-ins at the
// measured diameters and lengths
for (set = [1, 2]) translate([set == 1 ? -190 : -15, -pad_t, 120]) {
    data = my_suppressors_data(set);
    sd = data[0];
    sl = data[1];
    layout = suppressor_layout(suppressor_d = sd, wall_offset = data[2], gaps = data[3]);
    color(part_color) my_suppressors(part = str("cradle_", set), modular = false);
    color(part_color) translate([0, 0, data[4] - suppressor_clip_h()])
        my_suppressors(part = str("clip_", set), modular = false);
    for (i = [0 : len(sd) - 1])
        translate([layout[0][i], -layout[1][i], suppressor_floor_t()]) stand_in(sd[i], sl[i]);
}

// my spare barrels, right: the cup row stands on the safe floor (z = 0),
// one clip row above it; right of the gun rack so the long barrels clear it
translate([320, -pad_t, pad_t]) {
    data = my_barrels_data();
    bd = data[0];
    md = data[1];
    bl = data[2];
    layout = barrel_layout(breech_d = bd, barrel_d = md, wall_offset = data[3],
                           gaps = data[4], clip_align = data[5], clip_shift = data[8]);
    color(part_color) my_barrels(part = "cup", modular = false);
    color(part_color) translate([0, 0, barrel_floor_t() + data[7] - barrel_clip_h()])
        my_barrels(part = "clip", modular = false);
    for (i = [0 : len(bd) - 1])
        translate([layout[0][i], 0, barrel_floor_t()])
            barrel_stand_in(bd[i], data[6][i], bl[i], layout[1][i]);
}
