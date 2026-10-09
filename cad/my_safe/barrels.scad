// My safe: the spare barrel holder set up for my switch barrels. A
// wrapper around cad/safe/barrel_holder.scad, so the model stays generic
// and regen_all.py exports this build like any other model.
//
// Measured barrels (mm):
//   1   9.3: 27 at the breech, 17.5 at the muzzle, about 450 long
//       (estimate)
//   2   6 mm Creedmoor: 27 at the breech, 24 at the muzzle, 660 long, SSG
//       3000 / STR 200 drop-in, M24 profile, 26 inch (from the spec)
//   3   B25 over and under shotgun barrel set: 40 wide at its widest
//       (the first cup, sized for a 28 wide monoblock, did not fit) x 67
//       deep, two straight 21 mm barrels stacked away from the wall,
//       about 710 long (estimate, B25 barrels are commonly 28 to 30 inch).
//       The monoblock is round on the top barrel side and near square
//       at the lump. It stands lump to the wall, round side out: its cup
//       is square at the back (1 mm corner radius) and round at the
//       front. The cup only locates it, the clip holds. The clip grips
//       only the barrel nearest the wall, which holds the set fine.
//       Standing plumb in the printed cup, that barrel is 20 mm from the
//       safe wall (measured).
// The cup row stands on the safe floor. One joined clip row, mounted with
// its top 400 mm above the cup floor, just below the shortest muzzle; it
// sits above every barrel's center of mass. The clips are sized for the
// diameter at that height, not the muzzle: 1 and 2 are straight-taper
// estimates there (the M24 contour starts with a straight shank, so 2
// may run a little thicker). The first printed clips were all too loose;
// a test print of ring slices picked bores about 15 percent under the
// barrel, now clip_fit in design_params.scad.

use <../safe/barrel_holder.scad>

// Which part to show
part = "cup"; // [cup, clip]

/* [Slots] */
// Breech end size per barrel, measured: a diameter, or [width, depth,
// front corner radius, back corner radius]
breech_d = [27, 27, [40, 67, 20, 1]];
// Barrel size per slot where the clip grips it, 400 mm up (the clip bore
// is clip_fit times this). The B25 clip grips the barrel nearest the
// wall only
barrel_d = [18.6, 25.2, 21];
// Muzzle size per barrel, measured (only the assembly scene uses it)
muzzle_d = [17.5, 24, [21, 42]];
// Barrel length (only the assembly scene uses it); 1 and 3 are estimates
barrel_l = [450, 660, 710];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0, 0];
// Space between neighbouring cups, one entry per pair
gaps = [8, 8];
// Clip position per slot: 0 centered over the cup, 1 back flush with it
clip_align = [0, 0, 1];
// Clip moved away from the wall per slot, mm. The B25 stands lump to the
// wall; its nearest barrel measured 20 mm from the safe wall, so its axis
// sits 30.5 out, 29.5 from the plate back behind the 1 mm pad. Back flush
// puts the clip axis at 17.4, so 12 more
clip_shift = [0, 0, 12];
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
// offsets, gaps, clip align, muzzle, clip top, clip shift].
function my_barrels_data() = [breech_d, barrel_d, barrel_l, wall_offset, gaps, clip_align,
                              muzzle_d, clip_top, clip_shift];

module my_barrels(part = part, modular = modular, print_slot = print_slot,
                  spacing = 12, pad = pad) {
    barrel_holder(part = part, breech_d = breech_d, barrel_d = barrel_d,
                  wall_offset = wall_offset, gaps = gaps, clip_align = clip_align,
                  clip_shift = clip_shift, clip_row = true, modular = modular,
                  print_slot = print_slot, spacing = spacing, pad = pad);
}

my_barrels();
