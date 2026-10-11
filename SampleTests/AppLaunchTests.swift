@testable import Sample
import XCTest

final class AppLaunchTests: XCTestCase {
  func testStartsOnTheCounter() {
    let launch = AppLaunch(arguments: [])
    XCTAssertFalse(launch.isUITesting)
    XCTAssertEqual(launch.screen, .counter)
  }

  func testUITestsPickAScreen() {
    let launch = AppLaunch(arguments: [
      "-uiTesting", "-showScreen", "info",
    ])
    XCTAssertTrue(launch.isUITesting)
    XCTAssertEqual(launch.screen, .info)
  }

  /// Outside UI tests, and for an unknown
  /// screen, the app starts as usual.
  func testIgnoresOtherScreenRequests() {
    let normal = AppLaunch(arguments: [
      "-showScreen", "info",
    ])
    XCTAssertEqual(normal.screen, .counter)
    let unknown = AppLaunch(arguments: [
      "-uiTesting", "-showScreen", "nope",
    ])
    XCTAssertEqual(unknown.screen, .counter)
  }
}
