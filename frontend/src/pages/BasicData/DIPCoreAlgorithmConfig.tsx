/**
 * DIP核心算法配置页面
 * 功能：列表查询、新增/编辑、删除
 */

import React, { useState, useEffect, useCallback } from 'react';
import {
  Table, Button, Card, Space, message, Popconfirm, Form, Select, Input, Row, Col, Modal, InputNumber
} from 'antd';
import {
  PlusOutlined, SearchOutlined, ReloadOutlined
} from '@ant-design/icons';
import CustomPagination from '../../components/CustomPagination';
import {
  queryDipCoreAlgorithm, deleteDipCoreAlgorithm,
  saveDipCoreAlgorithm,
  getProvinceData, getCityData,
  type DipCoreAlgorithmItem,
  type ProvinceItem, type CityItem
} from '../../api/basicData';

const { Option } = Select;

const DIPCoreAlgorithmConfig: React.FC = () => {
  const [data, setData] = useState<DipCoreAlgorithmItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);

  // 查询条件
  const [principalDiagnosis, setPrincipalDiagnosis] = useState('');
  const [principalDiagnosisName, setPrincipalDiagnosisName] = useState('');
  const [majorProcedure, setMajorProcedure] = useState('');
  const [majorProcedureName, setMajorProcedureName] = useState('');
  const [provinceId, setProvinceId] = useState('');
  const [cityId, setCityId] = useState('');
  const [medinsLv, setMedinsLv] = useState('');

  // 弹窗
  const [modalVisible, setModalVisible] = useState(false);
  const [editingRecord, setEditingRecord] = useState<DipCoreAlgorithmItem | null>(null);
  const [form] = Form.useForm();
  const [modalLoading, setModalLoading] = useState(false);

  // 省市下拉数据（查询用）
  const [provinceList, setProvinceList] = useState<ProvinceItem[]>([]);
  const [cityList, setCityList] = useState<CityItem[]>([]);
  const [provinceLoading, setProvinceLoading] = useState(false);
  const [cityLoading, setCityLoading] = useState(false);

  // 弹窗省市数据
  const [modalProvinceList, setModalProvinceList] = useState<ProvinceItem[]>([]);
  const [modalCityList, setModalCityList] = useState<CityItem[]>([]);
  const [modalProvinceLoading, setModalProvinceLoading] = useState(false);
  const [modalCityLoading, setModalCityLoading] = useState(false);

  // 加载省数据（查询）
  const loadProvinces = useCallback(async () => {
    setProvinceLoading(true);
    try {
      const res = await getProvinceData();
      if (res.errorCode === '0' && res.result) {
        setProvinceList(res.result);
      }
    } catch (error) {
      message.error('加载省数据失败');
    } finally {
      setProvinceLoading(false);
    }
  }, []);

  // 加载市数据（查询）
  const loadCities = useCallback(async (provinceId: string) => {
    if (!provinceId) {
      setCityList([]);
      setCityId('');
      return;
    }
    setCityLoading(true);
    try {
      const res = await getCityData(provinceId);
      if (res.errorCode === '0' && res.result) {
        setCityList(res.result);
      }
    } catch (error) {
      message.error('加载市数据失败');
    } finally {
      setCityLoading(false);
    }
  }, []);

  // 初始化加载省数据
  useEffect(() => {
    loadProvinces();
  }, [loadProvinces]);

  // 加载数据
  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const filters = {
        principalDiagnosis,
        principalDiagnosisName,
        majorProcedure,
        majorProcedureName,
        provinceID: provinceId,
        cityID: cityId,
        medinsLv,
      };
      const res = await queryDipCoreAlgorithm(filters, {
        pageSize,
        currentPage,
      });
      if (res.errorCode === '0' && res.result) {
        setData(res.result.rows || []);
        setTotal(res.result.total || 0);
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch (error) {
      message.error('查询失败');
    } finally {
      setLoading(false);
    }
  }, [principalDiagnosis, principalDiagnosisName, majorProcedure, majorProcedureName, provinceId, cityId, medinsLv, currentPage, pageSize]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // 查询
  const handleSearch = () => {
    setCurrentPage(1);
    fetchData();
  };

  // 重置
  const handleReset = () => {
    setPrincipalDiagnosis('');
    setPrincipalDiagnosisName('');
    setMajorProcedure('');
    setMajorProcedureName('');
    setProvinceId('');
    setCityId('');
    setMedinsLv('');
    setCityList([]);
    setCurrentPage(1);
  };

  // 省变化（查询）
  const handleProvinceChange = (value: string) => {
    setProvinceId(value);
    setCityId('');
    setCityList([]);
    if (value) {
      loadCities(value);
    }
  };

  // 分页变化
  const handlePageChange = (page: number, size: number) => {
    setCurrentPage(page);
    setPageSize(size);
  };

  // ========== 弹窗相关方法 ==========

  // 加载弹窗省数据
  const loadModalProvinces = useCallback(async () => {
    setModalProvinceLoading(true);
    try {
      const res = await getProvinceData();
      if (res.errorCode === '0' && res.result) {
        setModalProvinceList(res.result);
      }
    } catch (error) {
      message.error('加载省数据失败');
    } finally {
      setModalProvinceLoading(false);
    }
  }, []);

  // 加载弹窗市数据
  const loadModalCities = useCallback(async (provinceId: string) => {
    if (!provinceId) {
      setModalCityList([]);
      return;
    }
    setModalCityLoading(true);
    try {
      const res = await getCityData(provinceId);
      if (res.errorCode === '0' && res.result) {
        setModalCityList(res.result);
      }
    } catch (error) {
      message.error('加载市数据失败');
    } finally {
      setModalCityLoading(false);
    }
  }, []);

  // 新增
  const handleAdd = () => {
    setEditingRecord(null);
    form.resetFields();
    setModalCityList([]);
    setModalVisible(true);
    loadModalProvinces();
  };

  // 编辑
  const handleEdit = (record: DipCoreAlgorithmItem) => {
    setEditingRecord(record);
    setModalVisible(true);
    loadModalProvinces().then(() => {
      if (record.provinceID) {
        loadModalCities(record.provinceID).then(() => {
          form.setFieldsValue({
            id: record.id,
            principalDiagnosis: record.principalDiagnosis,
            principalDiagnosisName: record.principalDiagnosisName,
            majorProcedure: record.majorProcedure,
            majorProcedureName: record.majorProcedureName,
            secondaryProcedure: record.secondaryProcedure,
            secondaryProcedureName: record.secondaryProcedureName,
            provinceDr: record.provinceID,
            cityDr: record.cityID,
            mdtrtArea: record.mdtrtArea,
            medinsLv: record.medinsLv,
            scoreValue: record.scoreValue ? parseFloat(record.scoreValue) : undefined,
            adjustCoefficient: record.adjustCoefficient ? parseFloat(record.adjustCoefficient) : undefined,
            primaryAdjustCoefficient: record.primaryAdjustCoefficient ? parseFloat(record.primaryAdjustCoefficient) : undefined,
            secondaryAdjustCoefficient: record.secondaryAdjustCoefficient ? parseFloat(record.secondaryAdjustCoefficient) : undefined,
            thirdAdjustCoefficient: record.thirdAdjustCoefficient ? parseFloat(record.thirdAdjustCoefficient) : undefined,
          });
        });
      } else {
        form.setFieldsValue({
          id: record.id,
          principalDiagnosis: record.principalDiagnosis,
          principalDiagnosisName: record.principalDiagnosisName,
          majorProcedure: record.majorProcedure,
          majorProcedureName: record.majorProcedureName,
          secondaryProcedure: record.secondaryProcedure,
          secondaryProcedureName: record.secondaryProcedureName,
          provinceDr: record.provinceID,
          cityDr: record.cityID,
          mdtrtArea: record.mdtrtArea,
          medinsLv: record.medinsLv,
          scoreValue: record.scoreValue ? parseFloat(record.scoreValue) : undefined,
          adjustCoefficient: record.adjustCoefficient ? parseFloat(record.adjustCoefficient) : undefined,
          primaryAdjustCoefficient: record.primaryAdjustCoefficient ? parseFloat(record.primaryAdjustCoefficient) : undefined,
          secondaryAdjustCoefficient: record.secondaryAdjustCoefficient ? parseFloat(record.secondaryAdjustCoefficient) : undefined,
          thirdAdjustCoefficient: record.thirdAdjustCoefficient ? parseFloat(record.thirdAdjustCoefficient) : undefined,
        });
      }
    });
  };

  // 删除
  const handleDelete = async (id: string) => {
    try {
      const res = await deleteDipCoreAlgorithm(id);
      if (res.errorCode === '0') {
        message.success('删除成功');
        fetchData();
      } else {
        message.error(res.errorMessage || '删除失败');
      }
    } catch (error) {
      message.error('删除失败');
    }
  };

  // 弹窗省变化
  const handleModalProvinceChange = (value: string) => {
    form.setFieldValue('cityDr', undefined);
    setModalCityList([]);
    if (value) {
      loadModalCities(value);
    }
  };

  // 弹窗保存
  const handleModalSubmit = async () => {
    try {
      const values = await form.validateFields();
      setModalLoading(true);
      const res = await saveDipCoreAlgorithm(values as any);
      if (res.errorCode === '0') {
        message.success(editingRecord ? '更新成功' : '新增成功');
        setModalVisible(false);
        fetchData();
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch (error) {
      console.error('表单校验失败:', error);
    } finally {
      setModalLoading(false);
    }
  };

  // 关闭弹窗
  const handleModalClose = () => {
    setModalVisible(false);
  };

  // 医疗机构等级选项
  const medinsLvOptions = [
    { label: '一级', value: '1' },
    { label: '二级', value: '2' },
    { label: '三级', value: '3' },
  ];

  // 表格列定义
  const columns = [
    {
      title: '序号',
      dataIndex: 'index',
      key: 'index',
      width: 60,
      render: (_text: any, _record: any, index: number) => 
        (currentPage - 1) * pageSize + index + 1,
    },
    {
      title: '主要诊断代码',
      dataIndex: 'principalDiagnosis',
      key: 'principalDiagnosis',
      width: 120,
    },
    {
      title: '主要诊断名称',
      dataIndex: 'principalDiagnosisName',
      key: 'principalDiagnosisName',
      width: 180,
    },
    {
      title: '主要手术代码',
      dataIndex: 'majorProcedure',
      key: 'majorProcedure',
      width: 120,
    },
    {
      title: '主要手术名称',
      dataIndex: 'majorProcedureName',
      key: 'majorProcedureName',
      width: 180,
    },
    {
      title: '省',
      dataIndex: 'provinceDesc',
      key: 'provinceDesc',
      width: 100,
    },
    {
      title: '市',
      dataIndex: 'cityDesc',
      key: 'cityDesc',
      width: 100,
    },
    {
      title: '医疗机构等级',
      dataIndex: 'medinsLv',
      key: 'medinsLv',
      width: 100,
      render: (text: string) => {
        const option = medinsLvOptions.find(item => item.value === text);
        return option ? option.label : text;
      },
    },
    {
      title: '基准分值',
      dataIndex: 'scoreValue',
      key: 'scoreValue',
      width: 100,
    },
    {
      title: '调节系数',
      dataIndex: 'adjustCoefficient',
      key: 'adjustCoefficient',
      width: 100,
    },
    {
      title: '操作',
      key: 'action',
      width: 120,
      fixed: 'right' as const,
      render: (_text: any, record: DipCoreAlgorithmItem) => (
        <Space size="small">
          <Button type="link" size="small" onClick={() => handleEdit(record)}>
            编辑
          </Button>
          <Popconfirm
            title="确定删除该配置吗？"
            onConfirm={() => handleDelete(record.id)}
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
    <div style={{ padding: 12 }}>
      <Card>
        {/* 查询表单 */}
        <Form layout="vertical" style={{ marginBottom: 1 }}>
          <Row gutter={8}>
            <Col span={4}>
              <Form.Item label="主要诊断代码">
                <Input
                  placeholder="请输入主要诊断代码"
                  value={principalDiagnosis}
                  onChange={(e) => setPrincipalDiagnosis(e.target.value)}
                />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item label="主要诊断名称">
                <Input
                  placeholder="请输入主要诊断名称"
                  value={principalDiagnosisName}
                  onChange={(e) => setPrincipalDiagnosisName(e.target.value)}
                />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item label="主要手术代码">
                <Input
                  placeholder="请输入主要手术代码"
                  value={majorProcedure}
                  onChange={(e) => setMajorProcedure(e.target.value)}
                />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item label="主要手术名称">
                <Input
                  placeholder="请输入主要手术名称"
                  value={majorProcedureName}
                  onChange={(e) => setMajorProcedureName(e.target.value)}
                />
              </Form.Item>
            </Col>
          </Row>
          <Row gutter={16}>
            <Col span={4}>
              <Form.Item label="省">
                <Select
                  placeholder="请选择省"
                  value={provinceId || undefined}
                  onChange={handleProvinceChange}
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
              <Form.Item label="市">
                <Select
                  placeholder="请选择市"
                  value={cityId || undefined}
                  onChange={setCityId}
                  allowClear
                  disabled={!provinceId}
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
              <Form.Item label="机构等级">
                <Select
                  placeholder="全部"
                  value={medinsLv || undefined}
                  onChange={setMedinsLv}
                  allowClear
                  style={{ width: '100%' }}
                >
                  {medinsLvOptions.map(item => (
                    <Option key={item.value} value={item.value}>{item.label}</Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={3}>
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
        <Row style={{ marginBottom: 6 }}>
          <Col>
            <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
              新增配置
            </Button>
          </Col>
        </Row>

        {/* 表格 */}
        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1400 }}
          pagination={false}
        />

        {/* 分页 */}
        <CustomPagination
          total={total}
          current={currentPage}
          pageSize={pageSize}
          onChange={handlePageChange}
        />
      </Card>

      {/* 新增/编辑弹窗 */}
      <Modal
        title={editingRecord ? '编辑DIP核心算法配置' : '新增DIP核心算法配置'}
        open={modalVisible}
        onOk={handleModalSubmit}
        onCancel={handleModalClose}
        confirmLoading={modalLoading}
        width={800}
        okText="保存"
        cancelText="取消"
        destroyOnClose
      >
        <Form form={form} layout="vertical">
          <Form.Item name="id" hidden>
            <Input />
          </Form.Item>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0 16px' }}>
            <Form.Item
              label="主要诊断代码"
              name="principalDiagnosis"
              rules={[{ required: true, message: '请输入主要诊断代码' }]}
            >
              <Input placeholder="请输入主要诊断代码" />
            </Form.Item>

            <Form.Item
              label="主要诊断名称"
              name="principalDiagnosisName"
              rules={[{ required: true, message: '请输入主要诊断名称' }]}
            >
              <Input placeholder="请输入主要诊断名称" />
            </Form.Item>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0 16px' }}>
            <Form.Item label="主要手术代码" name="majorProcedure">
              <Input placeholder="请输入主要手术代码" />
            </Form.Item>

            <Form.Item label="主要手术名称" name="majorProcedureName">
              <Input placeholder="请输入主要手术名称" />
            </Form.Item>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0 16px' }}>
            <Form.Item label="相关手术代码" name="secondaryProcedure">
              <Input placeholder="请输入相关手术代码" />
            </Form.Item>

            <Form.Item label="相关手术名称" name="secondaryProcedureName">
              <Input placeholder="请输入相关手术名称" />
            </Form.Item>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0 16px' }}>
            <Form.Item
              label="省"
              name="provinceDr"
              rules={[{ required: true, message: '请选择省' }]}
            >
              <Select
                placeholder="请选择省"
                onChange={handleModalProvinceChange}
                loading={modalProvinceLoading}
              >
                {modalProvinceList.map(item => (
                  <Option key={item.id} value={item.id}>{item.descripts}</Option>
                ))}
              </Select>
            </Form.Item>

            <Form.Item
              label="市"
              name="cityDr"
              rules={[{ required: true, message: '请选择市' }]}
            >
              <Select
                placeholder="请选择市"
                disabled={!form.getFieldValue('provinceDr')}
                loading={modalCityLoading}
              >
                {modalCityList.map(item => (
                  <Option key={item.id} value={item.id}>{item.descripts}</Option>
                ))}
              </Select>
            </Form.Item>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0 16px' }}>
            <Form.Item label="就医地区划代码" name="mdtrtArea">
              <Input placeholder="请输入就医地区划代码" />
            </Form.Item>

            <Form.Item
              label="医疗机构等级"
              name="medinsLv"
              rules={[{ required: true, message: '请选择医疗机构等级' }]}
            >
              <Select placeholder="请选择">
                {medinsLvOptions.map(item => (
                  <Option key={item.value} value={item.value}>{item.label}</Option>
                ))}
              </Select>
            </Form.Item>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0 16px' }}>
            <Form.Item
              label="基准分值"
              name="scoreValue"
              rules={[{ required: true, message: '请输入基准分值' }]}
            >
              <InputNumber
                placeholder="请输入基准分值"
                style={{ width: '100%' }}
                precision={2}
                min={0}
              />
            </Form.Item>

            <Form.Item label="调节系数" name="adjustCoefficient">
              <InputNumber
                placeholder="请输入调节系数"
                style={{ width: '100%' }}
                precision={4}
                min={0}
              />
            </Form.Item>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '0 16px' }}>
            <Form.Item label="一级调节系数" name="primaryAdjustCoefficient">
              <InputNumber
                placeholder="一级调节系数"
                style={{ width: '100%' }}
                precision={4}
                min={0}
              />
            </Form.Item>

            <Form.Item label="二级调节系数" name="secondaryAdjustCoefficient">
              <InputNumber
                placeholder="二级调节系数"
                style={{ width: '100%' }}
                precision={4}
                min={0}
              />
            </Form.Item>

            <Form.Item label="三级调节系数" name="thirdAdjustCoefficient">
              <InputNumber
                placeholder="三级调节系数"
                style={{ width: '100%' }}
                precision={4}
                min={0}
              />
            </Form.Item>
          </div>
        </Form>
      </Modal>
    </div>
  );
};

export default DIPCoreAlgorithmConfig;