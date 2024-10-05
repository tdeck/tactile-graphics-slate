include <slate.scad>;
$part = "none";

PEG_HEIGHT = TOP_THICKNESS + LINE_RIDGE_HEIGHT;
PEG_CLEARANCE = .22; // To allow the peg to be inserted; radius clearance
PEG_DIAM = hole_diameter - 2 * PEG_CLEARANCE;
PEG_END_CHAMFER = .2; // To make the peg easier to insert
PEG_BASE_CHAMFER = .4; // To help keep the peg from snapping off
BASE_THICKNESS = 5;

module peg() {
    // Flat on the horizontal plane, pointing up
    cyl(
        d=PEG_DIAM,
        h=PEG_HEIGHT,
        align=V_UP,
        orient=ORIENT_Z,
        chamfer2=PEG_END_CHAMFER
    );
    
    // Base chamfer
    cyl(
        d1=PEG_DIAM + 2*PEG_BASE_CHAMFER,
        d2=PEG_DIAM,
        h=PEG_BASE_CHAMFER,
        align=V_UP,
        orient=ORIENT_Z
    );
}

module peg_pair() {
    // Flat on the horizontal plane, pointing up
    left(DOT_SPACING / 2) peg();
    right(DOT_SPACING / 2) peg();
}

module arrow_marker() {
    // 2 peg directional marker with an arrow end
    // This is printed upside down so there isn't support around the delicate pegs
    // Flat on the horizontal plane pointing up
    marker_width = DOT_SPACING;
    
    cuboid([5, marker_width, BASE_THICKNESS], align=V_DOWN);
    
    // here we have to use the pythagorean theorem!
    triangle_leg = sqrt(marker_width*marker_width / 2);
    
    left(2.5)
    zrot(-45)
        right_triangle(
            [triangle_leg, triangle_leg, BASE_THICKNESS],
            orient=ORIENT_Z,
            align=V_DOWN
    );
   
    peg_pair();
}

module corner_marker() {
    // 2 peg directional marker with an L-shape
    
    cuboid([3*DOT_SPACING, DOT_SPACING, BASE_THICKNESS], align=V_DOWN + V_BACK);
    
    left(3/2*DOT_SPACING)
    cuboid(
        [DOT_SPACING, DOT_SPACING, BASE_THICKNESS],
            align=V_DOWN + V_FWD + V_RIGHT);
    
    back(DOT_SPACING/2)
    right(DOT_SPACING/2) peg_pair();
}
    

module circle_marker() {
    // 1 peg non-directional marker
    diam = 5;
    
    zcyl(h=BASE_THICKNESS, d=diam, align=V_DOWN);
    peg();
}

module square_marker() {
    // 1 peg non-directional marker
    downcube([5, 5, BASE_THICKNESS]);
    peg();
}

module eight_peg_line_marker() {
    cuboid(
        [DOT_SPACING, 8*DOT_SPACING, BASE_THICKNESS],
        align=V_DOWN + V_FWD
    );
    for (i = [0:7]) {
        forward(DOT_SPACING * (i + .5)) peg();
    }
}

eight_peg_line_marker();
right(10) arrow_marker();
right(20) corner_marker();
right(30) circle_marker();
right(40) square_marker();
