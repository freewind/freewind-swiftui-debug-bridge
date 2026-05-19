import FreewindSwiftUIDebugServer
import SwiftUI

struct ContentView: View {
    @Environment(DemoAppShell.self) private var shell

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Freewind SwiftUI Debug Server")
                .font(.title2)
                .debugNodeStatic(
                    id: "title_text",
                    role: "text",
                    label: "Demo title"
                )

            Text("Counter: \(shell.counter)")
                .font(.body.monospacedDigit())
                .debugNodeStatic(
                    id: "counter_text",
                    role: "text",
                    label: "Counter value"
                )

            Button(
                "Increment",
                action: shell.debugBridge.wrapNodeAction(
                    id: "increment_button",
                    action: "press"
                ) {
                    shell.increment()
                }
            )
            .debugNode(
                id: "increment_button",
                role: "button",
                label: "Increment counter button",
                actions: ["press"]
            )

            Text(shell.debugBridge.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .debugNodeStatic(
                    id: "status_text",
                    role: "text",
                    label: "Debug bridge status"
                )
        }
        .padding(24)
        .frame(minWidth: 420, minHeight: 220)
        .debugNodeStatic(
            id: "demo_root",
            role: "container",
            label: "Demo root"
        )
    }
}
