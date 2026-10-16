import Foundation
import SwiftData

/// The stored data as the first release
/// wrote it. Frozen from then on: never edit
/// these models. To change a stored model,
/// copy them into a `SchemaV2` (the new
/// shape), point the `Item` alias at it, add
/// it and a V1 → V2 stage to `Migrations`,
/// and keep the test that a V1 store opens
/// (`StoreTests`).
enum SchemaV1: VersionedSchema {
  static var versionIdentifier:
    Schema.Version {
    Schema.Version(1, 0, 0)
  }

  static var models:
    [any PersistentModel.Type] {
    [Item.self]
  }
}

/// The models the app uses: the latest
/// schema's.
typealias Item = SchemaV1.Item

/// Every stored-data version, oldest first,
/// and the steps between them.
enum Migrations: SchemaMigrationPlan {
  static var schemas:
    [any VersionedSchema.Type] {
    [SchemaV1.self]
  }

  static var stages: [MigrationStage] { [] }
}

extension SchemaV1 {
  /// Something the user keeps a list of.
  /// Rename and reshape it for the app.
  ///
  /// Follows CloudKit's rules so iCloud sync
  /// can be added later without a migration:
  /// every property has a default,
  /// relationships are optional, and nothing
  /// is unique.
  @Model
  final class Item {
    var title: String = ""
    var created = Date.now

    init(title: String, created: Date) {
      self.title = title
      self.created = created
    }
  }
}
