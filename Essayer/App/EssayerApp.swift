import SwiftUI

@main
struct EssayerApp: App {
    @State private var store = AttemptStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .preferredColorScheme(.light)
        }
    }
}
