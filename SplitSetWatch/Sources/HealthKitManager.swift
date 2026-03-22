import Foundation
import HealthKit
import Observation

@Observable
@MainActor
final class HealthKitManager: NSObject {
    var heartRate: Double = 0
    var isSessionActive = false
    var authorizationDenied = false

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let typesToShare: Set<HKSampleType> = [HKQuantityType.workoutType()]
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType(.heartRate),
            HKQuantityType.workoutType()
        ]
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
            authorizationDenied = true
        }
    }

    func startWorkout() async {
        guard !isSessionActive else { return }
        let config = HKWorkoutConfiguration()
        config.activityType = .traditionalStrengthTraining
        config.locationType = .indoor

        do {
            let newSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            let newBuilder = newSession.associatedWorkoutBuilder()
            newBuilder.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: config
            )
            newSession.delegate = self
            newBuilder.delegate = self
            self.session = newSession
            self.builder = newBuilder

            newSession.startActivity(with: Date())
            try await newBuilder.beginCollection(at: Date())
            isSessionActive = true
        } catch {
            // HealthKit unavailable in simulator — fail silently
        }
    }

    func endWorkout() async {
        guard isSessionActive else { return }
        session?.end()
        do {
            try await builder?.endCollection(at: Date())
            try await builder?.finishWorkout()
        } catch {}
        isSessionActive = false
        session = nil
        builder = nil
    }
}

// MARK: - HKWorkoutSessionDelegate

extension HealthKitManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {}

    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {}
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension HealthKitManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    nonisolated func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        guard collectedTypes.contains(HKQuantityType(.heartRate)) else { return }
        let bpm = workoutBuilder
            .statistics(for: HKQuantityType(.heartRate))?
            .mostRecentQuantity()?
            .doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
        Task { @MainActor [weak self] in
            self?.heartRate = bpm
        }
    }
}
