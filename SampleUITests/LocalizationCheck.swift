import XCTest

/// Runs the app in Xcode's bounded
/// pseudo-language, which wraps every
/// translatable string in "[# ... #]".
/// Visible text without the brackets would
/// stay in English after translation, so
/// each screen fails on any such text.
///
/// Text the app doesn't translate is let
/// through: system-formatted text (by
/// identifier or identifier prefix), text
/// the user typed, and system areas
/// (navigation bar buttons such as Back,
/// inside date pickers, and views with
/// `systemAreaIDs`, e.g. a chart's axes).
@MainActor
struct LocalizationCheck {
  /// Turns on the pseudo-language.
  static let pseudo = [
    "-NSSurroundLocalizedStrings", "YES",
  ]

  private typealias Node =
    any XCUIElementSnapshot

  let systemIDs: Set<String>
  let idPrefixes: [String]
  let userText: Set<String>
  let systemAreaIDs: Set<String>

  /// A check letting through the given
  /// identifiers, identifier prefixes,
  /// labels and areas (see above).
  init(
    systemIDs: Set<String> = [],
    idPrefixes: [String] = [],
    userText: Set<String> = [],
    systemAreaIDs: Set<String> = []
  ) {
    self.systemIDs = systemIDs
    self.idPrefixes = idPrefixes
    self.userText = userText
    self.systemAreaIDs = systemAreaIDs
  }

  /// Opens each screen directly and checks
  /// it. Each screen is read in one
  /// accessibility snapshot: asking for each
  /// element's label and frame took
  /// hundreds of round trips a screen, and
  /// one timed out when CI's runner stalled.
  func run(_ screens: [ScreenID]) {
    for screen in screens {
      let name = screen.rawValue
      let app = App.start(
        screen: screen,
        arguments: Self.pseudo
      )
      let text = app.staticTexts.firstMatch
      guard text.appears(within: 10) else {
        XCTFail("[\(name)] showed no text")
        continue
      }
      do {
        check(try app.snapshot(), on: name)
      } catch {
        XCTFail("[\(name)] \(error)")
      }
      app.terminate()
    }
  }

  /// `node` and everything inside it.
  private func all(_ node: Node) -> [Node] {
    let inside = node.children.flatMap {
      all($0)
    }
    return [node] + inside
  }

  /// Where system text sits, which isn't
  /// the app's to translate.
  private func systemAreas(
    in nodes: [Node]
  ) -> [CGRect] {
    let bars = nodes.filter {
      $0.elementType == .navigationBar
    }
    .flatMap { all($0) }
    .filter { $0.elementType == .button }
    let pickers = nodes.filter {
      $0.elementType == .datePicker
    }
    .flatMap { all($0).dropFirst() }
    let areas = nodes.filter {
      systemAreaIDs.contains($0.identifier)
    }
    return (bars + pickers + areas)
      .map(\.frame)
  }

  /// Whether a label with this identifier
  /// is let through.
  private func isAllowed(
    _ label: String,
    id: String
  ) -> Bool {
    systemIDs.contains(id)
      || idPrefixes.contains {
        id.hasPrefix($0)
      }
      || userText.contains(label)
  }

  /// Fails for each visible text or button
  /// label that has letters but no brackets.
  private func check(
    _ root: Node,
    on screen: String
  ) {
    let nodes = all(root)
    let system = systemAreas(in: nodes)
    let kinds: [XCUIElement.ElementType] =
      [.staticText, .button]
    var bracketed = 0
    for node in nodes
    where kinds.contains(node.elementType) {
      let label = node.label
      let id = node.identifier
      guard label.contains(where: \.isLetter)
      else { continue }
      if label.contains("[#") {
        bracketed += 1
        continue
      }
      let frame = node.frame
      if isAllowed(label, id: id)
        || system.contains(where: {
          $0.contains(frame)
        }) {
        continue
      }
      XCTFail(
        "[\(screen)] Not translatable: "
          + "'\(label)' (id '\(id)')"
      )
    }
    // Guards against the pseudo-language not
    // taking effect at all.
    XCTAssertGreaterThan(
      bracketed,
      0,
      "[\(screen)] No bracketed text"
    )
  }
}
