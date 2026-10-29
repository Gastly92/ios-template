#!/bin/bash
# Claude Code cloud sessions: install the
# workflow and script checkers CI runs, so
# they can run before pushing, and prepare
# SwiftLint.
set -euo pipefail

remote="${CLAUDE_CODE_REMOTE:-}"
[ "$remote" = true ] || exit 0
cd "$CLAUDE_PROJECT_DIR"

venv="$HOME/.cache/app-venv"
if [ ! -x "$venv/bin/pip" ]; then
  python3 -m venv "$venv"
fi
"$venv/bin/pip" install -q \
  --disable-pip-version-check \
  -r .github/scripts/checkers.txt
echo "export PATH=\"$venv/bin:\$PATH\"" \
  >> "$CLAUDE_ENV_FILE"

# SwiftLint runs in Docker: start it and
# fetch the image in the background so the
# first lint is quick.
lint=.github/scripts/swiftlint.sh
(nohup "$lint" --prepare >/dev/null 2>&1 &)

# A copy made with "Use this template" and
# not set up yet: tell Claude what to do.
origin=$(git remote get-url origin \
  2>/dev/null || true)
if [ -f .github/scripts/setup-app.sh ] \
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
