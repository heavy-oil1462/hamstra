// My safe: a single snap clip for the .22 suppressor, the Stalon RF
// (31.5 x 130 measured). The B14R and the AR15-22 share its thread, so one
// can serves both and gets its own small holder wherever the wall has
// room. It is the suppressor holder's clip on its own: one ring, one
// magnet, no cradle. The can is light and the clip grips it, so it can
// hang at any angle.
//
// A wrapper around cad/safe/suppressor_holder.scad like suppressors.scad,
// so the clip ring is the same one tested on the bigger cans.

use <../safe/suppressor_holder.scad>

/* [Suppressor] */
// Outer diameter, measured
suppressor_d = 31.5;
// Length, measured (for the assembly scene)
suppressor_l = 130;

/* [Magnets] */
// One magnet: about 0.8 kg shear on bare steel for a can of a few
// hundred grams
magnets_x = 1;
magnets_z = 1;

/* [Friction pad] */
// Show the friction pad instead (print in TPU, or use as the template to
// cut silicone sheet; pad_t in design_params.scad)
pad = false;

// [diameter, length] for the assembly scene.
function my_suppressor_22_data() = [suppressor_d, suppressor_l];

module my_suppressor_22(pad = pad) {
    suppressor_holder(part = "clip", suppressor_d = suppressor_d,
                      clip_magnets_x = magnets_x, clip_magnets_z = magnets_z, pad = pad);
}

my_suppressor_22();
