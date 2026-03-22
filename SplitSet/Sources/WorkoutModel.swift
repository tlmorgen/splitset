import Foundation
import SwiftData
import SplitSetCore

@Model
final class WorkoutModel {
    var syncId: UUID
    var name: String
    var trackWeights: Bool
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var exercises: [ExerciseModel]

    init(name: String = "", trackWeights: Bool = false) {
        self.syncId = UUID()
        self.name = name
        self.trackWeights = trackWeights
        self.createdAt = Date()
        self.exercises = []
    }

    func toWorkout() -> Workout {
        Workout(
            id: syncId,
            name: name,
            exercises: exercises.sorted { $0.order < $1.order }.map { $0.toExercise() },
            trackWeights: trackWeights
        )
    }
}
