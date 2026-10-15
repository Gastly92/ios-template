# ios-template

A template for SwiftUI iPhone apps, set up
for developing entirely from an iPhone
with Claude Code and the GitHub app, never
a desktop or Mac. Everything that needs a
Mac runs in CI on GitHub's macOS runners:
building, tests (strict lint, 100%
coverage, snapshot and localization tests
for every screen) and TestFlight upload.

Apps use it as a versioned dependency: each
app pins a tag (e.g. `v1.0.0`), Dependabot
opens a PR when a new one is out, and the
app's CI shows whether it still passes
before it's merged.

## What's here

| Path | What |
|---|---|
| `.github/workflows/ci.yml` | Shared CI, called by each app |
| `.github/workflows/testflight.yml` | Shared TestFlight upload |
| `scripts/` | The scripts CI and sessions run |
| `swiftlint/` | Shared SwiftLint rules and version |
| `.github/workflows/pages.yml` | Shared support pages publishing |
| `Packages/Base` | Shared Swift code: `Base` (view helpers, notifications), `BaseTesting`, `BaseSnapshots` (snapshots, App Store screenshots) |
| `RULES.md` | Rules for every app (and Claude) |
| `Sample*/`, `project.yml`, `site/` | The starter app every new app begins as: saved items, settings with a daily reminder, support pages, privacy manifest, icon and App Store screenshots |
| `scripts/app-icon.sh`, `app-header.sh` | Draw an app's icon and App Store header |
| `CHANGELOG.md` | What each version changed |

## Using it in an app

An app's workflows pin the template:

```yaml
jobs:
  ci:
    uses: gastly92/ios-template/.github/workflows/ci.yml@v1.0.0
```

CI checks the template out at that version
into `.template/`, where the app's
`project.yml` finds the Base package and
its `.swiftlint.yml` finds the shared
rules. The app's session start hook does
the same for Claude Code sessions.

## Starting a new app

Tap **Use this template** on GitHub, start
a Claude Code session on the new repo, and
say "Help me set this repo up using the
template". Details, TestFlight setup
included: [docs/NEW-APP.md](docs/NEW-APP.md).
