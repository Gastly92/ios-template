import Base
import Foundation
import SwiftData

/// What the app does at launch: read the
/// launch arguments, open the data store,
/// and set UI tests up. Kept out of the
/// `App` so it can be unit tested.
@MainActor
struct AppLaunch {
  /// The UserDefaults suite UI tests use, so
  /// every run starts clean.
  static let testSuite = "uiTesting"

  let isUITesting: Bool
  /// The screen to start on: the item list,
  /// or in UI tests the one given with
  /// `-showScreen <id>`.
  let screen: ScreenID
  /// The opened store, or the error that
  /// stopped it from opening.
  let store:
    Result<ModelContainer, any Error>
  /// Where reminders go. UI tests get none
  /// (no permission prompt), unless they
  /// launch with `-notifications`.
  let notifier: any Notifier
  /// Where settings are kept.
  let defaults: UserDefaults

  /// Opens the store, in memory or on disk.
  typealias Opener = (_ inMemory: Bool)
    throws -> ModelContainer

  init(
    arguments args: [String],
    open: Opener = AppStore.open(inMemory:)
  ) {
    let testing = args.contains("-uiTesting")
    isUITesting = testing
    let real = !testing
      || args.contains("-notifications")
    if real {
      notifier = PhoneNotifier()
    } else {
      notifier = SilentNotifier()
    }
    let id = args
      .drop { $0 != "-showScreen" }
      .dropFirst()
      .first
    let shown = testing
      ? id.flatMap(ScreenID.init(rawValue:))
      : nil
    screen = shown ?? .items
    defaults = testing
      ? Self.cleanDefaults() : .standard
    if shown == .storeError {
      // The store-error screen opens through
      // the real failure path (a full disk).
      store = .failure(
        CocoaError(.fileWriteOutOfSpace)
      )
    } else {
      store = Result { try open(testing) }
    }
    guard testing else {
      return
    }
    screen.prepare(defaults)
    let flag = "-seedSampleData"
    let seed = args.contains(flag)
      || screen.isSeeded
    guard seed,
      case .success(let container) = store
    else { return }
    SampleData.insert(
      into: container.mainContext
    )
  }

  /// UI tests' settings, emptied.
  private static func cleanDefaults()
    -> UserDefaults {
    let suite = testSuite
    let clean = UserDefaults(
      suiteName: suite
    ) ?? .standard
    clean.removePersistentDomain(
      forName: suite
    )
    return clean
  }
}
