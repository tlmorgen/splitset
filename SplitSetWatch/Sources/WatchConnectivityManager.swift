import Foundation
import WatchConnectivity
import Observation
import SplitSetCore

@Observable
@MainActor
final class WatchConnectivityManager: NSObject {
    var workouts: [Workout] = []

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func update(from context: [String: Any]) {
        guard
            let data = context[ConnectivityMessage.workoutsKey] as? Data,
            let decoded = try? JSONDecoder().decode([Workout].self, from: data)
        else { return }
        workouts = decoded
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        // Pick up any context that arrived while the app was not running
        Task { @MainActor in
            update(from: session.receivedApplicationContext)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        Task { @MainActor in
            update(from: applicationContext)
        }
    }
}
