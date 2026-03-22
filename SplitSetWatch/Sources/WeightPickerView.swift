import SwiftUI

struct WeightPickerView: View {
    @State private var weight: Double
    let onConfirm: (Double?) -> Void

    init(lastWeight: Double?, onConfirm: @escaping (Double?) -> Void) {
        self._weight = State(initialValue: lastWeight ?? 20.0)
        self.onConfirm = onConfirm
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Log Weight")
                .font(.headline)

            Text(String(format: "%.1f kg", weight))
                .font(.title2.bold().monospacedDigit())
                .focusable()
                .digitalCrownRotation(
                    $weight,
                    from: 0,
                    through: 500,
                    by: 0.5,
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )

            HStack(spacing: 8) {
                Button("Skip") { onConfirm(nil) }
                    .buttonStyle(.bordered)
                    .tint(.secondary)

                Button("Log") { onConfirm(weight) }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
            }
        }
    }
}
