import SwiftUI
import SplitSetCore

struct WorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        List {
            ForEach(workout.exercises) { exercise in
                Section(exercise.name) {
                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                        HStack {
                            Text("Set \(index + 1)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 44, alignment: .leading)

                            if let reps = set.targetReps {
                                Text("\(reps) reps")
                            } else {
                                Text("To failure")
                                    .foregroundStyle(.orange)
                            }

                            Spacer()

                            if let kg = set.suggestedWeightKg {
                                Text("\(kg, specifier: "%.1f") kg")
                                    .foregroundStyle(.secondary)
                            }

                            Text("\(set.restSeconds)s")
                                .foregroundStyle(.tertiary)
                                .font(.caption)
                        }
                        .font(.subheadline)
                    }
                    if let notes = exercise.notes {
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.large)
    }
}
