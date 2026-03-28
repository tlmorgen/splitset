import Foundation

public struct LiftAccelerationData: Codable, Sendable, Hashable {
    public var peakAccelerationG: Double
    public var averageAccelerationG: Double
    public var sampleCount: Int

    public init(peakAccelerationG: Double, averageAccelerationG: Double, sampleCount: Int) {
        self.peakAccelerationG = peakAccelerationG
        self.averageAccelerationG = averageAccelerationG
        self.sampleCount = sampleCount
    }
}
