#!/usr/bin/env bash
# After a PR's tests: commits the snapshot
# images they recorded (new screens, or all
# of them with the `record-snapshots` label)
# to the PR branch, removes the label, and
# starts CI on the new commit (a push made by
# CI doesn't start workflows by itself).
# GitHub also makes a run for the bot's push
# that waits for "Approve and run"; it's a
# duplicate, so a PR comment links the real
# run and says so.
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
started=$(gh workflow run "$WORKFLOW" \
  --ref "$BRANCH" 2>&1)
echo "$started"
run=$(grep -o 'https://[^ ]*' \
  <<<"$started" | head -1)
gh pr comment "$PR" --body "$(cat <<MD
Recorded snapshot images and pushed them.
CI runs again here: ${run:-see Actions}.

No need to tap **Approve and run**: that
run is a duplicate GitHub holds for the
bot's push.
MD
)" || true
echo "Pushed the images; CI runs again."
