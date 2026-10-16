import SwiftUI
import UIKit

@main
struct SampleApp: App {
  private let launch: AppLaunch

  init() {
    let info = ProcessInfo.processInfo
    launch = AppLaunch(
      arguments: info.arguments
    )
    if launch.isUITesting {
      // No UIKit animations (screen pushes,
      // sheets, menus): a long-press that
      // lands while a screen is still
      // sliding in turns into a tap.
      UIView.setAnimationsEnabled(false)
    }
  }

  var body: some Scene {
    WindowGroup {
      content
    }
  }

  @ViewBuilder
  private var content: some View {
    switch launch.store {
    case .success(let container):
      ScreenHost(
        screen: launch.screen,
        notifier: launch.notifier,
        defaults: launch.defaults
      )
      .modelContainer(container)
    case .failure(let error):
      StoreErrorView(
        details: error.localizedDescription
      )
    }
  }
}
