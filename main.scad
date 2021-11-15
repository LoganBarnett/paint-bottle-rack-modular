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


/* translate([50, 0, 0]) */
/*   flexClip(); */


frameHorizontalGap=20;
frameWidth=10;
module strut() {
  cube([frameWidth, 10, 50], center = true);
}

module frame() {
  translate([-frameHorizontalGap, -frameHorizontalGap, 0])
    strut();
  translate([frameHorizontalGap, -frameHorizontalGap, 0])
    strut();
  translate([-frameHorizontalGap, frameHorizontalGap, 0])
    strut();
  translate([frameHorizontalGap, frameHorizontalGap, 0])
    strut();
}

include <bottle.scad>

module cradle() {
  rotate(a=125, v=[1,0,0]) {
      difference() {
      color("red")
        cylinder(d=(frameHorizontalGap * 2) - frameWidth, h=50, center=true);
      translate([0, 0, -10])
        bottleVallejo();
    }
  }
}

frame();
cradle();

preview = true;
include <diagonal-frame-joint.scad>
include <peg-press-fit-joint.scad>
