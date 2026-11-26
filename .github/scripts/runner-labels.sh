#!/usr/bin/env bash
# Fails when the pinned actionlint already
# knows a runner label that
# .github/actionlint.yaml lists, so the
# entry is dropped once it isn't needed.
# Dependabot bumps actionlint
# (.github/checkers/requirements.txt);
# its PR fails here when a label can go.
set -euo pipefail

config=.github/actionlint.yaml
probe=$(mktemp -d)
trap 'rm -rf "$probe"' EXIT

stale=""
while read -r label; do
  # A workflow using only this label,
  # checked outside the repo, so without
  # the config.
  cat > "$probe/p.yml" <<YAML
on: push
jobs:
  probe:
    runs-on: $label
    steps:
    - run: "true"
YAML
  if (cd "$probe" && actionlint p.yml) \
    > /dev/null 2>&1; then
    stale+=" $label"
  fi
done < <(sed -n 's/^ *- //p' "$config")

if [ -n "$stale" ]; then
  echo "::error::actionlint knows" \
    "these runner labels now; drop" \
    "them from $config:$stale"
  exit 1
fi
echo "Every label in $config is needed."
