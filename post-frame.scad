
module postFrame() {
  let(
    postHeight = 80,
    postSplitGap = 3,
    postSplitHeight = 7,
    outerRadius = (0.75 * bottleBodyDiameterVallejo / 2),
    innerRadius = (0.75 * bottleBodyDiameterVallejo / 2) - 0.5
  ) {
    difference() {
      translate([0, -2, 0]) {
        upperPostFrame(
          postHeight - 10,
          outerRadius - 1,
          innerRadius - 1,
          postSplitGap
        );
        lowerPostFrame(
          postHeight - 20,
          outerRadius,
          innerRadius,
          postSplitGap,
          postSplitHeight
        );
      }
      translate([0, 0, 5])
        rotate(a=125, v=[1,0,0])
        cylinder(r=cradleRadius - frameWidth / 2, h=50, center=true);
    }
  }
}

module post(postHeight, outerRadius, innerRadius) {
  difference() {
    cylinder(
      r=outerRadius,
      h=postHeight / 2,
      center = true
    );
    cylinder(
      r=innerRadius,
      h=postHeight / 2 + zPeace * 2,
      center = true
    );
  }
}

module upperPostFrame(
  postHeight,
  outerRadius,
  innerRadius,
  postSplitGap
) {
  translate([0, 0, postHeight / 4]) {
    post(postHeight, outerRadius, innerRadius);
  }
  translate([0, 0, (postHeight / 2 - 2) ])
    outerCaptureRing(innerRadius, 1);
}

module lowerPostFrame(
  postHeight,
  outerRadius,
  innerRadius,
  postSplitGap,
  postSplitHeight
) {
  difference() {
    translate([0, 0, -postHeight / 4]) {
      post(postHeight, outerRadius, innerRadius);
    }
    postFrameSplit(postHeight, postSplitHeight, postSplitGap);
  }
  difference() {
    translate([0, 0, -(postHeight / 2 - 2) ])
      innerCaptureRing(innerRadius, 1);
    postFrameSplit(postHeight, postSplitHeight, postSplitGap);
  }
}

module postFrameSplit(postHeight, postSplitHeight, postSplitGap) {
  let (
    splitDiameter = zPeace * 2 + bottleBodyDiameterVallejo * 0.75
  ) {
    $fn=100;
    translate([
      0,
      0,
      -((postHeight / 2) - (postSplitHeight / 2))
    ])
      cube(
        [
          postSplitGap,
          splitDiameter,
          postSplitHeight + zPeace * 2
        ],
        center = true
      );
    translate([0, 0, -postHeight / 2 + postSplitHeight])
      rotate(a=90, v=[0,0,1])
      rotate(a=90, v=[0,1,0])
      cylinder(d=postSplitGap, h=splitDiameter, center=true);
  }
}

module innerCaptureRing(radius, thickness) {
  intersection() {
    minkowski() {
      difference() {
        cylinder(r=radius + thickness / 2, h=thickness, center =true);
        cylinder(r=radius, h=thickness + zPeace, center=true);
      }
      sphere(thickness / 2);
    }
    // This clips the outside.
    cylinder(r=radius, h=thickness * 2, center =true);
  }
}

module outerCaptureRing(radius, thickness) {
  difference() {
    minkowski() {
      difference() {
        cylinder(r=radius + thickness / 2, h=thickness, center =true);
        cylinder(r=radius, h=thickness + zPeace, center=true);
      }
      sphere(thickness / 2);
    }
    // This clips the outside.
    cylinder(r=radius, h=thickness * 2, center =true);
  }
}

module postFrameCradle() {
  difference() {
    rotate(a=cradleAngle + 90, v=[1,0,0]) {
      difference() {
        color("red")
          cylinder(r=cradleRadius - frameWidth / 2, h=50, center=true);
        translate([0, 0, 10])
          bottleVallejo();
      }
    }
    // We don't need the entire cylinder to hold the paint bottle. These
    // subtractions reduce the material required.
    rotate(a=90, v=[0,1,0])
      cylinder(r=cradleRadius / 2, h=50, center=true);
  }
}

postFrame();
translate([0, 0, 5])
  postFrameCradle();
