import Foundation
import SwiftData

/// Items for tests and screenshots, as if
/// the user had typed them.
enum SeedData {
  static let titles = [
    "Groceries", "Books", "Ideas",
  ]

  /// Adds the sample items, one a day up to
  /// `now`.
  static func insert(
    into context: ModelContext,
    now: Date = .now
  ) {
    let day: TimeInterval = 86_400
    let all = titles.enumerated()
    for (index, title) in all {
      let back = titles.count - index
      let created = now.addingTimeInterval(
        -day * Double(back)
      )
      context.insert(
        Item(title: title, created: created)
      )
    }
  }
}
