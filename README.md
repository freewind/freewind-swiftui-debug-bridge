# FreewindSwiftUIDebugBridge

给 `SwiftUI macOS` app 提供一套给 AI 用的本地 debug bridge。

目标：

- 暴露简单 `HTTP API`
- 导出当前已注册节点的结构化快照
- 导出精简 `appState / targetState`
- 记录结构化 `logs`
- 通过统一 `POST /action` 驱动已注册动作

当前协议已对齐 Android 版的核心心智：

- `GET /meta`
- `GET /help`
- `GET /action`
- `POST /action`
- `GET /logs`
- `DELETE /logs`
- `GET /state`
- `GET /snapshot`

说明：

- 协议 SSOT：`/Users/peng.li/workspace/freewind-debug-bridge-web/typespec/main.tsp`
- 机器可读契约：`/Users/peng.li/workspace/freewind-debug-bridge-web/typespec/generated/openapi.yaml`
- 独立调试台：`/Users/peng.li/workspace/freewind-debug-bridge-web`
- 这是“已注册关键节点”模型，不是自动穷举 SwiftUI 私有 view tree
- 推荐只在 `DEBUG` / 本机开发启用

## 代码侧最小接入

```swift
import SwiftUI
import FreewindSwiftUIDebugBridge

@Observable
@MainActor
final class DemoStore {
    var counter = 0
}

@Observable
@MainActor
final class DemoShell {
    let store = DemoStore()
    let debugBridge = DebugBridge(
        appName: "Demo App",
        consoleTitle: "Demo Debug Console"
    )

    func start() {
        debugBridge.registerNodeAction(id: "increment_button", action: "press") { [store] _ in
            store.counter += 1
            return .ok("accepted")
        }

        debugBridge.registerIntent(name: "increment_counter") { [store] _ in
            store.counter += 1
            return .ok("accepted")
        }

        debugBridge.start(
            port: 7879,
            screenName: { "DemoScreen" }
        ) { [store, debugBridge] in
            debugBridge.publishTargetState(
                id: "increment_button",
                state: ["count": "\(store.counter)"]
            )
            return [
                "counter": "\(store.counter)",
                "debugStatus": debugBridge.statusMessage,
            ]
        }
    }
}

struct ContentView: View {
    @Environment(DemoShell.self) private var shell

    var body: some View {
        Button(
            "Increment",
            action: shell.debugBridge.wrapNodeAction(
                id: "increment_button",
                action: "press"
            ) {
                shell.store.counter += 1
            }
        )
        .debugNode(
            id: "increment_button",
            role: "button",
            label: "Increment counter button",
            actions: ["press"]
        )
    }
}
```

## endpoint 示例

字段名、query、返回 shape 以 `freewind-debug-bridge-web/typespec/generated/openapi.yaml` 为准（源文件 `typespec/main.tsp`）。

基址：

```text
http://127.0.0.1:7879
```

### `GET /meta`

返回 app 标识与 buildVersion。

```bash
curl http://127.0.0.1:7879/meta
```

### `GET /help`

返回当前能力、字段、示例。

```bash
curl http://127.0.0.1:7879/help
```

返回示例：

```json
{
  "appName": "Demo App",
  "consoleTitle": "Demo Debug Console",
  "screenName": "DemoScreen",
  "serverTime": "20260519-220000",
  "capabilities": ["action", "logs", "state", "snapshot"],
  "counts": {
    "actionTargetCount": 2,
    "logCount": 0,
    "stateKeyCount": 2,
    "snapshotNodeCount": 5
  }
}
```

### `GET /action`

默认返回可执行目标与动作。

```bash
curl http://127.0.0.1:7879/action
curl "http://127.0.0.1:7879/action?targetId=increment_button"
```

返回示例：

```json
{
  "summary": {
    "targetCount": 2,
    "actionCount": 2
  },
  "items": [
    {
      "targetId": "increment_button",
      "targetType": "Button",
      "screen": "DemoScreen",
      "actions": [
        {
          "name": "press",
          "args": [],
          "summary": "trigger increment_button press",
          "example": {
            "action": "press",
            "targetId": "increment_button"
          }
        }
      ]
    }
  ]
}
```

intent 也收口到这里：

- `targetId = intent name`
- `action = invoke`

### `POST /action`

统一执行入口。

```bash
curl -X POST http://127.0.0.1:7879/action \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "press",
    "targetId": "increment_button"
  }'
```

