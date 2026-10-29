@testable import Sample
import UserNotifications

/// A `Notifier` that remembers what the app
/// asked for, to check what's scheduled.
@MainActor
final class RecordingNotifier: Notifier {
  /// How many times the app asked to show
  /// notifications.
  private(set) var asks = 0
  /// The last set of notifications the app
  /// scheduled.
  private(set) var scheduled:
    [UNNotificationRequest] = []

  func ask() {
    asks += 1
  }

  func replace(
    with requests: [UNNotificationRequest]
  ) {
    scheduled = requests
  }
}
