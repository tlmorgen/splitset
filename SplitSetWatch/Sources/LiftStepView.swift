import SwiftUI
import SplitSetCore

struct LiftStepView: View {
    let exercise: Exercise
    let exerciseSet: ExerciseSet
    let setNumber: Int
    var currentAcceleration: Double = 0

    var body: some View {
        ScrollView {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(exercise.name) · \(setNumber)/\(exercise.sets.count)")
                .font(.headline)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            if exerciseSet.isTimed, let dur = exerciseSet.durationSeconds {
                Label(dur >= 60 ? "\(dur/60)m \(dur%60)s" : "\(dur)s", systemImage: "timer")
                    .font(.title2.bold())
                    .foregroundStyle(.purple)
            } else if let reps = exerciseSet.targetReps {
                Text("\(reps) reps")
                    .font(.title2.bold())
                    .foregroundStyle(.blue)
            } else {
                Text("To failure")
                    .font(.title2.bold())
                    .foregroundStyle(.orange)
            }

            if currentAcceleration > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "waveform.path")
                        .imageScale(.small)
                    Text(String(format: "%.1fg", currentAcceleration))
                        .monospacedDigit()
                }
                .font(.caption)
                .foregroundStyle(accelerationColor)
                .contentTransition(.numericText())
            }

            if let kg = exerciseSet.suggestedWeightKg {
                Text("\(WeightUnit.current.format(kg)) suggested")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let notes = exercise.notes {
                Text(notes)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

        }
        .padding(.bottom, 50)
        }
    }

    private var accelerationColor: Color {
        if currentAcceleration < 1.0 { return .green }
        if currentAcceleration < 2.0 { return .yellow }
        return .red
    }
}
