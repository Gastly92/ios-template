/// Every screen (and screen state) in the
/// app. UI tests open each one directly with
/// `-uiTesting -showScreen <rawValue>` and
/// run the localization check on all of
/// them; snapshot tests show each one.
/// `ScreenHost` shows each case.
///
/// Also compiled into the UI test target
/// (see `project.yml`), so the tests always
/// loop over the full list. Adding a screen:
/// add a case here and show it in
/// `ScreenHost`; CI (`check-screens.sh`)
/// fails if a view in `Views/Screens/` isn't
/// shown there.
enum ScreenID: String, CaseIterable {
  case items, itemsEmpty, item
  case settings, settingsOn
  case storeError
}
