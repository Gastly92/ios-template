import BaseSnapshots
@testable import Sample
import XCTest

/// A picture of every screen (`ScreenID`) in
/// each look (see `Looks`).
@MainActor
final class SnapshotTests: XCTestCase {
  func testEveryScreen() {
    for screen in ScreenID.allCases {
      Looks.check(
        ScreenHost(screen: screen),
        named: screen.rawValue
      )
    }
  }
}
