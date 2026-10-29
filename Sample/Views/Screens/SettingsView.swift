import SwiftUI

/// The daily reminder: a switch, and its
/// time. Changes schedule it at once.
struct SettingsView: View {
  @AppStorage private var isOn: Bool
  @AppStorage private var minutes: Int
  @Environment(\.now)
  private var now

  let notifier: any Notifier

  init(
    notifier: any Notifier,
    defaults: UserDefaults
  ) {
    self.notifier = notifier
    _isOn = AppStorage(
      wrappedValue: false,
      Reminder.onKey,
      store: defaults
    )
    _minutes = AppStorage(
      wrappedValue: Reminder.defaultMinutes,
      Reminder.minutesKey,
      store: defaults
    )
  }

  var body: some View {
    Form {
      Section {
        Toggle("Daily reminder", isOn: $isOn)
        if isOn {
          DatePicker(
            "Time",
            selection: time,
            displayedComponents:
              .hourAndMinute
          )
          .datePickerStyle(.wheel)
        }
      } footer: {
        Text("""
          A notification each day at this \
          time.
          """)
      }
    }
    .navigationTitle("Settings")
    .onChange(of: reminder) {
      schedule()
    }
  }

  private var reminder: Reminder {
    Reminder(isOn: isOn, minutes: minutes)
  }

  /// The time picker's value.
  private var time: Binding<Date> {
    Binding {
      Reminder.date(
        minutes: minutes,
        on: now
      )
    } set: {
      minutes = Reminder.minutes(of: $0)
    }
  }

  private func schedule() {
    Task {
      await reminder.apply(to: notifier)
    }
  }
}
