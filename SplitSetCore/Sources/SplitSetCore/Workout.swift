import Foundation

public struct Workout: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var exercises: [Exercise]

    public var trackWeights: Bool
    public var trackAcceleration: Bool

    public init(id: UUID = UUID(), name: String, exercises: [Exercise] = [], trackWeights: Bool = false, trackAcceleration: Bool = false) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.trackWeights = trackWeights
        self.trackAcceleration = trackAcceleration
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        exercises = try container.decode([Exercise].self, forKey: .exercises)
        trackWeights = try container.decodeIfPresent(Bool.self, forKey: .trackWeights) ?? false
        trackAcceleration = try container.decodeIfPresent(Bool.self, forKey: .trackAcceleration) ?? false
    }

    /// Flattens exercises into an ordered sequence of steps for the watch player.
    public func steps() -> [WorkoutStep] {
        var result: [WorkoutStep] = []
        for (exIdx, exercise) in exercises.enumerated() {
            let isLastExercise = exIdx == exercises.count - 1
            let nextExerciseName = isLastExercise ? "" : exercises[exIdx + 1].name

            for (setIdx, exerciseSet) in exercise.sets.enumerated() {
                result.append(.lift(exercise: exercise, exerciseSet: exerciseSet, setNumber: setIdx + 1))

                let isLastSet = setIdx == exercise.sets.count - 1
                let isLastStep = isLastSet && isLastExercise

                if !isLastStep && exercise.restSeconds > 0 {
                    let nextName = isLastSet ? nextExerciseName : exercise.name
                    result.append(.rest(seconds: exercise.restSeconds, nextName: nextName))
                }
            }
        }
        return result
    }
}
