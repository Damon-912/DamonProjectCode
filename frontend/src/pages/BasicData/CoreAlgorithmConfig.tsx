import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Input, Select, Space, Modal, Form,
  Row, Col, Tag, message, Popconfirm, DatePicker
} from 'antd';
import { PlusOutlined, SearchOutlined, ReloadOutlined, DeleteOutlined, EditOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';
import {
  queryCoreAlgorithm, saveCoreAlgorithm, deleteCoreAlgorithm,
  getProvinceData, getCityData, queryHospitalInfo,
  type CoreAlgorithmItem, type SaveCoreAlgorithmParams,
  type ProvinceItem, type CityItem, type HospitalInfoItem
} from '../../api/basicData';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;

const CoreAlgorithmConfig: React.FC = () => {
  const [data, setData] = useState<CoreAlgorithmItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);

  // 查询条件
  const [drg, setDrg] = useState('');
  const [fixmedinsName, setFixmedinsName] = useState('');
  const [provinceId, setProvinceId] = useState('');
  const [cityId, setCityId] = useState('');
  const [queryInsuType, setQueryInsuType] = useState('');
  const [status, setStatus] = useState('');

  // 弹窗
  const [modalOpen, setModalOpen] = useState(false);
  const [editRecord, setEditRecord] = useState<CoreAlgorithmItem | null>(null);
  const [saving, setSaving] = useState(false);
  const [form] = Form.useForm<SaveCoreAlgorithmParams>();

  // 省、市、医疗机构下拉数据（弹窗用）
  const [provinceList, setProvinceList] = useState<ProvinceItem[]>([]);
  const [cityList, setCityList] = useState<CityItem[]>([]);
  const [hospitalList, setHospitalList] = useState<HospitalInfoItem[]>([]);
  const [provinceLoading, setProvinceLoading] = useState(false);
  const [cityLoading, setCityLoading] = useState(false);
  const [hospitalLoading, setHospitalLoading] = useState(false);

  // 查询条件下拉数据
  const [queryProvinceList, setQueryProvinceList] = useState<ProvinceItem[]>([]);
  const [queryCityList, setQueryCityList] = useState<CityItem[]>([]);
  const [queryHospitalList, setQueryHospitalList] = useState<HospitalInfoItem[]>([]);
  const [queryProvinceLoading, setQueryProvinceLoading] = useState(false);
  const [queryCityLoading, setQueryCityLoading] = useState(false);
  const [queryHospitalLoading, setQueryHospitalLoading] = useState(false);

  // 固定险种选项
  const insuTypeOptions = [
    { code: '310', name: '职工' },
    { code: '390', name: '居民' },
  ];

  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await queryCoreAlgorithm(
        {
          drg: drg || undefined,
          fixmedinsName: fixmedinsName || undefined,
          provinceID: provinceId || undefined,
          cityID: cityId || undefined,
          insuType: queryInsuType || undefined,
          status: status || undefined,
        },
        { pageSize: size, currentPage: page }
      );
      if (res.errorCode === '0' && res.result) {
        setData(res.result.rows || []);
        setTotal(res.result.total || 0);
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setLoading(false);
    }
  }, [drg, fixmedinsName, provinceId, cityId, queryInsuType, status, currentPage, pageSize]);

  useEffect(() => {
    fetchData(1, pageSize);
    setCurrentPage(1);
  }, [drg, fixmedinsName, provinceId, cityId, queryInsuType, status]);

  // 页面加载时获取查询条件下拉数据
  useEffect(() => {
    // 获取省数据
    const fetchQueryProvinceData = async () => {
      setQueryProvinceLoading(true);
      try {
        const res = await getProvinceData();
        if (res.errorCode === '0' && res.result) {
          setQueryProvinceList(res.result);
        }
      } finally {
        setQueryProvinceLoading(false);
      }
    };
    // 获取医疗机构数据
    const fetchQueryHospitalData = async () => {
      setQueryHospitalLoading(true);
      try {
        const res = await queryHospitalInfo({ active: 'Y', descripts: '' });
        if (res.errorCode === '0' && res.result) {
          setQueryHospitalList(res.result);
        }
      } finally {
        setQueryHospitalLoading(false);
      }
    };
    fetchQueryProvinceData();
    fetchQueryHospitalData();
  }, []);

  // 省选择变化时获取市数据
  useEffect(() => {
    if (!provinceId) {
      setQueryCityList([]);
      setCityId('');
      return;
    }
    const fetchQueryCityData = async () => {
      setQueryCityLoading(true);
      try {
        // provinceId 现在就是 id，直接使用
        const res = await getCityData(provinceId);
        if (res.errorCode === '0' && res.result) {
          setQueryCityList(res.result);
        }
      } finally {
        setQueryCityLoading(false);
      }
    };
    fetchQueryCityData();
  }, [provinceId]);

  const handleSearch = () => {
    setCurrentPage(1);
    fetchData(1, pageSize);
  };

  const handleReset = () => {
    setDrg('');
    setFixmedinsName('');
    setProvinceId('');
    setCityId('');
    setQueryInsuType('');
    setStatus('');
  };

  // 获取省下拉数据
  const fetchProvinceData = async () => {
    setProvinceLoading(true);
    try {
      const res = await getProvinceData();
      if (res.errorCode === '0' && res.result) {
        setProvinceList(res.result);
      } else {
        message.error(res.errorMessage || '获取省数据失败');
      }
    } catch {
      message.error('获取省数据异常');
    } finally {
      setProvinceLoading(false);
    }
  };

  // 获取市下拉数据
  const fetchCityData = async (provinceID: string) => {
    if (!provinceID) {
      setCityList([]);
      return;
    }
    setCityLoading(true);
    try {
      const res = await getCityData(provinceID);
      if (res.errorCode === '0' && res.result) {
        setCityList(res.result);
      } else {
        message.error(res.errorMessage || '获取市数据失败');
      }
    } catch {
      message.error('获取市数据异常');
    } finally {
      setCityLoading(false);
    }
  };

  // 获取医疗机构下拉数据
  const fetchHospitalData = async () => {
    setHospitalLoading(true);
    try {
      const res = await queryHospitalInfo({ active: 'Y', descripts: '' });
      if (res.errorCode === '0' && res.result) {
        setHospitalList(res.result);
      } else {
        message.error(res.errorMessage || '获取医疗机构失败');
      }
    } catch {
      message.error('获取医疗机构异常');
    } finally {
      setHospitalLoading(false);
    }
  };

  const handleAdd = () => {
    setEditRecord(null);
    form.resetFields();
    setCityList([]); // 清空市数据
    setModalOpen(true);
    fetchProvinceData(); // 弹窗打开时获取省数据
    fetchHospitalData(); // 弹窗打开时获取医疗机构数据
    // 设置生效日期默认值为当年1月1日
    form.setFieldsValue({
      startDate: dayjs().startOf('year')
    });
  };

  const handleEdit = async (record: CoreAlgorithmItem) => {
    setEditRecord(record);
    setModalOpen(true);
    // 先获取下拉数据
    const provinceRes = await getProvinceData();
    let currentProvinceList: ProvinceItem[] = [];
    if (provinceRes.errorCode === '0' && provinceRes.result) {
      currentProvinceList = provinceRes.result;
      setProvinceList(currentProvinceList);
    }
    await fetchHospitalData();
    // 后端返回的是 provinceID 和 cityID（使用 id）
    const recordProvinceId = record.provinceID || record.provinceId;
    const recordCityId = record.cityID || record.cityId;
    // 根据 provinceId 获取市数据
    if (recordProvinceId) {
      const matchedProvince = currentProvinceList.find(p => p.id === recordProvinceId || p.code === recordProvinceId);
      if (matchedProvince) {
        const cityRes = await getCityData(matchedProvince.id);
        if (cityRes.errorCode === '0' && cityRes.result) {
          setCityList(cityRes.result);
        }
      }
    }
    // 等待一下确保下拉数据渲染完成
    setTimeout(() => {
      // 根据医疗机构代码找到对应的 medinsLv
      const matchedHospital = hospitalList.find(h => h.code === record.fixmedinsCode);
      const medinsLvValue = matchedHospital?.MedinsLv || matchedHospital?.medinsLv || record.medinsLv || '';
      // 数据加载完成后再设置表单值（使用 id 而不是 code）
      form.setFieldsValue({
        drg: record.drg,
        drgDesc: record.drgDesc,
        points: record.points,
        pipValue: record.pipValue ?? record.PipValue ?? record.pIPValue ?? '',
        dgdov: record.dgdov,
        payStandard: record.payStandard ?? record.PayStandard ?? record.pay_standard ?? '',
        insuType: record.insuType,
        mdtrtArea: record.mdtrtArea,
        fixmedinsCode: record.fixmedinsCode,
        fixmedinsName: record.fixmedinsName,
        provinceDr: recordProvinceId, // 使用 id
        cityID: recordCityId, // 使用 id
        medinsLv: medinsLvValue,
        medinsLvDisplay: medinsLvValue,
        startDate: record.startDate ? dayjs(record.startDate) : undefined,
        stopDate: record.stopDate ? dayjs(record.stopDate) : undefined,
        identification: record.identification,
        remark: record.remark,
      } as any);
    }, 100);
  };

  const handleDelete = async (id: string) => {
    try {
      const res = await deleteCoreAlgorithm(id);
      if (res.errorCode === '0') {
        message.success('删除成功');
        fetchData();
      } else {
        message.error(res.errorMessage || '删除失败');
      }
    } catch {
      message.error('网络异常');
    }
  };

  // 省选择变化时触发
  const handleProvinceChange = (value: string) => {
    form.setFieldsValue({ cityID: undefined, mdtrtArea: undefined }); // 清空市选择和就医地区划代码
    // value 就是 id，直接使用获取市数据
    if (value) {
      fetchCityData(value);
    }
  };

  // 市选择变化时触发
  const handleCityChange = (value: string) => {
    // 根据 id 找到城市，获取 code 填充就医地区划代码
    const selectedCity = cityList.find(item => item.id === value);
    if (selectedCity) {
      form.setFieldsValue({ mdtrtArea: selectedCity.code }); // 填充就医地区划代码
    }
  };

  // 计算预估支付标准：基准点数 × 病组差异系数 × 预估点值
  const calculatePayStandard = (points?: string | number, dgdov?: string | number, pipValue?: string | number) => {
    const p = parseFloat(String(points || 0));
    const d = parseFloat(String(dgdov || 0));
    const v = parseFloat(String(pipValue || 0));
    if (isNaN(p) || isNaN(d) || isNaN(v) || p === 0 || d === 0 || v === 0) {
      return '';
    }
    return (p * d * v).toFixed(2);
  };

  // 监听算法参数字段变化，自动计算预估支付标准
  const handleAlgorithmValueChange = (changedValues: any, allValues: any) => {
    const fields = ['points', 'dgdov', 'pipValue'];
    const hasChanged = Object.keys(changedValues).some(key => fields.includes(key));
    if (hasChanged) {
      const { points, dgdov, pipValue } = allValues;
      const payStandard = calculatePayStandard(points, dgdov, pipValue);
      form.setFieldsValue({ payStandard });
    }
  };

  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      setSaving(true);
      const params: SaveCoreAlgorithmParams = {
        ...values,
        id: editRecord?.id || '',
        startDate: values.startDate ? (values.startDate as any).format('YYYY-MM-DD') : '',
        stopDate: values.stopDate ? (values.stopDate as any).format('YYYY-MM-DD') : '',
      };
      const res = await saveCoreAlgorithm(params);
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

  const columns: ColumnsType<CoreAlgorithmItem> = [
    {
      title: 'DRG编码',
      dataIndex: 'drg',
      width: 90,
      fixed: 'left',
    },
    {
      title: 'DRG名称',
      dataIndex: 'drgDesc',
      width: 160,
      ellipsis: true,
    },
    {
      title: '基准点数',
      dataIndex: 'points',
      width: 90,
      align: 'right',
    },
    {
      title: '预估点值',
      dataIndex: 'pipValue',
      width: 90,
      align: 'right',
    },
    {
      title: '差异系数',
      dataIndex: 'dgdov',
      width: 85,
      align: 'right',
    },
    {
      title: '预估支付标准',
      dataIndex: 'payStandard',
      width: 100,
      align: 'right',
    },
    {
      title: '险种',
      dataIndex: 'insuType',
      width: 90,
    },
    {
      title: '医疗机构',
      dataIndex: 'fixmedinsName',
      width: 140,
      ellipsis: true,
    },
    {
      title: '机构等级',
      dataIndex: 'medinsLv',
      width: 90,
    },
    {
      title: '省',
      dataIndex: 'provinceDesc',
      width: 80,
    },
    {
      title: '市',
      dataIndex: 'cityDesc',
      width: 80,
    },
    {
      title: '状态',
      dataIndex: 'statusDesc',
      width: 70,
      render: (v: string) => (
        <Tag color={v === '有效' ? 'green' : 'red'}>{v || '无效'}</Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      width: 120,
      fixed: 'right',
      render: (_, record) => (
        <Space size="small">
          <Button type="link" size="small" icon={<EditOutlined />} onClick={() => handleEdit(record)}>编辑</Button>
          <Popconfirm
            title="确认删除"
            description="确定要删除该DRG算法配置吗？"
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

  return (
    <div style={{ padding: 16 }}>
      {/* 查询条件 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Row gutter={16} align="middle">
          <Col>
            <Input
              placeholder="DRG编码"
              value={drg}
              onChange={e => setDrg(e.target.value)}
              style={{ width: 140 }}
              allowClear
            />
          </Col>
          <Col>
            <Select
              placeholder="医疗机构名称"
              value={fixmedinsName || undefined}
              onChange={v => setFixmedinsName(v || '')}
              loading={queryHospitalLoading}
              style={{ width: 180 }}
              allowClear
              showSearch
              optionFilterProp="children"
            >
              {queryHospitalList.map(item => (
                <Option key={item.code} value={item.descripts}>
                  {item.descripts}
                </Option>
              ))}
            </Select>
          </Col>
          <Col>
            <Select
              placeholder="省代码"
              value={provinceId || undefined}
              onChange={v => setProvinceId(v || '')}
              loading={queryProvinceLoading}
              style={{ width: 120 }}
              allowClear
              showSearch
              optionFilterProp="children"
            >
              {queryProvinceList.map(item => (
                <Option key={item.id} value={item.id}>
                  {item.descripts}
                </Option>
              ))}
            </Select>
          </Col>
          <Col>
            <Select
              placeholder="市代码"
              value={cityId || undefined}
              onChange={v => setCityId(v || '')}
              loading={queryCityLoading}
              style={{ width: 120 }}
              allowClear
              showSearch
              optionFilterProp="children"
            >
              {queryCityList.map(item => (
                <Option key={item.id} value={item.id}>
                  {item.descripts}
                </Option>
              ))}
            </Select>
          </Col>
          <Col>
            <Select
              placeholder="险种"
              value={queryInsuType || undefined}
              onChange={v => setQueryInsuType(v || '')}
              style={{ width: 100 }}
              allowClear
            >
              {insuTypeOptions.map(item => (
                <Option key={item.code} value={item.code}>
                  {item.name}
                </Option>
              ))}
            </Select>
          </Col>
          <Col>
            <Select
              placeholder="状态"
              value={status || undefined}
              onChange={v => setStatus(v || '')}
              style={{ width: 100 }}
              allowClear
            >
              <Option value="">全部</Option>
              <Option value="1">有效</Option>
              <Option value="0">无效</Option>
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
          <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增配置</Button>
          <span>共 {total} 条记录</span>
        </div>
        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1490 }}
          size="small"
          pagination={false}
        />
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <CustomPagination
            current={currentPage}
            pageSize={pageSize}
            total={total}
            onChange={(page, size) => {
              setCurrentPage(page);
              setPageSize(size);
              fetchData(page, size);
            }}
          />
        </div>
      </Card>

      {/* 新增/编辑弹窗 */}
      <Modal
        title={editRecord ? '编辑DRG算法配置' : '新增DRG算法配置'}
        open={modalOpen}
        onOk={handleSave}
        onCancel={() => setModalOpen(false)}
        okText="确定"
        cancelText="取消"
        confirmLoading={saving}
        width={720}
        destroyOnClose
      >
        <Form form={form} layout="vertical" size="small" onValuesChange={handleAlgorithmValueChange}>
          {/* DRG信息 */}
          <Card size="small" title="DRG信息" style={{ marginBottom: 12 }}>
            <Row gutter={16}>
              <Col span={8}>
                <Form.Item name="drg" label="DRG编码" rules={[{ required: true, message: '请输入DRG编码' }]}>
                  <Input placeholder="如 FB23" />
                </Form.Item>
              </Col>
              <Col span={16}>
                <Form.Item name="drgDesc" label="DRG描述" rules={[{ required: true, message: '请输入DRG描述' }]}>
                  <Input placeholder="如 经皮冠状动脉介入治疗" />
                </Form.Item>
              </Col>
            </Row>
          </Card>

          {/* 算法参数 */}
          <Card size="small" title="算法参数" style={{ marginBottom: 12 }}>
            <Row gutter={16}>
              <Col span={12}>
                <Form.Item name="points" label="基准点数(Points)">
                  <Input placeholder="如 2.56" />
                </Form.Item>
              </Col>
              <Col span={12}>
                <Form.Item name="pipValue" label="预估点值(PipValue)">
                  <Input placeholder="如 10500" />
                </Form.Item>
              </Col>
              <Col span={12}>
                <Form.Item name="dgdov" label="病组差异系数(DGDOV)">
                  <Input placeholder="如 1.15" />
                </Form.Item>
              </Col>
              <Col span={12}>
                <Form.Item name="payStandard" label="预估支付标准(PayStandard)">
                  <Input placeholder="如 26880" />
                </Form.Item>
              </Col>
            </Row>
          </Card>

          {/* 机构与地区 */}
          <Card size="small" title="机构与地区" style={{ marginBottom: 12 }}>
            <Row gutter={16}>
              <Col span={8}>
                <Form.Item name="provinceDr" label="省代码">
                  <Select
                    placeholder="请选择省"
                    loading={provinceLoading}
                    onChange={handleProvinceChange}
                    allowClear
                    showSearch
                    optionFilterProp="children"
                    filterOption={(input, option) =>
                      (option?.children as unknown as string)?.toLowerCase().includes(input.toLowerCase())
                    }
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
                <Form.Item name="cityID" label="市代码">
                  <Select
                    placeholder="请选择市"
                    loading={cityLoading}
                    onChange={handleCityChange}
                    allowClear
                    showSearch
                    optionFilterProp="children"
                    filterOption={(input, option) =>
                      (option?.children as unknown as string)?.toLowerCase().includes(input.toLowerCase())
                    }
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
                <Form.Item name="mdtrtArea" label="就医地区划代码">
                  <Input placeholder="如 310100" />
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item name="insuType" label="险种">
                  <Select
                    placeholder="请选择险种"
                    allowClear
                  >
                    {insuTypeOptions.map(item => (
                      <Option key={item.code} value={item.code}>
                        {item.name}
                      </Option>
                    ))}
                  </Select>
                </Form.Item>
              </Col>
              <Col span={12}>
                <Form.Item name="fixmedinsCode" label="定点医疗机构">
                  <Select
                    placeholder="请选择定点医疗机构"
                    loading={hospitalLoading}
                    allowClear
                    showSearch
                    optionFilterProp="children"
                    onChange={(value) => {
                      const selected = hospitalList.find(item => item.code === value);
                      if (selected) {
                        const medinsLvValue = selected.MedinsLv || selected.medinsLv || '';
                        form.setFieldsValue({
                          fixmedinsCode: selected.code,
                          fixmedinsName: selected.descripts,
                          medinsLv: medinsLvValue
                        } as any);
                        form.setFieldsValue({
                          medinsLvDisplay: medinsLvValue || '暂无等级信息'
                        } as any);
                      } else {
                        form.setFieldsValue({
                          fixmedinsCode: undefined,
                          fixmedinsName: undefined,
                          medinsLv: undefined
                        } as any);
                        form.setFieldsValue({
                          medinsLvDisplay: undefined
                        } as any);
                      }
                    }}
                  >
                    {hospitalList.map(item => (
                      <Option key={item.code} value={item.code}>
                        {item.descripts} ({item.code})
                      </Option>
                    ))}
                  </Select>
                </Form.Item>
                <Form.Item name="fixmedinsName" hidden>
                  <Input />
                </Form.Item>
                <Form.Item name="medinsLv" hidden>
                  <Input />
                </Form.Item>
              </Col>
              <Col span={6}>
                <Form.Item name="medinsLvDisplay" label="机构等级">
                  <Input placeholder="选择定点医疗机构后自动填充" readOnly />
                </Form.Item>
              </Col>
            </Row>
          </Card>

          {/* 有效期 */}
          <Card size="small" title="有效期与备注">
            <Row gutter={16}>
              <Col span={8}>
                <Form.Item name="startDate" label="生效日期">
                  <DatePicker style={{ width: '100%' }} placeholder="请选择生效日期" format="YYYY-MM-DD" />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item name="stopDate" label="失效日期">
                  <DatePicker style={{ width: '100%' }} placeholder="请选择失效日期" format="YYYY-MM-DD" />
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
          </Card>
        </Form>
      </Modal>
    </div>
  );
};

export default CoreAlgorithmConfig;
