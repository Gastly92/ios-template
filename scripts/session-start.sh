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

cat "$here/../RULES.md"
