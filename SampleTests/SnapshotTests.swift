import BaseSnapshots
@testable import Sample
import XCTest

/// A picture of every screen (`ScreenID`) in
/// each look (see `Looks`), set up by
/// `TestScreens`.
@MainActor
final class SnapshotTests: XCTestCase {
  func testEveryScreen() throws {
    for screen in ScreenID.allCases {
      let page = try TestScreens.page(screen)
      let name = screen.rawValue
      Looks.check(page, named: name)
    }
  }
}
