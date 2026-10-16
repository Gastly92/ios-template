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
    .library(
      name: "Base",
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
    .target(
      name: "BaseTesting",
      dependencies: ["Base"]
    ),
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
