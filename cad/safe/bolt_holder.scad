// Bolt holder: a straight tube per bolt, open at the bottom, with a slot
// in the top of its front wall. The bolt hangs by its handle: the handle
// root rests in the round bottom of the slot, which indexes it, and the
// bolt body hangs down through the tube. Any bolt length fits, only the
// bore must clear the lugs.
//
// The slot faces away from the wall by default, so a handle never
// reaches into the neighbouring holder; slot_angle turns it.
//
// Every slot has its own bore, wall offset and gap to the next one.
// Per-slot knobs take one entry per slot, or a single number for all (a
// short list repeats its last entry).
//
// A bolt weighs about 0.4 to 0.5 kg and hangs off the front of the tube,
// so each holder gets two magnets by default, one above the other: the
// lower one keeps the bolt's weight from levering the top of the plate
// off the wall. Two 10x5 magnets give about 1.1 kg shear on bare steel,
// about 2.2x for a 0.5 kg bolt. The magnet knobs count per holder, in
// one piece or modular.
//
// Prints as modeled: back plate vertical, tubes standing on the bed. The
// slot is open at the top, so nothing bridges.

include <../design_params.scad>
use <../lib/magnets.scad>
use <../lib/holders.scad>

/* [Slots] */
// Bolt diameter per slot, measured over the locking lugs. One entry per slot.
bolt_d = [24, 24];
// Extra distance from the safe wall per slot, 0 = tight to the wall
wall_offset = [0, 0];
// Space between neighbouring tubes, one entry per pair
gaps = [8];

/* [Tube] */
// Tube height, also the back plate height
tube_h = 100;
// Tube wall
tube_wall = 2.4;
// Entry chamfer at the top of the bore
chamfer = 1;

/* [Handle slot] */
// Slot width: the bolt handle root plus some room
slot_w = 14;
// Slot depth from the top of the tube to the bottom of its round end
slot_depth = 25;
// Slot direction in degrees around the tube: 0 faces away from the wall,
// 90 to the right and -90 to the left, seen from the front
slot_angle = 0;

/* [Modular] */
// Print one module per holder, joined side by side with sliding dovetails
modular = true;
// Modular only: 0 lays out every module for printing, 1..n just that one
print_slot = 0;

/* [Friction pad] */
// Show this part's friction pad instead (print in TPU, or use as the
// template to cut silicone sheet; pad_t in design_params.scad)
pad = false;

/* [Magnets] */
// Magnet columns per holder (in one piece the row gets this times the slot count)
magnets_x = 1;
// Magnet rows per holder: 2 resists the bolt levering the plate off the wall, 1 for light bolts
magnets_z = 2;

// Bore per slot: the measured bolt plus item_clearance.
function bolt_bores(bolt_d = bolt_d) = [for (d = as_list(bolt_d)) d + item_clearance];

// Slot layout [xs, axes, bounds] for these knobs: the holder uses it, and
// so does the assembly to hang bolts in it.
function bolt_layout(bolt_d = bolt_d, wall_offset = wall_offset, gaps = gaps,
                     tube_wall = tube_wall, chamfer = chamfer) =
    let (ds = bolt_bores(bolt_d),
         xs = holder_xs(ds, tube_wall, gaps))
    [xs, holder_axes(ds, chamfer, wall_offset), holder_bounds(xs, ds, tube_wall)];

// [tube_h, slot_w, slot_depth, slot_angle], for the assembly scene.
function bolt_slot() = [tube_h, slot_w, slot_depth, slot_angle];

// Cutter for the handle slot of a tube of bore d and wall w, origin on
// the tube axis at the bed: a U notch slot_w wide from the top down to
// slot_depth, its round end at the bottom, through the wall at angle a.
module handle_slot(d, w, h, slot_w, slot_depth, a) {
    r = slot_w / 2;
    rotate([0, 0, a]) rotate([90, 0, 0])
        linear_extrude(d / 2 + w + 1) {
            translate([0, h - slot_depth + r]) circle(r = r);
            translate([-r, h - slot_depth + r]) square([slot_w, slot_depth]);
        }
}

module bolt_holder(bolt_d = bolt_d, wall_offset = wall_offset, gaps = gaps,
                   tube_h = tube_h, tube_wall = tube_wall, chamfer = chamfer,
                   slot_w = slot_w, slot_depth = slot_depth, slot_angle = slot_angle,
                   magnets_x = magnets_x, magnets_z = magnets_z,
                   modular = modular, print_slot = print_slot,
                   spacing = 12, pad = pad) {
    ds = bolt_bores(bolt_d);
    n = len(ds);
    layout = bolt_layout(bolt_d, wall_offset, gaps, tube_wall, chamfer);
    xs = layout[0];
    axes = layout[1];
    for (d = ds) assert(slot_w < d, "slot_w must be narrower than the bore");
    assert(slot_depth > slot_w / 2 && slot_depth < tube_h,
           "slot_depth must reach past the slot's round end and stay inside the tube");
    // toward the wall the slot would cut the web and the back plate
    assert(abs(slot_angle) <= 90, "slot_angle must be within -90..90");
    let ($pad = pad)
        wall_row(layout[2], tube_h, modular ? magnets_x : magnets_x * n, magnets_z,
                 modular = modular, print_slot = print_slot, spacing = spacing)
            difference() {
                holder_row(pick(ds, $slots), tube_h, pick(xs, $slots), pick(axes, $slots),
                           w = tube_wall, bottom = "open", chamfer = chamfer);
                for (i = $slots) translate([xs[i], -axes[i], 0])
                    handle_slot(ds[i], tube_wall, tube_h, slot_w, slot_depth, slot_angle);
            }
}

bolt_holder();
