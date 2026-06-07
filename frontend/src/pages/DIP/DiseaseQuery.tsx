/**
 * DIP业务页面
 * Tab1: DIP病种分值查询（只读查询）
 * Tab2: DIP病种目录
 */

import React, { useState, useEffect, useCallback } from 'react';
import {
  Table, Button, Card, Space, message, Form, Select, Input, Row, Col, Modal, InputNumber,
  Tag, Tabs, Descriptions
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, EyeOutlined,
  FileTextOutlined, DollarOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import CustomPagination from '../../components/CustomPagination';
import {
  queryDipCoreAlgorithm,
  getProvinceData, getCityData,
  type DipCoreAlgorithmItem,
  type ProvinceItem, type CityItem
} from '../../api/basicData';
import { queryDIPCatalog, type DIPCatalogItem } from '../../api/dip';
import { useDict } from '../../hooks/useDict';

const { Option } = Select;
const { TabPane } = Tabs;

const DiseaseQuery: React.FC = () => {
  const [activeTab, setActiveTab] = useState('points');

  // ==================== DIP病种分值查询 状态 ====================
  const [data, setData] = useState<DipCoreAlgorithmItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);

  const [principalDiagnosis, setPrincipalDiagnosis] = useState('');
  const [principalDiagnosisName, setPrincipalDiagnosisName] = useState('');
  const [majorProcedure, setMajorProcedure] = useState('');
  const [majorProcedureName, setMajorProcedureName] = useState('');
  const [provinceId, setProvinceId] = useState('');
  const [cityId, setCityId] = useState('');
  const [medinsLv, setMedinsLv] = useState('');
  const [year, setYear] = useState('');

  const [provinceList, setProvinceList] = useState<ProvinceItem[]>([]);
  const [cityList, setCityList] = useState<CityItem[]>([]);
  const [provinceLoading, setProvinceLoading] = useState(false);
  const [cityLoading, setCityLoading] = useState(false);

  // ==================== DIP病种目录 状态 ====================
  const [catalogData, setCatalogData] = useState<DIPCatalogItem[]>([]);
  const [catalogTotal, setCatalogTotal] = useState(0);
  const [catalogLoading, setCatalogLoading] = useState(false);
  const [catalogPage, setCatalogPage] = useState(1);
  const [catalogPageSize, setCatalogPageSize] = useState(20);

  const [catalogQuery, setCatalogQuery] = useState({
    principalDiagnosisName: '',
    majorProcedureName: '',
    provinceID: '',
    cityID: '',
    status: '',
  });

  const [catalogCities, setCatalogCities] = useState<CityItem[]>([]);
  const [catalogDetailModalOpen, setCatalogDetailModalOpen] = useState(false);
  const [catalogDetailRecord, setCatalogDetailRecord] = useState<DIPCatalogItem | null>(null);

  // ==================== DIP病种分值查询 逻辑 ====================

  const loadProvinces = useCallback(async () => {
    setProvinceLoading(true);
    try {
      const res = await getProvinceData();
      if (res.errorCode === '0' && res.result) {
        setProvinceList(res.result);
      }
    } catch {
      message.error('加载省数据失败');
    } finally {
      setProvinceLoading(false);
    }
  }, []);

  const loadCities = useCallback(async (pid: string) => {
    if (!pid) { setCityList([]); return; }
    setCityLoading(true);
    try {
      const res = await getCityData(pid);
      if (res.errorCode === '0' && res.result) { setCityList(res.result); }
    } catch { message.error('加载市数据失败'); }
    finally { setCityLoading(false); }
  }, []);

  useEffect(() => { loadProvinces(); }, [loadProvinces]);

  useEffect(() => {
    if (provinceId) { loadCities(provinceId); }
  }, [provinceId, loadCities]);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const filters = {
        principalDiagnosis, principalDiagnosisName, majorProcedure, majorProcedureName,
        provinceID: provinceId, cityID: cityId, medinsLv, year: year || undefined,
      };
      const res = await queryDipCoreAlgorithm(filters, { pageSize, currentPage });
      if (res.errorCode === '0' && res.result) {
        setData(res.result.rows || []);
        setTotal(res.result.total || 0);
      } else { message.error(res.errorMessage || '查询失败'); }
    } catch { message.error('查询失败'); }
    finally { setLoading(false); }
  }, [principalDiagnosis, principalDiagnosisName, majorProcedure, majorProcedureName, provinceId, cityId, medinsLv, year, currentPage, pageSize]);

  useEffect(() => { fetchData(); }, [fetchData]);

  const handleSearch = () => { setCurrentPage(1); fetchData(); };

  const handleReset = () => {
    setPrincipalDiagnosis(''); setPrincipalDiagnosisName('');
    setMajorProcedure(''); setMajorProcedureName('');
    setProvinceId(''); setCityId(''); setMedinsLv(''); setYear('');
    setCityList([]); setCurrentPage(1);
  };

  const handleProvinceChange = (value: string) => {
    setProvinceId(value); setCityId(''); setCityList([]);
    if (value) { loadCities(value); }
  };

  const handlePageChange = (page: number, size: number) => {
    setCurrentPage(page); setPageSize(size);
  };

  // ==================== DIP病种目录 逻辑 ====================

  const loadCatalogCities = useCallback(async (provId: string) => {
    if (!provId) { setCatalogCities([]); return; }
    try {
      const res = await getCityData(provId);
      if (res.errorCode === '0' && res.result) { setCatalogCities(res.result); }
    } catch { /* ignore */ }
  }, []);

  useEffect(() => {
    loadCatalogCities(catalogQuery.provinceID);
  }, [catalogQuery.provinceID, loadCatalogCities]);

  const fetchCatalog = useCallback(async (page = catalogPage, size = catalogPageSize) => {
    setCatalogLoading(true);
    try {
      const res = await queryDIPCatalog({
        principalDiagnosisName: catalogQuery.principalDiagnosisName || undefined,
        majorProcedureName: catalogQuery.majorProcedureName || undefined,
        provinceID: catalogQuery.provinceID || undefined,
        cityID: catalogQuery.cityID || undefined,
        status: catalogQuery.status || undefined,
      }, { pageSize: size, currentPage: page });
      if (res.errorCode === '0' && res.result) {
        setCatalogData(res.result.rows || []);
        setCatalogTotal(res.result.total || 0);
      } else { message.error(res.errorMessage || '查询失败'); }
    } catch { message.error('网络异常'); }
    finally { setCatalogLoading(false); }
  }, [catalogQuery, catalogPage, catalogPageSize]);

  const handleViewCatalogDetail = (record: DIPCatalogItem) => {
    setCatalogDetailRecord(record);
    setCatalogDetailModalOpen(true);
  };

  // ==================== 字典 ====================
  const { options: medinsLvOptions } = useDict('MEDINS_LEVEL');

  // ==================== 表格列 ====================

  const columns = [
    { title: '序号', dataIndex: 'index', key: 'index', width: 60,
      render: (_: any, _r: any, i: number) => (currentPage - 1) * pageSize + i + 1 },
    { title: '主要诊断代码', dataIndex: 'principalDiagnosis', key: 'principalDiagnosis', width: 120 },
    { title: '主要诊断名称', dataIndex: 'principalDiagnosisName', key: 'principalDiagnosisName', width: 180 },
    { title: '年份', dataIndex: 'year', key: 'year', width: 80 },
    { title: '主要手术代码', dataIndex: 'majorProcedure', key: 'majorProcedure', width: 120 },
    { title: '主要手术名称', dataIndex: 'majorProcedureName', key: 'majorProcedureName', width: 180 },
    { title: '省', dataIndex: 'provinceDesc', key: 'provinceDesc', width: 100 },
    { title: '市', dataIndex: 'cityDesc', key: 'cityDesc', width: 100 },
    { title: '医疗机构等级', dataIndex: 'medinsLv', key: 'medinsLv', width: 100,
      render: (text: string) => { const opt = medinsLvOptions.find(item => item.value === text); return opt ? opt.label : text; } },
    { title: '基准分值', dataIndex: 'scoreValue', key: 'scoreValue', width: 100 },
    { title: '调节系数', dataIndex: 'adjustCoefficient', key: 'adjustCoefficient', width: 100 },
  ];

  const catalogColumns: ColumnsType<DIPCatalogItem> = [
    { title: '序号', dataIndex: 'num', width: 80 },
    { title: '主要诊断编码', dataIndex: 'principalDiagnosis', width: 120 },
    { title: '主要诊断名称', dataIndex: 'principalDiagnosisName', width: 200, ellipsis: true },
    { title: '主要手术编码', dataIndex: 'majorProcedure', width: 120 },
    { title: '主要手术名称', dataIndex: 'majorProcedureName', width: 180, ellipsis: true },
    { title: '次要手术编码', dataIndex: 'secondaryProcedure', width: 120 },
    { title: '次要手术名称', dataIndex: 'secondaryProcedureName', width: 180, ellipsis: true },
    { title: '地区', key: 'area', width: 120,
      render: (_: any, record: DIPCatalogItem) => `${record.provinceDesc || ''} ${record.cityDesc || ''}` },
    { title: '生效日期', dataIndex: 'startDate', width: 100 },
    { title: '状态', dataIndex: 'statusDesc', width: 80,
      render: (v: string, record: DIPCatalogItem) => <Tag color={record.status === 'Y' ? 'green' : 'red'}>{v || '无效'}</Tag> },
    { title: '操作', key: 'action', width: 80, fixed: 'right',
      render: (_: any, record: DIPCatalogItem) => (
        <Button type="link" size="small" icon={<EyeOutlined />} onClick={() => handleViewCatalogDetail(record)}>查看</Button>
      ),
    },
  ];

  // ==================== JSX ====================

  return (
    <div style={{ padding: 16 }}>
      <Tabs activeKey={activeTab} onChange={setActiveTab}>
        {/* ===== Tab1: DIP病种分值查询 ===== */}
        <TabPane tab={<span><DollarOutlined />DIP病种分值查询</span>} key="points">
          <div style={{ padding: 10 }}>
            <Card>
              <Form layout="vertical" style={{ marginBottom: 1 }}>
                <Row gutter={8}>
                  <Col span={3}>
                    <Form.Item label="主要诊断代码">
                      <Input placeholder="请输入主要诊断代码" value={principalDiagnosis}
                        onChange={(e) => setPrincipalDiagnosis(e.target.value)} />
                    </Form.Item>
                  </Col>
                  <Col span={3}>
                    <Form.Item label="主要诊断名称">
                      <Input placeholder="请输入主要诊断名称" value={principalDiagnosisName}
                        onChange={(e) => setPrincipalDiagnosisName(e.target.value)} />
                    </Form.Item>
                  </Col>
                  <Col span={3}>
                    <Form.Item label="主要手术代码">
                      <Input placeholder="请输入主要手术代码" value={majorProcedure}
                        onChange={(e) => setMajorProcedure(e.target.value)} />
                    </Form.Item>
                  </Col>
                  <Col span={3}>
                    <Form.Item label="主要手术名称">
                      <Input placeholder="请输入主要手术名称" value={majorProcedureName}
                        onChange={(e) => setMajorProcedureName(e.target.value)} />
                    </Form.Item>
                  </Col>
                  <Col span={2}>
                    <Form.Item label="省">
                      <Select placeholder="请选择省" value={provinceId || undefined} onChange={handleProvinceChange}
                        allowClear loading={provinceLoading} style={{ width: '100%' }}>
                        {provinceList.map(item => <Option key={item.id} value={item.id}>{item.descripts}</Option>)}
                      </Select>
                    </Form.Item>
                  </Col>
                  <Col span={2}>
                    <Form.Item label="市">
                      <Select placeholder="请选择市" value={cityId || undefined} onChange={setCityId}
                        allowClear disabled={!provinceId} loading={cityLoading} style={{ width: '100%' }}>
                        {cityList.map(item => <Option key={item.id} value={item.id}>{item.descripts}</Option>)}
                      </Select>
                    </Form.Item>
                  </Col>
                  <Col span={2}>
                    <Form.Item label="机构等级">
                      <Select placeholder="全部" value={medinsLv || undefined} onChange={setMedinsLv}
                        allowClear style={{ width: '100%' }}>
                        {medinsLvOptions.map(item => <Option key={item.value} value={item.value}>{item.label}</Option>)}
                      </Select>
                    </Form.Item>
                  </Col>
                  <Col span={2}>
                    <Form.Item label="年份">
                      <InputNumber placeholder="全部" value={year ? Number(year) : undefined}
                        onChange={v => setYear(v ? String(v) : '')} style={{ width: '100%' }} min={2020} max={2099} precision={0} />
                    </Form.Item>
                  </Col>
                  <Col span={3}>
                    <Form.Item label=" " style={{ marginBottom: 0 }}>
                      <Space>
                        <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>查询</Button>
                        <Button icon={<ReloadOutlined />} onClick={handleReset}>重置</Button>
                      </Space>
                    </Form.Item>
                  </Col>
                </Row>
              </Form>

              <Table columns={columns} dataSource={data} rowKey="id" loading={loading} scroll={{ x: 1400 }} pagination={false} />
              <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
                <CustomPagination total={total} current={currentPage} pageSize={pageSize} onChange={handlePageChange} />
              </div>
            </Card>
          </div>
        </TabPane>

        {/* ===== Tab2: DIP病种目录 ===== */}
        <TabPane tab={<span><FileTextOutlined />DIP病种目录</span>} key="catalog">
          <Card size="small" style={{ marginBottom: 16 }}>
            <Row gutter={16} align="middle">
              <Col>
                <Input placeholder="主要诊断名称" value={catalogQuery.principalDiagnosisName}
                  onChange={e => setCatalogQuery({ ...catalogQuery, principalDiagnosisName: e.target.value })}
                  style={{ width: 180 }} allowClear />
              </Col>
              <Col>
                <Input placeholder="主要手术名称" value={catalogQuery.majorProcedureName}
                  onChange={e => setCatalogQuery({ ...catalogQuery, majorProcedureName: e.target.value })}
                  style={{ width: 180 }} allowClear />
              </Col>
              <Col>
                <Select placeholder="省份" value={catalogQuery.provinceID || undefined}
                  onChange={v => setCatalogQuery({ ...catalogQuery, provinceID: v, cityID: '' })}
                  style={{ width: 120 }} allowClear>
                  {provinceList.map(p => <Option key={p.id} value={p.id}>{p.descripts}</Option>)}
                </Select>
              </Col>
              <Col>
                <Select placeholder="城市" value={catalogQuery.cityID || undefined}
                  onChange={v => setCatalogQuery({ ...catalogQuery, cityID: v })}
                  style={{ width: 120 }} allowClear disabled={!catalogQuery.provinceID}>
                  {catalogCities.map(c => <Option key={c.id} value={c.id}>{c.descripts}</Option>)}
                </Select>
              </Col>
              <Col>
                <Select placeholder="状态" value={catalogQuery.status}
                  onChange={v => setCatalogQuery({ ...catalogQuery, status: v })}
                  style={{ width: 100 }} allowClear>
                  <Option value="">全部</Option><Option value="Y">有效</Option><Option value="N">无效</Option>
                </Select>
              </Col>
              <Col>
                <Space>
                  <Button type="primary" icon={<SearchOutlined />} onClick={() => { setCatalogPage(1); fetchCatalog(1); }}>查询</Button>
                  <Button icon={<ReloadOutlined />} onClick={() => {
                    setCatalogQuery({ principalDiagnosisName: '', majorProcedureName: '', provinceID: '', cityID: '', status: '' });
                    setCatalogPage(1);
                  }}>重置</Button>
                </Space>
              </Col>
            </Row>
          </Card>

          <Card size="small">
            <Table columns={catalogColumns} dataSource={catalogData} rowKey="id" loading={catalogLoading}
              scroll={{ x: 1500 }} size="small" pagination={false} />
            <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
              <CustomPagination current={catalogPage} pageSize={catalogPageSize} total={catalogTotal}
                onChange={(page, size) => { setCatalogPage(page); setCatalogPageSize(size); fetchCatalog(page, size); }} />
            </div>
          </Card>
        </TabPane>
      </Tabs>

      {/* 目录详情弹窗 */}
      <Modal title="病种目录详情" open={catalogDetailModalOpen} onCancel={() => setCatalogDetailModalOpen(false)} footer={null} width={700}>
        {catalogDetailRecord && (
          <Descriptions bordered column={2} size="small">
            <Descriptions.Item label="序号">{catalogDetailRecord.num}</Descriptions.Item>
            <Descriptions.Item label="主要诊断编码">{catalogDetailRecord.principalDiagnosis}</Descriptions.Item>
            <Descriptions.Item label="主要诊断名称" span={2}>{catalogDetailRecord.principalDiagnosisName}</Descriptions.Item>
            <Descriptions.Item label="主要手术编码">{catalogDetailRecord.majorProcedure}</Descriptions.Item>
            <Descriptions.Item label="主要手术名称">{catalogDetailRecord.majorProcedureName}</Descriptions.Item>
            <Descriptions.Item label="次要手术编码">{catalogDetailRecord.secondaryProcedure || '-'}</Descriptions.Item>
            <Descriptions.Item label="次要手术名称">{catalogDetailRecord.secondaryProcedureName || '-'}</Descriptions.Item>
            <Descriptions.Item label="省份">{catalogDetailRecord.provinceDesc}</Descriptions.Item>
            <Descriptions.Item label="城市">{catalogDetailRecord.cityDesc}</Descriptions.Item>
            <Descriptions.Item label="生效日期">{catalogDetailRecord.startDate}</Descriptions.Item>
            <Descriptions.Item label="失效日期">{catalogDetailRecord.stopDate || '-'}</Descriptions.Item>
            <Descriptions.Item label="状态">
              <Tag color={catalogDetailRecord.status === 'Y' ? 'green' : 'red'}>{catalogDetailRecord.statusDesc}</Tag>
            </Descriptions.Item>
          </Descriptions>
        )}
      </Modal>
    </div>
  );
};

export default DiseaseQuery;
