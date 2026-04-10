import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Select, Space, Row, Col,
  Tag, message, Statistic, DatePicker, Input, Modal, Descriptions
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, DollarOutlined,
  ArrowUpOutlined, ArrowDownOutlined, FileExcelOutlined,
  RedoOutlined, BarChartOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { Dayjs } from 'dayjs';
import dayjs from 'dayjs';
import {
  queryDeptProfit, getDeptProfitStatistics, recalculateProfit,
  type DeptProfitItem, type QueryDeptProfitParams, type DeptProfitStatistics
} from '../../api/profit';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;
const { RangePicker } = DatePicker;

// 默认科室盈亏数据（接口异常时使用）
const defaultDeptData: DeptProfitItem[] = [
  { deptCode: '001', deptName: '心血管内科', totalCaseCount: 156, groupedCaseCount: 148, groupRate: 94.87, totalFee: 2856000.00, payStandard: 3124000.00, profitAmount: 268000.00, profitRate: 9.38, cmi: 1.25, avgFee: 18307.69, avgHospitalDays: 7.5 },
  { deptCode: '002', deptName: '骨科', totalCaseCount: 128, groupedCaseCount: 120, groupRate: 93.75, totalFee: 4568000.00, payStandard: 4256000.00, profitAmount: -312000.00, profitRate: -6.83, cmi: 1.85, avgFee: 35687.50, avgHospitalDays: 12.3 },
  { deptCode: '003', deptName: '普外科', totalCaseCount: 98, groupedCaseCount: 95, groupRate: 96.94, totalFee: 2156000.00, payStandard: 2389000.00, profitAmount: 233000.00, profitRate: 10.81, cmi: 1.42, avgFee: 22000.00, avgHospitalDays: 8.6 },
  { deptCode: '004', deptName: '呼吸内科', totalCaseCount: 186, groupedCaseCount: 172, groupRate: 92.47, totalFee: 1985000.00, payStandard: 2156000.00, profitAmount: 171000.00, profitRate: 8.61, cmi: 1.15, avgFee: 10672.04, avgHospitalDays: 9.2 },
  { deptCode: '005', deptName: '神经外科', totalCaseCount: 76, groupedCaseCount: 72, groupRate: 94.74, totalFee: 3896000.00, payStandard: 3568000.00, profitAmount: -328000.00, profitRate: -8.42, cmi: 2.15, avgFee: 51263.16, avgHospitalDays: 14.5 },
];

// 默认统计数据（接口异常时使用）
const defaultStatistics: DeptProfitStatistics = {
  totalDeptCount: 5,
  totalCaseCount: 644,
  totalProfitAmount: 32000.00,
  avgProfitRate: 2.71,
  profitDeptCount: 3,
  lossDeptCount: 2,
  balanceDeptCount: 0,
  topProfitDepts: [
    { deptCode: '003', deptName: '普外科', profitAmount: 233000.00, profitRate: 10.81 },
    { deptCode: '001', deptName: '心血管内科', profitAmount: 268000.00, profitRate: 9.38 },
    { deptCode: '004', deptName: '呼吸内科', profitAmount: 171000.00, profitRate: 8.61 },
  ],
  topLossDepts: [
    { deptCode: '005', deptName: '神经外科', profitAmount: -328000.00, profitRate: -8.42 },
    { deptCode: '002', deptName: '骨科', profitAmount: -312000.00, profitRate: -6.83 },
  ],
};

