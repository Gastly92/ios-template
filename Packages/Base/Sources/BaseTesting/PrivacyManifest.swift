import Foundation

/// The app's privacy manifest
/// (`PrivacyInfo.xcprivacy`), read from the
/// app, so a unit test can keep it true to
/// what the app does. The App Store requires
/// one in every app.
public struct PrivacyManifest {
  /// Why reading the manifest failed.
  public enum Problem: Error {
    /// The app has no manifest.
    case missing
    /// The file isn't a property list.
    case unreadable
  }

  /// Whether the app tracks people.
  public let tracks: Bool
  /// How many kinds of data the app
  /// collects.
  public let collectedTypes: Int
  /// Each API category Apple requires a
  /// reason for (e.g. UserDefaults' long
  /// key), with the reasons given (e.g.
  /// `CA92.1`).
  public let reasons: [String: [String]]

  /// Reads the manifest from `bundle`: the
  /// app, in a unit test hosted by it.
  public init(
    bundle: Bundle = .main
  ) throws {
    guard let url = bundle.url(
      forResource: "PrivacyInfo",
      withExtension: "xcprivacy"
    ) else { throw Problem.missing }
    let data = try Data(contentsOf: url)
    let plist = try PropertyListSerialization
      .propertyList(from: data, format: nil)
    guard let root = plist as? [String: Any]
    else { throw Problem.unreadable }
    tracks = root["NSPrivacyTracking"]
      as? Bool ?? true
    let types = root[
      "NSPrivacyCollectedDataTypes"
    ] as? [Any]
    collectedTypes = types?.count ?? 0
    let apis = root[
      "NSPrivacyAccessedAPITypes"
    ] as? [[String: Any]] ?? []
    var found: [String: [String]] = [:]
    for api in apis {
      let type = api[
        "NSPrivacyAccessedAPIType"
      ] as? String ?? ""
      found[type] = api[
        "NSPrivacyAccessedAPITypeReasons"
      ] as? [String] ?? []
    }
    reasons = found
  }
}
