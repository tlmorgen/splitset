import CoreMotion
import Observation
import SplitSetCore

@Observable
@MainActor
final class MotionManager {
    var currentAcceleration: Double = 0

    private let motionManager = CMMotionManager()
    private var peak: Double = 0
    private var sum: Double = 0
    private var count: Int = 0
    private var smoothed: Double = 0
    private let alpha: Double = 0.3
    #if targetEnvironment(simulator)
    private var simulatorTimer: Timer?
    private var simulatorTick: Double = 0
    #endif

    func startTracking() {
        peak = 0; sum = 0; count = 0; smoothed = 0; currentAcceleration = 0

        #if targetEnvironment(simulator)
        simulatorTick = 0
        simulatorTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 20.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.simulatorTick += 1.0 / 20.0
                // Simulate a lifting rep cycle: ~2s per rep, peak ~1.5g
                let magnitude = abs(sin(self.simulatorTick * Double.pi / 2.0)) * 1.5
                self.smoothed = self.alpha * magnitude + (1 - self.alpha) * self.smoothed
                self.currentAcceleration = self.smoothed
                if magnitude > self.peak { self.peak = magnitude }
                self.sum += magnitude
                self.count += 1
            }
        }
        return
        #endif

        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            let ua = motion.userAcceleration
            let magnitude = (ua.x * ua.x + ua.y * ua.y + ua.z * ua.z).squareRoot()
            self.smoothed = self.alpha * magnitude + (1 - self.alpha) * self.smoothed
            self.currentAcceleration = self.smoothed
            if magnitude > self.peak { self.peak = magnitude }
            self.sum += magnitude
            self.count += 1
        }
    }

    func stopTracking() -> LiftAccelerationData? {
        #if targetEnvironment(simulator)
        simulatorTimer?.invalidate()
        simulatorTimer = nil
        currentAcceleration = 0
        guard count > 0 else { return nil }
        let result = LiftAccelerationData(
            peakAccelerationG: peak,
            averageAccelerationG: sum / Double(count),
            sampleCount: count
        )
        peak = 0; sum = 0; count = 0; smoothed = 0
        return result
        #endif

        guard motionManager.isDeviceMotionActive else {
            currentAcceleration = 0
            return nil
        }
        motionManager.stopDeviceMotionUpdates()
        currentAcceleration = 0
        guard count > 0 else { return nil }
        let data = LiftAccelerationData(
            peakAccelerationG: peak,
            averageAccelerationG: sum / Double(count),
            sampleCount: count
        )
        peak = 0; sum = 0; count = 0; smoothed = 0
        return data
    }
}
