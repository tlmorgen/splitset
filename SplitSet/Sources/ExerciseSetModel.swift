import Foundation
import SwiftData
import SplitSetCore

@Model
final class ExerciseSetModel {
    var syncId: UUID
    /// nil = to failure / AMRAP. Ignored when durationSeconds is set.
    var targetReps: Int?
    /// If set, this is a timed cardio set
    var durationSeconds: Int?
    var suggestedWeightKg: Double?
    var restSeconds: Int
    var order: Int

    var isTimed: Bool { durationSeconds != nil }

    init(
        targetReps: Int? = 10,
        durationSeconds: Int? = nil,
        suggestedWeightKg: Double? = nil,
        restSeconds: Int = 60,
        order: Int = 0
    ) {
        self.syncId = UUID()
        self.targetReps = targetReps
        self.durationSeconds = durationSeconds
        self.suggestedWeightKg = suggestedWeightKg
        self.restSeconds = restSeconds
        self.order = order
    }

    func toExerciseSet() -> ExerciseSet {
        ExerciseSet(
            id: syncId,
            targetReps: targetReps,
            durationSeconds: durationSeconds,
            suggestedWeightKg: suggestedWeightKg,
            restSeconds: restSeconds
        )
    }
}
