/*******************************************************************************
 * This is a vertical paint stand which can be stacked.
 *
 * Stacking allows us to print on smaller beds and reduces damage in the event
 * of a print failure.
 *
 * Currently it holds paint bottles from Reaper and Vallejo. The design will
 * hopefully make adding support for other paint bottles a relatively easy task.
 *
 * The design uses a stackable structure. The structure can be stacked both
 * vertically and horizontally, to allow widths and heights that smaller print
 * beds may not be able to accommodate. Any joined parts can be removed via a
 * release. The structure is held by flexible clips.
 ******************************************************************************/

module flexClip() {
  /* cube([10, 5, 3], center = true); */
  /* rotate(a=45, v=[0, 1, 0]) */
  /*   translate([10, 0, 3]) */
  /*   cube([10, 5, 3], center = true); */
  polygon(
    points=[
      [0,0],
      [8,0],
      [8,1],
      [7,2],
      [6,2],
      [6,3],
      [8,3],
      [10,0],
      [10,-1],
      [0,-1],
    ]
  );
}

include <bottle.scad>
include <connecting-cradle.scad>
/* include <hex.scad> */

/* include <diagonal-frame-joint.scad> */
/* include <peg-press-fit-joint.scad> */
/* include <fastener-joint.scad> */
/* include <annular-joint.scad> */

preview=true;
showFoot=false;
if(showFoot) {
  foot(60);
} else {
  rotation = preview ? 135 : 180;
  rotate([rotation, 0, 0]) {
    difference() {
      cradle();
      translate([0, 0, -bottleCapHeight * 0.33])
        bottleVallejo();
    }
  }
}
