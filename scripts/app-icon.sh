#!/usr/bin/env bash
# Draws a simple app icon in the three
# versions iOS shows, from a short mark
# (a letter or two) and two colors:
#   app-icon.sh <mark> <color> <color>
# e.g. app-icon.sh Q '#00B4F0' '#8B2CF5'.
# Light: the mark in white on a diagonal
# gradient of the colors. Dark: the mark in
# the gradient on near-black. Tinted: the
# mark in white on black (iOS colors it).
# Writes the app's AppIcon set in
# <App>/Assets.xcassets (the app is
# project.yml's name). Needs
# ImageMagick 6 and Inter Display Bold (both
# in the cloud session). Run from the app's
# root; a hand-drawn icon can replace the
# PNGs later.
set -euo pipefail

mark="${1:?a letter or two, e.g. Q}"
from="${2:?first color, e.g. '#00B4F0'}"
to="${3:?second color, e.g. '#8B2CF5'}"
font="${ICON_FONT:-/usr/share/fonts/opentype/inter/InterDisplay-Bold.otf}"
app=$(sed -n 's/^name: *//p' project.yml)
out="$app/Assets.xcassets/AppIcon.appiconset"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$out"

size=1024
points=$((560 / ${#mark}))
grad() {
  convert -size "${size}x$size" \
    -define gradient:angle=135 \
    gradient:"$from-$to" "$1"
}
# The mark in white on transparent.
convert -size "${size}x$size" xc:none \
  -font "$font" -pointsize "$points" \
  -fill white -gravity center \
  -annotate +0+10 "$mark" "$tmp/mark.png"

# Light.
grad "$tmp/grad.png"
convert "$tmp/grad.png" "$tmp/mark.png" \
  -composite -alpha off -depth 8 \
  "$out/AppIcon.png"

# Dark: the gradient, cut to the mark.
convert "$tmp/grad.png" "$tmp/mark.png" \
  -alpha off -compose CopyOpacity \
  -composite "$tmp/inked.png"
convert -size "${size}x$size" xc:'#05050A' \
  "$tmp/inked.png" -composite \
  -alpha off -depth 8 "$out/AppIcon-Dark.png"

# Tinted.
convert -size "${size}x$size" xc:black \
  "$tmp/mark.png" -composite \
  -colorspace Gray -alpha off -depth 8 \
  "$out/AppIcon-Tinted.png"

cat > "$out/Contents.json" <<'JSON'
{
  "images" : [
    {
      "filename" : "AppIcon.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "filename" : "AppIcon-Dark.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "tinted"
        }
      ],
      "filename" : "AppIcon-Tinted.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON
assets="$app/Assets.xcassets"
cat > "$assets/Contents.json" <<'JSON'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON
echo "Wrote the icons to $out."
