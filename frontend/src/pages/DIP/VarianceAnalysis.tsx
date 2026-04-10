import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Input, Select, Space, Row, Col,
  Tag, message, DatePicker, Statistic, Tabs, Badge, Tooltip
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, BarChartOutlined,
  DollarOutlined, ArrowUpOutlined, ArrowDownOutlined,
  WarningOutlined, CheckCircleOutlined, FileExcelOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { Dayjs } from 'dayjs';
import dayjs from 'dayjs';
import {
  queryDIPVariance, getDIPVarianceStatistics,
  type DIPVarianceItem, type DIPVarianceQueryParams, type DIPVarianceStatistics
} from '../../api/dip';
import { getProvinceData, getCityData, type ProvinceItem, type CityItem } from '../../api/basicData';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;
const { TabPane } = Tabs;
const { RangePicker } = DatePicker;

const VarianceAnalysis: React.FC = () => {
  const [activeTab, setActiveTab] = useState('list');
  
  // 列表查询状态
  const [data, setData] = useState<DIPVarianceItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  
  // 统计数据
  const [statistics, setStatistics] = useState<DIPVarianceStatistics | null>(null);
  const [statsLoading, setStatsLoading] = useState(false);
  
  // 查询条件
  const [queryParams, setQueryParams] = useState<DIPVarianceQueryParams>({});
  
  // 省市区数据
  const [provinces, setProvinces] = useState<ProvinceItem[]>([]);
  const [cities, setCities] = useState<CityItem[]>([]);

  // 加载省份数据
  useEffect(() => {
    const loadProvinces = async () => {
      try {
        const res = await getProvinceData();
        if (res.errorCode === '0' && res.result) {
          setProvinces(res.result);
        }
      } catch {
        // ignore
      }
    };
    loadProvinces();
  }, []);

  // 查询列表
  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await queryDIPVariance(queryParams, { pageSize: size, currentPage: page });
      if (res.errorCode === '0' && res.result) {
        setData(res.result.rows || []);
        setTotal(res.result.total || 0);
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setLoading(false);
    }
  }, [queryParams, currentPage, pageSize]);

  // 查询统计数据
  const fetchStatistics = useCallback(async () => {
    setStatsLoading(true);
    try {
      const res = await getDIPVarianceStatistics({
        startDate: queryParams.startDate,
        endDate: queryParams.endDate,
        department: queryParams.department,
        varianceLevel: queryParams.varianceLevel,
      });
      if (res.errorCode === '0' && res.result) {
        setStatistics(res.result);
      } else {
        message.error(res.errorMessage || '统计查询失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setStatsLoading(false);
    }
  }, [queryParams]);

  useEffect(() => {
    fetchData();
    fetchStatistics();
  }, [fetchData, fetchStatistics]);

  // 获取偏差等级颜色
  const getVarianceLevelColor = (level: string) => {
    switch (level) {
      case 'high': return '#ff4d4f';
      case 'medium': return '#faad14';
      case 'low': return '#52c41a';
      default: return '#999';
    }
  };

  // 获取偏差等级标签
  const getVarianceLevelTag = (level: string) => {
    switch (level) {
      case 'high': return <Tag color="red">高偏差</Tag>;
      case 'medium': return <Tag color="orange">中偏差</Tag>;
      case 'low': return <Tag color="green">低偏差</Tag>;
      default: return <Tag>正常</Tag>;
    }
  };

  // 表格列定义
  const columns: ColumnsType<DIPVarianceItem> = [
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
      title: '科室',
      dataIndex: 'department',
      width: 120,
    },
    {
      title: '医生',
      dataIndex: 'doctor',
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
      width: 180,
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
      title: '偏差金额',
      dataIndex: 'varianceAmount',
      width: 100,
      align: 'right',
      render: (v: number) => (
        <span style={{ color: (v || 0) >= 0 ? '#52c41a' : '#ff4d4f', fontWeight: 'bold' }}>
          {(v || 0) >= 0 ? '+' : ''}¥{(v || 0).toFixed(2)}
        </span>
      ),
    },
    {
      title: '偏差率',
      dataIndex: 'varianceRate',
      width: 100,
      align: 'right',
      render: (v: number) => (
        <span style={{ color: (v || 0) >= 0 ? '#52c41a' : '#ff4d4f', fontWeight: 'bold' }}>
          {(v || 0) >= 0 ? '+' : ''}{(v || 0).toFixed(2)}%
        </span>
      ),
    },
    {
      title: '偏差等级',
      dataIndex: 'varianceLevel',
      width: 90,
      render: (v: string) => getVarianceLevelTag(v),
    },
    {
      title: '出院日期',
      dataIndex: 'dischargeDate',
      width: 100,
    },
  ];

  return (
    <div style={{ padding: 16 }}>
      <Tabs activeKey={activeTab} onChange={setActiveTab}>
        <TabPane 
          tab={<span><BarChartOutlined />偏差分析列表</span>} 
          key="list"
        >
          {/* 统计卡片 */}
          {statistics && (
            <Row gutter={16} style={{ marginBottom: 16 }}>
              <Col span={4}>
                <Card size="small">
                  <Statistic
                    title="总病例数"
                    value={statistics.totalCases}
                    suffix="例"
                    valueStyle={{ color: '#1890ff' }}
                  />
                </Card>
              </Col>
              <Col span={4}>
                <Card size="small">
                  <Statistic
                    title="总费用"
                    value={statistics.totalCost}
                    prefix="¥"
                    precision={2}
                    valueStyle={{ color: '#722ed1' }}
                  />
                </Card>
              </Col>
              <Col span={4}>
                <Card size="small">
                  <Statistic
                    title="总支付"
                    value={statistics.totalPayment}
                    prefix="¥"
                    precision={2}
                    valueStyle={{ color: '#13c2c2' }}
                  />
                </Card>
              </Col>
              <Col span={4}>
                <Card size="small">
                  <Statistic
                    title="总偏差"
                    value={statistics.totalVariance}
                    prefix={statistics.totalVariance >= 0 ? '+' : ''}
                    precision={2}
                    valueStyle={{ color: statistics.totalVariance >= 0 ? '#52c41a' : '#ff4d4f' }}
                  />
                </Card>
              </Col>
              <Col span={4}>
                <Card size="small">
                  <Statistic
                    title="高偏差病例"
                    value={statistics.highVarianceCount}
                    suffix="例"
                    valueStyle={{ color: '#ff4d4f' }}
                  />
                </Card>
              </Col>
              <Col span={4}>
                <Card size="small">
                  <Statistic
                    title="平均偏差率"
                    value={statistics.avgVarianceRate}
                    suffix="%"
                    precision={2}
                    valueStyle={{ color: statistics.avgVarianceRate >= 0 ? '#52c41a' : '#ff4d4f' }}
                  />
                </Card>
              </Col>
            </Row>
          )}

          {/* 查询条件 */}
          <Card size="small" style={{ marginBottom: 16 }}>
            <Row gutter={16} align="middle">
              <Col>
                <Input
                  placeholder="病案号"
                  value={queryParams.admissionNo}
                  onChange={e => setQueryParams({ ...queryParams, admissionNo: e.target.value })}
                  style={{ width: 120 }}
                  allowClear
                />
              </Col>
              <Col>
                <Input
                  placeholder="患者姓名"
                  value={queryParams.patientName}
                  onChange={e => setQueryParams({ ...queryParams, patientName: e.target.value })}
                  style={{ width: 100 }}
                  allowClear
                />
              </Col>
              <Col>
                <Input
                  placeholder="科室"
                  value={queryParams.department}
                  onChange={e => setQueryParams({ ...queryParams, department: e.target.value })}
                  style={{ width: 120 }}
                  allowClear
                />
              </Col>
              <Col>
                <Input
                  placeholder="医生"
                  value={queryParams.doctor}
                  onChange={e => setQueryParams({ ...queryParams, doctor: e.target.value })}
                  style={{ width: 100 }}
                  allowClear
                />
              </Col>
              <Col>
                <Input
                  placeholder="DIP编码"
                  value={queryParams.dipCode}
                  onChange={e => setQueryParams({ ...queryParams, dipCode: e.target.value })}
                  style={{ width: 100 }}
                  allowClear
                />
              </Col>
              <Col>
                <Select
                  placeholder="偏差等级"
                  value={queryParams.varianceLevel}
                  onChange={v => setQueryParams({ ...queryParams, varianceLevel: v })}
                  style={{ width: 100 }}
                  allowClear
                >
                  <Option value="">全部</Option>
                  <Option value="high">高偏差</Option>
                  <Option value="medium">中偏差</Option>
                  <Option value="low">低偏差</Option>
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
              rowKey="id"
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
        </TabPane>

        <TabPane 
          tab={<span><BarChartOutlined />统计分析</span>} 
          key="statistics"
        >
          {statistics && (
            <>
              <Row gutter={16} style={{ marginBottom: 16 }}>
                <Col span={12}>
                  <Card title="偏差分布统计" size="small">
                    <Row gutter={16}>
                      <Col span={8}>
                        <Card size="small" style={{ background: '#fff1f0' }}>
                          <Statistic
                            title="高偏差病例"
                            value={statistics.highVarianceCount}
                            suffix="例"
                            valueStyle={{ color: '#ff4d4f' }}
                            prefix={<WarningOutlined />}
                          />
                        </Card>
                      </Col>
                      <Col span={8}>
                        <Card size="small" style={{ background: '#fff7e6' }}>
                          <Statistic
                            title="中偏差病例"
                            value={statistics.mediumVarianceCount}
                            suffix="例"
                            valueStyle={{ color: '#faad14' }}
                          />
                        </Card>
                      </Col>
                      <Col span={8}>
                        <Card size="small" style={{ background: '#f6ffed' }}>
                          <Statistic
                            title="低偏差病例"
                            value={statistics.lowVarianceCount}
                            suffix="例"
                            valueStyle={{ color: '#52c41a' }}
                            prefix={<CheckCircleOutlined />}
                          />
                        </Card>
                      </Col>
                    </Row>
                  </Card>
                </Col>
                <Col span={12}>
                  <Card title="整体统计" size="small">
                    <Row gutter={16}>
                      <Col span={12}>
                        <Statistic
                          title="平均偏差金额"
                          value={statistics.avgVarianceAmount}
                          prefix={statistics.avgVarianceAmount >= 0 ? '+' : ''}
                          precision={2}
                          valueStyle={{ color: statistics.avgVarianceAmount >= 0 ? '#52c41a' : '#ff4d4f' }}
                        />
                      </Col>
                      <Col span={12}>
                        <Statistic
                          title="平均偏差率"
                          value={statistics.avgVarianceRate}
                          suffix="%"
                          precision={2}
                          valueStyle={{ color: statistics.avgVarianceRate >= 0 ? '#52c41a' : '#ff4d4f' }}
                        />
                      </Col>
                    </Row>
                  </Card>
                </Col>
              </Row>

              <Row gutter={16}>
                <Col span={12}>
                  <Card title="Top5 偏差病种" size="small">
                    <Table
                      dataSource={statistics.topVarianceDips}
                      rowKey="dipCode"
                      size="small"
                      pagination={false}
                      columns={[
                        { title: '排名', dataIndex: 'index', width: 60, render: (_, __, i) => i + 1 },
                        { title: 'DIP编码', dataIndex: 'dipCode', width: 100 },
                        { title: 'DIP名称', dataIndex: 'dipName', ellipsis: true },
                        { title: '病例数', dataIndex: 'count', width: 80, align: 'right' },
                        { 
                          title: '平均偏差', 
                          dataIndex: 'avgVariance', 
                          width: 100, 
                          align: 'right',
                          render: (v: number) => (
                            <span style={{ color: (v || 0) >= 0 ? '#52c41a' : '#ff4d4f' }}>
                              {(v || 0) >= 0 ? '+' : ''}¥{(v || 0).toFixed(2)}
                            </span>
                          )
                        },
                      ]}
                    />
                  </Card>
                </Col>
                <Col span={12}>
                  <Card title="科室偏差排行" size="small">
                    <Table
                      dataSource={statistics.deptVarianceRank}
                      rowKey="department"
                      size="small"
                      pagination={false}
                      columns={[
                        { title: '排名', dataIndex: 'index', width: 60, render: (_, __, i) => i + 1 },
                        { title: '科室', dataIndex: 'department', ellipsis: true },
                        { title: '病例数', dataIndex: 'count', width: 80, align: 'right' },
                        { 
                          title: '平均偏差', 
                          dataIndex: 'avgVariance', 
                          width: 100, 
                          align: 'right',
                          render: (v: number) => (
                            <span style={{ color: (v || 0) >= 0 ? '#52c41a' : '#ff4d4f' }}>
                              {(v || 0) >= 0 ? '+' : ''}¥{(v || 0).toFixed(2)}
                            </span>
                          )
                        },
                        { 
                          title: '总偏差', 
                          dataIndex: 'totalVariance', 
                          width: 100, 
                          align: 'right',
                          render: (v: number) => (
                            <span style={{ color: (v || 0) >= 0 ? '#52c41a' : '#ff4d4f' }}>
                              {(v || 0) >= 0 ? '+' : ''}¥{(v || 0).toFixed(2)}
                            </span>
                          )
                        },
                      ]}
                    />
                  </Card>
                </Col>
              </Row>
            </>
          )}
        </TabPane>
      </Tabs>
    </div>
  );
};

export default VarianceAnalysis;
