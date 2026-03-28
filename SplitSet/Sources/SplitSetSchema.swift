import SwiftData

// MARK: - Schema versions
// When changing any @Model class:
//   1. Add a new SchemaVN enum below, bumping the version number
//   2. Add it to SplitSetMigrationPlan.schemas (in order)
//   3. Add a .lightweight or .custom MigrationStage to SplitSetMigrationPlan.stages
//   4. Update SplitSetApp to pass migrationPlan: SplitSetMigrationPlan.self
// See CLAUDE.md for the full checklist.

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [WorkoutModel.self, ExerciseModel.self, ExerciseSetModel.self,
         SessionModel.self, SetLogModel.self]
    }
}

// MARK: - Migration plan

enum SplitSetMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self] }
    // No stages yet — add one here each time a new SchemaVN is introduced.
    static var stages: [MigrationStage] { [] }
}
