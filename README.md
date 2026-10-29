# ios-template

A starting point for SwiftUI iPhone apps,
set up for developing entirely from an
iPhone with Claude Code and the GitHub
app, never a desktop or Mac. Everything
that needs a Mac runs in CI on GitHub's
macOS runners: building, tests (strict
lint, 100% coverage, snapshot and
localization tests for every screen) and
TestFlight upload.

An app is a copy: tap **Use this
template**, and Claude renames the sample
to the app. From then on the app owns
every file (CI, scripts, SwiftLint rules,
helpers), so apps can change anything
without affecting each other. A fix worth
sharing is ported by hand.

## What's here

| Path | What |
|---|---|
| `Sample/`, `SampleTests/`, `SampleUITests/` | The starter app: saved items, settings with a daily reminder, the store error screen, and the helpers for views, notifications, UI tests, snapshots and App Store screenshots |
| `project.yml` | The Xcode project (XcodeGen) |
| `.github/workflows/` | CI (`ios-build.yml`), TestFlight upload, support pages publishing |
| `.github/scripts/` | The scripts CI and sessions run, plus the icon and App Store header drawing |
| `.swiftlint.yml`, `.github/swiftlint/` | SwiftLint rules and version |
| `Packages/TestSupport` | Test-only Swift packages (snapshot testing) |
| `site/` | Support and privacy pages |
| `CLAUDE.md` | How the app is built and tested (for Claude, and the user) |
| `docs/NEW-APP.md` | Starting a new app, GitHub settings and TestFlight setup |

## Starting a new app

Tap **Use this template** on GitHub, start
a Claude Code session on the new repo, and
say "Help me set this repo up using the
template". Details, TestFlight setup
included: [docs/NEW-APP.md](docs/NEW-APP.md).
