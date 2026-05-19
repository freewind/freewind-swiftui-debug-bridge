import FreewindSwiftUIDebugServer
import SwiftUI

struct ContentView: View {
    @Environment(DemoAppShell.self) private var shell

    var body: some View {
        @Bindable var shell = shell

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Freewind SwiftUI Debug Server")
                    .font(.title2)
                    .debugNodeStatic(
                        id: "title_text",
                        role: "text",
                        label: "Demo title"
                    )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Counter: \(shell.counter)")
                        .font(.body.monospacedDigit())
                        .debugNodeStatic(
                            id: "counter_text",
                            role: "text",
                            label: "Counter value"
                        )

                    Text("Username: \(shell.username)")
                        .font(.body.monospaced())
                        .debugNodeStatic(
                            id: "username_text",
                            role: "text",
                            label: "Username value"
                        )

                    Text("Enabled: \(shell.enabled ? "true" : "false")")
                        .font(.body.monospaced())
                        .debugNodeStatic(
                            id: "enabled_text",
                            role: "text",
                            label: "Enabled value"
                        )
                }

                HStack(spacing: 12) {
                    Button(
                        "Increment",
                        action: shell.debugBridge.wrapNodeAction(
                            id: "increment_button",
                            action: "press",
                            metadata: ["screen": "DemoScreen"]
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

                    Button(
                        "Decrement",
                        action: shell.debugBridge.wrapNodeAction(
                            id: "decrement_button",
                            action: "press",
                            metadata: ["screen": "DemoScreen"]
                        ) {
                            shell.decrement()
                        }
                    )
                    .debugNode(
                        id: "decrement_button",
                        role: "button",
                        label: "Decrement counter button",
                        actions: ["press"]
                    )

                    Button(
                        "Reset",
                        action: shell.debugBridge.wrapNodeAction(
                            id: "reset_button",
                            action: "press",
                            metadata: ["screen": "DemoScreen"]
                        ) {
                            shell.reset()
                        }
                    )
                    .debugNode(
                        id: "reset_button",
                        role: "button",
                        label: "Reset counter button",
                        actions: ["press"]
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    TextField(
                        "Username",
                        text: shell.debugBridge.tracked(
                            $shell.username,
                            id: "username_input",
                            action: "input",
                            metadata: ["screen": "DemoScreen"]
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .debugNode(
                        id: "username_input",
                        role: "text_field",
                        label: "Username input",
                        actions: []
                    )

                    Toggle(
                        "Enabled",
                        isOn: shell.debugBridge.tracked(
                            $shell.enabled,
                            id: "enabled_toggle",
                            action: "toggle",
                            metadata: ["screen": "DemoScreen"]
                        )
                    )
                    .debugNode(
                        id: "enabled_toggle",
                        role: "toggle",
                        label: "Enabled toggle",
                        actions: ["toggle"]
                    )
                }

                Button(
                    "Fill Demo Name",
                    action: shell.debugBridge.wrapNodeAction(
                        id: "fill_name_button",
                        action: "press",
                        metadata: ["screen": "DemoScreen"]
                    ) {
                        shell.fillDemoName()
                    }
                )
                .debugNode(
                    id: "fill_name_button",
                    role: "button",
                    label: "Fill demo name button",
                    actions: ["press"]
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("HTTP")
                        .font(.headline)
                        .debugNodeStatic(
                            id: "http_title_text",
                            role: "text",
                            label: "HTTP title"
                        )
                    Text("http://127.0.0.1:7879")
                        .font(.body.monospaced())
                        .debugNodeStatic(
                            id: "http_url_text",
                            role: "text",
                            label: "HTTP base URL"
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .frame(minWidth: 760, minHeight: 420)
        .debugNodeStatic(
            id: "demo_root",
            role: "container",
            label: "Demo root"
        )
    }
}
