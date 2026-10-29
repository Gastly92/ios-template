# Changelog

Each version of the template. Apps pin one
(see README.md); a major version lists what
an app must change to update.

## v1.0.1
- Base is a dynamic library, so an app
  and its unit tests share one copy.
  Linked statically, the test bundle had
  its own: a test's `\.now` (e.g. the
  snapshots' fixed day) never reached the
  app's views, and `is` checks on Base
  types the app made never matched.
- `RecordingNotifier` moved from
  `BaseTesting` to `Base` (BaseTesting no
  longer depends on Base): tests using it
  `import Base`.

## v1.0.0
- The shared CI (`ci.yml`, required check
  `CI / Gate`), TestFlight upload
  (`testflight.yml`) and support pages
  publishing (`pages.yml`); the scripts;
  the SwiftLint rules and version.
- The Base package: `Base` (view helpers,
  `\.now`, notifications), `BaseTesting`
  (UI test helpers, `LocalizationCheck`,
  `RecordingNotifier`, `PrivacyManifest`)
  and `BaseSnapshots` (`Looks`,
  `AppStoreShots`).
- The starter app: saved items
  (SwiftData, versioned schema, store
  error screen, sample data), settings
  with a daily reminder, support and
  privacy pages, privacy manifest, icon
  (`app-icon.sh`) and App Store
  screenshots; `app-header.sh` draws the
  product page header.
- New apps: "Use this template", then
  Claude runs `scripts/setup-app.sh`;
  `docs/NEW-APP.md` has the steps, GitHub
  settings and TestFlight included. After
  recording snapshots, CI comments with
  the new run's link (the "Approve and
  run" box GitHub shows for the bot's
  push is a duplicate).