返回示例：

```json
{
  "accepted": true,
  "message": "Pressed increment button",
  "action": "press",
  "targetId": "increment_button"
}
```

带参数动作：

```json
{
  "action": "press",
  "targetId": "rename_device_button",
  "text": "freewind-mac"
}
```

说明：

- action handler 统一收 `DebugActionRequest`
- `text` 适合 text field / rename / send
- `args` 适合结构化小参数，如 `{"value":"true"}`
- `source` 可显式传 `ai|human|system`

调 intent：

```json
{
  "action": "invoke",
  "targetId": "increment_counter"
}
```

### `GET /logs`

默认返回 summary。

```bash
curl http://127.0.0.1:7879/logs
```

带 query 返回匹配日志：

```bash
curl "http://127.0.0.1:7879/logs?source=ai&targetId=increment_button&limit=10"
```

返回示例：

```json
{
  "items": [
    {
      "seq": 1,
      "time": "20260519-220014",
      "source": "ai",
      "level": "info",
      "event": "press",
      "targetId": "increment_button",
      "summary": "accepted increment_button press",
      "data": {
        "accepted": "true"
      }
    }
  ],
  "nextAfterSeq": 1
}
```

支持 query：

- `event`
- `level`
- `source`
- `targetId`
- `screen`
- `from`
- `to`
- `limit`
- `keyword`

### `DELETE /logs`

清空已有日志。

```bash
curl -X DELETE http://127.0.0.1:7879/logs
```

返回示例：

```json
{
  "accepted": true,
  "message": "cleared 1 logs",
  "clearedCount": 1
}
```

### `GET /state`

默认返回 `appState` key 摘要 + 已挂 targetState 的 target。

```bash
curl http://127.0.0.1:7879/state
curl "http://127.0.0.1:7879/state?keys=counter&scope=app"
curl "http://127.0.0.1:7879/state?targetId=increment_button&scope=target"
```

返回示例：

```json
{
  "appState": {
    "counter": "1"
  }
}
```

支持：

- `keys`
- `targetId`
- `scope=app|target|branch`

### `GET /snapshot`

默认返回 tree summary。

```bash
curl http://127.0.0.1:7879/snapshot
```

带 query 返回 detail：

```bash
curl "http://127.0.0.1:7879/snapshot?targetId=increment_button&scope=self&fields=id,type,text,bounds,clickable"
curl "http://127.0.0.1:7879/snapshot?targetId=increment_button&scope=branchToRoot&fields=id,type,text,bounds"
curl "http://127.0.0.1:7879/snapshot?types=Button&clickable=true&limit=20"
```

返回示例：

```json
{
  "screen": "DemoScreen",
  "nodes": [
    {
      "id": "increment_button",
      "type": "Button",
      "text": "Increment counter button",
      "clickable": true,
      "bounds": {
        "left": 331.5,
        "top": 221,
        "width": 77,
        "height": 20
      }
    }
  ]
}
```

支持：

- `targetId`
- `scope=self|branchToRoot|subtree`
- `depth`
- `types`
- `textKeyword`
- `visible`
- `enabled`
- `clickable`
- `fields`
- `limit`

## 协议来源与类型生成

本仓不再维护独立 API 文档。唯一准绳在 sibling 仓 `freewind-debug-bridge-web`：

| 文件 | 用途 |
|------|------|
| `typespec/main.tsp` | 契约 SSOT（改协议先改这里） |
| `typespec/generated/openapi.yaml` | 给其他语言/工具消费 |

协议变更流程：

1. 改 `freewind-debug-bridge-web/typespec/main.tsp`
2. 那边执行 `pnpm generate`（产出 OpenAPI + web TS 类型）
3. 本仓对齐 `DebugModels.swift` 等实现
4. 跑测试 / 用独立调试台联调

### 从 OpenAPI 生成 Swift 类型（对照用）

需要 Java 8+，安装 [OpenAPI Generator](https://openapi-generator.tech/) 后：

```bash
OPENAPI=/Users/peng.li/workspace/freewind-debug-bridge-web/typespec/generated/openapi.yaml

openapi-generator generate -i "$OPENAPI" -g swift5 -o /tmp/debug-bridge-swift \
  --global-property models,supportingFiles
```

只生成 model，不生成 HTTP client（本库自带 server）。生成物用于对照字段，禁止手改后当 SSOT。
