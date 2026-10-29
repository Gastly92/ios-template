#!/usr/bin/env bash
# Turns a copy made with "Use this template"
# into a new app, in place:
#   .github/scripts/setup-app.sh <Name>
# Name is the app's Swift name (e.g.
# QuestLog): its scheme, source folders and
# bundle ID (com.gastly92.questlog). It
# renames the sample to it, points the
# support pages at this repo, draws an icon
# from the name's first letter, and removes
# what only the template needs (this script
# too). Commit the result on a branch and
# open a PR (see docs/NEW-APP.md).
set -euo pipefail

name="${1:?app name, e.g. QuestLog}"
if ! [[ "$name" =~ ^[A-Z][A-Za-z0-9]*$ ]]
then
  echo "Name must be like QuestLog." >&2
  exit 1
fi
cd "$(git rev-parse --show-toplevel)"
origin=$(git remote get-url origin)
if grep -qi '/ios-template' <<<"$origin"
then
  echo "This is the template itself." >&2
  exit 1
fi
lower=$(tr '[:upper:]' '[:lower:]' \
  <<<"$name")

# Only the template needs these. The
# sample's snapshot images go too: CI
# records the app's own.
git rm -rq README.md \
  .github/scripts/setup-app.sh \
  SampleTests/__Snapshots__

# Folders and files named after the sample.
for dir in Sample SampleTests SampleUITests
do
  git mv "$dir" "${dir/Sample/$name}"
done
named=$(git ls-files "$name" \
  | grep Sample || true)
for file in $named; do
  git mv "$file" "${file//Sample/$name}"
done

# Every text file: Sample becomes the app's
# name, in code, docs and bundle IDs.
git ls-files -z \
  | xargs -0 grep -lIE 'Sample|\.sample' \
  | while IFS= read -r file; do
    sed -i -e "s/Sample/$name/g" \
      -e "s/\.sample/.$lower/g" "$file"
  done

# CLAUDE.md: the template's own section.
start='/^<!-- template -->$/'
end='/^<!-- \/template -->$/'
sed -i "$start,${end}d" CLAUDE.md

cat > README.md <<MD
# $name

An iPhone app. See CLAUDE.md.
MD

# The pages link to this repo's issues.
slug=$(sed -E 's#^.*[/:]([^/]+/[^/]+)$#\1#' \
  <<<"${origin%.git}")
sed -i "s#gastly92/ios-template#$slug#g" \
  site/*.html

# An icon to start with: the name's first
# letter on the sample's colors (redraw
# with app-icon.sh any time).
if command -v convert >/dev/null; then
  .github/scripts/app-icon.sh \
    "${name:0:1}" '#00B4F0' '#8B2CF5'
fi

git add -A
echo "Set up $name. Review, commit and push."
