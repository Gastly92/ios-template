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
    save(app, as: "after-flip")
    app.bar("Settings").tap()
    save(app, as: "after-tap")
    await fulfillment(
      of: [allowed],
      timeout: 10
    )
    let wheel = app.pickerWheels.firstMatch
    XCTAssertTrue(wheel.appears())
  }

  /// For now, while the iOS 27 prompt is
  /// looked into: saves the screen where CI
  /// uploads `snapshot-diffs`, and logs
  /// what SpringBoard shows.
  @MainActor
  private func save(
    _ app: App,
    as name: String
  ) {
    let folder = URL(filePath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appending(path: "build")
      .appending(path: "snapshot-diffs")
    try? FileManager.default
      .createDirectory(
        at: folder,
        withIntermediateDirectories: true
      )
    let png = XCUIScreen.main.screenshot()
      .pngRepresentation
    let file = folder
      .appending(path: "\(name).png")
    try? png.write(to: file)
    let board = App(
      bundleIdentifier:
        "com.apple.springboard"
    )
    print(name, board.debugDescription)
    print(name, app.debugDescription)
  }
}
