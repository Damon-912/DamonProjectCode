import React, { useState, useEffect } from 'react';
import {
  Card,
  Row,
  Col,
  Statistic,
  Table,
  Tag,
  Button,
  Space,
  Select,
  DatePicker,
  Badge,
  Tabs,
  Alert,
  Typography,
  Modal,
  Form,
  Input,
  message
} from 'antd';
import {
  WarningOutlined,
  ClockCircleOutlined,
  ExclamationCircleOutlined,
  EyeOutlined,
  CheckOutlined,
  CloseOutlined,
  ReloadOutlined,
  RiseOutlined,
  DollarOutlined
} from '@ant-design/icons';
import CustomPagination from '../../components/CustomPagination';
import type { ColumnsType } from 'antd/es/table';
import type { WarningRecord } from '@/api/warning';
import { queryWarningRecords, processWarning } from '@/api/warning';
import dayjs from 'dayjs';
import zhCN from 'antd/es/date-picker/locale/zh_CN';

const { Text } = Typography;
const { RangePicker } = DatePicker;
const { Option } = Select;
const { TabPane } = Tabs;
const { TextArea } = Input;

// 预警级别映射
const WARNING_LEVELS: Record<number, { text: string; tagColor: string }> = {
  1: { text: '低', tagColor: 'success' },
  2: { text: '中', tagColor: 'warning' },
  3: { text: '高', tagColor: 'error' },
};

// 预警类型映射（对应 BS_DRGWarningRecord.WarningType）
const WARNING_TYPES: Record<string, string> = {
  '01': '费用超支',
  '02': '低倍率',
  '03': '高倍率',
  '04': '编码异常',
  '05': '分解住院',
};

// 预警状态映射（对应 BS_DRGWarningRecord.WarningStatus）
const WARNING_STATUS: Record<string, { text: string; color: string }> = {
  '01': { text: '待处理', color: 'default' },
  '02': { text: '已确认', color: 'processing' },
  '03': { text: '已忽略', color: 'warning' },
  '04': { text: '已申诉', color: 'purple' },
  '05': { text: '已解决', color: 'success' },
};

interface StatsData {
  totalCount: number;
  pendingCount: number;
  processedCount: number;
  totalDiff?: number;
  totalProfit?: number;
  totalPayStandard?: number;
}

/** 格式化预警日期（兼容时间戳和字符串） */
const fmtDate = (val: any): string => {
  if (!val && val !== 0) return '-';
  const n = Number(val);
  if (!isNaN(n) && n > 100000000) return dayjs(n).format('YYYY-MM-DD');
  return String(val);
};

