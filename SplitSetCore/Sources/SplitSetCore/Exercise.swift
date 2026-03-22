import Foundation

public struct Exercise: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var sets: [ExerciseSet]
    public var notes: String?

    public init(
        id: UUID = UUID(),
        name: String,
        sets: [ExerciseSet] = [ExerciseSet()],
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.notes = notes
    }
}
