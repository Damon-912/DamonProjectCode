import React, { useState, useEffect, useCallback, useRef } from 'react';
import {
  Card, Table, Button, Input, InputNumber, Select, Space, Modal, Form,
  Row, Col, Tag, message, Popconfirm, DatePicker, Upload,
  Steps, Alert, Statistic, Divider, Typography, List, Result, Modal as ImportModal
} from 'antd';
import {
  PlusOutlined, SearchOutlined, ReloadOutlined, DeleteOutlined, EditOutlined,
  UploadOutlined, DownloadOutlined, EyeOutlined, FileTextOutlined,
  CheckCircleOutlined, CloseCircleOutlined, WarningOutlined,
  FileExcelOutlined, ArrowRightOutlined, ArrowLeftOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { UploadFile } from 'antd/es/upload/interface';
import dayjs from 'dayjs';
import {
  queryCoreAlgorithm, saveCoreAlgorithm, deleteCoreAlgorithm,
  getProvinceData, getCityData, queryHospitalInfo,
  downloadDrgCoreAlgorithmTemplate,
  previewDrgCoreAlgorithmImport,
  confirmDrgCoreAlgorithmImport,
  type CoreAlgorithmItem, type SaveCoreAlgorithmParams,
  type ProvinceItem, type CityItem, type HospitalInfoItem,
  type DrgCoreAlgorithmImportPreviewItem,
  type DrgCoreAlgorithmImportResult,
  type DrgCoreAlgorithmImportParams
} from '../../api/basicData';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;

const CoreAlgorithmConfig: React.FC = () => {
  const [data, setData] = useState<CoreAlgorithmItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);

  // 查询条件
  const [drg, setDrg] = useState('');
  const [fixmedinsName, setFixmedinsName] = useState('');
  const [provinceId, setProvinceId] = useState('');
  const [cityId, setCityId] = useState('');
  const [queryInsuType, setQueryInsuType] = useState('');
  const [status, setStatus] = useState('');
  const [year, setYear] = useState('');

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

  // ==================== 导入功能状态 ====================
  // 导入弹窗显示状态
  const [importModalVisible, setImportModalVisible] = useState(false);
  // 当前步骤（0:上传, 1:预览, 2:结果）
  const [importStep, setImportStep] = useState(0);
  // 导入加载状态
  const [importLoading, setImportLoading] = useState(false);
  // 导入表单
  const [importForm] = Form.useForm();
  // 导入省市选择
  const [importProvinceList, setImportProvinceList] = useState<ProvinceItem[]>([]);
  const [importCityList, setImportCityList] = useState<CityItem[]>([]);
  const [importHospitalList, setImportHospitalList] = useState<HospitalInfoItem[]>([]);
  const [importProvinceLoading, setImportProvinceLoading] = useState(false);
  const [importCityLoading, setImportCityLoading] = useState(false);
  const [importHospitalLoading, setImportHospitalLoading] = useState(false);
  // 上传文件列表
  const [fileList, setFileList] = useState<UploadFile[]>([]);
  // 预览数据
  const [previewData, setPreviewData] = useState<DrgCoreAlgorithmImportPreviewItem[]>([]);
  const [previewStats, setPreviewStats] = useState({ total: 0, valid: 0, invalid: 0, duplicate: 0 });
  // 导入结果
  const [importResult, setImportResult] = useState<DrgCoreAlgorithmImportResult | null>(null);
  // 当前文件内容（Base64）
  const fileContentRef = useRef<string>('');
  const fileNameRef = useRef<string>('');

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
          year: year || undefined,
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
  }, [drg, fixmedinsName, provinceId, cityId, queryInsuType, status, year, currentPage, pageSize]);

  useEffect(() => {
    fetchData(1, pageSize);
    setCurrentPage(1);
  }, [drg, fixmedinsName, provinceId, cityId, queryInsuType, status, year]);

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
    setYear('');
  };

  // ==================== 导入功能方法 ====================

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

    // 清空省市列表
    setImportCityList([]);
    setImportHospitalList([]);

    // 加载省下拉数据
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
      importHospitalId: undefined,
    });
    setImportCityList([]);
    setImportHospitalList([]);

    if (!value) {
      return;
    }
    const fetchCityData = async () => {
      setImportCityLoading(true);
      try {
        const res = await getCityData(value);
        if (res.errorCode === '0' && res.result) {
          setImportCityList(res.result);
        }
      } finally {
        setImportCityLoading(false);
      }
    };
    fetchCityData();
  };

  // 导入弹窗市选择变化 - 根据省市过滤医疗机构
  const handleImportCityChange = (value: string) => {
    importForm.setFieldsValue({
      importHospitalId: undefined,
    });
    setImportHospitalList([]);

    const provinceId = importForm.getFieldValue('importProvinceId');
    if (!value || !provinceId) {
      return;
    }
    const fetchFilteredHospitalData = async () => {
      setImportHospitalLoading(true);
      try {
        // 直接传入省市的id进行过滤
        const res = await queryHospitalInfo({
          active: 'Y',
          descripts: '',
          provinceID: provinceId,
          cityID: value
        });
        if (res.errorCode === '0' && res.result) {
          setImportHospitalList(res.result);
        }
      } finally {
        setImportHospitalLoading(false);
      }
    };
    fetchFilteredHospitalData();
  };

  // 导入弹窗医疗机构选择变化 - 填充机构信息
  const handleImportHospitalChange = (value: string) => {
    const selected = importHospitalList.find(h => h.code === value);
    if (selected) {
      importForm.setFieldsValue({
        importHospitalId: value,
      });
    } else {
      importForm.setFieldsValue({
        importHospitalId: undefined,
      });
    }
  };

  // 下载导入模板
  const handleDownloadTemplate = async () => {
    try {
      const res = await downloadDrgCoreAlgorithmTemplate();
      if (res.errorCode === '0' && res.result) {
        // Base64解码并下载
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

    // 读取文件内容为Base64（正确处理中文字符）
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
    return false; // 阻止自动上传
  };

  // 预览导入数据
  const handlePreviewImport = async () => {
    // 直接从表单获取值
    const provinceId = importForm.getFieldValue('importProvinceId');
    const cityId = importForm.getFieldValue('importCityId');
    const hospitalId = importForm.getFieldValue('importHospitalId');

    if (!provinceId) {
      message.error('请先选择省');
      return;
    }
    if (!cityId) {
      message.error('请先选择市');
      return;
    }
    if (!hospitalId) {
      message.error('请先选择医疗机构');
      return;
    }
    if (fileList.length === 0) {
      message.error('请先上传导入文件');
      return;
    }

    // 获取市和医疗机构的信息
    const selectedCity = importCityList.find(c => c.id === cityId);
    const selectedHospital = importHospitalList.find(h => h.code === hospitalId);

    const params: DrgCoreAlgorithmImportParams = {
      provinceID: provinceId,
      cityID: cityId,
      mdtrtArea: selectedCity?.code || '',
      fixmedinsCode: hospitalId,
      fixmedinsName: selectedHospital?.descripts || '',
      medinsLv: selectedHospital?.medinsLv || selectedHospital?.MedinsLv || '',
      fileData: fileContentRef.current,
      fileName: fileNameRef.current,
      year: importForm.getFieldValue('importYear') || '',
    };

    try {
      setImportLoading(true);
      const res = await previewDrgCoreAlgorithmImport(params);

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
    // 直接从表单获取值，避免getFieldsValue可能返回空值的问题
    const provinceId = importForm.getFieldValue('importProvinceId');
    const cityId = importForm.getFieldValue('importCityId');
    const hospitalId = importForm.getFieldValue('importHospitalId');

    // 验证省市和医疗机构是否已选择
    if (!provinceId) {
      message.error('请先选择省');
      return;
    }
    if (!cityId) {
      message.error('请先选择市');
      return;
    }
    if (!hospitalId) {
      message.error('请先选择医疗机构');
      return;
    }

    // 获取市的信息
    const selectedCity = importCityList.find(c => c.id === cityId);
    // 从医疗机构列表中获取名称和等级
    const selectedHospital = importHospitalList.find(h => h.code === hospitalId);

    const params: DrgCoreAlgorithmImportParams = {
      provinceID: String(provinceId),
      cityID: String(cityId),
      mdtrtArea: selectedCity?.code || '',
      fixmedinsCode: String(hospitalId),
      fixmedinsName: selectedHospital?.descripts || '',
      medinsLv: selectedHospital?.medinsLv || selectedHospital?.MedinsLv || '',
      fileData: fileContentRef.current,
      fileName: fileNameRef.current,
      year: importForm.getFieldValue('importYear') || '',
    };

    try {
      setImportLoading(true);
      const res = await confirmDrgCoreAlgorithmImport(params);

      if (res.result) {
        setImportResult(res.result);
        setImportStep(2);
        // 刷新列表数据
        fetchData(1, pageSize);
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
      startDate: dayjs().startOf('year'),
      year: dayjs().year(),
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
        year: record.year || '',
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
        year: values.year || '',
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
      title: '年份',
      dataIndex: 'year',
      width: 50,
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

  // 预览表格列定义
  const previewColumns: ColumnsType<DrgCoreAlgorithmImportPreviewItem> = [
    { title: '行号', dataIndex: 'rowNum', width: 60 },
    { title: 'DRG代码', dataIndex: 'drgCode', width: 100 },
    { title: 'DRG描述', dataIndex: 'drgDesc', ellipsis: true },
    { title: '基准点数', dataIndex: 'points', width: 90, align: 'right' },
    { title: '预估点值', dataIndex: 'pipValue', width: 90, align: 'right' },
    { title: '差异系数', dataIndex: 'dgdov', width: 80, align: 'right' },
    { title: '支付标准', dataIndex: 'payStandard', width: 90, align: 'right' },
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
            <InputNumber
              placeholder="年份"
              value={year ? Number(year) : undefined}
              onChange={v => setYear(v ? String(v) : '')}
              style={{ width: 100 }}
              min={2020}
              max={2099}
              precision={0}
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
          <Space>
            <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增配置</Button>
            <Button type="primary" icon={<UploadOutlined />} onClick={handleOpenImport}>导入</Button>
          </Space>
          <span>共 {total} 条记录</span>
        </div>
        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1570 }}
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
              <Col span={8}>
                <Form.Item name="year" label="分组方案年份" rules={[{ required: true, message: '请输入年份' }]}>
                  <InputNumber placeholder="请输入年份" style={{ width: '100%' }} min={2020} max={2099} precision={0} />
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

      {/* 导入弹窗 */}
      <ImportModal
        title="DRG核心算法配置导入"
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
              message="导入前请先选择省市和医疗机构"
              description="导入的DRG算法配置将归属到选定的省、市和医疗机构，请仔细确认。"
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
                    name="importHospitalId"
                    label="医疗机构"
                    rules={[{ required: true, message: '请选择医疗机构' }]}
                  >
                    <Select
                      placeholder="请选择医疗机构"
                      loading={importHospitalLoading}
                      showSearch
                      optionFilterProp="children"
                      onChange={handleImportHospitalChange}
                      filterOption={(input, option) =>
                        (option?.children as unknown as string)?.toLowerCase().includes(input.toLowerCase())
                      }
                      disabled={!importForm.getFieldValue('importProvinceId') || !importForm.getFieldValue('importCityId')}
                    >
                      {importHospitalList.map(item => (
                        <Option key={item.code} value={item.code}>
                          {item.descripts} ({item.code})
                        </Option>
                      ))}
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
                    <li>必填列：DRG代码(DRGCode)、DRG描述(DRGDesc)、基准点数(Points)、预估点值(PipValue)、病组差异系数(DGDOV)、支付标准(PayStandard)</li>
                    <li>字段说明：DRGCode=DRG代码、DRGDesc=DRG描述、Points=基准点数、PipValue=预估点值、DGDOV=病组差异系数、PayStandard=支付标准</li>
                    <li>重复处理：DRG代码+行政区划+机构代码相同则更新，否则新增</li>
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
                        <Typography.Text code>{item.drgCode || '空代码'}</Typography.Text>
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
      </ImportModal>
    </div>
  );
};

export default CoreAlgorithmConfig;
