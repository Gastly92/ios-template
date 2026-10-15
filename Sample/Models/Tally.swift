/// A running count: what the counter
/// screen shows.
struct Tally {
  private(set) var count: Int

  init(count: Int = 0) {
    self.count = count
  }

  /// The count as text, e.g. "3 taps".
  var summary: String {
    String(localized: "\(count) taps")
  }

  mutating func add() {
    count += 1
  }

  mutating func reset() {
    count = 0
  }
}
