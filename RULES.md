# Shared rules

The rules for every app built on
ios-template. An app's own CLAUDE.md adds
what's specific to it. `<App>` below is the
app's `name:` in `project.yml`; it is also
its scheme and source folder, with
`<App>Tests` and `<App>UITests` beside it.

## Working with the owner
- The owner develops entirely from an
  iPhone via Claude Code; there is no Mac.
- Keep it simple: few steps, few questions.
  Pick sensible defaults and say what you
  chose.
- Explain anything they must do by hand as
  short numbered steps for iPhone Safari.
  App Store Connect's mobile layout can
  hide buttons; "Request Desktop Website"
  or Safari's Find on page helps.

## The template
- Each app pins a template version (a tag,
  e.g. `v1.2.0`) in the `uses:` lines of
  `.github/workflows/build.yml` and
  `testflight.yml`. That one pin covers
  everything shared: CI, scripts,
  SwiftLint rules and version, and the
  Base package. Dependabot opens a PR for
  each new version; CI on that PR shows
  whether the app still passes. Check the
  template's CHANGELOG.md, summarize it,
  and let the owner merge.
- CI and the session start hook check the
  template out into `.template/` (git
  ignores it). Run its scripts from the
  app's root, e.g.
  `.template/scripts/swiftlint.sh`.
- To change something shared, change the
  template (PR there, then a new tag), not
  the app's copy in `.template/`.

## Building
- This container is Linux: nothing
  Swift/Xcode builds locally. CI is the
  compiler.
- `build.yml` runs the template's shared
  CI on every PR and push to `main`
  (macOS runner). It generates the project
  and builds the tests once, then runs
  them in two shards on separate runners
  in parallel (`run-tests.sh`; `main`, and
  `localization` for `LocalizationTests`
  alone), and a `Coverage` job merges the
  shards' results. A Release device build
  runs alongside. The CI summary shows how
  long building and each shard took.
  Docs-only PRs (`*.md`, `docs/`, `site/`)
  skip the macOS jobs. `CI / CI Gate` is
  the single pass/fail check for a PR.
- Tests: `<App>Tests/` (unit tests for
  logic in `<App>/Models/`) and
  `<App>UITests/` (XCTest UI tests that
  launch the app and check the screen).
  Both run in the scheme's test action.
- Screens: every full screen is a view in
  `<App>/Views/Screens/` (one per file;
  pieces of screens go in
  `Views/Components/`). Each screen and
  screen state has a case in `ScreenID`
  (`<App>/Support/`, also compiled into
  the UI tests) and is shown by
  `<App>/Views/ScreenHost.swift`, which
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
    `<App>/Localizable.xcstrings`; edit its
    JSON by hand (no Xcode here).
  - CI's `String catalog` job
    (`check-strings.py`) fails on catalog
    keys no Swift string uses any more;
    delete them with the code.
  - `LocalizationTests` runs every
    `ScreenID` in a pseudo-language that
    brackets translatable text, and fails
    on unbracketed text
    (`LocalizationCheck` in Base; tell it
    which system text to let through).
- SwiftLint runs in CI with `--strict`
  (warnings fail). The shared rules are
  the template's `swiftlint/base.yml`; the
  app's `.swiftlint.yml` names it as
  `parent_config` and lists its folders.
  Every opt-in rule is on; the few turned
  off each say why there. When two rules
  disagree, keep the one that makes code
  shorter. No `swiftlint:disable` comments
  in code: fix the cause (a flagged line
  usually has a cleaner form), or turn the
  rule off in the template's rules with a
  reason. Run
  `.template/scripts/swiftlint.sh` before
  pushing Swift changes: CI's SwiftLint
  job runs the same script, in Docker
  with the version the template pins.
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
  - Use the Base package's helpers:
    `LeadingStack`, `SectionTitle`,
    `.testID(_:)`, `.fullWidth(_:)`,
    `.wrapsText()`, `\.now` (`BaseUI`); in
    UI tests `App.start`,
    `app.text/button/field/bar(_:)`,
    `app.menuItem(_:on:ifTapped:)`
    (long-press; see below),
    `element.appears()` (`BaseTesting`).
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
  so data races are compile errors.
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
- No Thread Sanitizer: Swift 6 mode
  already makes data races compile errors,
  and it slowed every test by 25–30%. The
  `unchecked_concurrency` lint rule bans
  the ways around that check
  (`@unchecked Sendable`,
  `nonisolated(unsafe)`,
  `@preconcurrency`).
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
  each time. Any other miss fails. The
  owner wants 100% coverage kept and
  accepts retries like this one: tied to a
  detected stall sign, never blind.
  Likewise `run-tests.sh` runs a shard
  once more only when the UI test runner
  failed to start and no UI test ran, or
  the simulator dropped out before any
  test ran; it adds a warning and a
  summary line. Each app keeps one UI test
  that taps first on purpose, so the
  stall path runs every time.
