import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutModel
    @State private var showingEdit = false

    var body: some View {
        List {
            ForEach(workout.exercises.sorted { $0.order < $1.order }) { exercise in
                Section {
                    ForEach(exercise.sets.sorted { $0.order < $1.order }) { set in
                        SetRowView(setNumber: set.order + 1, set: set)
                    }
                    if let notes = exercise.notes {
                        Label(notes, systemImage: "note.text")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    HStack {
                        Text(exercise.name)
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                            .textCase(nil)
                        Spacer()
                        Text("\(exercise.sets.count) sets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(nil)
                    }
                }
            }
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            WorkoutEditView(editing: workout)
        }
    }
}

// MARK: - Set Row

private struct SetRowView: View {
    let setNumber: Int
    let set: ExerciseSetModel

    var body: some View {
        HStack(spacing: 12) {
            // Set number badge
            Text("\(setNumber)")
                .font(.caption.bold())
                .foregroundStyle(.blue)
                .frame(width: 24, height: 24)
                .background(.blue.opacity(0.12), in: Circle())

            // Reps
            if let reps = set.targetReps {
                Text("\(reps) reps")
                    .font(.subheadline)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .imageScale(.small)
                    Text("To failure")
                }
                .font(.subheadline)
                .foregroundStyle(.orange)
            }

            Spacer()

            // Weight
            if let kg = set.suggestedWeightKg {
                Label("\(kg, specifier: "%.1f") kg", systemImage: "scalemass.fill")
                    .font(.caption)
                    .foregroundStyle(.blue.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.blue.opacity(0.08), in: Capsule())
            }

            // Rest
            if set.restSeconds > 0 {
                Label("\(set.restSeconds)s", systemImage: "timer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
