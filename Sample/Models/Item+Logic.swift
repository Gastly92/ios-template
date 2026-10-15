import Foundation

extension Item {
  /// A new item, added at `date`.
  static func fresh(at date: Date) -> Item {
    Item(
      title: String(localized: "New item"),
      created: date
    )
  }

  /// How many items there are, e.g. "3
  /// items".
  static func count(_ count: Int) -> String {
    String(localized: "\(count) items")
  }
}
