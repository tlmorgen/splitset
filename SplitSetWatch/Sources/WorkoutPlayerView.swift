import SwiftUI
import WatchKit
import SplitSetCore

struct WorkoutPlayerView: View {
    let workout: Workout
    let healthKit: HealthKitManager

    private let steps: [WorkoutStep]

    @State private var currentStepIndex = 0
    @State private var restEndDate: Date = .now
    @State private var setLogs: [SetLog] = []
    @State private var pendingLift: (exercise: Exercise, exerciseSet: ExerciseSet, setNumber: Int)?
    @State private var lastWeights: [UUID: Double] = [:]
    @State private var restAutoAdvanced = false

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
        VStack(spacing: 0) {
            heartRateHeader
            Divider()
            stepContent
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await healthKit.startWorkout() }
        .onDisappear { Task { await healthKit.endWorkout() } }
    }

    // MARK: - Header

    private var heartRateHeader: some View {
        HStack {
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
            Spacer()
            if !isCompleted {
                Text("\(currentStepIndex + 1)/\(steps.count)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        if isCompleted {
            completedView
        } else if let pending = pendingLift, workout.trackWeights {
            WeightPickerView(
                lastWeight: lastWeights[pending.exerciseSet.id] ?? pending.exerciseSet.suggestedWeightKg
            ) { weight in
                logSet(exercise: pending.exercise, exerciseSet: pending.exerciseSet, setNumber: pending.setNumber, weight: weight)
                pendingLift = nil
                advance()
            }
        } else if let step = currentStep {
            switch step {
            case .lift(let exercise, let exerciseSet, let setNumber):
                LiftStepView(exercise: exercise, exerciseSet: exerciseSet, setNumber: setNumber) {
                    WKInterfaceDevice.current().play(.stop)
                    if workout.trackWeights {
                        pendingLift = (exercise, exerciseSet, setNumber)
                    } else {
                        logSet(exercise: exercise, exerciseSet: exerciseSet, setNumber: setNumber, weight: nil)
                        advance()
                    }
                }

            case .rest(let seconds, let nextName):
                RestStepView(restEndDate: restEndDate, nextExerciseName: nextName) {
                    skipRest()
                }
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
