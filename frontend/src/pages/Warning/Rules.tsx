import React, { useState, useEffect } from 'react';
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
  ReloadOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { queryWarningRules, saveWarningRule, deleteWarningRule } from '@/api/warning';
import type { WarningRule } from '@/api/warning';

const { Title, Text } = Typography;
const { Option } = Select;
const { TextArea } = Input;

// 规则类型
const RULE_TYPES: Record<string, string> = {
  '01': '费用超支',
  '02': '低倍率',
  '03': '高倍率',
  '04': '编码异常',
  '05': '分解住院',
};

// 预警级别
const WARNING_LEVELS: Record<number, { text: string; color: string }> = {
  1: { text: '提示', color: 'success' },
  2: { text: '警告', color: 'warning' },
  3: { text: '严重', color: 'error' },
};

const Rules: React.FC = () => {
  const [data, setData] = useState<WarningRule[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [modalTitle, setModalTitle] = useState('新增规则');
  const [editingRecord, setEditingRecord] = useState<WarningRule | null>(null);
  const [form] = Form.useForm();
  const [previewVisible, setPreviewVisible] = useState(false);
  const [previewRule, setPreviewRule] = useState<WarningRule | null>(null);
  const [searchForm] = Form.useForm();
  const [saving, setSaving] = useState(false);

  // 查询预警规则列表
  const fetchRules = async () => {
    setLoading(true);
    try {
      const values = searchForm.getFieldsValue();
      const res: any = await queryWarningRules(
        {
          ruleCode: values.ruleCode || '',
          ruleName: values.ruleName || '',
          ruleType: values.ruleType || '',
          isActive: values.isActive || '',
        },
        {
          pageSize: 100,
          currentPage: 1,
        }
      );
      
      if (res.errorCode === '0') {
        // 转换后端数据格式
        const list = (res.result.rows || []).map((item: any) => ({
          id: item.id,
          ruleCode: item.ruleCode,
          ruleName: item.ruleName,
          ruleDesc: item.ruleDesc,
          ruleType: item.ruleType,
          thresholdType: item.thresholdType,
          thresholdValue: item.thresholdValue,
          mdcCode: item.mdcCode,
          adrgCode: item.adrgCode,
          drgCode: item.drgCode,
          warningLevel: item.warningLevel || 1,
          isActive: item.isActive === 'Y' || item.isActive === '1',
          seqNo: item.seqNo,
          createDate: item.createDate,
          createTime: item.createTime,
          remark: item.remark,
        }));
        setData(list);
        setTotal(res.result.total || 0);
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch (error) {
      console.error('查询预警规则失败:', error);
      message.error('查询失败，请检查网络连接');
    } finally {
      setLoading(false);
    }
  };

  // 页面加载时查询数据
  useEffect(() => {
    fetchRules();
  }, []);

  // 搜索
  const handleSearch = () => {
    fetchRules();
  };

  // 重置搜索
  const handleReset = () => {
    searchForm.resetFields();
    fetchRules();
  };

  // 打开新增弹窗
  const handleAdd = () => {
    setEditingRecord(null);
    setModalTitle('新增预警规则');
    form.resetFields();
    form.setFieldsValue({
      isActive: true,
      warningLevel: 2,
      thresholdValue: 20,
      thresholdType: '01',
    });
    setModalVisible(true);
  };

  // 打开编辑弹窗
  const handleEdit = (record: WarningRule) => {
    setEditingRecord(record);
    setModalTitle('编辑预警规则');
    form.setFieldsValue({
      ruleCode: record.ruleCode,
      ruleName: record.ruleName,
      ruleDesc: record.ruleDesc,
      ruleType: record.ruleType,
      thresholdType: record.thresholdType || '01',
      thresholdValue: record.thresholdValue,
      mdcCode: record.mdcCode,
      adrgCode: record.adrgCode,
      drgCode: record.drgCode,
      warningLevel: record.warningLevel,
      isActive: record.isActive,
      seqNo: record.seqNo || 0,
      remark: record.remark,
    });
    setModalVisible(true);
  };

  // 删除规则
  const handleDelete = async (id: string) => {
    try {
      const res: any = await deleteWarningRule(id);
      if (res.errorCode === '0') {
        message.success('删除成功');
        fetchRules();
      } else {
        message.error(res.errorMessage || '删除失败');
      }
    } catch (error) {
      console.error('删除预警规则失败:', error);
      message.error('删除失败，请检查网络连接');
    }
  };

  // 切换启用状态
  const handleToggleEnable = async (record: WarningRule) => {
    try {
      const newStatus = !record.isActive;
      const res: any = await saveWarningRule({
        ruleId: record.id,
        ruleCode: record.ruleCode,
        ruleName: record.ruleName,
        ruleDesc: record.ruleDesc,
        ruleType: record.ruleType,
        thresholdType: record.thresholdType || '01',
        thresholdValue: record.thresholdValue,
        mdcCode: record.mdcCode,
        adrgCode: record.adrgCode,
        drgCode: record.drgCode,
        warningLevel: record.warningLevel,
        isActive: newStatus ? 'Y' : 'N',
        seqNo: record.seqNo,
        remark: record.remark,
      });
      if (res.errorCode === '0') {
        message.success(`${newStatus ? '启用' : '禁用'}成功`);
        fetchRules();
      } else {
        message.error(res.errorMessage || '操作失败');
      }
    } catch (error) {
      console.error('切换启用状态失败:', error);
      message.error('操作失败，请检查网络连接');
    }
  };

  // 保存规则
  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      setSaving(true);
      
      const ruleData = {
        ruleId: editingRecord?.id || '',
        ruleCode: values.ruleCode,
        ruleName: values.ruleName,
        ruleDesc: values.ruleDesc || '',
        ruleType: values.ruleType,
        thresholdType: values.thresholdType || '01',
        thresholdValue: values.thresholdValue || 0,
        mdcCode: values.mdcCode || '',
        adrgCode: values.adrgCode || '',
        drgCode: values.drgCode || '',
        warningLevel: values.warningLevel,
        isActive: values.isActive ? 'Y' : 'N',
        seqNo: values.seqNo || 0,
        remark: values.remark || '',
      };
      
      const res: any = await saveWarningRule(ruleData);
      
      if (res.errorCode === '0') {
        message.success(editingRecord ? '修改成功' : '新增成功');
        setModalVisible(false);
        fetchRules();
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch (error: any) {
      console.error('保存预警规则失败:', error);
      if (error.errorFields) {
        message.error('请检查必填项');
      } else {
        message.error(error.message || '保存失败');
      }
    } finally {
      setSaving(false);
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
      render: (type: string) => RULE_TYPES[type] || type,
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
      dataIndex: 'thresholdValue',
      key: 'thresholdValue',
      width: 100,
      align: 'center',
    },
    {
      title: '预警级别',
      dataIndex: 'warningLevel',
      key: 'warningLevel',
      width: 100,
      render: (level: number) => (
        <Tag color={WARNING_LEVELS[level]?.color || 'default'}>
          {WARNING_LEVELS[level]?.text || '未知'}
        </Tag>
      ),
    },
    {
      title: '状态',
      dataIndex: 'isActive',
      key: 'isActive',
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
      dataIndex: 'createUserDr',
      key: 'createUserDr',
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
      {/* 搜索表单 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Form form={searchForm} layout="inline">
          <Form.Item name="ruleCode" label="规则编码">
            <Input placeholder="请输入规则编码" style={{ width: 150 }} />
          </Form.Item>
          <Form.Item name="ruleName" label="规则名称">
            <Input placeholder="请输入规则名称" style={{ width: 150 }} />
          </Form.Item>
          <Form.Item name="ruleType" label="规则类型">
            <Select placeholder="请选择" style={{ width: 120 }} allowClear>
              <Option value="01">费用超支</Option>
              <Option value="02">低倍率</Option>
              <Option value="03">高倍率</Option>
              <Option value="04">编码异常</Option>
              <Option value="05">分解住院</Option>
            </Select>
          </Form.Item>
          <Form.Item name="isActive" label="状态">
            <Select placeholder="请选择" style={{ width: 100 }} allowClear>
              <Option value="Y">启用</Option>
              <Option value="N">禁用</Option>
            </Select>
          </Form.Item>
          <Form.Item>
            <Space>
              <Button type="primary" onClick={handleSearch}>
                查询
              </Button>
              <Button onClick={handleReset}>重置</Button>
              <Button icon={<ReloadOutlined />} onClick={fetchRules}>
                刷新
              </Button>
            </Space>
          </Form.Item>
        </Form>
      </Card>

      {/* 数据表格 */}
      <Card
        title={
          <Space>
            <BellOutlined />
            <span>预警规则配置</span>
            <Text type="secondary">（共 {total} 条）</Text>
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
          scroll={{ x: 1400, y: 'calc(100vh - 380px)' }}
          pagination={{
            total: total,
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
        confirmLoading={saving}
      >
        <Form form={form} layout="vertical">
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                label="规则编码"
                name="ruleCode"
                rules={[{ required: true, message: '请输入规则编码' }]}
              >
                <Input placeholder="如：WR001" disabled={!!editingRecord} />
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

          <Form.Item
            label="规则描述"
            name="ruleDesc"
          >
            <Input.TextArea rows={2} placeholder="请输入规则描述" />
          </Form.Item>

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
                label="阈值类型"
                name="thresholdType"
              >
                <Select placeholder="请选择阈值类型">
                  <Option value="01">百分比</Option>
                  <Option value="02">固定值</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                label="阈值"
                name="thresholdValue"
                rules={[{ required: true, message: '请输入阈值' }]}
                tooltip="百分比类型表示费用偏差比例，固定值类型表示费用偏差金额"
              >
                <InputNumber
                  min={0}
                  style={{ width: '100%' }}
                />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                label="排序号"
                name="seqNo"
              >
                <InputNumber min={0} style={{ width: '100%' }} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                label="是否启用"
                name="isActive"
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

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                label="MDC编码"
                name="mdcCode"
                tooltip="为空表示适用全部MDC"
              >
                <Input placeholder="为空表示全部" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                label="ADRG编码"
                name="adrgCode"
                tooltip="为空表示适用全部ADRG"
              >
                <Input placeholder="为空表示全部" />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item
            label="备注"
            name="remark"
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
                    color: WARNING_LEVELS[previewRule.warningLevel]?.color === 'error' ? '#ff4d4f' :
                           WARNING_LEVELS[previewRule.warningLevel]?.color === 'warning' ? '#faad14' : '#52c41a',
                  }}
                />
                <Title level={4} style={{ marginTop: 16, marginBottom: 0 }}>
                  {previewRule.ruleName}
                </Title>
                <Tag
                  color={WARNING_LEVELS[previewRule.warningLevel]?.color}
                  style={{ marginTop: 8 }}
                >
                  {WARNING_LEVELS[previewRule.warningLevel]?.text}级别
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
                <Text type="danger" strong>{previewRule.thresholdValue}%</Text>
              </Col>
              <Col span={12}>
                <Text strong>当前状态：</Text>
                <Tag color={previewRule.isActive ? 'success' : 'default'}>
                  {previewRule.isActive ? '已启用' : '已禁用'}
                </Tag>
              </Col>
              {previewRule.remark && (
                <Col span={24}>
                  <Text strong>备注说明：</Text>
                  <div style={{ marginTop: 8, padding: 12, background: '#f5f5f5', borderRadius: 4 }}>
                    {previewRule.remark}
                  </div>
                </Col>
              )}
              <Col span={24} style={{ marginTop: 16 }}>
                <Alert
                  message="预警示例"
                  description={`当病例费用${previewRule.ruleType === '02' ? '低于' : '超过'}DRG支付标准的${previewRule.thresholdValue}%时，将触发此预警规则`}
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
