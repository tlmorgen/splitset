import Foundation
import SwiftData
import SplitSetCore

@Model
final class ExerciseSetModel {
    var syncId: UUID
    /// nil = to failure / AMRAP
    var targetReps: Int?
    var suggestedWeightKg: Double?
    var restSeconds: Int
    var order: Int

    init(targetReps: Int? = 10, suggestedWeightKg: Double? = nil, restSeconds: Int = 60, order: Int = 0) {
        self.syncId = UUID()
        self.targetReps = targetReps
        self.suggestedWeightKg = suggestedWeightKg
        self.restSeconds = restSeconds
        self.order = order
    }

    func toExerciseSet() -> ExerciseSet {
        ExerciseSet(
            id: syncId,
            targetReps: targetReps,
            suggestedWeightKg: suggestedWeightKg,
            restSeconds: restSeconds
        )
    }
}
