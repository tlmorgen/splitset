import Foundation

public struct ExerciseSet: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    /// nil means "to failure" / AMRAP
    public var targetReps: Int?
    /// Optional guide shown on the watch — not required to log
    public var suggestedWeightKg: Double?
    public var restSeconds: Int

    public init(
        id: UUID = UUID(),
        targetReps: Int? = 10,
        suggestedWeightKg: Double? = nil,
        restSeconds: Int = 60
    ) {
        self.id = id
        self.targetReps = targetReps
        self.suggestedWeightKg = suggestedWeightKg
        self.restSeconds = restSeconds
    }
}
