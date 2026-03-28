import Foundation
import SwiftData

@Model
final class SessionModel {
    var syncId: UUID
    var workoutSyncId: UUID
    var startDate: Date
    var endDate: Date?
    var completedAt: Date
    @Relationship(deleteRule: .cascade) var setLogs: [SetLogModel]

    init(syncId: UUID = UUID(), workoutSyncId: UUID, startDate: Date, endDate: Date? = nil) {
        self.syncId = syncId
        self.workoutSyncId = workoutSyncId
        self.startDate = startDate
        self.endDate = endDate
        self.completedAt = Date()
        self.setLogs = []
    }
}

@Model
final class SetLogModel {
    var syncId: UUID
    var exerciseSetId: UUID
    var setNumber: Int
    var weightKg: Double?
    var peakAccelerationG: Double?
    var averageAccelerationG: Double?
    var completedAt: Date

    init(syncId: UUID = UUID(), exerciseSetId: UUID, setNumber: Int, weightKg: Double? = nil, peakAccelerationG: Double? = nil, averageAccelerationG: Double? = nil, completedAt: Date = Date()) {
        self.syncId = syncId
        self.exerciseSetId = exerciseSetId
        self.setNumber = setNumber
        self.weightKg = weightKg
        self.peakAccelerationG = peakAccelerationG
        self.averageAccelerationG = averageAccelerationG
        self.completedAt = completedAt
    }
}
