import React, { useState, useEffect } from 'react';
import {
  Card, Form, Input, Button, Table, Tag, Typography,
  Space, DatePicker, Select, message, Modal, Descriptions
} from 'antd';
import { SearchOutlined, ReloadOutlined, EyeOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { invoke } from '@/api/request';

const { Title, Text } = Typography;
const { RangePicker } = DatePicker;
const { Option } = Select;

/**
 * 分组结果查询页面
 * 对应后端接口: 02010036 - 查询DRG分组记录表
 * 对应数据表: BS_DRGGroupRecord (User.BSDRGGroupRecord)
 */

/** 后端返回的 BS_DRGGroupRecord 单条记录 */
interface GroupRecord {
  id: number;
  /** HIS唯一就诊ID（病案ID） */
  admID: string;
  /** 病案号 */
  medcasNo: string;
  /** 患者姓名 */
  patientName: string;
  /** 医保个人编号 */
  psnNo: string;
  /** 参保地 */
  insuranceAreaCode: string;
  /** 医保险种 */
  insuType: string;
  /** 性别 (1=男, 2=女) */
  sex: string;
  /** 年龄 */
  age: number;
  /** 主诊断代码 */
  mainDiagnosisCode: string;
  /** 主诊断名称 */
  mainDiagnosisName: string;
  /** 诊断类型编码 */
  diaTypeCode: string;
  /** 病种编码 */
  diagnosisCode: string;
  /** 病种名称 */
  diagnosisName: string;
  /** 主手术代码 */
  mainOperationCode: string;
  /** 主手术名称 */
  mainOperationName: string;
  /** DRG编码 */
  drg: string;
  /** DRG描述 */
  drgDesc: string;
  /** 权重 */
  weight: number;
  /** 基准费用 */
  benchmarkCost: number;
  /** CC标志 (1=有合并症) */
  ccFlag: string;
  /** MCC标志 (1=有严重合并症) */
  mccFlag: string;
  /** 分组时间 */
  groupTime: string;
  /** 分组阶段 (1=事前, 2=事中, 3=事后) */
  groupStage: string;
  /** 备注 */
  remark: string;
  /** HIS科室编码 */
  department: string;
  /** HIS科室名称 */
  departmentDesc: string;
  /** 医疗机构代码 */
  fixmedinsCode: string;
  /** 医疗机构名称 */
  fixmedinsName: string;
  /** 创建日期 */
  createDate: string;
  /** 创建时间 */
  createTime: string;
  /** 更新日期 */
  updateDate: string;
  /** 更新时间 */
  updateTime: string;
  /** 入院时间 */
  admDateTime: string;
  /** 出院时间 */
  discgDateTime: string;
  /** 结算时间 */
  settleDateTime: string;
}

/** 查询表单参数 */
interface SearchParams {
  patientName?: string;
  drg?: string;
  mainDiagnosisCode?: string;
  admID?: string;
  medcasNo?: string;
  department?: string;
  groupStage?: string;
  discgDateRange?: [any, any];
  admDateRange?: [any, any];
  settleDateRange?: [any, any];
  createDateRange?: [any, any];
}

const Results: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState<GroupRecord[]>([]);
  const [pagination, setPagination] = useState({
    current: 1,
    pageSize: 20,
    total: 0,
  });
  const [selectedRecord, setSelectedRecord] = useState<GroupRecord | null>(null);
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [form] = Form.useForm();

  /** 加载数据 - 调用 02010036 接口 */
  const loadData = async (searchParams: SearchParams = {}, page = 1, pageSize = 20) => {
    setLoading(true);
    try {
      // 构建请求参数（匹配后端 GroupDevice.QueryDRGGroupRecord 入参）
      const params: Record<string, string> = {};

      if (searchParams.admID) params.admID = searchParams.admID;
      if (searchParams.medcasNo) params.medcasNo = searchParams.medcasNo;
      if (searchParams.patientName) params.patientName = searchParams.patientName;
      if (searchParams.drg) params.drg = searchParams.drg;
      if (searchParams.mainDiagnosisCode) params.mainDiagnosisCode = searchParams.mainDiagnosisCode;
      if (searchParams.department) params.department = searchParams.department;
      if (searchParams.groupStage) params.groupStage = searchParams.groupStage;

      // 出院日期范围 → discgStartDate / discgEndDate
      if (searchParams.discgDateRange) {
        const [start, end] = searchParams.discgDateRange;
        if (start) params.discgStartDate = start.format('YYYY-MM-DD');
        if (end) params.discgEndDate = end.format('YYYY-MM-DD');
      }
      // 入院日期范围 → admStartDate / admEndDate
      if (searchParams.admDateRange) {
        const [start, end] = searchParams.admDateRange;
        if (start) params.admStartDate = start.format('YYYY-MM-DD');
        if (end) params.admEndDate = end.format('YYYY-MM-DD');
      }
      // 结算日期范围 → settleStartDate / settleEndDate
      if (searchParams.settleDateRange) {
        const [start, end] = searchParams.settleDateRange;
        if (start) params.settleStartDate = start.format('YYYY-MM-DD');
        if (end) params.settleEndDate = end.format('YYYY-MM-DD');
      }
      // 创建日期范围 → startDate / endDate
      if (searchParams.createDateRange) {
        const [start, end] = searchParams.createDateRange;
        if (start) params.startDate = start.format('YYYY-MM-DD');
        if (end) params.endDate = end.format('YYYY-MM-DD');
      }

      const result = await invoke(
        '02010036',
        [params],
        undefined,
        { pageSize, currentPage: page }
      );

      if (result.errorCode === '0') {
        setData(result.result?.rows || []);
        setPagination({
          current: page,
          pageSize,
          total: result.result?.total || 0,
        });
      } else {
        message.error(result.errorMessage || '查询失败');
        setData([]);
      }
    } catch (error: any) {
      message.error(error.message || '加载数据失败');
      setData([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  /** 查询 */
  const handleSearch = (values: SearchParams) => {
    loadData(values, 1, pagination.pageSize);
  };

  /** 重置 */
  const handleReset = () => {
    form.resetFields();
    loadData();
  };

  /** 查看详情 */
  const handleViewDetail = (record: GroupRecord) => {
    setSelectedRecord(record);
    setDetailModalOpen(true);
  };

  /** 分页变化 */
  const handleTableChange = (paginationConfig: any) => {
    const searchValues = form.getFieldsValue();
    loadData(searchValues, paginationConfig.current, paginationConfig.pageSize);
  };

  /** 性别显示 */
  const renderSex = (sex: string) => (sex === '1' ? '男' : sex === '2' ? '女' : sex || '-');

  /** 分组阶段显示 */
  const renderGroupStage = (stage: string) => {
    const map: Record<string, { label: string; color: string }> = {
      '1': { label: '事前', color: 'blue' },
      '2': { label: '事中', color: 'orange' },
      '3': { label: '事后', color: 'green' },
    };
    const item = map[stage];
    return item ? <Tag color={item.color}>{item.label}</Tag> : stage || '-';
  };

  /** CC/MCC标志合并显示 */
  const renderComplicationFlag = (ccFlag: string, mccFlag: string) => {
    if (mccFlag === '1') return <Tag color="red">MCC（严重合并症）</Tag>;
    if (ccFlag === '1') return <Tag color="orange">CC（合并症）</Tag>;
    return <Tag>无</Tag>;
  };

  const columns: ColumnsType<GroupRecord> = [
    { title: '就诊ID', dataIndex: 'admID', key: 'admID', width: 130, ellipsis: true },
    { title: '姓名', dataIndex: 'patientName', key: 'patientName', width: 80 },
    { title: '病案号', dataIndex: 'medcasNo', key: 'medcasNo', width: 110 },
    {
      title: 'DRG编码',
      key: 'drg',
      width: 150,
      render: (_, record) => (
        <Space direction="vertical" size={0}>
          <Tag color="blue">{record.drg}</Tag>
          <Text style={{ fontSize: 12 }} ellipsis={{ tooltip: record.drgDesc }}>
            {record.drgDesc}
          </Text>
        </Space>
      ),
    },
    {
      title: '主诊断',
      key: 'diagnosis',
      width: 180,
      render: (_, record) => (
        <Space direction="vertical" size={0}>
          <Text style={{ fontSize: 12 }} type="secondary">{record.mainDiagnosisCode}</Text>
          <Text style={{ fontSize: 12 }} ellipsis={{ tooltip: record.mainDiagnosisName }}>
            {record.mainDiagnosisName || '-'}
          </Text>
        </Space>
      ),
    },
    {
      title: '权重',
      dataIndex: 'weight',
      key: 'weight',
      width: 70,
      render: (val: number) => val != null ? val.toFixed(2) : '-',
    },
    {
      title: '基准费用',
      dataIndex: 'benchmarkCost',
      key: 'benchmarkCost',
      width: 100,
      render: (cost: number) =>
        cost != null ? `¥${cost.toLocaleString()}` : '-',
    },
    {
      title: '合并症',
      key: 'complication',
      width: 120,
      render: (_, record) => renderComplicationFlag(record.ccFlag, record.mccFlag),
    },
    {
      title: '科室',
      dataIndex: 'departmentDesc',
      key: 'departmentDesc',
      width: 100,
      ellipsis: true,
    },
    {
      title: '分组阶段',
      dataIndex: 'groupStage',
      key: 'groupStage',
      width: 80,
      render: (val: string) => renderGroupStage(val),
    },
    {
      title: '分组时间',
      dataIndex: 'groupTime',
      key: 'groupTime',
      width: 160,
    },
    {
      title: '操作',
      key: 'action',
      width: 70,
      fixed: 'right',
      render: (_, record) => (
        <Button
          type="link"
          size="small"
          icon={<EyeOutlined />}
          onClick={() => handleViewDetail(record)}
        >
          详情
        </Button>
      ),
    },
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
          style={{ marginBottom: 16, flexWrap: 'wrap', rowGap: 8 }}
        >
          <Form.Item name="patientName" label="患者姓名">
            <Input placeholder="姓名" style={{ width: 120 }} allowClear />
          </Form.Item>
          <Form.Item name="admID" label="就诊ID">
            <Input placeholder="就诊ID" style={{ width: 130 }} allowClear />
          </Form.Item>
          <Form.Item name="medcasNo" label="病案号">
            <Input placeholder="病案号" style={{ width: 120 }} allowClear />
          </Form.Item>
          <Form.Item name="drg" label="DRG编码">
            <Input placeholder="DRG编码" style={{ width: 100 }} allowClear />
          </Form.Item>
          <Form.Item name="mainDiagnosisCode" label="主诊断">
            <Input placeholder="主诊断编码" style={{ width: 120 }} allowClear />
          </Form.Item>
          <Form.Item name="department" label="科室">
            <Input placeholder="科室编码" style={{ width: 100 }} allowClear />
          </Form.Item>
          <Form.Item name="groupStage" label="分组阶段">
            <Select placeholder="全部" style={{ width: 90 }} allowClear>
              <Option value="1">事前</Option>
              <Option value="2">事中</Option>
              <Option value="3">事后</Option>
            </Select>
          </Form.Item>
          <Form.Item name="discgDateRange" label="出院日期">
            <RangePicker style={{ width: 240 }} />
          </Form.Item>
          <Form.Item name="admDateRange" label="入院日期">
            <RangePicker style={{ width: 240 }} />
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
          scroll={{ x: 1500 }}
          size="small"
        />
      </Card>

      {/* 详情弹窗 */}
      <Modal
        title="分组记录详情"
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        width={900}
        destroyOnClose
      >
        {selectedRecord && (
          <>
            {/* 基础信息 */}
            <Title level={5} style={{ marginTop: 0 }}>基础信息</Title>
            <Descriptions bordered column={3} size="small" style={{ marginBottom: 16 }}>
              <Descriptions.Item label="就诊ID">{selectedRecord.admID || '-'}</Descriptions.Item>
              <Descriptions.Item label="患者姓名">{selectedRecord.patientName || '-'}</Descriptions.Item>
              <Descriptions.Item label="病案号">{selectedRecord.medcasNo || '-'}</Descriptions.Item>
              <Descriptions.Item label="医保编号">{selectedRecord.psnNo || '-'}</Descriptions.Item>
              <Descriptions.Item label="性别">{renderSex(selectedRecord.sex)}</Descriptions.Item>
              <Descriptions.Item label="年龄">{selectedRecord.age != null ? selectedRecord.age : '-'}</Descriptions.Item>
              <Descriptions.Item label="参保地">{selectedRecord.insuranceAreaCode || '-'}</Descriptions.Item>
              <Descriptions.Item label="险种">{selectedRecord.insuType || '-'}</Descriptions.Item>
              <Descriptions.Item label="诊断类型">{selectedRecord.diaTypeCode || '-'}</Descriptions.Item>
            </Descriptions>

            {/* 诊断/手术信息 */}
            <Title level={5}>诊断与手术信息</Title>
            <Descriptions bordered column={2} size="small" style={{ marginBottom: 16 }}>
              <Descriptions.Item label="主诊断编码">
                <Tag color="blue">{selectedRecord.mainDiagnosisCode || '-'}</Tag>
              </Descriptions.Item>
              <Descriptions.Item label="主诊断名称">
                <Text>{selectedRecord.mainDiagnosisName || '-'}</Text>
              </Descriptions.Item>
              <Descriptions.Item label="病种编码">{selectedRecord.diagnosisCode || '-'}</Descriptions.Item>
              <Descriptions.Item label="病种名称">{selectedRecord.diagnosisName || '-'}</Descriptions.Item>
              <Descriptions.Item label="主手术编码">{selectedRecord.mainOperationCode || '-'}</Descriptions.Item>
              <Descriptions.Item label="主手术名称">{selectedRecord.mainOperationName || '-'}</Descriptions.Item>
            </Descriptions>

            {/* DRG分组结果 */}
            <Title level={5}>DRG分组结果</Title>
            <Descriptions bordered column={3} size="small" style={{ marginBottom: 16 }}>
              <Descriptions.Item label="DRG编码">
                <Tag color="blue">{selectedRecord.drg || '-'}</Tag>
              </Descriptions.Item>
              <Descriptions.Item label="DRG名称" span={2}>
                <Text>{selectedRecord.drgDesc || '-'}</Text>
              </Descriptions.Item>
              <Descriptions.Item label="权重">
                {selectedRecord.weight != null ? selectedRecord.weight.toFixed(4) : '-'}
              </Descriptions.Item>
              <Descriptions.Item label="基准费用">
                {selectedRecord.benchmarkCost != null ? `¥${selectedRecord.benchmarkCost.toLocaleString()}` : '-'}
              </Descriptions.Item>
              <Descriptions.Item label="分组阶段">
                {renderGroupStage(selectedRecord.groupStage)}
              </Descriptions.Item>
              <Descriptions.Item label="CC标志">
                {selectedRecord.ccFlag === '1' ? <Tag color="orange">有合并症</Tag> : <Tag>无</Tag>}
              </Descriptions.Item>
              <Descriptions.Item label="MCC标志">
                {selectedRecord.mccFlag === '1' ? <Tag color="red">有严重合并症</Tag> : <Tag>无</Tag>}
              </Descriptions.Item>
              <Descriptions.Item label="分组时间">{selectedRecord.groupTime || '-'}</Descriptions.Item>
            </Descriptions>

            {/* 科室与机构信息 */}
            <Title level={5}>科室与机构信息</Title>
            <Descriptions bordered column={2} size="small" style={{ marginBottom: 16 }}>
              <Descriptions.Item label="科室编码">{selectedRecord.department || '-'}</Descriptions.Item>
              <Descriptions.Item label="科室名称">{selectedRecord.departmentDesc || '-'}</Descriptions.Item>
              <Descriptions.Item label="机构代码">{selectedRecord.fixmedinsCode || '-'}</Descriptions.Item>
              <Descriptions.Item label="机构名称">{selectedRecord.fixmedinsName || '-'}</Descriptions.Item>
            </Descriptions>

            {/* 时间信息 */}
            <Title level={5}>时间信息</Title>
            <Descriptions bordered column={3} size="small" style={{ marginBottom: 16 }}>
              <Descriptions.Item label="入院时间">{selectedRecord.admDateTime || '-'}</Descriptions.Item>
              <Descriptions.Item label="出院时间">{selectedRecord.discgDateTime || '-'}</Descriptions.Item>
              <Descriptions.Item label="结算时间">{selectedRecord.settleDateTime || '-'}</Descriptions.Item>
              <Descriptions.Item label="创建日期">{selectedRecord.createDate || '-'}</Descriptions.Item>
              <Descriptions.Item label="创建时间">{selectedRecord.createTime || '-'}</Descriptions.Item>
              <Descriptions.Item label="更新时间">
                {selectedRecord.updateDate ? `${selectedRecord.updateDate} ${selectedRecord.updateTime || ''}` : '-'}
              </Descriptions.Item>
            </Descriptions>

            {/* 备注 */}
            {selectedRecord.remark && (
              <>
                <Title level={5}>备注</Title>
                <Card size="small" style={{ backgroundColor: '#fafafa' }}>
                  <Text style={{ whiteSpace: 'pre-wrap' }}>{selectedRecord.remark}</Text>
                </Card>
              </>
            )}
          </>
        )}
      </Modal>
    </div>
  );
};

export default Results;
