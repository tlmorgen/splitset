import Foundation

public struct WorkoutSession: Identifiable, Codable, Sendable, Equatable {
    public enum State: String, Codable, Sendable {
        case idle
        case active
        case resting
        case completed
    }

    public var id: UUID
    public var workoutId: UUID
    public var startDate: Date
    public var endDate: Date?
    public var currentStepIndex: Int
    public var state: State
    public var setLogs: [SetLog]

    public init(
        id: UUID = UUID(),
        workoutId: UUID,
        startDate: Date = Date(),
        endDate: Date? = nil,
        currentStepIndex: Int = 0,
        state: State = .idle,
        setLogs: [SetLog] = []
    ) {
        self.id = id
        self.workoutId = workoutId
        self.startDate = startDate
        self.endDate = endDate
        self.currentStepIndex = currentStepIndex
        self.state = state
        self.setLogs = setLogs
    }
}
