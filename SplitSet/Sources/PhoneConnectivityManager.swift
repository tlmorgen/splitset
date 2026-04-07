import Foundation
import WatchConnectivity
import Observation
import SplitSetCore

@Observable
@MainActor
final class PhoneConnectivityManager: NSObject {
    static let shared = PhoneConnectivityManager()

    var isWatchReachable = false
    var receivedSessions: [WorkoutSession] = []

    private let session = WCSession.default

    func activate() {
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
    }

    func syncWorkouts(_ workouts: [WorkoutModel]) {
        guard session.activationState == .activated else { return }
        let structs = workouts.sorted { $0.createdAt < $1.createdAt }.map { $0.toWorkout() }
        guard let data = try? JSONEncoder().encode(structs) else { return }
        try? session.updateApplicationContext([ConnectivityMessage.workoutsKey: data])
    }
}

extension PhoneConnectivityManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            isWatchReachable = session.isWatchAppInstalled
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        guard
            let data = userInfo[ConnectivityMessage.sessionKey] as? Data,
            let decoded = try? JSONDecoder().decode(WorkoutSession.self, from: data)
        else { return }
        Task { @MainActor in
            self.receivedSessions.append(decoded)
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in
            isWatchReachable = session.isWatchAppInstalled
        }
    }
}
