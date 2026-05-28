import React, { useState, useEffect } from 'react';
import { 
  Table, 
  Card, 
  Button, 
  Space, 
  Form, 
  Input, 
  Select, 
  DatePicker, 
  Tag, 
  Modal,
  Descriptions,
  message,
  Tabs,
  Statistic,
  Row,
  Col
} from 'antd';
import { 
  SearchOutlined, 
  ReloadOutlined, 
  EyeOutlined,
  CheckOutlined,
  CloseOutlined
} from '@ant-design/icons';
import type { RangePickerProps } from 'antd/es/date-picker';
import dayjs, { Dayjs } from 'dayjs';
import CustomPagination from '../../components/CustomPagination';
import { useDict } from '../../hooks/useDict';
import { getDictLabel } from '../../utils/dict';

const { RangePicker } = DatePicker;
const { Option } = Select;
const { TextArea } = Input;

// 结算状态颜色映射（UI展示用）
const SETTLEMENT_STATUS_COLORS: Record<string, string> = {
  pending: 'default',
  submitted: 'processing',
  settled: 'success',
  cancelled: 'default',
  rejected: 'error',
};

interface SettlementItem {
  key: string;
  settlementId: string;
  patientId: string;
  patientName: string;
  inpatientNo: string;
  admissionDate: string;
  dischargeDate: string;
  diagnosis: string;
  drgCode: string;
  drgName: string;
  dipCode: string;
  dipName: string;
  totalAmount: number;
  settlementAmount: number;
  actualPayment: number;
  status: 'pending' | 'submitted' | 'settled' | 'cancelled' | 'rejected';
  submitTime?: string;
  settleTime?: string;
  remark: string;
}

const HIS_SETTLEMENT_DATA: SettlementItem[] = [
  {
    key: '1',
    settlementId: 'ST2026033001',
    patientId: 'P20260301001',
    patientName: '张三',
    inpatientNo: 'IP20260315001',
    admissionDate: '2026-03-15',
    dischargeDate: '2026-03-20',
    diagnosis: '急性心肌梗死',
    drgCode: 'FM19',
    drgName: '心肌梗死',
    dipCode: 'BX1001',
    dipName: '急性心肌梗死',
    totalAmount: 25000,
    settlementAmount: 23000,
    actualPayment: 22000,
    status: 'settled',
    submitTime: '2026-03-21 10:30',
    settleTime: '2026-03-22 14:20',
    remark: ''
  },
  {
    key: '2',
    settlementId: 'ST2026033002',
    patientId: 'P20260301002',
    patientName: '李四',
    inpatientNo: 'IP20260318001',
    admissionDate: '2026-03-18',
    dischargeDate: '2026-03-25',
    diagnosis: '脑梗死',
    drgCode: 'BE25',
    drgName: '脑血管病',
    dipCode: 'BX2005',
    dipName: '脑梗死',
    totalAmount: 32000,
    settlementAmount: 30000,
    actualPayment: 29000,
    status: 'submitted',
    submitTime: '2026-03-26 09:15',
    remark: ''
  },
  {
    key: '3',
    settlementId: 'ST2026033003',
    patientId: 'P20260302001',
    patientName: '王五',
    inpatientNo: 'IP20260320001',
    admissionDate: '2026-03-20',
    dischargeDate: '2026-03-28',
    diagnosis: '肺炎',
    drgCode: 'ES15',
    drgName: '肺炎',
    dipCode: 'JS3001',
    dipName: '细菌性肺炎',
    totalAmount: 15000,
    settlementAmount: 14000,
    actualPayment: 0,
    status: 'pending',
    remark: ''
  }
];

