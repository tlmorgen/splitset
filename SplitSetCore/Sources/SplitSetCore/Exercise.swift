import Foundation

public struct Exercise: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var sets: [ExerciseSet]
    public var notes: String?
    public var restSeconds: Int

    public init(
        id: UUID = UUID(),
        name: String,
        sets: [ExerciseSet] = [ExerciseSet()],
        notes: String? = nil,
        restSeconds: Int = 60
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.notes = notes
        self.restSeconds = restSeconds
    }
}
