import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Button,
  Space,
  Tag,
  Select,
  DatePicker,
  Row,
  Col,
  Typography,
  Input,
  Modal,
  Descriptions,
  Statistic,
  message,
} from 'antd';
import {
  SearchOutlined,
  ReloadOutlined,
  DownloadOutlined,
  EyeOutlined,
  HistoryOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  ExclamationCircleOutlined,
  RiseOutlined,
  DollarOutlined,
} from '@ant-design/icons';
import CustomPagination from '../../components/CustomPagination';
import type { ColumnsType } from 'antd/es/table';
import type { WarningRecord } from '@/api/warning';
import { queryWarningRecords } from '@/api/warning';
import { useDict } from '../../hooks/useDict';
import { getDictLabel } from '../../utils/dict';
import dayjs from 'dayjs';
import zhCN from 'antd/es/date-picker/locale/zh_CN';

const { Text } = Typography;
const { RangePicker } = DatePicker;
const { Option } = Select;

// 预警级别 Tag 颜色映射（UI展示用）
const WARNING_LEVEL_COLORS: Record<string, string> = {
  '1': 'success',
  '2': 'warning',
  '3': 'error',
};

// 预警状态 Tag 颜色映射（UI展示用）
const WARNING_STATUS_COLORS: Record<string, string> = {
  '01': 'default',
  '02': 'processing',
  '03': 'warning',
  '04': 'purple',
  '05': 'success',
};

interface StatsData {
  totalCount: number;
  pendingCount: number;
  processedCount: number;
  totalDiff?: number;
  totalProfit?: number;
  totalPayStandard?: number;
}

/** 格式化预警日期（兼容时间戳和字符串） */
const fmtDate = (val: any): string => {
  if (!val && val !== 0) return '-';
  const n = Number(val);
  if (!isNaN(n) && n > 100000000) return dayjs(n).format('YYYY-MM-DD');
  return String(val);
};

