import UIKit
import XCTest

/// The iOS the committed snapshot images
/// were drawn on, kept in
/// `__Snapshots__/iOS.txt`.
/// iOS draws system controls itself (e.g.
/// how a date picker shows its date), so on
/// another iOS the images can differ for
/// reasons the app didn't cause.
/// CI draws on this iOS (`run-tests.sh`),
/// or on the newest one when recording
/// every image; on any other iOS (the saved
/// one gone from the runners), the snapshot
/// tests fail and say to record again.
enum SnapshotOS {
  private static let file = URL(
    filePath: #filePath
  )
  .deletingLastPathComponent()
  .appending(path: "__Snapshots__/iOS.txt")

  /// Whether this simulator runs the iOS the
  /// images were drawn on; fails the test if
  /// not. Saves it when every image is being
  /// recorded, or when no iOS is saved yet.
  @MainActor
  static func matches() throws -> Bool {
    let now = UIDevice.current.systemVersion
    let mode = ProcessInfo.processInfo
      .environment["SNAPSHOT_TESTING_RECORD"]
    let saved = try? String(
      contentsOf: file, encoding: .utf8
    )
    guard let saved, mode != "all" else {
      try "\(now)\n".write(
        to: file,
        atomically: true,
        encoding: .utf8
      )
      return true
    }
    let drawn = saved.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
    guard drawn == now else {
      XCTFail("""
        The snapshots were drawn on iOS \
        \(drawn), but this simulator runs \
        iOS \(now). Add the \
        record-snapshots label to the PR to \
        record them again.
        """)
      return false
    }
    return true
  }
}
