import Foundation
import Observation

// 对业务暴露的总入口。
@Observable
@MainActor
public final class DebugBridge {
    // 共享 registry，供 view 环境注入。
    public let registry = DebugRegistry()
    // 当前 server。
    private var server: DebugHTTPServer?
    // 当前端口。
    public private(set) var port: UInt16?
    // 启动状态说明。
    public private(set) var statusMessage: String = "Not started"

    // 构造。
    public init() {}

    // 注册 intent。
    public func registerIntent(name: String, perform: @escaping @MainActor () -> DebugActionResponse) {
        registry.registerIntent(name: name, perform: perform)
    }

    // 注册节点动作。
    public func registerNodeAction(id: String, action: String, perform: @escaping @MainActor () -> DebugActionResponse) {
        registry.registerNodeAction(id: id, action: action, perform: perform)
    }

    // 启动 server。
    public func start(port: UInt16, appState: @escaping @MainActor () -> [String: String]) {
        stop()
        self.port = port
        server = DebugHTTPServer(
            port: port,
            getSnapshot: { [weak self] in
                await MainActor.run {
                    guard let self else {
                        return DebugSnapshot(
                            timestamp: ISO8601DateFormatter().string(from: Date()),
                            appState: [:],
                            nodeCount: 0,
                            nodes: [],
                            actionNames: []
                        )
                    }
                    return self.registry.snapshot(appState: appState())
                }
            },
            querySnapshot: { [weak self] query in
                await MainActor.run {
                    guard let self else {
                        return DebugSnapshotResponse(
                            timestamp: ISO8601DateFormatter().string(from: Date()),
                            totalNodeCount: 0,
                            matchedNodeCount: 0
                        )
                    }
                    return self.registry.snapshot(appState: appState(), query: query)
                }
            },
            getEvents: { [weak self] query in
                await MainActor.run {
                    guard let self else {
                        return DebugEventResponse(nextSequence: 1, events: [])
                    }
                    return self.registry.events(query: query)
                }
            },
            performAction: { [weak self] request in
                await MainActor.run {
                    guard let self else {
                        return .fail("DebugBridge deallocated")
                    }
                    return self.registry.perform(request: request)
                }
            }
        )

        do {
            try server?.start()
            statusMessage = "Listening at http://127.0.0.1:\(port)"
        } catch {
            statusMessage = "Start failed: \(error.localizedDescription)"
        }
    }

    // 停止 server。
    public func stop() {
        server?.stop()
        server = nil
        port = nil
    }

    // 显式记录人类或系统事件。
    public func recordEvent(
        source: String,
        kind: String,
        name: String? = nil,
        id: String? = nil,
        action: String? = nil,
        ok: Bool? = nil,
        message: String? = nil,
        metadata: [String: String] = [:]
    ) {
        registry.recordEvent(
            source: source,
            kind: kind,
            name: name,
            id: id,
            action: action,
            ok: ok,
            message: message,
            metadata: metadata
        )
    }
}
