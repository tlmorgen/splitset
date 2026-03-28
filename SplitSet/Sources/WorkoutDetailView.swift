import SwiftUI
import SwiftData
import SplitSetCore

struct WorkoutDetailView: View {
    let workout: WorkoutModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        List {
            ForEach(workout.exercises.sorted { $0.order < $1.order }) { exercise in
                Section {
                    ForEach(exercise.sets.sorted { $0.order < $1.order }) { set in
                        SetRowView(setNumber: set.order + 1, set: set)
                    }
                    .onDelete { offsets in
                        let sorted = exercise.sets.sorted { $0.order < $1.order }
                        offsets.map { sorted[$0] }.forEach { modelContext.delete($0) }
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
                        HStack(spacing: 8) {
                            if exercise.restSeconds > 0 {
                                Label("\(exercise.restSeconds)s rest", systemImage: "timer")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .textCase(nil)
                            }
                            Text("\(exercise.sets.count) sets")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .textCase(nil)
                        }
                    }
                }
            }

            Section {
                Button("Delete Workout", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            }
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ShareLink(
                    item: WorkoutTransferItem(workout: workout.toWorkout()),
                    preview: SharePreview(workout.name, image: Image("ShareIcon"))
                )
            }
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 16) {
                    NavigationLink {
                        WorkoutHistoryView(workout: workout)
                    } label: {
                        Image(systemName: "clock")
                    }
                    Button("Edit") { showingEdit = true }
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            WorkoutEditView(editing: workout)
        }
        .confirmationDialog(
            "Delete \"\(workout.name)\"?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Workout", role: .destructive) {
                modelContext.delete(workout)
                dismiss()
            }
        } message: {
            Text("This cannot be undone.")
        }
    }
}

// MARK: - Set Row

private struct SetRowView: View {
    private var unit: WeightUnit { .current }
    let setNumber: Int
    let set: ExerciseSetModel

    var body: some View {
        HStack(spacing: 12) {
            Text("\(setNumber)")
                .font(.caption.bold())
                .foregroundStyle(.blue)
                .frame(width: 24, height: 24)
                .background(.blue.opacity(0.12), in: Circle())

            if set.isTimed {
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                        .imageScale(.small)
                    Text(formattedDuration(set.durationSeconds ?? 0))
                }
                .font(.subheadline)
                .foregroundStyle(.purple)
            } else if let reps = set.targetReps {
                Text("\(reps) reps").font(.subheadline)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").imageScale(.small)
                    Text("To failure")
                }
                .font(.subheadline)
                .foregroundStyle(.orange)
            }

            Spacer()

            if let kg = set.suggestedWeightKg {
                Label(unit.format(kg), systemImage: "scalemass.fill")
                    .font(.caption)
                    .foregroundStyle(.blue.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.blue.opacity(0.08), in: Capsule())
            }
        }
    }

    private func formattedDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}
