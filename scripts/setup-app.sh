#!/usr/bin/env bash
# Turns a repo made with "Use this template"
# into a new app, in place:
#   scripts/setup-app.sh <Name> [version]
# It makes the app with new-app.sh (the
# sample, renamed and pinned to the newest
# template version), replaces every file
# from the template with it, and fetches
# the pinned template into .template/.
# Commit the result on a branch and open a
# PR (see docs/NEW-APP.md).
set -euo pipefail

name="${1:?app name, e.g. QuestLog}"
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
origin=$(git remote get-url origin)
if grep -qi '/ios-template' <<<"$origin"
then
  echo "This is the template itself." >&2
  exit 1
fi

app=$(mktemp -d)
scripts/new-app.sh "$name" "$app" "${2:-}"

# Out with the template's files, in with
# the app's.
rm -rf .template
git ls-files -z | xargs -0 rm -f
find . -mindepth 1 -type d -empty \
  -not -path './.git/*' -delete
cp -R "$app"/. .
rm -rf "$app"

cat > README.md <<MD
# $name

An iOS app built on
[ios-template](https://github.com/gastly92/ios-template).
See CLAUDE.md.
MD

# The pinned template, as a session's start
# hook fetches it, so linting works now.
CLAUDE_CODE_REMOTE=true \
  CLAUDE_PROJECT_DIR="$root" \
  CLAUDE_ENV_FILE=/dev/null \
  .claude/hooks/session-start.sh >/dev/null

git add -A
echo "Set up $name. Review, commit and push."
