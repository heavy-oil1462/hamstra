// Gun safe scene: every safe model on a stretch of safe wall, with stand-in
// suppressors and barrels. Visual fit check only, renders to
// main_assembly.png. Not a printable part.

include <design_params.scad>
use <lib/holders.scad>
use <safe/suppressor_holder.scad>
use <safe/barrel_cup.scad>
use <safe/barrel_clip.scad>
use <safe/gun_rack.scad>

scene_suppressor_d = 50;
scene_breech_d = 32;
scene_barrel_d = 20;

module safe_wall() {
    color("dimgray") translate([-260, 0, -20]) cube([520, 2, 700]);
}

module stand_in(d, h) {
    color("black") cylinder(d = d, h = h);
}

safe_wall();

// gun rack along the top
color("peru") translate([-112.5, 0, 560]) rotate([90, 0, 0]) gun_rack();

// two suppressors, left
translate([-150, 0, 150]) {
    color("peru") suppressor_holder(suppressor_d = scene_suppressor_d);
    d = scene_suppressor_d + item_clearance;
    for (s = [-1, 1])
        translate([s * holder_pitch(d, wall, 4) / 2, holder_y(d, 1), 2])
            stand_in(scene_suppressor_d, 180);
}

// two spare barrels, right: cup at the bottom, clip up the wall
translate([120, 0, 0]) {
    color("peru") barrel_cup(breech_d = scene_breech_d);
    color("peru") translate([0, 0, 420]) barrel_clip(barrel_d = scene_barrel_d);
    for (s = [-1, 1])
        translate([s * barrel_pitch / 2, -barrel_axis_y, 2]) {
            stand_in(scene_breech_d, 60);
            stand_in(scene_barrel_d, 520);
        }
}
