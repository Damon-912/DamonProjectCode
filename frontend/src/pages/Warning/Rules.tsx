import React, { useState } from 'react';
import {
  Card,
  Table,
  Button,
  Space,
  Tag,
  Modal,
  Form,
  Input,
  Select,
  InputNumber,
  Switch,
  Popconfirm,
  message,
  Row,
  Col,
  Divider,
  Typography,
  Tooltip,
  Alert,
} from 'antd';
import {
  PlusOutlined,
  EditOutlined,
  DeleteOutlined,
  EyeOutlined,
  ExclamationCircleOutlined,
  BellOutlined,
  QuestionCircleOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';

const { Title, Text } = Typography;
const { Option } = Select;
const { TextArea } = Input;

// 规则类型
const RULE_TYPES = {
  '01': '费用超支',
  '02': '低倍率',
  '03': '高倍率',
  '04': '编码异常',
  '05': '分解住院',
};

// 预警级别
const WARNING_LEVELS = {
  1: { text: '提示', color: 'success' },
  2: { text: '警告', color: 'warning' },
  3: { text: '严重', color: 'error' },
};

interface WarningRule {
  id: string;
  ruleCode: string;
  ruleName: string;
  ruleType: string;
  drgCode: string;
  deptCode: string;
  thresholdPercent: number;
  warningLevel: 1 | 2 | 3;
  isEnabled: boolean;
  remarks: string;
  createUser: string;
  createDate: string;
}

// 模拟数据
const mockRules: WarningRule[] = [
  {
    id: '1',
    ruleCode: 'WR001',
    ruleName: '费用超支预警（严重）',
    ruleType: '01',
    drgCode: '',
    deptCode: '',
    thresholdPercent: 30,
    warningLevel: 3,
    isEnabled: true,
    remarks: '费用超过DRG支付标准30%触发严重预警',
    createUser: '管理员',
    createDate: '2026-03-01',
  },
  {
    id: '2',
    ruleCode: 'WR002',
    ruleName: '费用超支预警（警告）',
    ruleType: '01',
    drgCode: '',
    deptCode: '',
    thresholdPercent: 20,
    warningLevel: 2,
    isEnabled: true,
    remarks: '费用超过DRG支付标准20%触发警告',
    createUser: '管理员',
    createDate: '2026-03-01',
  },
  {
    id: '3',
    ruleCode: 'WR003',
    ruleName: '高倍率预警',
    ruleType: '03',
    drgCode: '',
    deptCode: '',
    thresholdPercent: 25,
    warningLevel: 2,
    isEnabled: true,
    remarks: '费用高于DRG支付标准25%判定为高倍率',
    createUser: '管理员',
    createDate: '2026-03-02',
  },
  {
    id: '4',
    ruleCode: 'WR004',
    ruleName: '低倍率预警',
    ruleType: '02',
    drgCode: '',
    deptCode: '',
    thresholdPercent: 40,
    warningLevel: 1,
    isEnabled: true,
    remarks: '费用低于DRG支付标准40%判定为低倍率',
    createUser: '管理员',
    createDate: '2026-03-02',
  },
  {
    id: '5',
    ruleCode: 'WR005',
    ruleName: '编码异常预警',
    ruleType: '04',
    drgCode: '',
    deptCode: '',
    thresholdPercent: 0,
    warningLevel: 2,
    isEnabled: false,
    remarks: '诊断/手术编码存在逻辑异常时触发',
    createUser: '管理员',
    createDate: '2026-03-03',
  },
  {
    id: '6',
    ruleCode: 'WR006',
    ruleName: '心内科专项预警',
    ruleType: '01',
    drgCode: '',
    deptCode: '心内科',
    thresholdPercent: 15,
    warningLevel: 2,
    isEnabled: true,
    remarks: '心内科专项费用预警规则',
    createUser: '管理员',
    createDate: '2026-03-05',
  },
];

const Rules: React.FC = () => {
  const [data, setData] = useState<WarningRule[]>(mockRules);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [modalTitle, setModalTitle] = useState('新增规则');
  const [editingRecord, setEditingRecord] = useState<WarningRule | null>(null);
  const [form] = Form.useForm();
  const [previewVisible, setPreviewVisible] = useState(false);
  const [previewRule, setPreviewRule] = useState<WarningRule | null>(null);

  // 打开新增弹窗
  const handleAdd = () => {
    setEditingRecord(null);
    setModalTitle('新增预警规则');
    form.resetFields();
    form.setFieldsValue({
      isEnabled: true,
      warningLevel: 2,
      thresholdPercent: 20,
    });
    setModalVisible(true);
  };

  // 打开编辑弹窗
  const handleEdit = (record: WarningRule) => {
    setEditingRecord(record);
    setModalTitle('编辑预警规则');
    form.setFieldsValue(record);
    setModalVisible(true);
  };

  // 删除规则
  const handleDelete = (id: string) => {
    const newData = data.filter(item => item.id !== id);
    setData(newData);
    message.success('删除成功');
  };

  // 切换启用状态
  const handleToggleEnable = (record: WarningRule) => {
    const newData = data.map(item => {
      if (item.id === record.id) {
        return { ...item, isEnabled: !item.isEnabled };
      }
      return item;
    });
    setData(newData);
    message.success(`${record.isEnabled ? '禁用' : '启用'}成功`);
  };

  // 保存规则
  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      
      if (editingRecord) {
        // 编辑
        const newData = data.map(item => {
          if (item.id === editingRecord.id) {
            return { ...item, ...values };
          }
          return item;
        });
        setData(newData);
        message.success('修改成功');
      } else {
        // 新增
        const newRule: WarningRule = {
          ...values,
          id: Date.now().toString(),
          createUser: '当前用户',
          createDate: new Date().toISOString().split('T')[0],
        };
        setData([newRule, ...data]);
        message.success('新增成功');
      }
      setModalVisible(false);
    } catch (error) {
      console.error(error);
    }
  };

  // 预览规则
  const handlePreview = (record: WarningRule) => {
    setPreviewRule(record);
    setPreviewVisible(true);
  };

  const columns: ColumnsType<WarningRule> = [
    {
      title: '规则编码',
      dataIndex: 'ruleCode',
      key: 'ruleCode',
      width: 120,
    },
    {
      title: '规则名称',
      dataIndex: 'ruleName',
      key: 'ruleName',
      width: 200,
    },
    {
      title: '规则类型',
      dataIndex: 'ruleType',
      key: 'ruleType',
      width: 120,
      render: (type: string) => RULE_TYPES[type],
    },
    {
      title: '适用DRG',
      dataIndex: 'drgCode',
      key: 'drgCode',
      width: 120,
      render: (code: string) => code || <Text type="secondary">全部</Text>,
    },
    {
      title: '适用科室',
      dataIndex: 'deptCode',
      key: 'deptCode',
      width: 120,
      render: (code: string) => code || <Text type="secondary">全部</Text>,
    },
    {
      title: '阈值(%)',
      dataIndex: 'thresholdPercent',
      key: 'thresholdPercent',
      width: 100,
      align: 'center',
    },
    {
      title: '预警级别',
      dataIndex: 'warningLevel',
      key: 'warningLevel',
      width: 100,
      render: (level: 1 | 2 | 3) => (
        <Tag color={WARNING_LEVELS[level].color}>
          {WARNING_LEVELS[level].text}
        </Tag>
      ),
    },
    {
      title: '状态',
      dataIndex: 'isEnabled',
      key: 'isEnabled',
      width: 100,
      render: (enabled: boolean, record) => (
        <Switch
          checked={enabled}
          onChange={() => handleToggleEnable(record)}
          checkedChildren="启用"
          unCheckedChildren="禁用"
        />
      ),
    },
    {
      title: '创建人',
      dataIndex: 'createUser',
      key: 'createUser',
      width: 100,
    },
    {
      title: '创建日期',
      dataIndex: 'createDate',
      key: 'createDate',
      width: 120,
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
            onClick={() => handlePreview(record)}
          >
            预览
          </Button>
          <Button
            type="link"
            size="small"
            icon={<EditOutlined />}
            onClick={() => handleEdit(record)}
          >
            编辑
          </Button>
          <Popconfirm
            title="确认删除"
            description="删除后不可恢复，是否继续？"
            onConfirm={() => handleDelete(record.id)}
            okText="确认"
            cancelText="取消"
          >
            <Button
              type="link"
              size="small"
              danger
              icon={<DeleteOutlined />}
            >
              删除
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: 16, height: '100%', display: 'flex', flexDirection: 'column' }}>
      <Card
        title={
          <Space>
            <BellOutlined />
            <span>预警规则配置</span>
          </Space>
        }
        extra={
          <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
            新增规则
          </Button>
        }
        style={{ flex: 1, display: 'flex', flexDirection: 'column' }}
        bodyStyle={{ height: '100%', padding: '16px 24px' }}
      >
        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1400, y: 'calc(100vh - 280px)' }}
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

      {/* 新增/编辑弹窗 */}
      <Modal
        title={modalTitle}
        open={modalVisible}
        onOk={handleSave}
        onCancel={() => setModalVisible(false)}
        width={700}
      >
        <Form form={form} layout="vertical">
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                label="规则编码"
                name="ruleCode"
                rules={[{ required: true, message: '请输入规则编码' }]}
              >
                <Input placeholder="如：WR001" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                label="规则名称"
                name="ruleName"
                rules={[{ required: true, message: '请输入规则名称' }]}
              >
                <Input placeholder="请输入规则名称" />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                label="规则类型"
                name="ruleType"
                rules={[{ required: true, message: '请选择规则类型' }]}
              >
                <Select placeholder="请选择规则类型">
                  <Option value="01">费用超支</Option>
                  <Option value="02">低倍率</Option>
                  <Option value="03">高倍率</Option>
                  <Option value="04">编码异常</Option>
                  <Option value="05">分解住院</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                label="预警级别"
                name="warningLevel"
                rules={[{ required: true, message: '请选择预警级别' }]}
              >
                <Select placeholder="请选择预警级别">
                  <Option value={1}>提示</Option>
                  <Option value={2}>警告</Option>
                  <Option value={3}>严重</Option>
                </Select>
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                label="阈值百分比"
                name="thresholdPercent"
                rules={[{ required: true, message: '请输入阈值' }]}
                tooltip="费用偏差达到此比例时触发预警"
              >
                <InputNumber
                  min={0}
                  max={100}
                  formatter={(value) => `${value}%`}
                  parser={(value) => value?.replace('%', '') as any}
                  style={{ width: '100%' }}
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                label="是否启用"
                name="isEnabled"
                valuePropName="checked"
              >
                <Switch checkedChildren="启用" unCheckedChildren="禁用" />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                label="适用DRG编码"
                name="drgCode"
                tooltip="为空表示适用全部DRG组"
              >
                <Input placeholder="多个编码用逗号分隔，为空表示全部" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                label="适用科室"
                name="deptCode"
                tooltip="为空表示适用全部科室"
              >
                <Input placeholder="多个科室用逗号分隔，为空表示全部" />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item
            label="备注"
            name="remarks"
          >
            <TextArea rows={3} placeholder="请输入备注说明" />
          </Form.Item>
        </Form>
      </Modal>

      {/* 预览弹窗 */}
      <Modal
        title="规则预览"
        open={previewVisible}
        onCancel={() => setPreviewVisible(false)}
        footer={[
          <Button key="close" onClick={() => setPreviewVisible(false)}>
            关闭
          </Button>,
        ]}
        width={550}
      >
        {previewRule && (
          <div style={{ padding: '8px 0' }}>
            <Row gutter={[16, 16]}>
              <Col span={24} style={{ textAlign: 'center', marginBottom: 16 }}>
                <ExclamationCircleOutlined
                  style={{
                    fontSize: 48,
                    color: WARNING_LEVELS[previewRule.warningLevel].color === 'error' ? '#ff4d4f' :
                           WARNING_LEVELS[previewRule.warningLevel].color === 'warning' ? '#faad14' : '#52c41a',
                  }}
                />
                <Title level={4} style={{ marginTop: 16, marginBottom: 0 }}>
                  {previewRule.ruleName}
                </Title>
                <Tag
                  color={WARNING_LEVELS[previewRule.warningLevel].color}
                  style={{ marginTop: 8 }}
                >
                  {WARNING_LEVELS[previewRule.warningLevel].text}级别
                </Tag>
              </Col>
              <Col span={24}>
                <Divider style={{ margin: '12px 0' }} />
              </Col>
              <Col span={12}><Text strong>规则编码：</Text>{previewRule.ruleCode}</Col>
              <Col span={12}><Text strong>规则类型：</Text>{RULE_TYPES[previewRule.ruleType]}</Col>
              <Col span={12}>
                <Text strong>适用DRG：</Text>
                {previewRule.drgCode || <Text type="secondary">全部DRG组</Text>}
              </Col>
              <Col span={12}>
                <Text strong>适用科室：</Text>
                {previewRule.deptCode || <Text type="secondary">全部科室</Text>}
              </Col>
              <Col span={12}>
                <Text strong>触发阈值：</Text>
                <Text type="danger" strong>{previewRule.thresholdPercent}%</Text>
              </Col>
              <Col span={12}>
                <Text strong>当前状态：</Text>
                <Tag color={previewRule.isEnabled ? 'success' : 'default'}>
                  {previewRule.isEnabled ? '已启用' : '已禁用'}
                </Tag>
              </Col>
              {previewRule.remarks && (
                <Col span={24}>
                  <Text strong>备注说明：</Text>
                  <div style={{ marginTop: 8, padding: 12, background: '#f5f5f5', borderRadius: 4 }}>
                    {previewRule.remarks}
                  </div>
                </Col>
              )}
              <Col span={24} style={{ marginTop: 16 }}>
                <Alert
                  message="预警示例"
                  description={`当病例费用${previewRule.ruleType === '02' ? '低于' : '超过'}DRG支付标准的${previewRule.thresholdPercent}%时，将触发此预警规则`}
                  type="info"
                  showIcon
                />
              </Col>
            </Row>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default Rules;
