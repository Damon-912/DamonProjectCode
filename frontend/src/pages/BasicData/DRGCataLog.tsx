import { useState, useEffect, useRef } from 'react';
import {
  Card, Form, Input, Select, Button, Space, Table, Row, Col,
  Tag, message, Modal, Popconfirm, Divider, Alert, Statistic,
  Upload, Steps, Result, List, Typography
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, FileTextOutlined,
  PlusOutlined, DeleteOutlined, EditOutlined, UploadOutlined,
  DownloadOutlined, EyeOutlined, CheckCircleOutlined,
  CloseCircleOutlined, WarningOutlined, FileExcelOutlined,
  ArrowRightOutlined, ArrowLeftOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { UploadFile } from 'antd/es/upload/interface';
import {
  queryHBDRGCataLog,
  saveHBDRGCataLog,
  deleteHBDRGCataLog,
  getProvinceData,
  getCityData,
  HBDRGCataLogItem,
  QueryHBDRGCataLogParams,
  SaveHBDRGCataLogParams,
  ProvinceItem,
  CityItem,
  downloadDrgTemplate,
  previewDrgImport,
  confirmDrgImport,
  DrgImportPreviewItem,
  DrgImportPreviewResult,
  DrgImportResult,
} from '@/api/basicData';
import CustomPagination from '@/components/CustomPagination';

const { Option } = Select;
const { Text, Title } = Typography;

/**
 * DRG目录信息表页面
 * 管理各地方DRG目录信息
 */
const DRGCataLog: React.FC = () => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [dataSource, setDataSource] = useState<HBDRGCataLogItem[]>([]);
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
  const [editRecord, setEditRecord] = useState<HBDRGCataLogItem | null>(null);
  const [editAdmvs, setEditAdmvs] = useState<string>('');

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
  const [importProvinceLoading, setImportProvinceLoading] = useState(false);
  const [importCityLoading, setImportCityLoading] = useState(false);
  // 上传文件列表
  const [fileList, setFileList] = useState<UploadFile[]>([]);
  // 预览数据
  const [previewData, setPreviewData] = useState<DrgImportPreviewItem[]>([]);
  const [previewStats, setPreviewStats] = useState({ total: 0, valid: 0, invalid: 0, duplicate: 0 });
  // 导入结果
  const [importResult, setImportResult] = useState<DrgImportResult | null>(null);
  // 当前文件内容（Base64）
  const fileContentRef = useRef<string>('');
  const fileNameRef = useRef<string>('');

  const loadData = async (page = currentPage, size = pageSize) => {
    try {
      setLoading(true);
      const values = form.getFieldsValue();
      const params: QueryHBDRGCataLogParams = {
        code: values.code || '',
        descripts: values.descripts || '',
        provinceID: values.provinceId || '',
        cityID: values.cityId || '',
      };
      const res = await queryHBDRGCataLog(params, { pageSize: size, currentPage: page });
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
    setEditModalVisible(true);
  };

  // 打开编辑弹窗
  const handleOpenEdit = (record: HBDRGCataLogItem) => {
    setEditRecord(record);
    setEditAdmvs(''); // 重置admvs
    editForm.setFieldsValue({
      code: record.code,
      descripts: record.descripts,
      provinceId: record.provinceID,
      cityId: record.cityID,
    });
    // 加载市数据并设置admvs
    const fetchCityData = async () => {
      setCityLoading(true);
      try {
        const res = await getCityData(record.provinceID);
        if (res.errorCode === '0' && res.result) {
          setCityList(res.result);
          // 查找当前市的code
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
      
      const params: SaveHBDRGCataLogParams = {
        id: editRecord?.id,
        code: values.code,
        descripts: values.descripts,
        provinceDr: values.provinceId,
        cityDr: values.cityId,
        admvs: editAdmvs,
      };

      const res = await saveHBDRGCataLog(params);
      if (res.errorCode === '0' || res.errorCode === '00') {
        message.success(editRecord ? '修改成功' : '新增成功');
        setEditModalVisible(false);
        loadData(currentPage, pageSize);
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch (error: any) {
      if (error.errorFields) {
        return; // 表单验证错误
      }
      message.error('保存失败：' + (error.message || '网络异常'));
    } finally {
      setEditLoading(false);
    }
  };

  // 删除记录
  const handleDelete = async (record: HBDRGCataLogItem) => {
    try {
      const res = await deleteHBDRGCataLog(record.id);
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
      importCityId: undefined 
    });
    
    if (!value) {
      setImportCityList([]);
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

  // 下载导入模板
  const handleDownloadTemplate = async () => {
    try {
      const res = await downloadDrgTemplate();
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
    return false;
  };

  // 预览导入数据
  const handlePreviewImport = async () => {
    const values = importForm.getFieldsValue();
    if (!values.importProvinceId) {
      message.error('请先选择省');
      return;
    }
    if (!values.importCityId) {
      message.error('请先选择市');
      return;
    }
    if (fileList.length === 0) {
      message.error('请先上传导入文件');
      return;
    }

    try {
      setImportLoading(true);
      const res = await previewDrgImport({
        provinceID: values.importProvinceId,
        cityID: values.importCityId,
        fileData: fileContentRef.current,
        fileName: fileNameRef.current
      });

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
    const provinceID = importForm.getFieldValue('importProvinceId');
    const cityID = importForm.getFieldValue('importCityId');
    
    if (!provinceID) {
      message.error('缺少省份参数，请返回上一步重新选择');
      return;
    }
    if (!cityID) {
      message.error('缺少城市参数，请返回上一步重新选择');
      return;
    }
    if (!fileContentRef.current) {
      message.error('文件内容为空，请返回上一步重新上传');
      return;
    }
    
    try {
      setImportLoading(true);
      const res = await confirmDrgImport({
        provinceID: String(provinceID),
        cityID: String(cityID),
        fileData: fileContentRef.current,
        fileName: fileNameRef.current
      });

      if (res.result) {
        setImportResult(res.result);
        setImportStep(2);
        loadData(1, pageSize);
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

  // 预览表格列定义
  const previewColumns: ColumnsType<DrgImportPreviewItem> = [
    { title: '行号', dataIndex: 'rowNum', width: 60 },
    { title: 'DRG代码', dataIndex: 'code', width: 120 },
    { title: 'DRG描述', dataIndex: 'descripts', ellipsis: true },
    { title: '行政区划', dataIndex: 'admvs', width: 120 },
    {
      title: '状态',
      dataIndex: 'status',
      width: 90,
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

  const columns: ColumnsType<HBDRGCataLogItem> = [
    {
      title: 'DRG代码',
      dataIndex: 'code',
      width: 100,
      render: (text: string) => <Tag color="blue">{text}</Tag>,
    },
    {
      title: 'DRG描述',
      dataIndex: 'descripts',
      width:300,
    },
    {
      title: '省市',
      width: 180,
      render: (_, record) => `${record.provinceDesc || ''} ${record.cityDesc || ''}`.trim(),
      ellipsis: true,
    },
    {        
      title:'行政区划',
      dataIndex:'admvs',
      width:60,
      render:(Text:string)=>Text||'-',
    },
    {
      title: '操作',
      width: 100,
      fixed: 'right',
      render: (_, record) => (
        <Space size="small">
          <Button type="link" size="small" icon={<EditOutlined />} onClick={() => handleOpenEdit(record)}>
            编辑
          </Button>
          <Popconfirm
            title="删除确认"
            description={`确定要删除DRG目录 "${record.code} - ${record.descripts}" 吗？`}
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
              <Form.Item name="code" label="DRG代码">
                <Input placeholder="模糊匹配" />
              </Form.Item>
            </Col>
            <Col span={5}>
              <Form.Item name="descripts" label="DRG描述">
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
                <Button type="primary" icon={<UploadOutlined />} onClick={handleOpenImport} style={{ height: 32 }}>
                  导入
                </Button>
              </Space>
            </div>
            <Space><FileTextOutlined /> <span>DRGs目录信息表</span></Space>
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
        title={editRecord ? '编辑DRG目录' : '新增DRG目录'}
        open={editModalVisible}
        onCancel={() => setEditModalVisible(false)}
        onOk={handleSave}
        okText="确定"
        cancelText="取消"
        confirmLoading={editLoading}
        width={600}
        destroyOnClose
      >
        <Form form={editForm} layout="vertical">
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="code"
                label="DRG代码"
                rules={[{ required: true, message: '请输入DRG代码' }]}
              >
                <Input placeholder="请输入DRG代码" />
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
          <Form.Item
            name="descripts"
            label="DRG描述"
            rules={[{ required: true, message: '请输入DRG描述' }]}
          >
            <Input placeholder="请输入DRG描述" />
          </Form.Item>
        </Form>
      </Modal>

      {/* 导入弹窗 */}
      <Modal
        title="DRG目录导入"
        open={importModalVisible}
        onCancel={handleCloseImport}
        width={800}
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
              description="导入的DRG目录将归属到选定的省市，请仔细确认。"
              type="warning"
              showIcon
              style={{ marginBottom: 16 }}
            />
            <Form form={importForm} layout="vertical">
              <Row gutter={16}>
                <Col span={12}>
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
                <Col span={12}>
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
                    >
                      {importCityList.map(item => (
                        <Option key={item.id} value={item.id}>{item.descripts}</Option>
                      ))}
                    </Select>
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
                    <li>必填列：DRG代码、DRG描述</li>                     
                    <li>重复处理：DRG代码+省市相同则更新，否则新增</li>
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
                  <Text>共计 <Text strong>{previewStats.total}</Text> 条</Text>
                  <Divider type="vertical" />
                  <Text type="success">正常 <Text strong>{previewStats.valid}</Text> 条</Text>
                  <Divider type="vertical" />
                  <Text type="warning">重复 <Text strong>{previewStats.duplicate}</Text> 条</Text>
                  <Divider type="vertical" />
                  <Text type="danger">异常 <Text strong>{previewStats.invalid}</Text> 条</Text>
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
                <Title level={5}>失败明细</Title>
                <List
                  size="small"
                  bordered
                  dataSource={importResult.failList}
                  renderItem={item => (
                    <List.Item>
                      <Space>
                        <Text type="secondary">行 {item.rowNum}</Text>
                        <Text code>{item.code || '空代码'}</Text>
                        <Text type="danger">{item.errorMsg}</Text>
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

export default DRGCataLog;
