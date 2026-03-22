import SwiftUI
import SwiftData

struct WorkoutEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var trackWeights = false
    @State private var exercises: [ExerciseModel] = []
    @State private var showingAddExercise = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Workout name", text: $name)
                }

                Section("Options") {
                    Toggle("Track weights on watch", isOn: $trackWeights)
                }

                Section("Exercises") {
                    ForEach(exercises) { exercise in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.name).font(.headline)
                            Text(setsSummary(exercise))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete { offsets in
                        exercises.remove(atOffsets: offsets)
                        reorder()
                    }
                    .onMove { from, to in
                        exercises.move(fromOffsets: from, toOffset: to)
                        reorder()
                    }

                    Button {
                        showingAddExercise = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                ExerciseEditView { exercise in
                    exercise.order = exercises.count
                    exercises.append(exercise)
                }
            }
        }
    }

    private func save() {
        let workout = WorkoutModel(name: name, trackWeights: trackWeights)
        workout.exercises = exercises
        modelContext.insert(workout)
        dismiss()
    }

    private func reorder() {
        for (i, exercise) in exercises.enumerated() {
            exercise.order = i
        }
    }

    private func setsSummary(_ exercise: ExerciseModel) -> String {
        let count = exercise.sets.count
        let repParts = exercise.sets.sorted { $0.order < $1.order }.map { set in
            set.targetReps.map { "\($0)" } ?? "F"
        }
        let unique = Set(repParts)
        if unique.count == 1, let rep = repParts.first {
            return "\(count) × \(rep == "F" ? "failure" : "\(rep) reps")"
        }
        return "\(count) sets · " + repParts.joined(separator: "/") + " reps"
    }
}
