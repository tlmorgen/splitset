import Foundation

public enum WorkoutStep: Sendable {
    case lift(exercise: Exercise, exerciseSet: ExerciseSet, setNumber: Int)
    case rest(seconds: Int, nextName: String)

    public var isRest: Bool {
        if case .rest = self { return true }
        return false
    }
}
