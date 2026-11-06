#!/usr/bin/env bash
# CI's tests, in two steps on separate
# runners:
#   run-tests.sh boot
#     starts the simulator early, so it
#     boots while the build downloads;
#   run-tests.sh build
#     builds the app and tests once;
#   run-tests.sh test <shard>
#     runs one shard of the tests on that
#     build (main, localization).
# Run from the app's root: the app is the
# `name:` in project.yml (its scheme and
# source folder), with <name>Tests and
# <name>UITests beside it.
# The shards run in parallel, each on its own
# runner with one simulator (the 3-core
# runner can't run two: when tried, the
# second timed out). A failed test prints its
# step-by-step record (taps, waits, what it
# found).
set -euo pipefail

mode="${1:?boot, build or test}"
app=$(sed -n 's/^name: *//p' project.yml)

# Always this iPhone, on the iOS the
# snapshots were drawn on (saved in
# __Snapshots__/iOS.txt), so every run
# draws on the same iOS: GitHub rolls new
# runner images out over days, and "the
# newest iOS" would differ between runs.
# Recording every image (RECORD_ALL) uses
# the newest iOS, which the snapshot tests
# then save. A newer iOS than the saved one
# only adds a warning (and, on main, opens
# a PR to move to it: ios-update.sh);
# without the saved one, the newest is used
# and the snapshot tests fail, saying to
# record again. Recording for an iOS newer
# than the runner has (that PR, on a runner
# the new image hasn't reached) fails
# rather than record on an older iOS.
model="iPhone 17"
saved="${app}Tests/__Snapshots__/iOS.txt"
pick() {
  local runtimes devices id version udid
  local list want newest chosen
  runtimes=$(
    xcrun simctl list runtimes available -j
  )
  devices=$(
    xcrun simctl list devices available -j
  )
  # "<version> <udid>" for each iOS with
  # the model, oldest first.
  list=$(
    jq -r '.runtimes[]
      | select(.identifier
        | contains("SimRuntime.iOS-"))
      | "\(.identifier) \(.version)"' \
      <<<"$runtimes" \
    | while read -r id version; do
      udid=$(RID=$id MODEL=$model jq -r \
        'first(.devices[env.RID][]?
          | select(.name == env.MODEL)
          | .udid) // empty' \
        <<<"$devices")
      if [ -n "$udid" ]; then
        echo "$version $udid"
      fi
    done | sort -V
  )
  if [ -z "$list" ]; then
    echo "::error::No $model simulator"
    exit 1
  fi
  newest=$(tail -n 1 <<<"$list")
  want=$(cat "$saved" 2>/dev/null || true)
  chosen=$newest
  if [ "${RECORD_ALL:-false}" = true ] \
    && [ -n "$want" ] \
    && [ "$want" != "${newest% *}" ] \
    && [ "$(printf '%s\n' "$want" \
      "${newest% *}" | sort -V \
      | tail -n 1)" = "$want" ]; then
    echo "::error::iOS $want isn't on" \
      "this runner yet (newest: iOS" \
      "${newest% *}); GitHub is still" \
      "rolling out the image that has it." \
      "Re-run the failed jobs later."
    exit 1
  fi
  if [ "${RECORD_ALL:-false}" != true ] \
    && [ -n "$want" ]; then
    # As text: as numbers, 26.10 == 26.1.
    chosen=$(awk -v want="$want" \
      '($1 "") == (want "")' <<<"$list")
    if [ -z "$chosen" ]; then
      chosen=$newest
      note "iOS $want, the snapshots' iOS," \
        "isn't on this runner; using iOS" \
        "${newest% *}. Snapshot tests will" \
        "fail: add the record-snapshots" \
        "label to record them again."
    elif [ "$chosen" != "$newest" ]; then
      note "iOS ${newest% *} is available;" \
        "the snapshots use iOS $want. To" \
        "move to it, add the" \
        "record-snapshots label."
      # For the build job's output (the
      # main branch opens a PR for it).
      if [ "$mode" = build ] \
        && [ -n "${GITHUB_OUTPUT:-}" ]; then
        echo "newer=${newest% *}" \
          >> "$GITHUB_OUTPUT"
      fi
    fi
  fi
  device=${chosen#* }
  echo "Using $model on iOS ${chosen% *}" \
    "($device)"
}

# A warning on the PR, once a run (from the
# build step).
note() {
  if [ "$mode" = build ]; then
    echo "::warning::$*"
  else
    echo "$*"
  fi
}
pick

