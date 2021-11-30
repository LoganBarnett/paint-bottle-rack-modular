include <openscad-iso-metric-fasteners/nuts.scad>
include <openscad-iso-metric-fasteners/screws.scad>

/**
 * I have had trouble with getting fasteners to work. I just can't seem to get
 * joints to occur cleanly, and with screws that can actually be reached (not
 * enough clearance between legs).
 *
 * Avoiding fasteners would be great, because it reduces the components
 * required.
 */

module femaleHorizontalLegJoint(size) {
  translate([size / 2 + zPeace - nuts[m3][nutThicknessIndex] / 2, 0, 0])
    rotate(a=90, v=[0, 0, 1])
    hexNutCapturePocket(m3);
  translate([size / 2 + zPeace, 0, 0])
    rotate(a=90, v=[0, 0, 1])
    screwShaft(m3, size + zPeace * 2);
}

module maleHorizontalLegJoint(size) {
  translate([(size / 2 + zPeace) * -1, 0, 0])
    rotate(a=90, v=[0, 0, 1])
    countersink(m3, size);
}

// Expected to be used with difference() to subtrace this out from the middle of
// the bottom leg ends.
module femaleVerticalLegJoint(size, percentage, tolerance) {
  scale([1.0 - tolerance, 1.0 + tolerance, 1.0 + tolerance])
    cube([size.x * percentage, size.y, size.z], center=true);
}

module maleVerticalLegJoint(size, percentage, tolerance) {
  difference() {
    translate([0, 0, -size.z * tolerance])
      scale([1.0 - tolerance, 1.0, 1.0 - tolerance])
      cube([size.x * percentage, size.y, size.z], center=true);
    translate([(size.x * percentage + zPeace * 2) / 2, 0, 0])
      rotate(a=90, v=[0,0,1])
      screwShaft(m3, size.x * percentage + zPeace * 2);
  }
}

module strutPortWithFastener(jointSize) {
  translate([0, 0, strutHeight / 2 + jointHeight / 2])
    maleVerticalLegJoint(jointSize, 0.33, 0.1);
  strut();
  translate([0, 0, -strutHeight / 2 + jointHeight / 2]) {
    difference() {
      cube(jointSize, center = true);
      femaleHorizontalLegJoint(frameWidth);
      femaleVerticalLegJoint(jointSize, 0.33, 0.1);
    }
  }
}

module strutStarboardWithFastener(jointSize) {
  translate([0, 0, strutHeight / 2 + jointSize.z / 2])
    maleVerticalLegJoint(jointSize, 0.33, 0.1);
  strut();
  translate([0, 0, -strutHeight / 2 + jointSize.z / 2]) {
    difference() {
      cube(jointSize, center = true);
      maleHorizontalLegJoint(frameWidth);
      femaleVerticalLegJoint(jointSize, 0.33, 0.1);
    }
  }
}


if(preview) {
  let(size = [frameWidth, frameDepth, jointHeight]) {
    translate([40, 20, 0]) {
      difference() {
        cube(size, center = true);
        femaleHorizontalLegJoint(size.x);
      }
    }
    translate([40, 40, 0]) {
      difference() {
        cube(size, center = true);
        maleHorizontalLegJoint(size.x);
      }
    }
    translate([40, 60, 0]) {
      cube(size, center = true);
      translate([0,0,size.z])
        maleVerticalLegJoint(size, 0.33, 0.1);
    }
    translate([40, 80, 0]) {
      difference() {
        cube(size, center = true);
        femaleVerticalLegJoint(size, 0.33, 0.1);
      }
    }
  }
}

frameHorizontalGap=17.5;
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
