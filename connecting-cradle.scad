cradleHeight = 77.5 * 0.65;
cradleWallThickness = 2;
cradleJointWidth = 9;
cradleJointThickness = 4;
cradleJointFemaleThickness = 2;
cradleJointChannelWidth = 2;
cradleJointChannelThickness = 2;
bottomHeight = cradleHeight * 0.65;

module cradleTrackFemale(bottomHeight) {
  cradleJointFemaleHeight = 5.5;
  translate([0, 0, cradleHeight / 2 - bottomHeight / 2]) {
    difference() {
      cube([
        cradleJointWidth + cradleJointChannelWidth + cradleJointFemaleThickness * 2,
        cradleJointThickness
          + cradleJointFemaleHeight
          + cradleJointChannelThickness,
        bottomHeight,
      ], center=true);
      translate([
        0,
        -cradleJointFemaleHeight - cradleJointChannelThickness / 3,
        cradleJointFemaleThickness + cradleJointChannelThickness * 2,
      ])
        scale([1.2, 1.2, 1.2])
        cradleTrackMale(bottomHeight, 1.0);
    }
  }
}

// The widthScale is because when we print the foot diagonally, the top doesn't
// quite fit in the joint securely.
module cradleTrackMale(height, widthScale) {
  cube([cradleJointWidth, cradleJointThickness, height], center=true);
  translate([0, cradleJointThickness / 2 + cradleJointChannelThickness / 2, 0])
    cube([
      (cradleJointChannelWidth + cradleJointWidth) * widthScale,
      cradleJointChannelThickness + 0.01,
      height,
    ], center=true);
}

module cradle() {
  cylinder(
    d=bottleBodyDiameterVallejo + cradleWallThickness,
    h=cradleHeight,
    center=true
  );
  translate([0, bottleBodyDiameterVallejo / 2, cradleJointFemaleThickness])
    cradleTrackMale(cradleHeight - cradleJointFemaleThickness * 2, 1.0);
  translate([0, -bottleBodyDiameterVallejo / 2, 0])
    cradleTrackFemale(bottomHeight);
  translate([-bottleBodyDiameterVallejo / 2, 0, cradleJointFemaleThickness])
    rotate([0, 0, 90])
    cradleTrackMale(cradleHeight - cradleJointFemaleThickness * 2, 1.0);
  translate([bottleBodyDiameterVallejo / 2, 0, 0])
    rotate([0, 0, 90])
    cradleTrackFemale(cradleHeight);
}

module foot(angle) {
  difference() {
    translate([
      0,
      0,
      (cos(angle) * bottomHeight / 2) + (sin(angle) * cradleJointThickness / 2),
    ])
      rotate([angle, 0, 0]) {
        cradleTrackMale(bottomHeight, 1.1);
        footLeg(angle);
      }
    let(floorSize = 500) {
      translate([0, 0, floorSize / -2])
        cube([floorSize, floorSize, floorSize], center=true);
    }
  }
}

module footLeg(angle) {
  let(
    frontLegLength = cos(angle) * bottomHeight * 2 + sin(angle) * cradleJointThickness / 2,
    backLegLength = bottomHeight * 2
  ) {
    translate([
      0,
      frontLegLength / -2,
      backLegLength / -4
    ])
      /* translate([0, cos(angle) * (bottomHeight + cradleJointThickness), 0]) */
    cube([
      cradleJointWidth,
      frontLegLength,
      backLegLength,
    ], center=true);
  }
}
