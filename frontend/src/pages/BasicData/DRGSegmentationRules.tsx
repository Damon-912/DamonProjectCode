import { useState, useEffect } from 'react';
import {
  Card, Form, Input, Select, Button, Space, Table, Row, Col,
  Tag, message, Modal, Popconfirm
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, FileTextOutlined,
  PlusOutlined, DeleteOutlined, EditOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import {
  queryHBDRGSegmentationRules,
  saveHBDRGSegmentationRules,
  deleteHBDRGSegmentationRules,
  getProvinceData,
  getCityData,
  HBDRGSegmentationRulesItem,
  QueryHBDRGSegmentationRulesParams,
  SaveHBDRGSegmentationRulesParams,
  ProvinceItem,
  CityItem,
} from '@/api/basicData';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;

/** 联合标志/细分标志选项 */
const flagOptions = [
  { value: '0', label: '否' },
  { value: '1', label: '是' },
];

/**
 * ADRG细分规则表页面
 * 管理各地方ADRG细分规则配置
 */
const DRGSegmentationRules: React.FC = () => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [dataSource, setDataSource] = useState<HBDRGSegmentationRulesItem[]>([]);
  const [total, setTotal] = useState(0);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);

  // 省、市下拉数据
  const [provinceList, setProvinceList] = useState<ProvinceItem[]>([]);
  const [cityList, setCityList] = useState<CityItem[]>([]);
  const [provinceLoading, setProvinceLoading] = useState(false);
  const [cityLoading, setCityLoading] = useState(false);

  // 编辑弹窗状态
  const [editModalVisible, setEditModalVisible] = useState(false);
  const [editLoading, setEditLoading] = useState(false);
  const [editForm] = Form.useForm();
  const [editRecord, setEditRecord] = useState<HBDRGSegmentationRulesItem | null>(null);
  const [editAdmvs, setEditAdmvs] = useState<string>('');

  const loadData = async (page = currentPage, size = pageSize) => {
    try {
      setLoading(true);
      const values = form.getFieldsValue();
      const params: QueryHBDRGSegmentationRulesParams = {
        adrg: values.adrg || '',
        adrgDesc: values.adrgDesc || '',
        provinceID: values.provinceId || '',
        cityID: values.cityId || '',
      };
      const res = await queryHBDRGSegmentationRules(params, { pageSize: size, currentPage: page });
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
    setEditModalVisible(true);
  };

  // 打开编辑弹窗
  const handleOpenEdit = (record: HBDRGSegmentationRulesItem) => {
    setEditRecord(record);
    setEditAdmvs('');
    editForm.setFieldsValue({
      adrg: record.adrg,
      adrgDesc: record.adrgDesc,
      provinceId: record.provinceID,
      cityId: record.cityID,
      unionFlag: record.unionFlag,
      segmentationFlag: record.segmentationFlag,
      selectionCriteria: record.selectionCriteria,
    });
    // 加载市数据并设置admvs
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

      const params: SaveHBDRGSegmentationRulesParams = {
        id: editRecord?.id,
        adrg: values.adrg,
        adrgDesc: values.adrgDesc,
        provinceDr: values.provinceId,
        cityDr: values.cityId,
        admvs: editAdmvs,
        unionFlag: values.unionFlag,
        segmentationFlag: values.segmentationFlag,
        selectionCriteria: values.selectionCriteria,
      };

      const res = await saveHBDRGSegmentationRules(params);
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
  const handleDelete = async (record: HBDRGSegmentationRulesItem) => {
    try {
      const res = await deleteHBDRGSegmentationRules(record.id);
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

  /** 渲染标志Tag */
  const renderFlagTag = (value: string, yesColor = 'green', noColor = 'default') => {
    return value === '1' ? <Tag color={yesColor}>是</Tag> : <Tag color={noColor}>否</Tag>;
  };

  const columns: ColumnsType<HBDRGSegmentationRulesItem> = [
    {
      title: 'ADRG代码',
      dataIndex: 'adrg',
      width: 100,
      render: (text: string) => <Tag color="blue">{text}</Tag>,
    },
    {
      title: 'ADRG描述',
      dataIndex: 'adrgDesc',
      width: 250,
    },
    {
      title: '行政区划',
      dataIndex: 'admvs',
      width: 140,
      render: (text: string) => text || '-',
    },
    {
      title: '省市',
      width: 160,
      render: (_, record) => `${record.provinceDesc || ''} ${record.cityDesc || ''}`.trim(),
      ellipsis: true,
    },
    {
      title: '联合标志',
      dataIndex: 'unionFlag',
      width: 90,
      align: 'center',
      render: (val: string) => renderFlagTag(val),
    },
    {
      title: '细分标志',
      dataIndex: 'segmentationFlag',
      width: 90,
      align: 'center',
      render: (val: string) => renderFlagTag(val, 'orange'),
    },
    {
      title: '入组规则',
      dataIndex: 'selectionCriteria',
      width: 200,
      ellipsis: true,
      render: (text: string) => text || '-',
    },
    {
      title: '操作',
      width: 120,
      fixed: 'right',
      render: (_, record) => (
        <Space size="small">
          <Button type="link" size="small" icon={<EditOutlined />} onClick={() => handleOpenEdit(record)}>
            编辑
          </Button>
          <Popconfirm
            title="删除确认"
            description={`确定要删除ADRG细分规则 "${record.adrg} - ${record.adrgDesc}" 吗？`}
            onConfirm={() => handleDelete(record)}
            okText="确定"
            cancelText="取消"
          >
            <Button type="link" size="small" danger icon={<DeleteOutlined />}>
              删除
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: 16 }}>
      {/* 查询条件 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Form form={form} layout="inline">
          <Row gutter={16} style={{ width: '100%' }}>
            <Col span={5}>
              <Form.Item name="provinceId" label="省">
                <Select
                  placeholder="请选择省"
                  loading={provinceLoading}
                  allowClear
                  showSearch
                  optionFilterProp="children"
                  onChange={handleProvinceChange}
                >
                  {provinceList.map(item => (
                    <Option key={item.id} value={item.id}>
                      {item.descripts}
                    </Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={5}>
              <Form.Item name="cityId" label="市">
                <Select
                  placeholder="请选择市"
                  loading={cityLoading}
                  allowClear
                  showSearch
                  optionFilterProp="children"
                >
                  {cityList.map(item => (
                    <Option key={item.id} value={item.id}>
                      {item.descripts}
                    </Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={5}>
              <Form.Item name="adrg" label="ADRG代码">
                <Input placeholder="模糊匹配" />
              </Form.Item>
            </Col>
            <Col span={5}>
              <Form.Item name="adrgDesc" label="ADRG描述">
                <Input placeholder="模糊匹配" />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Space>
                <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>查询</Button>
                <Button icon={<ReloadOutlined />} onClick={handleReset}>重置</Button>
              </Space>
            </Col>
          </Row>
        </Form>
      </Card>

      {/* 数据表格 */}
      <Card
        title={
          <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', position: 'relative', height: 32 }}>
            <div style={{ position: 'absolute', left: 0 }}>
              <Space>
                <Button type="primary" icon={<PlusOutlined />} onClick={handleOpenAdd} style={{ height: 32 }}>
                  新增
                </Button>
              </Space>
            </div>
            <Space><FileTextOutlined /> <span>ADRG细分规则表</span></Space>
          </div>
        }
        size="small"
      >
        <div style={{ textAlign: 'right', marginBottom: 12 }}>
          <span style={{ color: '#999' }}>共 {total} 条</span>
        </div>
        <Table
          dataSource={dataSource}
          columns={columns}
          rowKey="id"
          loading={loading}
          size="small"
          scroll={{ x: 1000 }}
          pagination={false}
        />
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <CustomPagination
            current={currentPage}
            pageSize={pageSize}
            total={total}
            onChange={(page, size) => loadData(page, size)}
          />
        </div>
      </Card>

      {/* 编辑弹窗 */}
      <Modal
        title={editRecord ? '编辑ADRG细分规则' : '新增ADRG细分规则'}
        open={editModalVisible}
        onCancel={() => setEditModalVisible(false)}
        onOk={handleSave}
        okText="确定"
        cancelText="取消"
        confirmLoading={editLoading}
        width={650}
        destroyOnClose
      >
        <Form form={editForm} layout="vertical">
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="adrg"
                label="ADRG代码"
                rules={[{ required: true, message: '请输入ADRG代码' }]}
              >
                <Input placeholder="请输入ADRG代码" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="adrgDesc"
                label="ADRG描述"
                rules={[{ required: true, message: '请输入ADRG描述' }]}
              >
                <Input placeholder="请输入ADRG描述" />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={12}>
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
            <Col span={12}>
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
                    setEditAdmvs(selectedCity?.code || '');
                  }}
                >
                  {cityList.map(item => (
                    <Option key={item.id} value={item.id}>{item.descripts}</Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="unionFlag"
                label="联合标志"
                rules={[{ required: true, message: '请选择联合标志' }]}
              >
                <Select placeholder="请选择联合标志">
                  {flagOptions.map(item => (
                    <Option key={item.value} value={item.value}>{item.label}</Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="segmentationFlag"
                label="细分标志"
                rules={[{ required: true, message: '请选择细分标志' }]}
              >
                <Select placeholder="请选择细分标志">
                  {flagOptions.map(item => (
                    <Option key={item.value} value={item.value}>{item.label}</Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
          </Row>
          <Form.Item
            name="selectionCriteria"
            label="入组规则"
          >
            <Input placeholder="请输入入组规则" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default DRGSegmentationRules;
