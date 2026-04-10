import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Select, Space, Row, Col,
  Tag, message, Statistic, DatePicker, Input, Modal, Descriptions,
  Divider
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, DollarOutlined,
  PieChartOutlined, BarChartOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { Dayjs } from 'dayjs';
import dayjs from 'dayjs';
import {
  queryCostStructure, getCostStructureStatistics,
  type CostStructureItem, type QueryCostStructureParams, type CostStructureStatistics
} from '../../api/profit';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;
const { RangePicker } = DatePicker;

// 默认费用结构数据（接口异常时使用）
const defaultCostData: CostStructureItem[] = [
  { deptCode: '001', deptName: '心血管内科', doctorCode: 'D001', doctorName: '张医生', drgCode: 'FB23', drgName: '经皮冠状动脉介入治疗', caseCount: 12, totalFee: 542400.00, drugCost: 162720.00, drugCostRatio: 30.0, materialCost: 189840.00, materialCostRatio: 35.0, serviceCost: 108480.00, serviceCostRatio: 20.0, examCost: 54240.00, examCostRatio: 10.0, otherCost: 27120.00, otherCostRatio: 5.0 },
  { deptCode: '002', deptName: '骨科', doctorCode: 'D002', doctorName: '李医生', drgCode: 'IB23', drgName: '髋关节置换术', caseCount: 8, totalFee: 380800.00, drugCost: 76160.00, drugCostRatio: 20.0, materialCost: 209440.00, materialCostRatio: 55.0, serviceCost: 57120.00, serviceCostRatio: 15.0, examCost: 26656.00, examCostRatio: 7.0, otherCost: 11424.00, otherCostRatio: 3.0 },
  { deptCode: '003', deptName: '普外科', doctorCode: 'D003', doctorName: '王医生', drgCode: 'JA15', drgName: '胆囊切除术', caseCount: 15, totalFee: 195000.00, drugCost: 58500.00, drugCostRatio: 30.0, materialCost: 48750.00, materialCostRatio: 25.0, serviceCost: 58500.00, serviceCostRatio: 30.0, examCost: 19500.00, examCostRatio: 10.0, otherCost: 9750.00, otherCostRatio: 5.0 },
  { deptCode: '004', deptName: '呼吸内科', doctorCode: 'D005', doctorName: '陈医生', drgCode: 'GR23', drgName: '肺炎', caseCount: 20, totalFee: 102000.00, drugCost: 40800.00, drugCostRatio: 40.0, materialCost: 10200.00, materialCostRatio: 10.0, serviceCost: 35700.00, serviceCostRatio: 35.0, examCost: 10200.00, examCostRatio: 10.0, otherCost: 5100.00, otherCostRatio: 5.0 },
  { deptCode: '001', deptName: '心血管内科', doctorCode: 'D004', doctorName: '刘医生', drgCode: 'FB23', drgName: '经皮冠状动脉介入治疗', caseCount: 10, totalFee: 452000.00, drugCost: 135600.00, drugCostRatio: 30.0, materialCost: 158200.00, materialCostRatio: 35.0, serviceCost: 90400.00, serviceCostRatio: 20.0, examCost: 45200.00, examCostRatio: 10.0, otherCost: 22600.00, otherCostRatio: 5.0 },
];

// 默认统计数据（接口异常时使用）
const defaultStatistics: CostStructureStatistics = {
  totalCaseCount: 65,
  totalFee: 1672200.00,
  totalDrugCost: 459200.00,
  totalMaterialCost: 689430.00,
  totalServiceCost: 399200.00,
  totalExamCost: 155796.00,
  totalOtherCost: 70574.00,
  avgDrugCostRatio: 30.0,
  avgMaterialCostRatio: 32.0,
  avgServiceCostRatio: 24.0,
  avgExamCostRatio: 9.4,
  avgOtherCostRatio: 4.6,
};

