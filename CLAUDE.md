# CLAUDE.md

ios-template: the shared setup for the
owner's iOS apps (CI, scripts, SwiftLint
rules, TestFlight upload and the Base Swift
package), used by each app as a versioned
dependency. README.md explains the layout.

If this repo isn't gastly92/ios-template
itself but a copy made with "Use this
template", it isn't set up yet: follow
"Setting up a new repo (for Claude)" in
docs/NEW-APP.md first.

The rules every app follows are in
RULES.md; they apply here too (the session
start hook prints them). This file adds
what's specific to the template.

## How apps use it
- An app's `build.yml` and `testflight.yml`
  call `ci.yml` and `testflight.yml` here
  at a pinned tag. Each shared job checks
  out the app, then this repo at the
  workflow's own commit (`job.workflow_*`)
  into `.template/`. The app's
  `project.yml` uses
  `.template/Packages/Base`, and its
  `.swiftlint.yml` names
  `.template/swiftlint/base.yml` as its
  `parent_config`.
- The template is an app too: `Sample/`,
  `SampleTests/` and `SampleUITests/`,
  with `build.yml` calling the local
  `ci.yml` (here `.template/` is this
  repo). Keep the sample using every
  shared piece, so this repo's CI tests
  them all before apps get them.
- `scripts/new-app.sh` starts a new app
  from the sample (see README.md).

## Releasing
- Every change goes through a PR here.
  After it merges, tag `main` with the next
  version and push the tag
  (`git tag v1.2.0 && git push origin
  v1.2.0`); apps get a Dependabot PR.
- Semantic versions: patch for fixes,
  minor for additions, major when an app
  must change something to update (e.g. a
  renamed helper or a new rule that fails
  existing code). Say what to change in
  CHANGELOG.md.
- Add every release to CHANGELOG.md in the
  PR that makes it.
- Never move or delete a released tag:
  apps pin them.
- Dependabot opens weekly PRs for the
  Actions, SwiftLint and Swift package
  versions here. Check CI and summarize
  what changed (release notes); the owner
  reviews and merges them, then tag a
  release.
