#!/usr/bin/env bash
# After a PR's tests: commits the snapshot
# images they recorded (new screens, or all
# of them with the `record-snapshots` label)
# to the PR branch, removes the label, and
# starts CI on the new commit (a push made by
# CI doesn't start workflows by itself).
# Needs BRANCH, PR, GH_TOKEN and WORKFLOW
# (the workflow file to run again).
set -euo pipefail

app=$(sed -n 's/^name: *//p' project.yml)
dir="${app}Tests/__Snapshots__"
changes=$(git status --porcelain -- "$dir")
if [ -z "$changes" ]; then
  echo "No new snapshot images."
  exit 0
fi
echo "$changes"

# The tests ran on the PR merged into main;
# put the images on the PR branch itself.
saved=$(mktemp -d)
cp -R "$dir" "$saved/"
# (Undo them here first; the folder may not
# be in git yet.)
if [ -n "$(git ls-files -- "$dir")" ]; then
  git checkout -- "$dir"
fi
git clean -fdq -- "$dir"
git fetch -q --depth=1 origin "$BRANCH"
git checkout -q -B "$BRANCH" FETCH_HEAD
rm -rf "$dir"
cp -R "$saved/__Snapshots__" "$dir"

git config user.name "github-actions[bot]"
git config user.email \
  "41898282+github-actions[bot]@users.noreply.github.com"
git add -A "$dir"
git commit -qm "Record snapshot images"
git push -q origin "HEAD:$BRANCH"

gh pr edit "$PR" \
  --remove-label record-snapshots || true
gh workflow run "$WORKFLOW" --ref "$BRANCH"
echo "Pushed the images; CI runs again."
