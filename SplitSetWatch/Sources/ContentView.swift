import SwiftUI
import SplitSetCore

struct ContentView: View {
    let connectivity: WatchConnectivityManager
    @State private var healthKit = HealthKitManager()

    var body: some View {
        NavigationStack {
            List(connectivity.workouts) { workout in
                NavigationLink(value: workout) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(workout.name)
                            .font(.headline)
                        Text("\(workout.exercises.count) exercise\(workout.exercises.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("SplitSet")
            .navigationDestination(for: Workout.self) { workout in
                WorkoutPlayerView(workout: workout, healthKit: healthKit, connectivity: connectivity)
            }
            .overlay {
                if connectivity.workouts.isEmpty {
                    ContentUnavailableView(
                        "No Workouts",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Build workouts in the iPhone app.")
                    )
                }
            }
        }
        .task { await healthKit.requestAuthorization() }
    }
}
