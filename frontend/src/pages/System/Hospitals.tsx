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
  Row,
  Col,
  DatePicker,
  Form,
  Switch,
  Tag
} from 'antd';
import {
  PlusOutlined,
  SearchOutlined,
  ReloadOutlined,
  EditOutlined,
  EyeOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';
import {
  queryHospitals,
  saveHospital,
  type HospitalItem,
  type SaveHospitalParams
} from '../../api/hospital';
import {
  getProvinceData,
  getCityData,
  getAreaData,
  getPolicyTypeData,
  type ProvinceItem,
  type CityItem,
  type AreaItem,
  type PolicyTypeItem
} from '../../api/basicData';



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
  const [organizationCode, setOrganizationCode] = useState('');
  const [descripts, setDescripts] = useState('');
  const [active, setActive] = useState('');

  // 省市区下拉数据
  const [provinceList, setProvinceList] = useState<ProvinceItem[]>([]);
  const [cityList, setCityList] = useState<CityItem[]>([]);
  const [areaList, setAreaList] = useState<AreaItem[]>([]);
  const [provinceLoading, setProvinceLoading] = useState(false);
  const [cityLoading, setCityLoading] = useState(false);
  const [areaLoading, setAreaLoading] = useState(false);

  // 政策类型下拉数据
  const [policyTypeList, setPolicyTypeList] = useState<PolicyTypeItem[]>([]);
  const [policyTypeLoading, setPolicyTypeLoading] = useState(false);

  // 表格列定义
  const columns: ColumnsType<HospitalItem> = [
    {
      title: '序号',
      key: 'index',
      width: 60,
      render: (_, __, index) => (pagination.current - 1) * pagination.pageSize + index + 1
    },
    {
      title: '定点机构代码',
      dataIndex: 'organizationCode',
      key: 'organizationCode',
      width: 120
    },

    {
      title: '定点机构名称',
      dataIndex: 'descripts',
      key: 'descripts',
      width: 200
    },
        {
      title: 'HIS机构代码',
      dataIndex: 'code',
      key: 'code',
      width: 100
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
      title: '政策类型',
      dataIndex: 'policyTypeDesc',
      key: 'policyTypeDesc',
      width: 150
    },
    {
      title: '状态',
      dataIndex: 'active',
      key: 'active',
      width: 100,
      render: (active: string, record: HospitalItem) => (
        <Switch
          checked={active === 'Y'}
          checkedChildren="启用"
          unCheckedChildren="停用"
          onChange={(checked) => {
            const newActive = checked ? 'Y' : 'N';
            handleToggleActive(record, newActive);
          }}
        />
      )
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 120,
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
          organizationCode: organizationCode || undefined,
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
    setOrganizationCode('');
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
    setCityList([]); // 清空城市数据
    setAreaList([]); // 清空区县数据
    setModalVisible(true);
    
    // 加载省份数据
    fetchProvinceData();
    // 加载政策类型数据
    fetchPolicyTypeData();
    
    // 使用 setTimeout 确保表单已渲染后再设置默认值
    setTimeout(() => {
      modalForm.setFieldsValue({ active: 'Y' });
    }, 0);
  };

  // 获取省份数据
  const fetchProvinceData = async () => {
    setProvinceLoading(true);
    try {
      const res = await getProvinceData();
      if (res.errorCode === '0' && res.result) {
        setProvinceList(res.result);
      } else {
        message.error(res.errorMessage || '获取省份数据失败');
      }
    } catch (error) {
      console.error('获取省份数据失败:', error);
      message.error('获取省份数据异常');
    } finally {
      setProvinceLoading(false);
    }
  };

  // 获取城市数据
  const fetchCityData = async (provinceID: string) => {
    if (!provinceID) {
      setCityList([]);
      setAreaList([]);
      return;
    }
    setCityLoading(true);
    try {
      const res = await getCityData(provinceID);
      if (res.errorCode === '0' && res.result) {
        setCityList(res.result);
        setAreaList([]); // 清空区县数据
      } else {
        message.error(res.errorMessage || '获取城市数据失败');
      }
    } catch (error) {
      console.error('获取城市数据失败:', error);
      message.error('获取城市数据异常');
    } finally {
      setCityLoading(false);
    }
  };

  // 获取区县数据 (01010009)
  const fetchAreaData = async (cityID: string) => {
    if (!cityID) {
      setAreaList([]);
      return;
    }
    setAreaLoading(true);
    try {
      const res = await getAreaData(cityID);
      if (res.errorCode === '0' && res.result) {
        setAreaList(res.result);
      } else {
        message.error(res.errorMessage || '获取区县数据失败');
      }
    } catch (error) {
      console.error('获取区县数据失败:', error);
      message.error('获取区县数据异常');
    } finally {
      setAreaLoading(false);
    }
  };

  // 获取政策类型数据 (01010065)
  const fetchPolicyTypeData = async () => {
    setPolicyTypeLoading(true);
    try {
      const res = await getPolicyTypeData();
      if (res.errorCode === '0' && res.result) {
        setPolicyTypeList(res.result);
      } else {
        message.error(res.errorMessage || '获取政策类型数据失败');
      }
    } catch (error) {
      console.error('获取政策类型数据失败:', error);
      message.error('获取政策类型异常');
    } finally {
      setPolicyTypeLoading(false);
    }
  };

  // 省份选择变化
  const handleProvinceChange = (value: string) => {
    modalForm.setFieldsValue({ cityID: undefined, areaID: undefined });
    if (value) {
      fetchCityData(value);
    } else {
      setCityList([]);
      setAreaList([]);
    }
  };

  // 城市选择变化
  const handleCityChange = (value: string) => {
    modalForm.setFieldsValue({ areaID: undefined });
    if (value) {
      fetchAreaData(value);
    } else {
      setAreaList([]);
    }
  };

  // 编辑
  const handleEdit = async (record: HospitalItem) => {
    setEditingRecord(record);
    setModalTitle('编辑医疗机构');
    modalForm.resetFields(); // 先清空表单
    setModalVisible(true);

    // 加载省份数据
    await fetchProvinceData();
    // 加载政策类型数据
    await fetchPolicyTypeData();
    
    // 如果记录中有省份ID，加载对应的城市数据
    if (record.provIDID) {
      await fetchCityData(String(record.provIDID));
    }
    
    // 如果记录中有城市ID，加载对应的区县数据
    if (record.cityIDID) {
      await fetchAreaData(String(record.cityIDID));
    }

    // 使用 setTimeout 确保表单已渲染后再设置值
    setTimeout(() => {
      modalForm.setFieldsValue({
        organizationCode: record.organizationCode,
        code: record.code,       
        descripts: record.descripts,
        hospGradeID: record.hospGradeID,
        hospTypeID: record.hospTypeID,
        hospNatureID: record.hospNatureID,
        proID: record.provIDID,
        cityID: record.cityIDID,
        areaID: record.areaIDID,
        active: record.active,
        policyType: record.policyTypeID !== undefined && record.policyTypeID !== null && record.policyTypeID !== '' ? Number(record.policyTypeID) : undefined,
        businesslicense: record.businesslicense,
        startDate: record.createDate ? dayjs(record.createDate) : null
      });
    }, 100);
  };

  // 查看详情
  const handleView = (record: HospitalItem) => {
    setDetailRecord(record);
    setDetailVisible(true);
  };

  // 切换启用/停用状态
  const handleToggleActive = async (record: HospitalItem, newActive: string) => {
    try {
      const params: SaveHospitalParams = {
        hospitalID: record.hospitalID,
        code: record.code,
        descripts: record.descripts,
        hospGradeID: record.hospGradeID ? String(record.hospGradeID) : undefined,
        hospTypeID: String(record.hospTypeID),
        hospNatureID: String(record.hospNatureID),
        provIDID: String(record.provIDID),
        cityIDID: String(record.cityIDID),
        areaIDID: record.areaIDID ? String(record.areaIDID) : undefined,
        policyTypeID: record.policyTypeID,
        active: newActive,
        organizationCode: record.organizationCode,
        businesslicense: record.businesslicense,
        startDate: record.createDate || ''
      };

      const res = await saveHospital(params);

      if (res.errorCode === '0') {
        message.success(newActive === 'Y' ? '已启用' : '已停用');
        fetchData(pagination.current, pagination.pageSize);
      } else {
        message.error(res.errorMessage || '状态修改失败');
      }
    } catch (error) {
      console.error('修改状态失败:', error);
      message.error('修改状态失败');
    }
  };

  // 保存
  const handleSave = async () => {
    try {
      const values = await modalForm.validateFields();

      const params: SaveHospitalParams = {
        hospitalID: editingRecord?.hospitalID,
        code: values.code,
        descripts: values.descripts,
        hospGradeID: values.hospGradeID ? String(values.hospGradeID) : undefined,
        hospTypeID: String(values.hospTypeID),
        hospNatureID: String(values.hospNatureID),
        provIDID: String(values.proID),
        cityIDID: String(values.cityID),
        areaIDID: values.areaID ? String(values.areaID) : undefined,
        policyTypeID: values.policyType !== undefined && values.policyType !== null ? String(values.policyType) : '',
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
              placeholder="定点机构代码"
              value={organizationCode}
              onChange={e => setOrganizationCode(e.target.value)}
              style={{ width: 140 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="定点机构名称"
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
              options={[
                { value: 'Y', label: '启用' },
                { value: 'N', label: '停用' }
              ]}
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
      >
        <Form
          form={modalForm}
          layout="vertical"
        >
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="organizationCode"
                label="定点机构代码"
                rules={[{ required: true, message: '请输入定点机构代码' }]}
              >
                <Input placeholder="请输入定点机构代码" maxLength={20} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="code"
                label="HIS机构代码"
                rules={[{ required: true, message: '请输入HIS机构代码' }]}
              >
                <Input placeholder="请输入HIS机构代码" maxLength={20} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={24}>
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
                rules={[{ required: true, message: '请选择医院级别' }]}                
              >
                <Select placeholder="请选择医院级别"
                  options={[
                    { value: 1, label: '一级' },
                    { value: 2, label: '二级' },
                    { value: 3, label: '三级' },
                    { value: 4, label: '省级' },
                  ]}
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="hospTypeID"
                label="医院类型"
                rules={[{ required: true, message: '请选择医院类型' }]}
              >
                <Select placeholder="请选择医院类型"
                  options={[
                    { value: 1, label: '综合医院' },
                    { value: 2, label: '中医医院' },
                    { value: 3, label: '专科医院' },
                    { value: 4, label: '社区卫生服务中心' },
                    { value: 5, label: '卫生院' }
                  ]}
                />
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
                <Select placeholder="请选择医院性质"
                  options={[
                    { value: 1, label: '公立医院' },
                    { value: 2, label: '民营医院' },
                    { value: 3, label: '合资医院' }
                  ]}
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="active"
                label="使用状态"
                rules={[{ required: true, message: '请选择使用状态' }]}
              >
                <Select placeholder="请选择使用状态"
                  options={[
                    { value: 'Y', label: '启用' },
                    { value: 'N', label: '停用' }
                  ]}
                />
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
                <Select 
                  placeholder="请选择省份"
                  loading={provinceLoading}
                  onChange={handleProvinceChange}
                  allowClear
                  showSearch
                  filterOption={(input, option) =>
                    (option?.label as string)?.toLowerCase().includes(input.toLowerCase())
                  }
                  options={provinceList.map(item => ({
                    value: item.id,
                    label: item.descripts
                  }))}
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="cityID"
                label="城市"
                rules={[{ required: true, message: '请选择城市' }]}
              >
                <Select 
                  placeholder="请选择城市"
                  loading={cityLoading}
                  onChange={handleCityChange}
                  allowClear
                  showSearch
                  filterOption={(input, option) =>
                    (option?.label as string)?.toLowerCase().includes(input.toLowerCase())
                  }
                  options={cityList.map(item => ({
                    value: item.id,
                    label: item.descripts
                  }))}
                />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="areaID"
                label="区县"
              >
                <Select 
                  placeholder="请选择区县"
                  loading={areaLoading}
                  allowClear
                  showSearch
                  filterOption={(input, option) =>
                    (option?.label as string)?.toLowerCase().includes(input.toLowerCase())
                  }
                  options={areaList.map(item => ({
                    value: item.id,
                    label: item.descripts
                  }))}
                />
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
                name="policyType"
                label="执行政策类型"
                rules={[{ required: false, message: '请选择执行政策类型' }]}
              >
             <Select placeholder="请选择执行政策类型"
                  loading={policyTypeLoading}
                  options={policyTypeList.map(item => ({
                    value: Number(item.code),
                    label: item.descripts
                  }))}
                />
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
                <p><strong>定点机构代码：</strong>{detailRecord.organizationCode}</p>
              </Col>
              <Col span={12}>
                <p><strong>HIS机构代码：</strong>{detailRecord.code || '-'}</p>
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
                <p><strong>执行政策类型：</strong>{detailRecord.policyTypeDesc || '-'}</p>
              </Col>
              <Col span={12}>
                <p><strong>营业执照：</strong>{detailRecord.businesslicense || '-'}</p>
              </Col>
            </Row>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default Hospitals;
