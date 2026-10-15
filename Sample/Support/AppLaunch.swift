/// What the app does at launch: read the
/// launch arguments. Kept out of the `App`
/// so it can be unit tested.
struct AppLaunch {
  let isUITesting: Bool
  /// The screen to start on: the counter,
  /// or in UI tests the one given with
  /// `-showScreen <id>`.
  let screen: ScreenID

  init(arguments: [String]) {
    isUITesting = arguments.contains(
      "-uiTesting"
    )
    let id = arguments
      .drop { $0 != "-showScreen" }
      .dropFirst()
      .first
    let shown = isUITesting
      ? id.flatMap(ScreenID.init(rawValue:))
      : nil
    screen = shown ?? .counter
  }
}
