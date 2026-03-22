import SwiftUI

struct ExerciseEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var notes = ""

    // Uniform mode
    @State private var varyPerSet = false
    @State private var uniformCount = 3
    @State private var uniformToFailure = false
    @State private var uniformReps = 10
    @State private var uniformHasWeight = false
    @State private var uniformWeight = 20.0
    @State private var uniformRest = 60

    // Per-set mode
    @State private var sets: [ExerciseSetModel] = []
    @State private var editingSetIndex: Int?

    var onSave: (ExerciseModel) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Name (e.g. Bench Press)", text: $name)
                }

                Section {
                    Toggle("Vary per set", isOn: $varyPerSet.animation())
                        .onChange(of: varyPerSet) { _, on in
                            if on { expandToPerSet() }
                        }

                    if varyPerSet {
                        perSetRows
                    } else {
                        uniformRows
                    }
                } header: {
                    HStack {
                        Text("Sets")
                        if varyPerSet {
                            Spacer()
                            EditButton()
                                .font(.caption)
                                .textCase(nil)
                        }
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let exercise = ExerciseModel(name: name, notes: notes.isEmpty ? nil : notes)
                        exercise.sets = buildSets()
                        onSave(exercise)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .sheet(item: Binding(
                get: { editingSetIndex.map { SetEditIndex(index: $0) } },
                set: { editingSetIndex = $0?.index }
            )) { item in
                ExerciseSetEditView(set: sets[item.index], setNumber: item.index + 1)
            }
        }
    }

    // MARK: - Uniform rows

    private var uniformRows: some View {
        Group {
            Stepper("Sets: \(uniformCount)", value: $uniformCount, in: 1...20)
            Toggle("To failure", isOn: $uniformToFailure)
            if !uniformToFailure {
                Stepper("Reps: \(uniformReps)", value: $uniformReps, in: 1...100)
            }
            Toggle("Suggested weight", isOn: $uniformHasWeight)
            if uniformHasWeight {
                HStack {
                    Text("Weight")
                    Spacer()
                    TextField("kg", value: $uniformWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text("kg").foregroundStyle(.secondary)
                }
            }
            Stepper("Rest: \(uniformRest)s", value: $uniformRest, in: 0...600, step: 15)
        }
    }

    // MARK: - Per-set rows

    private var perSetRows: some View {
        Group {
            ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                Button { editingSetIndex = index } label: {
                    SetRowView(setNumber: index + 1, set: set)
                }
                .foregroundStyle(.primary)
            }
            .onDelete { offsets in
                sets.remove(atOffsets: offsets)
                reorderSets()
            }
            .onMove { from, to in
                sets.move(fromOffsets: from, toOffset: to)
                reorderSets()
            }

            Button {
                sets.append(duplicatingLast())
            } label: {
                Label("Add Set", systemImage: "plus")
            }
        }
    }

    // MARK: - Helpers

    private func expandToPerSet() {
        sets = (0..<uniformCount).map { i in
            ExerciseSetModel(
                targetReps: uniformToFailure ? nil : uniformReps,
                suggestedWeightKg: uniformHasWeight ? uniformWeight : nil,
                restSeconds: uniformRest,
                order: i
            )
        }
    }

    private func buildSets() -> [ExerciseSetModel] {
        if varyPerSet {
            return sets
        }
        return (0..<uniformCount).map { i in
            ExerciseSetModel(
                targetReps: uniformToFailure ? nil : uniformReps,
                suggestedWeightKg: uniformHasWeight ? uniformWeight : nil,
                restSeconds: uniformRest,
                order: i
            )
        }
    }

    private func duplicatingLast() -> ExerciseSetModel {
        let last = sets.last
        return ExerciseSetModel(
            targetReps: last?.targetReps ?? 10,
            suggestedWeightKg: last?.suggestedWeightKg,
            restSeconds: last?.restSeconds ?? 60,
            order: sets.count
        )
    }

    private func reorderSets() {
        for (i, set) in sets.enumerated() { set.order = i }
    }
}

// MARK: - Supporting types

private struct SetEditIndex: Identifiable {
    let index: Int
    var id: Int { index }
}

private struct SetRowView: View {
    let setNumber: Int
    let set: ExerciseSetModel

    var body: some View {
        HStack {
            Text("Set \(setNumber)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                if let reps = set.targetReps {
                    Text("\(reps) reps").font(.subheadline)
                } else {
                    Text("To failure").font(.subheadline).foregroundStyle(.orange)
                }
                HStack(spacing: 6) {
                    if let kg = set.suggestedWeightKg {
                        Text("\(kg, specifier: "%.1f") kg")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Text("\(set.restSeconds)s rest")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            Spacer()
            Image(systemName: "chevron.right").imageScale(.small).foregroundStyle(.tertiary)
        }
    }
}
