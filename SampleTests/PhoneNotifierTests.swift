@testable import Sample
import UserNotifications
import XCTest

/// `PhoneNotifier` against a stand-in for
/// the phone's notification center.
@MainActor
final class PhoneNotifierTests: XCTestCase {
  func testAsksForAlertsAndSounds() async {
    let hub = FakeHub()
    await PhoneNotifier(hub: hub).ask()
    XCTAssertEqual(hub.log, ["ask"])
    XCTAssertEqual(
      hub.options, [.alert, .sound]
    )
  }

  func testReplacesWhatIsPending() async {
    let hub = FakeHub()
    let daily = UNNotificationRequest.daily(
      id: "daily",
      title: "Title",
      body: "Body",
      hour: 9,
      minute: 0
    )
    await PhoneNotifier(hub: hub)
      .replace(with: [daily])
    XCTAssertEqual(
      hub.log, ["clear", "add daily"]
    )
  }
}

/// Records what `PhoneNotifier` asks of the
/// notification center.
@MainActor
private final class FakeHub:
  NotificationHub {
  private(set) var log: [String] = []
  private(set) var options:
    UNAuthorizationOptions = []

  func requestAuthorization(
    options: UNAuthorizationOptions
  ) -> Bool {
    log.append("ask")
    self.options = options
    return true
  }

  func removeAllPendingNotificationRequests(
  ) {
    log.append("clear")
  }

  func add(
    _ request: UNNotificationRequest
  ) {
    let id = request.identifier
    log.append("add \(id)")
  }
}
