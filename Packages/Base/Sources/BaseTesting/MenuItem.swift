import XCTest

public extension XCUIApplication {
  /// Presses after the first, at most, each
  /// only when the one before was read as a
  /// tap.
  static let stallRetries = 2

  /// Long-presses `element` and returns its
  /// menu's `label` item, which must appear.
  ///
  /// CI's free runners (3 cores, no GPU)
  /// sometimes stall for a few seconds, and
  /// a press held during a stall reaches the
  /// app as a tap: no menu, and the tap's
  /// own screen opens. Only that case, the
  /// menu missing and `tapped.opens` shown,
  /// gets another press (up to
  /// `stallRetries`), after closing it.
  /// Anything else is a real failure.
  /// `press` lets a test make the first
  /// press a tap, to check this path.
  @MainActor
  func menuItem(
    _ label: String,
    on element: XCUIElement,
    ifTapped tapped: Tapped,
    press: Press = {
      $0.press(forDuration: 1.5)
    }
  ) -> XCUIElement {
    let item = buttons[label].firstMatch
    press(element)
    for _ in 0..<Self.stallRetries {
      if isMenu(item, not: tapped) {
        return item
      }
      XCTAssertTrue(
        tapped.opens.appears(),
        "No menu, and no sign of a tap"
      )
      // Not `element`'s name: it's off
      // screen now, and reading it would
      // fail.
      print("""
        Long-press read as a tap (app \
        stalled): closing what it opened \
        and pressing again.
        """)
      tapped.close()
      let closed = tapped.opens.disappears()
      XCTAssertTrue(closed)
      element.press(forDuration: 1.5)
    }
    XCTAssertTrue(
      isMenu(item, not: tapped),
      "Every press was read as a tap"
    )
    return item
  }

  /// A screen a tap pushes, by its title,
  /// closed with Back.
  @MainActor
  func pushed(_ title: String) -> Tapped {
    let back = navigationBars.buttons
      .element(boundBy: 0)
    return Tapped(opens: bar(title)) {
      back.tap()
    }
  }

  /// A sheet a tap opens, by its title,
  /// closed with its `close` button.
  @MainActor
  func sheet(
    _ title: String,
    close: String
  ) -> Tapped {
    let done = button(close)
    return Tapped(opens: bar(title)) {
      done.tap()
    }
  }

  /// Whether `item` is in the menu. The
  /// screen a tap opens can have a button
  /// with the same label, so it counts only
  /// while that screen isn't open.
  @MainActor
  private func isMenu(
    _ item: XCUIElement,
    not tapped: Tapped
  ) -> Bool {
    item.appears() && !tapped.opens.exists
  }
}

/// How a test presses an element.
public typealias Press = @MainActor (
  XCUIElement
) -> Void

/// What a press opens if the app reads it as
/// a tap, and how to close it again.
public struct Tapped {
  /// What the tap opens.
  public let opens: XCUIElement
  /// Closes it again.
  public let close: @MainActor () -> Void

  /// What a tap `opens`, and how to `close`
  /// it.
  public init(
    opens: XCUIElement,
    close: @escaping @MainActor () -> Void
  ) {
    self.opens = opens
    self.close = close
  }
}
