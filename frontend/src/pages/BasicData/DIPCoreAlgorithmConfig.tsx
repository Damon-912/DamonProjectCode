/**
 * DIP核心算法配置页面
 * 功能：列表查询、新增/编辑、删除、导入
 */

import React, { useState, useEffect, useCallback, useRef } from 'react';
import {
  Table, Button, Card, Space, message, Popconfirm, Form, Select, Input, Row, Col, Modal, InputNumber,
  Upload, Steps, Alert, Statistic, Divider, Typography, List, Result, Tag
} from 'antd';
import {
  PlusOutlined, SearchOutlined, ReloadOutlined, UploadOutlined, DownloadOutlined, EyeOutlined,
  CheckCircleOutlined, CloseCircleOutlined, WarningOutlined, FileExcelOutlined, ArrowRightOutlined, ArrowLeftOutlined
} from '@ant-design/icons';
import type { UploadFile } from 'antd/es/upload/interface';
import type { ColumnsType } from 'antd/es/table';
import dayjs from 'dayjs';
import CustomPagination from '../../components/CustomPagination';
import {
  queryDipCoreAlgorithm, deleteDipCoreAlgorithm,
  saveDipCoreAlgorithm,
  getProvinceData, getCityData,
  downloadDipCoreAlgorithmTemplate,
  previewDipCoreAlgorithmImport,
  confirmDipCoreAlgorithmImport,
  type DipCoreAlgorithmItem,
  type DipCoreAlgorithmImportPreviewItem,
  type DipCoreAlgorithmImportResult,
  type DipCoreAlgorithmImportParams,
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
  const [year, setYear] = useState('');

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

  // ==================== 导入功能状态 ====================
  const [importModalVisible, setImportModalVisible] = useState(false);
  const [importStep, setImportStep] = useState(0);
  const [importLoading, setImportLoading] = useState(false);
  const [importForm] = Form.useForm();
  const [importProvinceList, setImportProvinceList] = useState<ProvinceItem[]>([]);
  const [importCityList, setImportCityList] = useState<CityItem[]>([]);
  const [importProvinceLoading, setImportProvinceLoading] = useState(false);
  const [importCityLoading, setImportCityLoading] = useState(false);
  const [fileList, setFileList] = useState<UploadFile[]>([]);
  const [previewData, setPreviewData] = useState<DipCoreAlgorithmImportPreviewItem[]>([]);
  const [previewStats, setPreviewStats] = useState({ total: 0, valid: 0, invalid: 0, duplicate: 0 });
  const [importResult, setImportResult] = useState<DipCoreAlgorithmImportResult | null>(null);
  const fileContentRef = useRef<string>('');
  const fileNameRef = useRef<string>('');

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
        year: year || undefined,
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
  }, [principalDiagnosis, principalDiagnosisName, majorProcedure, majorProcedureName, provinceId, cityId, medinsLv, year, currentPage, pageSize]);

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
    setYear('');
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
    setTimeout(() => {
      form.setFieldsValue({ year: dayjs().year() });
    }, 0);
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
            year: record.year || '',
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
          year: record.year || '',
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

  // ========== 导入功能方法 ====================

  // 打开导入弹窗
  const handleOpenImport = async () => {
    setImportModalVisible(true);
    setImportStep(0);
    setFileList([]);
    setPreviewData([]);
    setImportResult(null);
    importForm.resetFields();
    fileContentRef.current = '';
    fileNameRef.current = '';
    setImportCityList([]);

    setImportProvinceLoading(true);
    try {
      const res = await getProvinceData();
      if (res.errorCode === '0' && res.result) {
        setImportProvinceList(res.result);
      }
    } finally {
      setImportProvinceLoading(false);
    }
  };

  // 导入弹窗省选择变化
  const handleImportProvinceChange = (value: string) => {
    importForm.setFieldsValue({
      importProvinceId: value,
      importCityId: undefined,
    });
    setImportCityList([]);

    if (!value) {
      return;
    }
    setImportCityLoading(true);
    getCityData(value).then(res => {
      if (res.errorCode === '0' && res.result) {
        setImportCityList(res.result);
      }
      setImportCityLoading(false);
    });
  };

  // 导入弹窗市选择变化
  const handleImportCityChange = (value: string) => {
    importForm.setFieldsValue({
      importCityId: value,
    });
  };

  // 下载导入模板
  const handleDownloadTemplate = async () => {
    try {
      const res = await downloadDipCoreAlgorithmTemplate();
      if (res.errorCode === '0' && res.result) {
        const byteString = atob(res.result.fileData);
        const ab = new ArrayBuffer(byteString.length);
        const ia = new Uint8Array(ab);
        for (let i = 0; i < byteString.length; i++) {
          ia[i] = byteString.charCodeAt(i);
        }
        const blob = new Blob([ab], { type: res.result.contentType || 'text/csv' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = res.result.fileName;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
        message.success('模板下载成功');
      } else {
        message.error(res.errorMessage || '下载模板失败');
      }
    } catch (error: any) {
      message.error('下载模板失败：' + (error.message || '网络异常'));
    }
  };

  // 文件上传前处理
  const beforeUpload = (file: UploadFile) => {
    const rawFile = file.originFileObj || file;
    const isExcel = rawFile.type === 'application/vnd.open-excel' ||
                    rawFile.type === 'application/vnd.ms-excel' ||
                    rawFile.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
                    rawFile.name?.endsWith('.csv');
    if (!isExcel) {
      message.error('请上传Excel或CSV文件！');
      return false;
    }
    const isLt10M = (rawFile.size || 0) / 1024 / 1024 < 10;
    if (!isLt10M) {
      message.error('文件大小不能超过10MB！');
      return false;
    }

    const reader = new FileReader();
    reader.onload = (e) => {
      const arrayBuffer = e.target?.result as ArrayBuffer;
      const bytes = new Uint8Array(arrayBuffer);
      let binary = '';
      for (let i = 0; i < bytes.byteLength; i++) {
        binary += String.fromCharCode(bytes[i]);
      }
      const base64Content = btoa(binary);
      fileContentRef.current = base64Content;
      fileNameRef.current = rawFile.name || '';
    };
    reader.readAsArrayBuffer(rawFile as Blob);

    setFileList([file]);
    return false;
  };

  // 预览导入数据
  const handlePreviewImport = async () => {
    const provinceId = importForm.getFieldValue('importProvinceId');
    const cityId = importForm.getFieldValue('importCityId');
    const medinsLv = importForm.getFieldValue('importMedinsLv');

    if (!provinceId) {
      message.error('请先选择省');
      return;
    }
    if (!cityId) {
      message.error('请先选择市');
      return;
    }
    if (!medinsLv) {
      message.error('请先选择机构等级');
      return;
    }
    if (fileList.length === 0) {
      message.error('请先上传导入文件');
      return;
    }

    const selectedCity = importCityList.find(c => c.id === cityId);

    const params: DipCoreAlgorithmImportParams = {
      provinceID: provinceId,
      cityID: cityId,
      mdtrtArea: selectedCity?.code || '',
      medinsLv: medinsLv,
      fileData: fileContentRef.current,
      fileName: fileNameRef.current,
      year: importForm.getFieldValue('importYear') || '',
    };

    try {
      setImportLoading(true);
      const res = await previewDipCoreAlgorithmImport(params);

      if (res.errorCode === '0' && res.result) {
        setPreviewData(res.result.previewList || []);
        setPreviewStats({
          total: res.result.totalCount,
          valid: res.result.validCount,
          invalid: res.result.invalidCount,
          duplicate: res.result.duplicateCount
        });
        setImportStep(1);
      } else {
        message.error(res.errorMessage || '预览失败');
      }
    } catch (error: any) {
      message.error('预览失败：' + (error.message || '网络异常'));
    } finally {
      setImportLoading(false);
    }
  };

  // 确认导入
  const handleConfirmImport = async () => {
    const provinceId = importForm.getFieldValue('importProvinceId');
    const cityId = importForm.getFieldValue('importCityId');
    const medinsLv = importForm.getFieldValue('importMedinsLv');

    if (!provinceId) {
      message.error('请先选择省');
      return;
    }
    if (!cityId) {
      message.error('请先选择市');
      return;
    }
    if (!medinsLv) {
      message.error('请先选择机构等级');
      return;
    }

    const selectedCity = importCityList.find(c => c.id === cityId);

    const params: DipCoreAlgorithmImportParams = {
      provinceID: String(provinceId),
      cityID: String(cityId),
      mdtrtArea: selectedCity?.code || '',
      medinsLv: medinsLv,
      fileData: fileContentRef.current,
      fileName: fileNameRef.current,
      year: importForm.getFieldValue('importYear') || '',
    };

    try {
      setImportLoading(true);
      const res = await confirmDipCoreAlgorithmImport(params);

      if (res.result) {
        setImportResult(res.result);
        setImportStep(2);
        fetchData();
      } else {
        message.error(res.errorMessage || '导入失败');
      }
    } catch (error: any) {
      message.error('导入失败：' + (error.message || '网络异常'));
    } finally {
      setImportLoading(false);
    }
  };

  // 关闭导入弹窗
  const handleCloseImport = () => {
    setImportModalVisible(false);
    setImportStep(0);
    setFileList([]);
    setPreviewData([]);
    setImportResult(null);
    importForm.resetFields();
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
      title: '年份',
      dataIndex: 'year',
      key: 'year',
      width: 80,
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

  // 预览表格列定义
  const previewColumns: ColumnsType<DipCoreAlgorithmImportPreviewItem> = [
    { title: '行号', dataIndex: 'rowNum', width: 60 },
    { title: '主要诊断代码', dataIndex: 'principalDiagnosis', width: 120 },
    { title: '主要诊断名称', dataIndex: 'principalDiagnosisName', width: 150, ellipsis: true },
    { title: '主要手术代码', dataIndex: 'majorProcedure', width: 120 },
    { title: '主要手术名称', dataIndex: 'majorProcedureName', width: 150, ellipsis: true },
    { title: '基准分值', dataIndex: 'scoreValue', width: 90, align: 'right' },
    { title: '调节系数', dataIndex: 'adjustCoefficient', width: 90, align: 'right' },
    {
      title: '状态',
      dataIndex: 'status',
      width: 80,
      render: (status: string) => {
        if (status === 'valid') {
          return <Tag color="success" icon={<CheckCircleOutlined />}>正常</Tag>;
        } else if (status === 'duplicate') {
          return <Tag color="warning" icon={<WarningOutlined />}>重复</Tag>;
        } else {
          return <Tag color="error" icon={<CloseCircleOutlined />}>错误</Tag>;
        }
      }
    },
    {
      title: '备注',
      dataIndex: 'errorMsg',
      ellipsis: true,
      render: (text: string) => text || '-'
    }
  ];

  return (
    <div style={{ padding: 10 }}>
      <Card>
        {/* 查询表单 */}
        <Form layout="vertical" style={{ marginBottom: 1 }}>
          <Row gutter={8}>
            <Col span={3}>
              <Form.Item label="主要诊断代码">
                <Input
                  placeholder="请输入主要诊断代码"
                  value={principalDiagnosis}
                  onChange={(e) => setPrincipalDiagnosis(e.target.value)}
                />
              </Form.Item>
            </Col>
            <Col span={3}>
              <Form.Item label="主要诊断名称">
                <Input
                  placeholder="请输入主要诊断名称"
                  value={principalDiagnosisName}
                  onChange={(e) => setPrincipalDiagnosisName(e.target.value)}
                />
              </Form.Item>
            </Col>
            <Col span={3}>
              <Form.Item label="主要手术代码">
                <Input
                  placeholder="请输入主要手术代码"
                  value={majorProcedure}
                  onChange={(e) => setMajorProcedure(e.target.value)}
                />
              </Form.Item>
            </Col>
            <Col span={3}>
              <Form.Item label="主要手术名称">
                <Input
                  placeholder="请输入主要手术名称"
                  value={majorProcedureName}
                  onChange={(e) => setMajorProcedureName(e.target.value)}
                />
              </Form.Item>
            </Col>
            <Col span={2}>
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
            <Col span={2}>
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
            <Col span={2}>
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
            <Col span={2}>
              <Form.Item label="年份">
                <InputNumber
                  placeholder="全部"
                  value={year ? Number(year) : undefined}
                  onChange={v => setYear(v ? String(v) : '')}
                  style={{ width: '100%' }}
                  min={2020}
                  max={2099}
                  precision={0}
                />
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
        <Row style={{ marginBottom: 2 }}>
          <Col>
            <Space>
              <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>
                新增配置
              </Button>
              <Button type="primary" icon={<UploadOutlined />} onClick={handleOpenImport}>
                导入
              </Button>
            </Space>
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

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0 16px' }}>
            <Form.Item
              label="分组方案年份"
              name="year"
              rules={[{ required: true, message: '请输入年份' }]}
            >
              <InputNumber placeholder="请输入年份" style={{ width: '100%' }} min={2020} max={2099} precision={0} />
            </Form.Item>
          </div>
        </Form>
      </Modal>

      {/* 导入弹窗 */}
      <Modal
        title="DIP核心算法配置导入"
        open={importModalVisible}
        onCancel={handleCloseImport}
        width={850}
        footer={null}
        destroyOnClose
      >
        <Steps
          current={importStep}
          style={{ marginBottom: 24 }}
          items={[
            { title: '上传文件', icon: <UploadOutlined /> },
            { title: '数据预览', icon: <EyeOutlined /> },
            { title: '导入结果', icon: <CheckCircleOutlined /> }
          ]}
        />

        {/* 步骤1：上传文件 */}
        {importStep === 0 && (
          <div>
            <Alert
              message="导入前请先选择省市"
              description="导入的DIP核心算法配置将归属到选定的省市，请仔细确认。"
              type="warning"
              showIcon
              style={{ marginBottom: 16 }}
            />
            <Form form={importForm} layout="vertical">
              <Row gutter={16}>
                <Col span={8}>
                  <Form.Item
                    name="importProvinceId"
                    label="省"
                    rules={[{ required: true, message: '请选择省' }]}
                  >
                    <Select
                      placeholder="请选择省"
                      loading={importProvinceLoading}
                      showSearch
                      optionFilterProp="children"
                      onChange={handleImportProvinceChange}
                    >
                      {importProvinceList.map(item => (
                        <Option key={item.id} value={item.id}>{item.descripts}</Option>
                      ))}
                    </Select>
                  </Form.Item>
                </Col>
                <Col span={8}>
                  <Form.Item
                    name="importCityId"
                    label="市"
                    rules={[{ required: true, message: '请选择市' }]}
                  >
                    <Select
                      placeholder="请选择市"
                      loading={importCityLoading}
                      showSearch
                      optionFilterProp="children"
                      onChange={handleImportCityChange}
                      disabled={!importForm.getFieldValue('importProvinceId')}
                    >
                      {importCityList.map(item => (
                        <Option key={item.id} value={item.id}>{item.descripts}</Option>
                      ))}
                    </Select>
                  </Form.Item>
                </Col>
                <Col span={8}>
                  <Form.Item
                    name="importMedinsLv"
                    label="机构等级"
                    rules={[{ required: true, message: '请选择机构等级' }]}
                  >
                    <Select placeholder="请选择机构等级">
                      <Option value="1">一级</Option>
                      <Option value="2">二级</Option>
                      <Option value="3">三级</Option>
                    </Select>
                  </Form.Item>
                </Col>
              </Row>

              <Row gutter={16}>
                <Col span={8}>
                  <Form.Item
                    name="importYear"
                    label="分组方案年份"
                    rules={[{ required: true, message: '请输入年份' }]}
                    initialValue={dayjs().year()}
                  >
                    <InputNumber placeholder="请输入年份" style={{ width: '100%' }} min={2020} max={2099} precision={0} />
                  </Form.Item>
                </Col>
              </Row>

              <Divider />

              <Form.Item label="导入文件" required>
                <Upload.Dragger
                  fileList={fileList}
                  beforeUpload={beforeUpload}
                  onRemove={() => {
                    setFileList([]);
                    fileContentRef.current = '';
                    fileNameRef.current = '';
                  }}
                  accept=".xlsx,.xls,.csv"
                  maxCount={1}
                >
                  <p className="ant-upload-drag-icon">
                    <FileExcelOutlined style={{ color: '#52c41a' }} />
                  </p>
                  <p className="ant-upload-text">点击或拖拽文件到此区域上传</p>
                  <p className="ant-upload-hint">
                    仅支持.csv 格式，文件大小不超过10MB
                  </p>
                </Upload.Dragger>
              </Form.Item>

              <div style={{ textAlign: 'center' }}>
                <Button icon={<DownloadOutlined />} onClick={handleDownloadTemplate}>
                  下载导入模板
                </Button>
              </div>

              <Divider />

              <Alert
                message="导入说明"
                description={
                  <ul style={{ margin: 0, paddingLeft: 16 }}>
                    <li>必填列：主要诊断代码(PrincipalDiagnosis)、主要诊断名称(PrincipalDiagnosisName)、基准分值(ScoreValue)</li>
                    <li>导入设置：省、市、机构等级由上方选择决定</li>
                    <li>可选列：主要手术代码/名称、相关手术代码/名称、调节系数、一/二/三级调节系数</li>
                    <li>重复处理：主要诊断代码+省+市+机构等级相同则更新，否则新增</li>
                    <li>模板规范：模板列名不可变更</li>
                  </ul>
                }
                type="info"
                showIcon
              />
            </Form>

            <div style={{ marginTop: 24, textAlign: 'right' }}>
              <Button onClick={handleCloseImport}>取消</Button>
              <Button
                type="primary"
                style={{ marginLeft: 8 }}
                onClick={handlePreviewImport}
                loading={importLoading}
                disabled={fileList.length === 0}
              >
                下一步：预览 <ArrowRightOutlined />
              </Button>
            </div>
          </div>
        )}

        {/* 步骤2：数据预览 */}
        {importStep === 1 && (
          <div>
            <Alert
              message={
                <Space>
                  <span>数据概览：</span>
                  <Typography.Text>共计 <Typography.Text strong>{previewStats.total}</Typography.Text> 条</Typography.Text>
                  <Divider type="vertical" />
                  <Typography.Text type="success">正常 <Typography.Text strong>{previewStats.valid}</Typography.Text> 条</Typography.Text>
                  <Divider type="vertical" />
                  <Typography.Text type="warning">重复 <Typography.Text strong>{previewStats.duplicate}</Typography.Text> 条</Typography.Text>
                  <Divider type="vertical" />
                  <Typography.Text type="danger">异常 <Typography.Text strong>{previewStats.invalid}</Typography.Text> 条</Typography.Text>
                </Space>
              }
              type="info"
              showIcon
              style={{ marginBottom: 16 }}
            />

            <Table
              columns={previewColumns}
              dataSource={previewData}
              rowKey="rowNum"
              size="small"
              scroll={{ y: 300 }}
              pagination={false}
            />

            <div style={{ marginTop: 16 }}>
              <Alert
                message="确认导入后将执行以下操作"
                description={
                  <ul style={{ margin: 0, paddingLeft: 16 }}>
                    <li>正常数据：直接导入</li>
                    <li>重复数据：更新现有记录</li>
                    <li>异常数据：跳过不导入</li>
                  </ul>
                }
                type="warning"
                showIcon
              />
            </div>

            <div style={{ marginTop: 24, textAlign: 'right' }}>
              <Button onClick={() => setImportStep(0)} icon={<ArrowLeftOutlined />}>
                上一步
              </Button>
              <Button
                type="primary"
                style={{ marginLeft: 8 }}
                onClick={handleConfirmImport}
                loading={importLoading}
              >
                确认导入
              </Button>
            </div>
          </div>
        )}

        {/* 步骤3：导入结果 */}
        {importStep === 2 && importResult && (
          <div>
            <Result
              status={importResult.failCount === 0 ? 'success' : 'warning'}
              title={importResult.failCount === 0 ? '导入成功' : '导入完成（部分失败）'}
              subTitle={`总计 ${importResult.totalCount} 条数据，成功 ${importResult.successCount} 条，失败 ${importResult.failCount} 条`}
            />

            <Row gutter={16} style={{ marginBottom: 16 }}>
              <Col span={6}>
                <Card size="small">
                  <Statistic
                    title="总记录数"
                    value={importResult.totalCount}
                  />
                </Card>
              </Col>
              <Col span={6}>
                <Card size="small">
                  <Statistic
                    title="成功导入"
                    value={importResult.successCount}
                    valueStyle={{ color: '#52c41a' }}
                  />
                </Card>
              </Col>
              <Col span={6}>
                <Card size="small">
                  <Statistic
                    title="新增记录"
                    value={importResult.newCount}
                    valueStyle={{ color: '#1890ff' }}
                  />
                </Card>
              </Col>
              <Col span={6}>
                <Card size="small">
                  <Statistic
                    title="更新记录"
                    value={importResult.duplicateCount}
                    valueStyle={{ color: '#faad14' }}
                  />
                </Card>
              </Col>
            </Row>

            {importResult.failCount > 0 && (
              <>
                <Divider />
                <Typography.Title level={5}>失败明细</Typography.Title>
                <List
                  size="small"
                  bordered
                  dataSource={importResult.failList}
                  renderItem={item => (
                    <List.Item>
                      <Space>
                        <Typography.Text type="secondary">行 {item.rowNum}</Typography.Text>
                        <Typography.Text code>{item.principalDiagnosis || '空代码'}</Typography.Text>
                        <Typography.Text type="danger">{item.errorMsg}</Typography.Text>
                      </Space>
                    </List.Item>
                  )}
                  style={{ maxHeight: 200, overflow: 'auto' }}
                />
              </>
            )}

            <div style={{ marginTop: 24, textAlign: 'right' }}>
              <Button onClick={handleCloseImport} type="primary">
                完成
              </Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};

export default DIPCoreAlgorithmConfig;