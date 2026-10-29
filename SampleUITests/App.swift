import XCTest

/// The app under test.
typealias App = XCUIApplication

extension XCUIApplication {
  /// Launches the app for a UI test with
  /// `-uiTesting` (the app turns off
  /// animations), and `-seedData` when
  /// `seeded`.
  @MainActor
  static func start(
    seeded: Bool = false,
    arguments: [String] = []
  ) -> XCUIApplication {
    let app = XCUIApplication()
    let seed = seeded
      ? ["-seedData"] : []
    app.launchArguments =
      ["-uiTesting"] + seed + arguments
    app.launch()
    return app
  }

  /// Launches straight into one screen
  /// (`-showScreen <id>`; see the app's
  /// `ScreenID` and `ScreenHost`).
  @MainActor
  static func start(
    screen: ScreenID,
    arguments: [String] = []
  ) -> XCUIApplication {
    let show = [
      "-showScreen", screen.rawValue,
    ]
    return start(arguments: show + arguments)
  }

  /// A static text, by label or identifier.
  @MainActor
  func text(_ id: String) -> XCUIElement {
    staticTexts[id]
  }

  /// A button, by label or identifier.
  @MainActor
  func button(_ id: String) -> XCUIElement {
    buttons[id]
  }

  /// A navigation bar, by title.
  @MainActor
  func bar(_ id: String) -> XCUIElement {
    navigationBars[id]
  }
}

extension XCUIElement {
  /// Waits up to `seconds` for the element
  /// to exist.
  @MainActor
  func appears(
    within seconds: TimeInterval = 5
  ) -> Bool {
    waitForExistence(timeout: seconds)
  }

  /// Waits up to `seconds` for the element
  /// to go away.
  @MainActor
  func disappears(
    within seconds: TimeInterval = 5
  ) -> Bool {
    waitForNonExistence(timeout: seconds)
  }
}
