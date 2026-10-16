import UserNotifications

/// Where an app's notifications go: the
/// phone's notification center, or a
/// stand-in in tests. Apps take one in (see
/// the sample's `AppLaunch`) so UI tests
/// never see the permission prompt.
@MainActor
public protocol Notifier: Sendable {
  /// Asks to show notifications. iOS shows
  /// its prompt only the first time.
  func ask() async
  /// Replaces every pending notification
  /// with `requests`.
  func replace(
    with requests: [UNNotificationRequest]
  )
}

/// The phone's notification center.
public struct PhoneNotifier: Notifier {
  /// The phone's notification center.
  public init() {
    // Nothing to set up.
  }

  public func ask() async {
    let hub = UNUserNotificationCenter
      .current()
    _ = try? await hub.requestAuthorization(
      options: [.alert, .sound]
    )
  }

  public func replace(
    with requests: [UNNotificationRequest]
  ) {
    let hub = UNUserNotificationCenter
      .current()
    hub
      .removeAllPendingNotificationRequests()
    for request in requests {
      hub.add(request)
    }
  }
}

/// UI tests: no permission prompt, and
/// nothing scheduled.
public struct SilentNotifier: Notifier {
  /// A notifier that does nothing.
  public init() {
    // Nothing to set up.
  }

  public func ask() {
    // Never prompts.
  }

  public func replace(
    with _: [UNNotificationRequest]
  ) {
    // Schedules nothing.
  }
}

public extension UNNotificationRequest {
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
