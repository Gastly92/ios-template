@testable import Sample
import XCTest

final class ItemTests: XCTestCase {
  func testCountUsesPlurals() {
    XCTAssertEqual(Item.count(1), "1 item")
    XCTAssertEqual(Item.count(3), "3 items")
  }

  func testFreshItem() {
    let date = Date(timeIntervalSince1970: 0)
    let item = Item.fresh(at: date)
    XCTAssertEqual(item.title, "New item")
    XCTAssertEqual(item.created, date)
  }
}
