import Foundation

public struct SetLog: Identifiable, Codable, Sendable {
    public var id: UUID
    public var exerciseSetId: UUID
    public var setNumber: Int
    /// Actual reps performed — may differ from target, especially for AMRAP sets
    public var actualReps: Int?
    public var weightKg: Double?
    public var completedAt: Date

    public init(
        id: UUID = UUID(),
        exerciseSetId: UUID,
        setNumber: Int,
        actualReps: Int? = nil,
        weightKg: Double? = nil,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.exerciseSetId = exerciseSetId
        self.setNumber = setNumber
        self.actualReps = actualReps
        self.weightKg = weightKg
        self.completedAt = completedAt
    }
}