if [ "$mode" = boot ]; then
  # Returns while the simulator boots;
  # xcodebuild waits for it later.
  xcrun simctl boot "$device"
  exit 0
fi

mkdir -p build
common=(
  -project "$app.xcodeproj"
  -scheme "$app"
  -destination "id=$device"
  -derivedDataPath build/test
  -enableCodeCoverage YES
  CODE_SIGNING_ALLOWED=NO
)
summary="${GITHUB_STEP_SUMMARY:-/dev/stdout}"
status=0
start=$SECONDS

if [ "$mode" = build ]; then
  xcodebuild build-for-testing \
    "${common[@]}" \
    > build/build.log 2>&1 || status=$?
  if [ "$status" -ne 0 ]; then
    grep -E 'error:' build/build.log \
      || tail -n 60 build/build.log
    exit "$status"
  fi
  echo "Build for testing:" \
    "$((SECONDS - start)) s" >> "$summary"
  exit 0
fi

# Which tests each shard runs: the slow
# localization check (every screen) on its
# own, and main takes the rest.
shard="${2:?shard: main or localization}"
ui="${app}UITests"
check="$ui/LocalizationTests"
case "$shard" in
  localization) only=(
    "-only-testing:$check"
  ) ;;
  main) only=(
    "-only-testing:${app}Tests"
    "-only-testing:$ui"
    "-skip-testing:$check"
  ) ;;
  *)
    echo "::error::Unknown shard $shard"
    exit 1 ;;
esac

# Snapshot tests record any missing images
# (all of them in the run that adding the
# `record-snapshots` label started:
# RECORD_ALL), and save the images of a
# failed comparison.
record=missing
if [ "${RECORD_ALL:-false}" = true ]; then
  record=all
fi
echo "Snapshot record mode: $record"
export \
  TEST_RUNNER_SNAPSHOT_TESTING_RECORD="$record"
diffs="$PWD/build/snapshot-diffs"
export \
  TEST_RUNNER_SNAPSHOT_ARTIFACTS="$diffs"

# The build's own test plan (.xctestrun), so
# a shard needs no Xcode project.
plan=$(find build/test/Build/Products \
  -name '*.xctestrun' | head -1)
run() {
  rm -rf build/test.xcresult
  status=0
  xcodebuild test-without-building \
    -xctestrun "$plan" \
    -destination "id=$device" \
    -enableCodeCoverage YES \
    "${only[@]}" \
    -resultBundlePath build/test.xcresult \
    > build/test.log 2>&1 || status=$?
}
run

# On CI's simulators the UI test runner
# sometimes fails to start ("Timed out while
# loading Accessibility"), or the simulator
# drops out of the device list ("Unable to
# find a device"), before those tests run.
# Only then, run the shard once more (on a
# freshly picked, booted simulator if it
# dropped out). Any other failure stands.
stuck='failed to initialize for UI testing'
gone='Unable to find a device matching'
started="Test Case '-["
log=build/test.log
if [ "$status" -ne 0 ]; then
  if grep -qF "$stuck" "$log" \
    && ! grep -qF "$started$ui." "$log"; then
    echo "::warning::The UI test runner" \
      "didn't start; running the $shard" \
      "tests once more."
    echo "UI test runner restarted" \
      "($shard)" >> "$summary"
    run
  elif grep -qF "$gone" "$log" \
    && ! grep -qF "$started" "$log"; then
    echo "::warning::The simulator was" \
      "gone; booting one and running the" \
      "$shard tests once more."
    echo "Simulator rebooted ($shard)" \
      >> "$summary"
    pick
    xcrun simctl boot "$device" || true
    run
  fi
fi

# Each test's result and errors, and any
# long-press retried after a stall (see
# `menuItem` in the UI tests).
shown='Test Case .*(passed|failed)'
shown+='|error:|\*\* TEST'
shown+='|Long-press read as a tap'
grep -E "($shown)" build/test.log || true

echo "Tests ($shard):" \
  "$((SECONDS - start)) s" >> "$summary"

if [ "$status" -ne 0 ]; then
  awk '
    /Test Case .* started/ { buf = "" }
    { buf = buf "\n" $0 }
    /Test Case .* failed/ {
      print "::group::" $0
      print buf
      print "::endgroup::"
    }' build/test.log
  tail -n 60 build/test.log
fi
exit "$status"
