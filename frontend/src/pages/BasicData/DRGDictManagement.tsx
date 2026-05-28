import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Input, Select, Space, Modal, Form, Row, Col,
  Switch, message, InputNumber
} from 'antd';
import {
  PlusOutlined, SearchOutlined, ReloadOutlined, EditOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import {
  getDictTypeList, saveDictType,
  queryDictItemList, saveDictItem,
  type DictTypeItem, type DictItemItem,
  type SaveDictTypeParams, type SaveDictItemParams
} from '../../api/basicData';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;

const DRGDictManagement: React.FC = () => {
  // 字典类型列表
  const [typeList, setTypeList] = useState<DictTypeItem[]>([]);
  const [typeLoading, setTypeLoading] = useState(false);
  const [selectedType, setSelectedType] = useState<DictTypeItem | null>(null);

  // 字典项查询
  const [itemData, setItemData] = useState<DictItemItem[]>([]);
  const [itemTotal, setItemTotal] = useState(0);
  const [itemLoading, setItemLoading] = useState(false);
  const [itemCurrentPage, setItemCurrentPage] = useState(1);
  const [itemPageSize, setItemPageSize] = useState(15);
  const [itemSearch, setItemSearch] = useState({ code: '', name: '', status: '' });

  // 字典项弹窗
  const [itemModalOpen, setItemModalOpen] = useState(false);
  const [itemEditRecord, setItemEditRecord] = useState<DictItemItem | null>(null);
  const [itemSaving, setItemSaving] = useState(false);
  const [itemForm] = Form.useForm<SaveDictItemParams>();

  // 字典类型弹窗
  const [typeModalOpen, setTypeModalOpen] = useState(false);
  const [typeEditRecord, setTypeEditRecord] = useState<DictTypeItem | null>(null);
  const [typeSaving, setTypeSaving] = useState(false);
  const [typeForm] = Form.useForm<SaveDictTypeParams>();

  // ========== 加载字典类型列表 ==========
  const fetchTypeList = useCallback(async () => {
    setTypeLoading(true);
    try {
      const res = await getDictTypeList();
      if (res.errorCode === '0' && res.result) {
        const rows = res.result.rows || [];
        setTypeList(rows);
        if (rows.length > 0 && !selectedType) {
          setSelectedType(rows[0]);
        }
      } else {
        message.error(res.errorMessage || '加载字典类型失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setTypeLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchTypeList();
  }, [fetchTypeList]);

  // ========== 加载字典项列表 ==========
  const fetchItemList = useCallback(async (page = itemCurrentPage, size = itemPageSize) => {
    if (!selectedType) return;
    setItemLoading(true);
    try {
      const res = await queryDictItemList(
        {
          parentDr: selectedType.id,
          code: itemSearch.code || undefined,
          name: itemSearch.name || undefined,
          status: itemSearch.status || undefined,
        },
        { pageSize: size, currentPage: page }
      );
      if (res.errorCode === '0' && res.result) {
        setItemData(res.result.rows || []);
        setItemTotal(res.result.total || 0);
      } else {
        message.error(res.errorMessage || '查询字典项失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setItemLoading(false);
    }
  }, [selectedType, itemSearch, itemCurrentPage, itemPageSize]);

  useEffect(() => {
    if (selectedType) {
      setItemCurrentPage(1);
      fetchItemList(1, itemPageSize);
    }
  }, [selectedType, itemSearch]);

  // ========== 字典类型操作 ==========

  /** 打开新增类型弹窗 */
  const handleAddType = () => {
    setTypeEditRecord(null);
    typeForm.resetFields();
    setTypeModalOpen(true);
  };

  /** 打开编辑类型弹窗 */
  const handleEditType = (record: DictTypeItem) => {
    setTypeEditRecord(record);
    typeForm.setFieldsValue({
      id: record.id,
      code: record.code,
      name: record.name,
      status: record.status,
      remark: record.remark,
    });
    setTypeModalOpen(true);
  };

  /** 保存类型 */
  const handleSaveType = async () => {
    try {
      const values = await typeForm.validateFields();
      setTypeSaving(true);
      const res = await saveDictType({
        id: values.id,
        code: values.code,
        name: values.name,
        status: values.status || 'Y',
        remark: values.remark || '',
      });
      if (res.errorCode === '0') {
        message.success('保存成功');
        setTypeModalOpen(false);
        fetchTypeList();
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch {
      // 表单校验失败
    } finally {
      setTypeSaving(false);
    }
  };

  /** 启用/停用类型 */
  const handleToggleType = async (record: DictTypeItem) => {
    const newStatus = record.status === 'Y' ? 'N' : 'Y';
    const res = await saveDictType({
      id: record.id,
      code: record.code,
      name: record.name,
      status: newStatus,
      remark: record.remark || '',
    });
    if (res.errorCode === '0') {
      message.success(newStatus === 'Y' ? '已启用' : '已停用');
      fetchTypeList();
    } else {
      message.error(res.errorMessage || '操作失败');
    }
  };

  // ========== 字典项操作 ==========

  /** 打开新增字典项弹窗 */
  const handleAddItem = () => {
    if (!selectedType) {
      message.warning('请先选择字典类型');
      return;
    }
    setItemEditRecord(null);
    itemForm.resetFields();
    // 排序号默认取当前数据中最大排序号 + 1
    const maxSort = itemData.reduce((max, item) => Math.max(max, item.sortNo || 0), 0);
    itemForm.setFieldsValue({ sortNo: maxSort + 1 });
    setItemModalOpen(true);
  };

  /** 打开编辑字典项弹窗 */
  const handleEditItem = (record: DictItemItem) => {
    setItemEditRecord(record);
    itemForm.setFieldsValue({
      id: record.id,
      parentDr: record.parentDr,
      code: record.code,
      name: record.name,
      sortNo: record.sortNo,
      status: record.status,
      remark: record.remark,
    });
    setItemModalOpen(true);
  };

  /** 保存字典项 */
  const handleSaveItem = async () => {
    try {
      const values = await itemForm.validateFields();
      if (!selectedType) {
        message.warning('请先选择字典类型');
        return;
      }
      setItemSaving(true);
      const res = await saveDictItem({
        id: values.id,
        parentDr: selectedType.id,
        code: values.code,
        name: values.name,
        status: values.status || 'Y',
        sortNo: values.sortNo,
        remark: values.remark || '',
      });
      if (res.errorCode === '0') {
        message.success('保存成功');
        setItemModalOpen(false);
        fetchItemList();
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch {
      // 表单校验失败
    } finally {
      setItemSaving(false);
    }
  };

  /** Switch 启用/停用字典项 */
  const handleToggleItem = async (record: DictItemItem, checked: boolean) => {
    const newStatus = checked ? 'Y' : 'N';
    const res = await saveDictItem({
      id: record.id,
      parentDr: record.parentDr,
      code: record.code,
      name: record.name,
      status: newStatus,
      sortNo: record.sortNo,
      remark: record.remark || '',
    });
    if (res.errorCode === '0') {
      message.success(newStatus === 'Y' ? '已启用' : '已停用');
      setItemData(prev =>
        prev.map(item =>
          item.id === record.id ? { ...item, status: newStatus, statusDesc: newStatus === 'Y' ? '启用' : '停用', statusFlag: newStatus } : item
        )
      );
    } else {
      message.error(res.errorMessage || '操作失败');
    }
  };

  // ========== 表格列定义 ==========

  /** 字典项表格列 */
  const itemColumns: ColumnsType<DictItemItem> = [
    { title: '编码', dataIndex: 'code', key: 'code', width: 120 },
    { title: '显示名称', dataIndex: 'name', key: 'name', width: 160 },
    { title: '排序', dataIndex: 'sortNo', key: 'sortNo', width: 80, align: 'center' },
    {
      title: '状态', dataIndex: 'status', key: 'status', width: 90, align: 'center',
      render: (_: string, record: DictItemItem) => (
        <Switch
          checked={record.status === 'Y'}
          onChange={(checked) => handleToggleItem(record, checked)}
          checkedChildren="启用"
          unCheckedChildren="停用"
        />
      ),
    },
    { title: '说明', dataIndex: 'remark', key: 'remark', ellipsis: true },
    {
      title: '操作', key: 'action', width: 80, align: 'center',
      render: (_: any, record: DictItemItem) => (
        <Button
          type="link"
          icon={<EditOutlined />}
          onClick={() => handleEditItem(record)}
        />
      ),
    },
  ];

  // ========== 左侧类型列表点击 ==========
  const handleTypeClick = (type: DictTypeItem) => {
    setSelectedType(type);
  };

  return (
    <Row gutter={16} style={{ height: '100%' }}>
      {/* ====== 左侧：字典类型列表 ====== */}
      <Col span={5}>
        <Card
          title="字典类型"
          size="small"
          style={{ height: '100%' }}
          extra={
            <Space size="small">
              <Button type="link" size="small" icon={<PlusOutlined />} onClick={handleAddType}>
                新增
              </Button>
            </Space>
          }
        >
          <div style={{ maxHeight: 'calc(100vh - 200px)', overflowY: 'auto' }}>
            {typeList.map((type) => (
              <div
                key={type.id}
                onClick={() => handleTypeClick(type)}
                style={{
                  padding: '8px 12px',
                  cursor: 'pointer',
                  borderRadius: 4,
                  marginBottom: 2,
                  backgroundColor: selectedType?.id === type.id ? '#e6f7ff' : 'transparent',
                  borderLeft: selectedType?.id === type.id ? '3px solid #1890ff' : '3px solid transparent',
                  color: type.status === 'N' ? '#999' : '#333',
                }}
              >
                {type.name}
                {type.status === 'N' && (
                  <span style={{ fontSize: 12, color: '#ff4d4f', marginLeft: 6 }}>(停用)</span>
                )}
              </div>
            ))}
            {typeList.length === 0 && !typeLoading && (
              <div style={{ textAlign: 'center', color: '#999', padding: 20 }}>暂无字典类型</div>
            )}
          </div>
        </Card>
      </Col>

      {/* ====== 右侧：字典项管理 ====== */}
      <Col span={19}>
        <Card
          title={
            selectedType
              ? `${selectedType.name} — 字典项管理`
              : '字典项管理'
          }
          size="small"
          extra={
            <Space>
              <Button type="primary" icon={<PlusOutlined />} onClick={handleAddItem}>
                新增字典项
              </Button>
            </Space>
          }
        >
          {/* 搜索栏 */}
          <Row gutter={16} style={{ marginBottom: 16 }}>
            <Col span={6}>
              <Input
                placeholder="编码"
                allowClear
                prefix={<SearchOutlined />}
                value={itemSearch.code}
                onChange={(e) => setItemSearch({ ...itemSearch, code: e.target.value })}
              />
            </Col>
            <Col span={6}>
              <Input
                placeholder="名称"
                allowClear
                prefix={<SearchOutlined />}
                value={itemSearch.name}
                onChange={(e) => setItemSearch({ ...itemSearch, name: e.target.value })}
              />
            </Col>
            <Col span={4}>
              <Select
                placeholder="状态"
                allowClear
                style={{ width: '100%' }}
                value={itemSearch.status || undefined}
                onChange={(val) => setItemSearch({ ...itemSearch, status: val || '' })}
              >
                <Option value="Y">启用</Option>
                <Option value="N">停用</Option>
              </Select>
            </Col>
            <Col span={4}>
              <Button
                icon={<ReloadOutlined />}
                onClick={() => {
                  setItemSearch({ code: '', name: '', status: '' });
                  setItemCurrentPage(1);
                }}
              >
                刷新
              </Button>
            </Col>
          </Row>

          {/* 字典项表格 */}
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 12, alignItems: 'center' }}>
            <span style={{ fontSize: 13, color: '#666' }}>共 {itemTotal} 条记录</span>
          </div>
          <Table<DictItemItem>
            rowKey="id"
            columns={itemColumns}
            dataSource={itemData}
            loading={itemLoading}
            locale={{ emptyText: '请选择字典类型' }}
            pagination={false}
            size="small"
          />
          <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
            <CustomPagination
              current={itemCurrentPage}
              pageSize={itemPageSize}
              total={itemTotal}
              onChange={(page, size) => {
                setItemCurrentPage(page);
                setItemPageSize(size);
                fetchItemList(page, size);
              }}
            />
          </div>
        </Card>
      </Col>

      {/* ====== 字典项新增/编辑弹窗 ====== */}
      <Modal
        title={itemEditRecord ? '编辑字典项' : '新增字典项'}
        open={itemModalOpen}
        onOk={handleSaveItem}
        onCancel={() => setItemModalOpen(false)}
        confirmLoading={itemSaving}
        destroyOnClose
      >
        <Form form={itemForm} layout="vertical">
          <Form.Item name="id" hidden><Input /></Form.Item>
          <Form.Item name="parentDr" hidden><Input /></Form.Item>
          <Form.Item
            name="code"
            label="编码"
            rules={[{ required: true, message: '请输入编码' }]}
          >
            <Input disabled={!!itemEditRecord} placeholder="请输入编码" maxLength={50} />
          </Form.Item>
          <Form.Item
            name="name"
            label="显示名称"
            rules={[{ required: true, message: '请输入显示名称' }]}
          >
            <Input placeholder="请输入显示名称" maxLength={100} />
          </Form.Item>
          <Form.Item name="sortNo" label="排序号">
            <InputNumber placeholder="请输入排序号" style={{ width: '100%' }} min={0} />
          </Form.Item>
          <Form.Item name="remark" label="说明">
            <Input.TextArea placeholder="请输入说明" rows={3} />
          </Form.Item>
        </Form>
      </Modal>

      {/* ====== 字典类型新增/编辑弹窗 ====== */}
      <Modal
        title={typeEditRecord ? '编辑字典类型' : '新增字典类型'}
        open={typeModalOpen}
        onOk={handleSaveType}
        onCancel={() => setTypeModalOpen(false)}
        confirmLoading={typeSaving}
        destroyOnClose
      >
        <Form form={typeForm} layout="vertical">
          <Form.Item name="id" hidden><Input /></Form.Item>
          <Form.Item
            name="code"
            label="编码"
            rules={[{ required: true, message: '请输入编码' }]}
          >
            <Input disabled={!!typeEditRecord} placeholder="请输入编码" maxLength={50} />
          </Form.Item>
          <Form.Item
            name="name"
            label="名称"
            rules={[{ required: true, message: '请输入名称' }]}
          >
            <Input placeholder="请输入名称" maxLength={100} />
          </Form.Item>
          <Form.Item name="remark" label="备注">
            <Input.TextArea placeholder="请输入备注" rows={3} />
          </Form.Item>
        </Form>
      </Modal>
    </Row>
  );
};

export default DRGDictManagement;
