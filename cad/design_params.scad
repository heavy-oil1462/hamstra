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
// Neodymium disc magnets glued into pockets in the back face. The
// magnet face sits flush with the back so it touches the safe wall:
// pull force collapses with any gap, so never bury the magnet behind
// a printed skin. Holding force on a vertical wall is shear, roughly
// a quarter of the rated pull, so count magnets generously.
magnet_d = 15;          // disc diameter
magnet_h = 5;           // disc thickness
magnet_clearance = 0.2; // added to magnet_d for the pocket. MEASURED with
                        // cad/calibration/magnet_pocket_gauge.scad, never
                        // tuned by eye. Printer, profile and filament specific.
magnet_recess = 0;      // extra pocket depth beyond magnet_h. 0 = flush.
                        // A felt-lined safe wall wants 0; a bare painted
                        // wall can take 0.2 to protect the paint.
magnet_chamfer = 0.4;   // pocket entry chamfer, eats the elephant foot
magnet_edge = 4;        // minimum plastic from a pocket to the plate edge

// --- Wall plates ---
// Every safe-mounted model has a flat back plate carrying the magnets.
back_skin = 2;                  // plastic behind the magnet
back_t = magnet_h + magnet_recess + back_skin; // back plate thickness
plate_r = 4;                    // back plate corner radius

// --- General print rules ---
wall = 2.4;             // default shell wall (6 perimeters at 0.4)
item_clearance = 1.0;   // added to a gun item's measured diameter for
                        // sleeves and cups it slides into
eps = 0.01;             // cutter overrun, keeps difference() faces apart

$fa = 2;
$fs = 0.4;
