// swift-tools-version: 6.0
// Code shared by every app: view helpers
// and notifications (Base), test helpers
// (BaseTesting), and snapshot and App
// Store screenshot helpers
// (BaseSnapshots). Apps use it from
// .template/, the template checked out at
// the version they pin. Swift 6 language
// mode, like the apps.
import PackageDescription

let package = Package(
  name: "Base",
  platforms: [.iOS(.v17)],
  products: [
    // Dynamic: the app embeds it once, and
    // its unit tests (run inside the app)
    // use that same copy. Linked
    // statically, the test bundle got a copy
    // of its own: its `\.now` was a key the
    // app's views never read, and `is`
    // checks on Base types never matched.
    .library(
      name: "Base",
      type: .dynamic,
      targets: ["Base"]
    ),
    .library(
      name: "BaseTesting",
      targets: ["BaseTesting"]
    ),
    .library(
      name: "BaseSnapshots",
      targets: ["BaseSnapshots"]
    ),
  ],
  dependencies: [
    // Pinned exactly: a new version can
    // change how snapshots render, so
    // updates come as PRs that CI tests.
    .package(
      url: "https://github.com/pointfreeco/swift-snapshot-testing",
      exact: "1.19.6"
    ),
  ],
  targets: [
    .target(name: "Base"),
    // No Base dependency: that would link a
    // second copy of Base into test
    // bundles.
    .target(name: "BaseTesting"),
    .target(
      name: "BaseSnapshots",
      dependencies: [
        .product(
          name: "SnapshotTesting",
          package: "swift-snapshot-testing"
        ),
      ]
    ),
  ]
)
