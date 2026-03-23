import SwiftUI
import SwiftData
import SplitSetCore

struct WorkoutListView: View {
    @Query(sort: \WorkoutModel.createdAt) var workouts: [WorkoutModel]
    @Environment(\.modelContext) var modelContext
    @State private var showingNewWorkout = false
    @State private var showingHelp = false

    var body: some View {
        NavigationStack {
            Group {
                if workouts.isEmpty {
                    emptyState
                } else {
                    workoutList
                }
            }
            .navigationTitle("SplitSet")
            .navigationDestination(for: WorkoutModel.self) { workout in
                WorkoutDetailView(workout: workout)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showingHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewWorkout = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingNewWorkout) {
                WorkoutEditView()
            }
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
            .onAppear {
                #if DEBUG
                seedSampleData()
                #endif
                PhoneConnectivityManager.shared.syncWorkouts(workouts)
            }
            .onChange(of: workouts) {
                PhoneConnectivityManager.shared.syncWorkouts(workouts)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 52))
                    .foregroundStyle(.blue)
            }

            VStack(spacing: 8) {
                Text("No Workouts Yet")
                    .font(.title2.bold())
                    .padding(.top, 24)

                Text("Build your first routine and your\nApple Watch will guide you through it.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showingNewWorkout = true
            } label: {
                Label("Create Workout", systemImage: "plus")
                    .fontWeight(.semibold)
                    .frame(maxWidth: 260)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 32)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Workout List

    private var workoutList: some View {
        List {
            ForEach(workouts) { workout in
                NavigationLink(value: workout) {
                    WorkoutRowView(workout: workout)
                }
            }
            .onDelete(perform: deleteWorkouts)
        }
    }

    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(workouts[index])
        }
    }

    #if DEBUG
    private func seedSampleData() {
        guard workouts.isEmpty else { return }
        for sample in Workout.samples {
            let workout = WorkoutModel(name: sample.name, trackWeights: sample.trackWeights)
            for (i, ex) in sample.exercises.enumerated() {
                let exercise = ExerciseModel(
                    name: ex.name,
                    notes: ex.notes,
                    order: i,
                    restSeconds: ex.restSeconds,
                    isUniform: true
                )
                for (j, s) in ex.sets.enumerated() {
                    exercise.sets.append(ExerciseSetModel(
                        targetReps: s.targetReps,
                        durationSeconds: s.durationSeconds,
                        suggestedWeightKg: s.suggestedWeightKg,
                        order: j
                    ))
                }
                workout.exercises.append(exercise)
            }
            modelContext.insert(workout)
        }
    }
    #endif
}

// MARK: - Workout Row

private struct WorkoutRowView: View {
    let workout: WorkoutModel

    var totalSets: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.count }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.blue.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.blue)
                    .imageScale(.medium)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(workout.name)
                    .font(.headline)
                HStack(spacing: 6) {
                    Text("\(workout.exercises.count) exercise\(workout.exercises.count == 1 ? "" : "s")")
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text("\(totalSets) sets")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if workout.trackWeights {
                Image(systemName: "scalemass.fill")
                    .imageScale(.small)
                    .foregroundStyle(.blue.opacity(0.6))
            }
        }
        .padding(.vertical, 4)
    }
}
