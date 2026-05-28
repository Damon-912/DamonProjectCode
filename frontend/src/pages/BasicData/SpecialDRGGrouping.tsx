import { useState, useEffect } from 'react';
import {
  Card, Form, Input, Select, Button, Space, Table, Row, Col,
  Tag, message, Modal, Popconfirm
} from 'antd';
import {
  SearchOutlined, ReloadOutlined,
  PlusOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import {
  queryDRGSpecialGroup,
  saveDRGSpecialGroup,
  deleteDRGSpecialGroup,
  getProvinceData,
  getCityData,
} from '@/api/basicData';
import type {
  DRGSpecialGroupItem,
  QueryDRGSpecialGroupParams,
  SaveDRGSpecialGroupParams,
  ProvinceItem,
  CityItem,
} from '@/api/basicData';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;
const { TextArea } = Input;

/**
 * DRG特异化分组内涵表页面
 * 管理各地区DRG特异化分组方案配置
 */
const SpecialDRGGrouping: React.FC = () => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [dataSource, setDataSource] = useState<DRGSpecialGroupItem[]>([]);
  const [total, setTotal] = useState(0);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);

  // 省、市下拉数据
  const [provinceList, setProvinceList] = useState<ProvinceItem[]>([]);
  const [cityList, setCityList] = useState<CityItem[]>([]);
  const [provinceLoading, setProvinceLoading] = useState(false);
  const [cityLoading, setCityLoading] = useState(false);

  // 编辑弹窗状态
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editLoading, setEditLoading] = useState(false);
  const [editForm] = Form.useForm();
  const [editRecord, setEditRecord] = useState<DRGSpecialGroupItem | null>(null);
  const [editAdmvs, setEditAdmvs] = useState<string>('');

  const loadData = async (page = currentPage, size = pageSize) => {
    try {
      setLoading(true);
      const values = form.getFieldsValue();
      const params: QueryDRGSpecialGroupParams = {
        drgCode: values.drgCode || '',
        provinceID: values.provinceId || '',
        cityID: values.cityId || '',
        year: values.year || '',
      };
      const res = await queryDRGSpecialGroup(params, { pageSize: size, currentPage: page });
      if (res.errorCode === '0' || res.errorCode === '00') {
        setDataSource(res.result?.rows || []);
        setTotal(res.result?.total || 0);
        setCurrentPage(page);
        setPageSize(size);
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch (error: any) {
      message.error('查询失败：' + (error.message || '网络异常'));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    const fetchProvinceData = async () => {
      setProvinceLoading(true);
      try {
        const res = await getProvinceData();
        if (res.errorCode === '0' && res.result) {
          setProvinceList(res.result);
        }
      } finally {
        setProvinceLoading(false);
      }
    };
    fetchProvinceData();
    loadData();
  }, []);

  // 省选择变化时获取市数据
  const handleProvinceChange = (value: string) => {
    form.setFieldsValue({ cityId: undefined });
    if (!value) {
      setCityList([]);
      return;
    }
    const fetchCityData = async () => {
      setCityLoading(true);
      try {
        const res = await getCityData(value);
        if (res.errorCode === '0' && res.result) {
          setCityList(res.result);
        }
      } finally {
        setCityLoading(false);
      }
    };
    fetchCityData();
  };

  const handleSearch = () => {
    loadData(1, pageSize);
  };

  const handleReset = () => {
    form.resetFields();
    setCityList([]);
    loadData(1, pageSize);
  };

  // ==================== 编辑功能方法 ====================

  // 打开新增弹窗
  const handleOpenAdd = () => {
    setEditRecord(null);
    editForm.resetFields();
    setEditAdmvs('');
    // 默认当前年份
    editForm.setFieldsValue({ year: new Date().getFullYear().toString() });
    setEditModalVisible(true);
  };

  // 打开编辑弹窗
  const handleOpenEdit = (record: DRGSpecialGroupItem) => {
    setEditRecord(record);
    setEditAdmvs('');
    editForm.setFieldsValue({
      drgCode: record.drgCode,
      drgName: record.drgName,
      principalDiagnosis: record.principalDiagnosis,
      principalDiagnosisName: record.principalDiagnosisName,
      secondaryDiagnosis: record.secondaryDiagnosis,
      secondaryDiagnosisName: record.secondaryDiagnosisName,
      majorProcedure: record.majorProcedure,
      majorProcedureName: record.majorProcedureName,
      secondaryProcedure: record.secondaryProcedure,
      secondaryProcedureName: record.secondaryProcedureName,
      groupFactors: record.groupFactors,
      remark: record.remark,
      admvs: record.admvs,
      provinceId: record.provinceID,
      cityId: record.cityID,
      year: record.year,
      startDate: record.startDate,
      stopDate: record.stopDate,
    });
    // 加载市数据
    const fetchCityData = async () => {
      setCityLoading(true);
      try {
        const res = await getCityData(record.provinceID);
        if (res.errorCode === '0' && res.result) {
          setCityList(res.result);
          const currentCity = res.result.find((item: CityItem) => item.id === record.cityID);
          if (currentCity) {
            setEditAdmvs(currentCity.code);
          }
        }
      } finally {
        setCityLoading(false);
      }
    };
    fetchCityData();
    setEditModalVisible(true);
  };

  // 编辑弹窗省选择变化
  const handleEditProvinceChange = (value: string) => {
    editForm.setFieldsValue({ cityId: undefined, provinceId: value });
    setEditAdmvs('');
    if (!value) {
      setCityList([]);
      return;
    }
    const fetchCityData = async () => {
      setCityLoading(true);
      try {
        const res = await getCityData(value);
        if (res.errorCode === '0' && res.result) {
          setCityList(res.result);
        }
      } finally {
        setCityLoading(false);
      }
    };
    fetchCityData();
  };

  // 保存记录
  const handleSave = async () => {
    try {
      const values = await editForm.validateFields();
      setEditLoading(true);

      const params: SaveDRGSpecialGroupParams = {
        id: editRecord?.id,
        drgCode: values.drgCode,
        drgName: values.drgName,
        principalDiagnosis: values.principalDiagnosis || '',
        principalDiagnosisName: values.principalDiagnosisName || '',
        secondaryDiagnosis: values.secondaryDiagnosis || '',
        secondaryDiagnosisName: values.secondaryDiagnosisName || '',
        majorProcedure: values.majorProcedure || '',
        majorProcedureName: values.majorProcedureName || '',
        secondaryProcedure: values.secondaryProcedure || '',
        secondaryProcedureName: values.secondaryProcedureName || '',
        groupFactors: values.groupFactors || '',
        remark: values.remark || '',
        admvs: values.admvs || editAdmvs,
        provinceDr: values.provinceId,
        cityDr: values.cityId,
        year: values.year,
        startDate: values.startDate || '',
        stopDate: values.stopDate || '',
      };

      const res = await saveDRGSpecialGroup(params);
      if (res.errorCode === '0' || res.errorCode === '00') {
        message.success(editRecord ? '修改成功' : '新增成功');
        setEditModalVisible(false);
        loadData(currentPage, pageSize);
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch (error: any) {
      if (error.errorFields) {
        return;
      }
      message.error('保存失败：' + (error.message || '网络异常'));
    } finally {
      setEditLoading(false);
    }
  };

  // 删除记录
  const handleDelete = async (record: DRGSpecialGroupItem) => {
    try {
      const res = await deleteDRGSpecialGroup(record.id);
      if (res.errorCode === '0' || res.errorCode === '00') {
        message.success('删除成功');
        loadData(currentPage, pageSize);
      } else {
        message.error(res.errorMessage || '删除失败');
      }
    } catch (error: any) {
      message.error('删除失败：' + (error.message || '网络异常'));
    }
  };

  const columns: ColumnsType<DRGSpecialGroupItem> = [
    {
      title: '序号',
      width: 60,
      align: 'center',
      render: (_, __, index) => (currentPage - 1) * pageSize + index + 1,
    },
    {
      title: 'DRG编码',
      dataIndex: 'drgCode',
      width: 90,
      render: (text: string) => <Tag color="blue">{text}</Tag>,
    },
    {
      title: 'DRG名称',
      dataIndex: 'drgName',
      width: 220,
      ellipsis: true,
    },
    {
      title: '主诊断编码',
      dataIndex: 'principalDiagnosis',
      width: 130,
      ellipsis: true,
      render: (text: string) => text || '-',
    },
    {
      title: '主诊断名称',
      dataIndex: 'principalDiagnosisName',
      width: 160,
      ellipsis: true,
      render: (text: string) => text || '-',
    },
    {
      title: '主手术编码',
      dataIndex: 'majorProcedure',
      width: 130,
      ellipsis: true,
      render: (text: string) => text || '-',
    },
    {
      title: '主手术名称',
      dataIndex: 'majorProcedureName',
      width: 160,
      ellipsis: true,
      render: (text: string) => text || '-',
    },
    {
      title: '次手术编码',
      dataIndex: 'secondaryProcedure',
      width: 130,
      ellipsis: true,
      render: (text: string) => text || '-',
    },
    {
      title: '次手术名称',
      dataIndex: 'secondaryProcedureName',
      width: 160,
      ellipsis: true,
      render: (text: string) => text || '-',
    },    
    {
      title: '行政区划',
      dataIndex: 'admvs',
      width: 90,
      render: (text: string) => text || '-',
    },
    {
      title: '省份',
      dataIndex: 'provinceDesc',
      width: 80,
      ellipsis: true,
      render: (text: string) => text || '-',
    },
    {
      title: '城市',
      dataIndex: 'cityDesc',
      width: 80,
      ellipsis: true,
      render: (text: string) => text || '-',
    },
    {
      title: '年份',
      dataIndex: 'year',
      width: 60,
      align: 'center',
      render: (text: string) => <Tag color="green">{text}</Tag>,
    },
    {
      title: '入组规则',
      dataIndex: 'groupFactors',
      width: 120,
      ellipsis: true,
      render: (text: string) => text || '-',
    },
    {
      title: '操作',
      key: 'action',
      width: 120,
      fixed: 'right' as const,
      render: (_text: any, record: DRGSpecialGroupItem) => (
        <Space size="small">
          <Button type="link" size="small" onClick={() => handleOpenEdit(record)}>
            编辑
          </Button>
          <Popconfirm
            title="确定删除该配置吗？"
            onConfirm={() => handleDelete(record)}
            okText="确定"
            cancelText="取消"
          >
            <Button type="link" danger size="small">
              删除
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: 10 }}>
      <Card>
        {/* 查询表单 */}
        <Form form={form} layout="vertical" style={{ marginBottom: 1 }}>
          <Row gutter={8}>
            <Col span={4}>
              <Form.Item label="DRG编码" name="drgCode">
                <Input
                  placeholder="模糊匹配"
                  allowClear
                />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item label="年份" name="year">
                <Input
                  placeholder="请输入年份"
                  allowClear
                />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item label="省" name="provinceId">
                <Select
                  placeholder="请选择省"
                  onChange={(value) => {
                    form.setFieldsValue({ cityId: undefined });
                    handleProvinceChange(value);
                  }}
                  allowClear
                  loading={provinceLoading}
                  style={{ width: '100%' }}
                >
                  {provinceList.map(item => (
                    <Option key={item.id} value={item.id}>{item.descripts}</Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item label="市" name="cityId">
                <Select
                  placeholder="请选择市"
                  allowClear
                  loading={cityLoading}
                  style={{ width: '100%' }}
                >
                  {cityList.map(item => (
                    <Option key={item.id} value={item.id}>{item.descripts}</Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item label=" " style={{ marginBottom: 0 }}>
                <Space>
                  <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>
                    查询
                  </Button>
                  <Button icon={<ReloadOutlined />} onClick={handleReset}>
                    重置
                  </Button>
                </Space>
              </Form.Item>
            </Col>
          </Row>
        </Form>

        {/* 操作按钮 */}
        <Row style={{ marginBottom: 2 }}>
          <Col>
            <Space>
              <Button type="primary" icon={<PlusOutlined />} onClick={handleOpenAdd}>
                新增
              </Button>
            </Space>
          </Col>
        </Row>

        {/* 表格 */}
        <Table
          columns={columns}
          dataSource={dataSource}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1800 }}
          pagination={false}
        />

        {/* 分页 */}
        <CustomPagination
          total={total}
          current={currentPage}
          pageSize={pageSize}
          onChange={(page, size) => loadData(page, size)}
        />
      </Card>

      {/* 编辑弹窗 */}
      <Modal
        title={editRecord ? '编辑特异化分组方案' : '新增特异化分组方案'}
        open={editModalVisible}
        onCancel={() => setEditModalVisible(false)}
        onOk={handleSave}
        okText="确定"
        cancelText="取消"
        confirmLoading={editLoading}
        width={800}
        destroyOnClose
      >
        <Form form={editForm} layout="vertical">
          <Row gutter={16}>
            <Col span={8}>
              <Form.Item
                name="drgCode"
                label="DRG编码"
                rules={[{ required: true, message: '请输入DRG编码' }]}
                extra="注：前3位即为ADRG编码"
              >
                <Input placeholder="请输入DRG编码（如CB46）" />
              </Form.Item>
            </Col>
            <Col span={16}>
              <Form.Item
                name="drgName"
                label="DRG名称"
                rules={[{ required: true, message: '请输入DRG名称' }]}
              >
                <Input placeholder="请输入DRG名称" />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={8}>
              <Form.Item
                name="provinceId"
                label="省"
                rules={[{ required: true, message: '请选择省' }]}
              >
                <Select
                  placeholder="请选择省"
                  loading={provinceLoading}
                  showSearch
                  optionFilterProp="children"
                  onChange={handleEditProvinceChange}
                >
                  {provinceList.map(item => (
                    <Option key={item.id} value={item.id}>{item.descripts}</Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item
                name="cityId"
                label="市"
                rules={[{ required: true, message: '请选择市' }]}
              >
                <Select
                  placeholder="请选择市"
                  loading={cityLoading}
                  showSearch
                  optionFilterProp="children"
                  onChange={(value) => {
                    const selectedCity = cityList.find((item: CityItem) => item.id === value);
                    const code = selectedCity?.code || '';
                    setEditAdmvs(code);
                    editForm.setFieldsValue({ admvs: code });
                  }}
                >
                  {cityList.map(item => (
                    <Option key={item.id} value={item.id}>{item.descripts}</Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item
                name="admvs"
                label="行政区划代码"
                rules={[{ required: true, message: '请输入行政区划代码' }]}
                extra="选择省市后自动填充"
              >
                <Input placeholder="如340100" />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={8}>
              <Form.Item
                name="year"
                label="年份"
                rules={[{ required: true, message: '请输入年份' }]}
              >
                <Input placeholder="如2026" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="startDate" label="生效日期">
                <Input placeholder="如2026-01-01" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="stopDate" label="失效日期">
                <Input placeholder="如2026-12-31" />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="principalDiagnosis" label="主要诊断编码">
                <Input placeholder="逗号分隔多个编码，如H33.502,H35.303" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="principalDiagnosisName" label="主要诊断名称">
                <Input placeholder="请输入主要诊断名称" />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="secondaryDiagnosis" label="次要诊断编码">
                <Input placeholder="逗号分隔多个编码" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="secondaryDiagnosisName" label="次要诊断名称">
                <Input placeholder="请输入次要诊断名称" />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="majorProcedure" label="主要手术编码">
                <Input placeholder="逗号分隔多个编码" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="majorProcedureName" label="主要手术名称">
                <Input placeholder="请输入主要手术名称" />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="secondaryProcedure" label="次要手术编码">
                <Input placeholder="逗号分隔多个编码" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="secondaryProcedureName" label="次要手术名称">
                <Input placeholder="请输入次要手术名称" />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="groupFactors" label="入组规则">
                <Input placeholder="如：主要诊断+主要手术" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="remark" label="备注">
                <TextArea rows={2} placeholder="请输入备注" />
              </Form.Item>
            </Col>
          </Row>
        </Form>
      </Modal>
    </div>
  );
};

export default SpecialDRGGrouping;
