// My safe: cup fit gauge for the B25 monoblock, before printing the
// barrel cup row. The monoblock is round toward the wall and close to
// square at the front; the rows try front corner radii from round (14)
// down, the columns the clearance. Push the monoblock in from the top
// with its back to the label tab. Put the winning radius into breech_d
// in cad/my_safe/barrels.scad as [28, 67, r], and the clearance into
// item_clearance if it differs. A wrapper around
// cad/calibration/fit_gauge.scad, exported by regen_all.py.

use <../calibration/fit_gauge.scad>

/* [B25 monoblock] */
// Monoblock as measured: [width along the wall, depth]
monoblock = [28, 67];
// Front corner radii to try, one row each (14 = round)
radii = [14, 6, 2];
// Clearances to try, one column each (the models use item_clearance, 1.0)
clearances = [0.6, 1.0, 1.4];

cup_gauge(monoblock, radii, clearances);
