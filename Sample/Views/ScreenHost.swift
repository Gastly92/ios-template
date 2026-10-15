import Base
import SwiftData
import SwiftUI

/// Shows one screen (`ScreenID`): where the
/// app starts, and each screen state UI and
/// snapshot tests open directly.
struct ScreenHost: View {
  /// What the store-error screen shows in
  /// snapshots (UI tests open it through
  /// the real failure, in `AppLaunch`).
  private static let error =
    CocoaError(.fileWriteOutOfSpace)
      .localizedDescription

  let screen: ScreenID
  let notifier: any Notifier
  let defaults: UserDefaults

  init(
    screen: ScreenID,
    notifier: any Notifier,
    defaults: UserDefaults
  ) {
    self.screen = screen
    self.notifier = notifier
    self.defaults = defaults
  }

  var body: some View {
    switch screen {
    case .items, .itemsEmpty:
      NavigationStack {
        ItemListView(
          notifier: notifier,
          defaults: defaults
        )
      }
    case .item:
      NavigationStack {
        FirstItem()
      }
    case .settings, .settingsOn:
      NavigationStack {
        SettingsView(
          notifier: notifier,
          defaults: defaults
        )
      }
    case .storeError:
      StoreErrorView(details: Self.error)
    }
  }
}

/// The first sample item's screen.
private struct FirstItem: View {
  @Query(sort: \Item.created)
  private var items: [Item]

  var body: some View {
    ForEach(items.prefix(1)) {
      ItemView(item: $0)
    }
  }
}
