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
  Tree,
  Select,
  Tag,
  Tabs,
  Divider
} from 'antd';
import {
  PlusOutlined,
  SearchOutlined,
  ReloadOutlined,
  EditOutlined,
  DeleteOutlined,
  MenuOutlined,
  SafetyOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { DataNode } from 'antd/es/tree';
import CustomPagination from '../../components/CustomPagination';

const { Option } = Select;
const { TabPane } = Tabs;

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
}

// 菜单项
interface MenuItem {
  id: number;
  key: string;
  menuDetailID: number;
  menuDetailDrDesc: string;
  seqNo: number;
  menuGroup?: string;
  children?: MenuItem[];
}

// 安全级别选项
const safeClassOptions = [
  { value: '1', label: '普通' },
  { value: '2', label: '重要' },
  { value: '3', label: '核心' },
];

// 默认菜单类型选项
const menuTypeOptions = [
  { value: '1', label: '类型1' },
  { value: '2', label: '类型2' },
];

const Roles: React.FC = () => {
  const [form] = Form.useForm();
  const [data, setData] = useState<RoleItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState<PaginationParams>({
    current: 1,
    pageSize: 10,
    total: 0
  });
  
  // 查询条件
  const [searchCode, setSearchCode] = useState('');
  const [searchName, setSearchName] = useState('');

  // 弹窗状态
  const [modalVisible, setModalVisible] = useState(false);
  const [modalTitle, setModalTitle] = useState('新增角色');
  const [editingRecord, setEditingRecord] = useState<RoleItem | null>(null);
  
  // 权限配置弹窗
  const [authVisible, setAuthVisible] = useState(false);
  const [authRecord, setAuthRecord] = useState<RoleItem | null>(null);
  const [menuTreeData, setMenuTreeData] = useState<DataNode[]>([]);
  const [selectedMenus, setSelectedMenus] = useState<string[]>([]);
  const [menuLoading, setMenuLoading] = useState(false);
  const [activeTab, setActiveTab] = useState('menu');

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
      width: 150
    },
    {
      title: '安全级别',
      dataIndex: 'safeClassificat',
      key: 'safeClassificat',
      width: 100,
      render: (value: string) => {
        const option = safeClassOptions.find(o => o.value === value);
        return option?.label || value || '-';
      }
    },
    {
      title: '允许列编辑',
      dataIndex: 'columnEdit',
      key: 'columnEdit',
      width: 100,
      render: (value: string) => (
        <Tag color={value === 'Y' ? 'green' : 'default'}>
          {value === 'Y' ? '是' : '否'}
        </Tag>
      )
    },
    {
      title: '允许布局编辑',
      dataIndex: 'layoutEdit',
      key: 'layoutEdit',
      width: 100,
      render: (value: string) => (
        <Tag color={value === 'Y' ? 'green' : 'default'}>
          {value === 'Y' ? '是' : '否'}
        </Tag>
      )
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 200,
      render: (_, record) => (
        <Space size="small">
          <Button
            type="link"
            size="small"
            icon={<SafetyOutlined />}
            onClick={() => handleAuth(record)}
          >
            权限
          </Button>
          <Button
            type="link"
            size="small"
            icon={<EditOutlined />}
            onClick={() => handleEdit(record)}
          >
            编辑
          </Button>
          <Button
            type="link"
            size="small"
            danger
            icon={<DeleteOutlined />}
            onClick={() => handleDelete(record)}
          >
            删除
          </Button>
        </Space>
      )
    }
  ];

  // 模拟角色列表数据
  const mockRoleData: RoleItem[] = [
    { id: 1, code: 'admin', descripts: '系统管理员', enDesc: 'System Admin', safeClassificat: '3', columnEdit: 'Y', layoutEdit: 'Y' },
    { id: 2, code: 'hosp_admin', descripts: '医院管理员', enDesc: 'Hospital Admin', safeClassificat: '2', columnEdit: 'Y', layoutEdit: 'N' },
    { id: 3, code: 'doctor', descripts: '医生', enDesc: 'Doctor', safeClassificat: '1', columnEdit: 'N', layoutEdit: 'N' },
    { id: 4, code: 'nurse', descripts: '护士', enDesc: 'Nurse', safeClassificat: '1', columnEdit: 'N', layoutEdit: 'N' },
    { id: 5, code: 'finance', descripts: '财务人员', enDesc: 'Finance', safeClassificat: '2', columnEdit: 'N', layoutEdit: 'N' },
  ];

  // 模拟菜单数据
  const mockMenuData: MenuItem[] = [
    {
      id: 1,
      key: '1',
      menuDetailID: 1,
      menuDetailDrDesc: '监控仪表盘',
      seqNo: 1,
      menuGroup: 'N'
    },
    {
      id: 2,
      key: '2',
      menuDetailID: 2,
      menuDetailDrDesc: 'DRG业务',
      seqNo: 2,
      menuGroup: 'Y',
      children: [
        { id: 21, key: '21', menuDetailID: 21, menuDetailDrDesc: '分组工作台', seqNo: 1, menuGroup: 'N' },
        { id: 22, key: '22', menuDetailID: 22, menuDetailDrDesc: 'DRG分组器', seqNo: 2, menuGroup: 'N' },
        { id: 23, key: '23', menuDetailID: 23, menuDetailDrDesc: '分组结果查询', seqNo: 3, menuGroup: 'N' },
      ]
    },
    {
      id: 3,
      key: '3',
      menuDetailID: 3,
      menuDetailDrDesc: 'DIP业务',
      seqNo: 3,
      menuGroup: 'Y',
      children: [
        { id: 31, key: '31', menuDetailID: 31, menuDetailDrDesc: 'DIP分组工作台', seqNo: 1, menuGroup: 'N' },
        { id: 32, key: '32', menuDetailID: 32, menuDetailDrDesc: '病种分值查询', seqNo: 2, menuGroup: 'N' },
      ]
    },
    {
      id: 4,
      key: '4',
      menuDetailID: 4,
      menuDetailDrDesc: '用户管理',
      seqNo: 4,
      menuGroup: 'Y',
      children: [
        { id: 41, key: '41', menuDetailID: 41, menuDetailDrDesc: '用户管理', seqNo: 1, menuGroup: 'N' },
        { id: 42, key: '42', menuDetailID: 42, menuDetailDrDesc: '用户申请审核', seqNo: 2, menuGroup: 'N' },
        { id: 43, key: '43', menuDetailID: 43, menuDetailDrDesc: '角色权限', seqNo: 3, menuGroup: 'N' },
        { id: 44, key: '44', menuDetailID: 44, menuDetailDrDesc: '菜单配置', seqNo: 4, menuGroup: 'N' },
      ]
    },
  ];

  // 查询角色列表
  const fetchData = async (page = pagination.current, size = pagination.pageSize) => {
    setLoading(true);
    try {
      // 模拟API调用，后续替换为真实接口
      // const res = await getGroupList({ code: searchCode, descripts: searchName }, { pageSize: size, currentPage: page });
      
      // 模拟数据过滤
      let filteredData = mockRoleData;
      if (searchCode) {
        filteredData = filteredData.filter(item => item.code.toLowerCase().includes(searchCode.toLowerCase()));
      }
      if (searchName) {
        filteredData = filteredData.filter(item => item.descripts.includes(searchName));
      }
      
      setData(filteredData);
      setPagination(prev => ({
        ...prev,
        total: filteredData.length
      }));
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
    setSearchName('');
    setPagination(prev => ({ ...prev, current: 1 }));
    fetchData(1, pagination.pageSize);
  };

  // 新增
  const handleAdd = () => {
    setEditingRecord(null);
    setModalTitle('新增角色');
    form.resetFields();
    setModalVisible(true);
    setTimeout(() => {
      form.setFieldsValue({
        operCodeTable: 'N',
        sendMsgToAllUser: 'N',
        safeClassificat: '1',
        columnEdit: 'N',
        layoutEdit: 'N'
      });
    }, 0);
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
        operCodeTable: record.operCodeTable || 'N',
        sendMsgToAllUser: record.sendMsgToAllUser || 'N',
        safeClassificat: record.safeClassificat || '1',
        columnEdit: record.columnEdit || 'N',
        layoutEdit: record.layoutEdit || 'N',
        defaultMenuType: record.defaultMenuType
      });
    }, 0);
  };

  // 删除
  const handleDelete = (record: RoleItem) => {
    Modal.confirm({
      title: '确认删除',
      content: `确定要删除角色"${record.descripts}"吗？`,
      onOk: async () => {
        try {
          // 后续替换为真实接口
          // await deleteGroup({ groupID: record.id });
          message.success('删除成功');
          fetchData(pagination.current, pagination.pageSize);
        } catch (error) {
          console.error('删除角色失败:', error);
          message.error('删除角色失败');
        }
      }
    });
  };

  // 保存角色
  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      
      // 后续替换为真实接口
      // const params = {
      //   id: editingRecord?.id,
      //   code: values.code,
      //   descripts: values.descripts,
      //   enDesc: values.enDesc,
      //   mainInterface: values.mainInterface,
      //   operCodeTable: values.operCodeTable,
      //   sendMsgToAllUser: values.sendMsgToAllUser,
      //   safeClassificat: values.safeClassificat,
      //   columnEdit: values.columnEdit,
      //   layoutEdit: values.layoutEdit,
      //   defaultMenuType: values.defaultMenuType
      // };
      // const res = await saveGroup(params);
      
      message.success(editingRecord ? '修改成功' : '新增成功');
      setModalVisible(false);
      fetchData(pagination.current, pagination.pageSize);
    } catch (error) {
      console.error('保存角色失败:', error);
      message.error('保存角色失败');
    }
  };

  // 打开权限配置弹窗
  const handleAuth = async (record: RoleItem) => {
    setAuthRecord(record);
    setAuthVisible(true);
    setMenuLoading(true);
    setActiveTab('menu');
    
    try {
      // 后续替换为真实接口
      // const res = await getGroupMenuDetail({ groupID: record.id });
      
      // 模拟加载菜单数据
      const treeData = convertMenuToTreeData(mockMenuData);
      setMenuTreeData(treeData);
      setSelectedMenus(['1', '21', '41']); // 模拟已选中的菜单
    } catch (error) {
      console.error('加载菜单失败:', error);
      message.error('加载菜单失败');
    } finally {
      setMenuLoading(false);
    }
  };

  // 转换菜单数据为Tree数据
  const convertMenuToTreeData = (menus: MenuItem[]): DataNode[] => {
    return menus.map(menu => ({
      key: menu.key,
      title: menu.menuDetailDrDesc,
      children: menu.children ? convertMenuToTreeData(menu.children) : undefined
    }));
  };

  // 保存权限配置
  const handleSaveAuth = async () => {
    if (!authRecord) return;
    try {
      // 后续替换为真实接口
      // await saveGroupMenu({ groupID: authRecord.id, menuIDs: selectedMenus });
      message.success('权限配置保存成功');
      setAuthVisible(false);
    } catch (error) {
      console.error('保存权限失败:', error);
      message.error('保存权限失败');
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
              value={searchName}
              onChange={e => setSearchName(e.target.value)}
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
          scroll={{ x: 1200 }}
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
        width={700}
      >
        <Form form={form} layout="vertical">
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="code"
                label="角色编码"
                rules={[{ required: true, message: '请输入角色编码' }]}
              >
                <Input placeholder="请输入角色编码" maxLength={20} disabled={!!editingRecord} />
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
                rules={[{ required: true, message: '请选择安全级别' }]}
              >
                <Select placeholder="请选择安全级别" options={safeClassOptions} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="columnEdit"
                label="允许列编辑"
                rules={[{ required: true, message: '请选择是否允许列编辑' }]}
              >
                <Select 
                  placeholder="请选择"
                  options={[
                    { value: 'Y', label: '是' },
                    { value: 'N', label: '否' }
                  ]}
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="layoutEdit"
                label="允许布局编辑"
                rules={[{ required: true, message: '请选择是否允许布局编辑' }]}
              >
                <Select 
                  placeholder="请选择"
                  options={[
                    { value: 'Y', label: '是' },
                    { value: 'N', label: '否' }
                  ]}
                />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="operCodeTable"
                label="操作码表"
                rules={[{ required: true, message: '请选择' }]}
              >
                <Select 
                  placeholder="请选择"
                  options={[
                    { value: 'Y', label: '是' },
                    { value: 'N', label: '否' }
                  ]}
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="sendMsgToAllUser"
                label="发送消息给所有用户"
                rules={[{ required: true, message: '请选择' }]}
              >
                <Select 
                  placeholder="请选择"
                  options={[
                    { value: 'Y', label: '是' },
                    { value: 'N', label: '否' }
                  ]}
                />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="defaultMenuType"
                label="默认菜单类型"
              >
                <Select placeholder="请选择默认菜单类型" options={menuTypeOptions} allowClear />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="mainInterface"
                label="主界面"
              >
                <Input placeholder="请输入主界面" maxLength={50} />
              </Form.Item>
            </Col>
          </Row>
        </Form>
      </Modal>

      {/* 权限配置弹窗 */}
      <Modal
        title={`配置权限 - ${authRecord?.descripts || ''}`}
        open={authVisible}
        onOk={handleSaveAuth}
        onCancel={() => setAuthVisible(false)}
        okText="保存"
        cancelText="取消"
        width={600}
      >
        <Tabs activeKey={activeTab} onChange={setActiveTab}>
          <TabPane tab="菜单权限" key="menu">
            <div style={{ maxHeight: 400, overflow: 'auto' }}>
              <Tree
                checkable
                treeData={menuTreeData}
                checkedKeys={selectedMenus}
                onCheck={(checkedKeys) => setSelectedMenus(checkedKeys as string[])}
                loading={menuLoading}
              />
            </div>
          </TabPane>
          <TabPane tab="数据权限" key="data">
            <div style={{ padding: '20px 0', textAlign: 'center', color: '#999' }}>
              <p>数据权限配置功能开发中...</p>
            </div>
          </TabPane>
          <TabPane tab="操作权限" key="operation">
            <div style={{ padding: '20px 0', textAlign: 'center', color: '#999' }}>
              <p>操作权限配置功能开发中...</p>
            </div>
          </TabPane>
        </Tabs>
      </Modal>
    </div>
  );
};

export default Roles;
