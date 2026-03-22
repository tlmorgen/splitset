import SwiftUI
import SplitSetCore

struct WorkoutListView: View {
    @State private var workouts: [Workout] = []
    @State private var showingNewWorkout = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(workouts) { workout in
                    NavigationLink(workout.name, value: workout)
                }
                .onDelete(perform: deleteWorkouts)
            }
            .navigationTitle("SplitSet")
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetailView(workout: workout)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewWorkout = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewWorkout) {
                WorkoutEditView { newWorkout in
                    workouts.append(newWorkout)
                }
            }
        }
    }

    private func deleteWorkouts(at offsets: IndexSet) {
        workouts.remove(atOffsets: offsets)
    }
}
