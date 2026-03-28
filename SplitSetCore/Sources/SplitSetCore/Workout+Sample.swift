import Foundation

public extension Workout {
    static let samples: [Workout] = [.sample, .cardioSample]

    static let sample = Workout(
        name: "Chest Day",
        exercises: [
            Exercise(
                name: "DB Warmup",
                sets: [
                    ExerciseSet(targetReps: 15, suggestedWeightKg: 10),
                    ExerciseSet(targetReps: 15, suggestedWeightKg: 10)
                ],
                notes: "Light weight, full range of motion. Focus on warming up the shoulder joint and rotator cuff before loading.",
                restSeconds: 30
            ),
            Exercise(
                name: "Bench Press",
                sets: [
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 60),
                    ExerciseSet(targetReps: 8,  suggestedWeightKg: 75),
                    ExerciseSet(targetReps: 6,  suggestedWeightKg: 85)
                ],
                notes: "Retract scapula and keep them pinned throughout. Bar path slightly toward lower chest. Pause 1s at bottom on working sets.",
                restSeconds: 90
            ),
            Exercise(
                name: "Incline Bench",
                sets: [
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 60),
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 60),
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 60)
                ],
                notes: "45° incline. Elbows at 45° to body, not flared. Control the descent.",
                restSeconds: 90
            ),
            Exercise(
                name: "Bicep Curl",
                sets: [
                    ExerciseSet(targetReps: 12, suggestedWeightKg: 15),
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 15),
                    ExerciseSet(targetReps: nil, suggestedWeightKg: 12)
                ],
                notes: "Last set to failure. Keep elbows pinned, no swinging. Supinate wrist at top.",
                restSeconds: 60
            ),
            Exercise(
                name: "Tricep Pushdown",
                sets: [
                    ExerciseSet(targetReps: 12, suggestedWeightKg: 20),
                    ExerciseSet(targetReps: 10, suggestedWeightKg: 20),
                    ExerciseSet(targetReps: nil, suggestedWeightKg: 17.5)
                ],
                notes: "Last set to failure. Use rope attachment. Spread rope at bottom, keep elbows at sides throughout the movement.",
                restSeconds: 60
            )
        ],
        trackWeights: true,
        trackAcceleration: true
    )

    static let cardioSample = Workout(
        name: "Cardio Day",
        exercises: [
            Exercise(
                name: "Stair Climber",
                sets: [
                    ExerciseSet(targetReps: nil, durationSeconds: 600),
                    ExerciseSet(targetReps: nil, durationSeconds: 600)
                ],
                notes: "Moderate pace, hold rails lightly",
                restSeconds: 120
            ),
            Exercise(
                name: "Rowing Machine",
                sets: [
                    ExerciseSet(targetReps: nil, durationSeconds: 300),
                    ExerciseSet(targetReps: nil, durationSeconds: 300),
                    ExerciseSet(targetReps: nil, durationSeconds: 300)
                ],
                notes: "Target 500m splits",
                restSeconds: 90
            ),
            Exercise(
                name: "Battle Ropes",
                sets: [
                    ExerciseSet(targetReps: nil, durationSeconds: 30),
                    ExerciseSet(targetReps: nil, durationSeconds: 30),
                    ExerciseSet(targetReps: nil, durationSeconds: 30),
                    ExerciseSet(targetReps: nil, durationSeconds: 30)
                ],
                restSeconds: 45
            ),
            Exercise(
                name: "Plank",
                sets: [
                    ExerciseSet(targetReps: nil, durationSeconds: 60),
                    ExerciseSet(targetReps: nil, durationSeconds: 60),
                    ExerciseSet(targetReps: nil, durationSeconds: 60)
                ],
                restSeconds: 30
            )
        ],
        trackWeights: false
    )
}
