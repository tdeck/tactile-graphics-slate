# Tactile pixel art slate

This design is an experiment in tactile graphics. Much like a braille slate allows you to emboss properly spaced braille, this slate allows you to emboss pixel art on a 3x5 index card. It includes standard 6 dot openings for Braille, and dot positions in between the braille cells that allow you to make continuous lines and other shapes. Raised ridges separate every 2 lines, and a raised circle surrounds the inter-line dot position below and to the left of each cell.

## Printing

Files are in the prints folder.

Both parts should be printed in their provided orientation. The base should be printed with fine layer heights (e.g. .1mm) so that the hemisphere depressions for each dot will have the right shape. The cover is less sensitive to layer height.

This is a large flat print so warping is a significant concern. You'll need good bed adhesion to print this properly.

PLA works just fine for this print.

## Assembly

The slate is designed to be printed in two parts, then permanently joined. There are 4 pegs at each corner of the cover, and 4 corresponding holes in the cover. Once the cover has been placed on these pegs, you should be able to slide in a 3x5 card into the slot on the side. You can permanently join the top and bottom halves with glue around the edges, or by heating up and pressing down the 4 protruding pegs so they form a kind of plastic rivet.

## Code
The code is all in slate.scad and can be adapted for different sizes of slates. I haven't modeled a hinge, but by making the alignment pegs smaller and increasing the clearance the pegs can be made to punch through paper and hold a slate in place. If you want to use the slate this way, disable the card cutout option.

Code contributions and print photos!
