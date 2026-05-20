export type HelpResponse = {
  appName: string
  consoleTitle?: string
  screenName: string
  serverTime: string
  capabilities: string[]
  counts: {
    actionTargetCount: number
    logCount: number
    stateKeyCount: number
    snapshotNodeCount: number
  }
  endpoints: Array<{
    method: string
    path: string
    summary: string
    queryFields?: string[]
    bodyFields?: string[]
  }>
  examples: string[]
}

export type ActionRequest = {
  action: string
  targetId: string
  text?: string
  dx?: number
  dy?: number
  args?: Record<string, string>
  source?: string
}

export type ActionResponse = {
  accepted: boolean
  message: string
  action?: string
  targetId?: string
}

export type ActionCatalogResponse = {
  summary: {
    targetCount: number
    actionCount: number
  }
  items: Array<{
    targetId: string
    targetType: string
    screen: string
    actions: Array<{
      name: string
      args: string[]
      summary: string
      example: ActionRequest
    }>
  }>
}

export type LogEntry = {
  seq: number
  time: string
  source: string
  level: string
  event: string
  targetId?: string
  summary: string
  data: Record<string, string>
}

export type LogsResponse = {
  summary?: {
    total: number
    timeRange?: {
      from: string
      to: string
    }
    levelCounts: Record<string, number>
    sourceCounts: Record<string, number>
    eventCountsTop: Record<string, number>
  }
  items?: LogEntry[]
  nextAfterSeq?: number
}

export type LogsClearResponse = {
  accepted: boolean
  message: string
  clearedCount: number
}

export type StateResponse = {
  summary?: {
    appStateKeys: Array<{ key: string; sample: string }>
    targetStateTargets: string[]
  }
  appState?: Record<string, string>
  targetState?: Record<string, string>
}

export type SnapshotNode = {
  id: string
  parentId?: string
  type?: string
  text?: string
  role?: string
  visible?: boolean
  enabled?: boolean
  clickable?: boolean
  value?: string
  bounds?: {
    left: number
    top: number
    width: number
    height: number
  }
}

export type SnapshotPreviewNode = SnapshotNode & {
  bounds: NonNullable<SnapshotNode['bounds']>
}

export type SnapshotResponse = {
  summary?: {
    screen: string
    nodeCount: number
    rootIds: string[]
    typeCounts: Record<string, number>
    clickableCount: number
  }
  fieldCatalog?: string[]
  examples?: string[]
  screen?: string
  nodes?: SnapshotNode[]
}
