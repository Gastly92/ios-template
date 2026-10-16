import Base
@testable import Sample
import SwiftData
import SwiftUI
import XCTest

/// Screens for snapshot and App Store tests:
/// each as `ScreenHost` shows it, set up as
/// in UI tests, on a fixed day.
@MainActor
enum TestScreens {
  /// Noon, Jan 15 2026, UTC, so dates on
  /// screen never change.
  static let now = Date(
    timeIntervalSince1970: 1_768_478_400
  )

  /// Every screen's store, kept for the
  /// whole run: SwiftUI keeps a drawn
  /// screen's @Query listening, and one
  /// whose store was freed crashes on the
  /// next save.
  private static var stores: [ModelContainer]
    = []

  /// `screen`, with the sample items where
  /// it needs them.
  static func page(
    _ screen: ScreenID
  ) throws -> some View {
    let store = try AppStore.open(
      inMemory: true
    )
    stores.append(store)
    if screen.isSeeded {
      SeedData.insert(
        into: store.mainContext,
        now: now
      )
    }
    let suite = "snapshot.\(screen.rawValue)"
    let defaults = try XCTUnwrap(
      UserDefaults(suiteName: suite)
    )
    defaults.removePersistentDomain(
      forName: suite
    )
    screen.prepare(defaults)
    return ScreenHost(
      screen: screen,
      notifier: SilentNotifier(),
      defaults: defaults
    )
    .modelContainer(store)
    .environment(\.now, now)
    .transaction { $0.animation = nil }
  }
}
