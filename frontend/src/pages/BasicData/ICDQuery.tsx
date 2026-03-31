import { useState, useEffect, useRef } from 'react';
import {
  Card, Form, Input, Select, Button, Space, Table, Row, Col,
  Tag, message, Modal, Upload, Steps, Alert, Statistic, Divider,
  Typography, List, Result
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, FileTextOutlined,
  UploadOutlined, DownloadOutlined, EyeOutlined,
  CheckCircleOutlined, CloseCircleOutlined, WarningOutlined,
  FileExcelOutlined, ArrowRightOutlined, ArrowLeftOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { UploadFile } from 'antd/es/upload/interface';
import {
  queryIcdInfo,
  getProvinceData,
  getCityData,
  previewIcdImport,
  confirmIcdImport,
  downloadIcdTemplate,
  IcdInfoItem,
  QueryIcdInfoParams,
  ProvinceItem,
  CityItem,
  IcdImportPreviewItem,
  IcdImportResult
} from '@/api/basicData';

const { Option } = Select;
const { Text, Title } = Typography;

/**
 * ICD编码查询页面
 * 查询各地方版本ICD编码信息（支持导入功能）
 */
const ICDQuery: React.FC = () => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [dataSource, setDataSource] = useState<IcdInfoItem[]>([]);
  const [total, setTotal] = useState(0);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);

  // 省、市下拉数据
  const [provinceList, setProvinceList] = useState<ProvinceItem[]>([]);
  const [cityList, setCityList] = useState<CityItem[]>([]);
  const [provinceLoading, setProvinceLoading] = useState(false);
  const [cityLoading, setCityLoading] = useState(false);

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
  const [previewData, setPreviewData] = useState<IcdImportPreviewItem[]>([]);
  const [previewStats, setPreviewStats] = useState({ total: 0, valid: 0, invalid: 0, duplicate: 0 });
  // 导入结果
  const [importResult, setImportResult] = useState<IcdImportResult | null>(null);
  // 当前文件内容（Base64）
  const fileContentRef = useRef<string>('');
  const fileNameRef = useRef<string>('');

  const loadData = async (page = currentPage, size = pageSize) => {
    try {
      setLoading(true);
      const values = form.getFieldsValue();
      const params: QueryIcdInfoParams = {
        version: values.version || '',
        provinceID: values.provinceId || '',
        cityID: values.cityId || '',
        code: values.code || '',
        descripts: values.descripts || '',
        status: values.status || '',
      };
      const res = await queryIcdInfo(params, { pageSize: size, currentPage: page });
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
    // 获取省下拉数据并设置默认值
    const fetchProvinceData = async () => {
      setProvinceLoading(true);
      try {
        const res = await getProvinceData();
        if (res.errorCode === '0' && res.result) {
          setProvinceList(res.result);
          // 查找"国家医疗保障局"
          const nationalProvince = res.result.find(p => p.descripts?.includes('国家医疗保障局') || p.descripts?.includes('国家'));
          if (nationalProvince) {
            // 设置省默认值
            form.setFieldsValue({ provinceId: nationalProvince.id });
            // 获取市数据
            const cityRes = await getCityData(nationalProvince.id);
            if (cityRes.errorCode === '0' && cityRes.result) {
              setCityList(cityRes.result);
              // 查找市中的"国家医疗保障局"
              const nationalCity = cityRes.result.find(c => c.descripts?.includes('国家医疗保障局') || c.descripts?.includes('国家'));
              if (nationalCity) {
                form.setFieldsValue({ cityId: nationalCity.id });
              }
            }
          }
        }
      } finally {
        setProvinceLoading(false);
      }
    };
    fetchProvinceData();
    // 设置版本默认值
    form.setFieldsValue({ version: 'ICD-10' });
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
    // 同时设置省和清空市
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
      const res = await downloadIcdTemplate();
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
      // 将ArrayBuffer转换为Base64
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
      const res = await previewIcdImport({
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
    // 直接从表单获取省、市ID值
    const provinceID = importForm.getFieldValue('importProvinceId');
    const cityID = importForm.getFieldValue('importCityId');
    
    // 调试：输出参数值
    console.log('=== 确认导入调试信息 ===');
    console.log('provinceID:', provinceID, '类型:', typeof provinceID);
    console.log('cityID:', cityID, '类型:', typeof cityID);
    console.log('fileContentRef.current:', fileContentRef.current ? '有值' : '无值');
    console.log('fileNameRef.current:', fileNameRef.current);
    
    // 验证参数
    if (!provinceID) {
      message.error('缺少省份参数(provinceID)，请返回上一步重新选择');
      return;
    }
    if (!cityID) {
      message.error('缺少城市参数(cityID)，请返回上一步重新选择');
      return;
    }
    if (!fileContentRef.current) {
      message.error('文件内容为空，请返回上一步重新上传');
      return;
    }
    
    try {
      setImportLoading(true);
      const res = await confirmIcdImport({
        provinceID: String(provinceID),
        cityID: String(cityID),
        fileData: fileContentRef.current,
        fileName: fileNameRef.current
      });
      
      console.log('02010039接口返回:', res);

      if (res.result) {
        setImportResult(res.result);
        setImportStep(2);
        // 刷新列表数据
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
  const previewColumns: ColumnsType<IcdImportPreviewItem> = [
    { title: '行号', dataIndex: 'rowNum', width: 60 },
    { title: 'ICD代码', dataIndex: 'code', width: 120 },
    { title: 'ICD描述', dataIndex: 'desc', ellipsis: true },
    { title: '版本', dataIndex: 'version', width: 90 },
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

  const columns: ColumnsType<IcdInfoItem> = [
    {
      title: 'ICD代码',
      dataIndex: 'code',
      width: 120,
      render: (text: string) => <Tag color="blue">{text}</Tag>,
    },
    {
      title: 'ICD描述',
      dataIndex: 'desc',
      ellipsis: true,
    },
    {
      title: '版本',
      dataIndex: 'version',
      width: 90,
      render: (text: string) => <Tag>{text}</Tag>,
    },
    {
      title: '省市',
      width: 140,
      render: (_, record) => `${record.provinceDesc || ''} ${record.cityDesc || ''}`.trim(),
      ellipsis: true,
    },
    {
      title: '生效日期',
      dataIndex: 'startDate',
      width: 110,
      render: (text: string) => text || '-',
    },
    {
      title: '失效日期',
      dataIndex: 'stopDate',
      width: 110,
      render: (text: string) => text || '-',
    },
    {
      title: '状态',
      dataIndex: 'statusDesc',
      width: 80,
      render: (text: string) => (
        <Tag color={text === '有效' ? 'green' : text === '无效' ? 'red' : 'default'}>{text}</Tag>
      ),
    },
    {
      title: '备注',
      dataIndex: 'remark',
      width: 150,
      ellipsis: true,
      render: (text: string) => text || '-',
    },
  ];

  return (
    <div style={{ padding: 16 }}>
      {/* 查询条件 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Form form={form} layout="inline">
          {/* 第一行查询条件 */}
          <Row gutter={16} style={{ width: '100%' }}>
            <Col span={4}>
              <Form.Item name="version" label="版本">
                <Select placeholder="全部" allowClear>
                  <Option value="ICD-9">ICD-9</Option>
                  <Option value="ICD-10">ICD-10</Option>
                </Select>
              </Form.Item>
            </Col>
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
              <Form.Item name="code" label="ICD代码">
                <Input placeholder="模糊匹配" />
              </Form.Item>
            </Col>
            <Col span={5}>
              <Form.Item name="descripts" label="ICD描述">
                <Input placeholder="模糊匹配" />
              </Form.Item>
            </Col>
          </Row>
          {/* 第二行查询条件 + 按钮 */}
          <Row gutter={16} style={{ width: '100%', marginTop: 16 }}>
            <Col span={4}>
              <Form.Item name="status" label="状态">
                <Select placeholder="全部" allowClear>
                  <Option value="Y">有效</Option>
                  <Option value="N">无效</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={5} offset={15} style={{ textAlign: 'right' }}>
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
              <Button type="primary" icon={<UploadOutlined />} onClick={handleOpenImport} style={{ height: 32 }}>
                导入
              </Button>
            </div>
            <Space><FileTextOutlined /> <span>ICD编码信息查询</span></Space>
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
          scroll={{ x: 1100 }}
          pagination={{
            current: currentPage,
            pageSize: pageSize,
            total: total,
            showSizeChanger: true,
            showQuickJumper: true,
            showTotal: (t) => `共 ${t} 条`,
            onChange: (page, size) => loadData(page, size),
            locale: {
              items_per_page: '/页',
              jump_to: '跳至',
              page: '页',
            }
          }}
        />
      </Card>

      {/* 导入弹窗 */}
      <Modal
        title="ICD编码导入"
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
              description="导入的ICD编码将归属到选定的省市，请仔细确认。"
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
                      onChange={(value) => {
                        console.log('市选择变化:', value);
                        importForm.setFieldsValue({ importCityId: value });
                      }}
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
                    <li>必填列：ICD代码、ICD描述、版本</li>
                    <li>版本值：ICD-9 或 ICD-10</li>             
                    <li>重复处理：ICD代码+省市相同则更新，否则新增</li>
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

export default ICDQuery;