const CostStructure: React.FC = () => {
  // 列表状态
  const [data, setData] = useState<CostStructureItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  
  // 统计数据
  const [statistics, setStatistics] = useState<CostStructureStatistics | null>(null);
  const [statsLoading, setStatsLoading] = useState(false);
  
  // 查询条件
  const [queryParams, setQueryParams] = useState<QueryCostStructureParams>({});
  const [selectedYear, setSelectedYear] = useState<string>(dayjs().format('YYYY'));
  const [selectedMonth, setSelectedMonth] = useState<string>(dayjs().format('MM'));
  
  // 详情弹窗
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [detailRecord, setDetailRecord] = useState<CostStructureItem | null>(null);

  // 查询列表
  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await queryCostStructure({
        year: selectedYear,
        month: selectedMonth,
        deptCode: queryParams.deptCode,
        doctorCode: queryParams.doctorCode,
        drgCode: queryParams.drgCode,
        startDate: queryParams.startDate,
        endDate: queryParams.endDate,
      }, { pageSize: size, currentPage: page });
      if (res.errorCode === '0' && res.result) {
        setData(res.result.rows || []);
        setTotal(res.result.total || 0);
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch {
      message.warning('接口异常，显示默认数据');
      setData(defaultCostData);
      setTotal(defaultCostData.length);
    } finally {
      setLoading(false);
    }
  }, [queryParams, selectedYear, selectedMonth, currentPage, pageSize]);

  // 查询统计
  const fetchStatistics = useCallback(async () => {
    setStatsLoading(true);
    try {
      const res = await getCostStructureStatistics({
        year: selectedYear,
        month: selectedMonth,
        deptCode: queryParams.deptCode,
        doctorCode: queryParams.doctorCode,
        startDate: queryParams.startDate,
        endDate: queryParams.endDate,
      });
      if (res.errorCode === '0' && res.result) {
        setStatistics(res.result);
      }
    } catch {
      setStatistics(defaultStatistics);
    } finally {
      setStatsLoading(false);
    }
  }, [selectedYear, selectedMonth, queryParams.deptCode, queryParams.doctorCode, queryParams.startDate, queryParams.endDate]);

  // 初始加载默认数据，不调用接口
  useEffect(() => {
    setData(defaultCostData);
    setTotal(defaultCostData.length);
    setStatistics(defaultStatistics);
  }, []);

  // 查看详情
  const handleViewDetail = (record: CostStructureItem) => {
    setDetailRecord(record);
    setDetailModalOpen(true);
  };

  // 获取费用占比颜色
  const getCostColor = (value: number) => {
    if (value >= 50) return '#ff4d4f';
    if (value >= 30) return '#faad14';
    if (value >= 15) return '#52c41a';
    return '#1890ff';
  };

  // 表格列定义
  const columns: ColumnsType<CostStructureItem> = [
    {
      title: '科室编码',
      dataIndex: 'deptCode',
      width: 100,
    },
    {
      title: '科室名称',
      dataIndex: 'deptName',
      width: 120,
    },
    {
      title: '医生编码',
      dataIndex: 'doctorCode',
      width: 100,
    },
    {
      title: '医生姓名',
      dataIndex: 'doctorName',
      width: 100,
    },
    {
      title: 'DRG编码',
      dataIndex: 'drgCode',
      width: 100,
    },
    {
      title: '病例数',
      dataIndex: 'caseCount',
      width: 80,
      align: 'right',
    },
    {
      title: '总费用',
      dataIndex: 'totalFee',
      width: 120,
      align: 'right',
      render: (v: number) => `¥${(v || 0).toFixed(2)}`,
    },
    {
      title: '药费',
      dataIndex: 'drugCost',
      width: 120,
      align: 'right',
      render: (v: number, record) => (
        <span>¥{(v || 0).toFixed(2)} ({record.drugCostRatio.toFixed(1)}%)</span>
      ),
    },
    {
      title: '材料费',
      dataIndex: 'materialCost',
      width: 120,
      align: 'right',
      render: (v: number, record) => (
        <span>¥{(v || 0).toFixed(2)} ({record.materialCostRatio.toFixed(1)}%)</span>
      ),
    },
    {
      title: '服务费',
      dataIndex: 'serviceCost',
      width: 120,
      align: 'right',
      render: (v: number, record) => (
        <span>¥{(v || 0).toFixed(2)} ({record.serviceCostRatio.toFixed(1)}%)</span>
      ),
    },
    {
      title: '检查费',
      dataIndex: 'examCost',
      width: 120,
      align: 'right',
      render: (v: number, record) => (
        <span>¥{(v || 0).toFixed(2)} ({record.examCostRatio.toFixed(1)}%)</span>
      ),
    },
    {
      title: '其他费用',
      dataIndex: 'otherCost',
      width: 120,
      align: 'right',
      render: (v: number, record) => (
        <span>¥{(v || 0).toFixed(2)} ({record.otherCostRatio.toFixed(1)}%)</span>
      ),
    },
    {
      title: '操作',
      key: 'action',
      width: 80,
      fixed: 'right',
      render: (_, record) => (
        <Button type="link" size="small" onClick={() => handleViewDetail(record)}>
          详情
        </Button>
      ),
    },
  ];

  return (
    <div style={{ padding: 16 }}>
      {/* 统计卡片 */}
      {statistics && (
        <Row gutter={16} style={{ marginBottom: 16 }}>
          <Col span={3}>
            <Card size="small">
              <Statistic
                title="总病例数"
                value={statistics.totalCaseCount}
                suffix="例"
                valueStyle={{ color: '#1890ff' }}
              />
            </Card>
          </Col>
          <Col span={3}>
            <Card size="small">
              <Statistic
                title="总费用"
                value={statistics.totalFee}
                prefix="¥"
                precision={2}
                valueStyle={{ color: '#722ed1' }}
              />
            </Card>
          </Col>
          <Col span={6}>
            <Card title="费用构成" size="small">
              <Row gutter={16}>
                <Col span={12}>
                  <Statistic
                    title="药费占比"
                    value={statistics.avgDrugCostRatio}
                    suffix="%"
                    precision={1}
                    valueStyle={{ color: getCostColor(statistics.avgDrugCostRatio) }}
                    prefix={<PieChartOutlined />}
                  />
                </Col>
                <Col span={12}>
                  <Statistic
                    title="材料费占比"
                    value={statistics.avgMaterialCostRatio}
                    suffix="%"
                    precision={1}
                    valueStyle={{ color: getCostColor(statistics.avgMaterialCostRatio) }}
                  />
                </Col>
                <Col span={12}>
                  <Statistic
                    title="服务费占比"
                    value={statistics.avgServiceCostRatio}
                    suffix="%"
                    precision={1}
                    valueStyle={{ color: getCostColor(statistics.avgServiceCostRatio) }}
                  />
                </Col>
                <Col span={12}>
                  <Statistic
                    title="检查费占比"
                    value={statistics.avgExamCostRatio}
                    suffix="%"
                    precision={1}
                    valueStyle={{ color: getCostColor(statistics.avgExamCostRatio) }}
                  />
                </Col>
                <Col span={12}>
                  <Statistic
                    title="其他费用占比"
                    value={statistics.avgOtherCostRatio}
                    suffix="%"
                    precision={1}
                    valueStyle={{ color: getCostColor(statistics.avgOtherCostRatio) }}
                  />
                </Col>
              </Row>
            </Card>
          </Col>
        </Row>
      )}

      {/* 查询条件 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Row gutter={16} align="middle">
          <Col>
            <Select
              placeholder="年份"
              value={selectedYear}
              onChange={setSelectedYear}
              style={{ width: 100 }}
            >
              {Array.from({ length: 5 }, (_, i) => {
                const year = dayjs().subtract(i, 'year').format('YYYY');
                return <Option key={year} value={year}>{year}</Option>;
              })}
            </Select>
          </Col>
          <Col>
            <Select
              placeholder="月份"
              value={selectedMonth}
              onChange={setSelectedMonth}
              style={{ width: 80 }}
            >
              {Array.from({ length: 12 }, (_, i) => {
                const month = (i + 1).toString().padStart(2, '0');
                return <Option key={month} value={month}>{month}月</Option>;
              })}
            </Select>
          </Col>
          <Col>
            <Input
              placeholder="科室编码"
              value={queryParams.deptCode}
              onChange={e => setQueryParams({ ...queryParams, deptCode: e.target.value })}
              style={{ width: 120 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="医生编码"
              value={queryParams.doctorCode}
              onChange={e => setQueryParams({ ...queryParams, doctorCode: e.target.value })}
              style={{ width: 120 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="DRG编码"
              value={queryParams.drgCode}
              onChange={e => setQueryParams({ ...queryParams, drgCode: e.target.value })}
              style={{ width: 120 }}
              allowClear
            />
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
              <Button type="primary" icon={<SearchOutlined />} onClick={() => { setCurrentPage(1); fetchData(1); }}>
                查询
              </Button>
              <Button icon={<ReloadOutlined />} onClick={() => { 
                setQueryParams({});
                setCurrentPage(1);
              }}>
                重置
              </Button>
            </Space>
          </Col>
        </Row>
      </Card>

      {/* 数据表格 */}
      <Card size="small">
        <div style={{ marginBottom: 12 }}>
          <span style={{ color: '#999' }}>共 {total} 条记录</span>
        </div>
        <Table
          columns={columns}
          dataSource={data}
          rowKey={(record) => `${record.deptCode || ''}-${record.doctorCode || ''}-${record.drgCode || ''}`}
          loading={loading}
          scroll={{ x: 1500 }}
          size="small"
          pagination={false}
        />
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <CustomPagination
            current={currentPage}
            pageSize={pageSize}
            total={total}
            onChange={(page, size) => {
              setCurrentPage(page);
              setPageSize(size);
              fetchData(page, size);
            }}
          />
        </div>
      </Card>

      {/* 详情弹窗 */}
      <Modal
        title="费用结构详情"
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        width={700}
      >
        {detailRecord && (
          <Descriptions bordered column={2} size="small">
            <Descriptions.Item label="科室编码">{detailRecord.deptCode || '-'}</Descriptions.Item>
            <Descriptions.Item label="科室名称">{detailRecord.deptName || '-'}</Descriptions.Item>
            <Descriptions.Item label="医生编码">{detailRecord.doctorCode || '-'}</Descriptions.Item>
            <Descriptions.Item label="医生姓名">{detailRecord.doctorName || '-'}</Descriptions.Item>
            <Descriptions.Item label="DRG编码">{detailRecord.drgCode || '-'}</Descriptions.Item>
            <Descriptions.Item label="DRG名称">{detailRecord.drgName || '-'}</Descriptions.Item>
            <Descriptions.Item label="病例数">{detailRecord.caseCount}</Descriptions.Item>
            <Descriptions.Item label="总费用">¥{detailRecord.totalFee.toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="药费">¥{detailRecord.drugCost.toFixed(2)} ({detailRecord.drugCostRatio.toFixed(1)}%)</Descriptions.Item>
            <Descriptions.Item label="材料费">¥{detailRecord.materialCost.toFixed(2)} ({detailRecord.materialCostRatio.toFixed(1)}%)</Descriptions.Item>
            <Descriptions.Item label="服务费">¥{detailRecord.serviceCost.toFixed(2)} ({detailRecord.serviceCostRatio.toFixed(1)}%)</Descriptions.Item>
            <Descriptions.Item label="检查费">¥{detailRecord.examCost.toFixed(2)} ({detailRecord.examCostRatio.toFixed(1)}%)</Descriptions.Item>
            <Descriptions.Item label="其他费用">¥{detailRecord.otherCost.toFixed(2)} ({detailRecord.otherCostRatio.toFixed(1)}%)</Descriptions.Item>
          </Descriptions>
        )}
      </Modal>
    </div>
  );
};

export default CostStructure;
