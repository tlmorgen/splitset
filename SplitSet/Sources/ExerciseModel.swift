import Foundation
import SwiftData
import SplitSetCore

@Model
final class ExerciseModel {
    var syncId: UUID
    var name: String
    var notes: String?
    var order: Int
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSetModel]

    init(name: String = "", notes: String? = nil, order: Int = 0) {
        self.syncId = UUID()
        self.name = name
        self.notes = notes
        self.order = order
        self.sets = []
    }

    func toExercise() -> Exercise {
        Exercise(
            id: syncId,
            name: name,
            sets: sets.sorted { $0.order < $1.order }.map { $0.toExerciseSet() },
            notes: notes
        )
    }
}
