import SwiftUI
import SplitSetCore

struct WeightPickerView: View {
    @Binding var displayWeight: Double

    private var unit: WeightUnit { .current }

    init(displayWeight: Binding<Double>) {
        self._displayWeight = displayWeight
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

        }
    }
}
