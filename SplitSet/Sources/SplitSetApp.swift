import SwiftUI
import SwiftData

@main
struct SplitSetApp: App {
    private let container: ModelContainer = {
        let schema = Schema([WorkoutModel.self, ExerciseModel.self, ExerciseSetModel.self,
                             SessionModel.self, SetLogModel.self])
        let config = ModelConfiguration(schema: schema)
        return try! ModelContainer(for: schema, migrationPlan: SplitSetMigrationPlan.self,
                                   configurations: config)
    }()

    init() {
        PhoneConnectivityManager.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
