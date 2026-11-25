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

  /// With the phone's notification center
  /// (`-notifications`), turning the
  /// reminder on asks for permission. CI's
  /// simulators are new, so it's always the
  /// first time. Other UI tests never see
  /// the prompt.
  /// On iOS 27 SpringBoard no longer shows
  /// the prompt's buttons to a query, so an
  /// interruption monitor answers it: XCTest
  /// calls it when the test next acts on the
  /// app with a system alert in the way.
  @MainActor
  func testAsksForPermission() async {
    let allowed = expectation(
      description: "Allow tapped"
    )
    addUIInterruptionMonitor(
      withDescription: "Notifications"
    ) { alert in
      MainActor.assumeIsolated {
        alert.buttons["Allow"].tap()
      }
      allowed.fulfill()
      return true
    }
    let app = App.start(
      screen: .settings,
      arguments: ["-notifications"]
    )
    flip(app)
    app.bar("Settings").tap()
    await fulfillment(
      of: [allowed],
      timeout: 10
    )
    let wheel = app.pickerWheels.firstMatch
    XCTAssertTrue(wheel.appears())
  }
}
