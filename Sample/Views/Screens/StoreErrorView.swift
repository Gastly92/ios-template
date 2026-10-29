import SwiftUI

/// Shown instead of the app if the data
/// store can't be opened (for example, the
/// phone is out of storage). Nothing is
/// deleted; reopening the app tries again.
///
/// A scrolling page rather than
/// `ContentUnavailableView`, which can't
/// grow or scroll, so its text would be
/// clipped at large text sizes.
struct StoreErrorView: View {
  private static let icon =
    "exclamationmark.triangle"

  let details: String

  @ScaledMetric(relativeTo: .largeTitle)
  private var iconSize: CGFloat = 48

  init(details: String) {
    self.details = details
  }

  var body: some View {
    ScrollView {
      message
        .multilineTextAlignment(.center)
        .wrapsText()
        .padding(24)
        .padding(.top, 60)
        .fullWidth()
    }
    .background(Color(.systemBackground))
  }

  private var message: some View {
    VStack(spacing: 16) {
      Image(systemName: Self.icon)
        .font(.system(size: iconSize))
        .foregroundStyle(.secondary)
        .accessibilityHidden(true)
      Text("Can't open your data")
        .font(.title2.bold())
        .accessibilityAddTraits(.isHeader)
      Text("""
        Your data is safe. Close the app \
        and open it again. If this keeps \
        happening, free up some storage \
        on your iPhone.
        """)
      // The system's own error text (already
      // in the user's language).
      Text(details)
        .font(.footnote)
        .foregroundStyle(.secondary)
        .testID("errorDetails")
    }
  }
}
