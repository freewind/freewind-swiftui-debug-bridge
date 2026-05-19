import SwiftUI

@main
struct FreewindSwiftUIDebugServerDemoApp: App {
    @State private var shell = DemoAppShell()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(shell)
                .environment(shell.debugBridge.registry)
                .task {
                    shell.startIfNeeded()
                }
        }
    }
}
