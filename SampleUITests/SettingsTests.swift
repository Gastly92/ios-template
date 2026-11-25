import XCTest

final class SettingsTests: XCTestCase {
  /// The switch itself, inside the
  /// labelled row (a tap on the label
  /// doesn't flip it, and the row's right
  /// end sat only half a point inside the
  /// switch on iOS 27).
  @MainActor
  private func flip(_ app: App) {
    app.switches["Daily reminder"]
      .switches.firstMatch
      .tap()
  }

  @MainActor
  func testReminderTimeShowsWhenOn() {
    let app = App.start(
      screen: .settings
    )
    let wheel = app.pickerWheels.firstMatch
    XCTAssertFalse(wheel.exists)
    flip(app)
    XCTAssertTrue(wheel.appears())
    wheel.adjust(toPickerWheelValue: "10")
  }
}
