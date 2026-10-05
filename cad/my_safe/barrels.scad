// My safe: the spare barrel holder set up for my switch barrels. A
// wrapper around cad/safe/barrel_holder.scad, so the model stays generic
// and regen_all.py exports this build like any other model.
//
// Measured barrels (mm):
//   1   9.3: 27 at the breech, 17.5 at the muzzle, about 450 long
//       (estimate)
//   2   6 mm Creedmoor: 27 at the breech, 24 at the muzzle, 660 long, SSG
//       3000 / STR 200 drop-in, M24 profile, 26 inch (from the spec)
//   3   B25 over and under shotgun barrel set: monoblock 28 wide x 67
//       deep, two straight 21 mm barrels stacked away from the wall,
//       about 710 long (estimate, B25 barrels are commonly 28 to 30 inch).
//       The monoblock is round on the top barrel side (to the wall) and
//       near square at the lump: its cup gets a 1 mm front corner
//       radius. The cup only locates it, the clip holds.
// The cup row stands on the safe floor. One joined clip row, mounted with
// its top 400 mm above the cup floor, just below the shortest muzzle; it
// sits above every barrel's center of mass. The clips are sized for the
// diameter at that height, not the muzzle: 1 and 2 are straight-taper
// estimates there (the M24 contour starts with a straight shank, so 2
// may run a little thicker). Confirm them with the fit gauge rings.

use <../safe/barrel_holder.scad>

// Which part to show
part = "cup"; // [cup, clip]

/* [Slots] */
// Breech end size per barrel, measured: a diameter, or [width, depth]
breech_d = [27, 27, [28, 67, 1]];
// Barrel size per slot where the clip grips it, 400 mm up (1, 2 estimates)
barrel_d = [18.6, 25.2, [21, 42]];
// Muzzle size per barrel, measured (only the assembly scene uses it)
muzzle_d = [17.5, 24, [21, 42]];
// Barrel length (only the assembly scene uses it); 1 and 3 are estimates
barrel_l = [450, 660, 710];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0, 0];
// Space between neighbouring cups, one entry per pair
gaps = [8, 8];
// Clip position per slot: 0 centered over the cup, 1 back flush with it
// (the B25 barrels run flush with the back of the monoblock, to the wall)
clip_align = [0, 0, 1];
// Where to mount the clip row: its top edge above the cup floor (scene only)
clip_top = 400;

/* [Modular] */
// Print one base module per slot, joined side by side with sliding dovetails
modular = false;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

/* [Friction pad] */
// Show this part's friction pad instead (print in TPU, or use as the
// template to cut silicone sheet; pad_t in design_params.scad)
pad = false;

// These values for the assembly scene: [breech, clip size, lengths, wall
// offsets, gaps, clip align, muzzle, clip top].
function my_barrels_data() = [breech_d, barrel_d, barrel_l, wall_offset, gaps, clip_align,
                              muzzle_d, clip_top];

module my_barrels(part = part, modular = modular, print_slot = print_slot,
                  spacing = 12, pad = pad) {
    barrel_holder(part = part, breech_d = breech_d, barrel_d = barrel_d,
                  wall_offset = wall_offset, gaps = gaps, clip_align = clip_align,
                  clip_row = true, modular = modular,
                  print_slot = print_slot, spacing = spacing, pad = pad);
}

my_barrels();
