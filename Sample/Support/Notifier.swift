import UserNotifications

/// Where the app's notifications go: the
/// phone's notification center, or a
/// stand-in in tests. `AppLaunch` picks one,
/// so UI tests never see the permission
/// prompt.
@MainActor
protocol Notifier: Sendable {
  /// Asks to show notifications. iOS shows
  /// its prompt only the first time.
  func ask() async
  /// Replaces every pending notification
  /// with `requests`.
  func replace(
    with requests: [UNNotificationRequest]
  ) async
}

/// The parts of the phone's notification
/// center `PhoneNotifier` uses, so unit
/// tests can pass a stand-in. (UI tests
/// can't: on iOS 27, XCTest can't see or
/// answer the permission prompt.)
@MainActor
protocol NotificationHub {
  func requestAuthorization(
    options: UNAuthorizationOptions
  ) async throws -> Bool
  func removeAllPendingNotificationRequests()
  func add(
    _ request: UNNotificationRequest
  ) async throws
}

extension UNUserNotificationCenter:
  NotificationHub {}

/// The phone's notification center.
@MainActor
final class PhoneNotifier: Notifier {
  private let hub: any NotificationHub

  init(
    hub: any NotificationHub =
      UNUserNotificationCenter.current()
  ) {
    self.hub = hub
  }

  func ask() async {
    _ = try? await hub.requestAuthorization(
      options: [.alert, .sound]
    )
  }

  func replace(
    with requests: [UNNotificationRequest]
  ) async {
    hub
      .removeAllPendingNotificationRequests()
    for request in requests {
      try? await hub.add(request)
    }
  }
}

/// UI tests: no permission prompt, and
/// nothing scheduled.
struct SilentNotifier: Notifier {
  func ask() {
    // Never prompts.
  }

  func replace(
    with _: [UNNotificationRequest]
  ) {
    // Schedules nothing.
  }
}

extension UNNotificationRequest {
  /// A notification shown every day at
  /// `hour`:`minute`, replacing any earlier
  /// one with the same `id`.
  static func daily(
    id: String,
    title: String,
    body: String,
    hour: Int,
    minute: Int
  ) -> UNNotificationRequest {
    let content =
      UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    let time = DateComponents(
      hour: hour, minute: minute
    )
    let trigger =
      UNCalendarNotificationTrigger(
        dateMatching: time, repeats: true
      )
    return UNNotificationRequest(
      identifier: id,
      content: content,
      trigger: trigger
    )
  }
}
