import UniformTypeIdentifiers
import CoreTransferable
import SplitSetCore

extension UTType {
    static let splitsetWorkout = UTType(exportedAs: "com.tlmorgen.splitset.workout")
}

struct WorkoutTransferItem: Transferable {
    let workout: Workout

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .splitsetWorkout) { item in
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(item.workout)
            let safeName = item.workout.name
                .replacingOccurrences(of: "/", with: "-")
                .replacingOccurrences(of: ":", with: "-")
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(safeName)
                .appendingPathExtension("splitset")
            try data.write(to: url)
            return SentTransferredFile(url)
        }
    }
}
