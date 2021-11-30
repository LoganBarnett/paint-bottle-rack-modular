#!/usr/bin/env bash
set -euo pipefail

mkdir -p dist

openscad \
  -o dist/paint-bottle-cradle.stl \
  -DshowCradle=true \
  -DshowFoot=false \
  -DlayFlat=true \
  main.scad
openscad \
  -o dist/paint-bottle-foot.stl \
  -DshowCradle=false \
  -DshowFoot=true \
  main.scad
