#!/bin/bash
# Claude Code cloud sessions: fetch the
# template at the version this repo pins
# into .template/ (git ignores it), then run
# its setup: the checkers CI runs, the
# SwiftLint image, and the shared rules.
# The same file in every app.
set -euo pipefail

remote="${CLAUDE_CODE_REMOTE:-}"
[ "$remote" = true ] || exit 0
cd "$CLAUDE_PROJECT_DIR"

# The pin: `<owner/repo> <ref>` from the
# shared CI call in build.yml. The template
# calls its own copy (no pin): .template is
# the repo itself.
uses='s|.*uses: *\([^/]*/[^/]*\)'
uses+='/\.github/workflows/ci\.yml@'
uses+='\(.*\)|\1 \2|p'
pin=$(sed -n "$uses" \
  .github/workflows/build.yml)
if [ -z "$pin" ]; then
  ln -sfn . .template
else
  read -r repo ref <<<"$pin"
  rm -rf .template
  git init -q .template
  git -C .template fetch -q --depth 1 \
    "https://github.com/$repo" "$ref"
  git -C .template checkout -q FETCH_HEAD
fi

exec .template/scripts/session-start.sh
