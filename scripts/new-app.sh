#!/usr/bin/env bash
# Starts a new app from the template's
# sample app, in an empty repo:
#   new-app.sh <Name> <repo dir> [version]
# Name is the app's Swift name (e.g.
# QuestLog): its scheme, source folder and
# bundle ID (com.gastly92.questlog). The app
# pins the template at `version` (default:
# the newest tag on GitHub). Run it from a
# checkout of the template (or a copy made
# with "Use this template"; setup-app.sh
# turns such a copy into the app).
set -euo pipefail

name="${1:?app name, e.g. QuestLog}"
dest="${2:?folder of the new app repo}"
here="$(cd "$(dirname "$0")/.." && pwd)"
repo=gastly92/ios-template
shared="$repo/.github/workflows"
newest() {
  git ls-remote -q --tags --refs \
    "https://github.com/$repo" 'v*' \
    | sed 's|.*refs/tags/||' \
    | sort -V | tail -n 1
}
version="${3:-}"
version="${version:-$(newest)}"
if [ -z "$version" ]; then
  echo "No template version tag yet." >&2
  exit 1
fi
lower=$(tr '[:upper:]' '[:lower:]' \
  <<<"$name")

if ! [[ "$name" =~ ^[A-Z][A-Za-z0-9]*$ ]]
then
  echo "Name must be like QuestLog." >&2
  exit 1
fi
if [ -e "$dest/project.yml" ]; then
  echo "$dest already has an app." >&2
  exit 1
fi
mkdir -p "$dest"

# The sample app, renamed. Snapshot images
# aren't copied: CI records the app's own.
for dir in Sample SampleTests SampleUITests
do
  to="$dest/${dir/Sample/$name}"
  mkdir -p "$to"
  (cd "$here/$dir" && git ls-files) \
    | grep -v __Snapshots__ \
    | while IFS= read -r file; do
      out="$to/${file//Sample/$name}"
      mkdir -p "$(dirname "$out")"
      cp "$here/$dir/$file" "$out"
    done
done
for file in project.yml .swiftlint.yml \
  .gitignore .github/unpictured.txt \
  .claude/settings.json \
  .claude/hooks/session-start.sh; do
  mkdir -p "$(dirname "$dest/$file")"
  cp "$here/$file" "$dest/$file"
done

# Every copied text file: Sample becomes the
# app's name, in code and bundle IDs.
grep -rlE 'Sample|sample' "$dest" \
  --exclude-dir=.git \
  | while IFS= read -r file; do
    sed -i.bak -e "s/Sample/$name/g" \
      -e "s/\.sample/.$lower/g" "$file"
    rm "$file.bak"
  done
# Only the template has a Packages folder.
sed -i.bak '/^  - Packages$/d' \
  "$dest/.swiftlint.yml"
rm "$dest/.swiftlint.yml.bak"

flows="$dest/.github/workflows"
mkdir -p "$flows"
cat > "$flows/build.yml" <<YML
name: iOS Build

# The template's shared CI, at the version
# this app pins. Dependabot opens a PR for
# each new version (see RULES.md).
on:
  push:
    branches: [main]
  pull_request:
    # \`labeled\`: the record-snapshots
    # label records every snapshot again.
    types:
    - opened
    - synchronize
    - reopened
    - labeled
  workflow_dispatch:

concurrency:
  group: ios-build-\${{ github.ref }}
  cancel-in-progress: true

# What the shared CI may do: commit
# recorded snapshot images to a PR branch
# and start CI again on it.
permissions:
  contents: write
  actions: write
  pull-requests: write

jobs:
  ci:
    name: CI
    uses: $shared/ci.yml@$version
YML

cat > "$flows/testflight.yml" <<YML
name: TestFlight

# Run from the GitHub app: Actions →
# TestFlight → Run workflow. Uploads the
# app to TestFlight with the template's
# shared workflow (see RULES.md).
on:
  workflow_dispatch:

concurrency:
  group: testflight
  cancel-in-progress: false

permissions:
  contents: write

jobs:
  upload:
    name: TestFlight
    uses: $shared/testflight.yml@$version
    secrets: inherit
YML

cat > "$dest/.github/dependabot.yml" <<YML
# Dependabot opens a PR when a new template
# version is out (the shared workflows'
# pins). Everything else the app uses comes
# with the template.
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    groups:
      template:
        patterns: ["*"]
YML

cat > "$dest/CLAUDE.md" <<MD
# CLAUDE.md

$name: an iOS app built on
[ios-template](https://github.com/$repo)
($version, pinned in
\`.github/workflows/build.yml\`). The
template's rules (RULES.md) apply here;
the session start hook fetches the
template into \`.template/\` and prints
them. Rules specific to this app go
below. TestFlight setup: the template's
\`docs/NEW-APP.md\`.

## This app
- What it is: (fill in)
- Bundle ID \`com.gastly92.$lower\`.
MD

echo "Created $name in $dest, pinned to" \
  "$repo $version."
