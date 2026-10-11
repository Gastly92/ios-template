// Tests importing BaseSnapshots get
// SnapshotTesting too.
@_exported import SnapshotTesting
import SwiftUI

/// Pictures of a screen in light mode, dark
/// mode and large text, compared with the
/// committed images in `__Snapshots__/`
/// next to the test file. A screen that
/// looks different fails until its images
/// are recorded again (see RULES.md).
///
/// Pictures are drawn in the app's window:
/// iOS 26's glass bars only show their real
/// colors there (offscreen, small titles
/// came out white on white).
@MainActor
public enum Looks {
  /// An iPhone 13-sized screen.
  private static let phone =
    SwiftUISnapshotLayout.device(
      config: .iPhone13
    )

  /// The same width, three times as tall:
  /// large text runs long, and a phone-sized
  /// picture cut off whatever scrolled past
  /// the bottom.
  private static let tall = {
    let base = ViewImageConfig.iPhone13
    let size = base.size.map {
      CGSize(
        width: $0.width,
        height: $0.height * 3
      )
    }
    return SwiftUISnapshotLayout.device(
      config: ViewImageConfig(
        safeArea: base.safeArea,
        size: size,
        traits: base.traits
      )
    )
  }()

  /// Each look's name, traits and screen.
  /// 2x scale keeps the images small but
  /// readable.
  private static let all = [
    ("light", traits(.light), phone),
    ("dark", traits(.dark), phone),
    (
      "large",
      traits(.light, large: true),
      tall
    ),
  ]

  /// sRGB color: in the app's window images
  /// are otherwise wide color (Display P3),
  /// which compares unreliably once saved.
  /// The text size is always set: left
  /// unset, sizes scaled with text (like
  /// @ScaledMetric) drift from the standard
  /// size.
  private static func traits(
    _ style: UIUserInterfaceStyle,
    large: Bool = false
  ) -> UITraitCollection {
    UITraitCollection {
      $0.userInterfaceStyle = style
      $0.displayScale = 2
      $0.displayGamut = .SRGB
      $0.preferredContentSizeCategory = large
        ? .accessibilityExtraLarge : .large
    }
  }

  /// Compares `view` in every look with its
  /// images, named `<name>-<look>` (e.g.
  /// `counter-dark`). The source location
  /// arguments place the images next to the
  /// calling test.
  public static func check(
    _ view: some View,
    named name: String,
    fileID: StaticString = #fileID,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
  ) {
    for (look, traits, layout) in all {
      assertSnapshot(
        of: view,
        as: .image(
          drawHierarchyInKeyWindow: true,
          precision: 0.99,
          perceptualPrecision: 0.98,
          layout: layout,
          traits: traits
        ),
        named: "\(name)-\(look)",
        fileID: fileID,
        file: file,
        testName: testName,
        line: line,
        column: column
      )
    }
  }
}
