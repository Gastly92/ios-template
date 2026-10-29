import Base
@testable import Sample
import SwiftData
import XCTest

@MainActor
final class AppLaunchTests: XCTestCase {
  /// An in-memory store, whatever is asked.
  private let memory: AppLaunch.Opener =
    { _ in
      try AppStore.open(inMemory: true)
    }

  private func launch(
    _ args: [String]
  ) -> AppLaunch {
    AppLaunch(arguments: args, open: memory)
  }

  func testNormalLaunch() {
    let normal = launch([])
    XCTAssertFalse(normal.isUITesting)
    XCTAssertEqual(normal.screen, .items)
    // `is` matches only if the app and this
    // test bundle share one copy of Base.
    XCTAssertTrue(
      normal.notifier is PhoneNotifier
    )
    XCTAssertEqual(
      normal.defaults, .standard
    )
  }

  func testUITestsPickAScreen() {
    let shown = launch([
      "-uiTesting",
      "-showScreen",
      "settingsOn",
    ])
    XCTAssertTrue(shown.isUITesting)
    XCTAssertEqual(shown.screen, .settingsOn)
    XCTAssertTrue(
      shown.notifier is SilentNotifier
    )
    let isOn = shown.defaults.bool(
      forKey: Reminder.onKey
    )
    XCTAssertTrue(isOn)
    let unknown = launch([
      "-uiTesting", "-showScreen", "nope",
    ])
    XCTAssertEqual(unknown.screen, .items)
  }

  func testRealNotificationsOnRequest() {
    let real = launch([
      "-uiTesting", "-notifications",
    ])
    XCTAssertTrue(
      real.notifier is PhoneNotifier
    )
  }

  func testSeededScreensGetItems()
    throws {
    let seeded = launch([
      "-uiTesting", "-showScreen", "item",
    ])
    let container = try seeded.store.get()
    let items = try container.mainContext
      .fetch(FetchDescriptor<Item>())
    XCTAssertEqual(
      items.count, SeedData.titles.count
    )
  }

  func testStoreErrorScreenFails() {
    let failed = launch([
      "-uiTesting",
      "-showScreen",
      "storeError",
    ])
    XCTAssertThrowsError(
      try failed.store.get()
    )
  }
}
