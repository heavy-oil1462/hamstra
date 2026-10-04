// My safe: the suppressor holder set up for the suppressors I own. A
// wrapper around cad/safe/suppressor_holder.scad, so the model stays
// generic and regen_all.py exports this build like any other model.
//
// Measured suppressors (diameter x length, mm):
//   1   45   x 230.7
//   2   45   x 230.7
//   3   41   x 265
//   4   31.5 x 130
// One clip row for all, mounted with its top 80 mm above the cradle
// row's bottom: low enough for the short .22 can, and it still holds the
// long ones.
//
// Why a wrapper and not a Customizer preset: a preset must match the
// type and list length of the model's defaults (2 slots there), so it
// cannot hold a 4-slot row. Here the lists are the defaults.

use <../safe/suppressor_holder.scad>

// Which piece to show
part = "cradle"; // [cradle, clip]

/* [Slots] */
// Outer diameter of each suppressor, measured
suppressor_d = [45, 45, 41, 31.5];
// Length of each suppressor, measured (for the assembly scene)
suppressor_l = [230.7, 230.7, 265, 130];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0, 0, 0];
// Space between neighbouring holders, one entry per pair
gaps = [6, 6, 6];
// Where to mount the clip row: its top edge above the cradle row's bottom
// (only the assembly scene uses it)
clip_top = 80;

/* [Modular] */
// Print one module per slot, joined side by side with sliding dovetails
modular = false;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

// These values for the assembly scene: [diameters, lengths, wall
// offsets, gaps, clip tops].
function my_suppressors_data() = [suppressor_d, suppressor_l, wall_offset, gaps, clip_top];

module my_suppressors(part = part, modular = modular, print_slot = print_slot,
                      spacing = 12) {
    suppressor_holder(part = part, suppressor_d = suppressor_d,
                      wall_offset = wall_offset, gaps = gaps, modular = modular,
                      print_slot = print_slot, spacing = spacing);
}

my_suppressors();
