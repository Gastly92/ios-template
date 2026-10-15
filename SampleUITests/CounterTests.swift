import BaseTesting
import XCTest

final class CounterTests: XCTestCase {
  @MainActor
  func testAddCounts() {
    let app = App.start()
    let zero = app.button("0 taps")
    XCTAssertTrue(zero.appears())
    app.button("Add").tap()
    let one = app.button("1 tap")
    XCTAssertTrue(one.appears())
  }

  @MainActor
  func testLongPressResets() {
    let app = App.start(
      screen: ScreenID.counted
    )
    app.menuItem(
      "Reset",
      on: app.button("count"),
      ifTapped: app.pushed("Info")
    )
    .tap()
    let zero = app.button("0 taps")
    XCTAssertTrue(zero.appears())
  }

  /// Taps first on purpose, so the path for
  /// a long-press read as a tap (see
  /// `menuItem`) runs every time.
  @MainActor
  func testLongPressAfterATap() {
    let app = App.start(
      screen: ScreenID.counted
    )
    let item = app.menuItem(
      "Reset",
      on: app.button("count"),
      ifTapped: app.pushed("Info")
    ) { $0.tap() }
    XCTAssertTrue(item.exists)
  }
}
