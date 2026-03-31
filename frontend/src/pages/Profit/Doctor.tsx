import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Select, Space, Row, Col,
  Tag, message, Statistic, DatePicker, Input, Modal, Descriptions
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, DollarOutlined,
  ArrowUpOutlined, ArrowDownOutlined, UserOutlined,
  BarChartOutlined, TrophyOutlined, WarningOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { Dayjs } from 'dayjs';
import dayjs from 'dayjs';
import {
  queryDoctorProfit, getDoctorProfitStatistics,
  type DoctorProfitItem, type QueryDoctorProfitParams, type DoctorProfitStatistics
} from '../../api/profit';

const { Option } = Select;
const { RangePicker } = DatePicker;

// 默认医生盈亏数据（接口异常时使用）
const defaultDoctorData: DoctorProfitItem[] = [
  { doctorCode: 'D001', doctorName: '张医生', deptCode: '001', deptName: '心血管内科', caseCount: 45, totalFee: 856000.00, payStandard: 956000.00, profitAmount: 100000.00, profitRate: 11.68, avgFee: 19022.22, avgPayment: 21244.44, avgProfit: 100000.00 },
  { doctorCode: 'D002', doctorName: '李医生', deptCode: '002', deptName: '骨科', caseCount: 38, totalFee: 1425600.00, payStandard: 1256000.00, profitAmount: -169600.00, profitRate: -11.90, avgFee: 37515.79, avgPayment: 33052.63, avgProfit: -169600.00 },
  { doctorCode: 'D003', doctorName: '王医生', deptCode: '003', deptName: '普外科', caseCount: 52, totalFee: 1156000.00, payStandard: 1289000.00, profitAmount: 133000.00, profitRate: 11.51, avgFee: 22230.77, avgPayment: 24788.46, avgProfit: 133000.00 },
  { doctorCode: 'D004', doctorName: '刘医生', deptCode: '001', deptName: '心血管内科', caseCount: 42, totalFee: 756000.00, payStandard: 856000.00, profitAmount: 100000.00, profitRate: 13.23, avgFee: 18000.00, avgPayment: 20380.95, avgProfit: 100000.00 },
  { doctorCode: 'D005', doctorName: '陈医生', deptCode: '004', deptName: '呼吸内科', caseCount: 68, totalFee: 785000.00, payStandard: 856000.00, profitAmount: 71000.00, profitRate: 9.04, avgFee: 11544.12, avgPayment: 12588.24, avgProfit: 71000.00 },
];

// 默认统计数据（接口异常时使用）
const defaultStatistics: DoctorProfitStatistics = {
  totalDoctorCount: 5,
  totalCaseCount: 245,
  totalProfitAmount: 234400.00,
  avgProfitRate: 6.71,
  profitDoctorCount: 4,
  lossDoctorCount: 1,
  balanceDoctorCount: 0,
  topProfitDoctors: [
    { doctorCode: 'D004', doctorName: '刘医生', deptName: '心血管内科', profitAmount: 100000.00, profitRate: 13.23 },
    { doctorCode: 'D001', doctorName: '张医生', deptName: '心血管内科', profitAmount: 100000.00, profitRate: 11.68 },
    { doctorCode: 'D003', doctorName: '王医生', deptName: '普外科', profitAmount: 133000.00, profitRate: 11.51 },
  ],
  topLossDoctors: [
    { doctorCode: 'D002', doctorName: '李医生', deptName: '骨科', profitAmount: -169600.00, profitRate: -11.90 },
  ],
};

