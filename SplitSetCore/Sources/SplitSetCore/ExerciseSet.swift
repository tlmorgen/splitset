import Foundation

public struct ExerciseSet: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    /// nil means "to failure" / AMRAP. Ignored when durationSeconds is set.
    public var targetReps: Int?
    /// If set, this is a timed cardio set — watch shows a countdown instead of reps
    public var durationSeconds: Int?
    /// Optional guide shown on the watch — not required to log
    public var suggestedWeightKg: Double?

    public var isTimed: Bool { durationSeconds != nil }

    public init(
        id: UUID = UUID(),
        targetReps: Int? = 10,
        durationSeconds: Int? = nil,
        suggestedWeightKg: Double? = nil
    ) {
        self.id = id
        self.targetReps = targetReps
        self.durationSeconds = durationSeconds
        self.suggestedWeightKg = suggestedWeightKg
    }
}
