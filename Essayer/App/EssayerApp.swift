import SwiftUI

@main
struct EssayerApp: App {
    @State private var store = ScreenshotScene.current?.makeStore() ?? AttemptStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .preferredColorScheme(.light)
        }
    }
}
