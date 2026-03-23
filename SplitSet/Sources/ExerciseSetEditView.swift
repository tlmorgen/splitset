import SwiftUI
import SplitSetCore

struct ExerciseSetEditView: View {
    @Environment(\.dismiss) private var dismiss
    private var unit: WeightUnit { .current }

    let set: ExerciseSetModel
    let setNumber: Int

    @State private var isToFailure: Bool
    @State private var reps: Int
    @State private var durationMinutes: Int
    @State private var durationSeconds: Int
    @State private var hasWeight: Bool
    @State private var weight: Double
    @State private var weightEdited = false
    private let originalWeightKg: Double?

    init(set: ExerciseSetModel, setNumber: Int) {
        self.set = set
        self.setNumber = setNumber
        self.originalWeightKg = set.suggestedWeightKg
        let totalDuration = set.durationSeconds ?? 30
        self._isToFailure = State(initialValue: set.targetReps == nil && !set.isTimed)
        self._reps = State(initialValue: set.targetReps ?? 10)
        self._durationMinutes = State(initialValue: totalDuration / 60)
        self._durationSeconds = State(initialValue: totalDuration % 60)
        let u = WeightUnit.current
        self._hasWeight = State(initialValue: set.suggestedWeightKg != nil)
        self._weight = State(initialValue: u.fromKg(set.suggestedWeightKg ?? u.defaultWeight))
    }

    private var totalDurationSeconds: Int { durationMinutes * 60 + durationSeconds }

    var body: some View {
        NavigationStack {
            Form {
                if set.isTimed {
                    Section("Duration") {
                        HStack {
                            Stepper("\(durationMinutes) min", value: $durationMinutes, in: 0...60)
                            Divider()
                            Stepper("\(durationSeconds) sec", value: $durationSeconds, in: 0...59, step: 5)
                        }
                    }
                } else {
                    Section("Reps") {
                        Toggle("To failure", isOn: $isToFailure)
                        if !isToFailure {
                            Stepper("Target: \(reps)", value: $reps, in: 1...100)
                        }
                    }
                }

                Section("Suggested Weight") {
                    Toggle("Set a target weight", isOn: $hasWeight)
                    if hasWeight {
                        HStack {
                            Text("Weight")
                            Spacer()
                            TextField(unit.label, value: $weight, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .onChange(of: weight) { weightEdited = true }
                            Text(unit.label).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Set \(setNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if set.isTimed {
                            set.durationSeconds = max(totalDurationSeconds, 5)
                            set.targetReps = nil
                        } else {
                            set.durationSeconds = nil
                            set.targetReps = isToFailure ? nil : reps
                        }
                        if !hasWeight {
                            set.suggestedWeightKg = nil
                        } else if weightEdited {
                            set.suggestedWeightKg = unit.toKg(weight)
                        } else {
                            set.suggestedWeightKg = originalWeightKg
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