const Center: React.FC = () => {
  const [data, setData] = useState<WarningRecord[]>([]);
  const [loading, setLoading] = useState(false);
  const [statsLoading, setStatsLoading] = useState(false);
  const [stats, setStats] = useState<StatsData>({
    totalCount: 0,
    pendingCount: 0,
    processedCount: 0,
    totalDiff: 0,
    totalProfit: 0,
    totalPayStandard: 0,
  });

  // 筛选条件
  const [filterLevel, setFilterLevel] = useState<string>('');
  const [filterStatus, setFilterStatus] = useState<string>('');
  const [filterType, setFilterType] = useState<string>('');
  const [dateRange, setDateRange] = useState<[dayjs.Dayjs, dayjs.Dayjs] | null>(null);
  const [activeTab, setActiveTab] = useState('all');

  // 分页
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);

  // 处理弹窗
  const [processModalVisible, setProcessModalVisible] = useState(false);
  const [currentRecord, setCurrentRecord] = useState<WarningRecord | null>(null);
  const [processType, setProcessType] = useState<'processed' | 'ignored'>('processed');
  const [processing, setProcessing] = useState(false);
  const [form] = Form.useForm();

  // 加载全部数据（统计+记录）
  const loadData = async () => {
    setLoading(true);
    setStatsLoading(true);
    try {
      // 一次性获取全部记录（用于统计计算和表格展示）
      const res: any = await queryWarningRecords(
        {
          warningStatus: activeTab === 'pending' ? '01' : (activeTab === 'processed' ? '' : filterStatus),
          warningType: filterType || undefined,
          startDate: dateRange?.[0]?.format('YYYY-MM-DD') || '',
          endDate: dateRange?.[1]?.format('YYYY-MM-DD') || '',
        },
        { pageSize: 99999, currentPage: 1 }
      );
      console.log('[Center] records response:', res);

      if (res.errorCode === '0' || res.errorCode === 0) {
        const allRows: WarningRecord[] = (res.result.rows || []).map((item: any) => ({
          ...item,
          id: String(item.id || ''),
        }));

        // ====== 本地计算精确统计 ======
        const pendingCount = allRows.filter(r => r.warningStatus === '01').length;
        const processedAll = allRows.filter(r => r.warningStatus !== '01').length;
        const totalDiff = allRows.reduce((sum, r) => sum + (Number(r.diffAmount) || 0), 0);
        const totalProfit = allRows.reduce((sum, r) => {
          const d = Number(r.diffAmount) || 0;
          return sum + (d > 0 ? d : 0);
        }, 0);
        const totalPayStandard = allRows.reduce((sum, r) => sum + (Number(r.drgPayStandard) || 0), 0);

        setStats({
          totalCount: allRows.length,
          pendingCount,
          processedCount: processedAll,
          totalDiff,
          totalProfit,
          totalPayStandard,
        });
        setStatsLoading(false);

        // ====== 前端分页+筛选展示 ======
        let filtered = allRows;
        if (activeTab === 'processed') {
          filtered = allRows.filter(r => r.warningStatus !== '01');
        }
        if (filterLevel) {
          filtered = filtered.filter(r => Number(r.warningLevel) === Number(filterLevel));
        }
        // 更新total反映筛选后的数量
        setTotal(filtered.length);
        // 前端分页切片
        const start = (currentPage - 1) * pageSize;
        const paged = filtered.slice(start, start + pageSize);
        setData(paged);
      } else {
        setStatsLoading(false);
        console.warn('[Center] records API error:', res.errorCode, res.errorMessage);
      }
    } catch (error) {
      console.error('[Center] 查询预警记录失败:', error);
      setStatsLoading(false);
    } finally {
      setLoading(false);
    }
  };

  // 当筛选条件变化时自动重新加载
  useEffect(() => {
    loadData();
  }, [activeTab, filterStatus, filterType, filterLevel, dateRange, pageSize, currentPage]);

  // 处理预警按钮
  const handleProcess = (record: WarningRecord, type: 'processed' | 'ignored') => {
    setCurrentRecord(record);
    setProcessType(type);
    setProcessModalVisible(true);
    form.resetFields();
  };

  // 提交处理
  const submitProcess = async () => {
    try {
      const values = await form.validateFields();
      if (!currentRecord?.id) return;
      setProcessing(true);

      const res: any = await processWarning(
        currentRecord.id,
        processType,
        values.processRemarks || ''
      );

      if (res.errorCode === '0') {
        message.success(processType === 'processed' ? '已确认处理' : '已忽略该预警');
        setProcessModalVisible(false);
        loadData();
      } else {
        message.error(res.errorMessage || '处理失败');
      }
    } catch (error) {
      console.error('处理预警失败:', error);
    } finally {
      setProcessing(false);
    }
  };

  // 查看详情
  const handleView = (record: WarningRecord) => {
    Modal.info({
      title: '预警详情',
      width: 680,
      content: (
        <div style={{ marginTop: 16 }}>
          <Row gutter={[16, 16]}>
            <Col span={12}><Text strong>预警流水号:</Text> {record.warningNo}</Col>
            <Col span={12}><Text strong>就诊ID:</Text> {record.hisAdmId}</Col>
            <Col span={12}><Text strong>患者姓名:</Text> {record.patientName}</Col>
            <Col span={12}>
              <Text strong>预警级别:</Text>
              <Tag color={WARNING_LEVELS[record.warningLevel]?.tagColor}>
                {WARNING_LEVELS[record.warningLevel]?.text || record.warningLevel}
              </Tag>
            </Col>
            <Col span={12}><Text strong>科室:</Text> {record.deptName || '-'}</Col>
            <Col span={12}><Text strong>医生:</Text> {record.doctorName || '-'}</Col>
            <Col span={12}>
              <Text strong>预警类型:</Text>
              <Tag>{WARNING_TYPES[record.warningType] || record.warningType}</Tag>
            </Col>
            <Col span={12}>
              <Text strong>预警状态:</Text>
              <Tag color={WARNING_STATUS[record.warningStatus]?.color}>
                {WARNING_STATUS[record.warningStatus]?.text || record.warningStatus}
              </Tag>
            </Col>
            <Col span={24}><Text strong>预警规则:</Text> {record.ruleName}</Col>
            <Col span={12}><Text strong>DRG编码:</Text> {record.drgCode}</Col>
            <Col span={12}><Text strong>DRG名称:</Text> {record.drgName || '-'}</Col>
            <Col span={12}><Text strong>费用总额:</Text> ¥{(record.totalFee || 0).toLocaleString()}</Col>
            <Col span={12}><Text strong>DRG支付标准:</Text> ¥{(record.drgPayStandard || 0).toLocaleString()}</Col>
            <Col span={12}>
              <Text strong>费用差异:</Text>
              <Text type={(record.diffAmount || 0) < 0 ? 'danger' : 'success'}>
                ¥{(record.diffAmount || 0).toLocaleString()}
              </Text>
            </Col>
            <Col span={12}>
              <Text strong>差异率:</Text>
              <Text type={(record.diffRate || 0) < 0 ? 'danger' : 'success'}>
                {record.diffRate || 0}%
              </Text>
            </Col>
            <Col span={12}><Text strong>预警时间:</Text> {record.warningDateTime || `${fmtDate(record.warningDate)} ${record.warningTime || ''}`}</Col>
            {record.warningMessage && (
              <Col span={24}>
                <Text strong>预警消息:</Text>
                <div style={{ marginTop: 8, padding: 12, background: '#fff7e6', borderRadius: 4, whiteSpace: 'pre-wrap' }}>
                  {record.warningMessage}
                </div>
              </Col>
            )}
            {record.processRemark && (
              <>
                <Col span={12}><Text strong>处理人:</Text> {record.processUser || '-'}</Col>
                <Col span={12}><Text strong>处理时间:</Text> {record.processDateTime || `${fmtDate(record.processDate)} ${record.processTime || ''}`}</Col>
                <Col span={24}>
                  <Text strong>处理备注:</Text>
                  <div style={{ marginTop: 8, padding: 12, background: '#f5f5f5', borderRadius: 4 }}>
                    {record.processRemark}
                  </div>
                </Col>
              </>
            )}
          </Row>
        </div>
      ),
    });
  };

  // 重置筛选
  const handleReset = () => {
    setFilterLevel('');
    setFilterStatus('');
    setFilterType('');
    setDateRange(null);
    setCurrentPage(1);
    setActiveTab('all');
  };

  // 高危预警数量（level=3且待处理）
  const highRiskCount = data.filter(d => d.warningLevel === 3 && d.warningStatus === '01').length;

  const columns: ColumnsType<WarningRecord> = [
    {
      title: '级别',
      dataIndex: 'warningLevel',
      key: 'warningLevel',
      width: 65,
      render: (level: number) => (
        <Tag color={WARNING_LEVELS[level]?.tagColor || 'default'}>
          {WARNING_LEVELS[level]?.text || level}
        </Tag>
      ),
    },
    {
      title: '流水号',
      dataIndex: 'warningNo',
      key: 'warningNo',
      width: 160,
      ellipsis: true,
    },
    {
      title: '就诊ID',
      dataIndex: 'hisAdmId',
      key: 'hisAdmId',
      width: 100,
    },
    {
      title: '患者姓名',
      dataIndex: 'patientName',
      key: 'patientName',
      width: 100,
    },
    {
      title: '预警类型',
      dataIndex: 'warningType',
      key: 'warningType',
      width: 100,
      render: (type: string) => (
        <Tag>{WARNING_TYPES[type] || type}</Tag>
      ),
    },
    {
      title: '科室',
      dataIndex: 'deptName',
      key: 'deptName',
      width: 120,
      render: (val: string) => val || '-',
    },
    {
      title: 'DRG编码',
      dataIndex: 'drgCode',
      key: 'drgCode',
      width: 100,
    },
    {
      title: '费用总额',
      dataIndex: 'totalFee',
      key: 'totalFee',
      width: 120,
      align: 'right',
      render: (val: number) => `¥${(val || 0).toLocaleString()}`,
    },
    {
      title: 'DRG标准',
      dataIndex: 'drgPayStandard',
      key: 'drgPayStandard',
      width: 120,
      align: 'right',
      render: (val: number) => `¥${(val || 0).toLocaleString()}`,
    },
    {
      title: '超支/结余',
      key: 'balance',
      width: 120,
      align: 'right',
      render: (_, record) => {
        const diff = record.diffAmount || 0;
        const diffRate = record.diffRate || 0;
        return (
          <Text type={diff < 0 ? 'danger' : 'success'}>
            ¥{diff.toLocaleString()}
            <br />
            <small>({diffRate}%)</small>
          </Text>
        );
      },
    },
    {
      title: '预警时间',
      dataIndex: 'warningDateTime',
      key: 'warningDateTime',
      width: 110,
      render: (val: string, record) => (
        <span>
          {val || `${fmtDate(record.warningDate)} ${record.warningTime || ''}`}
        </span>
      ),
    },
    {
      title: '状态',
      dataIndex: 'warningStatus',
      key: 'warningStatus',
      width: 90,
      render: (status: string) => (
        <Tag color={WARNING_STATUS[status]?.color || 'default'}>
          {WARNING_STATUS[status]?.text || status}
        </Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 180,
      render: (_, record) => (
        <Space size="small">
          <Button
            type="link"
            size="small"
            icon={<EyeOutlined />}
            onClick={() => handleView(record)}
          >
            查看
          </Button>
          {record.warningStatus === '01' && (
            <>
              <Button
                type="link"
                size="small"
                style={{ color: '#52c41a' }}
                icon={<CheckOutlined />}
                onClick={() => handleProcess(record, 'processed')}
              >
                确认
              </Button>
              <Button
                type="link"
                size="small"
                danger
                icon={<CloseOutlined />}
                onClick={() => handleProcess(record, 'ignored')}
              >
                忽略
              </Button>
            </>
          )}
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: 16, height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* 统计卡片 */}
      <Row gutter={[16, 16]} style={{ marginBottom: 16 }}>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card loading={statsLoading}>
            <Statistic
              title="总预警数"
              value={stats.totalCount}
              prefix={<WarningOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card loading={statsLoading}>
            <Statistic
              title="待处理"
              value={stats.pendingCount}
              prefix={<ClockCircleOutlined />}
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card loading={statsLoading}>
            <Statistic
              title="严重预警(待处理)"
              value={highRiskCount}
              prefix={<ExclamationCircleOutlined />}
              valueStyle={{ color: '#ff4d4f' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card loading={statsLoading}>
            <Statistic
              title="总结余金额"
              value={stats.totalProfit || 0}
              precision={2}
              prefix={<RiseOutlined />}
              suffix="元"
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card loading={statsLoading}>
            <Statistic
              title="总标准费用"
              value={stats.totalPayStandard || 0}
              precision={2}
              prefix={<DollarOutlined />}
              suffix="元"
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card loading={statsLoading}>
            <Statistic
              title="总超支金额"
              value={Math.abs(stats.totalDiff || 0)}
              precision={2}
              prefix={<ExclamationCircleOutlined />}
              suffix="元"
              valueStyle={{ color: (stats.totalDiff || 0) < 0 ? '#ff4d4f' : '#52c41a' }}
            />
          </Card>
        </Col>
      </Row>

      {/* 预警列表 */}
      <Card style={{ flex: 1, display: 'flex', flexDirection: 'column' }} bodyStyle={{ height: '100%', padding: '16px 24px' }}>
        <Tabs
          activeKey={activeTab}
          onChange={(key) => { setActiveTab(key); setCurrentPage(1); }}
          style={{ marginBottom: 16 }}
        >
          <TabPane tab={<span>全部预警 <Badge count={stats.totalCount} style={{ marginLeft: 8 }} /></span>} key="all" />
          <TabPane tab={<span>待处理 <Badge count={stats.pendingCount} style={{ marginLeft: 8 }} color="#faad14" /></span>} key="pending" />
          <TabPane tab={<span>已处理 <Badge count={stats.processedCount} style={{ marginLeft: 8 }} color="#52c41a" /></span>} key="processed" />
        </Tabs>

        {/* 筛选栏 */}
        <Space style={{ marginBottom: 16 }} wrap>
          <RangePicker
            locale={zhCN}
            style={{ width: 240 }}
            value={dateRange as any}
            onChange={(dates) => {
              setDateRange(dates as [dayjs.Dayjs, dayjs.Dayjs] | null);
              setCurrentPage(1);
            }}
            placeholder={['开始日期', '结束日期']}
          />
          <Select
            placeholder="预警类型"
            style={{ width: 130 }}
            allowClear
            value={filterType || undefined}
            onChange={(val) => { setFilterType(val || ''); setCurrentPage(1); }}
          >
            <Option value="01">费用超支</Option>
            <Option value="02">低倍率</Option>
            <Option value="03">高倍率</Option>
            <Option value="04">编码异常</Option>
            <Option value="05">分解住院</Option>
          </Select>
          <Select
            placeholder="预警级别"
            style={{ width: 120 }}
            allowClear
            value={filterLevel || undefined}
            onChange={(val) => { setFilterLevel(val || ''); setCurrentPage(1); }}
          >
            <Option value="1">低</Option>
            <Option value="2">中</Option>
            <Option value="3">高</Option>
          </Select>
          <Button type="primary" icon={<ReloadOutlined />} onClick={loadData}>
            查询
          </Button>
          <Button onClick={handleReset}>重置</Button>
        </Space>

        {highRiskCount > 0 && (
          <Alert
            message={`当前有 ${highRiskCount} 条高级别预警需要紧急处理`}
            type="error"
            showIcon
            style={{ marginBottom: 16 }}
          />
        )}

        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1500, y: 'calc(100vh - 480px)' }}
          pagination={false}
        />
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <CustomPagination
            current={currentPage}
            pageSize={pageSize}
            total={total}
            onChange={(page: number, size: number) => {
              setCurrentPage(page);
              setPageSize(size || pageSize);
            }}
          />
        </div>
      </Card>

      {/* 处理弹窗 */}
      <Modal
        title={processType === 'processed' ? '确认预警' : '忽略预警'}
        open={processModalVisible}
        onOk={submitProcess}
        onCancel={() => setProcessModalVisible(false)}
        okText="确定"
        cancelText="取消"
        width={500}
        confirmLoading={processing}
      >
        <div style={{ marginBottom: 16 }}>
          <Text strong>预警流水号：</Text>{currentRecord?.warningNo}<br />
          <Text strong>患者：</Text>{currentRecord?.patientName} &nbsp;|&nbsp;
          <Text strong>规则：</Text>{currentRecord?.ruleName}
        </div>
        <Form form={form} layout="vertical">
          <Form.Item label="处理方式" name="processType">
            <Tag color={processType === 'processed' ? 'processing' : 'warning'}>
              {processType === 'processed' ? '标记为已确认' : '标记为已忽略'}
            </Tag>
          </Form.Item>
          <Form.Item
            label="处理备注"
            name="processRemarks"
            rules={[{ required: true, message: '请输入处理备注' }]}
          >
            <TextArea rows={4} placeholder="请输入处理备注说明..." />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default Center;
