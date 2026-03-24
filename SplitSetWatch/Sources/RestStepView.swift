import SwiftUI

struct RestStepView: View {
    let restEndDate: Date
    let nextExerciseName: String

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = max(0, Int(restEndDate.timeIntervalSince(context.date)))

            VStack(spacing: 6) {
                Text("Rest")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(formattedTime(remaining))
                    .font(.system(.title, design: .rounded).monospacedDigit().bold())
                    .foregroundStyle(remaining <= 10 ? .orange : .primary)
                    .contentTransition(.numericText(countsDown: true))

                Text("Next: \(nextExerciseName)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

            }
        }
    }

    private func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m > 0 ? String(format: "%d:%02d", m, s) : String(format: "0:%02d", s)
    }
}
