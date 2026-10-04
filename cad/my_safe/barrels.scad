// My safe: the spare barrel holder set up for my switch barrels. A
// wrapper around cad/safe/barrel_holder.scad, so the model stays generic
// and regen_all.py exports this build like any other model.
//
// Measured barrels (mm):
//   1   27 at the breech, 24 at the muzzle, 660 long: SSG 3000 / STR 200
//       drop-in, 6 mm Creedmoor, M24 profile, 26 inch (from the spec)
//   2   27 at the breech, 17.5 at the muzzle, about 450 long (estimate)
//   3   B25 over and under shotgun barrel set: monoblock 28 wide x 67
//       deep, two 21 mm barrels stacked away from the wall, about 710
//       long (estimate, B25 barrels are commonly 28 to 30 inch)
// The clips use the muzzle sizes, so mount each clip just below its
// muzzle. The cup row stands on the safe floor.

use <../safe/barrel_holder.scad>

// Which part to show
part = "cup"; // [cup, clip]

/* [Slots] */
// Breech end size per barrel, measured: a diameter, or [width, depth]
breech_d = [27, 27, [28, 67]];
// Muzzle size per barrel, measured (the clip sits just below it)
barrel_d = [24, 17.5, [21, 42]];
// Barrel length (only the assembly scene uses it); 2 and 3 are estimates
barrel_l = [660, 450, 710];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0, 0];
// Space between neighbouring cups, one entry per pair
gaps = [8, 8];
// Clip position per slot: 0 centered over the cup, 1 back flush with it
// (the B25 barrels run flush with the back of the monoblock, to the wall)
clip_align = [0, 0, 1];

/* [Modular] */
// Print one base module per slot, joined side by side with sliding dovetails
modular = false;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

// These values for the assembly scene: [breech, muzzle, lengths, wall
// offsets, gaps, clip align].
function my_barrels_data() = [breech_d, barrel_d, barrel_l, wall_offset, gaps, clip_align];

module my_barrels(part = part, modular = modular, print_slot = print_slot,
                  spacing = 12) {
    barrel_holder(part = part, breech_d = breech_d, barrel_d = barrel_d,
                  wall_offset = wall_offset, gaps = gaps, clip_align = clip_align,
                  modular = modular,
                  print_slot = print_slot, spacing = spacing);
}

my_barrels();
