import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Button,
  Input,
  Select,
  Modal,
  message,
  Space,
  Tag,
  Popconfirm,
  Row,
  Col,
  Form,
  Tree,
  TreeSelect,
  Typography
} from 'antd';
import {
  PlusOutlined,
  SearchOutlined,
  ReloadOutlined,
  EditOutlined,
  DeleteOutlined,
  MenuOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { DataNode } from 'antd/es/tree';
import { queryHospitals, type HospitalItem } from '../../api/hospital';

const { Title } = Typography;
const { Option } = Select;
const { TreeNode } = TreeSelect;

// 菜单项定义
interface MenuItem {
  menuID: number;
  parentID: number;
  menuCode: string;
  menuName: string;
  menuType: 'module' | 'page' | 'button';
  menuIcon?: string;
  menuPath?: string;
  sortNo: number;
  active: string;
  hospitalIDs?: number[];
  children?: MenuItem[];
}

// 分页参数
interface PaginationParams {
  current: number;
  pageSize: number;
  total: number;
}

// 菜单类型选项
const menuTypeOptions = [
  { value: 'module', label: '模块' },
  { value: 'page', label: '页面' },
  { value: 'button', label: '按钮' },
];

const Menus: React.FC = () => {
  const [modalForm] = Form.useForm();
  const [menuData, setMenuData] = useState<MenuItem[]>([]);
  const [flatMenuData, setFlatMenuData] = useState<MenuItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState<PaginationParams>({
    current: 1,
    pageSize: 10,
    total: 0
  });
  const [modalVisible, setModalVisible] = useState(false);
  const [modalTitle, setModalTitle] = useState('新增菜单');
  const [editingMenu, setEditingMenu] = useState<MenuItem | null>(null);
  const [hospitals, setHospitals] = useState<HospitalItem[]>([]);
  const [hospitalLoading, setHospitalLoading] = useState(false);
  const [searchName, setSearchName] = useState('');
  const [searchType, setSearchType] = useState('');
  const [searchActive, setSearchActive] = useState('');

  // 查询医疗机构列表
  const fetchHospitals = async () => {
    setHospitalLoading(true);
    try {
      const res = await queryHospitals({ active: 'Y' }, { pageSize: 1000, currentPage: 1 });
      if (res.errorCode === '0' && res.result) {
        setHospitals(res.result.rows || []);
      } else {
        message.error(res.errorMessage || '获取医疗机构列表失败');
      }
    } catch (error) {
      console.error('获取医疗机构列表失败:', error);
      message.error('获取医疗机构列表失败');
    } finally {
      setHospitalLoading(false);
    }
  };

  // 加载菜单数据（模拟数据）
  const fetchMenus = async () => {
    setLoading(true);
    try {
      // 模拟API调用
      await new Promise(resolve => setTimeout(resolve, 500));
      
      // 模拟数据
      const mockMenus: MenuItem[] = [
        {
          menuID: 1,
          parentID: 0,
          menuCode: 'system',
          menuName: '系统管理',
          menuType: 'module',
          menuIcon: 'SettingOutlined',
          sortNo: 100,
          active: 'Y',
          children: [
            {
              menuID: 2,
              parentID: 1,
              menuCode: 'system-user',
              menuName: '用户管理',
              menuType: 'page',
              menuIcon: 'UserOutlined',
              menuPath: '/system/users',
              sortNo: 1,
              active: 'Y'
            },
            {
              menuID: 3,
              parentID: 1,
              menuCode: 'system-role',
              menuName: '角色权限',
              menuType: 'page',
              menuIcon: 'SafetyOutlined',
              menuPath: '/system/roles',
              sortNo: 2,
              active: 'Y'
            },
            {
              menuID: 4,
              parentID: 1,
              menuCode: 'system-menu',
              menuName: '菜单配置',
              menuType: 'page',
              menuIcon: 'MenuOutlined',
              menuPath: '/system/menus',
              sortNo: 3,
              active: 'Y'
            },
            {
              menuID: 5,
              parentID: 1,
              menuCode: 'system-hospital',
              menuName: '医疗机构管理',
              menuType: 'page',
              menuIcon: 'HospitalOutlined',
              menuPath: '/system/hospitals',
              sortNo: 4,
              active: 'Y',
              hospitalIDs: [1, 2] // 关联的医院ID
            }
          ]
        }
      ];

      setMenuData(mockMenus);
      // 展平数据用于表格显示
      const flattenData: MenuItem[] = [];
      const flatten = (menus: MenuItem[]) => {
        menus.forEach(menu => {
          flattenData.push({ ...menu, children: undefined });
          if (menu.children && menu.children.length > 0) {
            flatten(menu.children);
          }
        });
      };
      flatten(mockMenus);
      setFlatMenuData(flattenData);
      setPagination(prev => ({ ...prev, total: flattenData.length }));
    } catch (error) {
      console.error('加载菜单数据失败:', error);
      message.error('加载菜单数据失败');
    } finally {
      setLoading(false);
    }
  };

  // 表格列定义
  const columns: ColumnsType<MenuItem> = [
    {
      title: '序号',
      key: 'index',
      width: 60,
      render: (_, __, index) => (pagination.current - 1) * pagination.pageSize + index + 1
    },
    {
      title: '菜单编码',
      dataIndex: 'menuCode',
      key: 'menuCode',
      width: 120
    },
    {
      title: '菜单名称',
      dataIndex: 'menuName',
      key: 'menuName',
      width: 150
    },
    {
      title: '菜单类型',
      dataIndex: 'menuType',
      key: 'menuType',
      width: 80,
      render: (type: string) => {
        const typeMap: Record<string, string> = {
          'module': '模块',
          'page': '页面',
          'button': '按钮'
        };
        return typeMap[type] || type;
      }
    },
    {
      title: '菜单路径',
      dataIndex: 'menuPath',
      key: 'menuPath',
      width: 200,
      ellipsis: true
    },
    {
      title: '关联医院',
      key: 'hospitals',
      width: 200,
      ellipsis: true,
      render: (record: MenuItem) => {
        if (!record.hospitalIDs || record.hospitalIDs.length === 0) {
          return '全部医院';
        }
        const hospitalNames = record.hospitalIDs.map(id => {
          const hospital = hospitals.find(h => h.hospitalID === id);
          return hospital ? hospital.descripts : `ID: ${id}`;
        });
        return hospitalNames.join(', ');
      }
    },
    {
      title: '排序号',
      dataIndex: 'sortNo',
      key: 'sortNo',
      width: 80
    },
    {
      title: '状态',
      dataIndex: 'active',
      key: 'active',
      width: 80,
      render: (active: string) => (
        <Tag color={active === 'Y' ? 'green' : 'red'}>
          {active === 'Y' ? '启用' : '停用'}
        </Tag>
      )
    },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 180,
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
            description={`确定要删除菜单"${record.menuName}"吗？`}
            onConfirm={() => handleDelete(record)}
            okText="确定"
            cancelText="取消"
          >
            <Button type="link" size="small" danger icon={<DeleteOutlined />}>
              删除
            </Button>
          </Popconfirm>
        </Space>
      )
    }
  ];

  // 搜索
  const handleSearch = () => {
    // 这里可以实现搜索逻辑
    message.info('搜索功能待实现');
  };

  // 重置
  const handleReset = () => {
    setSearchName('');
    setSearchType('');
    setSearchActive('');
  };

  // 新增菜单
  const handleAdd = () => {
    setEditingMenu(null);
    setModalTitle('新增菜单');
    modalForm.resetFields();
    modalForm.setFieldsValue({
      active: 'Y',
      sortNo: 1,
      menuType: 'page'
    });
    setModalVisible(true);
  };

  // 编辑菜单
  const handleEdit = (record: MenuItem) => {
    setEditingMenu(record);
    setModalTitle('编辑菜单');
    modalForm.setFieldsValue({
      menuCode: record.menuCode,
      menuName: record.menuName,
      menuType: record.menuType,
      menuIcon: record.menuIcon,
      menuPath: record.menuPath,
      parentID: record.parentID,
      sortNo: record.sortNo,
      active: record.active,
      hospitalIDs: record.hospitalIDs || []
    });
    setModalVisible(true);
  };

  // 删除菜单
  const handleDelete = async (record: MenuItem) => {
    try {
      // 模拟删除操作
      await new Promise(resolve => setTimeout(resolve, 500));
      message.success('删除成功');
      fetchMenus();
    } catch (error) {
      console.error('删除菜单失败:', error);
      message.error('删除菜单失败');
    }
  };

  // 保存菜单
  const handleSave = async () => {
    try {
      const values = await modalForm.validateFields();
      
      // 模拟保存操作
      await new Promise(resolve => setTimeout(resolve, 500));
      message.success(editingMenu ? '修改成功' : '新增成功');
      setModalVisible(false);
      fetchMenus();
    } catch (error) {
      console.error('保存菜单失败:', error);
      message.error('保存菜单失败');
    }
  };

  // 构建树形选择器数据
  const buildTreeSelectData = (menus: MenuItem[]): DataNode[] => {
    return menus.map(menu => ({
      title: `${menu.menuName} (${menu.menuCode})`,
      value: menu.menuID,
      key: menu.menuID,
      children: menu.children ? buildTreeSelectData(menu.children) : []
    }));
  };

  // 初始化加载
  useEffect(() => {
    fetchHospitals();
    fetchMenus();
  }, []);

  return (
    <div style={{ padding: 16 }}>
      <Title level={4}>菜单配置</Title>
      
      {/* 查询条件 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Row gutter={16} align="middle">
          <Col>
            <Input
              placeholder="菜单名称"
              value={searchName}
              onChange={e => setSearchName(e.target.value)}
              style={{ width: 140 }}
              allowClear
            />
          </Col>
          <Col>
            <Select
              placeholder="菜单类型"
              value={searchType || undefined}
              onChange={v => setSearchType(v || '')}
              style={{ width: 100 }}
              allowClear
            >
              {menuTypeOptions.map(option => (
                <Option key={option.value} value={option.value}>{option.label}</Option>
              ))}
            </Select>
          </Col>
          <Col>
            <Select
              placeholder="状态"
              value={searchActive || undefined}
              onChange={v => setSearchActive(v || '')}
              style={{ width: 100 }}
              allowClear
            >
              <Option value="Y">启用</Option>
              <Option value="N">停用</Option>
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
          <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增菜单</Button>
          <span>共 {pagination.total} 条记录</span>
        </div>
        <Table
          columns={columns}
          dataSource={flatMenuData}
          rowKey="menuID"
          loading={loading}
          scroll={{ x: 1200 }}
          size="small"
          pagination={{
            current: pagination.current,
            pageSize: pagination.pageSize,
            total: pagination.total,
            showSizeChanger: true,
            showTotal: (t) => `共 ${t} 条`,
            onChange: (page, size) => {
              setPagination(prev => ({ ...prev, current: page, pageSize: size }));
            },
            locale: {
              items_per_page: '/页',
              jump_to: '跳至',
              page: '页',
            }
          }}
        />
      </Card>

      {/* 新增/编辑弹窗 */}
      <Modal
        title={modalTitle}
        open={modalVisible}
        onOk={handleSave}
        onCancel={() => setModalVisible(false)}
        width={600}
        destroyOnClose
      >
        <Form
          form={modalForm}
          layout="vertical"
          preserve={false}
        >
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="menuCode"
                label="菜单编码"
                rules={[{ required: true, message: '请输入菜单编码' }]}
              >
                <Input placeholder="请输入菜单编码" maxLength={50} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="menuName"
                label="菜单名称"
                rules={[{ required: true, message: '请输入菜单名称' }]}
              >
                <Input placeholder="请输入菜单名称" maxLength={50} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="menuType"
                label="菜单类型"
                rules={[{ required: true, message: '请选择菜单类型' }]}
              >
                <Select placeholder="请选择菜单类型">
                  {menuTypeOptions.map(option => (
                    <Option key={option.value} value={option.value}>{option.label}</Option>
                  ))}
                </Select>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="parentID"
                label="上级菜单"
              >
                <TreeSelect
                  placeholder="请选择上级菜单"
                  treeData={buildTreeSelectData(menuData)}
                  allowClear
                  treeDefaultExpandAll
                />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="menuIcon"
                label="菜单图标"
              >
                <Input placeholder="请输入图标名称（如：UserOutlined）" maxLength={50} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="menuPath"
                label="菜单路径"
              >
                <Input placeholder="请输入菜单路径（如：/system/users）" maxLength={200} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="sortNo"
                label="排序号"
                rules={[{ required: true, message: '请输入排序号' }]}
              >
                <Input type="number" placeholder="请输入排序号" min={0} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="active"
                label="状态"
                rules={[{ required: true, message: '请选择状态' }]}
              >
                <Select placeholder="请选择状态">
                  <Option value="Y">启用</Option>
                  <Option value="N">停用</Option>
                </Select>
              </Form.Item>
            </Col>
          </Row>

          <Form.Item
            name="hospitalIDs"
            label="关联医疗机构"
            extra="不选择表示所有医院可见"
          >
            <Select
              mode="multiple"
              placeholder="请选择关联的医疗机构"
              loading={hospitalLoading}
              allowClear
              showSearch
              filterOption={(input, option) =>
                String(option?.children ?? '').toLowerCase().indexOf(input.toLowerCase()) >= 0
              }
            >
              {hospitals.map(hospital => (
                <Option key={hospital.hospitalID} value={hospital.hospitalID}>
                  {hospital.descripts} ({hospital.code})
                </Option>
              ))}
            </Select>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default Menus;
