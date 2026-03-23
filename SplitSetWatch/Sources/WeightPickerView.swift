import SwiftUI
import SplitSetCore

struct WeightPickerView: View {
    @State private var displayWeight: Double
    let onConfirm: (Double?) -> Void

    private var unit: WeightUnit { .current }

    init(lastWeight: Double?, onConfirm: @escaping (Double?) -> Void) {
        let u = WeightUnit.current
        if let kg = lastWeight {
            self._displayWeight = State(initialValue: u.fromKg(kg).rounded())
        } else {
            self._displayWeight = State(initialValue: u.defaultWeight)
        }
        self.onConfirm = onConfirm
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("Log Weight")
                .font(.headline)

            Text(String(format: "%.0f %@", displayWeight, unit.label))
                .font(.title2.bold().monospacedDigit())
                .focusable()
                .digitalCrownRotation(
                    $displayWeight,
                    from: 0,
                    through: unit.maxWeight,
                    by: unit.step,
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )

            HStack(spacing: 8) {
                Button("Skip") { onConfirm(nil) }
                    .buttonStyle(.bordered)
                    .tint(.secondary)

                Button("Log") { onConfirm(unit.toKg(displayWeight)) }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
            }
        }
    }
}
