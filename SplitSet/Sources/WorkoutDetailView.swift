import SwiftUI

struct WorkoutDetailView: View {
    let workout: WorkoutModel

    var body: some View {
        List {
            ForEach(workout.exercises.sorted { $0.order < $1.order }) { exercise in
                Section(exercise.name) {
                    ForEach(exercise.sets.sorted { $0.order < $1.order }) { set in
                        HStack {
                            Text("Set \(set.order + 1)")
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
