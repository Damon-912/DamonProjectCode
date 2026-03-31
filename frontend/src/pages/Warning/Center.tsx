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
  CheckCircleOutlined,
  ClockCircleOutlined,
  ExclamationCircleOutlined,
  EyeOutlined,
  CheckOutlined,
  CloseOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';

const { Title, Text } = Typography;
const { RangePicker } = DatePicker;
const { Option } = Select;
const { TabPane } = Tabs;
const { TextArea } = Input;

// 预警级别
const WARNING_LEVELS = {
  1: { text: '提示', color: 'green', tagColor: 'success' },
  2: { text: '警告', color: 'orange', tagColor: 'warning' },
  3: { text: '严重', color: 'red', tagColor: 'error' },
};

// 处理状态
const PROCESS_STATUS = {
  '待处理': { text: '待处理', color: 'default' },
  '已处理': { text: '已处理', color: 'success' },
  '已忽略': { text: '已忽略', color: 'warning' },
};

interface WarningRecord {
  id: string;
  admissionNo: string;
  patientName: string;
  ruleName: string;
  warningLevel: 1 | 2 | 3;
  totalCost: number;
  drgPayment: number;
  balanceAmount: number;
  balancePercent: number;
  deptName: string;
  warningDate: string;
  processStatus: '待处理' | '已处理' | '已忽略';
  processUser?: string;
  processRemarks?: string;
}

// 模拟数据
const mockData: WarningRecord[] = [
  {
    id: '1',
    admissionNo: '20240001',
    patientName: '张三',
    ruleName: '费用超支预警',
    warningLevel: 3,
    totalCost: 15800,
    drgPayment: 12000,
    balanceAmount: -3800,
    balancePercent: -31.67,
    deptName: '心内科',
    warningDate: '2026-03-28 14:30:00',
    processStatus: '待处理',
  },
  {
    id: '2',
    admissionNo: '20240002',
    patientName: '李四',
    ruleName: '高倍率预警',
    warningLevel: 2,
    totalCost: 25000,
    drgPayment: 18000,
    balanceAmount: -7000,
    balancePercent: -38.89,
    deptName: '骨科',
    warningDate: '2026-03-28 10:15:00',
    processStatus: '待处理',
  },
  {
    id: '3',
    admissionNo: '20240003',
    patientName: '王五',
    ruleName: '费用超支预警',
    warningLevel: 1,
    totalCost: 8500,
    drgPayment: 8000,
    balanceAmount: -500,
    balancePercent: -6.25,
    deptName: '呼吸内科',
    warningDate: '2026-03-27 16:45:00',
    processStatus: '已处理',
    processUser: '医生A',
    processRemarks: '已核实，患者病情复杂，费用合理',
  },
  {
    id: '4',
    admissionNo: '20240004',
    patientName: '赵六',
    ruleName: '低倍率预警',
    warningLevel: 1,
    totalCost: 4500,
    drgPayment: 8000,
    balanceAmount: 3500,
    balancePercent: 43.75,
    deptName: '普外科',
    warningDate: '2026-03-27 09:30:00',
    processStatus: '已忽略',
    processUser: '医生B',
    processRemarks: '提前出院，费用正常',
  },
  {
    id: '5',
    admissionNo: '20240005',
    patientName: '钱七',
    ruleName: '编码异常预警',
    warningLevel: 2,
    totalCost: 12000,
    drgPayment: 12000,
    balanceAmount: 0,
    balancePercent: 0,
    deptName: '神经内科',
    warningDate: '2026-03-26 11:20:00',
    processStatus: '待处理',
  },
];

