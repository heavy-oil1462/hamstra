// Gun safe scene: every safe model on a stretch of safe wall, with stand-in
// suppressors and barrels. Visual fit check only, renders to
// main_assembly.png. Not a printable part.
//
// The scene passes its own slot layouts to the models so the stand-ins
// can be placed with the same holders.scad functions the models use.

include <design_params.scad>
use <lib/holders.scad>
use <safe/suppressor_holder.scad>
use <safe/barrel_holder.scad>
use <safe/gun_rack.scad>

scene_suppressor_d = [50, 44];
scene_breech_d = [32, 30];
scene_barrel_d = [20, 18];
scene_barrel_offset = [0, 10];
scene_barrel_gaps = [8];

module safe_wall() {
    color("dimgray") translate([-260, 0, -20]) cube([520, 2, 700]);
}

module stand_in(d, h) {
    color("black") cylinder(d = d, h = h);
}

safe_wall();

// gun rack along the top, model defaults, slid together from modules
color("peru") translate([-107, 0, 560]) rotate([90, 0, 0]) gun_rack(modular = true, spacing = 0);

// two suppressors, left
translate([-150, 0, 120]) {
    color("peru") rotate([90, 0, 0]) suppressor_holder(suppressor_d = scene_suppressor_d);
    // mirrors suppressor_holder's layout with its default knobs
    layout = holder_pair_layout([for (d = scene_suppressor_d) d + item_clearance], wall,
                                [for (d = scene_suppressor_d) d + 0.6], 3, 6, 0);
    for (i = [0 : len(scene_suppressor_d) - 1])
        translate([layout[0][i], -layout[1][i], 3]) stand_in(scene_suppressor_d[i], 180);
}

// two spare barrels, right: cup at the bottom, clip up the wall. Mirrors
// barrel_holder's layout rule: spaced by the fatter part per slot.
translate([120, 0, 0]) {
    color("peru") barrel_holder(part = "cup", breech_d = scene_breech_d,
                                barrel_d = scene_barrel_d,
                                wall_offset = scene_barrel_offset,
                                gaps = scene_barrel_gaps);
    color("peru") translate([0, 0, 420])
        barrel_holder(part = "clip", breech_d = scene_breech_d,
                      barrel_d = scene_barrel_d,
                      wall_offset = scene_barrel_offset, gaps = scene_barrel_gaps);
    ds = [for (d = scene_breech_d) d + item_clearance];
    xs = holder_xs(ds, 3, scene_barrel_gaps);
    axes = holder_axes(ds, 1, scene_barrel_offset);
    for (i = [0 : len(ds) - 1])
        translate([xs[i], -axes[i], 2]) {
            stand_in(scene_breech_d[i], 60);
            stand_in(scene_barrel_d[i], 520);
        }
}
