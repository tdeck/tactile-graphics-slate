include <BOSL/constants.scad>
use <BOSL/transforms.scad>
use <BOSL/shapes.scad>

/* TODO 3x5
ROWS = 28;
COLUMNS = 48;
*/

USE_CARD_CUTOUT = true;
CARD_CUTOUT_WIDTH = 28;
CARD_CUTOUT_LENGTH = 25;
CARD_CUTOUT_THICKNESS = .6; // TODO

ROWS = 8;
COLUMNS = 8;

DOT_SPACING = 2.54; // This is the CA sign standard where the cell spacing is actually 
DEPRESSION_DIAMETER = 1.9; // TODO need to tune this
DEPRESSION_DEPTH = .9;
STYLUS_GUIDE_CLEARANCE = .1;

BASE_THICKNESS = 1.5;
TOP_THICKNESS = 2;
SIDE_SPACE = 5;
CHAMFER_HEIGHT = .4; // This makes it easier to remove the print from the bed

ALIGNMENT_SPIKE_TOP_DIAM = .5;
ALIGNMENT_SPIKE_BOTTOM_DIAM = 1.5;
ALIGNMENT_SPIKE_HEIGHT = 3;
ALIGNMENT_HOLE_CLEARANCE = .2;

USE_CELL_GUIDES = true;

RIDGE_SPACING = 8;
LINE_RIDGE_HEIGHT = .8; // These are every 8 dots (2 Braille lines)
COL_RIDGE_HEIGHT = 0; // These are every 8 columns, to match the above
MAX_RIDGE_WIDTH = 1; // These ridges will mostly be pierced by holes
INTERSECTION_BUMP_HEIGHT = .8;
INTERSECTION_BUMP_DIAM = DEPRESSION_DIAMETER + 2 * .8;

/* TODO 3x5 card
CARD_CUTOUT_WIDTH = 5 * 25.4 + 1;
CARD_CUTOUT_LENGTH = 3 * 25.4 + 1;
*/


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
        
        
        platen_negative_offset = 0;
        if (USE_CARD_CUTOUT) {
            platen_negative_offset = CARD_CUTOUT_THICKNESS;
        }

        right(DEPRESSION_DIAMETER + SIDE_SPACE)
        forward(DEPRESSION_DIAMETER + SIDE_SPACE)
        down(platen_negative_offset)
        for (r = [0:ROWS-1]) {
            for (c = [0:COLUMNS-1]) {
                right(c * DOT_SPACING)
                    forward(r * DOT_SPACING)
                        depression();
            }
       }
       
        // Card cutout (may be zero)
        up(SMALL_DELTA)
            forward(plate_length / 2)
            cuboid(
                [CARD_CUTOUT_WIDTH, CARD_CUTOUT_LENGTH, CARD_CUTOUT_THICKNESS],
                align=V_DOWN + V_RIGHT
            );
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
        union() {
            cuboid(
                [plate_width, plate_length, TOP_THICKNESS],
                align=V_DOWN + V_RIGHT + V_FWD,
                chamfer=CHAMFER_HEIGHT
            );
            
            // Ridges
            color("green")
            right(SIDE_SPACE)  forward(SIDE_SPACE) {
                // Horizontal ridges
                for (r = [RIDGE_SPACING: RIDGE_SPACING: ROWS - 1]) {
                    forward(DEPRESSION_DIAMETER + r * DOT_SPACING - DOT_SPACING/2)
                        cuboid(
                            [plate_width - 2*SIDE_SPACE, MAX_RIDGE_WIDTH, LINE_RIDGE_HEIGHT],
                            align=V_UP + V_RIGHT
                        );
                }
                
                // Vertical ridges
                for (c = [RIDGE_SPACING: RIDGE_SPACING: COLUMNS - 1]) { // TODO these should start at right
                    right(DEPRESSION_DIAMETER + c * DOT_SPACING - DOT_SPACING/2)
                        cuboid([MAX_RIDGE_WIDTH, plate_length - 2*SIDE_SPACE, COL_RIDGE_HEIGHT],
                            align=V_UP + V_FWD
                        );
                }
                
                // Intersection bumps
                color("blue")
                for (r = [3: 4: ROWS - 1]) {
                    for (c = [COLUMNS - 3: -3: 0]) {
                        forward(DEPRESSION_DIAMETER + r * DOT_SPACING )
                            right(DEPRESSION_DIAMETER + c * DOT_SPACING)
                            zcyl(d=INTERSECTION_BUMP_DIAM, h=INTERSECTION_BUMP_HEIGHT);
                    }
                }
            }
        }

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
               for (r = [0: 4: ROWS - 3]) {
                   for (c = [COLUMNS -2: -3: 0]) { // TODO
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
