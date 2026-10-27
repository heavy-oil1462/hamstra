// My safe: the bolt holder set up for my bolt guns, left to right. A
// wrapper around cad/safe/bolt_holder.scad, so the model stays generic
// and regen_all.py exports this build like any other model.
//
//   1   Sauer 202 6.5x55
//   2   Tikka T3 Lite
//   3   Bergara B14R
// Not measured yet: every slot has the model's default bore, which
// clears common bolts over the lugs. Measure each bolt over its lugs and
// type it in.

use <../safe/bolt_holder.scad>

/* [Slots] */
// Bolt diameter per slot, over the locking lugs (defaults, not measured yet)
bolt_d = [24, 24, 24];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0, 0];
// Space between neighbouring tubes, one entry per pair
gaps = [8, 8];

/* [Magnets] */
// Two magnets per holder, one above the other: about 1.1 kg shear on
// bare steel for a bolt of about 0.5 kg hanging off the front, about 2.2x
magnets_x = 1;
magnets_z = 2;

/* [Modular] */
// One holder per module, so a holder can be added or swapped on its own
modular = true;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

/* [Friction pad] */
// Show this part's friction pad instead (print in TPU, or use as the
// template to cut silicone sheet; pad_t in design_params.scad)
pad = false;

// These values for the assembly scene: [bolt diameters, wall offsets,
// gaps].
function my_bolts_data() = [bolt_d, wall_offset, gaps];

module my_bolts(modular = modular, print_slot = print_slot, spacing = 12, pad = pad) {
    bolt_holder(bolt_d = bolt_d, wall_offset = wall_offset, gaps = gaps,
                magnets_x = magnets_x, magnets_z = magnets_z,
                modular = modular, print_slot = print_slot,
                spacing = spacing, pad = pad);
}

my_bolts();
