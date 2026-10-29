// swift-tools-version: 6.0
// Test-only libraries, kept in a package so
// Dependabot can see and update them (it
// can't read XcodeGen's project.yml).
// Pinned exactly: a new version can change
// how snapshots render, so updates come as
// PRs that CI tests.
import PackageDescription

let package = Package(
  name: "TestSupport",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "TestSupport",
      targets: ["TestSupport"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-snapshot-testing",
      exact: "1.19.7"
    ),
  ],
  targets: [
    .target(
      name: "TestSupport",
      dependencies: [
        .product(
          name: "SnapshotTesting",
          package: "swift-snapshot-testing"
        ),
      ]
    ),
  ]
)
