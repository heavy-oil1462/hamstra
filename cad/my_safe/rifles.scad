// My safe: the gun rack set up for my long guns, left to right. A
// wrapper around cad/safe/gun_rack.scad, so the model stays generic and
// regen_all.py exports this build like any other model.
//
// Slots are open, the guns just lean in: slot width is the barrel width
// where it rests plus 4 mm. Break actions have no bolt, so they sit tight
// to the wall and close together (the 12 mm finger is about the minimum:
// modular splits it in half and each half carries a 5 mm gusset). Bolt
// guns get a wide gap on their left for the bolt and some wall offset
// for their scopes.
//
//   1   Miroku O/U combo 12 ga / 6.5x55, 20.5 mm shotgun barrel on top
//   2   Tikka O/U combo 12 ga / .222 Rem, 20.5 mm shotgun barrel
//   3   Browning B25 O/U 12 ga, 20 mm barrels
//   4   side by side 12 ga, 43 mm across both barrels
//   5   Sauer 202 6.5x55, 17 mm barrel, slightly larger scope
//   6   Tikka T3 Lite in KKC duogrip, 51 cm barrel, LPVO or Aimpoint
//       (not here yet: barrel size is an estimate)
//   7   Bergara B14R, 22 mm barrel, 45 cm, large Razor HD Gen2 in an XLR
//       chassis: the most clearance
//   8   Schmeisser AR15-22, 45 cm barrel (not here yet: barrel size is an
//       estimate)
// The over and unders stand with their barrels stacked away from the
// wall, so their slot is one barrel wide.

use <../safe/gun_rack.scad>

/* [Slots] */
// Slot width per gun: barrel width where it rests plus 4 mm
slot_w = [24.5, 24.5, 24, 47, 21, 21, 26, 23];
// Extra distance from the safe wall per gun, for scopes
wall_offset = [0, 0, 0, 0, 15, 5, 35, 10];
// Finger between neighbouring slots: tight for break actions, wide on
// the left of each bolt gun for its bolt
gaps = [12, 12, 12, 45, 45, 60, 35];
// Finger at each end of the rack
edge = 15;

/* [Modular] */
// Print one module per gun, joined side by side with sliding dovetails
// (the whole rack is wider than a print bed)
modular = true;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

// Barrel shape where it rests, for the assembly scene's stand-ins: a
// diameter, [width, depth] for an over and under, [width, depth] wide
// for the side by side
muzzle_d = [[20.5, 41], [20.5, 41], [20, 40], [43, 21.5], 17, 17, 22, 19];
// Height of the rack's shelf top above the safe floor (scene only): just
// below the muzzle of the shortest gun standing on the floor, for now the
// Bergara at 61 cm overall, leaving about 5 cm of barrel above the shelf
rack_top = 560;

// These values for the assembly scene: [slot widths, wall offsets, gaps,
// edge, barrel shapes, rack top].
function my_rifles_data() = [slot_w, wall_offset, gaps, edge, muzzle_d, rack_top];

module my_rifles(modular = modular, print_slot = print_slot, spacing = 12) {
    gun_rack(slot_w = slot_w, wall_offset = wall_offset, gaps = gaps, edge = edge,
             modular = modular, print_slot = print_slot, spacing = spacing);
}

my_rifles();
