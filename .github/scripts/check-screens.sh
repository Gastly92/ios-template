#!/usr/bin/env bash
# Every screen must be in the screen list, so
# the snapshot and localization tests
# (which loop over ScreenID) cover it. A
# screen is a top-level `struct Name: View`
# in <app>/Views/Screens/; ScreenHost
# must show it.
set -euo pipefail

app=$(sed -n 's/^name: *//p' project.yml)
host="$app/Views/ScreenHost.swift"
screens="$app/Views/Screens"
pattern='^struct [A-Za-z0-9_]+: View'
missing=0
count=0
for file in "$screens"/*.swift; do
  names=$(grep -oE "$pattern" "$file" \
    | awk '{print $2}' | tr -d ':')
  for name in $names; do
    count=$((count + 1))
    if grep -qE "\\b${name}\\b" "$host"; then
      continue
    fi
    echo "::error file=$file::$name is a" \
      "screen but isn't in the screen" \
      "list. Add a ScreenID case for it" \
      "and show it in ScreenHost (see" \
      "CLAUDE.md)."
    missing=1
  done
done
echo "Checked $count screens against $host."
exit "$missing"
