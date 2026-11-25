import XCTest

final class SettingsTests: XCTestCase {
  /// The switch, tapped at its right end
  /// (a tap on the label doesn't flip it).
  @MainActor
  private func flip(_ app: App) {
    app.switches["Daily reminder"]
      .coordinate(
        withNormalizedOffset: CGVector(
          dx: 0.95, dy: 0.5
        )
      )
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
