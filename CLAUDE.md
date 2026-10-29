# CLAUDE.md

<!-- template -->
This repo is ios-template: the starting
point for SwiftUI iPhone apps. A new app
is a copy ("Use this template") that
`.github/scripts/setup-app.sh` renames;
after that the app owns every file, and
nothing links it back here. README.md
explains the layout.

If this repo isn't gastly92/ios-template
itself but a fresh copy (the session start
hook says so), set it up first: follow
"Setting up a new repo (for Claude)" in
docs/NEW-APP.md.

In the template itself, keep `Sample`
general enough to build any app on, and
using every piece below, so this repo's
CI tests them all. A fix made in an app
that every app needs is ported here by
hand (and to other apps when asked).
`setup-app.sh` removes this section.
<!-- /template -->
Sample: a SwiftUI iPhone app, set up for
developing entirely from an iPhone with
Claude Code and the GitHub app, never a
desktop or Mac. Everything that needs a
Mac (building, testing, signing,
uploading) runs in CI.

## This app
- What it is: (fill in)
- Bundle ID `com.gastly92.sample`.

## Building
- This container is Linux: nothing
  Swift/Xcode builds locally. CI is the
  compiler.
- `.github/workflows/ios-build.yml` runs
  on every PR and push to `main` (macOS
  runner). It generates the project and
  builds the tests once, then runs them in
  two shards on separate runners in
  parallel (`.github/scripts/run-tests.sh`;
  `main`, and `localization` for
  `LocalizationTests` alone), and a
  `Coverage` job merges the shards'
  results. A Release device build runs
  alongside. The CI summary shows how long
  building and each shard took. Docs-only
  PRs (`*.md`, `docs/`, `site/`) skip the
  macOS jobs. `CI Gate` is the single
  pass/fail check for a PR; the repo's
  `main` ruleset requires it (see
  `docs/NEW-APP.md`), so keep its name.
- Tests: `SampleTests/` (unit tests for
  logic in `Sample/Models/`) and
  `SampleUITests/` (XCTest UI tests that
  launch the app and check the screen).
  Both run in the scheme's test action.
