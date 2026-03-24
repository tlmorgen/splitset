import SwiftUI
import SplitSetCore

struct LiftStepView: View {
    let exercise: Exercise
    let exerciseSet: ExerciseSet
    let setNumber: Int

    var body: some View {
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

            if let kg = exerciseSet.suggestedWeightKg {
                Text("\(WeightUnit.current.format(kg)) suggested")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let notes = exercise.notes {
                Text(notes)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }

        }
    }
}
