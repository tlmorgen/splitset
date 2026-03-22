import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Query(sort: \WorkoutModel.createdAt) var workouts: [WorkoutModel]
    @Environment(\.modelContext) var modelContext
    @State private var showingNewWorkout = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(workouts) { workout in
                    NavigationLink(value: workout) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(workout.name)
                                .font(.headline)
                            Text("\(workout.exercises.count) exercise\(workout.exercises.count == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .onDelete(perform: deleteWorkouts)
            }
            .navigationTitle("SplitSet")
            .navigationDestination(for: WorkoutModel.self) { workout in
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
                WorkoutEditView()
            }
            .onAppear {
                PhoneConnectivityManager.shared.syncWorkouts(workouts)
            }
            .onChange(of: workouts) {
                PhoneConnectivityManager.shared.syncWorkouts(workouts)
            }
        }
    }

    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(workouts[index])
        }
    }
}
