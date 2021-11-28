/**
 * Annular joints are essentially a ball in socket, where the ball is captured
 * within the socket. The ball is able to push open the socket just a little
 * bit, but once it goes inside the socket closes around the ball. A shaft
 * attached to the ball can help the object with the male (ball) joint maintain
 * its orientation.
 *
 * The socket cuts off at "y/2", which I take to mean the ball radius.
 *
 * There is also a design where, instead of a ball, a wider portion of a shaft
 * with two conical ends is used. This probably maintains orientation better.
 * The "y/2" still applies to the widest radius used.
 *
 * In the case of the ball, a subtractive cone should be used that points inward
 * to the socket. This creates a sort of slope that will force the socket apart
 * rather than the ball crushing the walls inwards to the socket's gap.
 *
 * https://infocenter.3dsystems.com/bestpractices/mjp-best-practices/projet-mjp-2500/rapid-prototyping/snap-fits
 */

module maleAnnularJoint(wideRadius, neckRadius, height, neckBallRatio) {
  $fn=100;
  let(
    ballHeight = height * neckBallRatio,
    neckHeight = height - ballHeight,
    neckFunnelHeightPercentage = 0.25,
    wideHeightPercentage = 0.5,
    endHeightPercentage = 0.25
  ) {
      // The ballHeight and neckHeight offsets are, perhaps counterintuitively,
      // offseting the neck and ball respectively. Yes, you heard that right,
      // it's intentional.
      translate([0, 0, -ballHeight / 2])
        cylinder(r=neckRadius, h=neckHeight + zPeace * 2, center=true);
      translate([0, 0, neckHeight / 2]) {
        translate([
          0,
          0,
          ballHeight * -(wideHeightPercentage- neckFunnelHeightPercentage / 2)
        ])
          rotate([180, 0, 0])
          cylinder(
            r1=wideRadius,
            r2=neckRadius,
            h=ballHeight * neckFunnelHeightPercentage,
            center=true
          );
        cylinder(
          r=wideRadius,
          h=zPeace + ballHeight * wideHeightPercentage,
          center=true
        );
        translate([
          0,
          0,
          ballHeight * (wideHeightPercentage - endHeightPercentage / 2)
        ])
          cylinder(
            r1=wideRadius,
            r2=neckRadius,
            h=ballHeight * endHeightPercentage,
            center=true
          );
      }
  }
}

module femaleAnnularJointSubtractive(
  jointThickness,
  wideRadius,
  neckRadius,
  height,
  tolerance,
  neckBallRatio
) {
  $fn=100;
  cube(
    [
      // I get z fighting even with this. Just make it extra wide.
      (jointThickness + wideRadius + tolerance + zPeace) * 2,
      jointThickness + tolerance,
      height + tolerance
    ],
    center = true
  );
  translate([0, 0, -(zPeace * 2) - (1 - neckBallRatio) * height])
    maleAnnularJoint(wideRadius, neckRadius, height, neckBallRatio);
  // This subtraction smooths the entry of the male piece, so the male piece
  // doesn't just crush the entry.
  translate([0, 0, -height * 0.5])
    rotate([180, 0, 0])
    cylinder(r1=neckRadius, r2=wideRadius, h=height * 0.25, center=true);
}

module femaleAnnularJoint(
  jointThickness,
  wideRadius,
  neckRadius,
  height,
  tolerance,
  neckBallRatio
) {
  $fn=100;
  scale([1 + tolerance, 1 + tolerance, 1 + tolerance]) {
    difference() {
      cylinder(
        r=jointThickness + wideRadius + tolerance,
        h=height,
        center=true
      );
      femaleAnnularJointSubtractive(
        jointThickness,
        wideRadius,
        neckRadius,
        height,
        tolerance,
        neckBallRatio
      );
    }
  }
}

module femaleAnnularJointSubtractiveFreedom(
  jointThickness,
  wideRadius,
  tolerance,
  height
) {
  $fn=100;
  difference() {
    cylinder(
      r=(jointThickness * 2) + wideRadius + tolerance,
      h=height + zPeace * 2,
      center=true
    );
    cylinder(
      r=jointThickness + wideRadius + tolerance,
      h=height + zPeace * 2,
      center=true
    );
  }
}

module strutStarboardWithAnnular(jointSize, jointOffset) {
  let (
    wideRadius = 3,
    narrowRadius = 2
  ) {
    translate([0, 0, strutHeight / 2 + jointSize.z / 2])
      maleAnnularJoint(wideRadius, narrowRadius, jointSize.z, 1);
    strut();
    translate([jointSize.x, 0, jointOffset])
      rotate([0, 90, 0])
      maleAnnularJoint(wideRadius, narrowRadius, jointSize.z, 1);
    translate([0, 0, -strutHeight / 2 + jointSize.z / 2]) {
      femaleAnnularJoint(
        1.5,
        3,
        2,
        10,
        0.1,
        1
      );
    }
  }
}

module strutPortWithAnnular(jointSize, jointOffset) {
  let (
    wideRadius = 3,
    narrowRadius = 2
  ) {
    translate([0, 0, strutHeight / 2 + jointSize.z / 2])
      maleAnnularJoint(wideRadius, narrowRadius, jointSize.z, 1);
    difference() {
      strut();
      translate([0, 0, jointOffset]) {
        rotate([0, 90, 0]) {
          femaleAnnularJointSubtractive(
            1.5,
            3,
            2,
            10,
            0.1,
            1
          );
          femaleAnnularJointSubtractiveFreedom(0.75, 3, 0.1, 10);
        }
      }
    }
    translate([0, 0, jointOffset]) {
      // Maybe make thickness more. This doesn't provide much of an intersection.
      translate([0, 1.3, -4.4]) {
        cube([10, 1, 3], center=true);
      }
      translate([0, -1.3, -4.4]) {
        cube([10, 1, 3], center=true);
      }
      translate([0, 1.3, 4.4]) {
        cube([10, 1, 3], center=true);
      }
      translate([0, -1.3, 4.4]) {
        cube([10, 1, 3], center=true);
      }
    }
    /* translate([0, 0, -5]) { */
    /*   cube([10, 10, 3], center=true); */
    /* } */
    /* translate([0, 0, 5]) { */
    /*   cube([10, 10, 3], center=true); */
    /* } */
    translate([0, 0, -strutHeight / 2 + jointSize.z / 2]) {
      femaleAnnularJoint(
        1.5,
        3,
        2,
        10,
        0.1,
        1
      );
    }
  }
}

if(preview) {
  translate([40, 100, 0])
    maleAnnularJoint(3, 2, 10, 1);
  translate([40, 120, 0])
    femaleAnnularJoint(
      1.5,
      3,
      2,
      10,
      0.1,
      1
    );
}
