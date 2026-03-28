import UniformTypeIdentifiers
import CoreTransferable
import SplitSetCore

struct HistoryTransferItem: Transferable {
    let workout: WorkoutModel
    let sessions: [SessionModel]

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .plainText) { item in
            let markdown = item.generateMarkdown()
            let safeName = item.workout.name
                .replacingOccurrences(of: "/", with: "-")
                .replacingOccurrences(of: ":", with: "-")
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(safeName) History")
                .appendingPathExtension("md")
            try markdown.write(to: url, atomically: true, encoding: .utf8)
            return SentTransferredFile(url)
        }
    }

    private func generateMarkdown() -> String {
        let unit = WeightUnit.current
        var lines: [String] = []

        lines.append("# \(workout.name) — History")
        lines.append("")

        // Workout definition
        lines.append("## Workout")
        lines.append("")
        let exercises = workout.exercises.sorted { $0.order < $1.order }
        for exercise in exercises {
            let sets = exercise.sets.sorted { $0.order < $1.order }
            let setsLabel = sets.count == 1 ? "1 set" : "\(sets.count) sets"
            var header = "### \(exercise.name) (\(setsLabel)"
            if exercise.restSeconds > 0 { header += ", \(exercise.restSeconds)s rest" }
            header += ")"
            lines.append(header)
            if let notes = exercise.notes, !notes.isEmpty {
                lines.append("> \(notes)")
            }
            lines.append("")
            for (i, set) in sets.enumerated() {
                var desc = "- Set \(i + 1): "
                if set.isTimed, let dur = set.durationSeconds {
                    desc += dur >= 60 ? "\(dur / 60)m \(dur % 60)s" : "\(dur)s"
                } else if let reps = set.targetReps {
                    desc += "\(reps) reps"
                } else {
                    desc += "to failure"
                }
                if let kg = set.suggestedWeightKg {
                    desc += " @ \(unit.format(kg)) suggested"
                }
                lines.append(desc)
            }
            lines.append("")
        }

        // Sessions
        if sessions.isEmpty {
            lines.append("## Sessions")
            lines.append("")
            lines.append("No sessions recorded yet.")
            return lines.joined(separator: "\n")
        }

        lines.append("## Sessions")
        lines.append("")

        // Build a lookup from exerciseSetId -> (exerciseName, setNumber)
        var setInfo: [UUID: (exerciseName: String, setNumber: Int)] = [:]
        for exercise in exercises {
            for (i, set) in exercise.sets.sorted(by: { $0.order < $1.order }).enumerated() {
                setInfo[set.syncId] = (exercise.name, i + 1)
            }
        }

        let sorted = sessions.sorted { $0.completedAt > $1.completedAt }
        for session in sorted {
            let dateStr = session.completedAt.formatted(date: .abbreviated, time: .shortened)
            var sessionHeader = "### \(dateStr)"
            if let end = session.endDate {
                let secs = Int(end.timeIntervalSince(session.startDate))
                let m = secs / 60
                let s = secs % 60
                sessionHeader += " · \(m > 0 ? "\(m)m " : "")\(s)s"
            }
            lines.append(sessionHeader)
            lines.append("")

            // Group logs by exercise
            var grouped: [(name: String, logs: [SetLogModel])] = []
            var seen: [String] = []
            for exercise in exercises {
                let setIds = Set(exercise.sets.map { $0.syncId })
                let logs = session.setLogs.filter { setIds.contains($0.exerciseSetId) }.sorted { $0.setNumber < $1.setNumber }
                if !logs.isEmpty {
                    grouped.append((exercise.name, logs))
                    seen.append(exercise.name)
                }
            }

            let hasAcceleration = grouped.flatMap { $0.logs }.contains { $0.peakAccelerationG != nil }

            for group in grouped {
                lines.append("**\(group.name)**")
                lines.append("")
                if hasAcceleration {
                    lines.append("| Set | Weight | Peak | Avg |")
                    lines.append("|-----|--------|------|-----|")
                    for log in group.logs {
                        let w = log.weightKg.map { unit.format($0) } ?? "—"
                        let peak = log.peakAccelerationG.map { String(format: "%.1fg", $0) } ?? "—"
                        let avg = log.averageAccelerationG.map { String(format: "%.1fg", $0) } ?? "—"
                        lines.append("| \(log.setNumber) | \(w) | \(peak) | \(avg) |")
                    }
                } else {
                    lines.append("| Set | Weight |")
                    lines.append("|-----|--------|")
                    for log in group.logs {
                        let w = log.weightKg.map { unit.format($0) } ?? "—"
                        lines.append("| \(log.setNumber) | \(w) |")
                    }
                }
                lines.append("")
            }
        }

        return lines.joined(separator: "\n")
    }
}
