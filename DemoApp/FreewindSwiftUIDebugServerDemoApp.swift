import AppKit
import SwiftUI

final class DemoAppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct FreewindSwiftUIDebugServerDemoApp: App {
    @NSApplicationDelegateAdaptor(DemoAppDelegate.self) private var appDelegate
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
