import type { FC } from 'react'
import { useEffect, useState } from 'react'
import {
  App as AntdApp,
  Button,
  Card,
  Col,
  Divider,
  Form,
  Input,
  InputNumber,
  Layout,
  Row,
  Space,
  Statistic,
  Table,
  Tabs,
  Tag,
  Typography,
} from 'antd'
import type { ColumnsType } from 'antd/es/table'
import { buildQuery, fetchJSON, prettyJSON } from './api'
import type {
  ActionCatalogResponse,
  ActionRequest,
  ActionResponse,
  HelpResponse,
  LogEntry,
  LogsClearResponse,
  LogsResponse,
  SnapshotResponse,
  StateResponse,
} from './types'

const { Header, Content } = Layout
const { Title, Text } = Typography
const compactInputStyle = { width: '100%', maxWidth: 180 } as const
const compactNumberStyle = { width: '100%', maxWidth: 120 } as const

const logColumns: ColumnsType<LogEntry> = [
  { title: 'seq', dataIndex: 'seq', width: 80 },
  { title: 'time', dataIndex: 'time', width: 170 },
  { title: 'source', dataIndex: 'source', width: 120 },
  { title: 'level', dataIndex: 'level', width: 100 },
  { title: 'event', dataIndex: 'event', width: 140 },
  { title: 'targetId', dataIndex: 'targetId', width: 160, render: (value) => value || '-' },
  { title: 'summary', dataIndex: 'summary' },
  {
    title: 'data',
    dataIndex: 'data',
    width: 260,
    render: (value) => <pre>{prettyJSON(value || {})}</pre>,
  },
]

