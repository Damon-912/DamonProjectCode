import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Button,
  Input,
  Select,
  Modal,
  message,
  Space,
  Tag,
  Popconfirm,
  Row,
  Col,
  DatePicker,
  Form
} from 'antd';
import {
  PlusOutlined,
  SearchOutlined,
  ReloadOutlined,
  EditOutlined,
  DeleteOutlined,
  EyeOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';
import {
  queryHospitals,
  saveHospital,
  deleteHospital,
  type HospitalItem,
  type SaveHospitalParams
} from '../../api/hospital';

const { Option } = Select;

// 分页参数
interface PaginationParams {
  current: number;
  pageSize: number;
  total: number;
}

const Hospitals: React.FC = () => {
  const [modalForm] = Form.useForm();
  const [data, setData] = useState<HospitalItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState<PaginationParams>({
    current: 1,
    pageSize: 10,
    total: 0
  });
  const [modalVisible, setModalVisible] = useState(false);
  const [modalTitle, setModalTitle] = useState('新增医疗机构');
  const [editingRecord, setEditingRecord] = useState<HospitalItem | null>(null);
  const [detailVisible, setDetailVisible] = useState(false);
  const [detailRecord, setDetailRecord] = useState<HospitalItem | null>(null);

  // 查询条件
  const [code, setCode] = useState('');
  const [descripts, setDescripts] = useState('');
  const [active, setActive] = useState('');

  // 表格列定义
  const columns: ColumnsType<HospitalItem> = [
    {
      title: '序号',
      key: 'index',
      width: 60,
      render: (_, __, index) => (pagination.current - 1) * pagination.pageSize + index + 1
    },
    {
      title: '机构代码',
      dataIndex: 'code',
      key: 'code',
      width: 120
    },
    {
      title: 'HIS机构代码',
      dataIndex: 'hisCode',
      key: 'hisCode',
      width: 100
    },
    {
      title: '机构名称',
      dataIndex: 'descripts',
      key: 'descripts',
      width: 200
    },
    {
      title: '医院级别',
      dataIndex: 'gradeDesc',
      key: 'gradeDesc',
      width: 100
    },
    {
      title: '医院类型',
      dataIndex: 'typeDesc',
      key: 'typeDesc',
      width: 100
    },
    {
      title: '医院性质',
      dataIndex: 'natureDesc',
      key: 'natureDesc',
      width: 100
    },
    {
      title: '所在地区',
      key: 'area',
      width: 150,
      render: (record: HospitalItem) =>
        `${record.proDesc || ''} ${record.cityDesc || ''} ${record.areaDesc || ''}`
    },
    {
      title: '组织机构代码',
      dataIndex: 'organizationCode',
      key: 'organizationCode',
      width: 150
    },
    {
      title: '状态',
      dataIndex: 'active',
      key: 'active',
      width: 80,
      render: (active: string) => (
        <Tag color={active === 'Y' ? 'green' : 'red'}>
          {active === 'Y' ? '启用' : '停用'}
        </Tag>
      )
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
            查看
          </Button>
          <Button
            type="link"
            size="small"
            icon={<EditOutlined />}
            onClick={() => handleEdit(record)}
          >
            编辑
          </Button>
          <Popconfirm
            title="确认删除"
            description={`确定要删除医疗机构"${record.descripts}"吗？`}
            onConfirm={() => handleDelete(record)}
            okText="确定"
            cancelText="取消"
          >
            <Button type="link" size="small" danger icon={<DeleteOutlined />}>
              删除
            </Button>
          </Popconfirm>
        </Space>
      )
    }
  ];

  // 查询医疗机构列表
  const fetchData = async (page = pagination.current, size = pagination.pageSize) => {
    setLoading(true);
    try {
      const res = await queryHospitals(
        {
          code: code || undefined,
          desc: descripts || undefined,
          active: active || undefined
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
      console.error('查询医疗机构失败:', error);
      message.error('查询医疗机构失败');
    } finally {
      setLoading(false);
    }
  };

  // 初始化加载
  useEffect(() => {
    fetchData(1, pagination.pageSize);
  }, []);

  // 搜索
  const handleSearch = () => {
    setPagination(prev => ({ ...prev, current: 1 }));
    fetchData(1, pagination.pageSize);
  };

  // 重置
  const handleReset = () => {
    setCode('');
    setDescripts('');
    setActive('');
    setPagination(prev => ({ ...prev, current: 1 }));
    fetchData(1, pagination.pageSize);
  };

  // 新增
  const handleAdd = () => {
    setEditingRecord(null);
    setModalTitle('新增医疗机构');
    modalForm.resetFields();
    modalForm.setFieldsValue({ active: 'Y' });
    setModalVisible(true);
  };

  // 编辑
  const handleEdit = (record: HospitalItem) => {
    setEditingRecord(record);
    setModalTitle('编辑医疗机构');
    modalForm.setFieldsValue({
      code: record.code,
      descripts: record.descripts,
      hospGradeID: record.hospGradeID,
      hospTypeID: record.hospTypeID,
      hospNatureID: record.hospNatureID,
      proID: record.provIDID,
      cityID: record.cityIDID,
      areaID: record.areaIDID,
      active: record.active,
      organizationCode: record.organizationCode,
      businesslicense: record.businesslicense,
      startDate: record.createDate ? dayjs(record.createDate) : null
    });
    setModalVisible(true);
  };

  // 查看详情
  const handleView = (record: HospitalItem) => {
    setDetailRecord(record);
    setDetailVisible(true);
  };

  // 删除
  const handleDelete = async (record: HospitalItem) => {
    try {
      const res = await deleteHospital(record.hospitalID);

      if (res.errorCode === '0') {
        message.success('删除成功');
        fetchData(pagination.current, pagination.pageSize);
      } else {
        message.error(res.errorMessage || '删除失败');
      }
    } catch (error) {
      console.error('删除医疗机构失败:', error);
      message.error('删除医疗机构失败');
    }
  };

  // 保存
  const handleSave = async () => {
    try {
      const values = await modalForm.validateFields();

      const params: SaveHospitalParams = {
        ID: editingRecord?.hospitalID,
        code: values.code,
        descripts: values.descripts,
        hospGradeID: values.hospGradeID,
        hospTypeID: values.hospTypeID,
        hospNatureID: values.hospNatureID,
        provIDID: values.proID,
        cityIDID: values.cityID,
        areaIDID: values.areaID,
        active: values.active,
        organizationCode: values.organizationCode,
        businesslicense: values.businesslicense,
        startDate: values.startDate ? values.startDate.format('YYYY-MM-DD') : ''
      };

      const res = await saveHospital(params);

      if (res.errorCode === '0') {
        message.success(editingRecord ? '修改成功' : '新增成功');
        setModalVisible(false);
        fetchData(pagination.current, pagination.pageSize);
      } else {
        message.error(res.errorMessage || (editingRecord ? '修改失败' : '新增失败'));
      }
    } catch (error) {
      console.error('保存医疗机构失败:', error);
      message.error('保存医疗机构失败');
    }
  };

  return (
    <div style={{ padding: 16 }}>
      {/* 查询条件 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Row gutter={16} align="middle">
          <Col>
            <Input
              placeholder="机构代码"
              value={code}
              onChange={e => setCode(e.target.value)}
              style={{ width: 140 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="机构名称"
              value={descripts}
              onChange={e => setDescripts(e.target.value)}
              style={{ width: 180 }}
              allowClear
            />
          </Col>
          <Col>
            <Select
              placeholder="状态"
              value={active || undefined}
              onChange={v => setActive(v || '')}
              style={{ width: 100 }}
              allowClear
            >
              <Option value="Y">启用</Option>
              <Option value="N">停用</Option>
            </Select>
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
          <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增医疗机构</Button>
          <span>共 {pagination.total} 条记录</span>
        </div>
          <Table
          columns={columns}
          dataSource={data}
          rowKey="hospitalID"
          loading={loading}
          scroll={{ x: 1400 }}
          size="small"
          pagination={{
            current: pagination.current,
            pageSize: pagination.pageSize,
            total: pagination.total,
            showSizeChanger: true,
            showTotal: (t) => `共 ${t} 条`,
            onChange: (page, size) => {
              setPagination(prev => ({ ...prev, current: page, pageSize: size }));
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

      {/* 新增/编辑弹窗 */}
      <Modal
        title={modalTitle}
        open={modalVisible}
        onOk={handleSave}
        onCancel={() => setModalVisible(false)}
        width={800}
        destroyOnClose
      >
        <Form
          form={modalForm}
          layout="vertical"
          preserve={false}
        >
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="code"
                label="机构代码"
                rules={[{ required: true, message: '请输入机构代码' }]}
              >
                <Input placeholder="请输入机构代码" maxLength={20} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="descripts"
                label="机构名称"
                rules={[{ required: true, message: '请输入机构名称' }]}
              >
                <Input placeholder="请输入机构名称" maxLength={50} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="hospGradeID"
                label="医院级别"
              >
                <Select placeholder="请选择医院级别">
                  <Option value={1}>三级甲等</Option>
                  <Option value={2}>三级乙等</Option>
                  <Option value={3}>二级甲等</Option>
                  <Option value={4}>二级乙等</Option>
                  <Option value={5}>一级医院</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="hospTypeID"
                label="医院类型"
                rules={[{ required: true, message: '请选择医院类型' }]}
              >
                <Select placeholder="请选择医院类型">
                  <Option value={1}>综合医院</Option>
                  <Option value={2}>中医医院</Option>
                  <Option value={3}>专科医院</Option>
                  <Option value={4}>社区卫生服务中心</Option>
                  <Option value={5}>卫生院</Option>
                </Select>
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="hospNatureID"
                label="医院性质"
                rules={[{ required: true, message: '请选择医院性质' }]}
              >
                <Select placeholder="请选择医院性质">
                  <Option value={1}>公立医院</Option>
                  <Option value={2}>民营医院</Option>
                  <Option value={3}>合资医院</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="active"
                label="使用状态"
                rules={[{ required: true, message: '请选择使用状态' }]}
              >
                <Select placeholder="请选择使用状态">
                  <Option value="Y">启用</Option>
                  <Option value="N">停用</Option>
                </Select>
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="proID"
                label="省份"
                rules={[{ required: true, message: '请选择省份' }]}
              >
                <Select placeholder="请选择省份">
                  <Option value={1}>北京市</Option>
                  <Option value={2}>上海市</Option>
                  <Option value={3}>广东省</Option>
                  <Option value={4}>江苏省</Option>
                  <Option value={5}>浙江省</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="cityID"
                label="城市"
                rules={[{ required: true, message: '请选择城市' }]}
              >
                <Select placeholder="请选择城市">
                  <Option value={1}>北京市</Option>
                  <Option value={2}>上海市</Option>
                  <Option value={3}>广州市</Option>
                  <Option value={4}>深圳市</Option>
                  <Option value={5}>南京市</Option>
                </Select>
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="areaID"
                label="区县"
                rules={[{ required: true, message: '请选择区县' }]}
              >
                <Select placeholder="请选择区县">
                  <Option value={1}>东城区</Option>
                  <Option value={2}>西城区</Option>
                  <Option value={3}>朝阳区</Option>
                  <Option value={4}>海淀区</Option>
                  <Option value={5}>丰台区</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="startDate"
                label="生效日期"
              >
                <DatePicker style={{ width: '100%' }} placeholder="请选择生效日期" />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="organizationCode"
                label="组织机构代码"
                rules={[{ required: true, message: '请输入组织机构代码' }]}
              >
                <Input placeholder="请输入组织机构代码" maxLength={30} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="businesslicense"
                label="营业执照"
                rules={[{ required: true, message: '请输入营业执照' }]}
              >
                <Input placeholder="请输入营业执照" maxLength={30} />
              </Form.Item>
            </Col>
          </Row>
        </Form>
      </Modal>

      {/* 详情弹窗 */}
      <Modal
        title="医疗机构详情"
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
          <div>
            <Row gutter={[16, 16]}>
              <Col span={12}>
                <p><strong>机构代码：</strong>{detailRecord.code}</p>
              </Col>
              <Col span={12}>
                <p><strong>HIS机构代码：</strong>{detailRecord.hisCode || '-'}</p>
              </Col>
            </Row>
            <Row gutter={[16, 16]}>
              <Col span={12}>
                <p><strong>机构名称：</strong>{detailRecord.descripts}</p>
              </Col>
              <Col span={12}>
                <p><strong>医院级别：</strong>{detailRecord.gradeDesc || '-'}</p>
              </Col>
            </Row>
            <Row gutter={[16, 16]}>
              <Col span={12}>
                <p><strong>医院类型：</strong>{detailRecord.typeDesc || '-'}</p>
              </Col>
              <Col span={12}>
                <p><strong>医院性质：</strong>{detailRecord.natureDesc || '-'}</p>
              </Col>
            </Row>
            <Row gutter={[16, 16]}>
              <Col span={12}>
                <p><strong>医院性质：</strong>{detailRecord.natureDesc || '-'}</p>
              </Col>
              <Col span={12}>
                <p><strong>使用状态：</strong>
                  <Tag color={detailRecord.active === 'Y' ? 'green' : 'red'}>
                    {detailRecord.active === 'Y' ? '启用' : '停用'}
                  </Tag>
                </p>
              </Col>
            </Row>
            <Row gutter={[16, 16]}>
              <Col span={12}>
                <p><strong>所在省份：</strong>{detailRecord.proDesc || '-'}</p>
              </Col>
              <Col span={12}>
                <p><strong>所在城市：</strong>{detailRecord.cityDesc || '-'}</p>
              </Col>
            </Row>
            <Row gutter={[16, 16]}>
              <Col span={12}>
                <p><strong>所在区县：</strong>{detailRecord.areaDesc || '-'}</p>
              </Col>
              <Col span={12}>
                <p><strong>创建日期：</strong>{detailRecord.createDate || '-'}</p>
              </Col>
            </Row>
            <Row gutter={[16, 16]}>
              <Col span={12}>
                <p><strong>组织机构代码：</strong>{detailRecord.organizationCode}</p>
              </Col>
              <Col span={12}>
                <p><strong>营业执照：</strong>{detailRecord.businesslicense}</p>
              </Col>
            </Row>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default Hospitals;
