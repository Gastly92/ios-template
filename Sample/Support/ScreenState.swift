import Foundation

/// What each screen state needs before it's
/// shown, for UI and snapshot tests.
extension ScreenID {
  /// Screens shown with the sample items;
  /// the rest show an empty app.
  var isSeeded: Bool {
    switch self {
    case .items, .item:
      true
    default:
      false
    }
  }

  /// Sets `defaults` up for this screen: the
  /// reminder on for `settingsOn`, off
  /// otherwise.
  func prepare(_ defaults: UserDefaults) {
    let isOn = self == .settingsOn
    defaults.set(
      isOn, forKey: Reminder.onKey
    )
  }
}
