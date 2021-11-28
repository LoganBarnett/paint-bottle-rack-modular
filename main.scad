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

frameHorizontalGap=17.5;
cradleThickness=1;
// Unusual vocabulary: The apothem is the radius of a regular polygon from the
// center to the middle of the flat edge, and the nearest point from center.
// This comes up quite a bit when dealing with a hexagonal cradle.
apothemFactor=pow(3, 1/2) / 2;
// This gives us a very direct relationship with the cradleThickness, so we can
// be sure the thinnest point is described by the thickness. A thickness of 0
// would mean that the midpoint of each side would have a thickness of 0 (which
// would not be printable).
cradleRadius=cradleThickness + (bottleBodyDiameterVallejo / 2) / apothemFactor;
cradleApothem=cradleRadius * apothemFactor;
cradleLength=50;
cradleAngle=35;
cradleHandOffset=cos(90 + cradleAngle) * cradleApothem * 2;
cradleFloorOffset=
  -cos(90 + cradleAngle) * cradleRadius + cradleRadius
  // Keep the corners of the arms from dipping below the positive Z axis.
  /* + cos(cradleAngle) * cradleThickness */
  /* - cos(90 + cradleAngle) * cradleLength */
  ;
frameWidth=10;
frameDepth=10;
jointHeight=10;
strutHeight=50;
module strut() {
  translate([0, 0, jointHeight / 2])
    cube([frameWidth, frameDepth, strutHeight - jointHeight], center = true);
}

module fourLegsFrame() {
  let(jointSize = [frameWidth, frameDepth, jointHeight]) {
    translate([frameHorizontalGap, -frameHorizontalGap, 0])
      strutStarboardWithAnnular(jointSize, 10);
    translate([-frameHorizontalGap, -frameHorizontalGap, 0])
      strutPortWithAnnular(jointSize, 10);
    translate([frameHorizontalGap, frameHorizontalGap, 0])
      strutStarboardWithAnnular(jointSize, 0);
    translate([-frameHorizontalGap, frameHorizontalGap, 0])
      strutPortWithAnnular(jointSize, 0);
  }
}

module hexCradle(reducedMaterial) {
  difference() {
    let($fn=6) {
      color("red")
        cylinder(r=cradleRadius, h=cradleLength, center=true);
    }
    translate([0, 0, 10])
      bottleVallejo();
    // THis still needs some work. I'd like it to play nice with the hands and
    // also work two dimensionally across the surface. I do need to verify
    // whether or not this requires additional supports, which might make this
    // counterproductive.
    if(reducedMaterial) {
      let(optimizationSize=5) {
        for(x=[0:optimizationSize * pow(2, 1/2) + cradleThickness:cradleLength]) {
          for(a=[0:60:360-60]) {
            translate([0, 0, x - cradleLength / 2]) {
              rotate(a=a, v=[0, 0, a])
                rotate(a=45, v=[0, 1, 0])
                cube(
                  [optimizationSize, cradleRadius * 2 + zPeace, optimizationSize],
                  center = true
                );
            }
          }
        }
      }
    }
  }
}


module hexTiltedCradle(reducedMaterial) {
  difference() {
    rotate(a=90 + cradleAngle, v=[1,0,0]) {
      hexCradle(reducedMaterial);
    }
  }
}