const App: FC = () => {
  const { message } = AntdApp.useApp()

  const [help, setHelp] = useState<HelpResponse | null>(null)
  const [actions, setActions] = useState<ActionCatalogResponse | null>(null)
  const [logs, setLogs] = useState<LogsResponse | null>(null)
  const [stateData, setStateData] = useState<StateResponse | null>(null)
  const [snapshot, setSnapshot] = useState<SnapshotResponse | null>(null)
  const [actionResult, setActionResult] = useState<ActionResponse | LogsClearResponse | null>(null)

  const [actionQueryForm] = Form.useForm()
  const [manualActionForm] = Form.useForm()
  const [logsForm] = Form.useForm()
  const [stateForm] = Form.useForm()
  const [snapshotForm] = Form.useForm()

  async function loadHelp() {
    const result = await fetchJSON<HelpResponse>('/help')
    setHelp(result)
    return result
  }

  async function loadActions(values?: Record<string, unknown>) {
    const formValues = values ?? actionQueryForm.getFieldsValue()
    const result = await fetchJSON<ActionCatalogResponse>(`/action${buildQuery(formValues)}`)
    setActions(result)
    return result
  }

  async function loadLogs(values?: Record<string, unknown>) {
    const formValues = values ?? logsForm.getFieldsValue()
    const result = await fetchJSON<LogsResponse>(`/logs${buildQuery(formValues)}`)
    setLogs(result)
    return result
  }

  async function loadState(values?: Record<string, unknown>) {
    const formValues = values ?? stateForm.getFieldsValue()
    const result = await fetchJSON<StateResponse>(`/state${buildQuery(formValues)}`)
    setStateData(result)
    return result
  }

  async function loadSnapshot(values?: Record<string, unknown>) {
    const formValues = values ?? snapshotForm.getFieldsValue()
    const result = await fetchJSON<SnapshotResponse>(`/snapshot${buildQuery(formValues)}`)
    setSnapshot(result)
    return result
  }

  async function refreshAll() {
    try {
      await Promise.all([
        loadHelp(),
        loadActions({}),
        loadLogs({}),
        loadState({}),
        loadSnapshot({}),
      ])
    } catch (error) {
      message.error(String((error as Error).message || error))
    }
  }

  async function runAction(payload: ActionRequest) {
    try {
      const result = await fetchJSON<ActionResponse>('/action', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      })
      setActionResult(result)
      message.success(result.message)
      await Promise.all([loadHelp(), loadLogs({}), loadState({}), loadSnapshot({})])
    } catch (error) {
      message.error(String((error as Error).message || error))
    }
  }

  async function runManualAction() {
    try {
      const values = await manualActionForm.validateFields()
      const args = values.args ? (JSON.parse(values.args) as Record<string, string>) : {}
      await runAction({
        action: values.action,
        targetId: values.targetId,
        text: values.text || undefined,
        dx: values.dx ?? undefined,
        dy: values.dy ?? undefined,
        source: values.source || undefined,
        args,
      })
    } catch (error) {
      message.error(String((error as Error).message || error))
    }
  }

  async function clearLogs() {
    try {
      const result = await fetchJSON<LogsClearResponse>('/logs', { method: 'DELETE' })
      setActionResult(result)
      message.success(result.message)
      await Promise.all([loadHelp(), loadLogs({})])
    } catch (error) {
      message.error(String((error as Error).message || error))
    }
  }

  useEffect(() => {
    actionQueryForm.setFieldsValue({})
    manualActionForm.setFieldsValue({ source: 'human', args: '{}' })
    logsForm.setFieldsValue({ limit: 20 })
    snapshotForm.setFieldsValue({ limit: 20 })
    void refreshAll()
  }, [])

  return (
    <Layout>
      <Header style={{ background: '#fff', borderBottom: '1px solid #f0f0f0', paddingInline: 16, height: 56 }}>
        <Space direction="vertical" size={0}>
          <Title level={4} style={{ margin: 0, lineHeight: '32px', paddingTop: 6 }}>
            Freewind Debug Console
          </Title>
          <Text type="secondary">
            {help ? `${help.appName} / ${help.screenName} / ${help.serverTime}` : 'loading...'}
          </Text>
        </Space>
      </Header>
      <Content className="page">
        <Space direction="vertical" size={8} style={{ display: 'flex' }}>
          <Card size="small">
            <Space size={8} wrap>
              <Button size="small" type="primary" onClick={() => void refreshAll()}>
                Refresh All
              </Button>
              <Button size="small" onClick={() => void loadActions({})}>Refresh Actions</Button>
              <Button size="small" danger onClick={() => void clearLogs()}>
                Clear Logs
              </Button>
            </Space>
          </Card>

          <Row gutter={[8, 8]}>
            <Col xs={24} md={12} xl={6}>
              <Card size="small"><Statistic title="Action Targets" value={help?.counts.actionTargetCount ?? 0} /></Card>
            </Col>
            <Col xs={24} md={12} xl={6}>
              <Card size="small"><Statistic title="Logs" value={help?.counts.logCount ?? 0} /></Card>
            </Col>
            <Col xs={24} md={12} xl={6}>
              <Card size="small"><Statistic title="State Keys" value={help?.counts.stateKeyCount ?? 0} /></Card>
            </Col>
            <Col xs={24} md={12} xl={6}>
              <Card size="small"><Statistic title="Snapshot Nodes" value={help?.counts.snapshotNodeCount ?? 0} /></Card>
            </Col>
          </Row>

          <Tabs
            size="small"
            items={[
              {
                key: 'logs',
                label: 'Logs',
                children: (
                  <Space direction="vertical" size={8} style={{ display: 'flex' }}>
                    <Card size="small" title="Query">
                      <Form form={logsForm} layout="vertical" size="small">
                        <Row gutter={[8, 8]}>
                          <Col xs={12} md={8} xl={4}><Form.Item label="event" name="event"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="level" name="level"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="source" name="source"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="targetId" name="targetId"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="screen" name="screen"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="from" name="from"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="to" name="to"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="limit" name="limit"><InputNumber style={compactNumberStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="keyword" name="keyword"><Input style={compactInputStyle} /></Form.Item></Col>
                        </Row>
                        <Space size={8} wrap>
                          <Button size="small" type="primary" onClick={() => void loadLogs()}>Query Logs</Button>
                          <Button size="small" onClick={() => void loadLogs({})}>Summary</Button>
                          <Button size="small" danger onClick={() => void clearLogs()}>Delete Logs</Button>
                        </Space>
                      </Form>
                    </Card>

                    {logs?.summary ? (
                      <Card size="small" title="J">
                        <pre>{prettyJSON(logs.summary)}</pre>
                      </Card>
                    ) : null}

                    <Card size="small" title="Table">
                      <Table
                        size="small"
                        rowKey="seq"
                        columns={logColumns}
                        dataSource={logs?.items || []}
                        pagination={false}
                        scroll={{ x: 1200 }}
                      />
                    </Card>
                  </Space>
                ),
              },
              {
                key: 'action',
                label: 'Action',
                children: (
                  <Space direction="vertical" size={8} style={{ display: 'flex' }}>
                    <Card size="small" title="Query">
                      <Form form={actionQueryForm} layout="vertical" size="small">
                        <Row gutter={[8, 8]}>
                          <Col xs={12} md={8} xl={4}><Form.Item label="targetId" name="targetId"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="action" name="action"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="screen" name="screen"><Input style={compactInputStyle} /></Form.Item></Col>
                        </Row>
                        <Button size="small" type="primary" onClick={() => void loadActions()}>Load Actions</Button>
                      </Form>
                    </Card>

                    <Card size="small" title="Dynamic Buttons">
                      <Space direction="vertical" size={8} style={{ display: 'flex' }}>
                        {actions?.items.map((item) => (
                          <Card key={item.targetId} size="small">
                            <Space direction="vertical" size={8} style={{ display: 'flex' }}>
                              <Space size={4} wrap>
                                <Text strong>{item.targetId}</Text>
                                <Tag>{item.targetType}</Tag>
                                <Tag>{item.screen}</Tag>
                              </Space>
                              <Space size={4} wrap>
                                {item.actions.map((action) => (
                                  <Button size="small" key={`${item.targetId}-${action.name}`} onClick={() => void runAction(action.example)}>
                                    {action.name}
                                  </Button>
                                ))}
                              </Space>
                            </Space>
                          </Card>
                        ))}
                      </Space>
                    </Card>

                    <Card size="small" title="Catalog JSON">
                      <pre>{prettyJSON(actions || {})}</pre>
                    </Card>

                    <Card size="small" title="Manual Action">
                      <Form form={manualActionForm} layout="vertical" size="small">
                        <Row gutter={[8, 8]}>
                          <Col xs={12} md={8} xl={4}><Form.Item label="action" name="action" rules={[{ required: true }]}><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="targetId" name="targetId" rules={[{ required: true }]}><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="source" name="source"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="text" name="text"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="dx" name="dx"><InputNumber style={compactNumberStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="dy" name="dy"><InputNumber style={compactNumberStyle} /></Form.Item></Col>
                        </Row>
                        <Form.Item label="args JSON" name="args"><Input.TextArea rows={4} /></Form.Item>
                        <Space size={8}>
                          <Button size="small" type="primary" onClick={() => void runManualAction()}>Send Action</Button>
                        </Space>
                      </Form>
                    </Card>

                    <Card size="small" title="Latest Result">
                      <pre>{prettyJSON(actionResult || {})}</pre>
                    </Card>
                  </Space>
                ),
              },
              {
                key: 'state',
                label: 'State',
                children: (
                  <Space direction="vertical" size={8} style={{ display: 'flex' }}>
                    <Card size="small" title="Query">
                      <Form form={stateForm} layout="vertical" size="small">
                        <Row gutter={[8, 8]}>
                          <Col xs={12} md={8} xl={4}><Form.Item label="keys" name="keys"><Input style={compactInputStyle} placeholder="counter,enabled" /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="targetId" name="targetId"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="scope" name="scope"><Input style={compactInputStyle} placeholder="app / target / branch" /></Form.Item></Col>
                        </Row>
                        <Space size={8}>
                          <Button size="small" type="primary" onClick={() => void loadState()}>Query State</Button>
                          <Button size="small" onClick={() => void loadState({})}>Summary</Button>
                        </Space>
                      </Form>
                    </Card>

                    <Card size="small" title="JSON">
                      <pre>{prettyJSON(stateData || {})}</pre>
                    </Card>
                  </Space>
                ),
              },
              {
                key: 'snapshot',
                label: 'Snapshot',
                children: (
                  <Space direction="vertical" size={8} style={{ display: 'flex' }}>
                    <Card size="small" title="Query">
                      <Form form={snapshotForm} layout="vertical" size="small">
                        <Row gutter={[8, 8]}>
                          <Col xs={12} md={8} xl={4}><Form.Item label="targetId" name="targetId"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="scope" name="scope"><Input style={compactInputStyle} placeholder="self / branchToRoot / subtree" /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="depth" name="depth"><InputNumber style={compactNumberStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="types" name="types"><Input style={compactInputStyle} placeholder="Button,Text" /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="textKeyword" name="textKeyword"><Input style={compactInputStyle} /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="visible" name="visible"><Input style={compactInputStyle} placeholder="true / false" /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="enabled" name="enabled"><Input style={compactInputStyle} placeholder="true / false" /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="clickable" name="clickable"><Input style={compactInputStyle} placeholder="true / false" /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="fields" name="fields"><Input style={compactInputStyle} placeholder="id,type,text,bounds" /></Form.Item></Col>
                          <Col xs={12} md={8} xl={4}><Form.Item label="limit" name="limit"><InputNumber style={compactNumberStyle} /></Form.Item></Col>
                        </Row>
                        <Space size={8}>
                          <Button size="small" type="primary" onClick={() => void loadSnapshot()}>Query Snapshot</Button>
                          <Button size="small" onClick={() => void loadSnapshot({})}>Summary</Button>
                        </Space>
                      </Form>
                    </Card>

                    <Card size="small" title="JSON">
                      <pre>{prettyJSON(snapshot || {})}</pre>
                    </Card>
                  </Space>
                ),
              },
              {
                key: 'help',
                label: 'Help',
                children: (
                  <Space direction="vertical" size={8} style={{ display: 'flex' }}>
                    <Card size="small" title="JSON">
                      <pre>{prettyJSON(help || {})}</pre>
                    </Card>
                  </Space>
                ),
              },
            ]}
          />
          <Divider />
          <Text type="secondary">Vite + TypeScript + Antd build output served from Swift static dist.</Text>
        </Space>
      </Content>
    </Layout>
  )
}

export default App
