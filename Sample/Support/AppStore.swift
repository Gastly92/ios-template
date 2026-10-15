import SwiftData

enum AppStore {
  /// Opens the data store: on disk normally,
  /// in memory for UI and snapshot tests.
  static func open(
    inMemory: Bool
  ) throws -> ModelContainer {
    try open(ModelConfiguration(
      isStoredInMemoryOnly: inMemory
    ))
  }

  /// Opens the store at the latest schema,
  /// migrating older data first (see
  /// `SchemaV1`).
  static func open(
    _ configuration: ModelConfiguration
  ) throws -> ModelContainer {
    try ModelContainer(
      for: Schema(
        versionedSchema: SchemaV1.self
      ),
      migrationPlan: Migrations.self,
      configurations: configuration
    )
  }
}
