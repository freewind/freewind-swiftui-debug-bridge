import Foundation

// 单个调试节点快照。
public struct DebugNodeSnapshot: Codable, Identifiable, Sendable {
    // 稳定节点 id。
    public let id: String
    // 父节点 id。
    public let parentID: String?
    // 节点角色，如 button / text / panel。
    public let role: String
    // 对外标签。
    public let label: String
    // 左上角 x。
    public let x: Double
    // 左上角 y。
    public let y: Double
    // 宽度。
    public let width: Double
    // 高度。
    public let height: Double
    // 是否可见。
    public let isVisible: Bool
    // 允许动作。
    public let actions: [String]

    // 对外构造。
    public init(
        id: String,
        parentID: String? = nil,
        role: String,
        label: String,
        x: Double,
        y: Double,
        width: Double,
        height: Double,
        isVisible: Bool,
        actions: [String]
    ) {
        self.id = id
        self.parentID = parentID
        self.role = role
        self.label = label
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.isVisible = isVisible
        self.actions = actions
    }
}

// 节点字段投影结果。
public struct DebugNodePayload: Codable, Identifiable, Sendable {
    public let id: String
    public let parentID: String?
    public let role: String?
    public let label: String?
    public let x: Double?
    public let y: Double?
    public let width: Double?
    public let height: Double?
    public let isVisible: Bool?
    public let actions: [String]?

    public init(
        id: String,
        parentID: String? = nil,
        role: String? = nil,
        label: String? = nil,
        x: Double? = nil,
        y: Double? = nil,
        width: Double? = nil,
        height: Double? = nil,
        isVisible: Bool? = nil,
        actions: [String]? = nil
    ) {
        self.id = id
        self.parentID = parentID
        self.role = role
        self.label = label
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.isVisible = isVisible
        self.actions = actions
    }
}

// 整体 snapshot。
public struct DebugSnapshot: Codable, Sendable {
    // 时间戳。
    public let timestamp: String
    // 业务状态，使用结构化 JSON 值承载。
    public let appState: [String: String]
    // 节点总数。
    public let nodeCount: Int
    // 所有节点。
    public let nodes: [DebugNodeSnapshot]
    // 所有 intent 名。
    public let actionNames: [String]

    // 对外构造。
    public init(
        timestamp: String,
        appState: [String: String],
        nodeCount: Int,
        nodes: [DebugNodeSnapshot],
        actionNames: [String]
    ) {
        self.timestamp = timestamp
        self.appState = appState
        self.nodeCount = nodeCount
        self.nodes = nodes
        self.actionNames = actionNames
    }
}

// 矩形过滤。
public struct DebugRectFilter: Codable, Sendable {
    public let minX: Double?
    public let minY: Double?
    public let maxX: Double?
    public let maxY: Double?

    public init(minX: Double? = nil, minY: Double? = nil, maxX: Double? = nil, maxY: Double? = nil) {
        self.minX = minX
        self.minY = minY
        self.maxX = maxX
        self.maxY = maxY
    }
}

// 精简 snapshot 查询。
public struct DebugSnapshotQuery: Codable, Sendable {
    public let includeNodes: Bool
    public let includeAppState: Bool
    public let includeActionNames: Bool
    public let nodeFields: [String]?
    public let appStateKeys: [String]?
    public let nodeIDs: [String]?
    public let roles: [String]?
    public let visibleOnly: Bool
    public let includeAncestors: Bool
    public let ancestorDepth: Int?
    public let rect: DebugRectFilter?
    public let limit: Int?

    public init(
        includeNodes: Bool = true,
        includeAppState: Bool = false,
        includeActionNames: Bool = false,
        nodeFields: [String]? = nil,
        appStateKeys: [String]? = nil,
        nodeIDs: [String]? = nil,
        roles: [String]? = nil,
        visibleOnly: Bool = false,
        includeAncestors: Bool = false,
        ancestorDepth: Int? = nil,
        rect: DebugRectFilter? = nil,
        limit: Int? = 50
    ) {
        self.includeNodes = includeNodes
        self.includeAppState = includeAppState
        self.includeActionNames = includeActionNames
        self.nodeFields = nodeFields
        self.appStateKeys = appStateKeys
        self.nodeIDs = nodeIDs
        self.roles = roles
        self.visibleOnly = visibleOnly
        self.includeAncestors = includeAncestors
        self.ancestorDepth = ancestorDepth
        self.rect = rect
        self.limit = limit
    }

