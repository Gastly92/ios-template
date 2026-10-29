import SwiftUI

private struct NowKey: EnvironmentKey {
  static var defaultValue: Date { Date() }
}

extension EnvironmentValues {
  /// The moment screens treat as now (which
  /// day is "today"). Snapshot tests fix it
  /// so dates on screen don't change day to
  /// day. Views read it instead of `Date()`.
  var now: Date {
    get { self[NowKey.self] }
    set { self[NowKey.self] = newValue }
  }
}
