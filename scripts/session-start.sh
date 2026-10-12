#!/bin/bash
# Session setup for an app (or the
# template), run by its session start hook
# from the repo's root: installs the
# workflow and script checkers CI runs, so
# they can run before pushing; fetches the
# SwiftLint image; and prints the shared
# rules (RULES.md) into Claude's context.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
venv="$HOME/.cache/ios-template-venv"
if [ ! -x "$venv/bin/pip" ]; then
  python3 -m venv "$venv"
fi
"$venv/bin/pip" install -q \
  --disable-pip-version-check \
  -r "$here/checkers.txt"
echo "export PATH=\"$venv/bin:\$PATH\"" \
  >> "$CLAUDE_ENV_FILE"

# SwiftLint runs in Docker: start it and
# fetch the image in the background so the
# first lint is quick.
(nohup "$here/swiftlint.sh" --prepare \
  >/dev/null 2>&1 &)

# A repo made with "Use this template" and
# not set up yet: tell Claude what to do.
origin=$(git remote get-url origin \
  2>/dev/null || true)
if [ -f Sample/SampleApp.swift ] \
  && ! grep -qi '/ios-template' <<<"$origin"
then
  cat <<'MD'
# This repo needs setting up

It was made from ios-template ("Use this
template") and is still the template's
sample. Follow "Setting up a new repo
(for Claude)" in docs/NEW-APP.md as soon
as the user asks for anything, before
other work.

MD
fi

cat "$here/../RULES.md"
