import Foundation
import UserNotifications

/// The daily reminder: on or off, and its
/// time as minutes after midnight. Kept in
/// UserDefaults (see `SettingsView`).
struct Reminder: Equatable {
  /// UserDefaults keys.
  static let onKey = "reminderOn"
  static let minutesKey = "reminderMinutes"
  /// 9:00.
  static let defaultMinutes = 540

  var isOn: Bool
  var minutes: Int

  /// What to schedule: one daily
  /// notification, or none.
  var requests: [UNNotificationRequest] {
    guard isOn else {
      return []
    }
    return [
      .daily(
        id: "daily",
        title: String(
          localized: "Daily reminder"
        ),
        body: String(localized: """
          Time to check your items.
          """),
        hour: minutes / 60,
        minute: minutes % 60
      ),
    ]
  }

  /// Asks for permission when on, then
  /// schedules (or clears) the reminder.
  @MainActor
  func apply(
    to notifier: any Notifier
  ) async {
    if isOn {
      await notifier.ask()
    }
    notifier.replace(with: requests)
  }

  /// `minutes` on `day` as a date, for a
  /// time picker.
  static func date(
    minutes: Int,
    on day: Date,
    in cal: Calendar = .current
  ) -> Date {
    let start = cal.startOfDay(for: day)
    let seconds = TimeInterval(minutes * 60)
    return start.addingTimeInterval(seconds)
  }

  /// `date`'s time as minutes after
  /// midnight.
  static func minutes(
    of date: Date,
    in cal: Calendar = .current
  ) -> Int {
    let parts = cal.dateComponents(
      [.hour, .minute], from: date
    )
    return (parts.hour ?? 0) * 60
      + (parts.minute ?? 0)
  }
}
