import Foundation

// @rule wire 类型来自 OpenAPI 生成；改 typespec 后跑 freewind-debug-bridge-web/scripts/generate-bridge-models.sh

public typealias DebugMetaResponse = MetaResponse
public typealias DebugActionRequest = ActionRequest
public typealias DebugActionResponse = ActionResponse
public typealias DebugLogsClearResponse = LogsClearResponse
public typealias DebugActionCatalogResponse = ActionCatalogResponse
public typealias DebugActionCatalogSummary = ActionCatalogSummary
public typealias DebugActionCatalogItem = ActionCatalogItem
public typealias DebugActionDescriptor = ActionCatalogItemAction
public typealias DebugLogEntry = LogEntry
public typealias DebugLogsResponse = LogsResponse
public typealias DebugLogsSummary = LogsSummary
public typealias DebugTimeRange = LogsTimeRange
public typealias DebugStateResponse = StateResponse
public typealias DebugStateSummary = StateSummary
public typealias DebugStateKeySample = StateKeySample
public typealias DebugSnapshotResponse = SnapshotResponse
public typealias DebugSnapshotSummary = SnapshotSummary
public typealias DebugSnapshotNodePayload = SnapshotNode
public typealias DebugBounds = SnapshotBounds
public typealias DebugHelpResponse = HelpResponse
public typealias DebugHelpCounts = HelpCounts
public typealias DebugEndpointDescriptor = HelpEndpoint

extension MetaResponse: @unchecked Sendable {}
extension ActionRequest: @unchecked Sendable {}
extension ActionResponse: @unchecked Sendable {}
extension LogsClearResponse: @unchecked Sendable {}
extension ActionCatalogResponse: @unchecked Sendable {}
extension ActionCatalogSummary: @unchecked Sendable {}
extension ActionCatalogItem: @unchecked Sendable {}
extension ActionCatalogItemAction: @unchecked Sendable {}
extension LogEntry: @unchecked Sendable {}
extension LogsResponse: @unchecked Sendable {}
extension LogsSummary: @unchecked Sendable {}
extension LogsTimeRange: @unchecked Sendable {}
extension StateResponse: @unchecked Sendable {}
extension StateSummary: @unchecked Sendable {}
extension StateKeySample: @unchecked Sendable {}
extension SnapshotResponse: @unchecked Sendable {}
extension SnapshotSummary: @unchecked Sendable {}
extension SnapshotNode: @unchecked Sendable {}
extension SnapshotBounds: @unchecked Sendable {}
extension HelpResponse: @unchecked Sendable {}
extension HelpCounts: @unchecked Sendable {}
extension HelpEndpoint: @unchecked Sendable {}

extension ActionResponse {
    public static func ok(
        _ message: String,
        action: String? = nil,
        targetId: String? = nil,
        durationMs: Int? = nil
    ) -> ActionResponse {
        ActionResponse(
            accepted: true,
            message: message,
            action: action,
            targetId: targetId,
            durationMs: durationMs,
            errorType: nil,
            timedOut: nil
        )
    }

    public static func fail(
        _ message: String,
        action: String? = nil,
        targetId: String? = nil,
        errorType: String? = nil,
        timedOut: Bool? = nil,
        durationMs: Int? = nil
    ) -> ActionResponse {
        ActionResponse(
            accepted: false,
            message: message,
            action: action,
            targetId: targetId,
            durationMs: durationMs,
            errorType: errorType,
            timedOut: timedOut
        )
    }
}

extension SnapshotBounds {
    public var left: Double { _left }

    public init(left: Double, top: Double, width: Double, height: Double) {
        self.init(_left: left, top: top, width: width, height: height)
    }
}
