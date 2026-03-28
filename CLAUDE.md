# SplitSet — Claude Rules

## SwiftData schema migrations

Any time you add, remove, or rename a property on a `@Model` class (`WorkoutModel`, `ExerciseModel`, `ExerciseSetModel`, `SessionModel`, `SetLogModel`), you **must** follow these steps before touching the model file:

1. **Freeze the current schema** — add a new `SchemaVN` enum to `SplitSet/Sources/SplitSetSchema.swift`, bumping the version number. Copy the full model list from the previous version.
2. **Add it to the migration plan** — append the new schema to `SplitSetMigrationPlan.schemas` (must be in ascending order).
3. **Write a migration stage** — add a `.lightweight` or `.custom` `MigrationStage` to `SplitSetMigrationPlan.stages`:
   - Use `.lightweight` for: adding optional properties, adding new models, renaming with `@Attribute(.originalName("old"))`.
   - Use `.custom(willMigrate:didMigrate:)` for: non-optional new fields (need a default), computed transforms, or removing data.
4. **Verify `SplitSetApp`** still passes `migrationPlan: SplitSetMigrationPlan.self` to `.modelContainer`.

**Never** change a `@Model` without a corresponding schema version bump. Users will lose all their workout and session data if a migration is missing.

## General

- User lifts in lbs; `suggestedWeightKg` in `.splitset` files must be converted (1 lb = 0.453592 kg).
- Weights are stored in kg internally; convert for display using `WeightUnit`.
- Keep sessions under 30 min — lunch-break workouts.
