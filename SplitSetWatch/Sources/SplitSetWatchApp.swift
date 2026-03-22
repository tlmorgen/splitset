import SwiftUI

@main
struct SplitSetWatchApp: App {
    @State private var connectivity = WatchConnectivityManager()

    var body: some Scene {
        WindowGroup {
            ContentView(connectivity: connectivity)
                .task { connectivity.activate() }
        }
    }
}
