# iOS updates for the snapshots

The snapshots are drawn on one iOS, saved
in `SampleTests/__Snapshots__/iOS.txt`
(see CLAUDE.md). When GitHub's runners get
a newer iOS, CI moves to it in a PR you
review, never on its own.

## What happens
1. A run on `main` finds a newer iOS on the
   runner (`run-tests.sh`, in the build
   job). The `iOS update` job
   (`ios-update.sh`) opens a PR from
   `snapshots/ios-<version>` that sets
   `iOS.txt`, adds the `record-snapshots`
   label and assigns you, so GitHub emails
   you. One PR per iOS version, ever.
2. CI draws every image again on the new
   iOS and commits them to the PR.
   If GitHub is still rolling out the
   runner image with that iOS, a run can
   land on an older runner: recording then
   fails with "isn't on this runner yet".
   Re-run the failed jobs a day or two
   later.
3. You look at the changed images (Files
   changed) and merge (every PR then
   draws on the new iOS), or close the PR
   to stay on the current one.

## Setup (once)
The snapshot app needs **Pull requests:
Read and write** to open the PR
(docs/SNAPSHOT-APP.md). Without it, the
`iOS update` job's "Open the PR" step
fails (without failing the run), and the
build log only warns.
