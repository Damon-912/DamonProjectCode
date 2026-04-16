import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Input, Select, Space, Modal, Form,
  Row, Col, Tag, message, Popconfirm
} from 'antd';
import { PlusOutlined, SearchOutlined, ReloadOutlined, DeleteOutlined, EditOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import {
  queryDipDiseases, saveDipDisease, deleteDipDisease,
  type DipDiseaseItem, type SaveDipDiseaseParams
} from '../../api/basicData';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;

const DIPDisease: React.FC = () => {
  const [data, setData] = useState<DipDiseaseItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);

  // 查询条件
  const [principalDiagnosisName, setPrincipalDiagnosisName] = useState('');
  const [majorProcedureName, setMajorProcedureName] = useState('');
  const [status, setStatus] = useState('');

  // 弹窗
  const [modalOpen, setModalOpen] = useState(false);
  const [editRecord, setEditRecord] = useState<DipDiseaseItem | null>(null);
  const [saving, setSaving] = useState(false);
  const [form] = Form.useForm<SaveDipDiseaseParams>();

  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await queryDipDiseases(
        {
          principalDiagnosisName: principalDiagnosisName || undefined,
          majorProcedureName: majorProcedureName || undefined,
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
  }, [principalDiagnosisName, majorProcedureName, status, currentPage, pageSize]);

  useEffect(() => {
    fetchData(1, pageSize);
    setCurrentPage(1);
  }, [principalDiagnosisName, majorProcedureName, status]);

  const handleSearch = () => {
    setCurrentPage(1);
    fetchData(1, pageSize);
  };

  const handleReset = () => {
    setPrincipalDiagnosisName('');
    setMajorProcedureName('');
    setStatus('');
  };

  const handleAdd = () => {
    setEditRecord(null);
    form.resetFields();
    setModalOpen(true);
  };

  const handleEdit = (record: DipDiseaseItem) => {
    setEditRecord(record);
    form.setFieldsValue({
      num: record.num,
      principalDiagnosis: record.principalDiagnosis,
      principalDiagnosisName: record.principalDiagnosisName,
      majorProcedure: record.majorProcedure,
      majorProcedureName: record.majorProcedureName,
      secondaryProcedure: record.secondaryProcedure,
      secondaryProcedureName: record.secondaryProcedureName,
      provinceID: record.provinceID,
      cityID: record.cityID,
      startDate: record.startDate,
      stopDate: record.stopDate,
    });
    setModalOpen(true);
  };

  const handleDelete = async (id: string) => {
    try {
      const res = await deleteDipDisease(id);
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

  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      setSaving(true);
      const params: SaveDipDiseaseParams = {
        ...values,
        id: editRecord?.id || '',
        startDate: values.startDate || '',
        stopDate: values.stopDate || '',
      };
      const res = await saveDipDisease(params);
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

  const columns: ColumnsType<DipDiseaseItem> = [
    {
      title: '序号',
      dataIndex: 'num',
      width: 50,
    },
    {
      title: '主要诊断编码',
      dataIndex: 'principalDiagnosis',
      width: 120,
    },
    {
      title: '主要诊断名称',
      dataIndex: 'principalDiagnosisName',
      width: 180,
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
      title: '省',
      dataIndex: 'provinceDesc',
      width: 100,
    },
    {
      title: '市',
      dataIndex: 'cityDesc',
      width: 100,
    },
    {
      title: '生效日期',
      dataIndex: 'startDate',
      width: 80,
    },
    {
      title: '状态',
      dataIndex: 'statusDesc',
      width: 40,
      render: (v: string) => (
        <Tag color={v === '有效' ? 'green' : 'red'}>{v || '无效'}</Tag>
      ),
    },
    {
      title: '操作',
      key: 'action',
      width: 100,
      fixed: 'right',
      render: (_, record) => (
        <Space size="small">
          <Button type="link" size="small" icon={<EditOutlined />} onClick={() => handleEdit(record)}>编辑</Button>
          <Popconfirm
            title="确认删除"
            description="确定要删除该DIP病种吗？"
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
              placeholder="主要诊断名称"
              value={principalDiagnosisName}
              onChange={e => setPrincipalDiagnosisName(e.target.value)}
              style={{ width: 180 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="主要手术名称"
              value={majorProcedureName}
              onChange={e => setMajorProcedureName(e.target.value)}
              style={{ width: 180 }}
              allowClear
            />
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
              <Option value="Y">有效</Option>
              <Option value="N">无效</Option>
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
          <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增病种</Button>
          <span>共 {total} 条记录</span>
        </div>
        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1200 }}
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
        title={editRecord ? '编辑DIP病种' : '新增DIP病种'}
        open={modalOpen}
        onOk={handleSave}
        onCancel={() => setModalOpen(false)}
        okText="确定"
        cancelText="取消"
        confirmLoading={saving}
        width={720}
        destroyOnClose
      >
        <Form form={form} layout="vertical" size="small">
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="num" label="序号">
                <Input placeholder="序号" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="principalDiagnosis" label="主要诊断编码" rules={[{ required: true, message: '请输入主要诊断编码' }]}>
                <Input placeholder="如 I21.0" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="principalDiagnosisName" label="主要诊断名称" rules={[{ required: true, message: '请输入主要诊断名称' }]}>
                <Input placeholder="如 急性心肌梗死" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="majorProcedure" label="主要手术编码">
                <Input placeholder="如 36.07" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="majorProcedureName" label="主要手术名称">
                <Input placeholder="如 冠状动脉支架置入" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="secondaryProcedure" label="次要手术编码">
                <Input placeholder="如 88.56" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="secondaryProcedureName" label="次要手术名称">
                <Input placeholder="如 冠状动脉造影" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="provinceID" label="省代码" rules={[{ required: true, message: '请输入省代码' }]}>
                <Input placeholder="如 310000" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="cityID" label="市代码" rules={[{ required: true, message: '请输入市代码' }]}>
                <Input placeholder="如 310100" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="startDate" label="生效日期" rules={[{ required: true, message: '请输入生效日期' }]}>
                <Input placeholder="YYYY-MM-DD" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="stopDate" label="失效日期">
                <Input placeholder="YYYY-MM-DD" />
              </Form.Item>
            </Col>
          </Row>
        </Form>
      </Modal>
    </div>
  );
};

export default DIPDisease;
