import SwiftUI

@main
struct EssayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var store = ScreenshotScene.current?.makeStore() ?? AttemptStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .preferredColorScheme(.light)
        }
    }
}
