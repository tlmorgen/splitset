import SwiftUI
import SplitSetCore

struct WorkoutEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var exercises: [Exercise] = []
    @State private var trackWeights = false
    @State private var showingAddExercise = false

    var onSave: (Workout) -> Void

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
                    .onDelete { exercises.remove(atOffsets: $0) }
                    .onMove { exercises.move(fromOffsets: $0, toOffset: $1) }

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
                        onSave(Workout(name: name, exercises: exercises, trackWeights: trackWeights))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                ExerciseEditView { exercise in
                    exercises.append(exercise)
                }
            }
        }
    }

    private func setsSummary(_ exercise: Exercise) -> String {
        let count = exercise.sets.count
        let repParts = exercise.sets.map { set in
            set.targetReps.map { "\($0)" } ?? "F"
        }
        let unique = Set(repParts)
        if unique.count == 1, let rep = repParts.first {
            return "\(count) × \(rep == "F" ? "failure" : "\(rep) reps")"
        }
        return "\(count) sets · " + repParts.joined(separator: "/") + " reps"
    }
}
