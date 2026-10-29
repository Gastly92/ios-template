import SwiftData
import SwiftUI

/// The items, oldest first: + adds one, a
/// tap opens one, and a long-press offers
/// Delete. The gear opens Settings.
struct ItemListView: View {
  @Environment(\.modelContext)
  private var context
  @Environment(\.now)
  private var now
  @Query(sort: \Item.created)
  private var items: [Item]

  let notifier: any Notifier
  let defaults: UserDefaults

  init(
    notifier: any Notifier,
    defaults: UserDefaults
  ) {
    self.notifier = notifier
    self.defaults = defaults
  }

  var body: some View {
    List {
      Section {
        ForEach(items) { item in
          row(item)
        }
      } footer: {
        Text(Item.count(items.count))
      }
    }
    .overlay {
      if items.isEmpty {
        ContentUnavailableView(
          "No items yet",
          systemImage: "tray",
          description: Text(
            "Tap + to add one."
          )
        )
      }
    }
    .navigationTitle("Items")
    .navigationDestination(for: Item.self) {
      ItemView(item: $0)
    }
    .toolbar { toolbar }
  }

  private func row(
    _ item: Item
  ) -> some View {
    NavigationLink(value: item) {
      Text(item.title)
    }
    .contextMenu {
      Button(
        "Delete",
        systemImage: "trash",
        role: .destructive
      ) {
        context.delete(item)
      }
    }
  }

  @ToolbarContentBuilder
  private var toolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      NavigationLink {
        SettingsView(
          notifier: notifier,
          defaults: defaults
        )
      } label: {
        Label(
          "Settings",
          systemImage: "gear"
        )
      }
    }
    ToolbarItem(placement: .primaryAction) {
      Button("Add", systemImage: "plus") {
        context.insert(Item.fresh(at: now))
      }
    }
  }
}
