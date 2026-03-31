import React, { useState } from 'react';
import {
  Card,
  Table,
  Button,
  Space,
  Tag,
  Select,
  DatePicker,
  Row,
  Col,
  Typography,
  Input,
  Modal,
  Descriptions,
  Badge,
  Statistic,
  Tooltip,
  message,
} from 'antd';
import {
  SearchOutlined,
  ReloadOutlined,
  DownloadOutlined,
  EyeOutlined,
  FileExcelOutlined,
  HistoryOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  ExclamationCircleOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';

const { Title, Text } = Typography;
const { RangePicker } = DatePicker;
const { Option } = Select;

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

// 规则类型
const RULE_TYPES = {
  '01': '费用超支',
  '02': '低倍率',
  '03': '高倍率',
  '04': '编码异常',
  '05': '分解住院',
};

interface WarningRecord {
  id: string;
  admissionNo: string;
  patientName: string;
  patientGender: string;
  patientAge: number;
  ruleCode: string;
  ruleName: string;
  ruleType: string;
  warningLevel: 1 | 2 | 3;
  totalCost: number;
  drgPayment: number;
  balanceAmount: number;
  balancePercent: number;
  drgCode: string;
  drgName: string;
  deptCode: string;
  deptName: string;
  doctorName: string;
  admissionDate: string;
  dischargeDate: string;
  warningDate: string;
  processStatus: '待处理' | '已处理' | '已忽略';
  processUser?: string;
  processDate?: string;
  processRemarks?: string;
}

// 模拟数据
const mockRecords: WarningRecord[] = [
  {
    id: '1',
    admissionNo: '20240001',
    patientName: '张三',
    patientGender: '男',
    patientAge: 65,
    ruleCode: 'WR001',
    ruleName: '费用超支预警（严重）',
    ruleType: '01',
    warningLevel: 3,
    totalCost: 15800,
    drgPayment: 12000,
    balanceAmount: -3800,
    balancePercent: -31.67,
    drgCode: 'ES23',
    drgName: '呼吸系统肿瘤',
    deptCode: '001',
    deptName: '心内科',
    doctorName: '王医生',
    admissionDate: '2026-03-15',
    dischargeDate: '2026-03-28',
    warningDate: '2026-03-28 14:30:00',
    processStatus: '已处理',
    processUser: '李主任',
    processDate: '2026-03-28 16:00:00',
    processRemarks: '患者病情复杂，使用高价药品，费用合理',
  },
  {
    id: '2',
    admissionNo: '20240002',
    patientName: '李四',
    patientGender: '女',
    patientAge: 58,
    ruleCode: 'WR003',
    ruleName: '高倍率预警',
    ruleType: '03',
    warningLevel: 2,
    totalCost: 25000,
    drgPayment: 18000,
    balanceAmount: -7000,
    balancePercent: -38.89,
    drgCode: 'IC13',
    drgName: '关节置换',
    deptCode: '002',
    deptName: '骨科',
    doctorName: '张医生',
    admissionDate: '2026-03-10',
    dischargeDate: '2026-03-27',
    warningDate: '2026-03-28 10:15:00',
    processStatus: '已处理',
    processUser: '刘主任',
    processDate: '2026-03-28 14:30:00',
    processRemarks: '手术中使用进口耗材，已核实',
  },
  {
    id: '3',
    admissionNo: '20240003',
    patientName: '王五',
    patientGender: '男',
    patientAge: 72,
    ruleCode: 'WR002',
    ruleName: '费用超支预警（警告）',
    ruleType: '01',
    warningLevel: 2,
    totalCost: 18500,
    drgPayment: 15000,
    balanceAmount: -3500,
    balancePercent: -23.33,
    drgCode: 'FB23',
    drgName: '心脏介入治疗',
    deptCode: '001',
    deptName: '心内科',
    doctorName: '陈医生',
    admissionDate: '2026-03-12',
    dischargeDate: '2026-03-26',
    warningDate: '2026-03-26 09:00:00',
    processStatus: '已忽略',
    processUser: '赵医生',
    processDate: '2026-03-26 11:00:00',
    processRemarks: '患者合并多种基础疾病，费用在合理范围',
  },
  {
    id: '4',
    admissionNo: '20240004',
    patientName: '赵六',
    patientGender: '女',
    patientAge: 45,
    ruleCode: 'WR004',
    ruleName: '低倍率预警',
    ruleType: '02',
    warningLevel: 1,
    totalCost: 4500,
    drgPayment: 8000,
    balanceAmount: 3500,
    balancePercent: 43.75,
    drgCode: 'GC13',
    drgName: '消化系统其他手术',
    deptCode: '003',
    deptName: '普外科',
    doctorName: '孙医生',
    admissionDate: '2026-03-20',
    dischargeDate: '2026-03-25',
    warningDate: '2026-03-25 16:00:00',
    processStatus: '已处理',
    processUser: '钱主任',
    processDate: '2026-03-25 17:30:00',
    processRemarks: '患者恢复良好提前出院',
  },
  {
    id: '5',
    admissionNo: '20240005',
    patientName: '钱七',
    patientGender: '男',
    patientAge: 60,
    ruleCode: 'WR005',
    ruleName: '编码异常预警',
    ruleType: '04',
    warningLevel: 2,
    totalCost: 12000,
    drgPayment: 12000,
    balanceAmount: 0,
    balancePercent: 0,
    drgCode: 'BR23',
    drgName: '神经系统肿瘤',
    deptCode: '004',
    deptName: '神经内科',
    doctorName: '周医生',
    admissionDate: '2026-03-18',
    dischargeDate: '2026-03-27',
    warningDate: '2026-03-27 11:20:00',
    processStatus: '待处理',
  },
  {
    id: '6',
    admissionNo: '20240006',
    patientName: '孙八',
    patientGender: '女',
    patientAge: 55,
    ruleCode: 'WR001',
    ruleName: '费用超支预警（严重）',
    ruleType: '01',
    warningLevel: 3,
    totalCost: 32000,
    drgPayment: 22000,
    balanceAmount: -10000,
    balancePercent: -45.45,
    drgCode: 'IC13',
    drgName: '关节置换',
    deptCode: '002',
    deptName: '骨科',
    doctorName: '吴医生',
    admissionDate: '2026-03-08',
    dischargeDate: '2026-03-27',
    warningDate: '2026-03-27 15:00:00',
    processStatus: '已处理',
    processUser: '郑主任',
    processDate: '2026-03-27 16:30:00',
    processRemarks: '术后感染需长期抗感染治疗，费用合理',
  },
];

const Records: React.FC = () => {
  const [data, setData] = useState<WarningRecord[]>(mockRecords);
  const [loading, setLoading] = useState(false);
  const [detailVisible, setDetailVisible] = useState(false);
  const [currentRecord, setCurrentRecord] = useState<WarningRecord | null>(null);
  
  // 筛选条件
  const [filterStatus, setFilterStatus] = useState<string>('');
  const [filterLevel, setFilterLevel] = useState<string>('');
  const [filterDept, setFilterDept] = useState<string>('');
  const [filterRuleType, setFilterRuleType] = useState<string>('');
  const [filterAdmissionNo, setFilterAdmissionNo] = useState<string>('');

  // 统计数据
  const stats = {
    total: data.length,
    processed: data.filter(d => d.processStatus === '已处理').length,
    ignored: data.filter(d => d.processStatus === '已忽略').length,
    pending: data.filter(d => d.processStatus === '待处理').length,
    totalBalance: data.reduce((sum, d) => sum + d.balanceAmount, 0),
  };

  // 筛选数据
  const getFilteredData = () => {
    let filtered = [...data];
    
    if (filterStatus) {
      filtered = filtered.filter(d => d.processStatus === filterStatus);
    }
    if (filterLevel) {
      filtered = filtered.filter(d => d.warningLevel === parseInt(filterLevel));
    }
    if (filterDept) {
      filtered = filtered.filter(d => d.deptName === filterDept);
    }
    if (filterRuleType) {
      filtered = filtered.filter(d => d.ruleType === filterRuleType);
    }
    if (filterAdmissionNo) {
      filtered = filtered.filter(d => d.admissionNo.includes(filterAdmissionNo) || d.patientName.includes(filterAdmissionNo));
    }
    
    return filtered;
  };

  // 查看详情
  const handleView = (record: WarningRecord) => {
    setCurrentRecord(record);
    setDetailVisible(true);
  };

  // 导出数据
  const handleExport = () => {
    message.success('数据导出成功');
  };

  // 重置筛选
  const handleReset = () => {
    setFilterStatus('');
    setFilterLevel('');
    setFilterDept('');
    setFilterRuleType('');
    setFilterAdmissionNo('');
    message.success('筛选条件已重置');
  };

  const columns: ColumnsType<WarningRecord> = [
    {
      title: '预警时间',
      dataIndex: 'warningDate',
      key: 'warningDate',
      width: 160,
      sorter: (a, b) => new Date(a.warningDate).getTime() - new Date(b.warningDate).getTime(),
    },
    {
      title: '级别',
      dataIndex: 'warningLevel',
      key: 'warningLevel',
      width: 80,
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
      title: '患者信息',
      key: 'patient',
      width: 120,
      render: (_, record) => (
        <div>
          <div>{record.patientName}</div>
          <Text type="secondary" style={{ fontSize: 12 }}>
            {record.patientGender} / {record.patientAge}岁
          </Text>
        </div>
      ),
    },
    {
      title: '科室/医生',
      key: 'dept',
      width: 140,
      render: (_, record) => (
        <div>
          <div>{record.deptName}</div>
          <Text type="secondary" style={{ fontSize: 12 }}>
            {record.doctorName}
          </Text>
        </div>
      ),
    },
    {
      title: '预警规则',
      key: 'rule',
      width: 180,
      render: (_, record) => (
        <div>
          <div>{record.ruleName}</div>
          <Text type="secondary" style={{ fontSize: 12 }}>
            {RULE_TYPES[record.ruleType]}
          </Text>
        </div>
      ),
    },
    {
      title: 'DRG信息',
      key: 'drg',
      width: 140,
      render: (_, record) => (
        <div>
          <div>{record.drgCode}</div>
          <Text type="secondary" style={{ fontSize: 12 }}>
            {record.drgName}
          </Text>
        </div>
      ),
    },
    {
      title: '费用/标准',
      key: 'cost',
      width: 160,
      align: 'right',
      render: (_, record) => (
        <div>
          <div>¥{record.totalCost.toLocaleString()}</div>
          <Text type="secondary" style={{ fontSize: 12 }}>
            标准: ¥{record.drgPayment.toLocaleString()}
          </Text>
        </div>
      ),
    },
    {
      title: '超支/结余',
      key: 'balance',
      width: 140,
      align: 'right',
      render: (_, record) => (
        <div>
          <Text type={record.balanceAmount < 0 ? 'danger' : 'success'} strong>
            ¥{record.balanceAmount.toLocaleString()}
          </Text>
          <div>
            <Text type={record.balancePercent < 0 ? 'danger' : 'success'} style={{ fontSize: 12 }}>
              {record.balancePercent > 0 ? '+' : ''}{record.balancePercent}%
            </Text>
          </div>
        </div>
      ),
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
      title: '处理人',
      dataIndex: 'processUser',
      key: 'processUser',
      width: 100,
      render: (user: string) => user || '-',
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 100,
      render: (_, record) => (
        <Button
          type="link"
          size="small"
          icon={<EyeOutlined />}
          onClick={() => handleView(record)}
        >
          查看
        </Button>
      ),
    },
  ];

  return (
    <div style={{ padding: 16, height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* 统计卡片 */}
      <Row gutter={[16, 16]} style={{ marginBottom: 16 }}>
        <Col xs={24} sm={12} md={6}>
          <Card size="small">
            <Statistic
              title="总记录数"
              value={stats.total}
              prefix={<HistoryOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card size="small">
            <Statistic
              title="已处理"
              value={stats.processed}
              prefix={<CheckCircleOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card size="small">
            <Statistic
              title="已忽略"
              value={stats.ignored}
              prefix={<CloseCircleOutlined />}
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={6}>
          <Card size="small">
            <Statistic
              title="总超支金额"
              value={Math.abs(stats.totalBalance)}
              prefix={<ExclamationCircleOutlined />}
              suffix="元"
              valueStyle={{ color: stats.totalBalance < 0 ? '#ff4d4f' : '#52c41a' }}
            />
          </Card>
        </Col>
      </Row>

      {/* 主内容区 */}
      <Card
        title={
          <Space>
            <HistoryOutlined />
            <span>预警处理记录</span>
          </Space>
        }
        extra={
          <Space>
            <Button icon={<DownloadOutlined />} onClick={handleExport}>
              导出Excel
            </Button>
          </Space>
        }
        style={{ flex: 1, display: 'flex', flexDirection: 'column' }}
        bodyStyle={{ height: '100%', padding: '16px 24px' }}
      >
        {/* 筛选栏 */}
        <Row gutter={[16, 16]} style={{ marginBottom: 16 }}>
          <Col xs={24} sm={12} md={6} lg={4}>
            <Input
              placeholder="住院号/患者姓名"
              prefix={<SearchOutlined />}
              value={filterAdmissionNo}
              onChange={(e) => setFilterAdmissionNo(e.target.value)}
              allowClear
            />
          </Col>
          <Col xs={24} sm={12} md={6} lg={4}>
            <RangePicker style={{ width: '100%' }} placeholder={['开始日期', '结束日期']} />
          </Col>
          <Col xs={24} sm={12} md={6} lg={3}>
            <Select
              placeholder="处理状态"
              style={{ width: '100%' }}
              allowClear
              value={filterStatus || undefined}
              onChange={setFilterStatus}
            >
              <Option value="待处理">待处理</Option>
              <Option value="已处理">已处理</Option>
              <Option value="已忽略">已忽略</Option>
            </Select>
          </Col>
          <Col xs={24} sm={12} md={6} lg={3}>
            <Select
              placeholder="预警级别"
              style={{ width: '100%' }}
              allowClear
              value={filterLevel || undefined}
              onChange={setFilterLevel}
            >
              <Option value="1">提示</Option>
              <Option value="2">警告</Option>
              <Option value="3">严重</Option>
            </Select>
          </Col>
          <Col xs={24} sm={12} md={6} lg={3}>
            <Select
              placeholder="科室"
              style={{ width: '100%' }}
              allowClear
              value={filterDept || undefined}
              onChange={setFilterDept}
            >
              <Option value="心内科">心内科</Option>
              <Option value="骨科">骨科</Option>
              <Option value="普外科">普外科</Option>
              <Option value="神经内科">神经内科</Option>
            </Select>
          </Col>
          <Col xs={24} sm={12} md={6} lg={3}>
            <Select
              placeholder="规则类型"
              style={{ width: '100%' }}
              allowClear
              value={filterRuleType || undefined}
              onChange={setFilterRuleType}
            >
              <Option value="01">费用超支</Option>
              <Option value="02">低倍率</Option>
              <Option value="03">高倍率</Option>
              <Option value="04">编码异常</Option>
              <Option value="05">分解住院</Option>
            </Select>
          </Col>
          <Col xs={24} sm={12} md={12} lg={4}>
            <Space>
              <Button type="primary" icon={<SearchOutlined />}>查询</Button>
              <Button icon={<ReloadOutlined />} onClick={handleReset}>重置</Button>
            </Space>
          </Col>
        </Row>

        <Table
          columns={columns}
          dataSource={getFilteredData()}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1600, y: 'calc(100vh - 400px)' }}
          pagination={{
            pageSize: 10,
            showSizeChanger: true,
            showTotal: (total) => `共 ${total} 条记录`,
            locale: {
              items_per_page: '/页',
              jump_to: '跳至',
              page: '页',
            }
          }}
        />
      </Card>

      {/* 详情弹窗 */}
      <Modal
        title="预警处理详情"
        open={detailVisible}
        onCancel={() => setDetailVisible(false)}
        footer={[
          <Button key="close" onClick={() => setDetailVisible(false)}>
            关闭
          </Button>,
        ]}
        width={800}
      >
        {currentRecord && (
          <div>
            <Row gutter={[16, 16]}>
              <Col span={24} style={{ textAlign: 'center', marginBottom: 16 }}>
                <Badge
                  count={WARNING_LEVELS[currentRecord.warningLevel].text}
                  style={{
                    backgroundColor:
                      currentRecord.warningLevel === 3 ? '#ff4d4f' :
                      currentRecord.warningLevel === 2 ? '#faad14' : '#52c41a',
                    fontSize: 14,
                    padding: '0 12px',
                    height: 28,
                    lineHeight: '28px',
                  }}
                />
                <Title level={4} style={{ marginTop: 16, marginBottom: 0 }}>
                  {currentRecord.ruleName}
                </Title>
              </Col>
            </Row>

            <Descriptions title="患者信息" bordered column={3} size="small">
              <Descriptions.Item label="住院号">{currentRecord.admissionNo}</Descriptions.Item>
              <Descriptions.Item label="姓名">{currentRecord.patientName}</Descriptions.Item>
              <Descriptions.Item label="性别">{currentRecord.patientGender}</Descriptions.Item>
              <Descriptions.Item label="年龄">{currentRecord.patientAge}岁</Descriptions.Item>
              <Descriptions.Item label="入院日期">{currentRecord.admissionDate}</Descriptions.Item>
              <Descriptions.Item label="出院日期">{currentRecord.dischargeDate}</Descriptions.Item>
            </Descriptions>

            <Descriptions title="DRG信息" bordered column={3} size="small" style={{ marginTop: 16 }}>
              <Descriptions.Item label="DRG编码">{currentRecord.drgCode}</Descriptions.Item>
              <Descriptions.Item label="DRG名称" span={2}>{currentRecord.drgName}</Descriptions.Item>
              <Descriptions.Item label="科室">{currentRecord.deptName}</Descriptions.Item>
              <Descriptions.Item label="主管医生" span={2}>{currentRecord.doctorName}</Descriptions.Item>
            </Descriptions>

            <Descriptions title="费用信息" bordered column={3} size="small" style={{ marginTop: 16 }}>
              <Descriptions.Item label="费用总额">¥{currentRecord.totalCost.toLocaleString()}</Descriptions.Item>
              <Descriptions.Item label="DRG支付标准">¥{currentRecord.drgPayment.toLocaleString()}</Descriptions.Item>
              <Descriptions.Item label="超支/结余">
                <Text type={currentRecord.balanceAmount < 0 ? 'danger' : 'success'} strong>
                  ¥{currentRecord.balanceAmount.toLocaleString()} ({currentRecord.balancePercent}%)
                </Text>
              </Descriptions.Item>
            </Descriptions>

            <Descriptions title="预警信息" bordered column={2} size="small" style={{ marginTop: 16 }}>
              <Descriptions.Item label="规则类型">{RULE_TYPES[currentRecord.ruleType]}</Descriptions.Item>
              <Descriptions.Item label="预警级别">
                <Tag color={WARNING_LEVELS[currentRecord.warningLevel].tagColor}>
                  {WARNING_LEVELS[currentRecord.warningLevel].text}
                </Tag>
              </Descriptions.Item>
              <Descriptions.Item label="预警时间">{currentRecord.warningDate}</Descriptions.Item>
              <Descriptions.Item label="处理状态">
                <Tag color={PROCESS_STATUS[currentRecord.processStatus].color}>
                  {PROCESS_STATUS[currentRecord.processStatus].text}
                </Tag>
              </Descriptions.Item>
              {currentRecord.processUser && (
                <>
                  <Descriptions.Item label="处理人">{currentRecord.processUser}</Descriptions.Item>
                  <Descriptions.Item label="处理时间">{currentRecord.processDate}</Descriptions.Item>
                </>
              )}
              {currentRecord.processRemarks && (
                <Descriptions.Item label="处理备注" span={2}>
                  {currentRecord.processRemarks}
                </Descriptions.Item>
              )}
            </Descriptions>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default Records;
