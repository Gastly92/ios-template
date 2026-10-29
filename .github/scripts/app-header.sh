#!/usr/bin/env bash
# Draws the App Store product page header
# (docs/appstore/header.png, 5244 x 2950):
# the icon's mark, the app's name and its
# subtitle in white on the icon's gradient.
# Everything sits in the middle, inside the
# widest crop (3840 x 1646's shape), as
# Apple's asset guidance asks.
#   app-header.sh <name> <subtitle> <mark> \
#     <color> <color>
# Needs ImageMagick 6 and Inter Display
# (both in the cloud session). Run from the
# app's root.
set -euo pipefail

name="${1:?app name, e.g. Quest Log}"
subtitle="${2:?subtitle}"
mark="${3:?the icon mark, e.g. Q}"
from="${4:?first color}"
to="${5:?second color}"
fonts=/usr/share/fonts/opentype/inter
bold="$fonts/InterDisplay-Bold.otf"
medium="$fonts/InterDisplay-Medium.otf"
out=docs/appstore/header.png
mkdir -p "$(dirname "$out")"

w=5244
h=2950
# Text is placed from the centre, so +0+N
# is N below the middle.
convert -size "${w}x$h" \
  -define gradient:angle=135 \
  gradient:"$from-$to" \
  -gravity center -fill white \
  -font "$bold" -pointsize 520 \
  -annotate +0-330 "$mark" \
  -pointsize 300 \
  -annotate +0+300 "$name" \
  -font "$medium" -pointsize 150 \
  -fill 'rgba(255,255,255,0.88)' \
  -annotate +0+600 "$subtitle" \
  -alpha off -depth 8 "$out"

echo "Wrote $out."