    private enum CodingKeys: String, CodingKey {
        case includeNodes
        case includeAppState
        case includeActionNames
        case nodeFields
        case appStateKeys
        case nodeIDs
        case roles
        case visibleOnly
        case includeAncestors
        case ancestorDepth
        case rect
        case limit
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            includeNodes: try container.decodeIfPresent(Bool.self, forKey: .includeNodes) ?? true,
            includeAppState: try container.decodeIfPresent(Bool.self, forKey: .includeAppState) ?? false,
            includeActionNames: try container.decodeIfPresent(Bool.self, forKey: .includeActionNames) ?? false,
            nodeFields: try container.decodeIfPresent([String].self, forKey: .nodeFields),
            appStateKeys: try container.decodeIfPresent([String].self, forKey: .appStateKeys),
            nodeIDs: try container.decodeIfPresent([String].self, forKey: .nodeIDs),
            roles: try container.decodeIfPresent([String].self, forKey: .roles),
            visibleOnly: try container.decodeIfPresent(Bool.self, forKey: .visibleOnly) ?? false,
            includeAncestors: try container.decodeIfPresent(Bool.self, forKey: .includeAncestors) ?? false,
            ancestorDepth: try container.decodeIfPresent(Int.self, forKey: .ancestorDepth),
            rect: try container.decodeIfPresent(DebugRectFilter.self, forKey: .rect),
            limit: try container.decodeIfPresent(Int.self, forKey: .limit) ?? 50
        )
    }
}

// 查询后的 snapshot 结果。
public struct DebugSnapshotResponse: Codable, Sendable {
    public let timestamp: String
    public let totalNodeCount: Int
    public let matchedNodeCount: Int
    public let appState: [String: String]?
    public let nodes: [DebugNodePayload]?
    public let actionNames: [String]?

    public init(
        timestamp: String,
        totalNodeCount: Int,
        matchedNodeCount: Int,
        appState: [String: String]? = nil,
        nodes: [DebugNodePayload]? = nil,
        actionNames: [String]? = nil
    ) {
        self.timestamp = timestamp
        self.totalNodeCount = totalNodeCount
        self.matchedNodeCount = matchedNodeCount
        self.appState = appState
        self.nodes = nodes
        self.actionNames = actionNames
    }
}

// 外部动作请求。
public struct DebugActionRequest: Codable, Sendable {
    // 请求类型：intent / node。
    public let type: String
    // intent 名。
    public let name: String?
    // 节点 id。
    public let id: String?
    // 节点动作名。
    public let action: String?
    // 来源，如 ai / human / system。
    public let source: String?
    // 额外标签。
    public let metadata: [String: String]?

    // 对外构造。
    public init(
        type: String,
        name: String? = nil,
        id: String? = nil,
        action: String? = nil,
        source: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.type = type
        self.name = name
        self.id = id
        self.action = action
        self.source = source
        self.metadata = metadata
    }
}

// 动作响应。
public struct DebugActionResponse: Codable, Sendable {
    // 是否成功。
    public let ok: Bool
    // 说明文本。
    public let message: String

    // 对外构造。
    public init(ok: Bool, message: String) {
        self.ok = ok
        self.message = message
    }

    // 成功快捷构造。
    public static func ok(_ message: String) -> Self {
        Self(ok: true, message: message)
    }

    // 失败快捷构造。
    public static func fail(_ message: String) -> Self {
        Self(ok: false, message: message)
    }
}

// 单条操作事件。
public struct DebugEvent: Codable, Sendable {
    public let sequence: Int
    public let timestamp: String
    public let source: String
    public let kind: String
    public let name: String?
    public let id: String?
    public let action: String?
    public let ok: Bool?
    public let message: String?
    public let metadata: [String: String]

    public init(
        sequence: Int,
        timestamp: String,
        source: String,
        kind: String,
        name: String? = nil,
        id: String? = nil,
        action: String? = nil,
        ok: Bool? = nil,
        message: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.sequence = sequence
        self.timestamp = timestamp
        self.source = source
        self.kind = kind
        self.name = name
        self.id = id
        self.action = action
        self.ok = ok
        self.message = message
        self.metadata = metadata
    }
}

// 事件查询。
public struct DebugEventQuery: Codable, Sendable {
    public let afterSequence: Int
    public let limit: Int
    public let sources: [String]?
    public let kinds: [String]?
    public let ids: [String]?

    public init(
        afterSequence: Int = 0,
        limit: Int = 50,
        sources: [String]? = nil,
        kinds: [String]? = nil,
        ids: [String]? = nil
    ) {
        self.afterSequence = afterSequence
        self.limit = limit
        self.sources = sources
        self.kinds = kinds
        self.ids = ids
    }

    private enum CodingKeys: String, CodingKey {
        case afterSequence
        case limit
        case sources
        case kinds
        case ids
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            afterSequence: try container.decodeIfPresent(Int.self, forKey: .afterSequence) ?? 0,
            limit: try container.decodeIfPresent(Int.self, forKey: .limit) ?? 50,
            sources: try container.decodeIfPresent([String].self, forKey: .sources),
            kinds: try container.decodeIfPresent([String].self, forKey: .kinds),
            ids: try container.decodeIfPresent([String].self, forKey: .ids)
        )
    }
}

// 事件拉取结果。
public struct DebugEventResponse: Codable, Sendable {
    public let nextSequence: Int
    public let events: [DebugEvent]

    public init(nextSequence: Int, events: [DebugEvent]) {
        self.nextSequence = nextSequence
        self.events = events
    }
}
