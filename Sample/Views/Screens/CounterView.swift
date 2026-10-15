import BaseUI
import SwiftUI

/// A count that goes up with each tap on
/// Add. Tapping the count opens Info;
/// long-pressing it offers Reset.
struct CounterView: View {
  @State private var tally: Tally

  init(count: Int = 0) {
    _tally = State(
      initialValue: Tally(count: count)
    )
  }

  var body: some View {
    LeadingStack(spacing: 24) {
      NavigationLink {
        InfoView()
      } label: {
        Text(tally.summary)
          .font(.largeTitle.bold())
      }
      .testID("count")
      .contextMenu {
        Button("Reset", role: .destructive) {
          tally.reset()
        }
      }
      Button("Add") {
        tally.add()
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
    .fullWidth(.leading)
    .navigationTitle("Counter")
  }
}
