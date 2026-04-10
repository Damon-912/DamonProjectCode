import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Input, Select, Space, Modal, Form,
  Row, Col, Tag, message, Checkbox
} from 'antd';
import { PlusOutlined, SearchOutlined, ReloadOutlined, EditOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import {
  queryInterfaceServices, saveInterfaceService,
  type InterfaceServiceItem, type SaveInterfaceServiceParams
} from '../../api/system';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;

const Interfaces: React.FC = () => {
  const [data, setData] = useState<InterfaceServiceItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(15);

  // 查询条件
  const [code, setCode] = useState('');
  const [descripts, setDescripts] = useState('');
  const [className, setClassName] = useState('');
  const [methodName, setMethodName] = useState('');
  const [status, setStatus] = useState<string>('');

  // 弹窗
  const [modalOpen, setModalOpen] = useState(false);
  const [editRecord, setEditRecord] = useState<InterfaceServiceItem | null>(null);
  const [saving, setSaving] = useState(false);
  const [form] = Form.useForm<SaveInterfaceServiceParams>();

  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      // 服务端分页查询 - 所有查询条件都传到后端
      const res = await queryInterfaceServices(
        {
          code: code || undefined,
          descripts: descripts || undefined,
          className: className || undefined,
          methodName: methodName || undefined,
          status: status || undefined,
        },
        { pageSize: size, currentPage: page, sortColumn: '', sortOrder: '' }
      );
      if (res.errorCode === '0' && res.result) {
        console.log('查询返回数据:', res.result.rows);
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
  }, [code, descripts, className, methodName, status, currentPage, pageSize]);

  // 初始加载
  useEffect(() => {
    fetchData(1, pageSize);
    setCurrentPage(1);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleSearch = () => {
    setCurrentPage(1);
    fetchData(1, pageSize);
  };

  const handleReset = () => {
    setCode('');
    setDescripts('');
    setClassName('');
    setMethodName('');
    setStatus('');
  };

  const handleAdd = () => {
    setEditRecord(null);
    form.resetFields();
    form.setFieldsValue({
      id: '',           // 新增时id为空字符串
      key: '',          // 新增时key为空字符串
      sessionFlag: 'N',
      tokenFlag: 'N',
    });
    setModalOpen(true);
  };

  const handleEdit = (record: InterfaceServiceItem) => {
    console.log('编辑记录:', record);
    console.log('id:', record?.id, 'key:', record?.key);
    console.log('sessionFlag:', record?.sessionFlag, 'tokenFlag:', record?.tokenFlag);
    
    if (!record?.id) {
      message.error('记录ID为空，无法编辑');
      return;
    }
    
    setEditRecord(record);
    form.setFieldsValue({
      id: record.id || '',
      key: record.key || record.id || '',
      code: record.code,
      descripts: record.descripts,
      className: record.className,
      methodName: record.methodName,
      serviceType: record.serviceType,
      startDate: record.startDate || '',
      stopDate: record.stopDate || '',
      sessionFlag: record.sessionFlag || 'N',
      tokenFlag: record.tokenFlag || 'N',
    });
    setModalOpen(true);
  };



  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      console.log('表单values:', values);
      console.log('editRecord:', editRecord);
      setSaving(true);
      
      // 转换 Checkbox 布尔值为 Y/N
      const params = {
        ...values,
        id: values.id || editRecord?.id || '',
        key: values.key || editRecord?.key || editRecord?.id || '',
        sessionFlag: values.sessionFlag ? 'Y' : 'N',
        tokenFlag: values.tokenFlag ? 'Y' : 'N',
      };
      console.log('保存params:', params);
      
      const res = await saveInterfaceService(params);
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

  const columns: ColumnsType<InterfaceServiceItem> = [
    {
      title: '接口代码',
      dataIndex: 'code',
      width: 120,
      render: (text: string) => <Tag color="blue">{text}</Tag>,
    },
    {
      title: '接口描述',
      dataIndex: 'descripts',
      width: 200,
      ellipsis: true,
    },
    {
      title: '类名',
      dataIndex: 'className',
      width: 200,
      ellipsis: true,
    },
    {
      title: '方法名',
      dataIndex: 'methodName',
      width: 150,
    },
    {
      title: '服务类型',
      dataIndex: 'serviceType',
      width: 90,
      render: (v: string) => {
        const typeMap: Record<string, { color: string; text: string }> = {
          'S': { color: 'green', text: '查询' },
          'A': { color: 'blue', text: '新增' },
          'U': { color: 'orange', text: '修改' },
          'D': { color: 'red', text: '删除' },
        };
        const type = typeMap[v] || { color: 'default', text: v };
        return <Tag color={type.color}>{type.text}</Tag>;
      },
    },
    {
      title: '产品类别',
      dataIndex: 'productCatDesc',
      width: 100,
    },
    {
      title: '产品模块',
      dataIndex: 'productModuleDesc',
      width: 100,
    },
    {
      title: '启用日期',
      dataIndex: 'startDate',
      width: 110,
    },
    {
      title: '停用日期',
      dataIndex: 'stopDate',
      width: 110,
      render: (v: string) => v || '-',
    },
    {
      title: '会话验证',
      dataIndex: 'sessionFlag',
      width: 80,
      render: (v: string) => <Tag color={v === 'Y' ? 'green' : 'default'}>{v}</Tag>,
    },
    {
      title: '令牌验证',
      dataIndex: 'tokenFlag',
      width: 70,
      render: (v: string) => <Tag color={v === 'Y' ? 'green' : 'default'}>{v}</Tag>,
    },
    {
      title: '状态',
      key: 'status',
      width: 80,
      fixed: 'right',
      render: (_, record) => {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        
        const startDate = record.startDate ? new Date(record.startDate) : null;
        const stopDate = record.stopDate ? new Date(record.stopDate) : null;
        
        let isActive = false;
        
        if (startDate) {
          startDate.setHours(0, 0, 0, 0);
          // 启用日期必须小于等于今天
          if (startDate <= today) {
            // 如果没有停用日期，或者停用日期大于今天，则状态为有效
            if (!stopDate || stopDate > today) {
              isActive = true;
            }
          }
        }
        
        return (
          <Tag color={isActive ? 'green' : 'red'}>
            {isActive ? '有效' : '无效'}
          </Tag>
        );
      },
    },
    {
      title: '操作',
      key: 'action',
      width: 80,
      fixed: 'right',
      render: (_, record) => (
        <Button type="link" size="small" icon={<EditOutlined />} onClick={() => handleEdit(record)}>编辑</Button>
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
              placeholder="请输入"
              value={code}
              onChange={e => setCode(e.target.value)}
              style={{ width: 140 }}
              allowClear
              addonBefore="代码"
            />
          </Col>
          <Col>
            <Input
              placeholder="请输入"
              value={descripts}
              onChange={e => setDescripts(e.target.value)}
              style={{ width: 160 }}
              allowClear
              addonBefore="描述"
            />
          </Col>
          <Col>
            <Input
              placeholder="请输入"
              value={className}
              onChange={e => setClassName(e.target.value)}
              style={{ width: 180 }}
              allowClear
              addonBefore="类名"
            />
          </Col>
          <Col>
            <Input
              placeholder="请输入"
              value={methodName}
              onChange={e => setMethodName(e.target.value)}
              style={{ width: 160 }}
              allowClear
              addonBefore="方法名"
            />
          </Col>
          <Col>
            <Select
              placeholder="请选择"
              value={status || undefined}
              onChange={v => setStatus(v || '')}
              style={{ width: 130 }}
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
          <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增接口</Button>
          <span>共 {total} 条记录</span>
        </div>
        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          scroll={{ x: 1700 }}
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
        title={editRecord ? '编辑接口服务' : '新增接口服务'}
        open={modalOpen}
        onOk={handleSave}
        onCancel={() => setModalOpen(false)}
        okText="确定"
        cancelText="取消"
        confirmLoading={saving}
        width={600}
        destroyOnClose
      >
        <Form form={form} layout="vertical" size="small">
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="code" label="接口代码" rules={[{ required: true, message: '请输入接口代码' }]}>
                <Input placeholder="如 02010001" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="serviceType" label="服务类型" rules={[{ required: true, message: '请选择服务类型' }]}>
                <Select placeholder="请选择">
                  <Option value="S">查询(S)</Option>
                  <Option value="A">新增(A)</Option>
                  <Option value="U">修改(U)</Option>
                  <Option value="D">删除(D)</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={24}>
              <Form.Item name="descripts" label="接口描述">
                <Input placeholder="接口功能描述" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="className" label="类名" rules={[{ required: true, message: '请输入类名' }]}>
                <Input placeholder="如 src.DRG.BasicData.InterFace" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="methodName" label="方法名" rules={[{ required: true, message: '请输入方法名' }]}>
                <Input placeholder="如 GetDRGBasicData" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="startDate" label="启用日期">
                <Input type="date" placeholder="请选择启用日期" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="stopDate" label="停用日期">
                <Input type="date" placeholder="请选择停用日期" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="sessionFlag" valuePropName="checked">
                <Checkbox>验证Session</Checkbox>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="tokenFlag" valuePropName="checked">
                <Checkbox>验证Token</Checkbox>
              </Form.Item>
            </Col>
          </Row>
        </Form>
      </Modal>
    </div>
  );
};

export default Interfaces;