- Read many elements in one accessibility
  snapshot (`app.snapshot()`), not
  element by element: hundreds of separate
  queries a screen timed out when a runner
  stalled.
- Snapshot tests take a picture of every
  `ScreenID` with `Looks.check`
  (`BaseSnapshots`) in light, dark and
  large text (on a screen three phones
  tall, so long screens show in full), on
  a fixed day (`\.now`; views read
  "today" from it, not `Date()`). Images
  live in `<App>Tests/__Snapshots__/`. CI
  records missing ones and commits them to
  the PR branch (pull before pushing
  again). A bot push needs approval to
  merge, so look at the images, then push
  the next real change (or the owner
  approves). Deleting images re-records
  them too. After an intended visual
  change, add the `record-snapshots` label
  to the PR to record all of them again; a
  failed comparison uploads
  `snapshot-diffs`. Re-record after Xcode,
  iOS or snapshot library updates.
- CI's `Workflows & scripts` job runs
  actionlint on `.github/workflows/` and
  ShellCheck on every `*.sh`. The session
  start hook installs both (versions in
  the template's `scripts/checkers.txt`),
  so run them before pushing workflow or
  script changes.
- Periphery (CI step after the build)
  fails on unused code. Delete it rather
  than ignore it; no `periphery:ignore`
  comments. For a real false positive,
  restructure the code or ask the owner.
- Stored data must never be lost: version
  stored models (e.g. SwiftData
  `VersionedSchema`) from the first
  release on, never edit a released
  schema, and add a migration and a test
  that the previous version's data opens.
- The Xcode project is generated from
  `project.yml` by XcodeGen. Never add a
  `.xcodeproj`; put new source files under
  `<App>/` (picked up automatically) and
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
  (manual, `workflow_dispatch`) calls the
  template's shared TestFlight workflow:
  it archives, cloud-signs with an App
  Store Connect API key, uploads to
  TestFlight, and tags the commit (e.g.
  `v0.4.6-build12`).
- One-time setup per app: create the app
  in App Store Connect with its bundle ID,
  and add the repo secrets
  `APPLE_TEAM_ID`, `ASC_ISSUER_ID`,
  `ASC_KEY_ID` and `ASC_KEY_P8` (the same
  team API key works for every app).
  Never print, log, or ask for them.
- When the owner asks to ship or test on
  their phone, trigger it with
  `actions_run_trigger` (`run_workflow`,
  `workflow_id: testflight.yml`,
  `ref: main`). Verify the log shows
  "Upload succeeded". The build shows in
  TestFlight about 5–15 min later.
- Version scheme (`MARKETING_VERSION` in
  `project.yml`; Apple allows only three
  numbers): before 1.0, `0.<plan step>.0`
  when a plan step lands, patch for fixes
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
  and likely changes to the shared
  TestFlight workflow (it archives with
  `CODE_SIGNING_ALLOWED=NO`).
- Keep a privacy manifest
  (`PrivacyInfo.xcprivacy`) true to what
  the app does, e.g. `UserDefaults` /
  `@AppStorage` need reason `CA92.1`.
