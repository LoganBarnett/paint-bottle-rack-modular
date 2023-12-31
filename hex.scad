cradleThickness=1;
// Unusual vocabulary: The apothem is the radius of a regular polygon from the
// center to the middle of the flat edge, and the nearest point from center.
// This comes up quite a bit when dealing with a hexagonal cradle.
apothemFactor=pow(3, 1/2) / 2;
cradleApothem=(bottleBodyDiameterVallejo / 2);
// This gives us a very direct relationship with the cradleThickness, so we can
// be sure the thinnest point is described by the thickness. A thickness of 0
// would mean that the midpoint of each side would have a thickness of 0 (which
// would not be printable).
cradleRadius=cradleApothem / apothemFactor + cradleThickness;
cradleLength=50;
cradleAngle=45;
cradleHandOffset=cos(90 + cradleAngle) * cradleApothem * 2;
cradleFloorOffset=
  -cos(90 + cradleAngle) * cradleRadius + cradleRadius
  // Keep the corners of the arms from dipping below the positive Z axis.
  /* + cos(cradleAngle) * cradleThickness */
  /* - cos(90 + cradleAngle) * cradleLength */
  ;
include <hex.scad>


module hexCradle(reducedMaterial) {
  difference() {
    let($fn=6) {
      color("red")
        cylinder(r=cradleRadius, h=cradleLength, center=true);
    }
    translate([0, 0, -4])
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
  rotate(a=90 + cradleAngle, v=[1,0,0])
    hexCradle(reducedMaterial);
}

module hexHands(thickness) {
  // We want to know the point at which two stacked cradles will line up,
  // assuming the stacking involves no movement along the y axis. From here, we
  // can make small hands with which to grasp the lower cradle. This should line
  // up perfectly with the top of the bottom cradle.
  let (
    // In a perfect hexagon, the side length and the radius are the same. The
    // radius is also the height, which we use as a z offset here. I don't quite
    // understand why it needs to be divided by two.
    zOffset = -cradleRadius / 2,
    yOffset = -cos(90 + cradleAngle) * cradleLength / 2
  ) {
    // This translation places us along the edge of the cradle.
    /* translate([0, yOffset, zOffset]) { */
    translate([
      0,
      /* -(cradleApothem + cradleThickness) - thickness / 2, */
      -thickness / 2 - cradleApothem - cradleThickness / 2,
      -thickness / 2,
    ]) {
      // A handy marker for debugging. Keep around.
      /* sphere(3); */
      // We have virtually no depth and cut off the hexagonal shape halfway
      // through its edge.
      /* rotate(a=90 + cradleAngle, v=[1,0,0]) { */
          translate([
            0,
            /* -thickness * 1.5, */
            0,
            0,
            /* -(cradleLength / 2 - thickness / 2), */
          ]) {
            let(x = cradleRadius / 2 - thickness / 2) {
              translate([x, 0, 0])
                hexFinger(thickness);
              translate([-x, 0, 0])
                hexFinger(thickness);
            }
        /* } */
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

module hexFinger(thickness) {
  cube([thickness, thickness, thickness], center=true);
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

// This increases surface area on the bottom, which should make for a more
// reliable print. I have noticed that it can easily come off while printing
// when only a single line is connecting with the ground.
module hexTiltedCradleSupport() {
  let(
    supportHeight = -cos( cradleAngle) * (bottleCapWideDiameter / 2 - cradleApothem),
    supportLength = -sin(cradleAngle) * (bottleCapWideDiameter / 2 - cradleApothem)
  ) {
    translate([
      0,
      -cos(90 - cradleAngle) * cradleFloorOffset + supportLength + zPeace,
      0,
    ])
      rotate(a=90, v=[1, 0, 0])
      rotate(a=90, v=[0, 1, 0])
      linear_extrude(center=true, height=cradleRadius)
      // Ugh, this is a mess. Clean it up someday.
      polygon([
        [-(supportLength + zPeace), (supportHeight + zPeace)],
        [-(supportLength + zPeace) * 2, 0],
        [0, 0],
      ]);
  }
}

module hexCradleFull() {
  // I had a hard time getting the trig functions to do what I expected, maybe
  // because I should have used apothem+thickness, which I think is the only
  // permutation I didn't try. For now, just do a couple of rotations.
  // Doing these rotations makes the hexFingers significantly easier.
  rotate(a=-90 + cradleAngle, v=[1,0,0])
    translate([
      0,
      -(cradleApothem + cradleThickness),
      cradleLength / 2,
    ])
    rotate(a=180, v=[1, 0, 0]) {
    // Disabled for now. See implementation in hexCradle for details.
    hexCradle(false);
    hexHands(1.5);
  }
  /* translate([0, 0, -cradleFloorOffset]) */
  /*   hexTiltedCradleSupport(); */
}

module hexCradleFoot() {
  difference() {
    rotate(a=90 + cradleAngle, v=[1,0,0])
      translate([0, -(cradleApothem + cradleThickness), 0])
      // There may be merit in optimizing this geometry as well, but for now
      // leave it disabled - it doesn't work yet in the case of the normal
      // cradle.
      hexCradle(false);
    translate([0, 0, -cradleLength])
      cube([cradleLength * 2, cradleLength * 2, cradleLength * 2], center = true);
  }
}

// Override these as needed, especially from the command line to generate
// separate models.
showFoot=true;
showCradle=true;
layFlat=false;
if(showCradle) {
  if(layFlat) {
    rotate(a=90 - cradleAngle, v=[1, 0, 0])
      hexCradleFull();
  }
  else {
    /* translate([0, 0, cradleFloorOffset]) */
      hexCradleFull();
  }
}
if(showFoot) {
  color("yellow")
    hexCradleFoot();
}


preview = false;
// End z-fighting by nudging an object over with this value.
zPeace = 0.01;
