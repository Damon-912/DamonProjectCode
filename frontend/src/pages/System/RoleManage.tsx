import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Button,
  Input,
  Modal,
  message,
  Space,
  Row,
  Col,
  Form,
  Switch,
  Select
} from 'antd';
import {
  PlusOutlined,
  SearchOutlined,
  ReloadOutlined,
  EditOutlined,
  DeleteOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import CustomPagination from '../../components/CustomPagination';
import { invoke } from '../../api/request';
import type { ApiResponse, PageResult } from '../../api/basicData';

const { Option } = Select;

// 分页参数
interface PaginationParams {
  current: number;
  pageSize: number;
  total: number;
}

// 角色项
interface RoleItem {
  id: number;
  code: string;
  descripts: string;
  enDesc?: string;
  mainInterface?: string;
  operCodeTable?: string;
  sendMsgToAllUser?: string;
  safeClassificat?: string;
  columnEdit?: string;
  layoutEdit?: string;
  defaultMenuType?: string;
  tokenOverTime?: number;
  startDate?: string;
  endDate?: string;
}

// 保存角色参数
interface SaveRoleParams {
  id?: number;
  code: string;
  descripts: string;
  enDesc?: string;
  mainInterface?: string;
  operCodeTable?: string;
  sendMsgToAllUser?: string;
  safeClassificat?: string;
  columnEdit?: string;
  layoutEdit?: string;
  defaultMenuType?: string;
  tokenOverTime?: number;
  startDate?: string;
  endDate?: string;
}

// 查询角色列表 (01010032)
const queryRoles = (
  params: {
    code?: string;
    descripts?: string;
  },
  pagination: { pageSize: number; currentPage: number }
): Promise<ApiResponse<PageResult<RoleItem>>> => {
  return invoke('01010032', [params], undefined, pagination);
};

// 保存角色 (01010031)
const saveRole = (params: SaveRoleParams): Promise<ApiResponse> => {
  return invoke('01010031', [params]);
};

const RoleManage: React.FC = () => {
  const [form] = Form.useForm();
  const [data, setData] = useState<RoleItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState<PaginationParams>({
    current: 1,
    pageSize: 10,
    total: 0
  });
  const [modalVisible, setModalVisible] = useState(false);
  const [modalTitle, setModalTitle] = useState('新增角色');
  const [editingRecord, setEditingRecord] = useState<RoleItem | null>(null);

  // 查询条件
  const [searchCode, setSearchCode] = useState('');
  const [searchDesc, setSearchDesc] = useState('');

  // 表格列定义
  const columns: ColumnsType<RoleItem> = [
    {
      title: '序号',
      key: 'index',
      width: 60,
      render: (_, __, index) => (pagination.current - 1) * pagination.pageSize + index + 1
    },
    {
      title: '角色编码',
      dataIndex: 'code',
      key: 'code',
      width: 120
    },
    {
      title: '角色名称',
      dataIndex: 'descripts',
      key: 'descripts',
      width: 150
    },
    {
      title: '英文名称',
      dataIndex: 'enDesc',
      key: 'enDesc',
      width: 150,
      render: (text: string) => text || '-'
    },
    {
      title: '安全级别',
      dataIndex: 'safeClassificat',
      key: 'safeClassificat',
      width: 100,
      render: (text: string) => text || '-'
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 150,
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
        </Space>
      )
    }
  ];

  // 查询角色列表
  const fetchData = async (page = pagination.current, size = pagination.pageSize) => {
    setLoading(true);
    try {
      const res = await queryRoles(
        {
          code: searchCode || undefined,
          descripts: searchDesc || undefined
        },
        { pageSize: size, currentPage: page }
      );

      if (String(res.errorCode) === '0' && res.result) {
        setData(res.result.rows || []);
        setPagination(prev => ({
          ...prev,
          total: res.result?.total || 0
        }));
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch (error) {
      console.error('查询角色失败:', error);
      message.error('查询角色失败');
    } finally {
      setLoading(false);
    }
  };

  // 初始化加载
  useEffect(() => {
    fetchData(1, pagination.pageSize);
  }, []);

  // 搜索
  const handleSearch = () => {
    setPagination(prev => ({ ...prev, current: 1 }));
    fetchData(1, pagination.pageSize);
  };

  // 重置
  const handleReset = () => {
    setSearchCode('');
    setSearchDesc('');
    setPagination(prev => ({ ...prev, current: 1 }));
    fetchData(1, pagination.pageSize);
  };

  // 新增
  const handleAdd = () => {
    setEditingRecord(null);
    setModalTitle('新增角色');
    form.resetFields();
    setModalVisible(true);
  };

  // 编辑
  const handleEdit = (record: RoleItem) => {
    setEditingRecord(record);
    setModalTitle('编辑角色');
    form.resetFields();
    setModalVisible(true);
    
    setTimeout(() => {
      form.setFieldsValue({
        id: record.id,
        code: record.code,
        descripts: record.descripts,
        enDesc: record.enDesc,
        mainInterface: record.mainInterface,
        operCodeTable: record.operCodeTable === 'Y',
        sendMsgToAllUser: record.sendMsgToAllUser === 'Y',
        safeClassificat: record.safeClassificat,
        columnEdit: record.columnEdit === 'Y',
        layoutEdit: record.layoutEdit === 'Y',
        defaultMenuType: record.defaultMenuType,
        tokenOverTime: record.tokenOverTime,
        startDate: record.startDate,
        endDate: record.endDate
      });
    }, 0);
  };

  // 保存角色
  const handleSave = async () => {
    try {
      const values = await form.validateFields();

      const params: SaveRoleParams = {
        id: editingRecord?.id,
        code: values.code,
        descripts: values.descripts,
        enDesc: values.enDesc,
        mainInterface: values.mainInterface,
        operCodeTable: values.operCodeTable ? 'Y' : 'N',
        sendMsgToAllUser: values.sendMsgToAllUser ? 'Y' : 'N',
        safeClassificat: values.safeClassificat,
        columnEdit: values.columnEdit ? 'Y' : 'N',
        layoutEdit: values.layoutEdit ? 'Y' : 'N',
        defaultMenuType: values.defaultMenuType,
        tokenOverTime: values.tokenOverTime,
        startDate: values.startDate,
        endDate: values.endDate
      };

      const res = await saveRole(params);

      if (String(res.errorCode) === '0') {
        message.success(editingRecord ? '修改成功' : '新增成功');
        setModalVisible(false);
        fetchData(pagination.current, pagination.pageSize);
      } else {
        message.error(res.errorMessage || (editingRecord ? '修改失败' : '新增失败'));
      }
    } catch (error) {
      console.error('保存角色失败:', error);
      message.error('保存角色失败');
    }
  };

  return (
    <div style={{ padding: 16 }}>
      {/* 查询条件 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Row gutter={16} align="middle">
          <Col>
            <Input
              placeholder="角色编码"
              value={searchCode}
              onChange={e => setSearchCode(e.target.value)}
              style={{ width: 140 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="角色名称"
              value={searchDesc}
              onChange={e => setSearchDesc(e.target.value)}
              style={{ width: 140 }}
              allowClear
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
          <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增角色</Button>
          <span>共 {pagination.total} 条记录</span>
        </div>
        <Table
          columns={columns}
          dataSource={data}
          rowKey="id"
          loading={loading}
          scroll={{ x: 800 }}
          size="small"
          pagination={false}
        />
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <CustomPagination
            current={pagination.current}
            pageSize={pagination.pageSize}
            total={pagination.total}
            onChange={(page, size) => {
              setPagination(prev => ({ ...prev, current: page, pageSize: size }));
              fetchData(page, size);
            }}
          />
        </div>
      </Card>

      {/* 新增/编辑弹窗 */}
      <Modal
        title={modalTitle}
        open={modalVisible}
        onOk={handleSave}
        onCancel={() => setModalVisible(false)}
        okText="确定"
        cancelText="取消"
        width={600}
      >
        <Form
          form={form}
          layout="vertical"
        >
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="code"
                label="角色编码"
                rules={[{ required: true, message: '请输入角色编码' }]}
              >
                <Input placeholder="请输入角色编码" maxLength={50} disabled={!!editingRecord} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="descripts"
                label="角色名称"
                rules={[{ required: true, message: '请输入角色名称' }]}
              >
                <Input placeholder="请输入角色名称" maxLength={50} />
              </Form.Item>
            </Col>
          </Row>
          
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="enDesc"
                label="英文名称"
              >
                <Input placeholder="请输入英文名称" maxLength={50} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="safeClassificat"
                label="安全级别"
              >
                <Input placeholder="请输入安全级别" maxLength={10} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="operCodeTable"
                label="操作码表"
                valuePropName="checked"
              >
                <Switch checkedChildren="是" unCheckedChildren="否" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="sendMsgToAllUser"
                label="发送消息给所有用户"
                valuePropName="checked"
              >
                <Switch checkedChildren="是" unCheckedChildren="否" />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="columnEdit"
                label="列编辑"
                valuePropName="checked"
              >
                <Switch checkedChildren="是" unCheckedChildren="否" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="layoutEdit"
                label="布局编辑"
                valuePropName="checked"
              >
                <Switch checkedChildren="是" unCheckedChildren="否" />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="tokenOverTime"
                label="Token超时时间(分钟)"
              >
                <Input type="number" placeholder="请输入Token超时时间" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="defaultMenuType"
                label="默认菜单类型"
              >
                <Input placeholder="请输入默认菜单类型" maxLength={10} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="startDate"
                label="开始日期"
              >
                <Input placeholder="YYYY-MM-DD" maxLength={10} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="endDate"
                label="结束日期"
              >
                <Input placeholder="YYYY-MM-DD" maxLength={10} />
              </Form.Item>
            </Col>
          </Row>
        </Form>
      </Modal>
    </div>
  );
};

export default RoleManage;