- Screens: every full screen is a view in
  `Sample/Views/Screens/` (one per file;
  pieces of screens go in
  `Views/Components/`). Each screen and
  screen state has a case in `ScreenID`
  (`Sample/Support/`, also compiled into
  the UI tests) and is shown by
  `Sample/Views/ScreenHost.swift`, which
  UI tests open directly with
  `-showScreen <id>`. CI's `Screen list`
  job fails if a screen in
  `Views/Screens/` isn't in `ScreenHost`.
  The Coverage job's `Screen list gate`
  (`unpictured.sh`) fails on view code no
  ScreenID draws (from the localization
  shard's coverage), so every state gets a
  snapshot. Lines that are never drawn
  (what a tap does, a sheet's contents) go
  in `.github/unpictured.txt` with why.
- Accessibility: use system colors and
  text styles (or `@ScaledMetric` for big
  custom sizes) so text scales and both
  light and dark mode work; the
  `fixed_font_size` lint rule flags fixed
  sizes. Large text snapshots show every
  screen scaled. Check on the phone too
  before a release.
- All user-facing text must be
  translatable:
  - In views, pass literals to `Text`,
    `Label`, `Button`, etc. Helper
    parameters that reach `Text` are
    `LocalizedStringKey`, not `String`.
    Never join text with `+` (one literal,
    or a `"""` literal with `\` line
    breaks).
  - Text built in `Models/` or `Support/`
    uses `String(localized:)`, as whole
    sentences (no gluing words together).
    A SwiftLint rule flags plain sentences
    there.
  - Words that change with a number ("1
    day" / "2 days") get plural forms in
    `Sample/Localizable.xcstrings`; edit
    its JSON by hand (no Xcode here).
  - CI's `String catalog` job
    (`check-strings.py`) fails on catalog
    keys no Swift string uses any more;
    delete them with the code.
  - `LocalizationTests` runs every
    `ScreenID` in a pseudo-language that
    brackets translatable text, and fails
    on unbracketed text
    (`LocalizationCheck`; tell it which
    system text to let through).
- SwiftLint runs in CI with `--strict`
  (warnings fail). Config:
  `.swiftlint.yml`. Every opt-in rule is
  on; the few turned off each say why
  there. When two rules disagree, keep the
  one that makes code shorter. No
  `swiftlint:disable` comments in code:
  fix the cause (a flagged line usually
  has a cleaner form), or turn the rule
  off in `.swiftlint.yml` with a reason.
  Run `.github/scripts/swiftlint.sh`
  before pushing Swift changes: CI's
  SwiftLint job runs the same script, in
  Docker with the version pinned in
  `.github/swiftlint/Dockerfile` (the
  session start hook prepares it).
- Lines max 45 chars, so a diff line fits
  a phone in portrait without wrapping.
  This covers docs, YAML and scripts too:
  CI's `Line length` job runs
  `check-lines.py` (it skips URLs, single
  unbreakable words, Markdown tables and
  code blocks, and `uses:` lines). Indent
  with 2 spaces. To fit:
  - Prefer short, clear names; a long line
    often means a name could be shorter.
  - Pull deeply nested view code into a
    small helper view or property, but
    only where nesting is what pushes lines
    over.
  - Use the helpers: `.testID(_:)`,
    `.fullWidth(_:)`, `.wrapsText()`
    (`Views/Components/ViewHelpers.swift`);
    in UI tests `App.start`,
    `app.text/button/bar(_:)`,
    `app.menuItem(_:on:ifTapped:)`
    (long-press; see below),
    `element.appears()`.
  - Long text uses a `"""` literal with
    `\` line breaks (one key, still one
    sentence).
  - Otherwise wrap: one argument per line
    is fine.
- Wrapped Swift lines go in one level (2
  spaces), never aligned by hand:
  SwiftLint's `indentation_width` rule
  checks it.
- Compiler warnings are errors, and every
  target builds in Swift 6 language mode,
  so data races are compile errors. The
  `unchecked_concurrency` lint rule bans
  the ways around that check
  (`@unchecked Sendable`,
  `nonisolated(unsafe)`,
  `@preconcurrency`).
- Coverage gate (`coverage.sh`): every line
  of the app must run in tests (unit,
  snapshot and UI tests all count); the
  log names each untested function. Keep
  decisions out of views: put them in
  `Models/` or `Support/` and unit test
  them. Pass in outside pieces (store,
  clock, notifications) so tests can fake
  them. Every button and branch in a view
  needs a UI test or snapshot that
  reaches it; code nothing can reach gets
  deleted. A view using Swift's automatic
  initializer shows its private property
  defaults as untested; give it an
  explicit `init`.
- UI tests launch the app with
  `App.start`, which passes `-uiTesting`;
  the app then turns off UIKit animations,
  so a long-press never lands on a screen
  still sliding in (it turns into a tap).
  No retries or longer waits in UI tests,
  with one exception: CI's free runners (3
  cores, no GPU) stall now and then, and a
  long-press held during a stall reaches
  the app as a tap. `menuItem` presses
  again only on that sign (menu missing
  and the tap's own screen open, given by
  `ifTapped`, e.g. `app.pushed(title)`),
  after closing it, up to twice, and logs
  "Long-press read as a tap" in the CI log
  each time. Any other miss fails. 100%
  coverage stays; retries are allowed only
  like this one: tied to a detected stall
  sign, never blind.
  Likewise `run-tests.sh` runs a shard
  once more only when the UI test runner
  failed to start and no UI test ran, or
  the simulator dropped out before any
  test ran; it adds a warning and a
  summary line. One UI test taps first on
  purpose, so the stall path runs every
  time.
- Read many elements in one accessibility
  snapshot (`app.snapshot()`), not
  element by element: hundreds of separate
  queries a screen timed out when a runner
  stalled.
- Snapshot tests take a picture of every
  `ScreenID` with `Looks.check` in light,
  dark and large text (on a screen three
  phones tall, so long screens show in
  full), on a fixed day (`\.now`; views
  read "today" from it, not `Date()`).
  Images live in
  `SampleTests/__Snapshots__/`. CI records
  missing ones and commits them to the PR
  branch (pull before pushing again),
  pushing with the snapshot app's token so
  CI runs on the new commit
  (`docs/SNAPSHOT-APP.md`). Without the
  app's secrets (e.g. Dependabot PRs) it
  pushes with CI's own token and starts
  the run itself; GitHub then also holds a
  duplicate behind "Approve and run"
  (`action_required` in `actions_list`),
  which needs no approval. Look at the
  images, then push the next real change.
  Deleting images re-records them too.
  After an intended visual change, add
  the `record-snapshots` label to the PR
  to record all of them again; a failed
  comparison uploads `snapshot-diffs`.
  Re-record after Xcode, iOS or snapshot
  library updates.
- Test-only Swift packages are declared in
  `Packages/TestSupport/Package.swift`
  (pinned with `exact:`), which tests
  `import TestSupport` to get. Dependabot
  opens weekly PRs for them, and for the
  GitHub Actions and SwiftLint versions:
  check CI and summarize what changed
  (release notes); the user merges. If
  snapshots change, re-record them before
  merging.
- CI's `Workflows & scripts` job runs
  actionlint on `.github/workflows/` and
  ShellCheck on every `*.sh`. The session
  start hook installs both (versions in
  `.github/scripts/checkers.txt`), so run
  them before pushing workflow or script
  changes.
- Periphery (CI step after the build)
  fails on unused code. Delete it rather
  than ignore it; no `periphery:ignore`
  comments. For a real false positive,
  restructure the code or ask the user.
- Saved data (SwiftData) must never be
  lost. The models are in
  `Models/Schema.swift` (`SchemaV1`, used
  through aliases such as `Item`), frozen
  from the first release on: never edit a
  released schema. To change a stored
  model, follow the steps in that file: a
  new schema version, a migration stage,
  and a test that the previous version's
  data opens (`StoreTests`). `AppStore`
  opens the store (in memory for UI and
  snapshot tests); if it can't,
  `StoreErrorView` shows instead.
- Seed data (`SeedData`) fills the
  screens that need it in UI tests,
  snapshots and App Store screenshots
  (`ScreenID.isSeeded`, or launching with
  `-seedData`). Its text stands for
  what a user typed, so
  `LocalizationTests` lets it through.
- Notifications go through a `Notifier`
  that `AppLaunch` passes in: the phone's
  notification center normally,
  `SilentNotifier` in UI tests (no
  permission prompt, nothing scheduled),
  and `RecordingNotifier` in unit tests to
  check what's scheduled. One UI test
  launches with `-notifications` to see
  the real permission prompt. What to
  schedule is decided in `Models/` (e.g.
  `Reminder`) and unit tested.
- Settings use `@AppStorage` with the
  `UserDefaults` `AppLaunch` passes in (an
  emptied suite in UI tests, set up per
  screen by `ScreenID.prepare`).
- The Xcode project is generated from
  `project.yml` by XcodeGen. Never add a
  `.xcodeproj`; put new source files under
  `Sample/` (picked up automatically) and
  build settings in `project.yml`.
  Info.plist is generated from
  `INFOPLIST_KEY_*` settings there. Add
  permission strings the same way.
- After pushing, check CI with the GitHub
  MCP tools (`actions_list`,
  `get_job_logs`) and fix failures before
  calling the work done. Re-read Swift
  changes carefully first, since each CI
  round trip takes a few minutes.

## Shipping to the phone (TestFlight)
- `.github/workflows/testflight.yml`
  (manual, `workflow_dispatch`) archives,
  cloud-signs with an App Store Connect
  API key, uploads to TestFlight, and tags
  the commit (e.g. `v0.4.6-build12`).
- One-time setup (bundle ID, App Store
  Connect app, an API key, and the repo
  secrets `APPLE_TEAM_ID`,
  `ASC_ISSUER_ID`, `ASC_KEY_ID` and
  `ASC_KEY_P8`): the steps are in
  `docs/NEW-APP.md`; walk the user through
  them. Never print, log, or ask for the
  secrets.
- When asked to ship or test on the
  phone, trigger it with
  `actions_run_trigger` (`run_workflow`,
  `workflow_id: testflight.yml`,
  `ref: main`). Verify the log shows
  "Upload succeeded". The build shows in
  TestFlight about 5–15 min later.
- Version scheme (`MARKETING_VERSION` in
  `project.yml`; Apple allows only three
  numbers): before 1.0, `0.<step>.0` when
  a planned step lands, patch for fixes
  between steps, bumped in the same PR.
  1.0.0 is the first App Store release;
  after that, patch for bug fixes, minor
  for new features. Build number =
  workflow run number (automatic).
- iOS 17+, iPhone only, portrait.
  `ITSAppUsesNonExemptEncryption` is NO;
  keep it that way unless adding real
  encryption.
- Capabilities that need entitlements
  (HealthKit, push, iCloud, App Groups)
  need extra signing setup: a
  `.entitlements` file via `project.yml`,
  the capability enabled on the App ID,
  and likely changes to the TestFlight
  workflow (it archives with
  `CODE_SIGNING_ALLOWED=NO`).
- Keep the privacy manifest
  (`Sample/PrivacyInfo.xcprivacy`) and
  the privacy page (`site/privacy.html`)
  true to what the app does: update both
  when adding tracking, collected data, or
  APIs Apple requires a reason for (e.g.
  `UserDefaults` / `@AppStorage`: reason
  `CA92.1`). `PrivacyInfoTests` checks the
  manifest.
- `site/` holds the App Store support and
  privacy pages; `pages.yml` publishes
  them to GitHub Pages on each push to
  `main` that changes them, at
  `https://<owner>.github.io/<repo>/` and
  `.../privacy.html` (the URLs App Store
  Connect asks for). Keep the support page
  true to the app's features.
- App Store screenshots: `AppStoreTests`
  draws them with `AppStoreShots` from the
  same screens as the snapshots, framed
  and captioned, at the sizes App Store
  Connect takes; the images to upload are
  in
  `SampleTests/__Snapshots__/AppStoreTests/`.
  Update the shots and captions when a
  pictured screen or a listed feature
  changes.
- The app icon comes from
  `.github/scripts/app-icon.sh <mark>
  <color> <color>` (a letter or two on a
  gradient, in light, dark and tinted),
  and the product page header from
  `.github/scripts/app-header.sh`. Both
  run in the cloud session (ImageMagick).
  Use the same colors in `AppStoreTests`.
