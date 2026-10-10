// My safe: the suppressor holder set up for the suppressors I own. A
// wrapper around cad/safe/suppressor_holder.scad, so the model stays
// generic and regen_all.py exports this build like any other model.
//
// Measured suppressors (diameter x length, mm):
//   1   50   x 240  (Stalon W110, from the official spec; the first
//   2   50   x 240   measurement, 45 x 230.7, was off)
//   3   41   x 258  (Stalon Victor L, from the official spec)
//   4   31.5 x 130
//   5   29   x 120  (IMS22 for the AR22, not bought yet: listed size)
//   6   49.1 x 235  (Stalon X108, over barrel, not measured yet: listed
//       size)
// Two sets of three, each its own cradle row with its own clip row
// above it: set 1 the W110s and the Victor L, set 2 the X108 and the
// two short .22 cans. A clip row is set for the shortest can in its set
// and still holds the longer ones there.
//
// Why a wrapper and not a Customizer preset: a preset must match the
// type and list length of the model's defaults (2 slots there), so it
// cannot hold these rows. Here the lists are the defaults.

use <../safe/suppressor_holder.scad>

// Which piece of which set to show
part = "cradle_1"; // [cradle_1, clip_1, cradle_2, clip_2]

/* [Set 1] */
// Outer diameter of each suppressor, measured
set1_d = [50, 50, 41];
// Length of each suppressor, measured (for the assembly scene)
set1_l = [240, 240, 258];
// Extra distance from the safe wall per slot, 0 = tight to the wall
set1_wall_offset = [0, 0, 0];
// Space between neighbouring holders, one entry per pair
set1_gaps = [6, 6];
// Where to mount the clip row: its top edge above the cradle row's
// bottom (only the assembly scene uses it). Above the middle of the
// shortest can, so it holds them all upright
set1_clip_top = 150;

/* [Set 2] */
// Outer diameter of each suppressor, measured
set2_d = [49.1, 31.5, 29];
// Length of each suppressor, measured (for the assembly scene)
set2_l = [235, 130, 120];
// Extra distance from the safe wall per slot, 0 = tight to the wall
set2_wall_offset = [0, 0, 0];
// Space between neighbouring holders, one entry per pair
set2_gaps = [6, 6];
// Where to mount the clip row: its top edge above the cradle row's
// bottom (only the assembly scene uses it). Low enough for the short .22
// cans, and it still holds the X108
set2_clip_top = 80;

/* [Magnets] */
// Magnet columns on each cradle row, two rows each. Under 1 kg of
// suppressors per set: 2 columns give about 3.2 kg shear on bare steel
magnets_x = 2;

/* [Back plate] */
// Back plate 10 mm shorter at both ends than the cups and clips, to fit
// the spot on the safe wall
plate_trim = 10;

/* [Modular] */
// Print one module per slot, joined side by side with sliding dovetails
modular = false;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

/* [Friction pad] */
// Show this part's friction pad instead (print in TPU, or use as the
// template to cut silicone sheet; pad_t in design_params.scad)
pad = false;

// The piece and set of a part: "clip_2" is the clip row of set 2.
function suppressor_piece(part) = part == "clip_1" || part == "clip_2" ? "clip" : "cradle";
function suppressor_set(part) = part == "cradle_2" || part == "clip_2" ? 2 : 1;

// These values for the assembly scene, per set: [diameters, lengths,
// wall offsets, gaps, clip top].
function my_suppressors_data(set = 1) =
    set == 2 ? [set2_d, set2_l, set2_wall_offset, set2_gaps, set2_clip_top]
             : [set1_d, set1_l, set1_wall_offset, set1_gaps, set1_clip_top];

module my_suppressors(part = part, modular = modular, print_slot = print_slot,
                      spacing = 12, pad = pad) {
    assert(search([part], ["cradle_1", "clip_1", "cradle_2", "clip_2"]) != [[]],
           str("unknown part: ", part));
    data = my_suppressors_data(suppressor_set(part));
    suppressor_holder(part = suppressor_piece(part),
                      suppressor_d = data[0], wall_offset = data[2], gaps = data[3],
                      magnets_x = magnets_x, plate_trim = plate_trim,
                      modular = modular, print_slot = print_slot,
                      spacing = spacing, pad = pad);
}

my_suppressors();
