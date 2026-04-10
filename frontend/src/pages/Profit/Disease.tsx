import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Select, Space, Row, Col,
  Tag, message, Statistic, DatePicker, Input, Modal, Descriptions
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, DollarOutlined,
  ArrowUpOutlined, ArrowDownOutlined, TrophyOutlined,
  WarningOutlined, BarChartOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { Dayjs } from 'dayjs';
import dayjs from 'dayjs';
import {
  queryDiseaseProfit, getDiseaseProfitStatistics,
  type DiseaseProfitItem, type QueryDiseaseProfitParams, type DiseaseProfitStatistics
} from '../../api/profit';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;
const { RangePicker } = DatePicker;

// 默认病种盈亏数据（接口异常时使用）
const defaultDiseaseData: DiseaseProfitItem[] = [
  { drgCode: 'FB23', drgName: '经皮冠状动脉介入治疗', dipCode: '', dipName: '', caseCount: 28, totalFee: 1256000.00, payStandard: 1425600.00, profitAmount: 169600.00, profitRate: 13.50, avgFee: 44857.14, avgPayment: 50914.29, avgProfit: 6057.14, weight: 2.15 },
  { drgCode: 'IB23', drgName: '髋关节置换术', dipCode: '', dipName: '', caseCount: 18, totalFee: 856000.00, payStandard: 756000.00, profitAmount: -100000.00, profitRate: -11.68, avgFee: 47555.56, avgPayment: 42000.00, avgProfit: -5555.56, weight: 1.85 },
  { drgCode: 'JA15', drgName: '胆囊切除术', dipCode: '', dipName: '', caseCount: 35, totalFee: 456000.00, payStandard: 556000.00, profitAmount: 100000.00, profitRate: 21.93, avgFee: 13028.57, avgPayment: 15885.71, avgProfit: 2857.14, weight: 1.25 },
  { drgCode: 'ER23', drgName: '脑梗死', dipCode: '', dipName: '', caseCount: 42, totalFee: 356000.00, payStandard: 456000.00, profitAmount: 100000.00, profitRate: 28.09, avgFee: 8476.19, avgPayment: 10857.14, avgProfit: 2380.95, weight: 0.95 },
  { drgCode: 'GR23', drgName: '肺炎', dipCode: '', dipName: '', caseCount: 56, totalFee: 286000.00, payStandard: 356000.00, profitAmount: 70000.00, profitRate: 24.48, avgFee: 5107.14, avgPayment: 6357.14, avgProfit: 1250.00, weight: 0.75 },
];

// 默认统计数据（接口异常时使用）
const defaultStatistics: DiseaseProfitStatistics = {
  totalDiseaseCount: 5,
  totalCaseCount: 179,
  totalProfitAmount: 339600.00,
  avgProfitRate: 15.46,
  profitDiseaseCount: 4,
  lossDiseaseCount: 1,
  balanceDiseaseCount: 0,
  topProfitDiseases: [
    { drgCode: 'ER23', drgName: '脑梗死', caseCount: 42, profitAmount: 100000.00, profitRate: 28.09 },
    { drgCode: 'GR23', drgName: '肺炎', caseCount: 56, profitAmount: 70000.00, profitRate: 24.48 },
    { drgCode: 'JA15', drgName: '胆囊切除术', caseCount: 35, profitAmount: 100000.00, profitRate: 21.93 },
  ],
  topLossDiseases: [
    { drgCode: 'IB23', drgName: '髋关节置换术', caseCount: 18, profitAmount: -100000.00, profitRate: -11.68 },
  ],
};

