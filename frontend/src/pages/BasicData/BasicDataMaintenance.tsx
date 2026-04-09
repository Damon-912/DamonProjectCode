import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Input, Select, Space, Modal, Form, Row, Col,
  Tag, message, Popconfirm, DatePicker, ConfigProvider
} from 'antd';
import zhCN from 'antd/locale/zh_CN';
import dayjs, { type Dayjs } from 'dayjs';
import { 
  PlusOutlined, SearchOutlined, ReloadOutlined, DeleteOutlined, EditOutlined,
  DatabaseOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import {
  queryBasicData, saveBasicData, deleteBasicData,
  queryBasicDataSub, saveBasicDataSub, deleteBasicDataSub,
  getProvinceData, getCityData,
  type BasicDataItem, type BasicDataSubItem,
  type SaveBasicDataParams, type SaveBasicDataSubParams,
  type ProvinceItem, type CityItem
} from '../../api/basicData';

const { Option } = Select;

const BasicDataMaintenance: React.FC = () => {
  const [data, setData] = useState<BasicDataItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);

  // 选中主表行
  const [selectedRow, setSelectedRow] = useState<BasicDataItem | null>(null);
  const [subData, setSubData] = useState<BasicDataSubItem[]>([]);
  const [subTotal, setSubTotal] = useState(0);
  const [subLoading, setSubLoading] = useState(false);
  const [subCurrentPage, setSubCurrentPage] = useState(1);
  const [subPageSize, setSubPageSize] = useState(15);

  // 查询条件
  const [mainSearch, setMainSearch] = useState({ insuDesc: '', status: '' });
  const [subSearch, setSubSearch] = useState({ desc: '', status: '' });

  // 主表弹窗
  const [modalOpen, setModalOpen] = useState(false);
  const [editRecord, setEditRecord] = useState<BasicDataItem | null>(null);
  const [saving, setSaving] = useState(false);
  const [form] = Form.useForm<SaveBasicDataParams>();

  // 明细弹窗
  const [subModalOpen, setSubModalOpen] = useState(false);
  const [subEditRecord, setSubEditRecord] = useState<BasicDataSubItem | null>(null);
  const [subSaving, setSubSaving] = useState(false);
  const [subForm] = Form.useForm<SaveBasicDataSubParams>();

  // 弹框省、市下拉数据
  const [provinceList, setProvinceList] = useState<ProvinceItem[]>([]);
  const [cityList, setCityList] = useState<CityItem[]>([]);
  const [provinceLoading, setProvinceLoading] = useState(false);
  const [cityLoading, setCityLoading] = useState(false);

  // 加载主表数据
  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await queryBasicData(
        { 
          insuDesc: mainSearch.insuDesc || undefined,
          status: mainSearch.status || undefined
        },
        { pageSize: size, currentPage: page }
      );
      if (res.errorCode === '0' && res.result) {
        const rows = res.result.rows || [];
        setData(rows);
        setTotal(res.result.total || 0);
        // 数据不为空时，默认选中第一行
        if (rows.length > 0) {
          setSelectedRow(rows[0]);
        } else {
          setSelectedRow(null);
          setSubData([]);
        }
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setLoading(false);
    }
  }, [mainSearch, currentPage, pageSize]);

  useEffect(() => {
    fetchData(1, pageSize);
    setCurrentPage(1);
  }, [mainSearch]);

  // 加载明细数据（支持分页）
  const fetchSubData = async (page = subCurrentPage, size = subPageSize) => {
    if (!selectedRow) return;
    setSubLoading(true);
    try {
      // 使用主表返回的 dictID 作为查询明细的入参
      const res = await queryBasicDataSub(
        { 
          dictID: selectedRow.dictID || selectedRow.id, 
          desc: subSearch.desc || undefined,
          status: subSearch.status || undefined
        },
        { pageSize: size, currentPage: page }
      );
      if (res.errorCode === '0' && res.result) {
        setSubData(res.result.rows || []);
        setSubTotal(res.result.total || 0);
      } else {
        message.error(res.errorMessage || '查询明细失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setSubLoading(false);
    }
  };

  // 选中主表行时，自动查询明细数据
  useEffect(() => {
    if (selectedRow && selectedRow.dictID) {
      setSubCurrentPage(1);
      fetchSubData(1, subPageSize);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedRow?.dictID]);

  const handleMainSearch = () => {
    setCurrentPage(1);
    fetchData(1, pageSize);
  };

  const handleMainReset = () => {
    setMainSearch({ insuDesc: '', status: '' });
  };

  const handleSubSearch = () => {
    fetchSubData();
  };

  const handleSubReset = () => {
    setSubSearch({ desc: '', status: '' });
  };

  // 主表操作
  const handleAdd = async () => {
    setEditRecord(null);
    form.resetFields();
    setCityList([]);
    setModalOpen(true);
    // 获取省下拉数据
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

  const handleEdit = async (record: BasicDataItem) => {
    setEditRecord(record);
    setModalOpen(true);
    form.resetFields();
    setCityList([]);
    
    // 先获取下拉数据
    setProvinceLoading(true);
    let currentProvinceList: ProvinceItem[] = [];
    let currentCityList: CityItem[] = [];
    
    try {
      const res = await getProvinceData();
      if (res.errorCode === '0' && res.result) {
        currentProvinceList = res.result;
        setProvinceList(currentProvinceList);
      }
    } finally {
      setProvinceLoading(false);
    }
    
    // 找到省对应的ID（优先用ID匹配，如果没有则用名称匹配）
    let provinceValue = record.provinceID || record.provinceDr;
    let matchedProvinceId = '';
    if (currentProvinceList.length > 0) {
      // 先用ID匹配
      let matched = currentProvinceList.find(p => 
        String(p.id) === String(record.provinceID || record.provinceDr) || 
        String(p.code) === String(record.provinceID || record.provinceDr)
      );
      // 如果ID没匹配到，再用名称匹配
      if (!matched && record.provinceDesc) {
        matched = currentProvinceList.find(p => 
          p.descripts === record.provinceDesc ||
          p.descripts.includes(record.provinceDesc) ||
          record.provinceDesc.includes(p.descripts)
        );
      }
      if (matched) {
        provinceValue = matched.id;
        matchedProvinceId = matched.id;
      }
    }
    
    // 根据匹配到的省ID获取市数据
    if (matchedProvinceId) {
      setCityLoading(true);
      try {
        const cityRes = await getCityData(matchedProvinceId);
        if (cityRes.errorCode === '0' && cityRes.result) {
          currentCityList = cityRes.result;
          setCityList(currentCityList);
        }
      } finally {
        setCityLoading(false);
      }
    }
    
    // 找到市对应的ID（优先用ID匹配，如果没有则用名称匹配）
    let cityValue = record.cityID || record.cityDr;
    if (currentCityList.length > 0) {
      // 先用ID匹配
      let matched = currentCityList.find(c => 
        String(c.id) === String(record.cityID || record.cityDr) || 
        String(c.code) === String(record.cityID || record.cityDr)
      );
      // 如果ID没匹配到，再用名称匹配
      if (!matched && record.cityDesc) {
        matched = currentCityList.find(c => 
          c.descripts === record.cityDesc ||
          c.descripts.includes(record.cityDesc) ||
          record.cityDesc.includes(c.descripts)
        );
      }
      if (matched) {
        cityValue = matched.id;
      }
    }
    
    // 设置表单值（使用省市的ID，Select会根据ID匹配显示对应的中文）
    form.setFieldsValue({
      insuCode: record.insuCode,
      insuDesc: record.insuDesc,
      provinceID: provinceValue,
      cityID: cityValue,
      areaID: record.areaID || record.areaDr,
      startDate: record.startDate ? dayjs(record.startDate.split(' ')[0]) as unknown as string : null,
      stopDate: record.stopDate ? dayjs(record.stopDate.split(' ')[0]) as unknown as string : null,
      identification: record.identification,
      remark: record.remark,
    });
  };

  const handleDelete = async (id: string) => {
    try {
      const res = await deleteBasicData(id);
      if (res.errorCode === '0') {
        message.success('删除成功');
        fetchData();
        if (selectedRow?.id === id) {
          setSelectedRow(null);
          setSubData([]);
        }
      } else {
        message.error(res.errorMessage || '删除失败');
      }
    } catch {
      message.error('网络异常');
    }
  };

  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      setSaving(true);
      // dictID 取查询接口02010011返回的dictID，为空表示新增，非空表示更新
      const dictID = editRecord?.dictID || '';
      const params: SaveBasicDataParams = {
        ...values,
        dictID,
        startDate: (values.startDate as unknown as Dayjs)?.format('YYYY-MM-DD') || '',
        stopDate: (values.stopDate as unknown as Dayjs)?.format('YYYY-MM-DD') || '',
      };
      const res = await saveBasicData(params);
      if (res.errorCode === '0') {
        message.success(editRecord ? '修改成功' : '新增成功');
        setModalOpen(false);
        fetchData();
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch {
      // form validation error
    } finally {
      setSaving(false);
    }
  };

  // 明细操作
  const handleSubAdd = () => {
    if (!selectedRow) {
      message.warning('请先选择主表记录');
      return;
    }
    setSubEditRecord(null);
    subForm.resetFields();
    // dictID 取自 02010011 查询主表返回的 dictID
    const dictID = selectedRow?.dictID || selectedRow?.id || '';
    subForm.setFieldsValue({ dictID });
    setSubModalOpen(true);
  };

  const handleSubEdit = (record: BasicDataSubItem) => {
    setSubEditRecord(record);
    subForm.setFieldsValue({
      code: record.code,
      desc: record.desc,
      identification: record.identification,
      startDate: record.startDate ? dayjs(record.startDate.split(' ')[0]) as unknown as string : null,
      stopDate: record.stopDate ? dayjs(record.stopDate.split(' ')[0]) as unknown as string : null,
    });
    setSubModalOpen(true);
  };

  const handleSubDelete = async (id: string) => {
    try {
      const res = await deleteBasicDataSub(id);
      if (res.errorCode === '0') {
        message.success('删除成功');
        fetchSubData();
      } else {
        message.error(res.errorMessage || '删除失败');
      }
    } catch {
      message.error('网络异常');
    }
  };

  const handleSubSave = async () => {
    try {
      const values = await subForm.validateFields();
      setSubSaving(true);
      // dictID 取自 02010011 查询主表返回的 dictID（selectedRow）
      const dictID = selectedRow?.dictID || selectedRow?.id || '';
      const params: SaveBasicDataSubParams = {
        ...values,
        id: subEditRecord?.id || '',
        dictID,
        startDate: (values.startDate as unknown as Dayjs)?.format('YYYY-MM-DD') || '',
        stopDate: (values.stopDate as unknown as Dayjs)?.format('YYYY-MM-DD') || '',
      };
      const res = await saveBasicDataSub(params);
      if (res.errorCode === '0') {
        message.success(subEditRecord ? '修改成功' : '新增成功');
        setSubModalOpen(false);
        fetchSubData();
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch {
      // form validation error
    } finally {
      setSubSaving(false);
    }
  };

  // 省选择变化时获取市数据
  const handleProvinceChange = async (value: string) => {
    form.setFieldsValue({ cityID: undefined, areaID: undefined });
    if (!value) {
      setCityList([]);
      return;
    }
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

  // 市选择变化时填充区代码
  const handleCityChange = (value: string) => {
    if (!value) {
      form.setFieldsValue({ areaID: undefined });
      return;
    }
    const selectedCity = cityList.find(item => item.id === value);
    if (selectedCity) {
      form.setFieldsValue({ areaID: selectedCity.code });
    }
  };

  const columns: ColumnsType<BasicDataItem> = [
    { title: '代码', dataIndex: 'insuCode', width: 180, ellipsis: true },
    { title: '描述', dataIndex: 'insuDesc', width: 280, ellipsis: true },
    { title: '省', dataIndex: 'provinceDesc', width: 120, ellipsis: true },
    { title: '市', dataIndex: 'cityDesc', width: 120, ellipsis: true },
    { title: '标识码', dataIndex: 'identification', width: 120, ellipsis: true },
    {
      title: '操作',
      key: 'action',
      width: 120,
      fixed: 'right',
      render: (_, record) => (
        <Space size="middle">
          <Button type="link" size="small" icon={<EditOutlined />} onClick={() => handleEdit(record)}>编辑</Button>
          <Popconfirm
            title="确认删除"
            description="确定要删除该基础数据吗？（将同时删除明细）"
            onConfirm={() => handleDelete(record.id)}
            okText="确定"
            cancelText="取消"
          >
            <Button type="link" size="small" danger icon={<DeleteOutlined />}>删除</Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  const subColumns: ColumnsType<BasicDataSubItem> = [
    { title: '代码', dataIndex: 'code', width: 150, ellipsis: true },
    { title: '描述', dataIndex: 'desc', width: 250, ellipsis: true },
    { title: '标识码', dataIndex: 'identification', width: 100, ellipsis: true },
    { title: '生效日期', dataIndex: 'startDate', width: 100 },
    { title: '失效日期', dataIndex: 'stopDate', width: 100 },
    { title: '状态', dataIndex: 'statusDesc', width: 80 },
    {
      title: '操作',
      key: 'action',
      width: 120,
      fixed: 'right',
      render: (_, record) => {
        return (
          <Space size="middle">
            <Button type="link" size="small" icon={<EditOutlined />} onClick={() => handleSubEdit(record)}>编辑</Button>
            <Popconfirm
              title="确认删除"
              description="确定要删除该明细吗？"
              onConfirm={() => handleSubDelete(record.id)}
              okText="确定"
              cancelText="取消"
            >
              <Button type="link" size="small" danger icon={<DeleteOutlined />}>删除</Button>
            </Popconfirm>
          </Space>
        );
      },
    },
  ];

  return (
    <ConfigProvider locale={zhCN}>
      <div style={{ padding: 16, width: '100%', height: '100%', boxSizing: 'border-box', display: 'flex', flexDirection: 'column' }}>
      {/* 左右两栏布局 */}
      <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'row', gap: 16 }}>
        {/* 左侧：主表数据 */}
        <Card 
          size="small" 
          title={
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span>DRG基础数据</span>
              <Space size={4}>
                <Button type="primary" size="small" icon={<PlusOutlined />} onClick={handleAdd}>添加</Button>
              </Space>
            </div>
          }
          styles={{ body: { padding: 8, flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' } }}
          style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}
        >
          <Row gutter={8} style={{ marginBottom: 8 }} align="middle">
            <Col>
              <span>描述：</span>
            </Col>
            <Col>
              <Input
                placeholder="输入名称查询"
                value={mainSearch.insuDesc}
                onChange={e => setMainSearch(prev => ({ ...prev, insuDesc: e.target.value }))}
                allowClear
                style={{ width: 200 }}
              />
            </Col>
            <Col>
              <span>状态：</span>
            </Col>
            <Col>
              <Select
                placeholder="请选择"
                value={mainSearch.status || undefined}
                onChange={v => setMainSearch(prev => ({ ...prev, status: v || '' }))}
                style={{ width: 100 }}
                allowClear
              >
                <Option value="Y">有效</Option>
                <Option value="N">无效</Option>
              </Select>
            </Col>
            <Col style={{ marginLeft: 'auto' }}>
              <Space>
                <Button type="primary" icon={<SearchOutlined />} onClick={handleMainSearch}>查询</Button>
                <Button icon={<ReloadOutlined />} onClick={handleMainReset}>重置</Button>
              </Space>
            </Col>
          </Row>
          {/* 工具栏 + 表格 */}
          <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
            <div style={{ flex: 1, overflow: 'auto' }}>
              <Table
                columns={columns}
                dataSource={data}
                rowKey="id"
                loading={loading}
                size="small"
                scroll={{ x: 'max-content' }}
                pagination={false}
                onRow={(record) => ({
                  onClick: () => setSelectedRow(record),
                  style: { 
                    cursor: 'pointer',
                    backgroundColor: selectedRow?.id === record.id ? '#e6f7ff' : undefined 
                  },
                })}
              />
            </div>
            {/* 底部独立分页控件 */}
            <div style={{ marginTop: 8, display: 'flex', justifyContent: 'flex-end', alignItems: 'center' }}>
              <Space size="small">
                <Button
                  size="small"
                  disabled={currentPage === 1}
                  onClick={() => {
                    const newPage = 1;
                    setCurrentPage(newPage);
                    fetchData(newPage, pageSize);
                  }}
                >
                  首页
                </Button>
                <Button
                  size="small"
                  disabled={currentPage === 1}
                  onClick={() => {
                    const newPage = currentPage - 1;
                    setCurrentPage(newPage);
                    fetchData(newPage, pageSize);
                  }}
                >
                  上一页
                </Button>
                <span style={{ fontSize: 12, padding: '0 8px' }}>
                  第 {currentPage} / {Math.ceil(total / pageSize) || 1} 页
                </span>
                <Button
                  size="small"
                  disabled={currentPage >= Math.ceil(total / pageSize)}
                  onClick={() => {
                    const newPage = currentPage + 1;
                    setCurrentPage(newPage);
                    fetchData(newPage, pageSize);
                  }}
                >
                  下一页
                </Button>
                <Button
                  size="small"
                  disabled={currentPage >= Math.ceil(total / pageSize)}
                  onClick={() => {
                    const newPage = Math.ceil(total / pageSize) || 1;
                    setCurrentPage(newPage);
                    fetchData(newPage, pageSize);
                  }}
                >
                  末页
                </Button>
                <Select
                  size="small"
                  value={pageSize}
                  style={{ width: 80 }}
                  onChange={(value: number) => {
                    setPageSize(value);
                    setCurrentPage(1);
                    fetchData(1, value);
                  }}
                >
                  <Option value={15}>15条/页</Option>
                  <Option value={20}>20条/页</Option>
                  <Option value={50}>50条/页</Option>
                  <Option value={100}>100条/页</Option>
                </Select>
              </Space>
            </div>
            </div>
          </Card>

        {/* 右侧：明细数据 */}
        <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
          {selectedRow ? (
            <Card
              size="small"
              title={
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span>明细数据（{selectedRow.insuDesc}）</span>
                  <Space size={4}>
                    <Button type="primary" size="small" icon={<PlusOutlined />} onClick={handleSubAdd}>添加</Button>
                  </Space>
                </div>
              }
              styles={{ body: { padding: 8, flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' } }}
              style={{ flex: 1, display: 'flex', flexDirection: 'column' }}
            >
              <Row gutter={8} align="middle">
                <Col>
                  <span>描述：</span>
                </Col>
                <Col>
                  <Input
                    placeholder="输入描述查询"
                    value={subSearch.desc}
                    onChange={e => setSubSearch(prev => ({ ...prev, desc: e.target.value }))}
                    allowClear
                    style={{ width: 200 }}
                  />
                </Col>
                <Col>
                  <span>状态：</span>
                </Col>
                <Col>
                  <Select
                    placeholder="请选择"
                    value={subSearch.status || undefined}
                    onChange={v => setSubSearch(prev => ({ ...prev, status: v || '' }))}
                    style={{ width: 100 }}
                    allowClear
                  >
                    <Option value="Y">有效</Option>
                    <Option value="N">无效</Option>
                  </Select>
                </Col>
                <Col style={{ marginLeft: 'auto' }}>
                  <Space>
                    <Button type="primary" icon={<SearchOutlined />} onClick={handleSubSearch}>查询</Button>
                    <Button icon={<ReloadOutlined />} onClick={handleSubReset}>重置</Button>
                  </Space>
                </Col>
              </Row>
              {/* 工具栏 + 表格 */}
              <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
                <div style={{ flex: 1, overflow: 'auto' }}>
                  <Table
                    columns={subColumns}
                    dataSource={subData}
                    rowKey="id"
                    loading={subLoading}
                    size="small"
                    scroll={{ x: 'max-content' }}
                    pagination={false}
                  />
                </div>
                {/* 底部独立分页控件 */}
                <div style={{ marginTop: 8, display: 'flex', justifyContent: 'flex-end', alignItems: 'center' }}>
                  <Space size="small">
                    <Button
                      size="small"
                      disabled={subCurrentPage === 1}
                      onClick={() => {
                        setSubCurrentPage(1);
                        fetchSubData(1, subPageSize);
                      }}
                    >
                      首页
                    </Button>
                    <Button
                      size="small"
                      disabled={subCurrentPage === 1}
                      onClick={() => {
                        const newPage = subCurrentPage - 1;
                        setSubCurrentPage(newPage);
                        fetchSubData(newPage, subPageSize);
                      }}
                    >
                      上一页
                    </Button>
                    <span style={{ fontSize: 12, padding: '0 8px' }}>
                      第 {subCurrentPage} / {Math.ceil(subTotal / subPageSize) || 1} 页
                    </span>
                    <Button
                      size="small"
                      disabled={subCurrentPage >= Math.ceil(subTotal / subPageSize)}
                      onClick={() => {
                        const newPage = subCurrentPage + 1;
                        setSubCurrentPage(newPage);
                        fetchSubData(newPage, subPageSize);
                      }}
                    >
                      下一页
                    </Button>
                    <Button
                      size="small"
                      disabled={subCurrentPage >= Math.ceil(subTotal / subPageSize)}
                      onClick={() => {
                        const newPage = Math.ceil(subTotal / subPageSize) || 1;
                        setSubCurrentPage(newPage);
                        fetchSubData(newPage, subPageSize);
                      }}
                    >
                      末页
                    </Button>
                    <Select
                      size="small"
                      value={subPageSize}
                      style={{ width: 80 }}
                      onChange={(value: number) => {
                        setSubPageSize(value);
                        setSubCurrentPage(1);
                        fetchSubData(1, value);
                      }}
                    >
                      <Option value={15}>15条/页</Option>
                      <Option value={20}>20条/页</Option>
                      <Option value={50}>50条/页</Option>
                      <Option value={100}>100条/页</Option>
                    </Select>
                  </Space>
                </div>
              </div>
            </Card>
          ) : (
            <Card size="small" title="明细数据" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}
              styles={{ body: { flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' } }}
            >
              <div style={{ textAlign: 'center', color: '#bbb', fontSize: 14 }}>
                <DatabaseOutlined style={{ fontSize: 32, marginBottom: 8, display: 'block' }} />
                请点击左侧主表数据查看明细
              </div>
            </Card>
          )}
        </div>
      </div>

      {/* 主表新增/编辑弹窗 */}
      <Modal
        title={editRecord ? '编辑DRG基础数据' : '新增DRG基础数据'}
        open={modalOpen}
        onOk={handleSave}
        onCancel={() => setModalOpen(false)}
        confirmLoading={saving}
        width={600}
        destroyOnClose
      >
        <Form form={form} layout="vertical">
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="insuCode" label="代码" rules={[{ required: true, message: '请输入代码' }]}>
                <Input placeholder="如 DRG_VERSION_2024" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="insuDesc" label="描述" rules={[{ required: true, message: '请输入描述' }]}>
                <Input placeholder="如 CHS-DRG 2.0版本" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="provinceID" label="省" rules={[{ required: true, message: '请选择省' }]}>
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
            <Col span={8}>
              <Form.Item name="cityID" label="市" rules={[{ required: true, message: '请选择市' }]}>
                <Select
                  placeholder="请选择市"
                  loading={cityLoading}
                  allowClear
                  showSearch
                  optionFilterProp="children"
                  onChange={handleCityChange}
                >
                  {cityList.map(item => (
                    <Option key={item.id} value={item.id}>
                      {item.descripts}
                    </Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="areaID" label="区代码">
                <Input placeholder="如 310101" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="startDate" label="生效日期" rules={[{ required: true, message: '请选择生效日期' }]}>
                <DatePicker style={{ width: '100%' }} format="YYYY-MM-DD" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="stopDate" label="失效日期">
                <DatePicker style={{ width: '100%' }} format="YYYY-MM-DD" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="identification" label="标识码">
                <Input placeholder="标识码" />
              </Form.Item>
            </Col>
            <Col span={24}>
              <Form.Item name="remark" label="备注">
                <Input.TextArea rows={2} placeholder="备注信息" />
              </Form.Item>
            </Col>
          </Row>
        </Form>
      </Modal>

      {/* 明细新增/编辑弹窗 */}
      <Modal
        title={subEditRecord ? '编辑明细' : '新增明细'}
        open={subModalOpen}
        onOk={handleSubSave}
        onCancel={() => setSubModalOpen(false)}
        confirmLoading={subSaving}
        width={500}
        destroyOnClose
      >
        <Form form={subForm} layout="vertical">
          <Form.Item name="dictID" hidden>
            <Input />
          </Form.Item>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="code" label="代码" rules={[{ required: true, message: '请输入代码' }]}>
                <Input placeholder="如 MDCA" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="desc" label="描述" rules={[{ required: true, message: '请输入描述' }]}>
                <Input placeholder="如 先期分组-器官移植" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="identification" label="标识码">
                <Input placeholder="标识码" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="startDate" label="生效日期" rules={[{ required: true, message: '请选择生效日期' }]}>
                <DatePicker style={{ width: '100%' }} format="YYYY-MM-DD" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="stopDate" label="失效日期">
                <DatePicker style={{ width: '100%' }} format="YYYY-MM-DD" />
              </Form.Item>
            </Col>
          </Row>
        </Form>
      </Modal>
    </div>
    </ConfigProvider>
  );
};

export default BasicDataMaintenance;
