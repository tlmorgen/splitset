import SwiftUI
import SplitSetCore

struct TimedSetView: View {
    let exercise: Exercise
    let exerciseSet: ExerciseSet
    let setNumber: Int
    let endDate: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = max(0, Int(endDate.timeIntervalSince(context.date)))

            VStack(alignment: .leading, spacing: 6) {
                Text("\(exercise.name) · \(setNumber)/\(exercise.sets.count)")
                    .font(.headline)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text(formattedTime(remaining))
                    .font(.system(.title, design: .rounded).monospacedDigit().bold())
                    .foregroundStyle(remaining <= 10 ? .orange : .purple)
                    .contentTransition(.numericText(countsDown: true))

                if let kg = exerciseSet.suggestedWeightKg {
                    Text("\(WeightUnit.current.format(kg)) suggested")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

            }
        }
    }

    private func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? String(format: "%d:%02d", m, s) : String(format: "0:%02d", s)
    }
}