const Disease: React.FC = () => {
  // 列表状态
  const [data, setData] = useState<DiseaseProfitItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  
  // 统计数据
  const [statistics, setStatistics] = useState<DiseaseProfitStatistics | null>(null);
  const [statsLoading, setStatsLoading] = useState(false);
  
  // 查询条件
  const [queryParams, setQueryParams] = useState<QueryDiseaseProfitParams>({});
  const [selectedYear, setSelectedYear] = useState<string>(dayjs().format('YYYY'));
  const [selectedMonth, setSelectedMonth] = useState<string>(dayjs().format('MM'));
  
  // 详情弹窗
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [detailRecord, setDetailRecord] = useState<DiseaseProfitItem | null>(null);

  // 查询列表
  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await queryDiseaseProfit({
        year: selectedYear,
        month: selectedMonth,
        drgCode: queryParams.drgCode,
        dipCode: queryParams.dipCode,
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
      setData(defaultDiseaseData);
      setTotal(defaultDiseaseData.length);
    } finally {
      setLoading(false);
    }
  }, [queryParams, selectedYear, selectedMonth, currentPage, pageSize]);

  // 查询统计
  const fetchStatistics = useCallback(async () => {
    setStatsLoading(true);
    try {
      const res = await getDiseaseProfitStatistics({
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
    setData(defaultDiseaseData);
    setTotal(defaultDiseaseData.length);
    setStatistics(defaultStatistics);
  }, []);

  // 查看详情
  const handleViewDetail = (record: DiseaseProfitItem) => {
    setDetailRecord(record);
    setDetailModalOpen(true);
  };

  // 表格列定义
  const columns: ColumnsType<DiseaseProfitItem> = [
    {
      title: 'DRG编码',
      dataIndex: 'drgCode',
      width: 100,
      render: (v, record) => v || record.dipCode || '-',
    },
    {
      title: 'DRG/DIP名称',
      dataIndex: 'drgName',
      width: 200,
      ellipsis: true,
      render: (v, record) => v || record.dipName || '-',
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
      title: '支付标准',
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
      title: '权重',
      dataIndex: 'weight',
      width: 80,
      align: 'right',
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
                title="总病种数"
                value={statistics.totalDiseaseCount}
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
                title="盈利病种"
                value={statistics.profitDiseaseCount}
                suffix="个"
                valueStyle={{ color: '#52c41a' }}
                prefix={<ArrowUpOutlined />}
              />
            </Card>
          </Col>
          <Col span={4}>
            <Card size="small">
              <Statistic
                title="亏损病种"
                value={statistics.lossDiseaseCount}
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
              placeholder="DRG编码"
              value={queryParams.drgCode}
              onChange={e => setQueryParams({ ...queryParams, drgCode: e.target.value })}
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
            <Card title="Top10 盈利病种" size="small">
              <Table
                dataSource={statistics.topProfitDiseases}
                rowKey="drgCode"
                size="small"
                pagination={false}
                columns={[
                  { title: '排名', width: 60, render: (_, __, i) => i + 1 },
                  { title: 'DRG编码', dataIndex: 'drgCode', width: 100 },
                  { title: 'DRG名称', dataIndex: 'drgName' },
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
            <Card title="Top10 亏损病种" size="small">
              <Table
                dataSource={statistics.topLossDiseases}
                rowKey="drgCode"
                size="small"
                pagination={false}
                columns={[
                  { title: '排名', width: 60, render: (_, __, i) => i + 1 },
                  { title: 'DRG编码', dataIndex: 'drgCode', width: 100 },
                  { title: 'DRG名称', dataIndex: 'drgName' },
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
          <span style={{ color: '#999' }}>共 {total} 条记录</span>
        </div>
        <Table
          columns={columns}
          dataSource={data}
          rowKey={(record) => record.drgCode || record.dipCode}
          loading={loading}
          scroll={{ x: 1400 }}
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
        title="病种盈亏详情"
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        width={700}
      >
        {detailRecord && (
          <Descriptions bordered column={2} size="small">
            <Descriptions.Item label="DRG编码">{detailRecord.drgCode || detailRecord.dipCode}</Descriptions.Item>
            <Descriptions.Item label="DRG名称">{detailRecord.drgName || detailRecord.dipName}</Descriptions.Item>
            <Descriptions.Item label="病例数">{detailRecord.caseCount}</Descriptions.Item>
            <Descriptions.Item label="总费用">¥{detailRecord.totalFee.toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="支付标准">¥{detailRecord.payStandard.toFixed(2)}</Descriptions.Item>
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
            <Descriptions.Item label="平均盈亏">¥{detailRecord.avgProfit.toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="权重">{detailRecord.weight}</Descriptions.Item>
          </Descriptions>
        )}
      </Modal>
    </div>
  );
};

export default Disease;
