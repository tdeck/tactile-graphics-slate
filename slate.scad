include <BOSL/constants.scad>
use <BOSL/transforms.scad>
use <BOSL/shapes.scad>

ROWS = 8;
COLUMNS = 11;

DOT_SPACING = 2.54; // This is the CA sign standard where the cell spacing is actually 
DEPRESSION_DIAMETER = 1.9; // TODO need to tune this
DEPRESSION_DEPTH = .9;
STYLUS_GUIDE_CLEARANCE = .1;

BASE_THICKNESS = 1.5;
TOP_THICKNESS = 1;
SIDE_SPACE = 5;
CHAMFER_HEIGHT = .4; // This makes it easier to remove the print from the bed

ALIGNMENT_SPIKE_TOP_DIAM = .5;
ALIGNMENT_SPIKE_BOTTOM_DIAM = 1.5;
ALIGNMENT_SPIKE_HEIGHT = 3;
ALIGNMENT_HOLE_CLEARANCE = .3;

USE_CELL_GUIDES = true;

// Utility constants
ARBITRARY = 1000; // Arbitrary size for various hole dimensions
SMALL_DELTA = .01; // Small movement to resolve ambiguity when part edges overlap

 // Set global params for smoother shapes
$fa = 1;
$fs = .2;

plate_length = ROWS * DOT_SPACING + DEPRESSION_DIAMETER + 2 * SIDE_SPACE;
plate_width = COLUMNS * DOT_SPACING + DEPRESSION_DIAMETER + 2 * SIDE_SPACE;

module depression() {
    zscale(2*DEPRESSION_DEPTH/DEPRESSION_DIAMETER)
        sphere(d=DEPRESSION_DIAMETER);
}

module alignment_spike() {
    zcyl(d2=ALIGNMENT_SPIKE_TOP_DIAM, d1=ALIGNMENT_SPIKE_BOTTOM_DIAM, h=ALIGNMENT_SPIKE_HEIGHT);
}

module bottom_plate() {
    difference() {
        cuboid(
            [plate_width, plate_length, BASE_THICKNESS],
            align=V_DOWN + V_RIGHT + V_FWD,
            chamfer=CHAMFER_HEIGHT
        );

        right(DEPRESSION_DIAMETER + SIDE_SPACE)
        forward(DEPRESSION_DIAMETER + SIDE_SPACE)
        for (r = [0:ROWS-1]) {
            for (c = [0:COLUMNS-1]) {
                right(c * DOT_SPACING)
                    forward(r * DOT_SPACING)
                        depression();
            }
       }
    }

    // Back alignment spikes
    spike_offset = SIDE_SPACE / 2;
    forward(spike_offset) {
        right(spike_offset) alignment_spike();
        right(plate_width - spike_offset) alignment_spike();
    }

    forward(plate_length - spike_offset) {
        right(spike_offset) alignment_spike();
        right(plate_width - spike_offset) alignment_spike();
    }
}

module alignment_hole_carveout() {
    zcyl(h=ARBITRARY, d=ALIGNMENT_SPIKE_BOTTOM_DIAM + 2*ALIGNMENT_HOLE_CLEARANCE);
}

module top_plate() {
    difference() {
        cuboid(
            [plate_width, plate_length, TOP_THICKNESS],
            align=V_DOWN + V_RIGHT + V_FWD,
            chamfer=CHAMFER_HEIGHT
        );

        hole_diameter = DEPRESSION_DIAMETER + 2*STYLUS_GUIDE_CLEARANCE;
        right(DEPRESSION_DIAMETER + SIDE_SPACE) forward(DEPRESSION_DIAMETER + SIDE_SPACE) {
            for (r = [0:ROWS-1]) {
                for (c = [0:COLUMNS-1]) {
                    right(c * DOT_SPACING)
                        forward(r * DOT_SPACING)
                           zcyl(h=ARBITRARY, d=hole_diameter);
                }
           }
           
           // Center cutouts to indicate Braille cells
           if (USE_CELL_GUIDES) {
               for (r = [0: 4: ROWS - 1]) {
                   for (c = [0: 3: COLUMNS - 1]) {
                        right(c * DOT_SPACING)
                            forward(r * DOT_SPACING - hole_diameter/2)
                                cuboid([DOT_SPACING, 2*DOT_SPACING + hole_diameter, ARBITRARY], align=V_RIGHT + V_FWD);
                   }
               }
           }
       }
       

       
        // Alignment holes
        spike_offset = SIDE_SPACE / 2;
        forward(spike_offset) {
            right(spike_offset) alignment_hole_carveout();
            right(plate_width - spike_offset) alignment_hole_carveout();
        }

        forward(plate_length - spike_offset) {
            right(spike_offset) alignment_hole_carveout();
            right(plate_width - spike_offset) alignment_hole_carveout();
        }
    }
}

bottom_plate();

down(BASE_THICKNESS - TOP_THICKNESS) // Cura won't lay 2 parts in same STL on bed
    forward(plate_length + 5) top_plate();
