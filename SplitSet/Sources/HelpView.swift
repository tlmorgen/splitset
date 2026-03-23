import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.blue.opacity(0.1))
                                .frame(width: 80, height: 80)
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 36))
                                .foregroundStyle(.blue)
                        }

                        Text("SplitSet")
                            .font(.title2.bold())

                        Text("Build on iPhone. Lift on Apple Watch.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .listRowBackground(Color.clear)
                }

                Section("Getting Started") {
                    HelpRow(
                        icon: "plus.circle.fill",
                        color: .blue,
                        title: "Create a Workout",
                        detail: "Tap + to build a workout. Give it a name, add exercises, and configure sets with rep targets or durations."
                    )
                    HelpRow(
                        icon: "applewatch",
                        color: .green,
                        title: "Sync to Watch",
                        detail: "Workouts sync to your Apple Watch automatically. Just open SplitSet on your watch to see them."
                    )
                    HelpRow(
                        icon: "play.circle.fill",
                        color: .orange,
                        title: "Start Lifting",
                        detail: "Select a workout on your watch and follow the guided steps. Your watch walks you through every set and rest period."
                    )
                }

                Section("Workout Builder Tips") {
                    HelpRow(
                        icon: "square.fill.on.square.fill",
                        color: .purple,
                        title: "Uniform vs. Per-Set",
                        detail: "Uniform mode creates identical sets — great for simple routines. Switch to per-set to configure each set individually for progressive overload."
                    )
                    HelpRow(
                        icon: "flame.fill",
                        color: .orange,
                        title: "To-Failure Sets",
                        detail: "Set the rep target to 0 to create a to-failure (AMRAP) set. Your watch will show \"To failure\" instead of a number."
                    )
                    HelpRow(
                        icon: "timer",
                        color: .purple,
                        title: "Timed Sets",
                        detail: "Switch a set to timed mode for cardio, planks, or any duration-based work. The watch counts down automatically."
                    )
                    HelpRow(
                        icon: "clock.arrow.circlepath",
                        color: .teal,
                        title: "Rest Between Sets",
                        detail: "Set a rest duration per exercise. The watch auto-advances after the rest countdown and lets you skip if you're ready early."
                    )
                }

                Section("On Your Watch") {
                    HelpRow(
                        icon: "heart.fill",
                        color: .red,
                        title: "Live Heart Rate",
                        detail: "Your heart rate is shown throughout the workout. SplitSet starts a HealthKit workout session for accurate tracking."
                    )
                    HelpRow(
                        icon: "scalemass.fill",
                        color: .blue,
                        title: "Weight Logging",
                        detail: "When weight tracking is on, use the Digital Crown to log the weight you used after each set. It pre-fills from your last session."
                    )
                    HelpRow(
                        icon: "water.waves",
                        color: .cyan,
                        title: "Haptic Cues",
                        detail: "Haptics tell you when a set is done, rest starts and ends, and when the workout is complete — so you can stay focused without watching the screen."
                    )
                }

                Section {
                    HStack {
                        Spacer()
                        Text("Made for the gym, not the couch.")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Help Row

private struct HelpRow: View {
    let icon: String
    let color: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }
}
