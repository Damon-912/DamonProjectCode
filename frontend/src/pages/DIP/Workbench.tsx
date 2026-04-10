import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Input, Select, Space, Form, Row, Col,
  Tag, message, DatePicker, InputNumber, Descriptions, Divider,
  Modal, Tabs, Badge, Tooltip, Popconfirm
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, PlayCircleOutlined,
  MedicineBoxOutlined, DollarOutlined, FileSearchOutlined,
  DeleteOutlined, EyeOutlined, BarChartOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { Dayjs } from 'dayjs';
import dayjs from 'dayjs';
import {
  dipGroup, queryDIPGroupRecords, batchDIPGroup,
  type DIPGroupParams, type DIPGroupResult, type DIPGroupQueryParams
} from '../../api/dip';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;
const { TabPane } = Tabs;
const { RangePicker } = DatePicker;

const Workbench: React.FC = () => {
  const [activeTab, setActiveTab] = useState('group');
  
  // 分组工作台状态
  const [groupForm] = Form.useForm();
  const [grouping, setGrouping] = useState(false);
  const [groupResult, setGroupResult] = useState<DIPGroupResult | null>(null);
  
  // 分组记录查询状态
  const [records, setRecords] = useState<DIPGroupResult[]>([]);
  const [recordsTotal, setRecordsTotal] = useState(0);
  const [recordsLoading, setRecordsLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  
  // 查询条件
  const [queryParams, setQueryParams] = useState<DIPGroupQueryParams>(({}));
  const [selectedRecords, setSelectedRecords] = useState<string[]>([]);
  
  // 详情弹窗
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [detailRecord, setDetailRecord] = useState<DIPGroupResult | null>(null);

  // 查询分组记录
  const fetchRecords = useCallback(async (page = currentPage, size = pageSize) => {
    setRecordsLoading(true);
    try {
      const res = await queryDIPGroupRecords(queryParams, { pageSize: size, currentPage: page });
      if (res.errorCode === '0' && res.result) {
        setRecords(res.result.rows || []);
        setRecordsTotal(res.result.total || 0);
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setRecordsLoading(false);
    }
  }, [queryParams, currentPage, pageSize]);

  useEffect(() => {
    if (activeTab === 'records') {
      fetchRecords();
    }
  }, [activeTab, fetchRecords]);

  // 执行分组
  const handleGroup = async (values: any) => {
    setGrouping(true);
    try {
      const params: DIPGroupParams = {
        patientId: values.patientId,
        admissionNo: values.admissionNo,
        name: values.name,
        sex: values.sex,
        age: values.age,
        mainDiagnosisCode: values.mainDiagnosisCode,
        mainDiagnosisName: values.mainDiagnosisName,
        otherDiagnoses: values.otherDiagnoses?.filter((d: string) => d)?.map((code: string) => ({ code })),
        mainProcedureCode: values.mainProcedureCode,
        mainProcedureName: values.mainProcedureName,
        otherProcedures: values.otherProcedures?.filter((p: string) => p)?.map((code: string) => ({ code })),
        totalCost: values.totalCost,
        department: values.department,
        doctor: values.doctor,
        hospitalDays: values.hospitalDays,
      };

      const res = await dipGroup(params);
      if (res.errorCode === '0' && res.result) {
        setGroupResult(res.result);
        message.success('DIP分组成功');
      } else {
        message.error(res.errorMessage || '分组失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setGrouping(false);
    }
  };

  // 批量分组
  const handleBatchGroup = async () => {
    if (selectedRecords.length === 0) {
      message.warning('请选择要分组的记录');
      return;
    }
    
    Modal.confirm({
      title: '批量分组确认',
      content: `确定要对选中的 ${selectedRecords.length} 条记录进行DIP分组吗？`,
      onOk: async () => {
        try {
          const res = await batchDIPGroup({ admissionNos: selectedRecords });
          if (res.errorCode === '0' && res.result) {
            message.success(`批量分组完成：成功 ${res.result.successCount} 条，失败 ${res.result.failCount} 条`);
            fetchRecords();
          } else {
            message.error(res.errorMessage || '批量分组失败');
          }
        } catch {
          message.error('网络异常');
        }
      },
    });
  };

  // 查看详情
  const handleViewDetail = (record: DIPGroupResult) => {
    setDetailRecord(record);
    setDetailModalOpen(true);
  };

  // 表格列定义
  const columns: ColumnsType<DIPGroupResult> = [
    {
      title: '病案号',
      dataIndex: 'admissionNo',
      width: 120,
    },
    {
      title: '患者姓名',
      dataIndex: 'patientName',
      width: 100,
    },
    {
      title: 'DIP编码',
      dataIndex: 'dipCode',
      width: 100,
    },
    {
      title: 'DIP名称',
      dataIndex: 'dipName',
      width: 200,
      ellipsis: true,
    },
    {
      title: '分值',
      dataIndex: 'points',
      width: 80,
      align: 'right',
    },
    {
      title: '支付标准',
      dataIndex: 'paymentStandard',
      width: 100,
      align: 'right',
      render: (v: number) => `¥${(v || 0).toFixed(2)}`,
    },
    {
      title: '总费用',
      dataIndex: 'totalCost',
      width: 100,
      align: 'right',
      render: (v: number) => `¥${(v || 0).toFixed(2)}`,
    },
    {
      title: '盈亏',
      dataIndex: 'balance',
      width: 100,
      align: 'right',
      render: (v: number) => (
        <span style={{ color: v >= 0 ? '#52c41a' : '#ff4d4f' }}>
          {v >= 0 ? '+' : ''}¥{(v || 0).toFixed(2)}
        </span>
      ),
    },
    {
      title: '状态',
      dataIndex: 'statusDesc',
      width: 80,
      render: (v: string, record: DIPGroupResult) => (
        <Badge 
          status={record.status === '1' ? 'success' : record.status === '2' ? 'warning' : 'default'} 
          text={v} 
        />
      ),
    },
    {
      title: '分组时间',
      dataIndex: 'groupTime',
      width: 150,
    },
    {
      title: '操作',
      key: 'action',
      width: 100,
      fixed: 'right',
      render: (_, record) => (
        <Button type="link" size="small" icon={<EyeOutlined />} onClick={() => handleViewDetail(record)}>
          查看
        </Button>
      ),
    },
  ];

  return (
    <div style={{ padding: 16 }}>
      <Tabs activeKey={activeTab} onChange={setActiveTab}>
        <TabPane 
          tab={<span><PlayCircleOutlined />DIP分组</span>} 
          key="group"
        >
          <Row gutter={24}>
            <Col span={14}>
              <Card title="患者信息录入" size="small">
                <Form
                  form={groupForm}
                  layout="vertical"
                  onFinish={handleGroup}
                >
                  <Row gutter={16}>
                    <Col span={8}>
                      <Form.Item name="admissionNo" label="病案号">
                        <Input placeholder="请输入病案号" />
                      </Form.Item>
                    </Col>
                    <Col span={8}>
                      <Form.Item name="name" label="患者姓名">
                        <Input placeholder="请输入患者姓名" />
                      </Form.Item>
                    </Col>
                    <Col span={4}>
                      <Form.Item name="sex" label="性别">
                        <Select placeholder="请选择">
                          <Option value="1">男</Option>
                          <Option value="2">女</Option>
                        </Select>
                      </Form.Item>
                    </Col>
                    <Col span={4}>
                      <Form.Item name="age" label="年龄">
                        <InputNumber style={{ width: '100%' }} min={0} max={150} placeholder="岁" />
                      </Form.Item>
                    </Col>
                  </Row>

                  <Divider style={{ margin: '12px 0' }} />

                  <Row gutter={16}>
                    <Col span={12}>
                      <Form.Item 
                        name="mainDiagnosisCode" 
                        label="主要诊断编码"
                        rules={[{ required: true, message: '请输入主要诊断编码' }]}
                      >
                        <Input placeholder="ICD-10编码，如 I21.0" />
                      </Form.Item>
                    </Col>
                    <Col span={12}>
                      <Form.Item name="mainDiagnosisName" label="主要诊断名称">
                        <Input placeholder="诊断名称" />
                      </Form.Item>
                    </Col>
                  </Row>

                  <Row gutter={16}>
                    <Col span={12}>
                      <Form.Item name="mainProcedureCode" label="主要手术编码">
                        <Input placeholder="ICD-9-CM-3编码，如 36.07" />
                      </Form.Item>
                    </Col>
                    <Col span={12}>
                      <Form.Item name="mainProcedureName" label="主要手术名称">
                        <Input placeholder="手术名称" />
                      </Form.Item>
                    </Col>
                  </Row>

                  <Row gutter={16}>
                    <Col span={8}>
                      <Form.Item name="department" label="科室">
                        <Input placeholder="科室名称" />
                      </Form.Item>
                    </Col>
                    <Col span={8}>
                      <Form.Item name="doctor" label="医生">
                        <Input placeholder="医生姓名" />
                      </Form.Item>
                    </Col>
                    <Col span={8}>
                      <Form.Item name="hospitalDays" label="住院天数">
                        <InputNumber style={{ width: '100%' }} min={0} placeholder="天" />
                      </Form.Item>
                    </Col>
                  </Row>

                  <Row gutter={16}>
                    <Col span={8}>
                      <Form.Item name="totalCost" label="总费用">
                        <InputNumber 
                          style={{ width: '100%' }} 
                          min={0} 
                          precision={2} 
                          placeholder="元"
                          prefix="¥"
                        />
                      </Form.Item>
                    </Col>
                  </Row>

                  <Form.Item style={{ marginBottom: 0, marginTop: 16 }}>
                    <Space>
                      <Button 
                        type="primary" 
                        htmlType="submit" 
                        icon={<PlayCircleOutlined />}
                        loading={grouping}
                        size="large"
                      >
                        执行DIP分组
                      </Button>
                      <Button 
                        icon={<ReloadOutlined />}
                        onClick={() => {
                          groupForm.resetFields();
                          setGroupResult(null);
                        }}
                        size="large"
                      >
                        重置
                      </Button>
                    </Space>
                  </Form.Item>
                </Form>
              </Card>
            </Col>

            <Col span={10}>
              {groupResult ? (
                <Card 
                  title={<span><MedicineBoxOutlined /> 分组结果</span>} 
                  size="small"
                  extra={
                    <Tag color="blue" style={{ fontSize: 14, padding: '2px 8px' }}>
                      {groupResult.dipCode}
                    </Tag>
                  }
                >
                  <Descriptions bordered column={1} size="small">
                    <Descriptions.Item label="DIP名称">{groupResult.dipName}</Descriptions.Item>
                    <Descriptions.Item label="分值">{groupResult.points}</Descriptions.Item>
                    <Descriptions.Item label="支付标准">
                      ¥{(groupResult.paymentStandard || 0).toFixed(2)}
                    </Descriptions.Item>
                    <Descriptions.Item label="总费用">
                      ¥{(groupResult.totalCost || 0).toFixed(2)}
                    </Descriptions.Item>
                    <Descriptions.Item label="医保支付">
                      ¥{(groupResult.paymentAmount || 0).toFixed(2)}
                    </Descriptions.Item>
                    <Descriptions.Item label="盈亏">
                      <span style={{ 
                        color: (groupResult.balance || 0) >= 0 ? '#52c41a' : '#ff4d4f',
                        fontWeight: 'bold'
                      }}>
                        {(groupResult.balance || 0) >= 0 ? '+' : ''}¥{(groupResult.balance || 0).toFixed(2)}
                      </span>
                    </Descriptions.Item>
                    <Descriptions.Item label="分组时间">{groupResult.groupTime}</Descriptions.Item>
                  </Descriptions>
                </Card>
              ) : (
                <Card title="分组结果" size="small">
                  <div style={{ textAlign: 'center', padding: '40px 0', color: '#999' }}>
                    <MedicineBoxOutlined style={{ fontSize: 48, marginBottom: 16 }} />
                    <p>请输入患者信息后执行分组</p>
                  </div>
                </Card>
              )}
            </Col>
          </Row>
        </TabPane>

        <TabPane 
          tab={<span><FileSearchOutlined />分组记录</span>} 
          key="records"
        >
          <Card size="small" style={{ marginBottom: 16 }}>
            <Row gutter={16} align="middle">
              <Col>
                <Input
                  placeholder="病案号"
                  value={queryParams.admissionNo}
                  onChange={e => setQueryParams({ ...queryParams, admissionNo: e.target.value })}
                  style={{ width: 150 }}
                  allowClear
                />
              </Col>
              <Col>
                <Input
                  placeholder="患者姓名"
                  value={queryParams.patientName}
                  onChange={e => setQueryParams({ ...queryParams, patientName: e.target.value })}
                  style={{ width: 120 }}
                  allowClear
                />
              </Col>
              <Col>
                <Input
                  placeholder="DIP编码"
                  value={queryParams.dipCode}
                  onChange={e => setQueryParams({ ...queryParams, dipCode: e.target.value })}
                  style={{ width: 120 }}
                  allowClear
                />
              </Col>
              <Col>
                <Select
                  placeholder="状态"
                  value={queryParams.status}
                  onChange={v => setQueryParams({ ...queryParams, status: v })}
                  style={{ width: 100 }}
                  allowClear
                >
                  <Option value="">全部</Option>
                  <Option value="1">已分组</Option>
                  <Option value="2">分组中</Option>
                  <Option value="0">未分组</Option>
                </Select>
              </Col>
              <Col>
                <RangePicker
                  placeholder={['开始日期', '结束日期']}
                  onChange={(dates: [Dayjs | null, Dayjs | null] | null) => {
                    if (dates) {
                      setQueryParams({
                        ...queryParams,
                        startDate: dates[0]?.format('YYYY-MM-DD'),
                        endDate: dates[1]?.format('YYYY-MM-DD'),
                      });
                    } else {
                      setQueryParams({ ...queryParams, startDate: undefined, endDate: undefined });
                    }
                  }}
                />
              </Col>
              <Col>
                <Space>
                  <Button type="primary" icon={<SearchOutlined />} onClick={() => { setCurrentPage(1); fetchRecords(1); }}>
                    查询
                  </Button>
                  <Button icon={<ReloadOutlined />} onClick={() => { setQueryParams({}); setCurrentPage(1); }}>
                    重置
                  </Button>
                </Space>
              </Col>
            </Row>
          </Card>

          <Card size="small">
            <div style={{ marginBottom: 12 }}>
              <Space>
                <Button 
                  type="primary" 
                  icon={<PlayCircleOutlined />}
                  disabled={selectedRecords.length === 0}
                  onClick={handleBatchGroup}
                >
                  批量分组 ({selectedRecords.length})
                </Button>
                <span style={{ color: '#999' }}>共 {recordsTotal} 条记录</span>
              </Space>
            </div>
            <Table
              columns={columns}
              dataSource={records}
              rowKey="id"
              loading={recordsLoading}
              scroll={{ x: 1200 }}
              size="small"
              rowSelection={{
                selectedRowKeys: selectedRecords,
                onChange: (keys) => setSelectedRecords(keys as string[]),
              }}
              pagination={false}
            />
            <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
              <CustomPagination
                current={currentPage}
                pageSize={pageSize}
                total={recordsTotal}
                onChange={(page, size) => {
                  setCurrentPage(page);
                  setPageSize(size);
                  fetchRecords(page, size);
                }}
              />
            </div>
          </Card>
        </TabPane>
      </Tabs>

      {/* 详情弹窗 */}
      <Modal
        title="DIP分组详情"
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        width={700}
      >
        {detailRecord && (
          <Descriptions bordered column={2} size="small">
            <Descriptions.Item label="病案号" span={2}>{detailRecord.admissionNo}</Descriptions.Item>
            <Descriptions.Item label="患者姓名">{detailRecord.patientName}</Descriptions.Item>
            <Descriptions.Item label="DIP编码">{detailRecord.dipCode}</Descriptions.Item>
            <Descriptions.Item label="DIP名称" span={2}>{detailRecord.dipName}</Descriptions.Item>
            <Descriptions.Item label="分值">{detailRecord.points}</Descriptions.Item>
            <Descriptions.Item label="支付标准">¥{(detailRecord.paymentStandard || 0).toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="总费用">¥{(detailRecord.totalCost || 0).toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="药品费用">¥{(detailRecord.drugCost || 0).toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="材料费用">¥{(detailRecord.materialCost || 0).toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="服务费用">¥{(detailRecord.serviceCost || 0).toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="医保支付">¥{(detailRecord.paymentAmount || 0).toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="盈亏">
              <span style={{ color: (detailRecord.balance || 0) >= 0 ? '#52c41a' : '#ff4d4f', fontWeight: 'bold' }}>
                {(detailRecord.balance || 0) >= 0 ? '+' : ''}¥{(detailRecord.balance || 0).toFixed(2)}
              </span>
            </Descriptions.Item>
            <Descriptions.Item label="状态">{detailRecord.statusDesc}</Descriptions.Item>
            <Descriptions.Item label="分组时间">{detailRecord.groupTime}</Descriptions.Item>
          </Descriptions>
        )}
      </Modal>
    </div>
  );
};

export default Workbench;
