import BaseTesting
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
      screen: ScreenID.settings
    )
    let wheel = app.pickerWheels.firstMatch
    XCTAssertFalse(wheel.exists)
    flip(app)
    XCTAssertTrue(wheel.appears())
    wheel.adjust(toPickerWheelValue: "10")
  }

  /// With the phone's notification center
  /// (`-notifications`), turning the
  /// reminder on asks for permission. CI's
  /// simulators are new, so it's always the
  /// first time. Other UI tests never see
  /// the prompt.
  @MainActor
  func testAsksForPermission() {
    let app = App.start(
      screen: ScreenID.settings,
      arguments: ["-notifications"]
    )
    flip(app)
    let springboard = App(
      bundleIdentifier:
        "com.apple.springboard"
    )
    let allow = springboard.buttons["Allow"]
    XCTAssertTrue(allow.appears(within: 10))
    allow.tap()
    XCTAssertTrue(allow.disappears())
  }
}
