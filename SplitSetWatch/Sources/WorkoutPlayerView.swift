import SwiftUI
import WatchKit
import SplitSetCore

struct WorkoutPlayerView: View {
    let workout: Workout
    let healthKit: HealthKitManager

    private let steps: [WorkoutStep]

    @State private var currentStepIndex = 0
    @State private var restEndDate: Date = .now
    @State private var restAutoAdvanced = false
    @State private var timedEndDate: Date = .now
    @State private var timedAutoAdvanced = false
    @State private var setLogs: [SetLog] = []
    @State private var pendingLift: (exercise: Exercise, exerciseSet: ExerciseSet, setNumber: Int)?
    @State private var lastWeights: [UUID: Double] = [:]
    @State private var showStopConfirm = false
    @State private var pickerWeight: Double = 0
    @Environment(\.dismiss) private var dismiss

    init(workout: Workout, healthKit: HealthKitManager) {
        self.workout = workout
        self.healthKit = healthKit
        self.steps = workout.steps()
    }

    private var isCompleted: Bool { currentStepIndex >= steps.count }
    private var currentStep: WorkoutStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }

    var body: some View {
        stepContent
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .navigationTitle {
                HStack(spacing: 2) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                        .imageScale(.small)
                    if healthKit.heartRate > 0 {
                        Text("\(Int(healthKit.heartRate)) bpm")
                            .font(.caption.monospacedDigit())
                            .contentTransition(.numericText())
                    } else {
                        Text("-- bpm")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showStopConfirm = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    bottomBar
                }
            }
        .confirmationDialog("End workout?", isPresented: $showStopConfirm) {
            Button("End Workout", role: .destructive) {
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        }
        .task { await healthKit.startWorkout() }
        .onDisappear { Task { await healthKit.endWorkout() } }
    }

    // MARK: - Bottom Bar

    @ViewBuilder
    private var bottomBar: some View {
        if isCompleted {
            EmptyView()
        } else if let pending = pendingLift, workout.trackWeights {
            HStack(spacing: 8) {
                Button("Skip") {
                    logSet(exercise: pending.exercise, exerciseSet: pending.exerciseSet, setNumber: pending.setNumber, weight: nil)
                    pendingLift = nil
                    advance()
                }
                .buttonStyle(.bordered)
                .tint(.secondary)

                Button("Log") {
                    let weight = WeightUnit.current.toKg(pickerWeight)
                    logSet(exercise: pending.exercise, exerciseSet: pending.exerciseSet, setNumber: pending.setNumber, weight: weight)
                    pendingLift = nil
                    advance()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        } else if let step = currentStep {
            switch step {
            case .lift(let exercise, let exerciseSet, let setNumber):
                let tint: Color = exerciseSet.isTimed ? .purple : .blue
                Button(action: {
                    completeLift(exercise: exercise, exerciseSet: exerciseSet, setNumber: setNumber)
                }) {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(tint)

            case .rest:
                Button("Skip") {
                    skipRest()
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        if isCompleted {
            completedView
        } else if pendingLift != nil, workout.trackWeights {
            WeightPickerView(displayWeight: $pickerWeight)
        } else if let step = currentStep {
            switch step {
            case .lift(let exercise, let exerciseSet, let setNumber):
                if exerciseSet.isTimed, let duration = exerciseSet.durationSeconds {
                    TimedSetView(
                        exercise: exercise,
                        exerciseSet: exerciseSet,
                        setNumber: setNumber,
                        endDate: timedEndDate
                    )
                    .onAppear {
                        timedEndDate = Date().addingTimeInterval(Double(duration))
                        timedAutoAdvanced = false
                        WKInterfaceDevice.current().play(.start)
                    }
                    .onChange(of: timedAutoAdvanced) { _, fired in
                        if fired { completeLift(exercise: exercise, exerciseSet: exerciseSet, setNumber: setNumber) }
                    }
                    .task(id: currentStepIndex) {
                        try? await Task.sleep(for: .seconds(duration))
                        if !timedAutoAdvanced {
                            WKInterfaceDevice.current().play(.stop)
                            timedAutoAdvanced = true
                        }
                    }
                } else {
                    LiftStepView(exercise: exercise, exerciseSet: exerciseSet, setNumber: setNumber)
                }

            case .rest(let seconds, let nextName):
                RestStepView(restEndDate: restEndDate, nextExerciseName: nextName)
                .onAppear {
                    restEndDate = Date().addingTimeInterval(Double(seconds))
                    restAutoAdvanced = false
                }
                .onChange(of: restAutoAdvanced) { _, fired in
                    if fired { advance() }
                }
                .task(id: currentStepIndex) {
                    guard case .rest(let secs, _) = currentStep else { return }
                    try? await Task.sleep(for: .seconds(secs))
                    if !restAutoAdvanced {
                        WKInterfaceDevice.current().play(.start)
                        restAutoAdvanced = true
                    }
                }
            }
        }
    }

    private var completedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.green)
            Text("Done!")
                .font(.title2.bold())
            if !setLogs.isEmpty {
                Text("\(setLogs.count) sets logged")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .task { await healthKit.endWorkout() }
    }

    // MARK: - Actions

    private func advance() {
        currentStepIndex += 1
        if currentStepIndex < steps.count, case .rest(let secs, _) = steps[currentStepIndex] {
            restEndDate = Date().addingTimeInterval(Double(secs))
            restAutoAdvanced = false
        }
        if isCompleted {
            WKInterfaceDevice.current().play(.success)
        }
    }

    private func completeLift(exercise: Exercise, exerciseSet: ExerciseSet, setNumber: Int) {
        WKInterfaceDevice.current().play(.stop)
        if workout.trackWeights && !exerciseSet.isTimed {
            let unit = WeightUnit.current
            let lastKg = lastWeights[exerciseSet.id] ?? exerciseSet.suggestedWeightKg
            pickerWeight = lastKg.map { unit.fromKg($0).rounded() } ?? unit.defaultWeight
            pendingLift = (exercise, exerciseSet, setNumber)
        } else {
            logSet(exercise: exercise, exerciseSet: exerciseSet, setNumber: setNumber, weight: nil)
            advance()
        }
    }

    private func skipRest() {
        restAutoAdvanced = true
        WKInterfaceDevice.current().play(.start)
        advance()
    }

    private func logSet(exercise: Exercise, exerciseSet: ExerciseSet, setNumber: Int, weight: Double?) {
        if let w = weight { lastWeights[exerciseSet.id] = w }
        setLogs.append(SetLog(
            exerciseSetId: exerciseSet.id,
            setNumber: setNumber,
            weightKg: weight
        ))
    }
}
