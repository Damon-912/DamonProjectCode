import React, { useState, useEffect } from 'react';
import { 
  Table, 
  Card, 
  Button, 
  Space, 
  Form, 
  Select, 
  Tag, 
  Modal,
  Descriptions,
  message,
  Statistic,
  Row,
  Col,
  Progress,
  Timeline
} from 'antd';
import { 
  ReloadOutlined, 
  PlayCircleOutlined,
  PauseCircleOutlined,
  StopOutlined,
  EyeOutlined,
  SyncOutlined
} from '@ant-design/icons';
import CustomPagination from '../../components/CustomPagination';
import { useDict } from '../../hooks/useDict';
import { getDictLabel } from '../../utils/dict';

const { Option } = Select;

// 同步状态颜色映射（UI展示用）
const SYNC_STATUS_COLORS: Record<string, string> = {
  running: 'processing',
  success: 'success',
  failed: 'error',
  pending: 'default',
  stopped: 'default',
};

interface SyncTask {
  key: string;
  taskId: string;
  taskName: string;
  source: string;
  target: string;
  syncType: 'incremental' | 'full' | 'realtime';
  status: 'running' | 'success' | 'failed' | 'pending' | 'stopped';
  progress: number;
  totalCount: number;
  successCount: number;
  failedCount: number;
  startTime: string;
  endTime?: string;
  duration?: number;
  errorMsg?: string;
  lastSyncTime?: string;
  nextSyncTime?: string;
}

const SYNC_TASKS_DATA: SyncTask[] = [
  {
    key: '1',
    taskId: 'SYNC001',
    taskName: '病案数据同步',
    source: 'HIS数据库',
    target: 'DRG数据库',
    syncType: 'incremental',
    status: 'running',
    progress: 75,
    totalCount: 1000,
    successCount: 750,
    failedCount: 0,
    startTime: '2026-03-30 20:00:00',
    lastSyncTime: '2026-03-30 20:30:00',
    nextSyncTime: '2026-03-31 02:00:00'
  },
  {
    key: '2',
    taskId: 'SYNC002',
    taskName: '费用数据同步',
    source: 'HIS数据库',
    target: 'DRG数据库',
    syncType: 'incremental',
    status: 'success',
    progress: 100,
    totalCount: 500,
    successCount: 500,
    failedCount: 0,
    startTime: '2026-03-30 19:00:00',
    endTime: '2026-03-30 19:30:00',
    duration: 30,
    lastSyncTime: '2026-03-30 19:30:00',
    nextSyncTime: '2026-03-31 03:00:00'
  },
  {
    key: '3',
    taskId: 'SYNC003',
    taskName: '诊断数据同步',
    source: 'HIS数据库',
    target: 'DRG数据库',
    syncType: 'realtime',
    status: 'running',
    progress: 100,
    totalCount: 1200,
    successCount: 1180,
    failedCount: 20,
    startTime: '2026-03-30 18:00:00',
    lastSyncTime: '2026-03-30 21:00:00'
  },
  {
    key: '4',
    taskId: 'SYNC004',
    taskName: '科室数据同步',
    source: 'HIS数据库',
    target: 'DRG数据库',
    syncType: 'full',
    status: 'failed',
    progress: 45,
    totalCount: 200,
    successCount: 90,
    failedCount: 110,
    startTime: '2026-03-30 17:00:00',
    endTime: '2026-03-30 17:10:00',
    duration: 10,
    errorMsg: '连接超时：无法连接到源数据库'
  }
];

