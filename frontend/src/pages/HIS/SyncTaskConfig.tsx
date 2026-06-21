import React, { useState, useEffect } from 'react';
import {
  Card, Table, Button, Select, Tag, message, Input,
  Radio, InputNumber, TimePicker, Switch, Form, Col, Row, Badge
} from 'antd';
import zhCN from 'antd/es/date-picker/locale/zh_CN';
import {
  ReloadOutlined, SaveOutlined, SettingOutlined, FieldTimeOutlined,
  FileTextOutlined, SyncOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import CustomPagination from '../../components/CustomPagination';
import {
  getSyncConfig, saveSyncConfig, getSyncStatus, executeSyncTask,
  querySyncLogs, getHisServiceConfig, saveHisServiceConfig,
  SyncConfig, SyncStatus, SyncLogItem, QuerySyncLogsParams, Pagination,
  HisServiceConfig
} from '../../api/hisData';
import { queryHospitalInfo, HospitalInfoItem } from '../../api/basicData';
import { getCurrentHospId } from '../../utils/auth';
import dayjs from 'dayjs';
import 'dayjs/locale/zh-cn';
dayjs.locale('zh-cn');

const SyncTaskConfig: React.FC = () => {
  const [activeTab, setActiveTab] = useState('status');
  const [config, setConfig] = useState<SyncConfig>({
    hospCode: '',
    syncType: 'incremental',
    frequency: 'daily',
    scheduledTime: '00:00',
    lookbackDays: 3,
    enabled: true,
  });
  const [status, setStatus] = useState<SyncStatus>({
    status: 'idle',
    lastSyncTime: '',
    lastSyncStatus: '',
    errorMessage: '',
  });
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [hisConfigSaving, setHisConfigSaving] = useState(false);
  const [hospitals, setHospitals] = useState<HospitalInfoItem[]>([]);
  const [hospitalsLoading, setHospitalsLoading] = useState(false);
  const [hisServiceConfig, setHisServiceConfig] = useState<HisServiceConfig>({
    hisProtocol: 'http',
    hisIP: '',
    hisPort: '',
    hisURL: '',
    authorization: '',
  });

  const [logs, setLogs] = useState<SyncLogItem[]>([]);
  const [logsLoading, setLogsLoading] = useState(false);
  const [logsPagination, setLogsPagination] = useState<Pagination>({
    pageSize: 10,
    currentPage: 1,
  });
  const [logsTotal, setLogsTotal] = useState(0);
  const [logFilters, setLogFilters] = useState<QuerySyncLogsParams>({
    syncType: '',
    statusCode: '',
  });

  const fetchHospitals = async () => {
    setHospitalsLoading(true);
    try {
      const res = await queryHospitalInfo({ active: 'Y', descripts: '' });
      if (res.errorCode === '0' && res.result) {
        setHospitals(res.result);
        const currentHospId = getCurrentHospId();
        const currentHosp = res.result.find(h => h.id === currentHospId);
        if (currentHosp) {
          setConfig(prev => ({ ...prev, hospCode: currentHosp.hospCode }));
        } else if (res.result.length > 0) {
          setConfig(prev => ({ ...prev, hospCode: res.result[0].hospCode }));
        }
      }
    } catch {
      message.error('获取医疗机构列表失败');
    } finally {
      setHospitalsLoading(false);
    }
  };

  const fetchConfig = async () => {
    if (!config.hospCode) return;
    setLoading(true);
    try {
      const res = await getSyncConfig({ hospCode: config.hospCode });
      if (res.errorCode === '0' && res.result) {
        setConfig(res.result);
      }
    } catch {
      message.error('获取配置失败');
    } finally {
      setLoading(false);
    }
  };

  const fetchStatus = async () => {
    if (!config.hospCode) return;
    try {
      const res = await getSyncStatus({ hospCode: config.hospCode });
      if (res.errorCode === '0' && res.result) {
        setStatus(res.result);
      }
    } catch {
      // 忽略
    }
  };

  const fetchSyncLogs = async () => {
    if (!config.hospCode) return;
    setLogsLoading(true);
    try {
      const res = await querySyncLogs(
        { ...logFilters },
        logsPagination
      );
      if (res.errorCode === '0' && res.result) {
        setLogs(res.result.rows || []);
        setLogsTotal(res.result.total || 0);
      } else {
        setLogs([]);
        setLogsTotal(0);
      }
    } catch {
      message.error('获取同步日志失败');
    } finally {
      setLogsLoading(false);
    }
  };

  const fetchHisServiceConfig = async () => {
    if (!config.hospCode) return;
    setHisConfigSaving(true);
    try {
      const res = await getHisServiceConfig({ hospCode: config.hospCode });
      if (res.errorCode === '0' && res.result) {
        setHisServiceConfig(res.result);
      } else {
        // 如果未配置，使用默认值
        setHisServiceConfig({
          hisIP: '',
          hisPort: '',
          hisURL: '',
          authorization: '',
        });
      }
    } catch {
      message.error('获取HIS服务配置失败');
    } finally {
      setHisConfigSaving(false);
    }
  };

  const handleSaveHisServiceConfig = async () => {
    if (!config.hospCode) {
      message.error('请先选择医疗机构');
      return;
    }
    setHisConfigSaving(true);
    try {
      const res = await saveHisServiceConfig({
        hospCode: config.hospCode,
        ...hisServiceConfig,
      });
      if (res.errorCode === '0') {
        message.success('HIS服务配置保存成功');
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setHisConfigSaving(false);
    }
  };

  useEffect(() => {
    fetchHospitals();
  }, []);

  useEffect(() => {
    if (config.hospCode) {
      fetchConfig();
      fetchStatus();
      fetchSyncLogs();
    }
  }, [config.hospCode]);

  useEffect(() => {
    if (config.hospCode) {
      fetchSyncLogs();
    }
  }, [logsPagination.currentPage, logsPagination.pageSize]);

  const handleSave = async () => {
    setSaving(true);
    try {
      const res = await saveSyncConfig(config);
      if (res.errorCode === '0') {
        message.success('配置保存成功');
        fetchConfig();
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setSaving(false);
    }
  };

  const handleSync = async () => {
    setLoading(true);
    try {
      // 1. 先从后端接口获取HIS服务配置
      const hisConfigRes = await getHisServiceConfig({ hospCode: config.hospCode });
      if (hisConfigRes.errorCode !== '0' || !hisConfigRes.result) {
        message.error('获取HIS服务配置失败，请先在系统配置中设置HIS服务参数');
        setLoading(false);
        return;
      }
      const hisConfig = hisConfigRes.result;
      
      // 2. 验证配置是否完整
      if (!hisConfig.hisIP || !hisConfig.hisURL) {
        message.error('HIS服务配置不完整，请先在系统配置中设置HIS服务参数');
        setLoading(false);
        return;
      }
      
      // 3. 构造同步参数（包含HIS服务配置）
      const params: any = {
        hospCode: config.hospCode,
        syncType: config.syncType,
        hisServiceConfig: {
          hisIP: hisConfig.hisIP,
          hisPort: hisConfig.hisPort || '',
          hisURL: hisConfig.hisURL,
          authorization: hisConfig.authorization || 'Basic cHJoaXA6cHJoaXBAMjAyMA==',
        }
      };
      
      if (config.syncType === 'incremental') {
        params.lookbackDays = config.lookbackDays;
      } else {
        message.info('全量同步请使用数据同步监控页面');
        setLoading(false);
        return;
      }
      
      console.log('执行同步任务，参数:', params);
      const res = await executeSyncTask(params);
      if (res.errorCode === '0') {
        message.success('同步任务执行成功');
        fetchStatus();
        fetchSyncLogs();
      } else {
        message.error(res.errorMessage || '同步失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setLoading(false);
    }
  };

  const handleSearchLogs = () => {
    setLogsPagination({ ...logsPagination, currentPage: 1 });
    fetchSyncLogs();
  };

  const handleResetLogs = () => {
    setLogFilters({ syncType: '', statusCode: '' });
    setLogsPagination({ pageSize: 10, currentPage: 1 });
    setTimeout(() => fetchSyncLogs(), 0);
  };

  const getStatusTag = (s: string) => {
    switch (s) {
      case 'idle':
        return <Tag color="green">空闲</Tag>;
      case 'running':
        return <Tag color="blue">同步中</Tag>;
      case 'error':
        return <Tag color="red">错误</Tag>;
      default:
        return <Tag>{s}</Tag>;
    }
  };

  const getLogStatusTag = (code: string) => {
    switch (code) {
      case 'success':
        return <Badge status="success" text="成功" />;
      case 'failed':
        return <Badge status="error" text="失败" />;
      case 'running':
        return <Badge status="processing" text="执行中" />;
      default:
        return <Badge status="default" text={code || '-'} />;
    }
  };

  const logColumns: ColumnsType<SyncLogItem> = [
    { title: '任务名称', dataIndex: 'taskName', width: 140 },
    { title: '同步类型', dataIndex: 'syncType', width: 100, render: (v: string) => v === 'full' ? '全量' : '增量' },
    { title: '开始时间', dataIndex: 'startTime', width: 160 },
    { title: '结束时间', dataIndex: 'endTime', width: 160 },
    { title: '状态', dataIndex: 'statusCode', width: 100, render: getLogStatusTag },
    { title: '总条数', dataIndex: 'totalCount', width: 80, align: 'center' },
    { title: '成功', dataIndex: 'successCount', width: 80, align: 'center', render: (v: number) => <span style={{ color: '#52c41a' }}>{v}</span> },
    { title: '失败', dataIndex: 'failedCount', width: 80, align: 'center', render: (v: number) => <span style={{ color: v > 0 ? '#f5222d' : undefined }}>{v}</span> },
    { title: '错误信息', dataIndex: 'errorMessage', ellipsis: true },
  ];

  return (
    <div style={{ padding: 24 }}>
      <Row gutter={24}>
        <Col span={4}>
          <Button
            block
            type={activeTab === 'status' ? 'primary' : 'text'}
            icon={<SyncOutlined />}
            onClick={() => setActiveTab('status')}
            style={{ marginBottom: 12, justifyContent: 'flex-start' }}
          >
            同步状态
          </Button>
          <Button
            block
            type={activeTab === 'config' ? 'primary' : 'text'}
            icon={<FieldTimeOutlined />}
            onClick={() => setActiveTab('config')}
            style={{ marginBottom: 12, justifyContent: 'flex-start' }}
          >
            同步配置
          </Button>
          <Button
            block
            type={activeTab === 'hisConfig' ? 'primary' : 'text'}
            icon={<SettingOutlined />}
            onClick={() => {
              setActiveTab('hisConfig');
              fetchHisServiceConfig();
            }}
            style={{ marginBottom: 12, justifyContent: 'flex-start' }}
          >
            HIS服务配置
          </Button>
        </Col>
        <Col span={20}>
          {activeTab === 'status' && (
            <>
              <Card variant="borderless" style={{ marginBottom: 16 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 20 }}>
                  <span style={{ fontSize: 16 }}>医疗机构：</span>
                  <Select
                    loading={hospitalsLoading}
                    value={config.hospCode}
                    onChange={val => setConfig({ ...config, hospCode: val })}
                    placeholder="请选择医疗机构"
                    style={{ width: 380 }}
                    showSearch
                    options={hospitals.map(h => ({ label: `${h.code} - ${h.descripts}`, value: h.hospCode }))}
                  />
              <Button
                type="primary"
                icon={<SettingOutlined />}
                onClick={handleSync}
                loading={loading}
              >
                立即同步
              </Button>
                  <Button
                    icon={<ReloadOutlined />}
                    onClick={() => { fetchStatus(); fetchSyncLogs(); }}
                  >
                    刷新
                  </Button>
                </div>

                <Row gutter={[24, 12]}>
                  <Col span={8}>
                    <p style={{ margin: 0, fontSize: 16 }}>当前状态：{getStatusTag(status.status)}</p>
                  </Col>
                  <Col span={8}>
                    <p style={{ margin: 0, fontSize: 16 }}>最后同步时间：{status.lastSyncTime ? dayjs(status.lastSyncTime).format('YYYY年MM月DD日 HH:mm:ss') : '-'}</p>
                  </Col>
                  <Col span={8}>
                    <p style={{ margin: 0, fontSize: 16 }}>最后同步状态：
                      {status.lastSyncStatus === 'success' ? <Tag color="green">成功</Tag> :
                       status.lastSyncStatus === 'failed' ? <Tag color="red">失败</Tag> : '-'}
                    </p>
                  </Col>
                </Row>
                {status.errorMessage && (
                  <p style={{ color: 'red', marginTop: 12, marginBottom: 0, fontSize: 16 }}>错误信息：{status.errorMessage}</p>
                )}
              </Card>

              <Card
                title={<span style={{ fontSize: 16 }}><FileTextOutlined /> 同步日志</span>}
                variant="borderless"
              >
                <div style={{ display: 'flex', gap: 16, marginBottom: 16, flexWrap: 'wrap' }}>
                  <Select
                    placeholder="同步类型"
                    value={logFilters.syncType || undefined}
                    onChange={v => setLogFilters({ ...logFilters, syncType: v })}
                    style={{ width: 160 }}
                    allowClear
                    options={[
                      { label: '增量同步', value: 'incremental' },
                      { label: '全量同步', value: 'full' }
                    ]}
                  />
                  <Select
                    placeholder="执行状态"
                    value={logFilters.statusCode || undefined}
                    onChange={v => setLogFilters({ ...logFilters, statusCode: v })}
                    style={{ width: 160 }}
                    allowClear
                    options={[
                      { label: '成功', value: 'success' },
                      { label: '失败', value: 'failed' },
                      { label: '执行中', value: 'running' }
                    ]}
                  />
                  <Button type="primary" onClick={handleSearchLogs}>查询</Button>
                  <Button onClick={handleResetLogs}>重置</Button>
                </div>

                <Table
                  columns={logColumns}
                  dataSource={logs}
                  rowKey="id"
                  loading={logsLoading}
                  pagination={false}
                  scroll={{ x: 900 }}
                />
                <div style={{ marginTop: 16 }}>
                  <CustomPagination
                    total={logsTotal}
                    current={logsPagination.currentPage}
                    pageSize={logsPagination.pageSize}
                    onChange={(page: number, pageSize: number) =>
                      setLogsPagination({ currentPage: page, pageSize })
                    }
                  />
                </div>
              </Card>
            </>
          )}

          {activeTab === 'config' && (
            <div style={{ maxWidth: 900 }}>
              <Card
                title={<span style={{ fontSize: 16 }}>同步任务配置</span>}
                variant="borderless"
                extra={
                  <Button
                    type="primary"
                    icon={<SaveOutlined />}
                    onClick={handleSave}
                    loading={saving}
                  >
                    保存配置
                  </Button>
                }
              >
                <Form layout="vertical">
                  <Row gutter={[24, 0]}>
                    <Col span={12}>
                      <Form.Item label={<span style={{ fontSize: 16 }}>医疗机构</span>} style={{ marginBottom: 16 }}>
                        <Select
                          loading={hospitalsLoading}
                          value={config.hospCode}
                          onChange={val => setConfig({ ...config, hospCode: val })}
                          placeholder="请选择医疗机构"
                          style={{ width: '100%' }}
                          showSearch
                          options={hospitals.map(h => ({ label: `${h.code} - ${h.descripts}`, value: h.hospCode }))}
                        />
                      </Form.Item>
                    </Col>
                    <Col span={12}>
                      <Form.Item label={<span style={{ fontSize: 16 }}>同步类型</span>} style={{ marginBottom: 16 }}>
                        <Radio.Group
                          value={config.syncType}
                          onChange={e => setConfig({ ...config, syncType: e.target.value })}
                        >
                          <Radio value="incremental">增量同步</Radio>
                          <Radio value="full">全量同步</Radio>
                        </Radio.Group>
                      </Form.Item>
                    </Col>
                  </Row>

                  <Row gutter={[24, 0]}>
                    <Col span={12}>
                      <Form.Item label={<span style={{ fontSize: 16 }}>同步频率</span>} style={{ marginBottom: 16 }}>
                        <Select
                          value={config.frequency}
                          onChange={val => setConfig({ ...config, frequency: val })}
                          style={{ width: '100%' }}
                          options={[
                            { label: '手动执行', value: 'manual' },
                            { label: '每小时', value: 'hourly' },
                            { label: '每天', value: 'daily' },
                            { label: '每周', value: 'weekly' }
                          ]}
                        />
                      </Form.Item>
                    </Col>
                    {config.frequency === 'daily' && (
                      <Col span={12}>
                        <Form.Item label={<span style={{ fontSize: 16 }}>定时时间</span>} style={{ marginBottom: 16 }}>
                          <TimePicker
                            value={config.scheduledTime ? dayjs(config.scheduledTime, 'HH:mm') : null}
                            onChange={(_, timeString) => setConfig({ ...config, scheduledTime: timeString })}
                            format="HH:mm"
                            locale={zhCN}
                            style={{ width: '100%' }}
                          />
                        </Form.Item>
                      </Col>
                    )}
                  </Row>

                  {config.syncType === 'incremental' && (
                    <Row gutter={[24, 0]}>
                      <Col span={12}>
                        <Form.Item label={<span style={{ fontSize: 16 }}>回溯天数</span>} style={{ marginBottom: 16 }}>
                          <InputNumber
                            min={1}
                            max={30}
                            value={config.lookbackDays}
                            onChange={val => setConfig({ ...config, lookbackDays: val || 3 })}
                            style={{ width: 160 }}
                          />
                          <span style={{ marginLeft: 12, color: '#888', fontSize: 16 }}>天</span>
                        </Form.Item>
                      </Col>
                    </Row>
                  )}

                  <Row gutter={[24, 0]}>
                    <Col span={12}>
                      <Form.Item label={<span style={{ fontSize: 16 }}>启用状态</span>} style={{ marginBottom: 0 }}>
                        <Switch
                          checked={config.enabled}
                          onChange={checked => setConfig({ ...config, enabled: checked })}
                          checkedChildren="已启用"
                          unCheckedChildren="未启用"
                        />
                      </Form.Item>
                    </Col>
                  </Row>
                </Form>
              </Card>
            </div>
          )}

          {activeTab === 'hisConfig' && (
            <div style={{ maxWidth: 900 }}>
              <Card
                title={<span style={{ fontSize: 16 }}>HIS服务配置</span>}
                variant="borderless"
                extra={
                  <Button
                    type="primary"
                    icon={<SaveOutlined />}
                    onClick={handleSaveHisServiceConfig}
                    loading={hisConfigSaving}
                  >
                    保存配置
                  </Button>
                }
              >
                <Form layout="vertical">
                  <Row gutter={[24, 0]}>
                    <Col span={8}>
                      <Form.Item label={<span style={{ fontSize: 16 }}>协议</span>} style={{ marginBottom: 16 }} required>
                        <Select
                          value={hisServiceConfig.hisProtocol || 'http'}
                          onChange={val => setHisServiceConfig({ ...hisServiceConfig, hisProtocol: val })}
                          style={{ width: '100%' }}
                          options={[
                            { label: 'http', value: 'http' },
                            { label: 'https', value: 'https' }
                          ]}
                        />
                      </Form.Item>
                    </Col>
                    <Col span={8}>
                      <Form.Item label={<span style={{ fontSize: 16 }}>HIS服务IP地址</span>} style={{ marginBottom: 16 }} required>
                        <Input
                          value={hisServiceConfig.hisIP}
                          onChange={e => setHisServiceConfig({ ...hisServiceConfig, hisIP: e.target.value })}
                          placeholder="例如：172.16.1.6"
                          style={{ width: '100%' }}
                        />
                      </Form.Item>
                    </Col>
                    <Col span={8}>
                      <Form.Item label={<span style={{ fontSize: 16 }}>HIS服务端口</span>} style={{ marginBottom: 16 }}>
                        <Input
                          value={hisServiceConfig.hisPort}
                          onChange={e => setHisServiceConfig({ ...hisServiceConfig, hisPort: e.target.value })}
                          placeholder="例如：52773（空为默认端口）"
                          style={{ width: '100%' }}
                        />
                      </Form.Item>
                    </Col>
                  </Row>

                  <Row gutter={[24, 0]}>
                    <Col span={12}>
                      <Form.Item label={<span style={{ fontSize: 16 }}>HIS服务URL路径</span>} style={{ marginBottom: 16 }} required>
                        <Input
                          value={hisServiceConfig.hisURL}
                          onChange={e => setHisServiceConfig({ ...hisServiceConfig, hisURL: e.target.value })}
                          placeholder="例如：bdhealth/"
                          style={{ width: '100%' }}
                        />
                        <div style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                          填写HIS服务的URL路径，如：bdhealth/ 或 api/his/
                        </div>
                      </Form.Item>
                    </Col>
                    <Col span={12}>
                      <Form.Item label={<span style={{ fontSize: 16 }}>认证信息 (Authorization)</span>} style={{ marginBottom: 16 }} required>
                        <Input.TextArea
                          value={hisServiceConfig.authorization}
                          onChange={e => setHisServiceConfig({ ...hisServiceConfig, authorization: e.target.value })}
                          placeholder="例如：Basic xxxxxxxxxxxxxxxx"
                          rows={3}
                          style={{ width: '100%' }}
                        />
                        <div style={{ color: '#888', fontSize: 12, marginTop: 4 }}>
                          Base64编码的认证信息，格式：Basic xxxx
                        </div>
                      </Form.Item>
                    </Col>
                  </Row>

                  <Row gutter={[24, 0]}>
                    <Col span={24}>
                      <div style={{ padding: 16, backgroundColor: '#f0f5ff', borderRadius: 8, marginBottom: 16 }}>
                        <p style={{ margin: 0, fontWeight: 500, fontSize: 14 }}>配置说明：</p>
                        <p style={{ margin: '8px 0 0 0', fontSize: 13, color: '#666' }}>
                          1. 此配置用于系统调用HIS提供的API服务（如获取住院患者列表、患者就诊信息等）<br/>
                          2. 系统会根据以上配置自动拼接HIS服务地址，格式如：http://IP:端口/URL路径<br/>
                          3. 修改配置后，点击"保存配置"按钮生效<br/>
                          4. 不同医疗机构可以配置不同的HIS服务地址
                        </p>
                      </div>
                    </Col>
                  </Row>
                </Form>
              </Card>
            </div>
          )}
        </Col>
      </Row>
    </div>
  );
};

export default SyncTaskConfig;
