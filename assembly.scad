include <slate.scad>;
$part = "none";
// This imports the rendered STLs and assembles them because they're so complex they break the preview
// and take ages to render

import("prints/3x5_base.stl");
up(BASE_THICKNESS) import("prints/3x5_cover.stl");
