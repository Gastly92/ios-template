import BaseTesting
import XCTest

/// Every screen's visible text is
/// translatable (see `LocalizationCheck`).
final class LocalizationTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = true
  }

  @MainActor
  func testEveryScreen() {
    let check = LocalizationCheck(
      // The system's own text: a formatted
      // date and an error description.
      systemIDs: [
        "itemDate", "errorDetails",
      ],
      // The sample items' names, as if the
      // user had typed them.
      userText: [
        "Groceries", "Books", "Ideas",
      ]
    )
    check.run(ScreenID.allCases)
  }
}
