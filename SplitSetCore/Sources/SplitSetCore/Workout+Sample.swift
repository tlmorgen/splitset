import Foundation

public extension Workout {
    static let sample = Workout(
        name: "Chest Day",
        exercises: [
            Exercise(
                name: "DB Warmup",
                sets: [
                    ExerciseSet(targetReps: 15, suggestedWeightKg: 10, restSeconds: 30),
                    ExerciseSet(targetReps: 15, suggestedWeightKg: 10, restSeconds: 30)
                ]
            ),
            Exercise(
                name: "Bench Press",
                sets: [
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 60, restSeconds: 90),
                    ExerciseSet(targetReps: 8,  suggestedWeightKg: 75, restSeconds: 90),
                    ExerciseSet(targetReps: 6,  suggestedWeightKg: 85, restSeconds: 120)
                ]
            ),
            Exercise(
                name: "Incline Bench",
                sets: [
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 60, restSeconds: 90),
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 60, restSeconds: 90),
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 60, restSeconds: 90)
                ]
            ),
            Exercise(
                name: "Bicep Curl",
                sets: [
                    ExerciseSet(targetReps: 12, suggestedWeightKg: 15, restSeconds: 60),
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 15, restSeconds: 60),
                    ExerciseSet(targetReps: nil, suggestedWeightKg: 12, restSeconds: 0)
                ],
                notes: "Last set to failure"
            ),
            Exercise(
                name: "Tricep Pushdown",
                sets: [
                    ExerciseSet(targetReps: 12, suggestedWeightKg: 20, restSeconds: 60),
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 20, restSeconds: 60),
                    ExerciseSet(targetReps: nil, suggestedWeightKg: 17.5, restSeconds: 0)
                ],
                notes: "Last set to failure"
            )
        ],
        trackWeights: true
    )
}
