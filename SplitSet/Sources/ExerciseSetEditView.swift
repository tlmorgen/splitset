import SwiftUI

struct ExerciseSetEditView: View {
    @Environment(\.dismiss) private var dismiss

    let set: ExerciseSetModel
    let setNumber: Int

    @State private var isTimed: Bool
    @State private var isToFailure: Bool
    @State private var reps: Int
    @State private var durationMinutes: Int
    @State private var durationSeconds: Int
    @State private var hasWeight: Bool
    @State private var weight: Double
    @State private var restSeconds: Int

    init(set: ExerciseSetModel, setNumber: Int) {
        self.set = set
        self.setNumber = setNumber
        let totalDuration = set.durationSeconds ?? 30
        self._isTimed = State(initialValue: set.isTimed)
        self._isToFailure = State(initialValue: set.targetReps == nil && !set.isTimed)
        self._reps = State(initialValue: set.targetReps ?? 10)
        self._durationMinutes = State(initialValue: totalDuration / 60)
        self._durationSeconds = State(initialValue: totalDuration % 60)
        self._hasWeight = State(initialValue: set.suggestedWeightKg != nil)
        self._weight = State(initialValue: set.suggestedWeightKg ?? 20.0)
        self._restSeconds = State(initialValue: set.restSeconds)
    }

    private var totalDurationSeconds: Int { durationMinutes * 60 + durationSeconds }

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Set Type", selection: $isTimed) {
                        Text("Reps").tag(false)
                        Text("Timed").tag(true)
                    }
                    .pickerStyle(.segmented)
                }

                if isTimed {
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
                            TextField("kg", value: $weight, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Text("kg").foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Rest After") {
                    Stepper("\(restSeconds)s", value: $restSeconds, in: 0...600, step: 15)
                }
            }
            .navigationTitle("Set \(setNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if isTimed {
                            set.durationSeconds = max(totalDurationSeconds, 5)
                            set.targetReps = nil
                        } else {
                            set.durationSeconds = nil
                            set.targetReps = isToFailure ? nil : reps
                        }
                        set.suggestedWeightKg = hasWeight ? weight : nil
                        set.restSeconds = restSeconds
                        dismiss()
                    }
                }
            }
        }
    }
}
