// My safe: a small single holder for the .22 suppressor, the Stalon RF
// (31.5 x 132, listed; 31.5 measured). The B14R and the AR15-22 share its
// thread, so one can serves both and gets its own small holder wherever
// the wall has room. Two ways to try, one magnet each:
//   clip  the suppressor holder's clip on its own, no cradle. The can is
//         light and the clip grips it, so it can hang at any angle.
//   cup   the suppressor holder's cradle on its own, with higher sides
//         and a closed front, so the can stands upright in it without a
//         clip above and lifts straight out.
//
// A wrapper around cad/safe/suppressor_holder.scad like suppressors.scad,
// so the clip ring and the cup are the ones tested on the bigger cans.

use <../safe/suppressor_holder.scad>

// Which holder to show
part = "clip"; // [clip, cup]

/* [Suppressor] */
// Outer diameter, measured
suppressor_d = 31.5;
// Length, from the listed spec (for the assembly scene)
suppressor_l = 132;

/* [Cup] */
// How far the can sits down in the cup, above its floor. The suppressor
// holder's cradle uses 20 with a clip above; alone it needs more
cup_depth = 40;
// Front opening as a fraction of the can diameter. 0 closes the cup: the
// can drops in from the top and cannot be knocked out the front
cup_snap = 0;

/* [Magnets] */
// One magnet: about 0.55 kg shear on bare steel for a can of about
// 100 g, over 5x
magnets_x = 1;
magnets_z = 1;

/* [Friction pad] */
// Show the friction pad instead (print in TPU, or use as the template to
// cut silicone sheet; pad_t in design_params.scad)
pad = false;

// [diameter, length] for the assembly scene.
function my_suppressor_22_data() = [suppressor_d, suppressor_l];

module my_suppressor_22(part = part, pad = pad) {
    assert(part == "clip" || part == "cup", str("unknown part: ", part));
    suppressor_holder(part = part == "cup" ? "cradle" : "clip",
                      suppressor_d = suppressor_d, cup_depth = cup_depth, cup_snap = cup_snap,
                      magnets_x = magnets_x, magnets_z = magnets_z,
                      clip_magnets_x = magnets_x, clip_magnets_z = magnets_z, pad = pad);
}

my_suppressor_22();
