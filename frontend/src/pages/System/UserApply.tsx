import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Button,
  Select,
  Modal,
  message,
  Space,
  Row,
  Col,
  DatePicker,
  Form,
  Tag,
  Input,
  Descriptions
} from 'antd';
import {
  PlusOutlined,
  SearchOutlined,
  ReloadOutlined,
  EyeOutlined,
  CheckOutlined,
  CloseOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';
import {
  queryApplyLogs,
  getUserAuditLogDetail,
  submitUserApply,
  auditUserApply,
  type UserAuditLogItem,
  type UserApplyParams,
  type AuditParams
} from '../../api/system';
import { queryHospitals, type HospitalItem } from '../../api/hospital';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;
const { RangePicker } = DatePicker;
const { TextArea } = Input;

// 分页参数
interface PaginationParams {
  current: number;
  pageSize: number;
  total: number;
}

// 审核状态选项
const auditStatusOptions = [
  { value: 'R', label: '待审核', color: 'orange' },
  { value: 'Y', label: '已通过', color: 'green' },
  { value: 'N', label: '已驳回', color: 'red' }
];

// 性别选项
const sexOptions = [
  { value: '1', label: '男' },
  { value: '2', label: '女' },
];

// 证件类型选项
const credTypeOptions = [
  { value: '1', label: '身份证' },
  { value: '2', label: '护照' },
  { value: '3', label: '军官证' },
  { value: '4', label: '其他' },
];

// 角色组选项
const groupOptions = [
  { value: '1', label: '系统管理员' },
  { value: '2', label: '医院管理员' },
  { value: '3', label: '医生' },
  { value: '4', label: '护士' },
];

const UserApply: React.FC = () => {
  const [applyForm] = Form.useForm();
  const [auditForm] = Form.useForm();
  const [data, setData] = useState<UserAuditLogItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState<PaginationParams>({
    current: 1,
    pageSize: 10,
    total: 0
  });
  
  // 查询条件
  const [searchStatus, setSearchStatus] = useState('R'); // 默认查询待审核
  const [searchHosp, setSearchHosp] = useState('');
  const [dateRange, setDateRange] = useState<[dayjs.Dayjs | null, dayjs.Dayjs | null] | null>(null);

  // 医院列表
  const [hospitals, setHospitals] = useState<HospitalItem[]>([]);
  const [hospitalLoading, setHospitalLoading] = useState(false);

  // 弹窗状态
  const [detailVisible, setDetailVisible] = useState(false);
  const [detailRecord, setDetailRecord] = useState<UserAuditLogItem | null>(null);
  const [auditVisible, setAuditVisible] = useState(false);
  const [auditRecord, setAuditRecord] = useState<UserAuditLogItem | null>(null);
  const [applyVisible, setApplyVisible] = useState(false);

  // 加载医院列表
  const fetchHospitals = async () => {
    setHospitalLoading(true);
    try {
      const res = await queryHospitals({ active: 'Y' }, { pageSize: 1000, currentPage: 1 });
      if (String(res.errorCode) === '0' && res.result) {
        setHospitals(res.result.rows || []);
      }
    } catch (error) {
      console.error('加载医院列表失败:', error);
    } finally {
      setHospitalLoading(false);
    }
  };

  // 表格列定义
  const columns: ColumnsType<UserAuditLogItem> = [
    {
      title: '序号',
      key: 'index',
      width: 60,
      render: (_, __, index) => (pagination.current - 1) * pagination.pageSize + index + 1
    },
    {
      title: '申请编码',
      dataIndex: 'code',
      key: 'code',
      width: 120
    },
    {
      title: '姓名',
      dataIndex: 'descripts',
      key: 'descripts',
      width: 120
    },
    {
      title: '性别',
      dataIndex: 'sexDesc',
      key: 'sexDesc',
      width: 80
    },
    {
      title: '所属医院',
      dataIndex: 'hospDesc',
      key: 'hospDesc',
      width: 180
    },
    {
      title: '手机号',
      dataIndex: 'mobile',
      key: 'mobile',
      width: 120
    },
    {
      title: '证件号',
      dataIndex: 'credNo',
      key: 'credNo',
      width: 150,
      ellipsis: true
    },
    {
      title: '申请时间',
      dataIndex: 'applyDateTime',
      key: 'applyDateTime',
      width: 150
    },
    {
      title: '审核状态',
      dataIndex: 'auditStatus',
      key: 'auditStatus',
      width: 100,
      render: (status: string) => {
        const option = auditStatusOptions.find(o => o.value === status);
        return (
          <Tag color={option?.color || 'default'}>
            {option?.label || status}
          </Tag>
        );
      }
    },
    {
      title: '审核人',
      dataIndex: 'auditUserDesc',
      key: 'auditUserDesc',
      width: 100,
      render: (text: string) => text || '-'
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 180,
      render: (_, record) => (
        <Space size="small">
          <Button
            type="link"
            size="small"
            icon={<EyeOutlined />}
            onClick={() => handleView(record)}
          >
            详情
          </Button>
          {record.auditStatus === 'R' && (
            <Button
              type="link"
              size="small"
              icon={<CheckOutlined />}
              onClick={() => handleAudit(record)}
            >
              审核
            </Button>
          )}
        </Space>
      )
    }
  ];

  // 查询申请列表
  const fetchData = async (page = pagination.current, size = pagination.pageSize) => {
    setLoading(true);
    try {
      const res = await queryApplyLogs(
        {
          auditStatus: searchStatus || undefined,
          hospitalID: searchHosp || undefined,
          beginDate: dateRange?.[0] ? dateRange[0].format('YYYY-MM-DD') : undefined,
          endDate: dateRange?.[1] ? dateRange[1].format('YYYY-MM-DD') : undefined
        },
        { pageSize: size, currentPage: page }
      );

      if (String(res.errorCode) === '0' && res.result) {
        setData(res.result.rows || []);
        setPagination(prev => ({
          ...prev,
          total: res.result?.total || 0
        }));
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch (error) {
      console.error('查询申请记录失败:', error);
      message.error('查询申请记录失败');
    } finally {
      setLoading(false);
    }
  };

  // 初始化加载
  useEffect(() => {
    fetchData(1, pagination.pageSize);
    fetchHospitals();
  }, []);

  // 搜索
  const handleSearch = () => {
    setPagination(prev => ({ ...prev, current: 1 }));
    fetchData(1, pagination.pageSize);
  };

  // 重置
  const handleReset = () => {
    setSearchStatus('R');
    setSearchHosp('');
    setDateRange(null);
    setPagination(prev => ({ ...prev, current: 1 }));
    fetchData(1, pagination.pageSize);
  };

  // 查看详情
  const handleView = async (record: UserAuditLogItem) => {
    try {
      const res = await getUserAuditLogDetail({ userAuditLogID: record.id });
      if (String(res.errorCode) === '0' && res.result) {
        setDetailRecord(res.result);
        setDetailVisible(true);
      } else {
        message.error(res.errorMessage || '获取详情失败');
      }
    } catch (error) {
      console.error('获取详情失败:', error);
      message.error('获取详情失败');
    }
  };

  // 打开审核弹窗
  const handleAudit = (record: UserAuditLogItem) => {
    setAuditRecord(record);
    auditForm.resetFields();
    setAuditVisible(true);
  };

  // 提交审核
  const handleSubmitAudit = async (auditStatus: string) => {
    if (!auditRecord) return;
    try {
      const values = await auditForm.validateFields();
      const params: AuditParams = {
        userAuditLogID: auditRecord.id,
        auditStatus: auditStatus,
        auditRemarks: values.auditRemarks
      };

      const res = await auditUserApply(params);
      if (String(res.errorCode) === '0') {
        message.success(auditStatus === 'Y' ? '审核通过' : '已驳回');
        setAuditVisible(false);
        fetchData(pagination.current, pagination.pageSize);
      } else {
        message.error(res.errorMessage || '审核失败');
      }
    } catch (error) {
      console.error('审核失败:', error);
      message.error('审核失败');
    }
  };

  // 打开新增申请弹窗
  const handleAddApply = () => {
    applyForm.resetFields();
    setApplyVisible(true);
    setTimeout(() => {
      applyForm.setFieldsValue({ 
        sexID: '1',
        credTypeID: '1'
      });
    }, 0);
  };

  // 提交申请
  const handleSubmitApply = async () => {
    try {
      const values = await applyForm.validateFields();
      const params: UserApplyParams = {
        code: values.code,
        descripts: values.descripts,
        sexID: values.sexID,
        mobile: values.mobile,
        credTypeID: values.credTypeID,
        credNo: values.credNo,
        hospitalID: values.hospitalID,
        introduce: values.introduce,
        auditGroupID: values.auditGroupID,
        password: values.password
      };

      const res = await submitUserApply(params);
      if (String(res.errorCode) === '0') {
        message.success('申请提交成功');
        setApplyVisible(false);
        fetchData(pagination.current, pagination.pageSize);
      } else {
        message.error(res.errorMessage || '申请提交失败');
      }
    } catch (error) {
      console.error('提交申请失败:', error);
      message.error('提交申请失败');
    }
  };

  return (
    <div style={{ padding: 16 }}>
      {/* 查询条件 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Row gutter={16} align="middle">
          <Col>
            <Select
              placeholder="审核状态"
              value={searchStatus || undefined}
              onChange={v => setSearchStatus(v || '')}
              style={{ width: 120 }}
              allowClear
              options={auditStatusOptions}
            />
          </Col>
          <Col>
            <Select
              placeholder="所属医院"
              value={searchHosp || undefined}
              onChange={v => setSearchHosp(v || '')}
              style={{ width: 180 }}
              allowClear
              loading={hospitalLoading}
              showSearch
              filterOption={(input, option) =>
                String(option?.label ?? '').toLowerCase().includes(input.toLowerCase())
              }
              options={hospitals.map(h => ({
                value: String(h.hospitalID),
                label: h.descripts
              }))}
            />
          </Col>
          <Col>
            <RangePicker
              placeholder={['开始日期', '结束日期']}
              value={dateRange}
              onChange={dates => setDateRange(dates)}
            />
          </Col>
          <Col>
            <Space>
              <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>查询</Button>
              <Button icon={<ReloadOutlined />} onClick={handleReset}>重置</Button>
            </Space>
          </Col>
        </Row>
      </Card>

      {/* 工具栏 + 表格 */}
      <Card size="small">
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 12 }}>
          <Button type="primary" icon={<PlusOutlined />} onClick={handleAddApply}>新增申请</Button>
          <span>共 {pagination.total} 条记录</span>
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
            current={pagination.current}
            pageSize={pagination.pageSize}
            total={pagination.total}
            onChange={(page, size) => {
              setPagination(prev => ({ ...prev, current: page, pageSize: size }));
              fetchData(page, size);
            }}
          />
        </div>
      </Card>

      {/* 详情弹窗 */}
      <Modal
        title="申请详情"
        open={detailVisible}
        onCancel={() => setDetailVisible(false)}
        footer={[
          <Button key="close" onClick={() => setDetailVisible(false)}>
            关闭
          </Button>
        ]}
        width={700}
      >
        {detailRecord && (
          <Descriptions bordered column={2} size="small">
            <Descriptions.Item label="申请编码">{detailRecord.code || '-'}</Descriptions.Item>
            <Descriptions.Item label="姓名">{detailRecord.descripts || '-'}</Descriptions.Item>
            <Descriptions.Item label="性别">{detailRecord.sexDesc || '-'}</Descriptions.Item>
            <Descriptions.Item label="手机号">{detailRecord.mobile || '-'}</Descriptions.Item>
            <Descriptions.Item label="所属医院">{detailRecord.hospDesc || '-'}</Descriptions.Item>
            <Descriptions.Item label="证件类型">{detailRecord.credTypeDesc || '-'}</Descriptions.Item>
            <Descriptions.Item label="证件号">{detailRecord.credNo || '-'}</Descriptions.Item>
            <Descriptions.Item label="申请时间">{detailRecord.applyDateTime || '-'}</Descriptions.Item>
            <Descriptions.Item label="审核状态">
              <Tag color={auditStatusOptions.find(o => o.value === detailRecord.auditStatus)?.color}>
                {auditStatusOptions.find(o => o.value === detailRecord.auditStatus)?.label}
              </Tag>
            </Descriptions.Item>
            <Descriptions.Item label="审核人">{detailRecord.auditUserDesc || '-'}</Descriptions.Item>
            <Descriptions.Item label="审核组">{detailRecord.auditGroupDesc || '-'}</Descriptions.Item>
            <Descriptions.Item label="审核备注">{detailRecord.auditRemarks || '-'}</Descriptions.Item>
            <Descriptions.Item label="简介" span={2}>{detailRecord.introduce || '-'}</Descriptions.Item>
          </Descriptions>
        )}
      </Modal>

      {/* 审核弹窗 */}
      <Modal
        title="审核用户申请"
        open={auditVisible}
        onCancel={() => setAuditVisible(false)}
        footer={[
          <Button key="reject" danger icon={<CloseOutlined />} onClick={() => handleSubmitAudit('N')}>
            驳回
          </Button>,
          <Button key="approve" type="primary" icon={<CheckOutlined />} onClick={() => handleSubmitAudit('Y')}>
            通过
          </Button>
        ]}
        width={600}
      >
        {auditRecord && (
          <>
            <Descriptions bordered column={2} size="small" style={{ marginBottom: 16 }}>
              <Descriptions.Item label="申请编码">{auditRecord.code || '-'}</Descriptions.Item>
              <Descriptions.Item label="姓名">{auditRecord.descripts || '-'}</Descriptions.Item>
              <Descriptions.Item label="性别">{auditRecord.sexDesc || '-'}</Descriptions.Item>
              <Descriptions.Item label="手机号">{auditRecord.mobile || '-'}</Descriptions.Item>
              <Descriptions.Item label="所属医院">{auditRecord.hospDesc || '-'}</Descriptions.Item>
              <Descriptions.Item label="证件号">{auditRecord.credNo || '-'}</Descriptions.Item>
            </Descriptions>
            <Form form={auditForm} layout="vertical">
              <Form.Item
                name="auditRemarks"
                label="审核备注"
              >
                <TextArea placeholder="请输入审核备注" maxLength={200} rows={3} />
              </Form.Item>
            </Form>
          </>
        )}
      </Modal>

      {/* 新增申请弹窗 */}
      <Modal
        title="新增用户申请"
        open={applyVisible}
        onOk={handleSubmitApply}
        onCancel={() => setApplyVisible(false)}
        okText="提交"
        cancelText="取消"
        width={600}
      >
        <Form form={applyForm} layout="vertical">
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="code"
                label="用户编码"
              >
                <Input placeholder="请输入用户编码" maxLength={20} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="descripts"
                label="姓名"
                rules={[{ required: true, message: '请输入姓名' }]}
              >
                <Input placeholder="请输入姓名" maxLength={50} />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="sexID"
                label="性别"
                rules={[{ required: true, message: '请选择性别' }]}
              >
                <Select placeholder="请选择性别" options={sexOptions} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="mobile"
                label="手机号"
                rules={[
                  { required: true, message: '请输入手机号' },
                  { pattern: /^1\d{10}$/, message: '请输入正确的11位手机号' }
                ]}
              >
                <Input placeholder="请输入手机号" maxLength={11} />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="credTypeID"
                label="证件类型"
              >
                <Select placeholder="请选择证件类型" options={credTypeOptions} allowClear />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="credNo"
                label="证件号"
              >
                <Input placeholder="请输入证件号" maxLength={30} />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="hospitalID"
                label="所属医院"
                rules={[{ required: true, message: '请选择所属医院' }]}
              >
                <Select 
                  placeholder="请选择所属医院"
                  loading={hospitalLoading}
                  showSearch
                  filterOption={(input, option) =>
                    String(option?.label ?? '').toLowerCase().includes(input.toLowerCase())
                  }
                  options={hospitals.map(h => ({
                    value: String(h.hospitalID),
                    label: h.descripts
                  }))}
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="auditGroupID"
                label="审核组"
              >
                <Select placeholder="请选择审核组" options={groupOptions} allowClear />
              </Form.Item>
            </Col>
          </Row>
          <Form.Item
            name="password"
            label="密码"
          >
            <Input.Password placeholder="请输入密码" maxLength={20} />
          </Form.Item>
          <Form.Item
            name="introduce"
            label="简介"
          >
            <TextArea placeholder="请输入简介" maxLength={200} rows={3} />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default UserApply;
