# ios-template

The shared setup for SwiftUI iPhone apps
built from an iPhone with Claude Code: CI
on GitHub's macOS runners, TestFlight
upload, strict lint and 100% test
coverage, snapshot and localization tests
for every screen.

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
| `Packages/Base` | Shared Swift code: `BaseUI`, `BaseTesting`, `BaseSnapshots` |
| `RULES.md` | Rules for every app (and Claude) |
| `Sample*/`, `project.yml` | A small app that runs all of it |
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

See [docs/NEW-APP.md](docs/NEW-APP.md):
create a repo, ask Claude to set it up from
here, then (when you want it on your phone)
the one-time TestFlight setup.
