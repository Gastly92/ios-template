@testable import Sample
import SwiftData
import XCTest

/// Stored data survives app updates.
@MainActor
final class StoreTests: XCTestCase {
  /// A store file of this test's own.
  private let url = URL.temporaryDirectory
    .appending(path: UUID().uuidString)

  /// A store the first release wrote
  /// (models frozen in `SchemaV1`) opens in
  /// this version, through its migrations,
  /// with nothing lost. Keep this test as
  /// later versions add schemas.
  func testVersion1StoreOpens() throws {
    defer { removeStore() }
    let created = Date(
      timeIntervalSince1970: 86_400
    )
    try autoreleasepool {
      let old = try ModelContainer(
        for: Schema(
          versionedSchema: SchemaV1.self
        ),
        configurations: ModelConfiguration(
          url: url
        )
      )
      old.mainContext.insert(
        SchemaV1.Item(
          title: "Groceries",
          created: created
        )
      )
      try old.mainContext.save()
    }

    let store = try AppStore.open(
      ModelConfiguration(url: url)
    )
    let all = try store.mainContext.fetch(
      FetchDescriptor<Item>()
    )
    XCTAssertEqual(
      all.map(\.title), ["Groceries"]
    )
    XCTAssertEqual(
      all.first?.created, created
    )
  }

  /// The plan starts at version 1, with
  /// nothing to migrate yet.
  func testPlanStartsAtVersion1() {
    XCTAssertEqual(
      SchemaV1.versionIdentifier,
      Schema.Version(1, 0, 0)
    )
    XCTAssertEqual(
      Migrations.schemas.count, 1
    )
    XCTAssertTrue(Migrations.stages.isEmpty)
  }

  /// The store and SQLite's side files.
  private func removeStore() {
    for end in ["", "-shm", "-wal"] {
      let file = URL(
        fileURLWithPath: url.path() + end
      )
      try? FileManager.default
        .removeItem(at: file)
    }
  }
}
