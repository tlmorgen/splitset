import SwiftUI
import SplitSetCore

struct TimedSetView: View {
    let exercise: Exercise
    let exerciseSet: ExerciseSet
    let setNumber: Int
    let endDate: Date
    let onDone: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = max(0, Int(endDate.timeIntervalSince(context.date)))

            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.name)
                    .font(.headline)
                    .minimumScaleFactor(0.6)
                    .lineLimit(2)

                Text("Set \(setNumber) of \(exercise.sets.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(formattedTime(remaining))
                    .font(.system(.title, design: .rounded).monospacedDigit().bold())
                    .foregroundStyle(remaining <= 10 ? .orange : .purple)
                    .contentTransition(.numericText(countsDown: true))

                if let kg = exerciseSet.suggestedWeightKg {
                    Text("\(WeightUnit.current.format(kg)) suggested")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 4)

                Button(action: onDone) {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
            }
        }
    }

    private func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? String(format: "%d:%02d", m, s) : String(format: "0:%02d", s)
    }
}
