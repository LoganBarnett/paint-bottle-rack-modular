
/**
 * A female joint for mating two parts of the frame together by adjacent pieces.
 * This allows adding an indefinite width of joined pieces.
 *
 * See diagonalJointMale for the mating end.
 *
 * The male and female joints are very close to each other, but I added 0.5 in
 * either direction to create a bit of a gap. This could probably stand to have
 * some sort of factor rather than a hardcoded and hand-done addition. This
 * allows some tolerance with both the printer and the fit of the joint.
 */
module diagonalJointFemale() {
  polygon(
    points=[
      [5,5],
      [5,-5],
      [-5,-5],
      [-1.5, -1.5],
      [-0.5, -2.5],
      [-0.5, -3.5],
      [2.5, -3.5],
      [3.5, -2.5],
      [3.5, -1.5],
      [3.5, 0.5],
      [2.5, 0.5],
      [1.5, 1.5],
    ]
  );
}

/**
 * A male joint for mating two parts of the frame together by adjacent pieces.
 * This allows adding an indefinite width of joined pieces.
 *
 * See diagonalJointFemale for the mating end.
 *
 * The male and female joints are very close to each other, but I added 0.5 in
 * either direction to create a bit of a gap. This could probably stand to have
 * some sort of factor rather than a hardcoded and hand-done addition. This
 * allows some tolerance with both the printer and the fit of the joint.
 */
module diagonalJointMale() {
  polygon(
    points=[
      [5,5],
      [5,-5],
      [-5,-5],
      [1, 1],
      [0, 2],
      [0, 3],
      [-2, 3],
      [-3, 2],
      [-3, 1],
      [-3, 0],
      [-2, 0],
      [-1, -1],
    ]
  );
}

if(preview) {
  translate([50, 0, 0]) {
    color("blue")
      rotate(a=180, v=[0,0,1])
      diagonalJointMale();
    color("green")
      diagonalJointFemale();
  }
}