module hexHands(thickness) {
  // We want to know the point at which two stacked cradles will line up,
  // assuming the staccking involves no movement along the y axis. From here, we
  // can make small hands with which to grasp the lower cradle. This should line
  // up perfectly with the top of the bottom cradle.
  let (
    // In a perfect hexagon, the side length and the radius are the same. The
    // radius is also the height, which we use as a z offset here. I don't quite
    // understand why it needs to be divided by two.
    zOffset = -cradleApothem / 2,
    yOffset = -cos(90 + cradleAngle) * cradleLength / 2
  ) {
    // This translation places us along the edge of the cradle.
    translate([0, yOffset, zOffset]) {
      // A handy marker for debugging. Keep around.
      /* sphere(3); */
      // We have virtually no depth and cut off the hexagonal shape halfway
      // through its edge.
      rotate(a=90 + cradleAngle, v=[1,0,0]) {
        translate([0, 0, cradleLength / 2 + cradleThickness / 2]) {
          let(xOffset = cos(30) * cradleApothem * 2) {
            translate([xOffset, 0, 0])
              rotate(a=60, v=[0, 0, 1])
              halfHexHand(1);
            translate([0, -cradleApothem, 0])
              hexHand();
            translate([-xOffset, 0, 0])
              rotate(a=-60, v=[0, 0, 1])
              halfHexHand(-1);
          }
        }
        translate([0, 0, cradleThickness / 2]) {
          hexHandButtress(1);
          hexHandButtress(-1);
        }
      }
    }
  }
}

// We don't want a whole hand on the sides or they will overlap with
// horizontally adjacent cradles.
module halfHexHand(side) {
  difference() {
    hexCradle(false);
    translate([0, 0, cradleThickness])
      cube(
        [cradleRadius * 2, cradleRadius * 2, cradleLength],
        center=true
      );
    translate([
      0,
      -cradleApothem / 2,
      cradleLength / -2
    ]) {
      translate([0,0, cradleThickness / 2])
      cube(
        [
          cradleRadius * 2,
          zPeace + cradleApothem,
          cradleThickness + zPeace * 2
        ],
        center = true
      );
      translate([side * cradleRadius / 2, cradleApothem, cradleThickness / 2])
        cube(
          [
            cradleRadius,
            zPeace + cradleApothem,
            cradleThickness + zPeace * 2
          ],
          center = true
        );
    }
  }
}

module hexHand() {
  difference() {
    hexCradle(false);
    translate([0, 0, cradleThickness])
      cube(
        [cradleRadius * 2, cradleRadius * 2, cradleLength],
        center=true
      );
    translate([
      0,
      -cradleApothem / 2,
      cradleLength / -2 + cradleThickness / 2
    ])
      cube(
        [
          cradleRadius * 2,
          zPeace + cradleApothem,
          cradleThickness + zPeace * 2
        ],
        center = true
      );
  }
}

// Create a support to help hold the hands together.
module hexHandButtress(side) {
  translate([cradleRadius / 2 * side, 0, 0])
    rotate(a=side == 1 ? -60 : 240, v=[0, 0, 1])
  rotate(a=90, v=[1, 0, 0])
    // TODO: Extrude this by cradleThickness so we can avoid warnings. I think
    // right now it assumes 1.
    linear_extrude(height=cradleThickness, center = true)
    polygon([
      [0,0],
      [0, -cradleRadius],
      [cradleRadius - cradleThickness, 0],
    ]);
}

module hexCradleFull() {
  // Disabled for now. See implementation in hexCradle for details.
  hexTiltedCradle(false);
  hexHands(1);
}

module hexCradleFoot() {
  difference() {
    translate([
      0,
      // Whoa. Tune carefully here. The foot is rises to mate perfectly with a
      // cradle whose back end rests at z=0. The hands also mate against the
      // face of the foot.
      +cos(cradleAngle) * cradleThickness,
      -cos(90 + cradleAngle) * cradleApothem - cradleRadius,
    ])
      // There may be merit in optimizing this geometry as well, but for now
      // leave it disabled - it doesn't work yet in the case of the normal
      // cradle.
      hexTiltedCradle(false);
    translate([0, 0, -cradleLength])
      cube([cradleLength * 2, cradleLength * 2, cradleLength * 2], center = true);
  }
}

// Override these as needed, especially from the command line to generate
// separate models.
showFoot=true;
showCradle=true;
if(showCradle) {
  translate([0, 0, cradleFloorOffset])
    hexCradleFull();
}
if(showFoot) {
  hexCradleFoot();
}


preview = false;
// End z-fighting by nudging an object over with this value.
zPeace = 0.01;

include <diagonal-frame-joint.scad>
include <peg-press-fit-joint.scad>
include <fastener-joint.scad>
include <annular-joint.scad>
