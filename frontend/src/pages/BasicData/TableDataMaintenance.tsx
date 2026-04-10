/*
 * 基础表数据维护
 * 从 frontend-云HIS 迁移适配
 * 功能：动态维护各类基础数据表
 */
import React, { useState, useEffect, useCallback, useRef } from 'react';
import {
  Card, Table, Button, Input, Select, Space, Modal, Form, Row, Col,
  Tag, message, Popconfirm, Breadcrumb, Divider
} from 'antd';
import { 
  PlusOutlined, SearchOutlined, ReloadOutlined, DeleteOutlined, EditOutlined,
  HomeOutlined, DatabaseOutlined, TableOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { invoke } from '../../api/request';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;

// 表定义接口
interface TableDefinition {
  id: string;
  code: string;
  desc: string;
  className: string;
  remark?: string;
}

// 数据项接口
interface DataItem {
  ID?: string;
  [key: string]: any;
}

const TableDataMaintenance: React.FC = () => {
  // 左侧表列表
  const [tableList, setTableList] = useState<TableDefinition[]>([]);
  const [tableLoading, setTableLoading] = useState(false);
  const [selectedTable, setSelectedTable] = useState<TableDefinition | null>(null);
  const [tableSearch, setTableSearch] = useState('');

  // 右侧数据列表
  const [dataList, setDataList] = useState<DataItem[]>([]);
  const [dataLoading, setDataLoading] = useState(false);
  const [dataTotal, setDataTotal] = useState(0);
  const [dataPage, setDataPage] = useState(1);
  const [dataPageSize, setDataPageSize] = useState(20);
  const [dataSearch, setDataSearch] = useState('');

  // 表结构定义
  const [columns, setColumns] = useState<ColumnsType<DataItem>>([]);
  const [formFields, setFormFields] = useState<any[]>([]);

  // 弹窗状态
  const [modalOpen, setModalOpen] = useState(false);
  const [editRecord, setEditRecord] = useState<DataItem | null>(null);
  const [saving, setSaving] = useState(false);
  const [form] = Form.useForm();

  // 加载表列表
  const fetchTableList = useCallback(async () => {
    setTableLoading(true);
    try {
      // 调用接口 4010 - 查询基础表列表
      const res: any = await invoke('4010', [{
        Descripts: tableSearch || undefined,
        Code: undefined,
      }]);
      if (res.errorCode === '0') {
        const list = res.result?.rows || [];
        setTableList(list);
        // 如果有数据且未选择，默认选择第一个
        if (list.length > 0 && !selectedTable) {
          setSelectedTable(list[0]);
        }
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch (error) {
      console.error('查询表列表失败:', error);
      message.error('网络异常');
    } finally {
      setTableLoading(false);
    }
  }, [tableSearch]);

  useEffect(() => {
    fetchTableList();
  }, [tableSearch]);

  // 加载表结构和数据
  const fetchTableStructure = useCallback(async () => {
    if (!selectedTable) return;
    
    try {
      // 调用接口 4002 - 获取表结构（列定义）
      const res: any = await invoke('4002', [{
        ClassName: selectedTable.className || selectedTable.code
      }]);
      
      if (res.errorCode === '0') {
        const columnDefs = res.result?.Data || [];
        
        // 构建表格列
        const tableColumns: ColumnsType<DataItem> = columnDefs.map((col: any) => ({
          title: col.Desc || col.Code,
          dataIndex: col.Code,
          key: col.Code,
          width: 150,
          ellipsis: true,
        }));
        
        // 添加操作列
        tableColumns.push({
          title: '操作',
          key: 'action',
          width: 120,
          fixed: 'right',
          render: (_, record) => (
            <Space size="small">
              <Button 
                type="link" 
                size="small" 
                icon={<EditOutlined />} 
                onClick={() => handleEdit(record)}
              >
                编辑
              </Button>
              <Popconfirm
                title="确认删除"
                description="确定要删除该记录吗？"
                onConfirm={() => handleDelete(record.ID)}
                okText="确定"
                cancelText="取消"
              >
                <Button type="link" size="small" danger icon={<DeleteOutlined />}>
                  删除
                </Button>
              </Popconfirm>
            </Space>
          ),
        });
        
        setColumns(tableColumns);
        
        // 构建表单字段
        const fields = columnDefs.map((col: any) => ({
          name: col.Code,
          label: col.Desc || col.Code,
          type: col.Type || 'Input',
          required: col.rules?.some((r: any) => r.required === 'true'),
        }));
        setFormFields(fields);
      }
    } catch (error) {
      console.error('获取表结构失败:', error);
    }
  }, [selectedTable]);

  // 加载数据
  const fetchData = useCallback(async () => {
    if (!selectedTable) return;
    
    setDataLoading(true);
    try {
      // 调用接口 4003 - 查询表数据
      const res: any = await invoke('4003', [{
        ClassName: selectedTable.className || selectedTable.code,
        FindFieldVal: dataSearch ? { keyword: dataSearch } : {},
      }]);
      
      if (res.errorCode === '0') {
        const rows = res.result?.rows || [];
        // 添加 key 属性
        const dataWithKey = rows.map((item: any, index: number) => ({
          ...item,
          key: item.ID || index,
        }));
        setDataList(dataWithKey);
        setDataTotal(res.result?.total || rows.length);
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch (error) {
      console.error('查询数据失败:', error);
      message.error('网络异常');
    } finally {
      setDataLoading(false);
    }
  }, [selectedTable, dataSearch, dataPage, dataPageSize]);

  useEffect(() => {
    if (selectedTable) {
      fetchTableStructure();
      fetchData();
    }
  }, [selectedTable]);

  // 操作函数
  const handleTableSearch = () => {
    fetchTableList();
  };

  const handleTableReset = () => {
    setTableSearch('');
  };

  const handleDataSearch = () => {
    setDataPage(1);
    fetchData();
  };

  const handleDataReset = () => {
    setDataSearch('');
  };

  const handleAdd = () => {
    setEditRecord(null);
    form.resetFields();
    setModalOpen(true);
  };

  const handleEdit = (record: DataItem) => {
    setEditRecord(record);
    form.setFieldsValue(record);
    setModalOpen(true);
  };

  const handleDelete = async (id: string) => {
    if (!selectedTable) return;
    
    try {
      // 调用接口 4006 - 删除数据
      const res: any = await invoke('4006', [{
        ClassName: selectedTable.className || selectedTable.code,
        ID: id,
      }]);
      
      if (res.errorCode === '0') {
        message.success('删除成功');
        fetchData();
      } else {
        message.error(res.errorMessage || '删除失败');
      }
    } catch (error) {
      console.error('删除失败:', error);
      message.error('网络异常');
    }
  };

  const handleSave = async () => {
    if (!selectedTable) return;
    
    try {
      const values = await form.validateFields();
      setSaving(true);
      
      // 调用接口 4005 - 保存数据
      const res: any = await invoke('4005', [{
        ClassName: selectedTable.className || selectedTable.code,
        Item: {
          ...values,
          ID: editRecord?.ID || undefined,
        },
      }]);
      
      if (res.errorCode === '0') {
        message.success(editRecord ? '修改成功' : '新增成功');
        setModalOpen(false);
        fetchData();
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch (error) {
      console.error('保存失败:', error);
    } finally {
      setSaving(false);
    }
  };

  // 表列表列定义
  const tableListColumns: ColumnsType<TableDefinition> = [
    {
      title: '表名',
      dataIndex: 'desc',
      key: 'desc',
      ellipsis: true,
    },
    {
      title: '代码',
      dataIndex: 'code',
      key: 'code',
      width: 120,
      ellipsis: true,
    },
  ];

  return (
    <div style={{ padding: 16, width: '100%', height: '100%', boxSizing: 'border-box', display: 'flex', flexDirection: 'column' }}>
      {/* 面包屑导航 */}
      <Breadcrumb style={{ marginBottom: 16 }}
        items={[
          { title: <><HomeOutlined /> 首页</> },
          { title: <><DatabaseOutlined /> 数据管理</> },
          { title: <><TableOutlined /> 基础表数据维护</> },
        ]}
      />

      {/* 左右两栏布局 */}
      <div style={{ flex: 1, minHeight: 0, display: 'flex', gap: 16 }}>
        {/* 左侧：表列表 */}
        <Card 
          size="small" 
          title="数据表列表"
          style={{ width: 300, display: 'flex', flexDirection: 'column' }}
          styles={{ body: { padding: 8, flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' } }}
        >
          <Row gutter={8} style={{ marginBottom: 8 }}>
            <Col flex="auto">
              <Input
                placeholder="搜索表名"
                value={tableSearch}
                onChange={e => setTableSearch(e.target.value)}
                allowClear
                size="small"
                onPressEnter={handleTableSearch}
              />
            </Col>
            <Col>
              <Button type="primary" size="small" icon={<SearchOutlined />} onClick={handleTableSearch} />
            </Col>
          </Row>
          <div style={{ flex: 1, overflow: 'auto' }}>
            <Table
              columns={tableListColumns}
              dataSource={tableList}
              rowKey="id"
              loading={tableLoading}
              size="small"
              pagination={false}
              showHeader={false}
              onRow={(record) => ({
                onClick: () => setSelectedTable(record),
                style: { 
                  cursor: 'pointer',
                  backgroundColor: selectedTable?.id === record.id ? '#e6f7ff' : undefined 
                },
              })}
            />
          </div>
        </Card>

        {/* 右侧：数据维护 */}
        <Card
          size="small"
          title={
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span>
                {selectedTable ? `${selectedTable.desc} (${selectedTable.code})` : '请选择数据表'}
              </span>
              <Space size={4}>
                <Button 
                  type="primary" 
                  size="small" 
                  icon={<PlusOutlined />} 
                  onClick={handleAdd}
                  disabled={!selectedTable}
                >
                  添加
                </Button>
              </Space>
            </div>
          }
          style={{ flex: 1, display: 'flex', flexDirection: 'column' }}
          styles={{ body: { padding: 8, flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' } }}
        >
          <Row gutter={8} style={{ marginBottom: 8 }} align="middle">
            <Col flex="auto">
              <Input
                placeholder="输入关键词查询"
                value={dataSearch}
                onChange={e => setDataSearch(e.target.value)}
                allowClear
                size="small"
                onPressEnter={handleDataSearch}
                disabled={!selectedTable}
              />
            </Col>
            <Col>
              <Button 
                type="primary" 
                size="small" 
                icon={<SearchOutlined />} 
                onClick={handleDataSearch}
                disabled={!selectedTable}
              >
                查询
              </Button>
            </Col>
            <Col>
              <Button 
                size="small" 
                icon={<ReloadOutlined />} 
                onClick={handleDataReset}
                disabled={!selectedTable}
              >
                重置
              </Button>
            </Col>
          </Row>
          <div style={{ flex: 1, overflow: 'auto' }}>
            <Table
              columns={columns}
              dataSource={dataList}
              rowKey="key"
              loading={dataLoading}
              size="small"
              scroll={{ x: 'max-content' }}
              pagination={false}
            />
            <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
              <CustomPagination
                current={dataPage}
                pageSize={dataPageSize}
                total={dataTotal}
                onChange={(page, size) => {
                  setDataPage(page);
                  setDataPageSize(size);
                }}
              />
            </div>
          </div>
        </Card>
      </div>

      {/* 新增/编辑弹窗 */}
      <Modal
        title={editRecord ? '编辑记录' : '新增记录'}
        open={modalOpen}
        onOk={handleSave}
        onCancel={() => setModalOpen(false)}
        okText="确定"
        cancelText="取消"
        confirmLoading={saving}
        width={700}
        destroyOnClose
      >
        <Form form={form} layout="vertical">
          <Row gutter={16}>
            {formFields.map((field) => (
              <Col span={12} key={field.name}>
                <Form.Item
                  name={field.name}
                  label={field.label}
                  rules={field.required ? [{ required: true, message: `请输入${field.label}` }] : []}
                >
                  <Input placeholder={`请输入${field.label}`} />
                </Form.Item>
              </Col>
            ))}
          </Row>
        </Form>
      </Modal>
    </div>
  );
};

export default TableDataMaintenance;
