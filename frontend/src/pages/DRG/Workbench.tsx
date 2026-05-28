import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Button,
  Input,
  Select,
  DatePicker,
  Form,
  Row,
  Col,
  Space,
  Tag,
  Modal,
  Descriptions,
  message,
  Popconfirm,
  Typography,
  Badge,
  Tooltip,
  Alert,
  Spin,
  Divider,
  List,
  Statistic,
  Progress
} from 'antd';
import {
  SearchOutlined,
  ReloadOutlined,
  PlayCircleOutlined,
  SaveOutlined,
  EyeOutlined,
  HistoryOutlined,
  FileTextOutlined,
  MedicineBoxOutlined,
  ScissorOutlined,
  UserOutlined,
  CalendarOutlined,
  DollarOutlined,
  AlertFilled,
  CheckCircleFilled,
  CloseCircleFilled
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import request from '../../api/request';
import dayjs from 'dayjs';
import { drgGroup, convertResultToLowerCamel, type DRGGroupResultLowerCamel } from '@/api/drgGrouping';
import CustomPagination from '../../components/CustomPagination';
import { useDict } from '../../hooks/useDict';
import { getDictLabel } from '../../utils/dict';

const { Title, Text } = Typography;
const { RangePicker } = DatePicker;
const { Option } = Select;

// 工作台分组状态映射（含图标，值码与业务数据一致）
const WORKBENCH_GROUP_STATUS_MAP: Record<string, { color: string; text: string; icon: React.ReactNode }> = {
  ungrouped: { color: 'default', text: '未分组', icon: <AlertFilled /> },
  grouped: { color: 'success', text: '已分组', icon: <CheckCircleFilled /> },
  failed: { color: 'error', text: '失败', icon: <CloseCircleFilled /> },
};

// 病案数据类型
interface MedicalRecord {
  id: string;
  admissionNo: string;
  patientName: string;
  sex: string;
  age: number;
  department: string;
  admissionDate: string;
  dischargeDate: string;
  hospitalDays: number;
  totalCost: number;
  mainDiagnosisCode: string;
  mainDiagnosisName: string;
  mainOperationCode: string;
  mainOperationName: string;
  drgGroupStatus: 'ungrouped' | 'grouped' | 'failed';
  drgCode?: string;
  drgName?: string;
  groupTime?: string;
}

// 使用统一的DRG分组结果类型
type DRGGroupResult = DRGGroupResultLowerCamel;

// 诊断信息
interface DiagnosisInfo {
  mainFlag: number;
  diagSn: number;
  diagCode: string;
  diagName: string;
}

// 手术信息
interface OperationInfo {
  mainFlag: string;
  oprnSn: number;
  oprnCode: string;
  oprnName: string;
}

const Workbench: React.FC = () => {
  // 字典数据
  const { options: sexOptions, map: sexMap } = useDict('SEX');
  const { options: dischargeTypeOptions } = useDict('DISCHARGE_TYPE');
  const { options: yesNoOptions } = useDict('YES_NO_FLAG');

  // 状态定义
  const [loading, setLoading] = useState(false);
  const [grouping, setGrouping] = useState(false);
  const [data, setData] = useState<MedicalRecord[]>([]);
  const [selectedRecord, setSelectedRecord] = useState<MedicalRecord | null>(null);
  const [groupModalVisible, setGroupModalVisible] = useState(false);
  const [detailModalVisible, setDetailModalVisible] = useState(false);
  const [groupResult, setGroupResult] = useState<DRGGroupResult | null>(null);
  const [searchForm] = Form.useForm();
  const [groupForm] = Form.useForm();
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [diagnoses, setDiagnoses] = useState<DiagnosisInfo[]>([]);
  const [operations, setOperations] = useState<OperationInfo[]>([]);
  const [statistics, setStatistics] = useState({
    total: 0,
    ungrouped: 0,
    grouped: 0,
    failed: 0
  });

  // 获取病案列表
  const fetchData = async (page = 1, pageSize = 10) => {
    setLoading(true);
    try {
      const values = searchForm.getFieldsValue();
      const params: any = {
        page,
        limit: pageSize,
        groupStatus: values.groupStatus
      };

      if (values.admissionNo) params.admissionNo = values.admissionNo;
      if (values.patientName) params.patientName = values.patientName;
      if (values.department) params.department = values.department;
      if (values.dateRange && values.dateRange.length === 2) {
        params.startDate = values.dateRange[0].format('YYYY-MM-DD');
        params.endDate = values.dateRange[1].format('YYYY-MM-DD');
      }

      // 调用查询病案接口
      const res: any = await request('/api/medicalRecord/list', {
        method: 'POST',
        data: params
      });

      if (res.errorCode === '0' || res.errorCode === '00') {
        setData(res.result?.rows || []);
        setPagination({
          current: page,
          pageSize,
          total: res.result?.total || 0
        });
        // 更新统计
        updateStatistics(res.result?.rows || []);
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch (error) {
      message.error('查询病案列表失败');
    } finally {
      setLoading(false);
    }
  };

  // 更新统计
  const updateStatistics = (records: MedicalRecord[]) => {
    const stats = {
      total: records.length,
      ungrouped: records.filter(r => r.drgGroupStatus === 'ungrouped').length,
      grouped: records.filter(r => r.drgGroupStatus === 'grouped').length,
      failed: records.filter(r => r.drgGroupStatus === 'failed').length
    };
    setStatistics(stats);
  };

  // 测试IRIS接口调用
  const testApiCall = async () => {
    try {
      message.loading('正在调用IRIS接口...', 0);
      
      // 构造测试参数
      const testParams = {
        MainDiagnosisCode: '',
        MainOperationCode: '',
        Sex: '1',
        Age: 0,
        AgeGroupDays: 0,
        NewbornFlag: '0',
        RespiratorTime: 0,
        ECMOFlag: '0',
        TransplantFlag: '0',
        MarrowTransplantFlag: '0',
        HIVFlag: '0',
        TraumaLevel: 0
      };

      console.log('【IRIS接口测试】请求参数:', { code: '02010001', params: [testParams] });

      const res: any = await request({
        url: '/invoke',
        method: 'POST',
        data: {
          code: '02010001',
          params: [testParams]
        }
      });

      message.destroy();
      console.log('【IRIS接口测试】响应结果:', res);

      Modal.success({
        title: 'IRIS接口调用成功',
        width: 700,
        content: (
          <div style={{ maxHeight: 400, overflow: 'auto' }}>
            <pre style={{ background: '#f6f8fa', padding: 12, borderRadius: 6, fontSize: 12 }}>
              {JSON.stringify(res, null, 2)}
            </pre>
          </div>
        ),
        okText: '关闭'
      });
    } catch (error: any) {
      message.destroy();
      console.error('【IRIS接口测试】调用失败:', error);
      
      Modal.error({
        title: 'IRIS接口调用失败',
        width: 600,
        content: (
          <div>
            <p>错误信息: {error.message || '未知错误'}</p>
            <p style={{ color: '#999', fontSize: 12 }}>请检查:</p>
            <ul style={{ color: '#999', fontSize: 12 }}>
              <li>IRIS服务是否启动 (端口52773)</li>
              <li>网络连接是否正常</li>
              <li>Nginx代理是否配置正确</li>
            </ul>
          </div>
        ),
        okText: '关闭'
      });
    }
  };

  // 执行DRG分组
  const handleGroup = async (record: MedicalRecord) => {
    setSelectedRecord(record);
    setGroupModalVisible(true);
    setGroupResult(null);

    // 初始化诊断和手术信息
    const initDiagnoses: DiagnosisInfo[] = [
      {
        mainFlag: 1,
        diagSn: 1,
        diagCode: record.mainDiagnosisCode || '',
        diagName: record.mainDiagnosisName || ''
      }
    ];
    const initOperations: OperationInfo[] = record.mainOperationCode ? [
      {
        mainFlag: '1',
        oprnSn: 1,
        oprnCode: record.mainOperationCode,
        oprnName: record.mainOperationName || ''
      }
    ] : [];

    setDiagnoses(initDiagnoses);
    setOperations(initOperations);

    // 设置表单初始值
    groupForm.setFieldsValue({
      mainDiagnosisCode: record.mainDiagnosisCode,
      mainOperationCode: record.mainOperationCode,
      sex: record.sex,
      age: record.age,
      department: record.department,
      hospitalDays: record.hospitalDays,
      totalCost: record.totalCost,
      newbornFlag: '0',
      ecmoFlag: '0',
      transplantFlag: '0',
      marrowTransplantFlag: '0',
      hivFlag: '0',
      traumaLevel: 0,
      respiratorTime: 0,
      ageGroupDays: 0,
      dischargeType: '1' // 默认值：1-医嘱离院
    });
  };

  // 提交分组
  const submitGroup = async () => {
    try {
      const values = await groupForm.validateFields();
      setGrouping(true);

      // 构建入参
      const params: any = {
        mainDiagnosisCode: values.mainDiagnosisCode,
        sex: values.sex,
        age: values.age,
        department: values.department,
        hospitalDays: values.hospitalDays,
        totalCost: values.totalCost,
        newbornFlag: values.newbornFlag || '0',
        ecmoFlag: values.ecmoFlag || '0',
        transplantFlag: values.transplantFlag || '0',
        marrowTransplantFlag: values.marrowTransplantFlag || '0',
        hivFlag: values.hivFlag || '0',
        traumaLevel: values.traumaLevel || 0,
        respiratorTime: values.respiratorTime || 0,
        ageGroupDays: values.ageGroupDays || 0,
        dischargeType: values.dischargeType || '1' // 离院方式，默认1-医嘱离院
      };

      if (values.mainOperationCode) {
        params.mainOperationCode = values.mainOperationCode;
      }

      // 添加诊断信息
      const validDiagnoses = diagnoses.filter(d => d.diagCode && d.diagCode.trim() !== '');
      if (validDiagnoses.length > 0) {
        params.diseInfo = validDiagnoses;
      }

      // 添加手术信息
      const validOperations = operations.filter(o => o.oprnCode && o.oprnCode.trim() !== '');
      if (validOperations.length > 0) {
        params.oprnInfo = validOperations;
      }

      // 调用DRG分组接口 02010001，使用统一的drgGroup函数
      const res = await drgGroup(params);
      
      if (res.errorCode === '0' || res.errorCode === '00') {
        // 转换为小驼峰格式
        const lowerResult = convertResultToLowerCamel(res);
        setGroupResult(lowerResult);
        message.success('分组成功');

        // 自动保存分组记录
        if (selectedRecord) {
          await saveGroupRecord(lowerResult);
        }
      } else {
        message.error(res.errorMessage || '分组失败');
        setGroupResult({
          errorCode: res.errorCode,
          errorMessage: res.errorMessage,
          code: '',
          desc: '',
          mdc: '',
          mdcDesc: '',
          drg: '',
          drgDesc: '',
          weight: 0,
          benchmarkCost: 0,
          ccFlag: false,
          mccFlag: false,
          riskLevel: '低',
          checkTime: dayjs().format('YYYY-MM-DD HH:mm:ss')
        });
      }
    } catch (error: any) {
      message.error(error.message || '分组失败');
    } finally {
      setGrouping(false);
    }
  };

  // 保存分组记录 - 入参与后端接口匹配
  const saveGroupRecord = async (result: DRGGroupResult) => {
    if (!selectedRecord) return;

    try {
      // 构建与后端接口匹配的入参（使用后端字段名）
      const params = {
        // 基础信息
        AdmID: selectedRecord.id,                    // HIS唯一就诊ID
        MedcasNo: selectedRecord.admissionNo,        // 病案号
        PatientName: selectedRecord.patientName,     // 患者姓名
        Sex: selectedRecord.sex,                     // 性别
        Age: selectedRecord.age,                     // 年龄
        Department: selectedRecord.department,       // 科室
        
        // 诊断信息
        MainDiagnosisCode: selectedRecord.mainDiagnosisCode,   // 主诊断代码
        MainDiagnosisName: selectedRecord.mainDiagnosisName,   // 主诊断名称
        MainOperationCode: selectedRecord.mainOperationCode,   // 主手术代码
        MainOperationName: selectedRecord.mainOperationName,   // 主手术名称
        
        // DRG分组结果（根据新结构调整）
        MDC: result.mdc,                             // MDC编码
        MDCDesc: result.mdcDesc,                     // MDC描述
        DRG: result.drg,                             // DRG编码
        DRGDesc: result.drgDesc,                     // DRG描述
        CCFlag: result.ccFlag ? '1' : '0',           // CC标志
        Complication: result.complicationInfo?.[0]?.complication || '',     // 合并症标识
        ComplicationDesc: result.complicationInfo?.[0]?.complicationDesc || '', // 合并症描述
        GroupTime: result.checkTime                  // 分组时间
      };

      await request('/api/drg/saveRecord', {
        method: 'POST',
        data: {
          code: '02010035',
          params: [params]
        }
      });

      // 刷新列表
      fetchData(pagination.current, pagination.pageSize);
    } catch (error) {
      console.error('保存分组记录失败:', error);
    }
  };

  // 查看详情
  const viewDetail = (record: MedicalRecord) => {
    setSelectedRecord(record);
    setDetailModalVisible(true);
  };

  // 重置搜索
  const handleReset = () => {
    searchForm.resetFields();
    fetchData(1, pagination.pageSize);
  };

  // 表格列定义
  const columns: ColumnsType<MedicalRecord> = [
    {
      title: '病案号',
      dataIndex: 'admissionNo',
      width: 120,
      fixed: 'left',
      render: (text) => <Text strong>{text}</Text>
    },
    {
      title: '患者姓名',
      dataIndex: 'patientName',
      width: 90
    },
    {
      title: '性别',
      dataIndex: 'sex',
      width: 50,
      render: (text) => getDictLabel(sexMap, text, '-')
    },
    {
      title: '年龄',
      dataIndex: 'age',
      width: 50,
      render: (text) => `${text}岁`
    },
    {
      title: '科室',
      dataIndex: 'department',
      width: 100
    },
    {
      title: '入院日期',
      dataIndex: 'admissionDate',
      width: 100
    },
    {
      title: '出院日期',
      dataIndex: 'dischargeDate',
      width: 100
    },
    {
      title: '住院天数',
      dataIndex: 'hospitalDays',
      width: 70
    },
    {
      title: '总费用',
      dataIndex: 'totalCost',
      width: 90,
      render: (text) => `¥${text?.toFixed(2) || '0.00'}`
    },
    {
      title: '主诊断',
      dataIndex: 'mainDiagnosisCode',
      width: 120,
      render: (code, record) => (
        <Tooltip title={record.mainDiagnosisName}>
          <Tag color="blue">{code}</Tag>
        </Tooltip>
      )
    },
    {
      title: '主诊断名称',
      dataIndex: 'mainDiagnosisName',
      ellipsis: true
    },
    {
      title: '主手术',
      dataIndex: 'mainOperationCode',
      width: 120,
      render: (code, record) => (
        code ? (
          <Tooltip title={record.mainOperationName}>
            <Tag color="cyan">{code}</Tag>
          </Tooltip>
        ) : '-'
      )
    },
    {
      title: '分组状态',
      dataIndex: 'drgGroupStatus',
      width: 80,
      render: (status) => {
        const config = WORKBENCH_GROUP_STATUS_MAP[status] || WORKBENCH_GROUP_STATUS_MAP.ungrouped;
        return <Badge status={config.color as any} text={config.text} />;
      }
    },
    {
      title: 'DRG编码',
      dataIndex: 'drgCode',
      width: 80,
      render: (text) => text ? <Tag color="green">{text}</Tag> : '-'
    },
    {
      title: '权重',
      dataIndex: 'drgWeight',
      width: 60,
      render: (text) => text || '-'
    },
    {
      title: '操作',
      key: 'action',
      width: 150,
      fixed: 'right',
      render: (_, record) => (
        <Space size="small">
          <Button
            type="primary"
            size="small"
            icon={<PlayCircleOutlined />}
            onClick={() => handleGroup(record)}
          >
            分组
          </Button>
          <Button
            size="small"
            icon={<EyeOutlined />}
            onClick={() => viewDetail(record)}
          >
            查看
          </Button>
        </Space>
      )
    }
  ];

  // 初始加载
  useEffect(() => {
    fetchData();
  }, []);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%', width: '100%', gap: 0, background: '#fff', padding: 16 }}>
      {/* 统计卡片 */}
      <div style={{ marginBottom: 16 }}>
        <Row gutter={16} style={{ flexShrink: 0, marginBottom: 0 }}>
        <Col span={6}>
          <Card>
            <Statistic
              title="总病案数"
              value={statistics.total}
              prefix={<FileTextOutlined />}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="未分组"
              value={statistics.ungrouped}
              valueStyle={{ color: '#cf1322' }}
              prefix={<AlertFilled />}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="已分组"
              value={statistics.grouped}
              valueStyle={{ color: '#3f8600' }}
              prefix={<CheckCircleFilled />}
            />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic
              title="分组失败"
              value={statistics.failed}
              valueStyle={{ color: '#faad14' }}
              prefix={<CloseCircleFilled />}
            />
          </Card>
        </Col>
      </Row>
      </div>

      {/* 查询条件 */}
      <div style={{ marginBottom: 8 }}>
      <Card size="small" style={{ flexShrink: 0, marginBottom: 0 }}>
        <Form form={searchForm} layout="inline">
          <Row gutter={16} style={{ width: '100%' }}>
            <Col span={5}>
              <Form.Item name="admissionNo" label="病案号">
                <Input placeholder="请输入病案号" allowClear />
              </Form.Item>
            </Col>
            <Col span={5}>
              <Form.Item name="patientName" label="患者姓名">
                <Input placeholder="请输入患者姓名" allowClear />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="department" label="科室">
                <Input placeholder="请输入科室" allowClear />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="groupStatus" label="分组状态">
                <Select placeholder="全部状态" allowClear
                  options={Object.entries(WORKBENCH_GROUP_STATUS_MAP).map(([k, v]) => ({ value: k, label: v.text }))}
                />
              </Form.Item>
            </Col>
            <Col span={6}>
              <Form.Item name="dateRange" label="出院日期">
                <RangePicker style={{ width: '100%' }} />
              </Form.Item>
            </Col>
          </Row>
          <Row style={{ marginTop: 16 }}>
            <Col span={24} style={{ textAlign: 'right' }}>
              <Space>
                <Button type="primary" icon={<SearchOutlined />} onClick={() => fetchData(1, pagination.pageSize)}>
                  查询
                </Button>
                <Button icon={<ReloadOutlined />} onClick={handleReset}>
                  重置
                </Button>
                <Button type="dashed" icon={<PlayCircleOutlined />} onClick={testApiCall} style={{ color: '#52c41a', borderColor: '#52c41a' }}>
                  测试IRIS接口
                </Button>
              </Space>
            </Col>
          </Row>
        </Form>
      </Card>
      </div>

      {/* 数据表格 */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <Card style={{ flex: 1, display: 'flex', flexDirection: 'column', width: '100%' }} styles={{ body: { flex: 1, padding: '12px', display: 'flex', flexDirection: 'column' } }}>
        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          size="small"
          scroll={{ y: 'calc(100vh - 420px)' }}
          style={{ flex: 1, width: '100%' }}
          pagination={false}
        />
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <CustomPagination
            current={pagination.current}
            pageSize={pagination.pageSize}
            total={pagination.total}
            onChange={(page, pageSize) => fetchData(page, pageSize || 10)}
          />
        </div>
      </Card>
      </div>

      {/* 分组弹窗 */}
      <Modal
        title={<Space><PlayCircleOutlined /> DRG分组</Space>}
        open={groupModalVisible}
        onCancel={() => setGroupModalVisible(false)}
        width={900}
        footer={[
          <Button key="cancel" onClick={() => setGroupModalVisible(false)}>
            关闭
          </Button>,
          <Button
            key="submit"
            type="primary"
            icon={<PlayCircleOutlined />}
            loading={grouping}
            onClick={submitGroup}
          >
            执行分组
          </Button>
        ]}
      >
        {selectedRecord && (
          <div>
            <Alert
              message="病案信息"
              description={
                <Space>
                  <span><UserOutlined /> {selectedRecord.patientName}</span>
                  <span>{getDictLabel(sexMap, selectedRecord.sex, '-')}</span>
                  <span>{selectedRecord.age}岁</span>
                  <span><MedicineBoxOutlined /> {selectedRecord.department}</span>
                  <span><CalendarOutlined /> {selectedRecord.hospitalDays}天</span>
                  <span><DollarOutlined /> ¥{selectedRecord.totalCost?.toFixed(2)}</span>
                </Space>
              }
              type="info"
              style={{ marginBottom: 16 }}
            />

            <Form form={groupForm} layout="vertical">
              <Row gutter={16}>
                <Col span={12}>
                  <Form.Item
                    name="mainDiagnosisCode"
                    label="主诊断代码"
                    rules={[{ required: true, message: '请输入主诊断代码' }]}
                  >
                    <Input placeholder="ICD-10编码" />
                  </Form.Item>
                </Col>
                <Col span={12}>
                  <Form.Item name="mainOperationCode" label="主手术代码">
                    <Input placeholder="ICD-9-CM-3编码（可选）" />
                  </Form.Item>
                </Col>
              </Row>

              <Row gutter={16}>
                <Col span={8}>
                  <Form.Item name="sex" label="性别">
                    <Select options={sexOptions} />
                  </Form.Item>
                </Col>
                <Col span={8}>
                  <Form.Item name="age" label="年龄">
                    <Input type="number" min={0} max={150} />
                  </Form.Item>
                </Col>
                <Col span={8}>
                  <Form.Item name="hospitalDays" label="住院天数">
                    <Input type="number" min={1} />
                  </Form.Item>
                </Col>
                <Col span={8}>
                  <Form.Item 
                    name="dischargeType" 
                    label="离院方式"
                    rules={[{ required: true, message: '请选择离院方式' }]}
                  >
                    <Select options={dischargeTypeOptions} />
                  </Form.Item>
                </Col>
              </Row>

              <Row gutter={16}>
                <Col span={8}>
                  <Form.Item name="newbornFlag" label="新生儿标志">
                    <Select options={yesNoOptions} />
                  </Form.Item>
                </Col>
                <Col span={8}>
                  <Form.Item name="ecmoFlag" label="ECMO标志">
                    <Select options={yesNoOptions} />
                  </Form.Item>
                </Col>
                <Col span={8}>
                  <Form.Item name="hivFlag" label="HIV标志">
                    <Select options={yesNoOptions} />
                  </Form.Item>
                </Col>
              </Row>
            </Form>

            {/* 分组结果 */}
            {groupResult && (
              <div style={{ marginTop: 24 }}>
                <Divider>分组结果</Divider>
                {groupResult.drg ? (
                  <div>
                    {/* 基础信息 */}
                    <Row gutter={16} style={{ marginBottom: 16 }}>
                      <Col span={12}>
                        <Card size="small" style={{ backgroundColor: '#f0f9ff' }}>
                          <div style={{ marginBottom: 8 }}>
                            <Text type="secondary" style={{ fontSize: 12 }}>MDC编码</Text>
                            <div>
                              <Tag color="purple" style={{ fontSize: 14 }}>{groupResult.mdc || '-'}</Tag>
                            </div>
                          </div>
                          <div>
                            <Text type="secondary" style={{ fontSize: 12 }}>MDC描述</Text>
                            <Text style={{ fontSize: 13 }}>{groupResult.mdcDesc || '-'}</Text>
                          </div>
                        </Card>
                      </Col>
                      <Col span={12}>
                        <Card size="small" style={{ backgroundColor: '#f6ffed' }}>
                          <div style={{ marginBottom: 8 }}>
                            <Text type="secondary" style={{ fontSize: 12 }}>合并症状态</Text>
                            <div>
                              {groupResult.ccFlag ? (
                                <Tag color="red" style={{ fontSize: 14 }}>有合并症</Tag>
                              ) : (
                                <Tag color="green" style={{ fontSize: 14 }}>无合并症</Tag>
                              )}
                            </div>
                          </div>
                          <div>
                            <Text type="secondary" style={{ fontSize: 12 }}>分组时间</Text>
                            <Text style={{ fontSize: 13 }}>{groupResult.checkTime}</Text>
                          </div>
                        </Card>
                      </Col>
                    </Row>
                    
                    {/* DRG分组信息 - 同级显示所有DRG */}
                    <div style={{ marginBottom: 16 }}>
                      <Text strong style={{ display: 'block', marginBottom: 12, fontSize: 14 }}>
                        DRG分组信息 (共{groupResult.drgInfo?.length || 0}个)
                      </Text>
                      <div style={{ 
                        display: 'grid', 
                        gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))',
                        gap: 12 
                      }}>
                        {groupResult.drgInfo?.map((item, index) => (
                          <Card 
                            key={index}
                            size="small"
                            style={{ 
                              backgroundColor: '#f0f9ff', 
                              border: '1px solid #bae0ff'
                            }}
                            bodyStyle={{ padding: '12px' }}
                          >
                            <div style={{ marginBottom: 8 }}>
                              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                <Tag color="blue" style={{ fontSize: 14, padding: '2px 8px' }}>
                                  {item.code}
                                </Tag>
                                <Text type="secondary" style={{ fontSize: 12 }}>DRG {index + 1}</Text>
                              </div>
                            </div>
                            <Text style={{ fontSize: 13 }}>{item.desc}</Text>
                          </Card>
                        ))}
                      </div>
                    </div>
                  </div>
                ) : (
                  <Alert message="分组失败" type="error" showIcon />
                )}
              </div>
            )}
          </div>
        )}
      </Modal>

      {/* 详情弹窗 */}
      <Modal
        title={<Space><EyeOutlined /> 病案详情</Space>}
        open={detailModalVisible}
        onCancel={() => setDetailModalVisible(false)}
        width={800}
        footer={[
          <Button key="close" onClick={() => setDetailModalVisible(false)}>
            关闭
          </Button>
        ]}
      >
        {selectedRecord && (
          <Descriptions bordered column={2}>
            <Descriptions.Item label="病案号">{selectedRecord.admissionNo}</Descriptions.Item>
            <Descriptions.Item label="患者姓名">{selectedRecord.patientName}</Descriptions.Item>
            <Descriptions.Item label="性别">{getDictLabel(sexMap, selectedRecord.sex, '-')}</Descriptions.Item>
            <Descriptions.Item label="年龄">{selectedRecord.age}岁</Descriptions.Item>
            <Descriptions.Item label="科室">{selectedRecord.department}</Descriptions.Item>
            <Descriptions.Item label="住院天数">{selectedRecord.hospitalDays}天</Descriptions.Item>
            <Descriptions.Item label="入院日期">{selectedRecord.admissionDate}</Descriptions.Item>
            <Descriptions.Item label="出院日期">{selectedRecord.dischargeDate}</Descriptions.Item>
            <Descriptions.Item label="总费用">¥{selectedRecord.totalCost?.toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="主诊断">{selectedRecord.mainDiagnosisCode} {selectedRecord.mainDiagnosisName}</Descriptions.Item>
            <Descriptions.Item label="主手术">{selectedRecord.mainOperationCode} {selectedRecord.mainOperationName}</Descriptions.Item>
            <Descriptions.Item label="分组状态">
              <Badge
                status={(WORKBENCH_GROUP_STATUS_MAP[selectedRecord.drgGroupStatus]?.color || 'default') as any}
                text={WORKBENCH_GROUP_STATUS_MAP[selectedRecord.drgGroupStatus]?.text || '未分组'}
              />
            </Descriptions.Item>
            {selectedRecord.drgCode && (
              <>
                <Descriptions.Item label="DRG编码">{selectedRecord.drgCode}</Descriptions.Item>
                <Descriptions.Item label="DRG名称">{selectedRecord.drgName}</Descriptions.Item>
              </>
            )}
          </Descriptions>
        )}
      </Modal>
    </div>
  );
};

export default Workbench;
