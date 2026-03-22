import SwiftUI
import SwiftData

@main
struct SplitSetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: WorkoutModel.self)
    }
}
