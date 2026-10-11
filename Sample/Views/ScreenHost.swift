import SwiftUI

/// Shows one screen (`ScreenID`): where the
/// app starts, and each screen state UI and
/// snapshot tests open directly.
struct ScreenHost: View {
  let screen: ScreenID

  var body: some View {
    NavigationStack {
      switch screen {
      case .counter:
        CounterView()
      case .counted:
        CounterView(count: 3)
      case .info:
        InfoView()
      }
    }
  }
}
