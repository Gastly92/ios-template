import BaseUI
import SwiftUI

/// What the sample app is for.
struct InfoView: View {
  var body: some View {
    Text("""
      This sample app runs the template's \
      checks on itself. Tap Add to count; \
      long-press the count to reset it.
      """)
    .wrapsText()
    .padding()
    .fullWidth(.leading)
    .navigationTitle("Info")
  }
}
