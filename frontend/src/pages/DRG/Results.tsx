import React, { useState, useEffect } from 'react';
import { Card, Form, Input, Button, Table, Tag, Row, Col, Typography, Collapse, Space, DatePicker, Select, message, Statistic, Modal, Descriptions } from 'antd';
import { SearchOutlined, ReloadOutlined, EyeOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import request from '@/api/request';

const { Title, Text } = Typography;
const { RangePicker } = DatePicker;
const { Option } = Select;

/**
 * 分组结果查询页面
 */
interface ResultRecord {
  id: number;
  patientId: string;
  patientName: string;
  inpatientId: string;
  admitDate: string;
  dischargeDate: string;
  mainDiagnosis: string;
  mainDiagnosisName: string;
  drgCode: string;
  drgName: string;
  mdcCode: string;
  mdcName: string;
  totalCost: number;
  benchmarkCost: number;
  riskLevel: string;
  hospAlgorithmInfo?: Array<{
    hisHospCode: string;
    hospCode: string;
    hospName: string;
    drg: string;
    drgDesc: string;
    points: string | number;
    pipValue: string | number;
    dgdov: string | number;
    payStandard: string | number;
    totalAmt?: string | number;
    preProfit?: string | number;
    preLoss?: string | number;
    discrepancyRate?: string | number;
  }>;
}

const Results: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<ResultRecord[]>([]);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [selectedRecord, setSelectedRecord] = useState<ResultRecord | null>(null);
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [form] = Form.useForm();

  // 模拟数据
  const mockData: ResultRecord[] = [
    {
      id: 1,
      patientId: 'P2024010001',
      patientName: '张三',
      inpatientId: 'ZY2024010001',
      admitDate: '2024-01-15',
      dischargeDate: '2024-01-22',
      mainDiagnosis: 'J18.900',
      mainDiagnosisName: '肺炎',
      drgCode: 'ES23',
      drgName: '呼吸系统肿瘤',
      mdcCode: 'MDCE',
      mdcName: '呼吸系统疾病及功能障碍',
      totalCost: 12500,
      benchmarkCost: 10800,
      riskLevel: '中',
      hospAlgorithmInfo: [
        {
          hisHospCode: 'H001',
          hospCode: 'H001',
          hospName: '测试医院',
          drg: 'ES23',
          drgDesc: '呼吸系统肿瘤',
          points: 45,
          pipValue: 240,
          dgdov: 1.0,
          payStandard: 10800,
          totalAmt: 12500,
          preProfit: 0,
          preLoss: 1700,
          discrepancyRate: -15.7
        }
      ]
    },
    {
      id: 2,
      patientId: 'P2024010002',
      patientName: '李四',
      inpatientId: 'ZY2024010002',
      admitDate: '2024-01-18',
      dischargeDate: '2024-01-25',
      mainDiagnosis: 'I21.000',
      mainDiagnosisName: '急性前壁心肌梗死',
      drgCode: 'FM23',
      drgName: '心脏介入治疗',
      mdcCode: 'MDCF',
      mdcName: '循环系统疾病及功能障碍',
      totalCost: 28500,
      benchmarkCost: 32000,
      riskLevel: '高',
      hospAlgorithmInfo: [
        {
          hisHospCode: 'H001',
          hospCode: 'H001',
          hospName: '测试医院',
          drg: 'FM23',
          drgDesc: '心脏介入治疗',
          points: 68,
          pipValue: 471,
          dgdov: 1.1,
          payStandard: 32028,
          totalAmt: 28500,
          preProfit: 3528,
          preLoss: 0,
          discrepancyRate: 12.3
        }
      ]
    },
    {
      id: 3,
      patientId: 'P2024010003',
      patientName: '王五',
      inpatientId: 'ZY2024010003',
      admitDate: '2024-01-20',
      dischargeDate: '2024-01-28',
      mainDiagnosis: 'S72.000',
      mainDiagnosisName: '股骨颈骨折',
      drgCode: 'IC13',
      drgName: '髋关节置换',
      mdcCode: 'MDCI',
      mdcName: '肌肉骨骼系统及功能障碍',
      totalCost: 45000,
      benchmarkCost: 48000,
      riskLevel: '低',
      hospAlgorithmInfo: [
        {
          hisHospCode: 'H001',
          hospCode: 'H001',
          hospName: '测试医院',
          drg: 'IC13',
          drgDesc: '髋关节置换',
          points: 120,
          pipValue: 400,
          dgdov: 1.0,
          payStandard: 48000,
          totalAmt: 45000,
          preProfit: 3000,
          preLoss: 0,
          discrepancyRate: 6.7
        }
      ]
    }
  ];

  // 加载数据
  const loadData = async (params: any = {}) => {
    setLoading(true);
    try {
      // 实际项目中从API获取数据
      // const res = await request.get('/api/drg/results', { params });
      // setData(res.data.list);
      // setPagination({ ...pagination, total: res.data.total });
      
      // 模拟数据
      setTimeout(() => {
        setData(mockData);
        setPagination({ ...pagination, total: mockData.length });
        setLoading(false);
      }, 500);
    } catch (error: any) {
      message.error(error.message || '加载数据失败');
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  // 查询
  const handleSearch = (values: any) => {
    loadData({ ...values, current: 1 });
  };

  // 重置
  const handleReset = () => {
    form.resetFields();
    loadData();
  };

  // 查看详情
  const handleViewDetail = (record: ResultRecord) => {
    setSelectedRecord(record);
    setDetailModalOpen(true);
  };

  // 分页变化
  const handleTableChange = (paginationConfig: any) => {
    setPagination(paginationConfig);
    loadData({ current: paginationConfig.current, pageSize: paginationConfig.pageSize });
  };

  const columns: ColumnsType<ResultRecord> = [
    { title: '患者ID', dataIndex: 'patientId', key: 'patientId', width: 120 },
    { title: '姓名', dataIndex: 'patientName', key: 'patientName', width: 80 },
    { title: '住院号', dataIndex: 'inpatientId', key: 'inpatientId', width: 130 },
    { title: '入院日期', dataIndex: 'admitDate', key: 'admitDate', width: 100 },
    { title: '出院日期', dataIndex: 'dischargeDate', key: 'dischargeDate', width: 100 },
    { title: '主诊断', dataIndex: 'mainDiagnosis', key: 'mainDiagnosis', width: 100 },
    { title: '诊断名称', dataIndex: 'mainDiagnosisName', key: 'mainDiagnosisName', ellipsis: true },
    { 
      title: 'DRG', 
      key: 'drg', 
      width: 150,
      render: (_, record) => (
        <Space direction="vertical" size={0}>
          <Tag color="blue">{record.drgCode}</Tag>
          <Text style={{ fontSize: 12 }} ellipsis={{ tooltip: record.drgName }}>
            {record.drgName}
          </Text>
        </Space>
      )
    },
    { 
      title: '风险等级', 
      dataIndex: 'riskLevel', 
      key: 'riskLevel', 
      width: 80,
      render: (level: string) => (
        <Tag color={level === '高' ? 'red' : level === '中' ? 'orange' : 'green'}>
          {level}
        </Tag>
      )
    },
    {
      title: '总费用',
      dataIndex: 'totalCost',
      key: 'totalCost',
      width: 100,
      render: (cost: number) => `¥${cost?.toLocaleString() || 0}`
    },
    {
      title: '基准费用',
      dataIndex: 'benchmarkCost',
      key: 'benchmarkCost',
      width: 100,
      render: (cost: number) => `¥${cost?.toLocaleString() || 0}`
    },
    {
      title: '操作',
      key: 'action',
      width: 80,
      fixed: 'right',
      render: (_, record) => (
        <Button 
          type="link" 
          icon={<EyeOutlined />} 
          onClick={() => handleViewDetail(record)}
        >
          详情
        </Button>
      )
    }
  ];

  return (
    <div style={{ padding: 16 }}>
      <Card>
        <Title level={4}>分组结果查询</Title>
        
        {/* 搜索表单 */}
        <Form 
          form={form} 
          layout="inline" 
          onFinish={handleSearch}
          style={{ marginBottom: 16 }}
        >
          <Form.Item name="keyword" label="关键词">
            <Input placeholder="姓名/住院号/诊断" style={{ width: 150 }} />
          </Form.Item>
          <Form.Item name="drgCode" label="DRG编码">
            <Input placeholder="DRG编码" style={{ width: 120 }} />
          </Form.Item>
          <Form.Item name="dateRange" label="出院日期">
            <RangePicker />
          </Form.Item>
          <Form.Item name="riskLevel" label="风险等级">
            <Select placeholder="请选择" style={{ width: 100 }} allowClear>
              <Option value="高">高</Option>
              <Option value="中">中</Option>
              <Option value="低">低</Option>
            </Select>
          </Form.Item>
          <Form.Item>
            <Space>
              <Button type="primary" icon={<SearchOutlined />} htmlType="submit">
                查询
              </Button>
              <Button icon={<ReloadOutlined />} onClick={handleReset}>
                重置
              </Button>
            </Space>
          </Form.Item>
        </Form>

        {/* 数据表格 */}
        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          pagination={pagination}
          onChange={handleTableChange}
          scroll={{ x: 1200 }}
          size="small"
        />
      </Card>

      {/* 详情弹窗 */}
      <Modal
        title="分组结果详情"
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        width={900}
      >
        {selectedRecord && (
          <>
            <Descriptions bordered column={2} size="small" style={{ marginBottom: 16 }}>
              <Descriptions.Item label="患者ID">{selectedRecord.patientId}</Descriptions.Item>
              <Descriptions.Item label="姓名">{selectedRecord.patientName}</Descriptions.Item>
              <Descriptions.Item label="住院号">{selectedRecord.inpatientId}</Descriptions.Item>
              <Descriptions.Item label="风险等级">
                <Tag color={selectedRecord.riskLevel === '高' ? 'red' : selectedRecord.riskLevel === '中' ? 'orange' : 'green'}>
                  {selectedRecord.riskLevel}
                </Tag>
              </Descriptions.Item>
              <Descriptions.Item label="入院日期">{selectedRecord.admitDate}</Descriptions.Item>
              <Descriptions.Item label="出院日期">{selectedRecord.dischargeDate}</Descriptions.Item>
              <Descriptions.Item label="主诊断" span={2}>
                <Space>
                  <Tag color="blue">{selectedRecord.mainDiagnosis}</Tag>
                  <Text>{selectedRecord.mainDiagnosisName}</Text>
                </Space>
              </Descriptions.Item>
              <Descriptions.Item label="DRG编码">{selectedRecord.drgCode}</Descriptions.Item>
              <Descriptions.Item label="DRG名称">{selectedRecord.drgName}</Descriptions.Item>
              <Descriptions.Item label="MDC编码">{selectedRecord.mdcCode}</Descriptions.Item>
              <Descriptions.Item label="MDC名称">{selectedRecord.mdcName}</Descriptions.Item>
            </Descriptions>

            <Row gutter={16} style={{ marginBottom: 16 }}>
              <Col span={8}>
                <Card size="small">
                  <Statistic 
                    title="总费用" 
                    value={selectedRecord.totalCost} 
                    prefix="¥"
                    valueStyle={{ color: '#1890ff' }}
                  />
                </Card>
              </Col>
              <Col span={8}>
                <Card size="small">
                  <Statistic 
                    title="基准费用" 
                    value={selectedRecord.benchmarkCost} 
                    prefix="¥"
                    valueStyle={{ color: '#52c41a' }}
                  />
                </Card>
              </Col>
              <Col span={8}>
                <Card size="small">
                  <Statistic 
                    title="费用差异" 
                    value={selectedRecord.totalCost - selectedRecord.benchmarkCost} 
                    prefix="¥"
                    valueStyle={{ color: selectedRecord.totalCost > selectedRecord.benchmarkCost ? '#ff4d4f' : '#52c41a' }}
                  />
                </Card>
              </Col>
            </Row>

            {/* 医疗机构算法信息 */}
            {selectedRecord.hospAlgorithmInfo && selectedRecord.hospAlgorithmInfo.length > 0 && (
              <>
                <Title level={5}>医疗机构算法信息</Title>
                <Row gutter={[16, 16]}>
                  {selectedRecord.hospAlgorithmInfo.map((item, index) => (
                    <Col span={12} key={index}>
                      <Card 
                        size="small" 
                        title={
                          <Space>
                            <Tag color="green">{item.drg}</Tag>
                            <Text type="secondary">{item.hospName}</Text>
                          </Space>
                        }
                        style={{ backgroundColor: '#f6ffed', border: '1px solid #b7eb8f' }}
                      >
                        <Row gutter={[8, 8]}>
                          <Col span={12}>
                            <Text type="secondary" style={{ fontSize: 12 }}>基准点数: </Text>
                            <Text style={{ fontSize: 13 }}>{item.points || '-'}</Text>
                          </Col>
                          <Col span={12}>
                            <Text type="secondary" style={{ fontSize: 12 }}>预估标准: </Text>
                            <Text style={{ fontSize: 13 }}>{item.payStandard || '-'}</Text>
                          </Col>
                          <Col span={12}>
                            <Text type="secondary" style={{ fontSize: 12 }}>点值: </Text>
                            <Text style={{ fontSize: 13 }}>{item.pipValue || '-'}</Text>
                          </Col>
                          <Col span={12}>
                            <Text type="secondary" style={{ fontSize: 12 }}>差异系数: </Text>
                            <Text style={{ fontSize: 13 }}>{item.dgdov || '-'}</Text>
                          </Col>
                          <Col span={12}>
                            <Text type="secondary" style={{ fontSize: 12 }}>当前费用总额: </Text>
                            <Text style={{ fontSize: 13 }}>{item.totalAmt !== undefined ? `¥${item.totalAmt}` : '-'}</Text>
                          </Col>
                          <Col span={12}>
                            <Text type="secondary" style={{ fontSize: 12 }}>预估盈利: </Text>
                            <Text style={{ fontSize: 13, color: '#52c41a' }}>
                              {item.preProfit !== undefined ? `¥${item.preProfit}` : '-'}
                            </Text>
                          </Col>
                          <Col span={12}>
                            <Text type="secondary" style={{ fontSize: 12 }}>预估亏损: </Text>
                            <Text style={{ fontSize: 13, color: '#ff4d4f' }}>
                              {item.preLoss !== undefined ? `¥${item.preLoss}` : '-'}
                            </Text>
                          </Col>
                          <Col span={12}>
                            <Text type="secondary" style={{ fontSize: 12 }}>差异率: </Text>
                            <Text style={{ fontSize: 13 }}>
                              {item.discrepancyRate !== undefined ? `${item.discrepancyRate}%` : '-'}
                            </Text>
                          </Col>
                        </Row>
                      </Card>
                    </Col>
                  ))}
                </Row>
              </>
            )}
          </>
        )}
      </Modal>
    </div>
  );
};

export default Results;
