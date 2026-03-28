import SwiftUI
import SwiftData

@main
struct SplitSetApp: App {
    init() {
        PhoneConnectivityManager.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [WorkoutModel.self, SessionModel.self],
                        migrationPlan: SplitSetMigrationPlan.self)
    }
}
