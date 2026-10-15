import SwiftUI

/// One item: its name and when it was added.
struct ItemView: View {
  private static let format:
    Date.FormatStyle = .dateTime
      .day().month().year()

  let item: Item

  init(item: Item) {
    self.item = item
  }

  var body: some View {
    List {
      LabeledContent("Added") {
        Text(
          item.created,
          format: Self.format
        )
        .testID("itemDate")
      }
    }
    .navigationTitle(item.title)
  }
}
