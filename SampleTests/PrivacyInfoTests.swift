import BaseTesting
import XCTest

/// The App Store requires a privacy
/// manifest. Keep it true to what the app
/// does: update it (and the privacy page in
/// `site/`) when adding tracking, collected
/// data, or APIs Apple lists as needing a
/// reason.
final class PrivacyInfoTests: XCTestCase {
  func testManifestMatchesTheApp() throws {
    let manifest = try PrivacyManifest()
    XCTAssertFalse(manifest.tracks)
    XCTAssertEqual(
      manifest.collectedTypes, 0
    )
    // Settings are kept in UserDefaults,
    // read only by the app itself (CA92.1).
    let defaults = "NSPrivacyAccessed"
      + "APICategoryUserDefaults"
    XCTAssertEqual(
      manifest.reasons,
      [defaults: ["CA92.1"]]
    )
  }
}
