import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Input, Select, Space, Modal, Form, InputNumber,
  Row, Col, Tag, message, Popconfirm, DatePicker
} from 'antd';
import { PlusOutlined, SearchOutlined, ReloadOutlined, DeleteOutlined, EditOutlined, EyeOutlined, ExclamationCircleOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import CustomPagination from '../../components/CustomPagination';
import {
  queryAdrgRules, saveAdrgRule, deleteAdrgRule,
  type AdrgRuleItem, type SaveAdrgRuleParams
} from '../../api/basicData';
import { useDict } from '../../hooks/useDict';
import { getDictLabel } from '../../utils/dict';

const { Option } = Select;

const ADRGRuleMaintenance: React.FC = () => {
  const { options: yesNoOptions, map: yesNoMap } = useDict('YES_NO_FLAG');
  const [data, setData] = useState<AdrgRuleItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);
  const [expandedRowKeys, setExpandedRowKeys] = useState<string[]>([]);

  // 查询条件
  const [adrg, setAdrg] = useState('');
  const [adrgDesc, setAdrgDesc] = useState('');
  const [status, setStatus] = useState('');

  // 弹窗
  const [modalOpen, setModalOpen] = useState(false);
  const [editRecord, setEditRecord] = useState<AdrgRuleItem | null>(null);
  const [saving, setSaving] = useState(false);
  const [form] = Form.useForm<SaveAdrgRuleParams>();

  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await queryAdrgRules(
        { adrg: adrg || undefined, adrgDesc: adrgDesc || undefined, status: status || undefined },
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
  }, [adrg, adrgDesc, status, currentPage, pageSize]);

  useEffect(() => {
    fetchData(1, pageSize);
    setCurrentPage(1);
  }, [adrg, adrgDesc, status]);

  const handleSearch = () => {
    setCurrentPage(1);
    fetchData(1, pageSize);
  };

  const handleReset = () => {
    setAdrg('');
    setAdrgDesc('');
    setStatus('');
  };

  const handleAdd = () => {
    setEditRecord(null);
    form.resetFields();
    setModalOpen(true);
  };

  const handleEdit = (record: AdrgRuleItem) => {
    setEditRecord(record);
    form.setFieldsValue({
      adrg: record.adrg,
      adrgDesc: record.adrgDesc,
      principalDiagnosis: record.principalDiagnosis,
      principalDiagnosisName: record.principalDiagnosisName,
      secondaryDiagnosis: record.secondaryDiagnosis,
      secondaryDiagnosisName: record.secondaryDiagnosisName,
      thirdlyDiagnosis: record.thirdlyDiagnosis,
      thirdlyDiagnosisName: record.thirdlyDiagnosisName,
      majorProcedure: record.majorProcedure,
      majorProcedureName: record.majorProcedureName,
      secondaryProcedure: record.secondaryProcedure,
      secondaryProcedureName: record.secondaryProcedureName,
      thirdlyProcedure: record.thirdlyProcedure,
      thirdlyProcedureName: record.thirdlyProcedureName,
      unionFlag: record.unionFlag,
      segmentationFlag: record.segmentationFlag,
      selectionCriteria: record.selectionCriteria,
      provinceId: record.provinceId,
      cityId: record.cityId,
      startDate: record.startDate,
      stopDate: record.stopDate,
    });
    setModalOpen(true);
  };

  const handleDelete = async (id: string) => {
    try {
      const res = await deleteAdrgRule(id);
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
      const params: SaveAdrgRuleParams = {
        ...values,
        id: editRecord?.id || '',
        startDate: values.startDate || '',
        stopDate: values.stopDate || '',
      };
      const res = await saveAdrgRule(params);
      if (res.errorCode === '0') {
        message.success(editRecord ? '修改成功' : '新增成功');
        setModalOpen(false);
        fetchData();
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch (err) {
      if (err instanceof Error) {
        // form validation error - ignore
      } else {
        message.error('保存失败');
      }
    } finally {
      setSaving(false);
    }
  };

  const columns: ColumnsType<AdrgRuleItem> = [
    {
      title: 'ADRG代码',
      dataIndex: 'adrg',
      width: 100,
      fixed: 'left',
    },
    {
      title: 'ADRG名称',
      dataIndex: 'adrgDesc',
      width: 140,
    },
    {
      title: '主要诊断',
      children: [
        { title: '编码', dataIndex: 'principalDiagnosis', width: 100 },
        { title: '名称', dataIndex: 'principalDiagnosisName', width: 140 },
      ],
    },
    {
      title: '主要手术',
      children: [
        { title: '编码', dataIndex: 'majorProcedure', width: 100 },
        { title: '名称', dataIndex: 'majorProcedureName', width: 140 },
      ],
    },
    {
      title: '联合标志',
      dataIndex: 'unionFlag',
      width: 80,
      render: (v: string) => <Tag color={v === '1' ? 'blue' : 'default'}>{getDictLabel(yesNoMap, v)}</Tag>,
    },
    {
      title: '细分标志',
      dataIndex: 'segmentationFlag',
      width: 80,
      render: (v: string) => <Tag color={v === '1' ? 'blue' : 'default'}>{getDictLabel(yesNoMap, v)}</Tag>,
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
      width: 180,
      fixed: 'right',
      render: (_, record) => (
        <Space size="small">
          <Button type="link" size="small" icon={<EyeOutlined />} onClick={() => {
            const keys = expandedRowKeys.includes(record.id)
              ? expandedRowKeys.filter(k => k !== record.id)
              : [...expandedRowKeys, record.id];
            setExpandedRowKeys(keys);
          }}>详情</Button>
          <Button type="link" size="small" icon={<EditOutlined />} onClick={() => handleEdit(record)}>编辑</Button>
          <Popconfirm
            title="确认删除"
            description="确定要删除该ADRG分组规则吗？"
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
              placeholder="ADRG代码"
              value={adrg}
              onChange={e => setAdrg(e.target.value)}
              style={{ width: 120 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="ADRG名称"
              value={adrgDesc}
              onChange={e => setAdrgDesc(e.target.value)}
              style={{ width: 200 }}
              allowClear
            />
          </Col>
          <Col>
            <Select
              placeholder="状态"
              value={status || undefined}
              onChange={v => setStatus(v || '')}
              style={{ width: 120 }}
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
          <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增规则</Button>
          <span>共 {total} 条记录</span>
        </div>
        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1200 }}
          size="small"
          expandable={{
            showExpandColumn: false,
            expandedRowKeys: expandedRowKeys,
            expandedRowRender: (record) => (
              <div style={{ padding: '8px 0' }}>
                <Row gutter={[16, 8]}>
                  <Col span={8}><strong>其他诊断编码：</strong>{record.secondaryDiagnosis || '-'}</Col>
                  <Col span={8}><strong>其他诊断名称：</strong>{record.secondaryDiagnosisName || '-'}</Col>
                  <Col span={8}><strong>第三诊断编码：</strong>{record.thirdlyDiagnosis || '-'}</Col>
                  <Col span={8}><strong>第三诊断名称：</strong>{record.thirdlyDiagnosisName || '-'}</Col>
                  <Col span={8}><strong>其他手术编码：</strong>{record.secondaryProcedure || '-'}</Col>
                  <Col span={8}><strong>其他手术名称：</strong>{record.secondaryProcedureName || '-'}</Col>
                  <Col span={8}><strong>第三手术编码：</strong>{record.thirdlyProcedure || '-'}</Col>
                  <Col span={8}><strong>第三手术名称：</strong>{record.thirdlyProcedureName || '-'}</Col>
                  <Col span={8}><strong>细分标志：</strong>{getDictLabel(yesNoMap, record.segmentationFlag)}</Col>
                  <Col span={8}><strong>入组条件：</strong>{record.selectionCriteria || '-'}</Col>
                  <Col span={8}><strong>省：</strong>{record.provinceDesc || record.provinceId || '-'}</Col>
                  <Col span={8}><strong>市：</strong>{record.cityDesc || record.cityId || '-'}</Col>
                  <Col span={8}><strong>生效日期：</strong>{record.startDate || '-'}</Col>
                  <Col span={8}><strong>失效日期：</strong>{record.stopDate || '-'}</Col>
                </Row>
              </div>
            ),
          }}
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
        title={editRecord ? '编辑ADRG分组规则' : '新增ADRG分组规则'}
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
          {/* 基本信息 */}
          <Card size="small" title="基本信息" style={{ marginBottom: 12 }}>
            <Row gutter={16}>
              <Col span={8}>
                <Form.Item name="adrg" label="ADRG代码" rules={[{ required: true, message: '请输入ADRG代码' }]}>
                  <Input placeholder="如 FB1" />
                </Form.Item>
              </Col>
              <Col span={16}>
                <Form.Item name="adrgDesc" label="ADRG名称" rules={[{ required: true, message: '请输入ADRG名称' }]}>
                  <Input placeholder="如 心脏介入治疗" />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item name="unionFlag" label="联合标志">
                  <Select options={yesNoOptions} />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item name="segmentationFlag" label="细分标志">
                  <Select options={yesNoOptions} />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item name="selectionCriteria" label="入组条件">
                  <Input placeholder="如 包含以下主要手术或操作" />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item name="provinceId" label="省代码">
                  <Input placeholder="如 310000" />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item name="cityId" label="市代码">
                  <Input placeholder="如 310100" />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item name="startDate" label="生效日期">
                  <Input placeholder="YYYY-MM-DD" />
                </Form.Item>
              </Col>
            </Row>
          </Card>

          {/* 诊断信息 */}
          <Card size="small" title="诊断信息" style={{ marginBottom: 12 }}>
            <Row gutter={16}>
              <Col span={8}>
                <Form.Item name="principalDiagnosis" label="主要诊断编码">
                  <Input placeholder="如 I21.0" />
                </Form.Item>
              </Col>
              <Col span={16}>
                <Form.Item name="principalDiagnosisName" label="主要诊断名称">
                  <Input placeholder="如 急性心肌梗死" />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item name="secondaryDiagnosis" label="其他诊断编码">
                  <Input placeholder="如 I10.0" />
                </Form.Item>
              </Col>
              <Col span={16}>
                <Form.Item name="secondaryDiagnosisName" label="其他诊断名称">
                  <Input placeholder="如 高血压" />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item name="thirdlyDiagnosis" label="第三诊断编码">
                  <Input placeholder="如 E11.9" />
                </Form.Item>
              </Col>
              <Col span={16}>
                <Form.Item name="thirdlyDiagnosisName" label="第三诊断名称">
                  <Input placeholder="如 2型糖尿病" />
                </Form.Item>
              </Col>
            </Row>
          </Card>

          {/* 手术/操作信息 */}
          <Card size="small" title="手术/操作信息">
            <Row gutter={16}>
              <Col span={8}>
                <Form.Item name="majorProcedure" label="主要手术编码">
                  <Input placeholder="如 36.07" />
                </Form.Item>
              </Col>
              <Col span={16}>
                <Form.Item name="majorProcedureName" label="主要手术名称">
                  <Input placeholder="如 冠状动脉支架置入" />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item name="secondaryProcedure" label="其他手术编码">
                  <Input placeholder="如 88.56" />
                </Form.Item>
              </Col>
              <Col span={16}>
                <Form.Item name="secondaryProcedureName" label="其他手术名称">
                  <Input placeholder="如 冠状动脉造影" />
                </Form.Item>
              </Col>
              <Col span={8}>
                <Form.Item name="thirdlyProcedure" label="第三手术编码">
                  <Input placeholder="手术编码" />
                </Form.Item>
              </Col>
              <Col span={16}>
                <Form.Item name="thirdlyProcedureName" label="第三手术名称">
                  <Input placeholder="手术名称" />
                </Form.Item>
              </Col>
            </Row>
          </Card>
        </Form>
      </Modal>
    </div>
  );
};

export default ADRGRuleMaintenance;