const Doctor: React.FC = () => {
  // 列表状态
  const [data, setData] = useState<DoctorProfitItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  
  // 统计数据
  const [statistics, setStatistics] = useState<DoctorProfitStatistics | null>(null);
  const [statsLoading, setStatsLoading] = useState(false);
  
  // 查询条件
  const [queryParams, setQueryParams] = useState<QueryDoctorProfitParams>({});
  const [selectedYear, setSelectedYear] = useState<string>(dayjs().format('YYYY'));
  const [selectedMonth, setSelectedMonth] = useState<string>(dayjs().format('MM'));
  
  // 详情弹窗
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [detailRecord, setDetailRecord] = useState<DoctorProfitItem | null>(null);

  // 查询列表
  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await queryDoctorProfit({
        year: selectedYear,
        month: selectedMonth,
        deptCode: queryParams.deptCode,
        doctorCode: queryParams.doctorCode,
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
      setData(defaultDoctorData);
      setTotal(defaultDoctorData.length);
    } finally {
      setLoading(false);
    }
  }, [queryParams, selectedYear, selectedMonth, currentPage, pageSize]);

  // 查询统计
  const fetchStatistics = useCallback(async () => {
    setStatsLoading(true);
    try {
      const res = await getDoctorProfitStatistics({
        year: selectedYear,
        month: selectedMonth,
        deptCode: queryParams.deptCode,
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
  }, [selectedYear, selectedMonth, queryParams.deptCode, queryParams.startDate, queryParams.endDate]);

  // 初始加载默认数据，不调用接口
  useEffect(() => {
    setData(defaultDoctorData);
    setTotal(defaultDoctorData.length);
    setStatistics(defaultStatistics);
  }, []);

  // 查看详情
  const handleViewDetail = (record: DoctorProfitItem) => {
    setDetailRecord(record);
    setDetailModalOpen(true);
  };

  // 表格列定义
  const columns: ColumnsType<DoctorProfitItem> = [
    {
      title: '医生编码',
      dataIndex: 'doctorCode',
      width: 100,
    },
    {
      title: '医生姓名',
      dataIndex: 'doctorName',
      width: 100,
      fixed: 'left',
    },
    {
      title: '科室编码',
      dataIndex: 'deptCode',
      width: 100,
    },
    {
      title: '科室名称',
      dataIndex: 'deptName',
      width: 150,
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
      title: 'DRG支付标准',
      dataIndex: 'payStandard',
      width: 120,
      align: 'right',
      render: (v: number) => `¥${(v || 0).toFixed(2)}`,
    },
    {
      title: '盈亏金额',
      dataIndex: 'profitAmount',
      width: 120,
      align: 'right',
      render: (v: number) => (
        <span style={{ color: (v || 0) >= 0 ? '#52c41a' : '#ff4d4f', fontWeight: 'bold' }}>
          {(v || 0) >= 0 ? '+' : ''}¥{(v || 0).toFixed(2)}
        </span>
      ),
    },
    {
      title: '盈亏率(%)',
      dataIndex: 'profitRate',
      width: 100,
      align: 'right',
      render: (v: number) => (
        <span style={{ color: (v || 0) >= 0 ? '#52c41a' : '#ff4d4f', fontWeight: 'bold' }}>
          {(v || 0) >= 0 ? '+' : ''}${(v || 0).toFixed(2)}%
        </span>
      ),
    },
    {
      title: '次均费用',
      dataIndex: 'avgFee',
      width: 120,
      align: 'right',
      render: (v: number) => `¥${(v || 0).toFixed(2)}`,
    },
    {
      title: '次均支付',
      dataIndex: 'avgPayment',
      width: 120,
      align: 'right',
      render: (v: number) => `¥${(v || 0).toFixed(2)}`,
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
          <Col span={4}>
            <Card size="small">
              <Statistic
                title="总医生数"
                value={statistics.totalDoctorCount}
                suffix="人"
                valueStyle={{ color: '#1890ff' }}
              />
            </Card>
          </Col>
          <Col span={4}>
            <Card size="small">
              <Statistic
                title="总病例数"
                value={statistics.totalCaseCount}
                suffix="例"
                valueStyle={{ color: '#722ed1' }}
              />
            </Card>
          </Col>
          <Col span={4}>
            <Card size="small">
              <Statistic
                title="总盈亏"
                value={statistics.totalProfitAmount}
                prefix={(statistics.totalProfitAmount >= 0 ? '+' : '') + '¥'}
                precision={2}
                valueStyle={{ color: statistics.totalProfitAmount >= 0 ? '#52c41a' : '#ff4d4f' }}
              />
            </Card>
          </Col>
          <Col span={4}>
            <Card size="small">
              <Statistic
                title="平均盈亏率"
                value={statistics.avgProfitRate}
                suffix="%"
                precision={2}
                valueStyle={{ color: statistics.avgProfitRate >= 0 ? '#52c41a' : '#ff4d4f' }}
              />
            </Card>
          </Col>
          <Col span={4}>
            <Card size="small">
              <Statistic
                title="盈利医生"
                value={statistics.profitDoctorCount}
                suffix="人"
                valueStyle={{ color: '#52c41a' }}
                prefix={<ArrowUpOutlined />}
              />
            </Card>
          </Col>
          <Col span={4}>
            <Card size="small">
              <Statistic
                title="亏损医生"
                value={statistics.lossDoctorCount}
                suffix="人"
                valueStyle={{ color: '#ff4d4f' }}
                prefix={<ArrowDownOutlined />}
              />
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

      {/* 盈亏排行 */}
      {statistics && (
        <Row gutter={16} style={{ marginBottom: 16 }}>
          <Col span={12}>
            <Card title="Top10 盈利医生" size="small">
              <Table
                dataSource={statistics.topProfitDoctors}
                rowKey="doctorCode"
                size="small"
                pagination={false}
                columns={[
                  { title: '排名', width: 60, render: (_, __, i) => {
                    if (i < 3) return <TrophyOutlined style={{ color: '#faad14' }} />;
                    return i + 1;
                  }},
                  { title: '医生编码', dataIndex: 'doctorCode', width: 100 },
                  { title: '医生姓名', dataIndex: 'doctorName' },
                  { title: '科室', dataIndex: 'deptName' },
                  { 
                    title: '盈亏金额', 
                    dataIndex: 'profitAmount', 
                    width: 120, 
                    align: 'right',
                    render: (v: number) => (
                      <span style={{ color: '#52c41a', fontWeight: 'bold' }}>
                        +¥{(v || 0).toFixed(2)}
                      </span>
                    )
                  },
                  { 
                    title: '盈亏率', 
                    dataIndex: 'profitRate', 
                    width: 100, 
                    align: 'right',
                    render: (v: number) => (
                      <span style={{ color: '#52c41a', fontWeight: 'bold' }}>
                        +${(v || 0).toFixed(2)}%
                      </span>
                    )
                  },
                ]}
              />
            </Card>
          </Col>
          <Col span={12}>
            <Card title="Top10 亏损医生" size="small">
              <Table
                dataSource={statistics.topLossDoctors}
                rowKey="doctorCode"
                size="small"
                pagination={false}
                columns={[
                  { title: '排名', width: 60, render: (_, __, i) => {
                    if (i < 3) return <WarningOutlined style={{ color: '#ff4d4f' }} />;
                    return i + 1;
                  }},
                  { title: '医生编码', dataIndex: 'doctorCode', width: 100 },
                  { title: '医生姓名', dataIndex: 'doctorName' },
                  { title: '科室', dataIndex: 'deptName' },
                  { 
                    title: '盈亏金额', 
                    dataIndex: 'profitAmount', 
                    width: 120, 
                    align: 'right',
                    render: (v: number) => (
                      <span style={{ color: '#ff4d4f', fontWeight: 'bold' }}>
                        ¥{(v || 0).toFixed(2)}
                      </span>
                    )
                  },
                  { 
                    title: '盈亏率', 
                    dataIndex: 'profitRate', 
                    width: 100, 
                    align: 'right',
                    render: (v: number) => (
                      <span style={{ color: '#ff4d4f', fontWeight: 'bold' }}>
                        ${(v || 0).toFixed(2)}%
                      </span>
                    )
                  },
                ]}
              />
            </Card>
          </Col>
        </Row>
      )}

      {/* 数据表格 */}
      <Card size="small">
        <div style={{ marginBottom: 12 }}>
          <Space>
            <span style={{ color: '#999' }}>共 {total} 条记录</span>
          </Space>
        </div>
        <Table
          columns={columns}
          dataSource={data}
          rowKey="doctorCode"
          loading={loading}
          scroll={{ x: 1500 }}
          size="small"
          pagination={{
            current: currentPage,
            pageSize,
            total,
            showSizeChanger: true,
            showTotal: (t) => `共 ${t} 条`,
            onChange: (page, size) => {
              setCurrentPage(page);
              setPageSize(size);
              fetchData(page, size);
            },
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
        title="医生盈亏详情"
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        width={700}
      >
        {detailRecord && (
          <Descriptions bordered column={2} size="small">
            <Descriptions.Item label="医生编码">{detailRecord.doctorCode}</Descriptions.Item>
            <Descriptions.Item label="医生姓名">{detailRecord.doctorName}</Descriptions.Item>
            <Descriptions.Item label="科室编码">{detailRecord.deptCode}</Descriptions.Item>
            <Descriptions.Item label="科室名称">{detailRecord.deptName}</Descriptions.Item>
            <Descriptions.Item label="病例数">{detailRecord.caseCount}</Descriptions.Item>
            <Descriptions.Item label="总费用">¥{detailRecord.totalFee.toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="DRG支付标准">¥{detailRecord.payStandard.toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="盈亏金额">
              <span style={{ color: detailRecord.profitAmount >= 0 ? '#52c41a' : '#ff4d4f', fontWeight: 'bold' }}>
                {detailRecord.profitAmount >= 0 ? '+' : ''}¥{detailRecord.profitAmount.toFixed(2)}
              </span>
            </Descriptions.Item>
            <Descriptions.Item label="盈亏率">
              <span style={{ color: detailRecord.profitRate >= 0 ? '#52c41a' : '#ff4d4f', fontWeight: 'bold' }}>
                {detailRecord.profitRate >= 0 ? '+' : ''}{detailRecord.profitRate.toFixed(2)}%
              </span>
            </Descriptions.Item>
            <Descriptions.Item label="次均费用">¥{detailRecord.avgFee.toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="次均支付">¥{detailRecord.avgPayment.toFixed(2)}</Descriptions.Item>
          </Descriptions>
        )}
      </Modal>
    </div>
  );
};

export default Doctor;
