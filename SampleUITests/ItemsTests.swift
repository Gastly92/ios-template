import BaseTesting
import XCTest

final class ItemsTests: XCTestCase {
  /// The list, with the sample items.
  @MainActor
  private func list() -> App {
    App.start(screen: ScreenID.items)
  }

  @MainActor
  func testAddsAnItem() {
    let app = App.start(
      screen: ScreenID.itemsEmpty
    )
    app.button("Add").tap()
    let added = app.button("New item")
    XCTAssertTrue(added.appears())
    let count = app.text("1 item")
    XCTAssertTrue(count.appears())
  }

  @MainActor
  func testOpensAnItem() {
    let app = list()
    app.button("Groceries").tap()
    let bar = app.bar("Groceries")
    XCTAssertTrue(bar.appears())
  }

  @MainActor
  func testOpensSettings() {
    let app = App.start(seeded: true)
    app.button("Settings").tap()
    let bar = app.bar("Settings")
    XCTAssertTrue(bar.appears())
  }

  @MainActor
  func testLongPressDeletes() {
    let app = list()
    let row = app.button("Groceries")
    app.menuItem(
      "Delete",
      on: row,
      ifTapped: app.pushed("Groceries")
    )
    .tap()
    XCTAssertTrue(row.disappears())
  }

  /// Taps first on purpose, so the path for
  /// a long-press read as a tap (see
  /// `menuItem`) runs every time.
  @MainActor
  func testLongPressAfterATap() {
    let app = list()
    let item = app.menuItem(
      "Delete",
      on: app.button("Groceries"),
      ifTapped: app.pushed("Groceries")
    ) { $0.tap() }
    XCTAssertTrue(item.exists)
  }
}
