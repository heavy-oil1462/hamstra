// My safe: the suppressor holder set up for the suppressors I own. A
// wrapper around cad/safe/suppressor_holder.scad, so the model stays
// generic and regen_all.py exports this build like any other model.
//
// Measured suppressors (diameter x length, mm):
//   1   45   x 230.7
//   2   45   x 230.7
//   3   41   x 265
//   4   31.5 x 130
// Each clip sits at about 60 % of its suppressor's length.
//
// Why a wrapper and not a Customizer preset: a preset must match the
// type and list length of the model's defaults (2 slots there), so it
// cannot hold a 4-slot row. Here the lists are the defaults.

use <../safe/suppressor_holder.scad>

/* [Slots] */
// Outer diameter of each suppressor, measured
suppressor_d = [45, 45, 41, 31.5];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0, 0, 0];
// Space between neighbouring holders, one entry per pair
gaps = [6, 6, 6];
// Height of each clip's top edge above the bottom of the plate
clip_top = [140, 140, 160, 80];

/* [Modular] */
// Print one module per slot, joined side by side with sliding dovetails
modular = false;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

suppressor_holder(suppressor_d = suppressor_d, wall_offset = wall_offset,
                  gaps = gaps, clip_top = clip_top, modular = modular,
                  print_slot = print_slot);
