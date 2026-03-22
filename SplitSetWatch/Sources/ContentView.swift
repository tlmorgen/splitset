import SwiftUI
import SplitSetCore

struct ContentView: View {
    @State private var workouts: [Workout] = [.sample]
    @State private var healthKit = HealthKitManager()

    var body: some View {
        NavigationStack {
            List(workouts) { workout in
                NavigationLink(value: workout) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(workout.name)
                            .font(.headline)
                        Text("\(workout.exercises.count) exercises")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("SplitSet")
            .navigationDestination(for: Workout.self) { workout in
                WorkoutPlayerView(workout: workout, healthKit: healthKit)
            }
            .overlay {
                if workouts.isEmpty {
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
