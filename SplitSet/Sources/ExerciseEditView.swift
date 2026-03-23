import SwiftUI

struct ExerciseEditView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var notes = ""
    @State private var restSeconds = 60

    // Uniform mode
    @State private var varyPerSet = false
    @State private var uniformIsTimed = false
    @State private var uniformCount = 3
    @State private var uniformToFailure = false
    @State private var uniformReps = 10
    @State private var uniformDurationMinutes = 0
    @State private var uniformDurationSeconds = 30
    @State private var uniformHasWeight = false
    @State private var uniformWeight = 20.0

    // Per-set mode
    @State private var sets: [ExerciseSetModel] = []
    @State private var editingSetIndex: Int?

    private let editingExercise: ExerciseModel?
    var onSave: (ExerciseModel) -> Void

    // Create mode
    init(onSave: @escaping (ExerciseModel) -> Void) {
        editingExercise = nil
        self.onSave = onSave
    }

    // Edit mode — preserves uniform vs per-set
    init(editing exercise: ExerciseModel) {
        editingExercise = exercise
        self.onSave = { _ in }
        _name = State(initialValue: exercise.name)
        _notes = State(initialValue: exercise.notes ?? "")
        _restSeconds = State(initialValue: exercise.restSeconds)
        _varyPerSet = State(initialValue: !exercise.isUniform)
        _sets = State(initialValue: exercise.sets.sorted { $0.order < $1.order })

        // Restore uniform controls from existing sets
        if exercise.isUniform, let first = exercise.sets.first {
            _uniformCount = State(initialValue: exercise.sets.count)
            _uniformIsTimed = State(initialValue: first.isTimed)
            _uniformToFailure = State(initialValue: first.targetReps == nil && !first.isTimed)
            _uniformReps = State(initialValue: first.targetReps ?? 10)
            let dur = first.durationSeconds ?? 30
            _uniformDurationMinutes = State(initialValue: dur / 60)
            _uniformDurationSeconds = State(initialValue: dur % 60)
            _uniformHasWeight = State(initialValue: first.suggestedWeightKg != nil)
            _uniformWeight = State(initialValue: first.suggestedWeightKg ?? 20.0)
        }
    }

    private var isEditing: Bool { editingExercise != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    TextField("Name (e.g. Bench Press)", text: $name)
                }

                Section {
                    if !varyPerSet {
                        Picker("Type", selection: $uniformIsTimed.animation()) {
                            Text("Reps").tag(false)
                            Text("Timed").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                        uniformRows
                    } else {
                        perSetRows
                    }

                    Toggle("Vary per set", isOn: $varyPerSet.animation())
                        .onChange(of: varyPerSet) { _, on in
                            if on { expandToPerSet() }
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

                Section("Rest Between Sets") {
                    Stepper("\(restSeconds)s", value: $restSeconds, in: 0...600, step: 15)
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Exercise" : "New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Done" : "Add") {
                        save()
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

            if uniformIsTimed {
                HStack {
                    Stepper("\(uniformDurationMinutes) min", value: $uniformDurationMinutes, in: 0...60)
                    Divider()
                    Stepper("\(uniformDurationSeconds) sec", value: $uniformDurationSeconds, in: 0...59, step: 5)
                }
            } else {
                Toggle("To failure", isOn: $uniformToFailure)
                if !uniformToFailure {
                    Stepper("Reps: \(uniformReps)", value: $uniformReps, in: 1...100)
                }
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

    // MARK: - Save

    private func save() {
        if let existing = editingExercise {
            existing.name = name
            existing.notes = notes.isEmpty ? nil : notes
            existing.restSeconds = restSeconds
            existing.isUniform = !varyPerSet
            if varyPerSet {
                existing.sets = sets
            } else {
                // Rebuild uniform sets
                let newSets = buildUniformSets()
                existing.sets = newSets
            }
            reorderSets(existing.sets)
        } else {
            let exercise = ExerciseModel(
                name: name,
                notes: notes.isEmpty ? nil : notes,
                restSeconds: restSeconds,
                isUniform: !varyPerSet
            )
            exercise.sets = varyPerSet ? sets : buildUniformSets()
            onSave(exercise)
        }
    }

    // MARK: - Helpers

    private func expandToPerSet() {
        let duration = uniformIsTimed ? uniformDurationMinutes * 60 + uniformDurationSeconds : nil
        sets = (0..<uniformCount).map { i in
            ExerciseSetModel(
                targetReps: uniformIsTimed ? nil : (uniformToFailure ? nil : uniformReps),
                durationSeconds: duration,
                suggestedWeightKg: uniformHasWeight ? uniformWeight : nil,
                order: i
            )
        }
    }

    private func buildUniformSets() -> [ExerciseSetModel] {
        let duration = uniformIsTimed ? uniformDurationMinutes * 60 + uniformDurationSeconds : nil
        return (0..<uniformCount).map { i in
            ExerciseSetModel(
                targetReps: uniformIsTimed ? nil : (uniformToFailure ? nil : uniformReps),
                durationSeconds: duration,
                suggestedWeightKg: uniformHasWeight ? uniformWeight : nil,
                order: i
            )
        }
    }

    private func duplicatingLast() -> ExerciseSetModel {
        let last = sets.last
        let isTimed = last?.isTimed ?? false
        return ExerciseSetModel(
            targetReps: isTimed ? nil : (last?.targetReps ?? 10),
            durationSeconds: last?.durationSeconds,
            suggestedWeightKg: last?.suggestedWeightKg,
            order: sets.count
        )
    }

    private func reorderSets(_ target: [ExerciseSetModel]? = nil) {
        for (i, set) in (target ?? sets).enumerated() { set.order = i }
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
                if set.isTimed, let dur = set.durationSeconds {
                    Label(dur >= 60 ? "\(dur/60)m \(dur%60)s" : "\(dur)s", systemImage: "timer")
                        .font(.subheadline).foregroundStyle(.purple)
                } else if let reps = set.targetReps {
                    Text("\(reps) reps").font(.subheadline)
                } else {
                    Text("To failure").font(.subheadline).foregroundStyle(.orange)
                }
                if let kg = set.suggestedWeightKg {
                    Text("\(kg, specifier: "%.1f") kg")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            Spacer()
            Image(systemName: "chevron.right").imageScale(.small).foregroundStyle(.tertiary)
        }
    }
}
