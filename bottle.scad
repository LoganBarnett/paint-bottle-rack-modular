// I couldn't find anyone who has taken measurements of the various bottle
// dimensions and made them available. Some measurements are taken but they are
// always incomplete. These measurements are taken with my own calipers.


bottleCapHeight=28;
// Vallejo, Army Painter, and Reaper all use the same cap sizes.
module bottleCap() {
  neckNarrowDiameter=8.5;
  neckNarrowHeight=12;
  neckWideDiameter=19;
  neckWideHeight=17;
  translate([0, 0, neckWideHeight / 2]) {
    translate([
      0, 0, neckNarrowHeight,
    ])
      cylinder(d=neckNarrowDiameter, h=neckNarrowHeight, center = true);
    cylinder(d=neckWideDiameter, h=neckWideHeight, center = true);
  }
}

// The real bottle cap and body are conical and rounded (respectively). These
// should serve as decent approximations though. Wouldn't it be swell to get
// this information from the source?!
module bottleVallejo() {
  bodyDiameter=24.5;
  height=77.5;
  let (
    bodyHeight = height - bottleCapHeight
  ) {
    // Center the entire model by accounting for the cap height.
    translate([0,0, -bottleCapHeight / 2]) {
      translate([
        0, 0, bodyHeight / 2 - 0.1,
      ]) {
        bottleCap();
      }
      cylinder(d=bodyDiameter, h=bodyHeight, center = true);
    }
  }
}