const Dept: React.FC = () => {
  // 列表状态
  const [data, setData] = useState<DeptProfitItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  
  // 统计数据
  const [statistics, setStatistics] = useState<DeptProfitStatistics | null>(null);
  const [statsLoading, setStatsLoading] = useState(false);
  
  // 查询条件
  const [queryParams, setQueryParams] = useState<QueryDeptProfitParams>({});
  const [selectedYear, setSelectedYear] = useState<string>(dayjs().format('YYYY'));
  const [selectedMonth, setSelectedMonth] = useState<string>(dayjs().format('MM'));
  
  // 详情弹窗
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [detailRecord, setDetailRecord] = useState<DeptProfitItem | null>(null);

  // 查询列表
  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await queryDeptProfit({
        year: selectedYear,
        month: selectedMonth,
        deptCode: queryParams.deptCode,
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
      setData(defaultDeptData);
      setTotal(defaultDeptData.length);
    } finally {
      setLoading(false);
    }
  }, [queryParams, selectedYear, selectedMonth, currentPage, pageSize]);

  // 查询统计
  const fetchStatistics = useCallback(async () => {
    setStatsLoading(true);
    try {
      const res = await getDeptProfitStatistics({
        year: selectedYear,
        month: selectedMonth,
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
  }, [selectedYear, selectedMonth, queryParams.startDate, queryParams.endDate]);

  // 初始加载默认数据，不调用接口
  useEffect(() => {
    setData(defaultDeptData);
    setTotal(defaultDeptData.length);
    setStatistics(defaultStatistics);
  }, []);

  // 重新计算
  const handleRecalculate = () => {
    Modal.confirm({
      title: '重新计算确认',
      content: `确定要重新计算 ${selectedYear}年${selectedMonth}月 的盈亏数据吗？`,
      onOk: async () => {
        try {
          const res = await recalculateProfit({
            year: selectedYear,
            month: selectedMonth,
            deptCode: queryParams.deptCode,
          });
          if (res.errorCode === '0' && res.result) {
            message.success(`重新计算完成，共 ${res.result.recalculatedCount} 条记录`);
            fetchData();
            fetchStatistics();
          } else {
            message.error(res.errorMessage || '重新计算失败');
          }
        } catch {
          message.error('网络异常');
        }
      },
    });
  };

  // 查看详情
  const handleViewDetail = (record: DeptProfitItem) => {
    setDetailRecord(record);
    setDetailModalOpen(true);
  };

  // 表格列定义
  const columns: ColumnsType<DeptProfitItem> = [
    {
      title: '科室编码',
      dataIndex: 'deptCode',
      width: 100,
    },
    {
      title: '科室名称',
      dataIndex: 'deptName',
      width: 150,
      fixed: 'left',
    },
    {
      title: '总病例数',
      dataIndex: 'totalCaseCount',
      width: 100,
      align: 'right',
    },
    {
      title: '已分组病例',
      dataIndex: 'groupedCaseCount',
      width: 100,
      align: 'right',
    },
    {
      title: '分组率(%)',
      dataIndex: 'groupRate',
      width: 100,
      align: 'right',
      render: (v: number) => `${(v || 0).toFixed(2)}%`,
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
      title: 'CMI值',
      dataIndex: 'cmi',
      width: 80,
      align: 'right',
    },
    {
      title: '次均费用',
      dataIndex: 'avgFee',
      width: 120,
      align: 'right',
      render: (v: number) => `¥${(v || 0).toFixed(2)}`,
    },
    {
      title: '平均住院天数',
      dataIndex: 'avgHospitalDays',
      width: 120,
      align: 'right',
      render: (v: number) => `${(v || 0).toFixed(1)}天`,
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
                title="总科室数"
                value={statistics.totalDeptCount}
                suffix="个"
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
                title="盈利科室"
                value={statistics.profitDeptCount}
                suffix="个"
                valueStyle={{ color: '#52c41a' }}
                prefix={<ArrowUpOutlined />}
              />
            </Card>
          </Col>
          <Col span={4}>
            <Card size="small">
              <Statistic
                title="亏损科室"
                value={statistics.lossDeptCount}
                suffix="个"
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
              <Button 
                icon={<RedoOutlined />} 
                onClick={handleRecalculate}
              >
                重新计算
              </Button>
            </Space>
          </Col>
        </Row>
      </Card>

      {/* 盈亏排行 */}
      {statistics && (
        <Row gutter={16} style={{ marginBottom: 16 }}>
          <Col span={12}>
            <Card title="Top10 盈利科室" size="small">
              <Table
                dataSource={statistics.topProfitDepts}
                rowKey="deptCode"
                size="small"
                pagination={false}
                columns={[
                  { title: '排名', width: 60, render: (_, __, i) => i + 1 },
                  { title: '科室编码', dataIndex: 'deptCode', width: 100 },
                  { title: '科室名称', dataIndex: 'deptName' },
                  { 
                    title: '盈亏金额', 
                    dataIndex: 'profitAmount', 
                    width: 120, 
                    align: 'right',
                    render: (v: number) => (
                      <span style={{ color: '#52c41a' }}>
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
                      <span style={{ color: '#52c41a' }}>
                        +${(v || 0).toFixed(2)}%
                      </span>
                    )
                  },
                ]}
              />
            </Card>
          </Col>
          <Col span={12}>
            <Card title="Top10 亏损科室" size="small">
              <Table
                dataSource={statistics.topLossDepts}
                rowKey="deptCode"
                size="small"
                pagination={false}
                columns={[
                  { title: '排名', width: 60, render: (_, __, i) => i + 1 },
                  { title: '科室编码', dataIndex: 'deptCode', width: 100 },
                  { title: '科室名称', dataIndex: 'deptName' },
                  { 
                    title: '盈亏金额', 
                    dataIndex: 'profitAmount', 
                    width: 120, 
                    align: 'right',
                    render: (v: number) => (
                      <span style={{ color: '#ff4d4f' }}>
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
                      <span style={{ color: '#ff4d4f' }}>
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
          rowKey="deptCode"
          loading={loading}
          scroll={{ x: 1600 }}
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
        title="科室盈亏详情"
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        width={700}
      >
        {detailRecord && (
          <Descriptions bordered column={2} size="small">
            <Descriptions.Item label="科室编码">{detailRecord.deptCode}</Descriptions.Item>
            <Descriptions.Item label="科室名称">{detailRecord.deptName}</Descriptions.Item>
            <Descriptions.Item label="总病例数">{detailRecord.totalCaseCount}</Descriptions.Item>
            <Descriptions.Item label="已分组病例">{detailRecord.groupedCaseCount}</Descriptions.Item>
            <Descriptions.Item label="分组率">{detailRecord.groupRate.toFixed(2)}%</Descriptions.Item>
            <Descriptions.Item label="CMI值">{detailRecord.cmi}</Descriptions.Item>
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
            <Descriptions.Item label="平均住院天数">{detailRecord.avgHospitalDays.toFixed(1)}天</Descriptions.Item>
          </Descriptions>
        )}
      </Modal>
    </div>
  );
};

export default Dept;