const Records: React.FC = () => {
  // 字典数据
  const { map: warningTypeMap, options: warningTypeOptions } = useDict('WARNING_TYPE');
  const { map: warningStatusMap, options: warningStatusOptions } = useDict('WARNING_STATUS');
  const { map: warningLevelMap, options: warningLevelOptions } = useDict('WARNING_LEVEL');

  const [data, setData] = useState<WarningRecord[]>([]);
  const [loading, setLoading] = useState(false);
  const [detailVisible, setDetailVisible] = useState(false);
  const [currentRecord, setCurrentRecord] = useState<WarningRecord | null>(null);
  const [stats, setStats] = useState<StatsData>({
    totalCount: 0,
    pendingCount: 0,
    processedCount: 0,
    totalDiff: 0,
    totalProfit: 0,
    totalPayStandard: 0,
  });

  // 筛选条件
  const [filterStatus, setFilterStatus] = useState<string>('');
  const [filterLevel, setFilterLevel] = useState<string>('');
  const [filterType, setFilterType] = useState<string>('');
  const [filterKeyword, setFilterKeyword] = useState<string>('');
  const [dateRange, setDateRange] = useState<[dayjs.Dayjs, dayjs.Dayjs] | null>(null);

  // 分页
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [total, setTotal] = useState(0);

  // 加载全部数据（统计+记录）
  const loadData = async () => {
    setLoading(true);
    try {
      // 一次性获取全部记录（用于统计计算和表格展示）
      const res: any = await queryWarningRecords(
        {
          warningStatus: filterStatus || undefined,
          warningType: filterType || undefined,
          patientName: filterKeyword || undefined,
          hisAdmId: filterKeyword || undefined,
          startDate: dateRange?.[0]?.format('YYYY-MM-DD') || '',
          endDate: dateRange?.[1]?.format('YYYY-MM-DD') || '',
        },
        { pageSize: 99999, currentPage: 1 }
      );
      console.log('[Records] records response:', res);

      if (res.errorCode === '0' || res.errorCode === 0) {
        let allRows: WarningRecord[] = (res.result.rows || []).map((item: any) => ({
          ...item,
          id: String(item.id || ''),
        }));
        if (filterLevel) {
          allRows = allRows.filter(r => Number(r.warningLevel) === Number(filterLevel));
        }

        // ====== 本地计算精确统计 ======
        const pendingCount = allRows.filter(r => r.warningStatus === '01').length;
        const processedAll = allRows.filter(r => r.warningStatus !== '01').length;
        const totalDiff = allRows.reduce((sum, r) => sum + (Number(r.diffAmount) || 0), 0);
        const totalProfit = allRows.reduce((sum, r) => {
          const d = Number(r.diffAmount) || 0;
          return sum + (d > 0 ? d : 0);
        }, 0);
        const totalPayStandard = allRows.reduce((sum, r) => sum + (Number(r.drgPayStandard) || 0), 0);

        setStats({
          totalCount: allRows.length,
          pendingCount,
          processedCount: processedAll,
          totalDiff,
          totalProfit,
          totalPayStandard,
        });

        // ====== 前端分页展示 ======
        setTotal(allRows.length);
        const start = (currentPage - 1) * pageSize;
        const paged = allRows.slice(start, start + pageSize);
        setData(paged);
      } else {
        console.warn('[Records] records API error:', res.errorCode, res.errorMessage);
      }
    } catch (error) {
      console.error('[Records] 查询预警记录失败:', error);
    } finally {
      setLoading(false);
    }
  };

  // 当筛选条件变化时自动重新加载
  useEffect(() => {
    loadData();
  }, [filterStatus, filterType, filterKeyword, filterLevel, dateRange, pageSize, currentPage]);

  // 查看详情
  const handleView = (record: WarningRecord) => {
    setCurrentRecord(record);
    setDetailVisible(true);
  };

  // 执行查询
  const handleSearch = () => {
    setCurrentPage(1);
    loadData();
  };

  // 导出数据
  const handleExport = () => {
    message.success('数据导出功能开发中...');
  };

  // 重置筛选
  const handleReset = () => {
    setFilterStatus('');
    setFilterLevel('');
    setFilterType('');
    setFilterKeyword('');
    setDateRange(null);
    setCurrentPage(1);
    message.success('筛选条件已重置');
  };

  const columns: ColumnsType<WarningRecord> = [
    {
      title: '预警时间',
      dataIndex: 'warningDateTime',
      key: 'warningDateTime',
      width: 110,
      sorter: (a, b) => (a.warningDate || '').localeCompare(b.warningDate || ''),
      render: (val: string, record) => (
        <span>{val || `${fmtDate(record.warningDate)} ${record.warningTime || ''}`}</span>
      ),
    },
    {
      title: '级别',
      dataIndex: 'warningLevel',
      key: 'warningLevel',
      width: 65,
      render: (level: number) => (
        <Tag color={WARNING_LEVEL_COLORS[String(level)]}>
          {getDictLabel(warningLevelMap, String(level), String(level))}
        </Tag>
      ),
    },
    {
      title: '就诊ID',
      dataIndex: 'hisAdmId',
      key: 'hisAdmId',
      width: 100,
    },
    {
      title: '患者姓名',
      dataIndex: 'patientName',
      key: 'patientName',
      width: 90,
    },
    {
      title: '科室/医生',
      key: 'dept',
      width: 130,
      render: (_, record) => (
        <div>
          <div>{record.deptName || '-'}</div>
          <Text type="secondary" style={{ fontSize: 12 }}>
            {record.doctorName || '-'}
          </Text>
        </div>
      ),
    },
    {
      title: '预警类型',
      dataIndex: 'warningType',
      key: 'warningType',
      width: 100,
      render: (type: string) => (
        <Tag>{getDictLabel(warningTypeMap, type)}</Tag>
      ),
    },
    {
      title: '预警规则',
      key: 'rule',
      width: 170,
      render: (_, record) => (
        <div>
          <div>{record.ruleName}</div>
          <Text type="secondary" style={{ fontSize: 12 }}>
            {record.ruleCode}
          </Text>
        </div>
      ),
    },
    {
      title: 'DRG信息',
      key: 'drg',
      width: 130,
      render: (_, record) => (
        <div>
          <div>{record.drgCode}</div>
          <Text type="secondary" style={{ fontSize: 12 }}>
            {record.drgName || '-'}
          </Text>
        </div>
      ),
    },
    {
      title: '费用/标准',
      key: 'cost',
      width: 150,
      align: 'right',
      render: (_, record) => (
        <div>
          <div>¥{(record.totalFee || 0).toLocaleString()}</div>
          <Text type="secondary" style={{ fontSize: 12 }}>
            标准: ¥{(record.drgPayStandard || 0).toLocaleString()}
          </Text>
        </div>
      ),
    },
    {
      title: '超支/结余',
      key: 'balance',
      width: 130,
      align: 'right',
      render: (_, record) => {
        const diff = record.diffAmount || 0;
        const diffRate = record.diffRate || 0;
        return (
          <div>
            <Text type={diff < 0 ? 'danger' : 'success'} strong>
              ¥{diff.toLocaleString()}
            </Text>
            <div>
              <Text type={diffRate < 0 ? 'danger' : 'success'} style={{ fontSize: 12 }}>
                {diffRate > 0 ? '+' : ''}{diffRate}%
              </Text>
            </div>
          </div>
        );
      },
    },
    {
      title: '状态',
      dataIndex: 'warningStatus',
      key: 'warningStatus',
      width: 90,
      render: (status: string) => (
        <Tag color={WARNING_STATUS_COLORS[status] || 'default'}>
          {getDictLabel(warningStatusMap, status)}
        </Tag>
      ),
    },
    {
      title: '处理人',
      dataIndex: 'processUser',
      key: 'processUser',
      width: 90,
      render: (user: string) => user || '-',
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 80,
      render: (_, record) => (
        <Button
          type="link"
          size="small"
          icon={<EyeOutlined />}
          onClick={() => handleView(record)}
        >
          查看
        </Button>
      ),
    },
  ];

  return (
    <div style={{ padding: 16, height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* 统计卡片 */}
      <Row gutter={[16, 16]} style={{ marginBottom: 16 }}>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card size="small">
            <Statistic
              title="总记录数"
              value={stats.totalCount}
              prefix={<HistoryOutlined />}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card size="small">
            <Statistic
              title="待处理"
              value={stats.pendingCount}
              prefix={<ExclamationCircleOutlined />}
              valueStyle={{ color: '#faad14' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card size="small">
            <Statistic
              title="已处理"
              value={stats.processedCount}
              prefix={<CheckCircleOutlined />}
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card size="small">
            <Statistic
              title="总结余金额"
              value={stats.totalProfit || 0}
              precision={2}
              prefix={<RiseOutlined />}
              suffix="元"
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card size="small">
            <Statistic
              title="总标准费用"
              value={stats.totalPayStandard || 0}
              precision={2}
              prefix={<DollarOutlined />}
              suffix="元"
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={12} md={8} lg={4}>
          <Card size="small">
            <Statistic
              title="总超支金额"
              value={Math.abs(stats.totalDiff || 0)}
              precision={2}
              prefix={<CloseCircleOutlined />}
              suffix="元"
              valueStyle={{ color: (stats.totalDiff || 0) < 0 ? '#ff4d4f' : '#52c41a' }}
            />
          </Card>
        </Col>
      </Row>

      {/* 主内容区 */}
      <Card
        title={
          <Space>
            <HistoryOutlined />
            <span>预警处理记录</span>
          </Space>
        }
        extra={
          <Space>
            <Button icon={<DownloadOutlined />} onClick={handleExport}>
              导出Excel
            </Button>
          </Space>
        }
        style={{ flex: 1, display: 'flex', flexDirection: 'column' }}
        bodyStyle={{ height: '100%', padding: '16px 24px' }}
      >
        {/* 筛选栏 */}
        <Row gutter={[16, 16]} style={{ marginBottom: 16 }}>
          <Col xs={24} sm={12} md={6} lg={4}>
            <Input
              placeholder="就诊ID/患者姓名"
              prefix={<SearchOutlined />}
              value={filterKeyword}
              onChange={(e) => setFilterKeyword(e.target.value)}
              allowClear
            />
          </Col>
          <Col xs={24} sm={12} md={6} lg={4}>
            <RangePicker
              locale={zhCN}
              style={{ width: '100%' }}
              value={dateRange as any}
              onChange={(dates) => setDateRange(dates as [dayjs.Dayjs, dayjs.Dayjs] | null)}
              placeholder={['开始日期', '结束日期']}
            />
          </Col>
          <Col xs={24} sm={12} md={6} lg={3}>
            <Select
              placeholder="处理状态"
              style={{ width: '100%' }}
              allowClear
              value={filterStatus || undefined}
              onChange={setFilterStatus}
              options={warningStatusOptions}
            />
          </Col>
          <Col xs={24} sm={12} md={6} lg={3}>
            <Select
              placeholder="预警级别"
              style={{ width: '100%' }}
              allowClear
              value={filterLevel || undefined}
              onChange={setFilterLevel}
              options={warningLevelOptions}
            />
          </Col>
          <Col xs={24} sm={12} md={6} lg={3}>
            <Select
              placeholder="预警类型"
              style={{ width: '100%' }}
              allowClear
              value={filterType || undefined}
              onChange={setFilterType}
              options={warningTypeOptions}
            />
          </Col>
          <Col xs={24} sm={12} md={12} lg={4}>
            <Space>
              <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>查询</Button>
              <Button icon={<ReloadOutlined />} onClick={handleReset}>重置</Button>
            </Space>
          </Col>
        </Row>

        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1600, y: 'calc(100vh - 400px)' }}
          pagination={false}
        />
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <CustomPagination
            current={currentPage}
            pageSize={pageSize}
            total={total}
            onChange={(page: number, size: number) => {
              setCurrentPage(page);
              setPageSize(size || pageSize);
            }}
          />
        </div>
      </Card>

      {/* 详情弹窗 - 展示BS_DRGWarningRecord表全部字段 */}
      <Modal
        title="预警处理详情"
        open={detailVisible}
        onCancel={() => setDetailVisible(false)}
        footer={[
          <Button key="close" onClick={() => setDetailVisible(false)}>
            关闭
          </Button>,
        ]}
        width={850}
      >
        {currentRecord && (
          <div>
            {/* 标题区域 */}
            <div style={{ textAlign: 'center', marginBottom: 16 }}>
              <ExclamationCircleOutlined
                style={{
                  fontSize: 36,
                  color: currentRecord.warningLevel === 3 ? '#ff4d4f' :
                         currentRecord.warningLevel === 2 ? '#faad14' : '#52c41a',
                }}
              />
              <div style={{ marginTop: 8 }}>
                <Tag color={WARNING_LEVEL_COLORS[String(currentRecord.warningLevel)]}>
                  {getDictLabel(warningLevelMap, String(currentRecord.warningLevel))}级别
                </Tag>
                <Text strong style={{ fontSize: 16, display: 'block', marginTop: 8 }}>
                  {currentRecord.ruleName}
                </Text>
              </div>
            </div>

            {/* 预警标识信息 */}
            <Descriptions title="预警标识" bordered column={2} size="small">
              <Descriptions.Item label="预警流水号">{currentRecord.warningNo}</Descriptions.Item>
              <Descriptions.Item label="关联规则编码">{currentRecord.ruleCode}</Descriptions.Item>
              <Descriptions.Item label="预警类型">
                <Tag>{getDictLabel(warningTypeMap, currentRecord.warningType)}</Tag>
              </Descriptions.Item>
              <Descriptions.Item label="预警级别">
                <Tag color={WARNING_LEVEL_COLORS[String(currentRecord.warningLevel)]}>
                  {getDictLabel(warningLevelMap, String(currentRecord.warningLevel))}
                </Tag>
              </Descriptions.Item>
              <Descriptions.Item label="预警状态">
                <Tag color={WARNING_STATUS_COLORS[currentRecord.warningStatus]}>
                  {getDictLabel(warningStatusMap, currentRecord.warningStatus)}
                </Tag>
              </Descriptions.Item>
              <Descriptions.Item label="预警时间">{currentRecord.warningDateTime || `${fmtDate(currentRecord.warningDate)} ${currentRecord.warningTime || ''}`}</Descriptions.Item>
            </Descriptions>

            {/* 病案与患者信息 */}
            <Descriptions title="患者信息" bordered column={3} size="small" style={{ marginTop: 16 }}>
              <Descriptions.Item label="就诊ID">{currentRecord.hisAdmId}</Descriptions.Item>
              <Descriptions.Item label="患者姓名">{currentRecord.patientName}</Descriptions.Item>
              <Descriptions.Item label="病案ID">{currentRecord.medicalRecordDr || '-'}</Descriptions.Item>
            </Descriptions>

            {/* 科室与医生信息 */}
            <Descriptions title="科室医生" bordered column={2} size="small" style={{ marginTop: 16 }}>
              <Descriptions.Item label="科室">{currentRecord.deptName || '-'}（{currentRecord.deptCode || '-'}）</Descriptions.Item>
              <Descriptions.Item label="医生">{currentRecord.doctorName || '-'}（{currentRecord.doctorCode || '-'}）</Descriptions.Item>
            </Descriptions>

            {/* DRG分组信息 */}
            <Descriptions title="DRG分组" bordered column={2} size="small" style={{ marginTop: 16 }}>
              <Descriptions.Item label="DRG编码">{currentRecord.drgCode}</Descriptions.Item>
              <Descriptions.Item label="DRG名称">{currentRecord.drgName || '-'}</Descriptions.Item>
            </Descriptions>

            {/* 费用信息 */}
            <Descriptions title="费用信息" bordered column={3} size="small" style={{ marginTop: 16 }}>
              <Descriptions.Item label="医疗总费用">¥{(currentRecord.totalFee || 0).toLocaleString()}</Descriptions.Item>
              <Descriptions.Item label="医保结算费用">¥{(currentRecord.insuranceFee || 0).toLocaleString()}</Descriptions.Item>
              <Descriptions.Item label="DRG支付标准">¥{(currentRecord.drgPayStandard || 0).toLocaleString()}</Descriptions.Item>
              <Descriptions.Item label="费用差异">
                <Text type={(currentRecord.diffAmount || 0) < 0 ? 'danger' : 'success'} strong>
                  ¥{(currentRecord.diffAmount || 0).toLocaleString()}
                </Text>
              </Descriptions.Item>
              <Descriptions.Item label="差异率(%)" span={2}>
                <Text type={(currentRecord.diffRate || 0) < 0 ? 'danger' : 'success'} strong>
                  {(currentRecord.diffRate || 0) > 0 ? '+' : ''}{currentRecord.diffRate || 0}%
                </Text>
              </Descriptions.Item>
            </Descriptions>

            {/* 预警消息 */}
            {currentRecord.warningMessage && (
              <Descriptions title="预警消息" bordered column={1} size="small" style={{ marginTop: 16 }}>
                <Descriptions.Item label="消息内容">
                  <div style={{ whiteSpace: 'pre-wrap' }}>{currentRecord.warningMessage}</div>
                </Descriptions.Item>
              </Descriptions>
            )}

            {/* 机构信息 */}
            <Descriptions title="机构信息" bordered column={2} size="small" style={{ marginTop: 16 }}>
              <Descriptions.Item label="医疗机构名称">{currentRecord.fixmedinsName || '-'}</Descriptions.Item>
              <Descriptions.Item label="医疗机构代码">{currentRecord.fixmedinsCode || '-'}</Descriptions.Item>
            </Descriptions>

            {/* 处理信息 */}
            {(currentRecord.processUser || currentRecord.processDate || currentRecord.processRemark) && (
              <Descriptions title="处理信息" bordered column={2} size="small" style={{ marginTop: 16 }}>
                <Descriptions.Item label="处理人">{currentRecord.processUser || '-'}</Descriptions.Item>
                <Descriptions.Item label="处理时间">{currentRecord.processDateTime || `${fmtDate(currentRecord.processDate)} ${currentRecord.processTime || ''}`}</Descriptions.Item>
                {currentRecord.processRemark && (
                  <Descriptions.Item label="处理备注" span={2}>
                    {currentRecord.processRemark}
                  </Descriptions.Item>
                )}
              </Descriptions>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
};

export default Records;
