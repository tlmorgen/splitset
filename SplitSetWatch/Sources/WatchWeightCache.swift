import Foundation

/// Persists the last logged weight (kg) per exercise set across watch app sessions.
/// Keyed by ExerciseSet.id (UUID). Survives app restarts; overridden by phone sync when available.
enum WatchWeightCache {
    private static let key = "watchWeightCache"

    static func load() -> [UUID: Double] {
        guard
            let raw = UserDefaults.standard.dictionary(forKey: key) as? [String: Double]
        else { return [:] }
        return Dictionary(uniqueKeysWithValues: raw.compactMap { k, v in
            UUID(uuidString: k).map { ($0, v) }
        })
    }

    static func save(weight: Double, for setId: UUID) {
        var raw = UserDefaults.standard.dictionary(forKey: key) as? [String: Double] ?? [:]
        raw[setId.uuidString] = weight
        UserDefaults.standard.set(raw, forKey: key)
    }
}
