import SwiftUI
import SwiftData

struct WorkoutEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let editingWorkout: WorkoutModel?

    @State private var name: String
    @State private var trackWeights: Bool
    @State private var exercises: [ExerciseModel]
    @State private var showingAddExercise = false
    @State private var editingExercise: ExerciseModel?

    // Create mode
    init() {
        editingWorkout = nil
        _name = State(initialValue: "")
        _trackWeights = State(initialValue: false)
        _exercises = State(initialValue: [])
    }

    // Edit mode
    init(editing workout: WorkoutModel) {
        editingWorkout = workout
        _name = State(initialValue: workout.name)
        _trackWeights = State(initialValue: workout.trackWeights)
        _exercises = State(initialValue: workout.exercises.sorted { $0.order < $1.order })
    }

    private var isEditing: Bool { editingWorkout != nil }
    private var title: String { isEditing ? "Edit Workout" : "New Workout" }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Workout name", text: $name)
                }

                Section("Options") {
                    Toggle("Track weights on watch", isOn: $trackWeights)
                }

                Section {
                    ForEach(exercises) { exercise in
                        Button {
                            editingExercise = exercise
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(setsSummary(exercise))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .imageScale(.small)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .onDelete { offsets in
                        if isEditing {
                            offsets.map { exercises[$0] }.forEach { modelContext.delete($0) }
                        }
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
                } header: {
                    HStack {
                        Text("Exercises")
                        Spacer()
                        EditButton()
                            .font(.caption)
                            .textCase(nil)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                ExerciseEditView { exercise in
                    exercise.order = exercises.count
                    if isEditing { modelContext.insert(exercise) }
                    exercises.append(exercise)
                }
            }
            .sheet(item: $editingExercise) { exercise in
                ExerciseEditView(editing: exercise)
            }
        }
    }

    // MARK: - Actions

    private func save() {
        if let existing = editingWorkout {
            existing.name = name
            existing.trackWeights = trackWeights
            existing.exercises = exercises
            reorder()
        } else {
            let workout = WorkoutModel(name: name, trackWeights: trackWeights)
            workout.exercises = exercises
            modelContext.insert(workout)
        }
        dismiss()
    }

    private func reorder() {
        for (i, exercise) in exercises.enumerated() {
            exercise.order = i
        }
    }

    private func setsSummary(_ exercise: ExerciseModel) -> String {
        let sorted = exercise.sets.sorted { $0.order < $1.order }
        let count = sorted.count

        let labels = sorted.map { set -> String in
            if set.isTimed, let dur = set.durationSeconds {
                return dur >= 60 ? "\(dur / 60)m \(dur % 60)s" : "\(dur)s"
            }
            if let reps = set.targetReps { return "\(reps) reps" }
            return "failure"
        }

        let unique = Set(labels)
        if unique.count == 1, let label = labels.first {
            return "\(count) × \(label)"
        }

        let preview = labels.prefix(3).joined(separator: ", ")
        return count > 3 ? "\(preview), …" : preview
    }
}
