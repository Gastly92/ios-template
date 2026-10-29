#!/bin/bash
# Runs SwiftLint in Docker, with the version
# pinned in .github/swiftlint/Dockerfile.
# CI's SwiftLint job runs this too, so a
# clean run here means a clean run there.
# Starts the Docker daemon if it isn't
# running (as in Claude Code cloud
# sessions). `--prepare` only starts Docker
# and downloads the image.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
pin="$root/.github/swiftlint/Dockerfile"
image="$(sed -n 's/^FROM //p' "$pin")"

if ! docker info >/dev/null 2>&1; then
  (dockerd >/tmp/dockerd.log 2>&1 &)
  for _ in $(seq 1 30); do
    docker info >/dev/null 2>&1 && break
    sleep 1
  done
fi

if [ "${1:-}" = "--prepare" ]; then
  docker pull -q "$image" >/dev/null
  exit 0
fi

echo "Linting with $image"
# Plain file:line output: GitHub shows only
# 10 annotations per step.
docker run --rm -v "$root:/work" -w /work \
  --entrypoint swiftlint "$image" \
  lint --strict --quiet --reporter xcode
