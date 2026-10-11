@testable import Sample
import XCTest

final class TallyTests: XCTestCase {
  func testAddAndReset() {
    var tally = Tally()
    tally.add()
    tally.add()
    XCTAssertEqual(tally.count, 2)
    tally.reset()
    XCTAssertEqual(tally.count, 0)
  }

  func testSummaryUsesPlurals() {
    XCTAssertEqual(
      Tally(count: 1).summary, "1 tap"
    )
    XCTAssertEqual(
      Tally(count: 3).summary, "3 taps"
    )
  }
}
