import Foundation
import SwiftData
import SplitSetCore

@Model
final class ExerciseModel {
    var syncId: UUID
    var name: String
    var notes: String?
    var order: Int
    var restSeconds: Int = 60
    var isUniform: Bool = true
    @Relationship(deleteRule: .cascade) var sets: [ExerciseSetModel]

    init(name: String = "", notes: String? = nil, order: Int = 0, restSeconds: Int = 60, isUniform: Bool = true) {
        self.syncId = UUID()
        self.name = name
        self.notes = notes
        self.order = order
        self.restSeconds = restSeconds
        self.isUniform = isUniform
        self.sets = []
    }

    func toExercise() -> Exercise {
        Exercise(
            id: syncId,
            name: name,
            sets: sets.sorted { $0.order < $1.order }.map { $0.toExerciseSet() },
            notes: notes,
            restSeconds: restSeconds
        )
    }
}
