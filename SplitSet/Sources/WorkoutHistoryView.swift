import SwiftUI
import SwiftData
import SplitSetCore

struct WorkoutHistoryView: View {
    let workout: WorkoutModel

    @Query private var allSessions: [SessionModel]

    init(workout: WorkoutModel) {
        self.workout = workout
        let id = workout.syncId
        _allSessions = Query(
            filter: #Predicate<SessionModel> { $0.workoutSyncId == id },
            sort: \SessionModel.completedAt,
            order: .reverse
        )
    }

    var body: some View {
        Group {
            if allSessions.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock",
                    description: Text("Complete a workout on your Apple Watch to see session history here.")
                )
            } else {
                List(allSessions) { session in
                    NavigationLink {
                        SessionDetailView(session: session, workout: workout)
                    } label: {
                        SessionRowView(session: session)
                    }
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !allSessions.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: HistoryTransferItem(workout: workout, sessions: allSessions),
                        preview: SharePreview("\(workout.name) History", image: Image(systemName: "clock"))
                    )
                }
            }
        }
    }
}

// MARK: - Session Row

private struct SessionRowView: View {
    let session: SessionModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.completedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.headline)
            HStack(spacing: 12) {
                if let end = session.endDate {
                    let duration = end.timeIntervalSince(session.startDate)
                    Label(formattedDuration(duration), systemImage: "timer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Label("\(session.setLogs.count) sets", systemImage: "dumbbell.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func formattedDuration(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}

// MARK: - Session Detail

struct SessionDetailView: View {
    let session: SessionModel
    let workout: WorkoutModel

    private var unit: WeightUnit { .current }

    private var setLogsByExercise: [(exerciseName: String, logs: [SetLogModel])] {
        let exercises = workout.exercises.sorted { $0.order < $1.order }
        var result: [(String, [SetLogModel])] = []
        for exercise in exercises {
            let setIds = Set(exercise.sets.map { $0.syncId })
            let logs = session.setLogs
                .filter { setIds.contains($0.exerciseSetId) }
                .sorted { $0.setNumber < $1.setNumber }
            if !logs.isEmpty {
                result.append((exercise.name, logs))
            }
        }
        // Append any logs not matched to an exercise (e.g. exercise deleted)
        let matchedIds = Set(result.flatMap { $0.1 }.map { $0.syncId })
        let unmatched = session.setLogs.filter { !matchedIds.contains($0.syncId) }.sorted { $0.setNumber < $1.setNumber }
        if !unmatched.isEmpty {
            result.append(("Unknown Exercise", unmatched))
        }
        return result
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Date", value: session.completedAt.formatted(date: .long, time: .shortened))
                if let end = session.endDate {
                    let duration = end.timeIntervalSince(session.startDate)
                    LabeledContent("Duration", value: formattedDuration(duration))
                }
                LabeledContent("Sets completed", value: "\(session.setLogs.count)")
            }

            ForEach(setLogsByExercise, id: \.exerciseName) { group in
                Section(group.exerciseName) {
                    ForEach(group.logs) { log in
                        SetLogRowView(log: log, unit: unit)
                    }
                }
            }
        }
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formattedDuration(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}

// MARK: - Set Log Row

private struct SetLogRowView: View {
    let log: SetLogModel
    let unit: WeightUnit

    var body: some View {
        HStack(spacing: 12) {
            Text("Set \(log.setNumber)")
                .font(.caption.bold())
                .foregroundStyle(.blue)
                .frame(width: 40, height: 24)
                .background(.blue.opacity(0.12), in: Capsule())

            VStack(alignment: .leading, spacing: 2) {
                if let kg = log.weightKg {
                    Text(unit.format(kg))
                        .font(.subheadline)
                }
                if let peak = log.peakAccelerationG {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .imageScale(.small)
                            .foregroundStyle(.orange)
                        Text(String(format: "Peak %.1fg", peak))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let avg = log.averageAccelerationG {
                            Text("·")
                                .foregroundStyle(.tertiary)
                            Text(String(format: "Avg %.1fg", avg))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Spacer()
        }
    }
}
