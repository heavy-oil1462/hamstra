// My safe: a one ring test print of the suppressor clip for the W110 and
// the Victor L (set 1), before printing the full clip row. A 5 mm slice
// of each clip with the holder's own bore, clearance, snap and wall, made
// by the fit gauge's ring. Snap the can in: it should go in with a firm
// push and not turn by hand once in.

use <../calibration/fit_gauge.scad>
use <../safe/suppressor_holder.scad>
use <suppressors.scad>

// Cans to test: the W110 and the Victor L from set 1
test_d = [my_suppressors_data(1)[0][0], my_suppressors_data(1)[0][2]];

ring = suppressor_clip_ring();
for (i = [0 : len(test_d) - 1])
    translate([i * (max(test_d) + 2 * ring[2] + 6), 0, 0])
        gauge_ring(test_d[i], ring[0], ring[1], ring[2]);
