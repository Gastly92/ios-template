#!/usr/bin/env bash
# After a PR's tests: commits the snapshot
# images they recorded (new screens, or all
# of them with the `record-snapshots` label)
# to the PR branch and removes the label.
# With APP_TOKEN (the snapshot app's, see
# docs/SNAPSHOT-APP.md) the push starts CI
# like any push. Without it the push uses
# CI's own token, which starts no run (only
# one held behind "Approve and run"), so
# this starts CI on the new commit itself.
# Needs BRANCH, PR and GH_TOKEN.
set -euo pipefail

app=$(sed -n 's/^name: *//p' project.yml)
dir="${app}Tests/__Snapshots__"
# Only the images the tests recorded (new
# or changed). Not the whole folder: the
# tests ran on the PR merged into main,
# which can be older than the branch, and
# copying it all brought back images the
# branch had just deleted.
list=$(mktemp)
{
  git ls-files -z --others \
    --exclude-standard -- "$dir"
  git diff -z --name-only \
    --diff-filter=M -- "$dir"
} > "$list"
if [ ! -s "$list" ]; then
  echo "No new snapshot images."
  exit 0
fi
tr '\0' '\n' < "$list"

# Put them on the PR branch itself.
saved=$(mktemp -d)
xargs -0 tar -cf "$saved/new.tar" < "$list"
# (Undo them here first; the folder may not
# be in git yet.)
if [ -n "$(git ls-files -- "$dir")" ]; then
  git checkout -- "$dir"
fi
git clean -fdq -- "$dir"
git fetch -q --depth=1 origin "$BRANCH"
git checkout -q -B "$BRANCH" FETCH_HEAD
tar -xf "$saved/new.tar"

git config user.name "github-actions[bot]"
git config user.email \
  "41898282+github-actions[bot]@users.noreply.github.com"
git add -A "$dir"
git commit -qm "Record snapshot images"

# Before pushing: the app's push starts a
# new run, which cancels this one.
gh pr edit "$PR" \
  --remove-label record-snapshots || true

if [ -n "${APP_TOKEN:-}" ]; then
  # The empty extraheader drops the
  # checkout's own credentials, so the
  # app's token is the one used.
  repo="github.com/$GITHUB_REPOSITORY.git"
  git -c http.https://github.com/.extraheader= \
    push -q \
    "https://x-access-token:$APP_TOKEN@$repo" \
    "HEAD:$BRANCH"
else
  git push -q origin "HEAD:$BRANCH"
  gh workflow run ios-build.yml \
    --ref "$BRANCH"
fi
echo "Pushed the images; CI runs again."