const Center: React.FC = () => {
  const [data, setData] = useState<WarningRecord[]>(mockData);
  const [loading, setLoading] = useState(false);
  const [filterLevel, setFilterLevel] = useState<string>('');
  const [filterDept, setFilterDept] = useState<string>('');
  const [activeTab, setActiveTab] = useState('all');
  const [processModalVisible, setProcessModalVisible] = useState(false);
  const [currentRecord, setCurrentRecord] = useState<WarningRecord | null>(null);
  const [form] = Form.useForm();

  // 统计数据
  const stats = {
    total: data.length,
    pending: data.filter(d => d.processStatus === '待处理').length,
    highRisk: data.filter(d => d.warningLevel === 3 && d.processStatus === '待处理').length,
    processed: data.filter(d => d.processStatus === '已处理').length,
  };

  // 筛选数据
  const getFilteredData = () => {
    let filtered = data;
    
    // 标签页筛选
    if (activeTab === 'pending') {
      filtered = filtered.filter(d => d.processStatus === '待处理');
    } else if (activeTab === 'processed') {
      filtered = filtered.filter(d => d.processStatus === '已处理' || d.processStatus === '已忽略');
    }
    
    // 级别筛选
    if (filterLevel) {
      filtered = filtered.filter(d => d.warningLevel === parseInt(filterLevel));
    }
    
    // 科室筛选
    if (filterDept) {
      filtered = filtered.filter(d => d.deptName === filterDept);
    }
    
    return filtered;
  };

  // 处理预警
  const handleProcess = (record: WarningRecord, status: '已处理' | '已忽略') => {
    setCurrentRecord({ ...record, processStatus: status });
    setProcessModalVisible(true);
    form.resetFields();
    form.setFieldsValue({ processStatus: status });
  };

  // 提交处理
  const submitProcess = async () => {
    try {
      const values = await form.validateFields();
      const updatedData = data.map(item => {
        if (item.id === currentRecord?.id) {
          return {
            ...item,
            processStatus: currentRecord.processStatus,
            processUser: '当前用户',
            processRemarks: values.processRemarks,
          };
        }
        return item;
      });
      setData(updatedData);
      setProcessModalVisible(false);
      message.success('处理成功');
    } catch (error) {
      console.error(error);
    }
  };

  // 查看详情
  const handleView = (record: WarningRecord) => {
    Modal.info({
      title: '预警详情',
      width: 600,
      content: (
        <div style={{ marginTop: 16 }}>
          <Row gutter={[16, 16]}>
            <Col span={12}><Text strong>住院号:</Text> {record.admissionNo}</Col>
            <Col span={12}><Text strong>患者姓名:</Text> {record.patientName}</Col>
            <Col span={12}><Text strong>科室:</Text> {record.deptName}</Col>
            <Col span={12}><Text strong>预警时间:</Text> {record.warningDate}</Col>
            <Col span={24}><Text strong>预警规则:</Text> {record.ruleName}</Col>
            <Col span={12}><Text strong>费用总额:</Text> ¥{record.totalCost.toLocaleString()}</Col>
            <Col span={12}><Text strong>DRG支付标准:</Text> ¥{record.drgPayment.toLocaleString()}</Col>
            <Col span={12}>
              <Text strong>超支/结余:</Text>
              <Text type={record.balanceAmount < 0 ? 'danger' : 'success'}>
                ¥{record.balanceAmount.toLocaleString()}
              </Text>
            </Col>
            <Col span={12}>
              <Text strong>比例:</Text>
              <Text type={record.balancePercent < 0 ? 'danger' : 'success'}>
                {record.balancePercent}%
              </Text>
            </Col>
            {record.processUser && (
              <>
                <Col span={12}><Text strong>处理人:</Text> {record.processUser}</Col>
                <Col span={12}><Text strong>处理备注:</Text> {record.processRemarks}</Col>
              </>
            )}
          </Row>
        </div>
      ),
    });
  };

  const columns: ColumnsType<WarningRecord> = [
    {
      title: '预警级别',
      dataIndex: 'warningLevel',
      key: 'warningLevel',
      width: 90,
      render: (level: 1 | 2 | 3) => (
        <Tag color={WARNING_LEVELS[level].tagColor}>
          {WARNING_LEVELS[level].text}
        </Tag>
      ),
    },
    {
      title: '住院号',
      dataIndex: 'admissionNo',
      key: 'admissionNo',
      width: 100,
    },
    {
      title: '患者姓名',
      dataIndex: 'patientName',
      key: 'patientName',
      width: 100,
    },
    {
      title: '科室',
      dataIndex: 'deptName',
      key: 'deptName',
      width: 120,
    },
    {
      title: '预警规则',
      dataIndex: 'ruleName',
      key: 'ruleName',
      width: 140,
    },
    {
      title: '费用总额',
      dataIndex: 'totalCost',
      key: 'totalCost',
      width: 120,
      align: 'right',
      render: (val: number) => `¥${val.toLocaleString()}`,
    },
    {
      title: 'DRG标准',
      dataIndex: 'drgPayment',
      key: 'drgPayment',
      width: 120,
      align: 'right',
      render: (val: number) => `¥${val.toLocaleString()}`,
    },
    {
      title: '超支/结余',
      key: 'balance',
      width: 120,
      align: 'right',
      render: (_, record) => (
        <Text type={record.balanceAmount < 0 ? 'danger' : 'success'}>
          ¥{record.balanceAmount.toLocaleString()}
          <br />
          <small>({record.balancePercent}%)</small>
        </Text>
      ),
    },
    {
      title: '预警时间',
      dataIndex: 'warningDate',
      key: 'warningDate',
      width: 160,
    },
    {
      title: '状态',
      dataIndex: 'processStatus',
      key: 'processStatus',
      width: 100,
      render: (status: string) => (
        <Tag color={PROCESS_STATUS[status].color}>
          {PROCESS_STATUS[status].text}
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
          {record.processStatus === '待处理' && (
            <>
              <Button
                type="link"
                size="small"
                style={{ color: '#52c41a' }}
                icon={<CheckOutlined />}
                onClick={() => handleProcess(record, '已处理')}
              >
                处理
              </Button>
              <Button
                type="link"
                size="small"
                danger
                icon={<CloseOutlined />}
                onClick={() => handleProcess(record, '已忽略')}
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
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="总预警数"
              value={stats.total}
              prefix={<WarningOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="待处理"
              value={stats.pending}
              prefix={<ClockCircleOutlined />}
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="严重预警"
              value={stats.highRisk}
              prefix={<ExclamationCircleOutlined />}
              valueStyle={{ color: '#ff4d4f' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="已处理"
              value={stats.processed}
              prefix={<CheckCircleOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
      </Row>

      {/* 预警列表 */}
      <Card style={{ flex: 1, display: 'flex', flexDirection: 'column' }} bodyStyle={{ height: '100%', padding: '16px 24px' }}>
        <Tabs activeKey={activeTab} onChange={setActiveTab} style={{ marginBottom: 16 }}>
          <TabPane tab={<span>全部预警 <Badge count={stats.total} style={{ marginLeft: 8 }} /></span>} key="all" />
          <TabPane tab={<span>待处理 <Badge count={stats.pending} style={{ marginLeft: 8 }} color="#faad14" /></span>} key="pending" />
          <TabPane tab={<span>已处理 <Badge count={stats.processed} style={{ marginLeft: 8 }} color="#52c41a" /></span>} key="processed" />
        </Tabs>

        {/* 筛选栏 */}
        <Space style={{ marginBottom: 16 }} wrap>
          <RangePicker style={{ width: 240 }} />
          <Select
            placeholder="预警级别"
            style={{ width: 120 }}
            allowClear
            value={filterLevel || undefined}
            onChange={setFilterLevel}
          >
            <Option value="1">提示</Option>
            <Option value="2">警告</Option>
            <Option value="3">严重</Option>
          </Select>
          <Select
            placeholder="科室"
            style={{ width: 140 }}
            allowClear
            value={filterDept || undefined}
            onChange={setFilterDept}
          >
            <Option value="心内科">心内科</Option>
            <Option value="骨科">骨科</Option>
            <Option value="呼吸内科">呼吸内科</Option>
            <Option value="普外科">普外科</Option>
            <Option value="神经内科">神经内科</Option>
          </Select>
          <Button type="primary">查询</Button>
          <Button>重置</Button>
        </Space>

        {stats.highRisk > 0 && (
          <Alert
            message={`当前有 ${stats.highRisk} 条严重预警需要紧急处理`}
            type="error"
            showIcon
            style={{ marginBottom: 16 }}
          />
        )}

        <Table
          columns={columns}
          dataSource={getFilteredData()}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1200, y: 'calc(100vh - 450px)' }}
          pagination={{
            pageSize: 10,
            showSizeChanger: true,
            showTotal: (total) => `共 ${total} 条`,
            locale: {
              items_per_page: '/页',
              jump_to: '跳至',
              page: '页',
            }
          }}
        />
      </Card>

      {/* 处理弹窗 */}
      <Modal
        title={currentRecord?.processStatus === '已处理' ? '处理预警' : '忽略预警'}
        open={processModalVisible}
        onOk={submitProcess}
        onCancel={() => setProcessModalVisible(false)}
        width={500}
      >
        <Form form={form} layout="vertical">
          <Form.Item label="处理方式" name="processStatus">
            <Tag color={currentRecord?.processStatus === '已处理' ? 'success' : 'warning'}>
              {currentRecord?.processStatus === '已处理' ? '标记为已处理' : '标记为已忽略'}
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
