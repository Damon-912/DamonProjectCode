import { useState, useEffect } from 'react';
import {
  Card, Form, Input, Select, Button, Space, Table, Modal, Row, Col,
  Tag, message, Divider, Tooltip
} from 'antd';
import {
  PlusOutlined, DeleteOutlined, SearchOutlined, ReloadOutlined,
  SwapOutlined, ArrowRightOutlined, EditOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import {
  queryIcdMapping, saveIcdMapping, deleteIcdMapping, queryMedInsuIcdInfo, queryIcdInfo,
  getProvinceData, getCityData,
  IcdMappingItem, MedInsuIcdItem, IcdInfoItem, QueryIcdMappingParams, SaveIcdMappingParams,
  ProvinceItem, CityItem
} from '@/api/basicData';

const { Option } = Select;

/**
 * ICD编码映射页面
 * 管理地方ICD编码与医保ICD编码的映射关系
 */
const ICDMapping: React.FC = () => {
  const [form] = Form.useForm();
  const [editForm] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [dataSource, setDataSource] = useState<IcdMappingItem[]>([]);
  const [total, setTotal] = useState(0);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  const [selectedRowKeys, setSelectedRowKeys] = useState<string[]>([]);
  const [editVisible, setEditVisible] = useState(false);
  const [editRecord, setEditRecord] = useState<IcdMappingItem | null>(null);
  const [saving, setSaving] = useState(false);
  const [selectIcdVisible, setSelectIcdVisible] = useState(false);
  const [selectSide, setSelectSide] = useState<'left' | 'right'>('left');
  const [icdList, setIcdList] = useState<(MedInsuIcdItem | IcdInfoItem)[]>([]);
  const [icdListLoading, setIcdListLoading] = useState(false);
  const [icdListTotal, setIcdListTotal] = useState(0);
  const [icdListPage, setIcdListPage] = useState(1);

  // 查询条件省、市下拉数据
  const [provinceList, setProvinceList] = useState<ProvinceItem[]>([]);
  const [cityList, setCityList] = useState<CityItem[]>([]);
  const [provinceLoading, setProvinceLoading] = useState(false);
  const [cityLoading, setCityLoading] = useState(false);

  // 弹框省、市下拉数据
  const [editProvinceList, setEditProvinceList] = useState<ProvinceItem[]>([]);
  const [editCityList, setEditCityList] = useState<CityItem[]>([]);
  const [editProvinceLoading, setEditProvinceLoading] = useState(false);
  const [editCityLoading, setEditCityLoading] = useState(false);

  // 加载映射数据
  const loadData = async (page = currentPage, size = pageSize) => {
    try {
      setLoading(true);
      const values = form.getFieldsValue();
      const params: QueryIcdMappingParams = {
        id: values.id || '',
        versionNo: values.versionNo || '',
        provinceID: values.provinceID || '',
        cityID: values.cityID || '',
        code: values.code || '',
        descripts: values.descripts || '',
        icd: values.icd || '',
        icdDesc: values.icdDesc || '',
      };
      const res = await queryIcdMapping(params, { pageSize: size, currentPage: page });
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
    loadData();
    // 获取省下拉数据
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
  }, []);

  // 搜索
  const handleSearch = () => {
    loadData(1, pageSize);
  };

  // 重置
  const handleReset = () => {
    form.resetFields();
    setCityList([]);
    loadData(1, pageSize);
  };

  // 省选择变化时获取市数据
  const handleProvinceChange = (value: string) => {
    form.setFieldsValue({ cityID: undefined });
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

  // 弹框省选择变化时获取市数据
  const handleEditProvinceChange = (value: string) => {
    editForm.setFieldsValue({ cityID: undefined });
    if (!value) {
      setEditCityList([]);
      return;
    }
    const fetchCityData = async () => {
      setEditCityLoading(true);
      try {
        const res = await getCityData(value);
        if (res.errorCode === '0' && res.result) {
          setEditCityList(res.result);
        }
      } finally {
        setEditCityLoading(false);
      }
    };
    fetchCityData();
  };

  // 新增
  const handleAdd = async () => {
    setEditRecord(null);
    editForm.resetFields();
    editForm.setFieldsValue({ versionNo: 'ICD-10' });
    setEditVisible(true);
    // 获取省下拉数据
    setEditProvinceLoading(true);
    try {
      const res = await getProvinceData();
      if (res.errorCode === '0' && res.result) {
        setEditProvinceList(res.result);
      }
    } finally {
      setEditProvinceLoading(false);
    }
  };

  // 编辑
  const handleEdit = async (record: IcdMappingItem) => {
    setEditRecord(record);
    setEditVisible(true);
    // 先获取下拉数据
    setEditProvinceLoading(true);
    let currentProvinceList: ProvinceItem[] = [];
    try {
      const res = await getProvinceData();
      if (res.errorCode === '0' && res.result) {
        currentProvinceList = res.result;
        setEditProvinceList(currentProvinceList);
      }
    } finally {
      setEditProvinceLoading(false);
    }
    // 根据记录中的省ID获取市数据
    const recordProvinceId = record.provinceId;
    if (recordProvinceId && currentProvinceList.length > 0) {
      const matchedProvince = currentProvinceList.find(p => p.id === recordProvinceId || p.code === recordProvinceId);
      if (matchedProvince) {
        setEditCityLoading(true);
        try {
          const cityRes = await getCityData(matchedProvince.id);
          if (cityRes.errorCode === '0' && cityRes.result) {
            setEditCityList(cityRes.result);
          }
        } finally {
          setEditCityLoading(false);
        }
      }
    }
    // 设置表单值
    editForm.setFieldsValue({
      versionNo: record.versionNo,
      provinceID: record.provinceId,
      cityID: record.cityId,
      leftCode: record.code,
      leftDesc: record.descripts,
      rightCode: record.icd,
      rightDesc: record.icdDesc,
      remark: record.remark,
    });
  };

  // 删除单条
  const handleDelete = async (id: string) => {
    Modal.confirm({
      title: '确认删除',
      content: '确定要删除该条ICD编码映射关系吗？',
      onOk: async () => {
        try {
          const res = await deleteIcdMapping(id);
          if (res.errorCode === '0' || res.errorCode === '00') {
            message.success('删除成功');
            loadData();
          } else {
            message.error(res.errorMessage || '删除失败');
          }
        } catch (error: any) {
          message.error('删除失败：' + (error.message || '网络异常'));
        }
      },
    });
  };

  // 批量删除
  const handleBatchDelete = () => {
    if (selectedRowKeys.length === 0) {
      message.warning('请至少选择一条记录');
      return;
    }
    Modal.confirm({
      title: '批量删除',
      content: `确定要删除选中的 ${selectedRowKeys.length} 条记录吗？`,
      onOk: async () => {
        try {
          for (const id of selectedRowKeys) {
            await deleteIcdMapping(id);
          }
          message.success('批量删除成功');
          setSelectedRowKeys([]);
          loadData();
        } catch (error: any) {
          message.error('删除失败：' + (error.message || '网络异常'));
        }
      },
    });
  };

  // 保存映射
  const handleSave = async () => {
    try {
      const values = await editForm.validateFields();
      setSaving(true);

      const params: SaveIcdMappingParams = {
        id: editRecord?.id || '',
        code: values.leftCode,
        descripts: values.leftDesc,
        icd: values.rightCode,
        icdDesc: values.rightDesc,
        versionNo: values.versionNo,
        provinceID: values.provinceID,
        cityID: values.cityID,
      };

      const res = await saveIcdMapping(params);
      if (res.errorCode === '0' || res.errorCode === '00') {
        message.success(editRecord ? '修改成功' : '新增成功');
        setEditVisible(false);
        loadData();
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch (error: any) {
      if (error.errorFields) return; // 表单验证错误
      message.error('保存失败：' + (error.message || '网络异常'));
    } finally {
      setSaving(false);
    }
  };

  // 打开ICD选择弹窗
  const handleOpenSelect = (side: 'left' | 'right') => {
    setSelectSide(side);
    setSelectIcdVisible(true);
    setIcdListPage(1);
    loadIcdList(1, side);
  };

  // 加载ICD列表（地方ICD调用02010037，医保ICD调用02010022）
  const loadIcdList = async (page: number, side: 'left' | 'right' = selectSide) => {
    try {
      setIcdListLoading(true);
      const editValues = editForm.getFieldsValue();
      
      if (side === 'left') {
        // 地方ICD - 调用02010037接口，使用用户选择的provinceID和cityID，以及输入的代码和描述
        const res = await queryIcdInfo(
          {
            version: editValues.versionNo || 'ICD-9',
            provinceID: editValues.provinceID || '',
            cityID: editValues.cityID || '',
            code: editValues.leftCode || '',
            descripts: editValues.leftDesc || '',
            status: 'Y',
          },
          { pageSize: 10, currentPage: page }
        );
        if (res.errorCode === '0' || res.errorCode === '00') {
          setIcdList(res.result?.rows || []);
          setIcdListTotal(res.result?.total || 0);
          setIcdListPage(page);
        } else {
          // 接口返回错误，清空列表并显示错误信息
          setIcdList([]);
          setIcdListTotal(0);
          message.error(res.errorMessage || '查询失败');
        }
      } else {
        // 医保ICD - 调用02010022接口，provinceID和cityID传空，使用输入的代码和描述
        const res = await queryMedInsuIcdInfo(
          {
            versionNo: editValues.versionNo || 'ICD-10',
            provinceId: '',
            cityId: '',
            code: editValues.rightCode || '',
            desc: editValues.rightDesc || '',
            status: 'Y',
          },
          { pageSize: 10, currentPage: page }
        );
        if (res.errorCode === '0' || res.errorCode === '00') {
          setIcdList(res.result?.rows || []);
          setIcdListTotal(res.result?.total || 0);
          setIcdListPage(page);
        } else {
          // 接口返回错误，清空列表并显示错误信息
          setIcdList([]);
          setIcdListTotal(0);
          message.error(res.errorMessage || '查询失败');
        }
      }
    } catch (error) {
      // 网络异常时清空列表
      setIcdList([]);
      setIcdListTotal(0);
      message.error('网络异常');
    } finally {
      setIcdListLoading(false);
    }
  };

  // 选择ICD编码
  const handleSelectIcd = (record: MedInsuIcdItem | IcdInfoItem) => {
    if (selectSide === 'left') {
      editForm.setFieldsValue({ leftCode: record.code, leftDesc: record.desc });
    } else {
      editForm.setFieldsValue({ rightCode: record.code, rightDesc: record.desc });
    }
    setSelectIcdVisible(false);
  };

  // 表格列定义
  const columns: ColumnsType<IcdMappingItem> = [
    {
      title: '地方ICD代码',
      dataIndex: 'code',
      width: 120,
      render: (text: string) => <Tag color="blue">{text}</Tag>,
    },
    {
      title: '地方ICD描述',
      dataIndex: 'descripts',
      width: 180,
      ellipsis: true,
    },
    {
      title: '映射',
      width: 60,
      align: 'center',
      render: () => <ArrowRightOutlined style={{ color: '#999' }} />,
    },
    {
      title: '医保ICD代码',
      dataIndex: 'icd',
      width: 120,
      render: (text: string) => <Tag color="green">{text}</Tag>,
    },
    {
      title: '医保ICD描述',
      dataIndex: 'icdDesc',
      width: 180,
      ellipsis: true,
    },
    {
      title: '版本',
      dataIndex: 'versionNo',
      width: 90,
      render: (text: string) => <Tag>{text}</Tag>,
    },
    {
      title: '省市',
      width: 120,
      render: (_, record) => `${record.provinceDesc || ''} ${record.cityDesc || ''}`.trim(),
      ellipsis: true,
    },
    {
      title: '更新时间',
      width: 150,
      render: (_, record) => record.updateDate && record.updateTime
        ? `${record.updateDate} ${record.updateTime}`
        : '-',
    },
    {
      title: '操作',
      width: 120,
      fixed: 'right',
      render: (_, record) => (
        <Space>
          <Tooltip title="编辑">
            <Button type="text" icon={<EditOutlined />} onClick={() => handleEdit(record)} />
          </Tooltip>
          <Tooltip title="删除">
            <Button type="text" danger icon={<DeleteOutlined />} onClick={() => handleDelete(record.id)} />
          </Tooltip>
        </Space>
      ),
    },
  ];

  // ICD选择表格列
  const icdSelectColumns: ColumnsType<MedInsuIcdItem | IcdInfoItem> = [
    { title: 'ICD代码', dataIndex: 'code', width: 100 },
    { title: 'ICD描述', dataIndex: 'desc', ellipsis: true },
    { title: '省市', width: 120, render: (_, r) => `${(r as any).provinceDesc || ''} ${(r as any).cityDesc || ''}`.trim() },
    { title: '状态', dataIndex: 'statusDesc', width: 80, render: (t: string) => <Tag color={t === '有效' ? 'green' : 'red'}>{t || '-'}</Tag> },
    {
      title: '操作', width: 80,
      render: (_, record) => <Button type="link" onClick={() => handleSelectIcd(record)}>选择</Button>,
    },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%', gap: 16, padding: 16 }}>
      {/* 查询条件 */}
      <Card size="small" style={{ flexShrink: 0, marginBottom: 0 }}>
        <Form form={form} layout="inline">
          <Row gutter={24} style={{ width: '100%' }}>
            <Col span={4}>
              <Form.Item name="versionNo" label="版本" style={{ width: '100%' }}>
                <Select placeholder="全部" allowClear style={{ width: '100%' }}>
                  <Option value="ICD-9">ICD-9</Option>
                  <Option value="ICD-10">ICD-10</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="provinceID" label="省" style={{ width: '100%' }}>
                <Select
                  placeholder="请选择省"
                  loading={provinceLoading}
                  allowClear
                  showSearch
                  optionFilterProp="children"
                  onChange={handleProvinceChange}
                  style={{ width: '100%' }}
                >
                  {provinceList.map(item => (
                    <Option key={item.id} value={item.id}>
                      {item.descripts}
                    </Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="cityID" label="市" style={{ width: '100%' }}>
                <Select
                  placeholder="请选择市"
                  loading={cityLoading}
                  allowClear
                  showSearch
                  optionFilterProp="children"
                  style={{ width: '100%' }}
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
              <Form.Item name="code" label="地方ICD代码" style={{ width: '100%' }}>
                <Input placeholder="模糊匹配" style={{ width: '100%' }} />
              </Form.Item>
            </Col>
            <Col span={7}>
              <Form.Item name="descripts" label="地方ICD描述" style={{ width: '100%' }}>
                <Input placeholder="模糊匹配" style={{ width: '100%' }} />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={24} style={{ width: '100%', marginTop: 8 }}>
            <Col span={5}>
              <Form.Item name="icd" label="医保ICD代码" style={{ width: '100%' }}>
                <Input placeholder="模糊匹配" style={{ width: '100%' }} />
              </Form.Item>
            </Col>
            <Col span={7}>
              <Form.Item name="icdDesc" label="医保ICD描述" style={{ width: '100%' }}>
                <Input placeholder="模糊匹配" style={{ width: '100%' }} />
              </Form.Item>
            </Col>
            <Col span={12} style={{ textAlign: 'right' }}>
              <Form.Item label=" " style={{ width: '100%' }}>
                <Space>
                  <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>查询</Button>
                  <Button icon={<ReloadOutlined />} onClick={handleReset}>重置</Button>
                </Space>
              </Form.Item>
            </Col>
          </Row>
        </Form>
      </Card>

      {/* 数据表格 */}
      <Card
        title={<Space><SwapOutlined /> <span>ICD编码映射关系</span></Space>}
        size="small"
        style={{ flex: 1, display: 'flex', flexDirection: 'column' }}
        bodyStyle={{ flex: 1, padding: '12px', display: 'flex', flexDirection: 'column' }}
        extra={
          <Space>
            <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增映射</Button>
            <Button danger icon={<DeleteOutlined />} onClick={handleBatchDelete} disabled={selectedRowKeys.length === 0}>
              批量删除 ({selectedRowKeys.length})
            </Button>
            <span style={{ color: '#999' }}>共 {total} 条</span>
          </Space>
        }
      >
        <Table
          dataSource={dataSource}
          columns={columns}
          rowKey="id"
          loading={loading}
          size="small"
          scroll={{ x: 1200, y: 'calc(100vh - 400px)' }}
          style={{ flex: 1 }}
          rowSelection={{
            selectedRowKeys,
            onChange: (keys) => setSelectedRowKeys(keys as string[]),
          }}
          pagination={{
            current: currentPage,
            pageSize: pageSize,
            total: total,
            showSizeChanger: true,
            showQuickJumper: true,
            showTotal: (t) => `共 ${t} 条`,
            onChange: (page, size) => loadData(page, size),
            style: { marginBottom: 0, marginTop: 12 },
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
        title={editRecord ? '编辑ICD编码映射' : '新增ICD编码映射'}
        open={editVisible}
        onOk={handleSave}
        onCancel={() => setEditVisible(false)}
        confirmLoading={saving}
        width={720}
        destroyOnClose
      >
        <Form form={editForm} layout="vertical" style={{ marginTop: 16 }}>
          <Row gutter={16}>
            <Col span={8}>
              <Form.Item name="versionNo" label="ICD版本号" rules={[{ required: true, message: '请选择版本' }]}>
                <Select>
                  <Option value="ICD-9">ICD-9</Option>
                  <Option value="ICD-10">ICD-10</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="provinceID" label="省" rules={[{ required: true, message: '请选择省' }]}>
                <Select
                  placeholder="请选择省"
                  loading={editProvinceLoading}
                  allowClear
                  showSearch
                  optionFilterProp="children"
                  onChange={handleEditProvinceChange}
                >
                  {editProvinceList.map(item => (
                    <Option key={item.id} value={item.id}>
                      {item.descripts}
                    </Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="cityID" label="市" rules={[{ required: true, message: '请选择市' }]}>
                <Select
                  placeholder="请选择市"
                  loading={editCityLoading}
                  allowClear
                  showSearch
                  optionFilterProp="children"
                >
                  {editCityList.map(item => (
                    <Option key={item.id} value={item.id}>
                      {item.descripts}
                    </Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
          </Row>

          <Divider>编码映射关系</Divider>

          <Row gutter={24}>
            {/* 左侧：地方ICD */}
            <Col span={11}>
              <Card size="small" title="地方ICD编码" extra={
                <Button type="link" size="small" onClick={() => handleOpenSelect('left')}>从ICD库选择</Button>
              }>
                <Form.Item name="leftCode" label="代码" rules={[{ required: true, message: '请输入地方ICD代码' }]}>
                  <Input placeholder="地方ICD代码" />
                </Form.Item>
                <Form.Item name="leftDesc" label="描述" rules={[{ required: true, message: '请输入地方ICD描述' }]}>
                  <Input placeholder="地方ICD描述" />
                </Form.Item>
              </Card>
            </Col>

            {/* 中间箭头 */}
            <Col span={2} style={{ display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <SwapOutlined style={{ fontSize: 24, color: '#1890ff' }} />
            </Col>

            {/* 右侧：医保ICD */}
            <Col span={11}>
              <Card size="small" title="医保ICD编码" extra={
                <Button type="link" size="small" onClick={() => handleOpenSelect('right')}>从医保库选择</Button>
              }>
                <Form.Item name="rightCode" label="代码" rules={[{ required: true, message: '请输入医保ICD代码' }]}>
                  <Input placeholder="医保ICD代码" />
                </Form.Item>
                <Form.Item name="rightDesc" label="描述" rules={[{ required: true, message: '请输入医保ICD描述' }]}>
                  <Input placeholder="医保ICD描述" />
                </Form.Item>
              </Card>
            </Col>
          </Row>

          <Form.Item name="remark" label="备注" style={{ marginTop: 8 }}>
            <Input.TextArea rows={2} placeholder="可选备注信息" />
          </Form.Item>
        </Form>
      </Modal>

      {/* 医保ICD选择弹窗 */}
      <Modal
        title={`选择${selectSide === 'left' ? '地方' : '医保'}ICD编码`}
        open={selectIcdVisible}
        onCancel={() => setSelectIcdVisible(false)}
        footer={null}
        width={600}
        zIndex={1100}
      >
        <div style={{ display: 'flex', flexDirection: 'column', height: 400 }}>
          <div style={{ flex: 1, overflow: 'auto' }}>
            <Table
              dataSource={icdList}
              columns={icdSelectColumns}
              rowKey="id"
              loading={icdListLoading}
              size="small"
              pagination={false}
            />
          </div>
          {/* 底部独立分页控件 */}
          <div style={{ marginTop: 8, display: 'flex', justifyContent: 'flex-end', alignItems: 'center' }}>
            <Space size="small">
              <Button
                size="small"
                disabled={icdListPage === 1}
                onClick={() => loadIcdList(1)}
              >
                首页
              </Button>
              <Button
                size="small"
                disabled={icdListPage === 1}
                onClick={() => loadIcdList(icdListPage - 1)}
              >
                上一页
              </Button>
              <span style={{ fontSize: 12, padding: '0 8px' }}>
                第 {icdListPage} / {Math.ceil(icdListTotal / 10) || 1} 页
              </span>
              <Button
                size="small"
                disabled={icdListPage >= Math.ceil(icdListTotal / 10)}
                onClick={() => loadIcdList(icdListPage + 1)}
              >
                下一页
              </Button>
              <Button
                size="small"
                disabled={icdListPage >= Math.ceil(icdListTotal / 10)}
                onClick={() => loadIcdList(Math.ceil(icdListTotal / 10) || 1)}
              >
                末页
              </Button>
            </Space>
          </div>
        </div>
      </Modal>
    </div>
  );
};

export default ICDMapping;
