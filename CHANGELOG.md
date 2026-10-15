# Changelog

Each version of the template. Apps pin one
(see README.md); a major version lists what
an app must change to update.

## v1.0.0
- First version: the shared CI
  (`ci.yml`), the TestFlight upload
  (`testflight.yml`), the scripts, the
  SwiftLint rules and version, and the
  Base package (`BaseUI`,
  `BaseTesting`, `BaseSnapshots`).
- `scripts/new-app.sh` starts a new app
  from the sample; `docs/NEW-APP.md` has
  the steps, branch rules and TestFlight
  setup included.
- After recording snapshots, CI comments
  on the PR with the new run's link: the
  "Approve and run" box GitHub shows for
  the bot's push is a duplicate.