const DataSync: React.FC = () => {
  // 字典数据
  const { map: syncStatusMap, options: syncStatusOptions } = useDict('SYNC_STATUS');
  const { map: syncTypeMap, options: syncTypeOptions } = useDict('SYNC_TYPE');

  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<SyncTask[]>([]);
  const [autoRefresh, setAutoRefresh] = useState(true);
  const [detailModalVisible, setDetailModalVisible] = useState(false);
  const [currentRecord, setCurrentRecord] = useState<SyncTask | null>(null);

  useEffect(() => {
    fetchData();
    let interval: ReturnType<typeof setInterval>;
    if (autoRefresh) {
      interval = setInterval(fetchData, 5000);
    }
    return () => {
      if (interval) clearInterval(interval);
    };
  }, [autoRefresh]);

  const fetchData = async () => {
    setLoading(true);
    try {
      // 模拟API调用
      await new Promise(resolve => setTimeout(resolve, 500));
      setData(SYNC_TASKS_DATA);
    } catch (error) {
      message.error('获取同步任务数据失败');
    } finally {
      setLoading(false);
    }
  };

  const handleRefresh = () => {
    fetchData();
  };

  const handleStartSync = async (record: SyncTask) => {
    Modal.confirm({
      title: '启动同步',
      content: `确定要启动同步任务 "${record.taskName}" 吗？`,
      onOk: async () => {
        try {
          message.loading('启动中...', 0);
          await new Promise(resolve => setTimeout(resolve, 1000));
          message.destroy();
          message.success('启动成功');
          fetchData();
        } catch (error) {
          message.error('启动失败');
        }
      }
    });
  };

  const handlePauseSync = async (record: SyncTask) => {
    Modal.confirm({
      title: '暂停同步',
      content: `确定要暂停同步任务 "${record.taskName}" 吗？`,
      onOk: async () => {
        try {
          message.loading('暂停中...', 0);
          await new Promise(resolve => setTimeout(resolve, 1000));
          message.destroy();
          message.success('暂停成功');
          fetchData();
        } catch (error) {
          message.error('暂停失败');
        }
      }
    });
  };

  const handleStopSync = async (record: SyncTask) => {
    Modal.confirm({
      title: '停止同步',
      content: `确定要停止同步任务 "${record.taskName}" 吗？`,
      onOk: async () => {
        try {
          message.loading('停止中...', 0);
          await new Promise(resolve => setTimeout(resolve, 1000));
          message.destroy();
          message.success('停止成功');
          fetchData();
        } catch (error) {
          message.error('停止失败');
        }
      }
    });
  };

  const handleRetrySync = async (record: SyncTask) => {
    Modal.confirm({
      title: '重试同步',
      content: `确定要重试同步任务 "${record.taskName}" 吗？`,
      onOk: async () => {
        try {
          message.loading('重试中...', 0);
          await new Promise(resolve => setTimeout(resolve, 1000));
          message.destroy();
          message.success('重试成功');
          fetchData();
        } catch (error) {
          message.error('重试失败');
        }
      }
    });
  };

  const handleViewDetail = (record: SyncTask) => {
    setCurrentRecord(record);
    setDetailModalVisible(true);
  };

  const columns = [
    {
      title: '任务ID',
      dataIndex: 'taskId',
      key: 'taskId',
      width: 100,
      fixed: 'left' as const
    },
    {
      title: '任务名称',
      dataIndex: 'taskName',
      key: 'taskName',
      width: 150
    },
    {
      title: '数据源',
      dataIndex: 'source',
      key: 'source',
      width: 120
    },
    {
      title: '目标',
      dataIndex: 'target',
      key: 'target',
      width: 120
    },
    {
      title: '同步类型',
      dataIndex: 'syncType',
      key: 'syncType',
      width: 100,
      render: (type: string) => (
        <Tag color={
          type === 'incremental' ? 'blue' : type === 'full' ? 'green' : type === 'realtime' ? 'purple' : 'default'
        }>
          {getDictLabel(syncTypeMap, type)}
        </Tag>
      )
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      width: 100,
      render: (status: string) => (
        <Tag color={SYNC_STATUS_COLORS[status] || 'default'}>
          {getDictLabel(syncStatusMap, status)}
        </Tag>
      )
    },
    {
      title: '进度',
      dataIndex: 'progress',
      key: 'progress',
      width: 150,
      render: (progress: number, record: SyncTask) => (
        <Progress percent={progress} size="small" status={progress === 100 ? 'success' : 'active'} />
      )
    },
    {
      title: '总数/成功/失败',
      key: 'counts',
      width: 150,
      render: (_: any, record: SyncTask) => (
        <span>
          {record.totalCount} / <span style={{ color: '#52c41a' }}>{record.successCount}</span> / <span style={{ color: '#ff4d4f' }}>{record.failedCount}</span>
        </span>
      )
    },
    {
      title: '开始时间',
      dataIndex: 'startTime',
      key: 'startTime',
      width: 160
    },
    {
      title: '结束时间',
      dataIndex: 'endTime',
      key: 'endTime',
      width: 160,
      render: (value: string) => value || '-'
    },
    {
      title: '耗时(秒)',
      dataIndex: 'duration',
      key: 'duration',
      width: 100,
      render: (value: number) => value || '-'
    },
    {
      title: '操作',
      key: 'action',
      width: 200,
      fixed: 'right' as const,
      render: (_: any, record: SyncTask) => (
        <Space size="small">
          <Button
            type="link"
            size="small"
            icon={<EyeOutlined />}
            onClick={() => handleViewDetail(record)}
          >
            详情
          </Button>
          {record.status === 'pending' || record.status === 'stopped' ? (
            <Button
              type="link"
              size="small"
              icon={<PlayCircleOutlined />}
              onClick={() => handleStartSync(record)}
            >
              启动
            </Button>
          ) : null}
          {record.status === 'running' ? (
            <>
              <Button
                type="link"
                size="small"
                icon={<PauseCircleOutlined />}
                onClick={() => handlePauseSync(record)}
              >
                暂停
              </Button>
              <Button
                type="link"
                size="small"
                danger
                icon={<StopOutlined />}
                onClick={() => handleStopSync(record)}
              >
                停止
              </Button>
            </>
          ) : null}
          {record.status === 'failed' ? (
            <Button
              type="link"
              size="small"
              icon={<SyncOutlined />}
              onClick={() => handleRetrySync(record)}
            >
              重试
            </Button>
          ) : null}
        </Space>
      )
    }
  ];

  const runningCount = data.filter(d => d.status === 'running').length;
  const successCount = data.filter(d => d.status === 'success').length;
  const failedCount = data.filter(d => d.status === 'failed').length;
  const pendingCount = data.filter(d => d.status === 'pending').length;

  return (
    <div style={{ padding: 24, background: '#f0f2f5', minHeight: '100%' }}>
      <Card>
        <div style={{ marginBottom: 16 }}>
          <Space>
            <Button
              type="primary"
              icon={<ReloadOutlined />}
              onClick={handleRefresh}
              loading={loading}
            >
              刷新
            </Button>
            <Button
              type={autoRefresh ? 'primary' : 'default'}
              icon={<SyncOutlined spin={autoRefresh} />}
              onClick={() => setAutoRefresh(!autoRefresh)}
            >
              {autoRefresh ? '自动刷新: 开' : '自动刷新: 关'}
            </Button>
          </Space>
        </div>

        <Row gutter={16} style={{ marginBottom: 16 }}>
          <Col span={6}>
            <Card size="small">
              <Statistic
                title="运行中"
                value={runningCount}
                valueStyle={{ color: '#1890ff' }}
                prefix={<PlayCircleOutlined />}
              />
            </Card>
          </Col>
          <Col span={6}>
            <Card size="small">
              <Statistic
                title="成功"
                value={successCount}
                valueStyle={{ color: '#52c41a' }}
              />
            </Card>
          </Col>
          <Col span={6}>
            <Card size="small">
              <Statistic
                title="失败"
                value={failedCount}
                valueStyle={{ color: '#ff4d4f' }}
              />
            </Card>
          </Col>
          <Col span={6}>
            <Card size="small">
              <Statistic
                title="等待中"
                value={pendingCount}
                valueStyle={{ color: '#faad14' }}
              />
            </Card>
          </Col>
        </Row>

        <Table
          columns={columns}
          dataSource={data}
          loading={loading}
          scroll={{ x: 1800 }}
          pagination={false}
        />
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <CustomPagination
            current={1}
            pageSize={15}
            total={data.length}
            onChange={() => {}}
          />
        </div>
      </Card>

      <Modal
        title="同步任务详情"
        open={detailModalVisible}
        onCancel={() => setDetailModalVisible(false)}
        footer={null}
        width={800}
      >
        {currentRecord && (
          <>
            <Descriptions column={2} bordered style={{ marginBottom: 16 }}>
              <Descriptions.Item label="任务ID">{currentRecord.taskId}</Descriptions.Item>
              <Descriptions.Item label="任务名称">{currentRecord.taskName}</Descriptions.Item>
              <Descriptions.Item label="数据源">{currentRecord.source}</Descriptions.Item>
              <Descriptions.Item label="目标">{currentRecord.target}</Descriptions.Item>
              <Descriptions.Item label="同步类型">
                <Tag>{getDictLabel(syncTypeMap, currentRecord.syncType)}</Tag>
              </Descriptions.Item>
              <Descriptions.Item label="状态">
                <Tag color={SYNC_STATUS_COLORS[currentRecord.status]}>{getDictLabel(syncStatusMap, currentRecord.status)}</Tag>
              </Descriptions.Item>
              <Descriptions.Item label="开始时间">{currentRecord.startTime}</Descriptions.Item>
              <Descriptions.Item label="结束时间">{currentRecord.endTime || '-'}</Descriptions.Item>
              <Descriptions.Item label="耗时">{currentRecord.duration ? `${currentRecord.duration}秒` : '-'}</Descriptions.Item>
              <Descriptions.Item label="进度">{currentRecord.progress}%</Descriptions.Item>
              <Descriptions.Item label="总记录数">{currentRecord.totalCount}</Descriptions.Item>
              <Descriptions.Item label="成功记录数">{currentRecord.successCount}</Descriptions.Item>
              <Descriptions.Item label="失败记录数">{currentRecord.failedCount}</Descriptions.Item>
              <Descriptions.Item label="上次同步时间">{currentRecord.lastSyncTime || '-'}</Descriptions.Item>
              <Descriptions.Item label="下次同步时间">{currentRecord.nextSyncTime || '-'}</Descriptions.Item>
              {currentRecord.errorMsg && (
                <Descriptions.Item label="错误信息" span={2}>
                  <span style={{ color: '#ff4d4f' }}>{currentRecord.errorMsg}</span>
                </Descriptions.Item>
              )}
            </Descriptions>

            <Card title="同步日志" size="small">
              <Timeline
                items={[
                  {
                    color: 'green',
                    children: `${currentRecord.startTime} - 任务开始`
                  },
                  {
                    color: 'blue',
                    children: `${currentRecord.startTime} - 连接数据源 ${currentRecord.source}`
                  },
                  {
                    color: 'blue',
                    children: `${currentRecord.startTime} - 开始同步数据`
                  },
                  {
                    color: currentRecord.status === 'running' ? 'blue' : currentRecord.status === 'success' ? 'green' : 'red',
                    children: currentRecord.status === 'running' 
                      ? `同步中... (已完成 ${currentRecord.progress}%)`
                      : currentRecord.status === 'success'
                      ? `${currentRecord.endTime} - 同步完成，成功 ${currentRecord.successCount} 条`
                      : currentRecord.errorMsg
                      ? `${currentRecord.endTime} - 同步失败：${currentRecord.errorMsg}`
                      : `${currentRecord.endTime} - 任务结束`
                  }
                ]}
              />
            </Card>
          </>
        )}
      </Modal>
    </div>
  );
};

export default DataSync;
