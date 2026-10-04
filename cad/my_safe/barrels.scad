// My safe: the spare barrel holder set up for my switch barrels. A
// wrapper around cad/safe/barrel_holder.scad, so the model stays generic
// and regen_all.py exports this build like any other model.
//
// Measured barrels (mm):
//   1   27 at the breech, 24 at the muzzle, 660 long: SSG 3000 / STR 200
//       drop-in, 6 mm Creedmoor, M24 profile, 26 inch (from the spec)
//   2   27 at the breech, 17.5 at the muzzle, about 450 long (estimate)
// The clips use the muzzle diameters, so mount each clip just below its
// muzzle. The cup row stands on the safe floor.
//
// Still to add: the O/U shotgun barrel set (21 mm barrels) once its
// monoblock is measured: breech_d [width, depth], barrel_d [21, 42].

use <../safe/barrel_holder.scad>

// Which part to show
part = "cup"; // [cup, clip]

/* [Slots] */
// Breech end diameter per barrel, measured
breech_d = [27, 27];
// Muzzle diameter per barrel, measured (the clip sits just below it)
barrel_d = [24, 17.5];
// Barrel length (only the assembly scene uses it); the second is an estimate
barrel_l = [660, 450];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0];
// Space between neighbouring cups, one entry per pair
gaps = [8];

/* [Modular] */
// Print one base module per slot, joined side by side with sliding dovetails
modular = false;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

// These values for the assembly scene: [breech, muzzle, lengths, wall
// offsets, gaps].
function my_barrels_data() = [breech_d, barrel_d, barrel_l, wall_offset, gaps];

module my_barrels(part = part, modular = modular, print_slot = print_slot,
                  spacing = 12) {
    barrel_holder(part = part, breech_d = breech_d, barrel_d = barrel_d,
                  wall_offset = wall_offset, gaps = gaps, modular = modular,
                  print_slot = print_slot, spacing = spacing);
}

my_barrels();
