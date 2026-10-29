import SwiftUI
import TestSupport
import XCTest

/// One App Store screenshot: a screen of the
/// app with a caption over it.
struct Shot {
  let name: String
  let caption: String
  let dark: Bool
  let view: AnyView

  /// `view` (e.g. a `ScreenHost` with sample
  /// data) under `caption`, saved as
  /// `name`, in dark mode if `dark`.
  /// Captions are short phrases that add to
  /// the picture.
  init(
    name: String,
    caption: String,
    view: some View,
    dark: Bool = false
  ) {
    self.name = name
    self.caption = caption
    self.dark = dark
    self.view = AnyView(view)
  }
}

/// The App Store screenshots: each `Shot`'s
/// screen drawn on a 6.9-inch iPhone, framed
/// and captioned (`Poster`), and saved at
/// the large and medium sizes App Store
/// Connect takes, without an alpha channel.
/// Recorded and compared like the other
/// snapshots; the images in
/// `__Snapshots__/` are the ones to upload.
@MainActor
enum AppStoreShots {
  /// An iPhone size App Store Connect takes,
  /// in pixels, and what's added to the
  /// file name.
  private struct Phone {
    let suffix: String
    let width: Int
    let height: Int
  }

  /// A shot, framed in `colors`.
  private struct Page {
    let shot: Shot
    let colors: [Color]
  }

  /// Large (6.9-inch, e.g. 17 Pro Max) and
  /// medium (6.3-inch, e.g. 17 Pro, the one
  /// App Store Connect requires).
  private static let phones = [
    Phone(
      suffix: "",
      width: 1320,
      height: 2868
    ),
    Phone(
      suffix: "-medium",
      width: 1206,
      height: 2622
    ),
  ]

  /// The screen's size in points.
  private static let size = CGSize(
    width: 440,
    height: 956
  )

  /// Records or compares every shot, on a
  /// background gradient of `colors` (top
  /// to bottom), and checks each saved file
  /// is a size App Store Connect takes.
  static func check(
    _ shots: [Shot],
    colors: [Color],
    fileID: StaticString = #fileID,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
  ) throws {
    for shot in shots {
      for phone in phones {
        let name = shot.name + phone.suffix
        assertSnapshot(
          of: Page(
            shot: shot,
            colors: colors
          ),
          as: poster(phone),
          named: name,
          fileID: fileID,
          file: file,
          testName: testName,
          line: line,
          column: column
        )
        try checkFile(
          named: name,
          phone: phone,
          file: file,
          testName: testName
        )
      }
    }
  }

  /// `style`, standard text, 3x, sRGB.
  private static func traits(
    dark: Bool
  ) -> UITraitCollection {
    UITraitCollection {
      $0.userInterfaceStyle = dark
        ? .dark : .light
      $0.displayScale = 3
      $0.displayGamut = .SRGB
      $0.preferredContentSizeCategory =
        .large
    }
  }

  /// The screen: an iPhone Pro Max, 440 ×
  /// 956 points with its safe area, drawn
  /// in the app's window like the
  /// snapshots.
  private static func screen(
    dark: Bool
  ) -> Snapshotting<AnyView, UIImage> {
    let look = traits(dark: dark)
    let insets = UIEdgeInsets(
      top: 62, left: 0, bottom: 34, right: 0
    )
    return .image(
      drawHierarchyInKeyWindow: true,
      precision: 0.99,
      perceptualPrecision: 0.98,
      layout: .device(
        config: ViewImageConfig(
          safeArea: insets,
          size: size,
          traits: look
        )
      ),
      traits: look
    )
  }

  /// Draws the screen, then the `Poster`
  /// around it, at `phone`'s size (the
  /// medium one scaled down from the large;
  /// their shapes differ by 0.07%).
  private static func poster(
    _ phone: Phone
  ) -> Snapshotting<Page, UIImage> {
    Snapshotting(
      pathExtension: "png",
      diffing: screen(dark: false).diffing
    ) { page in
      let shot = page.shot
      return screen(dark: shot.dark)
        .snapshot(shot.view)
        .map {
          opaque(
            frame($0, page: page),
            phone: phone
          )
        }
    }
  }

  /// `image` in its `Poster`, drawn off
  /// screen by SwiftUI (only shapes, text
  /// and the picture, so it comes out the
  /// same every time).
  private static func frame(
    _ image: UIImage,
    page: Page
  ) -> UIImage {
    let framed = Poster(
      caption: page.shot.caption,
      screen: image,
      dark: page.shot.dark,
      colors: page.colors
    )
    .frame(
      width: size.width,
      height: size.height
    )
    .environment(\.colorScheme, .light)
    .environment(\.dynamicTypeSize, .large)
    let renderer = ImageRenderer(
      content: framed
    )
    renderer.scale = 3
    renderer.isOpaque = true
    return renderer.uiImage ?? image
  }

  /// `image` drawn again at `phone`'s size
  /// with no alpha channel (App Store
  /// Connect turns those down).
  nonisolated private static func opaque(
    _ image: UIImage,
    phone: Phone
  ) -> UIImage {
    guard let source = image.cgImage,
      let space = source.colorSpace,
      let context = CGContext(
        data: nil,
        width: phone.width,
        height: phone.height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: space,
        bitmapInfo: CGImageAlphaInfo
          .noneSkipLast.rawValue
      )
    else { return image }
    let rect = CGRect(
      x: 0,
      y: 0,
      width: phone.width,
      height: phone.height
    )
    context.interpolationQuality = .high
    context.draw(source, in: rect)
    guard let drawn = context.makeImage()
    else { return image }
    return UIImage(
      cgImage: drawn,
      scale: image.scale,
      orientation: .up
    )
  }

  /// The saved image is what App Store
  /// Connect takes: `phone`'s size, 8-bit
  /// RGB (read from the PNG's header). It
  /// sits where SnapshotTesting saves it:
  /// in `__Snapshots__/<test file>/`, as
  /// `<test>.<name>.png`.
  private static func checkFile(
    named name: String,
    phone: Phone,
    file: StaticString,
    testName: String
  ) throws {
    let test = URL(filePath: "\(file)")
    let folder = test
      .deletingPathExtension()
      .lastPathComponent
    let function = testName.prefix {
      $0 != "("
    }
    let png = test
      .deletingLastPathComponent()
      .appending(path: "__Snapshots__")
      .appending(path: folder)
      .appending(
        path: "\(function).\(name).png"
      )
    let data = try Data(contentsOf: png)
    let head = [UInt8](data.prefix(26))
    guard head.count == 26 else {
      XCTFail("\(name): not a PNG")
      return
    }
    func number(at start: Int) -> Int {
      head[start..<start + 4].reduce(0) {
        $0 << 8 | Int($1)
      }
    }
    XCTAssertEqual(
      number(at: 16), phone.width, name
    )
    XCTAssertEqual(
      number(at: 20), phone.height, name
    )
    // 8 bits a channel; color type 2 is RGB
    // (6 would be RGB with alpha).
    XCTAssertEqual(head[24], 8, name)
    XCTAssertEqual(head[25], 2, name)
  }
}
