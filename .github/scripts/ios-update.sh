#!/usr/bin/env bash
# On main, when the runner has a newer iOS
# than the snapshots were drawn on
# (run-tests.sh gives it as the build job's
# `newer` output): opens a PR that moves
# them to it. The PR sets
# __Snapshots__/iOS.txt, carries the
# record-snapshots label (CI draws every
# image again on the new iOS) and is
# assigned to the repo's owner, whom
# GitHub then emails.
# One PR per iOS version, ever: closing it
# without merging declines that version.
# Needs NEWER, OWNER and GH_TOKEN (the
# snapshot app's: its events start CI).
set -euo pipefail

app=$(sed -n 's/^name: *//p' project.yml)
branch="snapshots/ios-$NEWER"
found=$(gh pr list --head "$branch" \
  --state all --json number --jq length)
if [ "$found" != 0 ]; then
  echo "iOS $NEWER already has a PR."
  exit 0
fi

git config user.name "github-actions[bot]"
git config user.email \
  "41898282+github-actions[bot]@users.noreply.github.com"
title="Snapshots: move to iOS $NEWER"
git checkout -q -B "$branch"
echo "$NEWER" \
  > "${app}Tests/__Snapshots__/iOS.txt"
git commit -qam "$title"
# A bot branch: replace any leftover from
# a run that stopped before its PR.
git push -q -f origin "HEAD:$branch"

body=$(cat <<EOF
CI's runners now have iOS $NEWER, newer
than the iOS the snapshots were drawn on.
This PR moves them to it: the
\`record-snapshots\` label draws every image
again on iOS $NEWER and commits them here.

Look at the changed images, then merge to
move every PR to iOS $NEWER, or close this
PR to stay on the current iOS.

If recording fails with "isn't on this
runner yet", GitHub is still rolling out
the new runner image: re-run the failed
jobs in a day or two.
EOF
)
gh pr create --base main --head "$branch" \
  --title "$title" \
  --body "$body" --assignee "$OWNER"
# Added after the PR opens, so CI sees the
# label being added (that run records
# every image).
gh pr edit "$branch" \
  --add-label record-snapshots