const Settlement: React.FC = () => {
  // 字典数据
  const { map: settlementStatusMap, options: settlementStatusOptions } = useDict('SETTLEMENT_STATUS');

  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<SettlementItem[]>([]);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [selectedRowKeys, setSelectedRowKeys] = useState<React.Key[]>([]);
  
  const [detailModalVisible, setDetailModalVisible] = useState(false);
  const [currentRecord, setCurrentRecord] = useState<SettlementItem | null>(null);

  useEffect(() => {
    fetchData();
  }, [pagination.current, pagination.pageSize]);

  const fetchData = async () => {
    setLoading(true);
    try {
      // 模拟API调用
      await new Promise(resolve => setTimeout(resolve, 500));
      setData(HIS_SETTLEMENT_DATA);
      setPagination(prev => ({ ...prev, total: HIS_SETTLEMENT_DATA.length }));
    } catch (error) {
      message.error('获取结算清单数据失败');
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = async (values: any) => {
    setLoading(true);
    try {
      // 模拟API调用
      await new Promise(resolve => setTimeout(resolve, 500));
      setData(HIS_SETTLEMENT_DATA);
      setPagination(prev => ({ ...prev, current: 1 }));
      message.success('查询成功');
    } catch (error) {
      message.error('查询失败');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    form.resetFields();
    fetchData();
  };

  const handleBatchSubmit = async () => {
    if (selectedRowKeys.length === 0) {
      message.warning('请选择要提交的记录');
      return;
    }
    
    Modal.confirm({
      title: '确认提交',
      content: `确定要提交选中的 ${selectedRowKeys.length} 条结算清单吗？`,
      onOk: async () => {
        try {
          message.loading('提交中...', 0);
          await new Promise(resolve => setTimeout(resolve, 1000));
          message.destroy();
          message.success('提交成功');
          setSelectedRowKeys([]);
          fetchData();
        } catch (error) {
          message.error('提交失败');
        }
      }
    });
  };

  const handleBatchCancel = async () => {
    if (selectedRowKeys.length === 0) {
      message.warning('请选择要取消的记录');
      return;
    }
    
    Modal.confirm({
      title: '确认取消',
      content: `确定要取消选中的 ${selectedRowKeys.length} 条结算清单吗？`,
      onOk: async () => {
        try {
          message.loading('取消中...', 0);
          await new Promise(resolve => setTimeout(resolve, 1000));
          message.destroy();
          message.success('取消成功');
          setSelectedRowKeys([]);
          fetchData();
        } catch (error) {
          message.error('取消失败');
        }
      }
    });
  };

  const handleViewDetail = (record: SettlementItem) => {
    setCurrentRecord(record);
    setDetailModalVisible(true);
  };

  const handleSubmit = async (record: SettlementItem) => {
    Modal.confirm({
      title: '确认提交',
      content: `确定要提交结算清单 ${record.settlementId} 吗？`,
      onOk: async () => {
        try {
          message.loading('提交中...', 0);
          await new Promise(resolve => setTimeout(resolve, 1000));
          message.destroy();
          message.success('提交成功');
          fetchData();
        } catch (error) {
          message.error('提交失败');
        }
      }
    });
  };

  const handleCancel = async (record: SettlementItem) => {
    Modal.confirm({
      title: '确认取消',
      content: `确定要取消结算清单 ${record.settlementId} 吗？`,
      onOk: async () => {
        try {
          message.loading('取消中...', 0);
          await new Promise(resolve => setTimeout(resolve, 1000));
          message.destroy();
          message.success('取消成功');
          fetchData();
        } catch (error) {
          message.error('取消失败');
        }
      }
    });
  };

  const columns = [
    {
      title: '结算单号',
      dataIndex: 'settlementId',
      key: 'settlementId',
      width: 140,
      fixed: 'left' as const
    },
    {
      title: '住院号',
      dataIndex: 'inpatientNo',
      key: 'inpatientNo',
      width: 140
    },
    {
      title: '患者姓名',
      dataIndex: 'patientName',
      key: 'patientName',
      width: 100
    },
    {
      title: '入院日期',
      dataIndex: 'admissionDate',
      key: 'admissionDate',
      width: 120
    },
    {
      title: '出院日期',
      dataIndex: 'dischargeDate',
      key: 'dischargeDate',
      width: 120
    },
    {
      title: '主要诊断',
      dataIndex: 'diagnosis',
      key: 'diagnosis',
      width: 150,
      ellipsis: true
    },
    {
      title: 'DRG编码',
      dataIndex: 'drgCode',
      key: 'drgCode',
      width: 100
    },
    {
      title: 'DRG名称',
      dataIndex: 'drgName',
      key: 'drgName',
      width: 150,
      ellipsis: true
    },
    {
      title: 'DIP编码',
      dataIndex: 'dipCode',
      key: 'dipCode',
      width: 100
    },
    {
      title: 'DIP名称',
      dataIndex: 'dipName',
      key: 'dipName',
      width: 150,
      ellipsis: true
    },
    {
      title: '总费用',
      dataIndex: 'totalAmount',
      key: 'totalAmount',
      width: 100,
      render: (value: number) => `¥${value.toLocaleString()}`
    },
    {
      title: '结算金额',
      dataIndex: 'settlementAmount',
      key: 'settlementAmount',
      width: 100,
      render: (value: number) => `¥${value.toLocaleString()}`
    },
    {
      title: '实际支付',
      dataIndex: 'actualPayment',
      key: 'actualPayment',
      width: 100,
      render: (value: number) => `¥${value.toLocaleString()}`
    },
    {
      title: '状态',
      dataIndex: 'status',
      key: 'status',
      width: 100,
      fixed: 'right' as const,
      render: (status: string) => (
        <Tag color={SETTLEMENT_STATUS_COLORS[status] || 'default'}>
          {getDictLabel(settlementStatusMap, status)}
        </Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      width: 200,
      fixed: 'right' as const,
      render: (_: any, record: SettlementItem) => (
        <Space size="small">
          <Button
            type="link"
            size="small"
            icon={<EyeOutlined />}
            onClick={() => handleViewDetail(record)}
          >
            详情
          </Button>
          {record.status === 'pending' && (
            <Button
              type="link"
              size="small"
              icon={<CheckOutlined />}
              onClick={() => handleSubmit(record)}
            >
              提交
            </Button>
          )}
          {(record.status === 'pending' || record.status === 'submitted') && (
            <Button
              type="link"
              size="small"
              danger
              icon={<CloseOutlined />}
              onClick={() => handleCancel(record)}
            >
              取消
            </Button>
          )}
        </Space>
      )
    }
  ];

  const rowSelection = {
    selectedRowKeys,
    onChange: (newSelectedRowKeys: React.Key[]) => {
      setSelectedRowKeys(newSelectedRowKeys);
    },
    getCheckboxProps: (record: SettlementItem) => ({
      disabled: record.status === 'settled' || record.status === 'cancelled'
    })
  };

  return (
    <div style={{ padding: 24, background: '#f0f2f5', minHeight: '100%' }}>
      <Card>
        <Form
          form={form}
          layout="inline"
          onFinish={handleSearch}
          style={{ marginBottom: 16 }}
        >
          <Form.Item name="keyword" label="关键字">
            <Input placeholder="结算单号/住院号/患者姓名" style={{ width: 200 }} />
          </Form.Item>
          <Form.Item name="dateRange" label="出院日期">
            <RangePicker style={{ width: 240 }} />
          </Form.Item>
          <Form.Item name="status" label="状态">
            <Select placeholder="全部状态" style={{ width: 120 }} allowClear options={settlementStatusOptions} />
          </Form.Item>
          <Form.Item>
            <Space>
              <Button type="primary" htmlType="submit" icon={<SearchOutlined />}>
                查询
              </Button>
              <Button onClick={handleReset} icon={<ReloadOutlined />}>
                重置
              </Button>
            </Space>
          </Form.Item>
        </Form>

        <Row gutter={16} style={{ marginBottom: 16 }}>
          <Col span={6}>
            <Card size="small">
              <Statistic
                title="待提交"
                value={data.filter(d => d.status === 'pending').length}
                valueStyle={{ color: '#faad14' }}
              />
            </Card>
          </Col>
          <Col span={6}>
            <Card size="small">
              <Statistic
                title="已提交"
                value={data.filter(d => d.status === 'submitted').length}
                valueStyle={{ color: '#1890ff' }}
              />
            </Card>
          </Col>
          <Col span={6}>
            <Card size="small">
              <Statistic
                title="已结算"
                value={data.filter(d => d.status === 'settled').length}
                valueStyle={{ color: '#52c41a' }}
              />
            </Card>
          </Col>
          <Col span={6}>
            <Card size="small">
              <Statistic
                title="已驳回"
                value={data.filter(d => d.status === 'rejected').length}
                valueStyle={{ color: '#ff4d4f' }}
              />
            </Card>
          </Col>
        </Row>

        <Space style={{ marginBottom: 16 }}>
          <Button
            type="primary"
            icon={<CheckOutlined />}
            onClick={handleBatchSubmit}
            disabled={selectedRowKeys.length === 0}
          >
            批量提交
          </Button>
          <Button
            danger
            icon={<CloseOutlined />}
            onClick={handleBatchCancel}
            disabled={selectedRowKeys.length === 0}
          >
            批量取消
          </Button>
        </Space>

        <Table
          columns={columns}
          dataSource={data}
          loading={loading}
          rowSelection={rowSelection}
          scroll={{ x: 2000 }}
          pagination={false}
        />
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <CustomPagination
            current={pagination.current}
            pageSize={pagination.pageSize}
            total={pagination.total}
            onChange={(page, pageSize) => {
              setPagination({ current: page, pageSize: pageSize || 10, total: pagination.total });
            }}
          />
        </div>
      </Card>

      <Modal
        title="结算清单详情"
        open={detailModalVisible}
        onCancel={() => setDetailModalVisible(false)}
        footer={null}
        width={800}
      >
        {currentRecord && (
          <Tabs defaultActiveKey="basic">
            <Tabs.TabPane tab="基本信息" key="basic">
              <Descriptions column={2} bordered>
                <Descriptions.Item label="结算单号">{currentRecord.settlementId}</Descriptions.Item>
                <Descriptions.Item label="住院号">{currentRecord.inpatientNo}</Descriptions.Item>
                <Descriptions.Item label="患者姓名">{currentRecord.patientName}</Descriptions.Item>
                <Descriptions.Item label="患者ID">{currentRecord.patientId}</Descriptions.Item>
                <Descriptions.Item label="入院日期">{currentRecord.admissionDate}</Descriptions.Item>
                <Descriptions.Item label="出院日期">{currentRecord.dischargeDate}</Descriptions.Item>
                <Descriptions.Item label="主要诊断" span={2}>{currentRecord.diagnosis}</Descriptions.Item>
                <Descriptions.Item label="DRG编码">{currentRecord.drgCode}</Descriptions.Item>
                <Descriptions.Item label="DRG名称">{currentRecord.drgName}</Descriptions.Item>
                <Descriptions.Item label="DIP编码">{currentRecord.dipCode}</Descriptions.Item>
                <Descriptions.Item label="DIP名称">{currentRecord.dipName}</Descriptions.Item>
                <Descriptions.Item label="总费用">¥{currentRecord.totalAmount.toLocaleString()}</Descriptions.Item>
                <Descriptions.Item label="结算金额">¥{currentRecord.settlementAmount.toLocaleString()}</Descriptions.Item>
                <Descriptions.Item label="实际支付">¥{currentRecord.actualPayment.toLocaleString()}</Descriptions.Item>
                <Descriptions.Item label="状态">
                  <Tag color={SETTLEMENT_STATUS_COLORS[currentRecord.status]}>
                    {getDictLabel(settlementStatusMap, currentRecord.status)}
                  </Tag>
                </Descriptions.Item>
                <Descriptions.Item label="提交时间">{currentRecord.submitTime || '-'}</Descriptions.Item>
                <Descriptions.Item label="结算时间">{currentRecord.settleTime || '-'}</Descriptions.Item>
                <Descriptions.Item label="备注" span={2}>{currentRecord.remark || '-'}</Descriptions.Item>
              </Descriptions>
            </Tabs.TabPane>
            <Tabs.TabPane tab="费用明细" key="cost">
              <Table
                columns={[
                  { title: '费用类型', dataIndex: 'type', key: 'type' },
                  { title: '费用名称', dataIndex: 'name', key: 'name' },
                  { title: '金额', dataIndex: 'amount', key: 'amount', render: (v: number) => `¥${v.toLocaleString()}` }
                ]}
                dataSource={[
                  { key: '1', type: '药品费', name: '西药费', amount: 5000 },
                  { key: '2', type: '药品费', name: '中成药费', amount: 2000 },
                  { key: '3', type: '检查费', name: 'CT检查', amount: 3000 },
                  { key: '4', type: '治疗费', name: '治疗费', amount: 4000 },
                  { key: '5', type: '护理费', name: '护理费', amount: 2000 },
                  { key: '6', type: '床位费', name: '床位费', amount: 1500 },
                  { key: '7', type: '其他', name: '其他费用', amount: 2500 }
                ]}
                pagination={false}
                size="small"
                summary={(pageData) => {
                  let totalAmount = 0;
                  pageData.forEach(({ amount }) => {
                    totalAmount += amount;
                  });
                  return (
                    <Table.Summary.Row>
                      <Table.Summary.Cell index={0} colSpan={2}>
                        <strong>合计</strong>
                      </Table.Summary.Cell>
                      <Table.Summary.Cell index={2}>
                        <strong>¥{totalAmount.toLocaleString()}</strong>
                      </Table.Summary.Cell>
                    </Table.Summary.Row>
                  );
                }}
              />
            </Tabs.TabPane>
          </Tabs>
        )}
      </Modal>
    </div>
  );
};

export default Settlement;
