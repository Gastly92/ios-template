import Base
@testable import Sample
import UserNotifications
import XCTest

@MainActor
final class ReminderTests: XCTestCase {
  private let utc: Calendar = {
    var cal = Calendar(
      identifier: .gregorian
    )
    cal.timeZone = .gmt
    return cal
  }()

  func testOffSchedulesNothing() {
    let off = Reminder(
      isOn: false, minutes: 540
    )
    XCTAssertTrue(off.requests.isEmpty)
  }

  func testOnSchedulesDaily() throws {
    let daily = Reminder(
      isOn: true, minutes: 615
    )
    XCTAssertEqual(daily.requests.count, 1)
    let request = try XCTUnwrap(
      daily.requests.first
    )
    let trigger = try XCTUnwrap(
      request.trigger
        as? UNCalendarNotificationTrigger
    )
    let time = trigger.dateComponents
    XCTAssertTrue(trigger.repeats)
    XCTAssertEqual(time.hour, 10)
    XCTAssertEqual(time.minute, 15)
    XCTAssertEqual(
      request.content.title, "Daily reminder"
    )
  }

  func testApplyAsksOnlyWhenOn() async {
    let notifier = RecordingNotifier()
    let daily = Reminder(
      isOn: true, minutes: 540
    )
    await daily.apply(to: notifier)
    XCTAssertEqual(notifier.asks, 1)
    let count = notifier.scheduled.count
    XCTAssertEqual(count, 1)
    let off = Reminder(
      isOn: false, minutes: 540
    )
    await off.apply(to: notifier)
    XCTAssertEqual(notifier.asks, 1)
    XCTAssertTrue(notifier.scheduled.isEmpty)
  }

  func testTimeRoundTrips() {
    let day = Date(timeIntervalSince1970: 0)
    let date = Reminder.date(
      minutes: 615, on: day, in: utc
    )
    let minutes = Reminder.minutes(
      of: date, in: utc
    )
    XCTAssertEqual(minutes, 615)
  }
}
