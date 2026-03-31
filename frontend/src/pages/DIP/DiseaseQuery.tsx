import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Input, Select, Space, Row, Col,
  Tag, message, Descriptions, Modal, Tabs, Badge, Tooltip
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, MedicineBoxOutlined,
  DollarOutlined, EyeOutlined, FileTextOutlined,
  EnvironmentOutlined, HistoryOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import {
  queryDIPPoints, queryDIPCatalog,
  type DIPPointsItem, type DIPCatalogItem
} from '../../api/dip';
import { getProvinceData, getCityData, type ProvinceItem, type CityItem } from '../../api/basicData';

const { Option } = Select;
const { TabPane } = Tabs;

const DiseaseQuery: React.FC = () => {
  const [activeTab, setActiveTab] = useState('points');
  
  // 病种分值查询状态
  const [pointsData, setPointsData] = useState<DIPPointsItem[]>([]);
  const [pointsTotal, setPointsTotal] = useState(0);
  const [pointsLoading, setPointsLoading] = useState(false);
  const [pointsPage, setPointsPage] = useState(1);
  const [pointsPageSize, setPointsPageSize] = useState(20);
  
  // 病种目录查询状态
  const [catalogData, setCatalogData] = useState<DIPCatalogItem[]>([]);
  const [catalogTotal, setCatalogTotal] = useState(0);
  const [catalogLoading, setCatalogLoading] = useState(false);
  const [catalogPage, setCatalogPage] = useState(1);
  const [catalogPageSize, setCatalogPageSize] = useState(20);
  
  // 查询条件
  const [pointsQuery, setPointsQuery] = useState({
    dipCode: '',
    dipName: '',
    mainDiagnosisCode: '',
    mainDiagnosisName: '',
    provinceId: '',
    cityId: '',
    status: '',
  });
  
  const [catalogQuery, setCatalogQuery] = useState({
    principalDiagnosisName: '',
    majorProcedureName: '',
    provinceID: '',
    cityID: '',
    status: '',
  });
  
  // 省市区数据
  const [provinces, setProvinces] = useState<ProvinceItem[]>([]);
  const [cities, setCities] = useState<CityItem[]>([]);
  const [catalogCities, setCatalogCities] = useState<CityItem[]>([]);
  
  // 详情弹窗
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [detailRecord, setDetailRecord] = useState<DIPPointsItem | null>(null);
  const [catalogDetailModalOpen, setCatalogDetailModalOpen] = useState(false);
  const [catalogDetailRecord, setCatalogDetailRecord] = useState<DIPCatalogItem | null>(null);

  // 加载省份数据
  useEffect(() => {
    const loadProvinces = async () => {
      try {
        const res = await getProvinceData();
        if (res.errorCode === '0' && res.result) {
          setProvinces(res.result);
        }
      } catch {
        // ignore
      }
    };
    loadProvinces();
  }, []);

  // 加载城市数据（分值查询）
  useEffect(() => {
    const loadCities = async () => {
      if (!pointsQuery.provinceId) {
        setCities([]);
        return;
      }
      try {
        const res = await getCityData(pointsQuery.provinceId);
        if (res.errorCode === '0' && res.result) {
          setCities(res.result);
        }
      } catch {
        // ignore
      }
    };
    loadCities();
  }, [pointsQuery.provinceId]);

  // 加载城市数据（目录查询）
  useEffect(() => {
    const loadCatalogCities = async () => {
      if (!catalogQuery.provinceID) {
        setCatalogCities([]);
        return;
      }
      try {
        const res = await getCityData(catalogQuery.provinceID);
        if (res.errorCode === '0' && res.result) {
          setCatalogCities(res.result);
        }
      } catch {
        // ignore
      }
    };
    loadCatalogCities();
  }, [catalogQuery.provinceID]);

  // 查询病种分值
  const fetchPoints = useCallback(async (page = pointsPage, size = pointsPageSize) => {
    setPointsLoading(true);
    try {
      const res = await queryDIPPoints({
        dipCode: pointsQuery.dipCode || undefined,
        dipName: pointsQuery.dipName || undefined,
        mainDiagnosisCode: pointsQuery.mainDiagnosisCode || undefined,
        mainDiagnosisName: pointsQuery.mainDiagnosisName || undefined,
        provinceId: pointsQuery.provinceId || undefined,
        cityId: pointsQuery.cityId || undefined,
        status: pointsQuery.status || undefined,
      }, { pageSize: size, currentPage: page });
      if (res.errorCode === '0' && res.result) {
        setPointsData(res.result.rows || []);
        setPointsTotal(res.result.total || 0);
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setPointsLoading(false);
    }
  }, [pointsQuery, pointsPage, pointsPageSize]);

  // 查询病种目录
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
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setCatalogLoading(false);
    }
  }, [catalogQuery, catalogPage, catalogPageSize]);

  useEffect(() => {
    if (activeTab === 'points') {
      fetchPoints();
    } else {
      fetchCatalog();
    }
  }, [activeTab, fetchPoints, fetchCatalog]);

  // 查看详情
  const handleViewPointsDetail = (record: DIPPointsItem) => {
    setDetailRecord(record);
    setDetailModalOpen(true);
  };

  const handleViewCatalogDetail = (record: DIPCatalogItem) => {
    setCatalogDetailRecord(record);
    setCatalogDetailModalOpen(true);
  };

  // 病种分值表格列
  const pointsColumns: ColumnsType<DIPPointsItem> = [
    {
      title: 'DIP编码',
      dataIndex: 'dipCode',
      width: 100,
    },
    {
      title: 'DIP名称',
      dataIndex: 'dipName',
      width: 200,
      ellipsis: true,
    },
    {
      title: '分值',
      dataIndex: 'points',
      width: 80,
      align: 'right',
      sorter: true,
    },
    {
      title: '支付标准',
      dataIndex: 'paymentStandard',
      width: 100,
      align: 'right',
      render: (v: number) => `¥${(v || 0).toFixed(2)}`,
    },
    {
      title: '主要诊断编码',
      dataIndex: 'mainDiagnosisCode',
      width: 120,
    },
    {
      title: '主要诊断名称',
      dataIndex: 'mainDiagnosisName',
      width: 180,
      ellipsis: true,
    },
    {
      title: '主要手术编码',
      dataIndex: 'mainProcedureCode',
      width: 120,
    },
    {
      title: '主要手术名称',
      dataIndex: 'mainProcedureName',
      width: 180,
      ellipsis: true,
    },
    {
      title: '地区',
      key: 'area',
      width: 120,
      render: (_, record) => `${record.provinceDesc || ''} ${record.cityDesc || ''}`,
    },
    {
      title: '生效日期',
      dataIndex: 'startDate',
      width: 100,
    },
    {
      title: '状态',
      dataIndex: 'statusDesc',
      width: 80,
      render: (v: string, record: DIPPointsItem) => (
        <Tag color={record.status === 'Y' ? 'green' : 'red'}>{v || '无效'}</Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      width: 80,
      fixed: 'right',
      render: (_, record) => (
        <Button type="link" size="small" icon={<EyeOutlined />} onClick={() => handleViewPointsDetail(record)}>
          查看
        </Button>
      ),
    },
  ];

  // 病种目录表格列
  const catalogColumns: ColumnsType<DIPCatalogItem> = [
    {
      title: '序号',
      dataIndex: 'num',
      width: 80,
    },
    {
      title: '主要诊断编码',
      dataIndex: 'principalDiagnosis',
      width: 120,
    },
    {
      title: '主要诊断名称',
      dataIndex: 'principalDiagnosisName',
      width: 200,
      ellipsis: true,
    },
    {
      title: '主要手术编码',
      dataIndex: 'majorProcedure',
      width: 120,
    },
    {
      title: '主要手术名称',
      dataIndex: 'majorProcedureName',
      width: 180,
      ellipsis: true,
    },
    {
      title: '次要手术编码',
      dataIndex: 'secondaryProcedure',
      width: 120,
    },
    {
      title: '次要手术名称',
      dataIndex: 'secondaryProcedureName',
      width: 180,
      ellipsis: true,
    },
    {
      title: '地区',
      key: 'area',
      width: 120,
      render: (_, record) => `${record.provinceDesc || ''} ${record.cityDesc || ''}`,
    },
    {
      title: '生效日期',
      dataIndex: 'startDate',
      width: 100,
    },
    {
      title: '状态',
      dataIndex: 'statusDesc',
      width: 80,
      render: (v: string, record: DIPCatalogItem) => (
        <Tag color={record.status === 'Y' ? 'green' : 'red'}>{v || '无效'}</Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      width: 80,
      fixed: 'right',
      render: (_, record) => (
        <Button type="link" size="small" icon={<EyeOutlined />} onClick={() => handleViewCatalogDetail(record)}>
          查看
        </Button>
      ),
    },
  ];

  return (
    <div style={{ padding: 16 }}>
      <Tabs activeKey={activeTab} onChange={setActiveTab}>
        <TabPane 
          tab={<span><DollarOutlined />病种分值查询</span>} 
          key="points"
        >
          <Card size="small" style={{ marginBottom: 16 }}>
            <Row gutter={16} align="middle">
              <Col>
                <Input
                  placeholder="DIP编码"
                  value={pointsQuery.dipCode}
                  onChange={e => setPointsQuery({ ...pointsQuery, dipCode: e.target.value })}
                  style={{ width: 120 }}
                  allowClear
                />
              </Col>
              <Col>
                <Input
                  placeholder="DIP名称"
                  value={pointsQuery.dipName}
                  onChange={e => setPointsQuery({ ...pointsQuery, dipName: e.target.value })}
                  style={{ width: 180 }}
                  allowClear
                />
              </Col>
              <Col>
                <Input
                  placeholder="主要诊断编码"
                  value={pointsQuery.mainDiagnosisCode}
                  onChange={e => setPointsQuery({ ...pointsQuery, mainDiagnosisCode: e.target.value })}
                  style={{ width: 140 }}
                  allowClear
                />
              </Col>
              <Col>
                <Input
                  placeholder="主要诊断名称"
                  value={pointsQuery.mainDiagnosisName}
                  onChange={e => setPointsQuery({ ...pointsQuery, mainDiagnosisName: e.target.value })}
                  style={{ width: 180 }}
                  allowClear
                />
              </Col>
              <Col>
                <Select
                  placeholder="省份"
                  value={pointsQuery.provinceId || undefined}
                  onChange={v => setPointsQuery({ ...pointsQuery, provinceId: v, cityId: '' })}
                  style={{ width: 120 }}
                  allowClear
                >
                  {provinces.map(p => (
                    <Option key={p.id} value={p.id}>{p.descripts}</Option>
                  ))}
                </Select>
              </Col>
              <Col>
                <Select
                  placeholder="城市"
                  value={pointsQuery.cityId || undefined}
                  onChange={v => setPointsQuery({ ...pointsQuery, cityId: v })}
                  style={{ width: 120 }}
                  allowClear
                  disabled={!pointsQuery.provinceId}
                >
                  {cities.map(c => (
                    <Option key={c.id} value={c.id}>{c.descripts}</Option>
                  ))}
                </Select>
              </Col>
              <Col>
                <Select
                  placeholder="状态"
                  value={pointsQuery.status}
                  onChange={v => setPointsQuery({ ...pointsQuery, status: v })}
                  style={{ width: 100 }}
                  allowClear
                >
                  <Option value="">全部</Option>
                  <Option value="Y">有效</Option>
                  <Option value="N">无效</Option>
                </Select>
              </Col>
              <Col>
                <Space>
                  <Button type="primary" icon={<SearchOutlined />} onClick={() => { setPointsPage(1); fetchPoints(1); }}>
                    查询
                  </Button>
                  <Button icon={<ReloadOutlined />} onClick={() => { 
                    setPointsQuery({ dipCode: '', dipName: '', mainDiagnosisCode: '', mainDiagnosisName: '', provinceId: '', cityId: '', status: '' });
                    setPointsPage(1);
                  }}>
                    重置
                  </Button>
                </Space>
              </Col>
            </Row>
          </Card>

          <Card size="small">
            <div style={{ marginBottom: 12 }}>
              <span style={{ color: '#999' }}>共 {pointsTotal} 条记录</span>
            </div>
            <Table
              columns={pointsColumns}
              dataSource={pointsData}
              rowKey="id"
              loading={pointsLoading}
              scroll={{ x: 1400 }}
              size="small"
              pagination={{
                current: pointsPage,
                pageSize: pointsPageSize,
                total: pointsTotal,
                showSizeChanger: true,
                showTotal: (t) => `共 ${t} 条`,
                onChange: (page, size) => {
                  setPointsPage(page);
                  setPointsPageSize(size);
                  fetchPoints(page, size);
                },
                locale: {
                  items_per_page: '/页',
                  jump_to: '跳至',
                  page: '页',
                }
              }}
            />
          </Card>
        </TabPane>

        <TabPane 
          tab={<span><FileTextOutlined />DIP病种目录</span>} 
          key="catalog"
        >
          <Card size="small" style={{ marginBottom: 16 }}>
            <Row gutter={16} align="middle">
              <Col>
                <Input
                  placeholder="主要诊断名称"
                  value={catalogQuery.principalDiagnosisName}
                  onChange={e => setCatalogQuery({ ...catalogQuery, principalDiagnosisName: e.target.value })}
                  style={{ width: 180 }}
                  allowClear
                />
              </Col>
              <Col>
                <Input
                  placeholder="主要手术名称"
                  value={catalogQuery.majorProcedureName}
                  onChange={e => setCatalogQuery({ ...catalogQuery, majorProcedureName: e.target.value })}
                  style={{ width: 180 }}
                  allowClear
                />
              </Col>
              <Col>
                <Select
                  placeholder="省份"
                  value={catalogQuery.provinceID || undefined}
                  onChange={v => setCatalogQuery({ ...catalogQuery, provinceID: v, cityID: '' })}
                  style={{ width: 120 }}
                  allowClear
                >
                  {provinces.map(p => (
                    <Option key={p.id} value={p.id}>{p.descripts}</Option>
                  ))}
                </Select>
              </Col>
              <Col>
                <Select
                  placeholder="城市"
                  value={catalogQuery.cityID || undefined}
                  onChange={v => setCatalogQuery({ ...catalogQuery, cityID: v })}
                  style={{ width: 120 }}
                  allowClear
                  disabled={!catalogQuery.provinceID}
                >
                  {catalogCities.map(c => (
                    <Option key={c.id} value={c.id}>{c.descripts}</Option>
                  ))}
                </Select>
              </Col>
              <Col>
                <Select
                  placeholder="状态"
                  value={catalogQuery.status}
                  onChange={v => setCatalogQuery({ ...catalogQuery, status: v })}
                  style={{ width: 100 }}
                  allowClear
                >
                  <Option value="">全部</Option>
                  <Option value="Y">有效</Option>
                  <Option value="N">无效</Option>
                </Select>
              </Col>
              <Col>
                <Space>
                  <Button type="primary" icon={<SearchOutlined />} onClick={() => { setCatalogPage(1); fetchCatalog(1); }}>
                    查询
                  </Button>
                  <Button icon={<ReloadOutlined />} onClick={() => { 
                    setCatalogQuery({ principalDiagnosisName: '', majorProcedureName: '', provinceID: '', cityID: '', status: '' });
                    setCatalogPage(1);
                  }}>
                    重置
                  </Button>
                </Space>
              </Col>
            </Row>
          </Card>

          <Card size="small">
            <div style={{ marginBottom: 12 }}>
              <span style={{ color: '#999' }}>共 {catalogTotal} 条记录</span>
            </div>
            <Table
              columns={catalogColumns}
              dataSource={catalogData}
              rowKey="id"
              loading={catalogLoading}
              scroll={{ x: 1500 }}
              size="small"
              pagination={{
                current: catalogPage,
                pageSize: catalogPageSize,
                total: catalogTotal,
                showSizeChanger: true,
                showTotal: (t) => `共 ${t} 条`,
                onChange: (page, size) => {
                  setCatalogPage(page);
                  setCatalogPageSize(size);
                  fetchCatalog(page, size);
                },
              }}
            />
          </Card>
        </TabPane>
      </Tabs>

      {/* 分值详情弹窗 */}
      <Modal
        title="病种分值详情"
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        width={700}
      >
        {detailRecord && (
          <Descriptions bordered column={2} size="small">
            <Descriptions.Item label="DIP编码">{detailRecord.dipCode}</Descriptions.Item>
            <Descriptions.Item label="DIP名称" span={2}>{detailRecord.dipName}</Descriptions.Item>
            <Descriptions.Item label="分值">{detailRecord.points}</Descriptions.Item>
            <Descriptions.Item label="支付标准">¥{(detailRecord.paymentStandard || 0).toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="主要诊断编码">{detailRecord.mainDiagnosisCode}</Descriptions.Item>
            <Descriptions.Item label="主要诊断名称">{detailRecord.mainDiagnosisName}</Descriptions.Item>
            {detailRecord.otherDiagnosisCodes && (
              <Descriptions.Item label="其他诊断" span={2}>{detailRecord.otherDiagnosisCodes}</Descriptions.Item>
            )}
            <Descriptions.Item label="主要手术编码">{detailRecord.mainProcedureCode}</Descriptions.Item>
            <Descriptions.Item label="主要手术名称">{detailRecord.mainProcedureName}</Descriptions.Item>
            {detailRecord.otherProcedureCodes && (
              <Descriptions.Item label="其他手术" span={2}>{detailRecord.otherProcedureCodes}</Descriptions.Item>
            )}
            <Descriptions.Item label="省份">{detailRecord.provinceDesc}</Descriptions.Item>
            <Descriptions.Item label="城市">{detailRecord.cityDesc}</Descriptions.Item>
            <Descriptions.Item label="生效日期">{detailRecord.startDate}</Descriptions.Item>
            <Descriptions.Item label="失效日期">{detailRecord.stopDate || '-'}</Descriptions.Item>
            <Descriptions.Item label="状态">
              <Tag color={detailRecord.status === 'Y' ? 'green' : 'red'}>{detailRecord.statusDesc}</Tag>
            </Descriptions.Item>
          </Descriptions>
        )}
      </Modal>

      {/* 目录详情弹窗 */}
      <Modal
        title="病种目录详情"
        open={catalogDetailModalOpen}
        onCancel={() => setCatalogDetailModalOpen(false)}
        footer={null}
        width={700}
      >
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
