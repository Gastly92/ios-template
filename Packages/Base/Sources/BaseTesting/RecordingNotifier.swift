import Base
import UserNotifications

/// Unit tests: a `Notifier` that remembers
/// what the app asked for.
@MainActor
public final class RecordingNotifier:
  Notifier {
  /// How many times the app asked to show
  /// notifications.
  public private(set) var asks = 0
  /// The last set of notifications the app
  /// scheduled.
  public private(set) var scheduled:
    [UNNotificationRequest] = []

  /// A notifier with nothing recorded yet.
  public init() {
    // Nothing recorded yet.
  }

  public func ask() {
    asks += 1
  }

  public func replace(
    with requests: [UNNotificationRequest]
  ) {
    scheduled = requests
  }
}
