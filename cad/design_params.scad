// ============================================================
// HAMSTRA SHARED DESIGN PARAMETERS: single source of truth for
// every dimension two or more models must agree on.
//
// Consumers:
//   - models in cad/<category>/ do   include <../design_params.scad>
//   - libraries in cad/lib/ do       include <../design_params.scad>
//   - scripts/check_params.py FAILS the build if any of these names
//     is re-declared anywhere else. Change values HERE only.
//
// Model-specific knobs (suppressor diameter, slot count, ...) live at
// the top of each model file where the OpenSCAD Customizer shows them.
// Only values that several models share belong here.
//
// Keep this file to simple `name = value;` lines so the tooling can
// parse it. One-off experiments: `openscad -D name=value` beats
// editing this file.
// ============================================================

// --- Mounting magnets (bought) ---
// Neodymium disc magnets glued into pockets in the back face. Nothing
// but air sits between a magnet and the safe wall: pull force collapses
// with any gap, so never bury the magnet behind a printed skin. Holding
// force on a vertical wall is shear, roughly a quarter of the rated pull,
// so count magnets generously.
magnet_d = 12;          // disc diameter
magnet_h = 5;           // disc thickness
magnet_clearance = 0.2; // added to magnet_d for the pocket. MEASURED with
                        // cad/calibration/magnet_pocket_gauge.scad, never
                        // tuned by eye. Printer, profile and filament specific.
magnet_recess = 0;      // extra pocket depth, pulls the magnet face back
                        // from where pad_t and pad_air put it. Without a
                        // pad a bare painted wall can take 0.2 to protect
                        // the paint.
magnet_chamfer = 0.4;   // pocket entry chamfer, eats the elephant foot
magnet_edge = 4;        // minimum plastic from a pocket to the plate edge

// --- Friction pad ---
// A bare plate slides down a smooth steel wall. A pad between plate and
// wall grips it: TPU printed from each model's pad part, or silicone
// sheet cut with that part as the template. The pad has a hole at each
// magnet and the magnets stand out of the back face through it, stopping
// pad_air short of the wall, so the pad carries the magnets' pull and
// takes the friction while only air sits in front of the magnets. The
// magnets also hold the pad in place, no glue needed. A row standing on
// the safe floor (the barrel cup row) gets a second pad under it, cut to
// its footprint: grip on the floor and an air gap under the cups. No
// magnet holds that one, so it has a lip the row sits in, open toward
// the wall where the wall pad is. Silicone cannot make the lip: use
// self-adhesive sheet there.
pad_t = 1;              // pad thickness, 0 for no pad (magnets flush)
pad_air = 0.3;          // magnet face to wall. Soft silicone squeezes,
                        // give it more
pad_hole_clearance = 0.4; // added to magnet_d for the pad's holes
pad_inset = 0.5;        // pad edge inside the plate edge
base_pad_gap = 5;       // a floor standing row's base pad, printed in
                        // front of its wall pad, this far from it
base_rim_h = 2;         // lip the base pad rises around the row's
                        // footprint, so the row sits in it (nothing else
                        // holds the base pad); 0 for a flat pad
base_rim_w = 1.2;       // lip thickness (3 perimeters)
base_rim_clearance = 0.3; // footprint to the inside of the lip
// how far a magnet stands out of the back face
magnet_out = pad_t > 0 ? pad_t - pad_air : 0;

// --- Wall plates ---
// Every safe-mounted model has a flat back plate carrying the magnets.
// One solid plate as thick as a magnet plus its skin, so the front shows
// no trace of the magnets. A skin closes each pocket in front: the magnet
// presses in to it, which sets how far it stands out, and the glue has a
// floor. A magnet standing out for the pad leaves that much more skin. Setting plate_t below back_t gives a lighter plate
// with a boss around each magnet instead.
back_skin = 1.2;                // skin in front of a flush magnet (3 perimeters
                                // at 0.4); 0 runs the pocket through the boss
back_t = magnet_h + magnet_recess + back_skin; // thickness at a magnet (boss)
plate_t = back_t;               // plate thickness away from the magnets
boss_wall = 2;                  // plastic around a pocket in its boss
plate_r = 4;                    // back plate corner radius

// --- Module connector (sliding dovetail) ---
// Modular prints (modular = true in a model) split a row into one module
// per slot. Neighbours join with a symmetric dovetail along the side
// edges of their back plates: tongue on the right edge, slot on the left,
// sliding vertically. The tongue starts on the bed and the slot is
// closed at the far end; tongue and slot end in matching 45 degree
// slopes that meet face to face when the plates are level. Upright prints close the slot at the
// top; the gun rack, printed top down, closes it at the bottom (flip in
// lib/dovetail.scad). 45 degree flanks print without support in either
// orientation. Shared by every model so modules of the same row height
// can mix.
dovetail_d = 2;             // how far the tongue reaches into the neighbour
dovetail_neck = 2.5;        // tongue thickness at its root
dovetail_wall = 1.6;        // plastic in front of and behind the slot
dovetail_clearance = 0.3;   // MEASURED with cad/calibration/dovetail_gauge.scad
dovetail_stop = 3;          // solid plate beyond the joint's sloped end
dovetail_spine_w = 8;       // width of the thickened plate edge carrying the joint
// thickness of that edge: slot plus a wall in front and behind
dovetail_spine_t = dovetail_neck + 2 * (dovetail_d + dovetail_clearance + dovetail_wall);

// --- General print rules ---
wall = 2.4;             // default shell wall (6 perimeters at 0.4)
item_clearance = 1.0;   // added to a gun item's measured diameter for
                        // sleeves and cups it slides into
clip_fit = 0.85;        // snap clip bore as a fraction of the item's
                        // measured diameter. Printed PETG rings stretch a
                        // lot: barrel clips at the barrel size were all too
                        // loose, 15 percent under won a slice test
eps = 0.01;             // cutter overrun, keeps difference() faces apart

$fa = 2;
$fs = 0.4;
