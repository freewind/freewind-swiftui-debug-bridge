import FreewindSwiftUIDebugServer
import Observation

@Observable
@MainActor
final class DemoAppShell {
    let debugBridge = DebugBridge(appName: "Freewind SwiftUI Debug Server Demo")
    var counter = 0
    var username = "freewind"
    var enabled = true
    private var didStart = false

    func startIfNeeded() {
        guard !didStart else {
            return
        }
        didStart = true

        debugBridge.registerIntent(name: "increment_counter") { [weak self] _ in
            guard let self else {
                return .fail("DemoAppShell released")
            }
            increment()
            return .ok("Counter incremented")
        }

        debugBridge.registerIntent(name: "reset_counter") { [weak self] _ in
            guard let self else {
                return .fail("DemoAppShell released")
            }
            reset()
            return .ok("Counter reset")
        }

        debugBridge.registerNodeAction(id: "increment_button", action: "press") { [weak self] _ in
            guard let self else {
                return .fail("DemoAppShell released")
            }
            increment()
            return .ok("Pressed increment button")
        }

        debugBridge.registerNodeAction(id: "decrement_button", action: "press") { [weak self] _ in
            guard let self else {
                return .fail("DemoAppShell released")
            }
            decrement()
            return .ok("Pressed decrement button")
        }

        debugBridge.registerNodeAction(id: "reset_button", action: "press") { [weak self] _ in
            guard let self else {
                return .fail("DemoAppShell released")
            }
            reset()
            return .ok("Pressed reset button")
        }

        debugBridge.registerNodeAction(id: "fill_name_button", action: "press", args: ["text"]) { [weak self] request in
            guard let self else {
                return .fail("DemoAppShell released")
            }
            if let text = request.text, !text.isEmpty {
                username = text
                return .ok("Updated username from request text")
            }
            fillDemoName()
            return .ok("Filled demo name")
        }

        debugBridge.registerNodeAction(id: "enabled_toggle", action: "toggle", args: ["value"]) { [weak self] request in
            guard let self else {
                return .fail("DemoAppShell released")
            }
            if let value = request.args?["value"]?.lowercased() {
                switch value {
                case "true":
                    enabled = true
                    return .ok("Enabled set true")
                case "false":
                    enabled = false
                    return .ok("Enabled set false")
                default:
                    break
                }
            }
            toggleEnabled()
            return .ok("Toggled enabled")
        }

        debugBridge.start(
            port: 7879,
            screenName: { "DemoScreen" }
        ) { [weak self] in
            guard let self else {
                return [:]
            }
            publishDebugState()
            return [
                "counter": "\(counter)",
                "username": username,
                "enabled": enabled ? "true" : "false",
                "debugStatus": debugBridge.statusMessage,
            ]
        }
    }

    func increment() {
        counter += 1
    }

    func decrement() {
        counter -= 1
    }

    func reset() {
        counter = 0
    }

    func fillDemoName() {
        username = "demo-\(counter)"
    }

    func toggleEnabled() {
        enabled.toggle()
    }

    private func publishDebugState() {
        debugBridge.publishTargetState(
            id: "increment_button",
            state: ["count": "\(counter)", "username": username]
        )
        debugBridge.publishTargetState(
            id: "decrement_button",
            state: ["count": "\(counter)"]
        )
        debugBridge.publishTargetState(
            id: "reset_button",
            state: ["count": "\(counter)"]
        )
        debugBridge.publishTargetState(
            id: "fill_name_button",
            state: ["username": username]
        )
        debugBridge.publishTargetState(
            id: "username_input",
            state: ["username": username]
        )
        debugBridge.publishTargetState(
            id: "enabled_toggle",
            state: ["enabled": enabled ? "true" : "false"]
        )
    }
}
