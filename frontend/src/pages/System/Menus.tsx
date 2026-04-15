import React, { useState, useEffect } from 'react';
import {
  Card,
  Table,
  Button,
  Input,
  Modal,
  message,
  Space,
  Popconfirm,
  Row,
  Col,
  Form,
  TreeSelect,
  Typography,
  Radio,
  Switch
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
import { getMenuTree, saveMenu, deleteMenu as deleteMenuApi, initDefaultMenus } from '../../api/menu';
// import CustomPagination from '../../components/CustomPagination'; // 暂时不使用，已注释

const { Title } = Typography;

// 菜单项定义(兼容新旧格式)
interface MenuItemLocal {
  id?: number;
  menuID?: number;
  parentID?: number;
  parentCode?: string;
  menuCode?: string;
  code?: string;
  menuName?: string;
  label?: string;
  menuType?: 'module' | 'page' | 'button';
  menuIcon?: string;
  icon?: string;
  menuPath?: string;
  linkPath?: string;
  routePath?: string;
  sortNo?: number;
  seqNo?: number;
  active?: string;
  isActive?: string;
  isVisible?: string;
  menuGroup?: string;
  level?: number;  // 新增：层级信息
  children?: MenuItemLocal[];
}

// 分页参数
interface PaginationParams {
  current: number;
  pageSize: number;
  total: number;
}

const Menus: React.FC = () => {
  const [modalForm] = Form.useForm();
  const [menuData, setMenuData] = useState<MenuItemLocal[]>([]);
  const [mainTableData, setMainTableData] = useState<MenuItemLocal[]>([]); // 主表：一级菜单
  const [subTableData, setSubTableData] = useState<MenuItemLocal[]>([]);   // 副表：当前选中菜单的子菜单
  const [selectedMainMenuItem, setSelectedMainMenuItem] = useState<MenuItemLocal | null>(null);
  const [loading, setLoading] = useState(false);
  // 由于分主副表显示，暂时不使用分页
  // const [pagination, setPagination] = useState<PaginationParams>({
  //   current: 1,
  //   pageSize: 20,
  //   total: 0
  // });
  const [modalVisible, setModalVisible] = useState(false);
  const [modalTitle, setModalTitle] = useState('新增菜单');
  const [editingMenu, setEditingMenu] = useState<MenuItemLocal | null>(null);
  const [searchName, setSearchName] = useState('');
  const [initLoading, setInitLoading] = useState(false);

  // 转换菜单数据格式
  const convertMenu = (item: any, parentCode: string = ''): MenuItemLocal => {
    const hasChildren = item.children && item.children.length > 0;
    
    // 计算当前菜单的层级
    const currentLevel = item.parentCode ? 2 : 1;
    
    return {
      id: item.id || item.menuDetailID,
      menuID: item.id || item.menuDetailID,
      code: item.code,
      menuCode: item.code,
      label: item.label,
      menuName: item.label,
      icon: item.icon,
      menuIcon: item.icon,
      linkPath: item.routePath,
      routePath: item.routePath,
      menuPath: item.routePath,
      seqNo: item.sortNo ? parseInt(item.sortNo) : 1,
      sortNo: item.sortNo ? parseInt(item.sortNo) : 1,
      parentCode: item.parentCode || parentCode || '',
      isActive: item.isActive,
      active: item.isActive,
      isVisible: item.isVisible,
      menuGroup: hasChildren ? 'Y' : 'N',
      level: currentLevel,
      children: item.children?.map((child: any) => convertMenu(child, item.code)) || []
    };
  };

  // 加载菜单数据
  const fetchMenus = async () => {
    setLoading(true);
    try {
      console.log('开始获取菜单数据...');
      // 调用后端API获取菜单树
      const res = await getMenuTree({});
      const errorCode = res.errorCode as string | number;
      
      // 后端可能返回 data 或 result 字段，需要兼容处理
      const responseData = res as any;
      const menuList = (responseData.data || responseData.result) as any[];
      console.log('后端返回的完整响应:', responseData);
      console.log('后端返回的菜单数据:', menuList);
      
      if ((errorCode === 0 || errorCode === '0') && menuList) {
        const menus = menuList.map(item => convertMenu(item));
        setMenuData(menus);
        
        // 分离主表数据（一级菜单）和副表数据（二级菜单）
        const mainData: MenuItemLocal[] = []; // 主表：一级菜单
        const allSubData: MenuItemLocal[] = []; // 所有二级菜单
        
        menus.forEach(menu => {
          // 一级菜单加入主表
          const mainItem: MenuItemLocal = {
            ...menu,
            children: undefined
          };
          mainData.push(mainItem);
          
          // 二级菜单加入副表
          if (menu.children && menu.children.length > 0) {
            menu.children.forEach((child: MenuItemLocal) => {
              const subItem: MenuItemLocal = {
                ...child,
                children: undefined,
                parentCode: menu.code,
                level: 2
              };
              allSubData.push(subItem);
            });
          }
        });
        
        console.log('主表数据（一级菜单）:', mainData);
        console.log('所有副表数据（二级菜单）:', allSubData);
        
        // 设置主表数据
        setMainTableData(mainData);
        
        // 处理搜索过滤
        let filteredMainData = mainData;
        if (searchName) {
          filteredMainData = mainData.filter(item => {
            const menuName = (item.menuName || item.label || '').toLowerCase();
            const searchTerm = searchName.toLowerCase();
            return menuName.includes(searchTerm);
          });
        }
        
        // 设置主表数据（支持搜索）
        setMainTableData(filteredMainData);
        
        // 默认选中第一个主表项
        if (filteredMainData.length > 0) {
          setSelectedMainMenuItem(filteredMainData[0]);
          const subData = allSubData.filter(item => item.parentCode === filteredMainData[0].code);
          setSubTableData(subData);
        } else {
          setSelectedMainMenuItem(null);
          setSubTableData([]);
        }
        
        // 由于分主副表显示，暂时不使用分页
        // 设置分页总数为主表数据数量
        // setPagination(prev => ({ ...prev, total: filteredMainData.length }));
      } else {
        console.error('获取菜单失败:', res.errorMessage);
        message.error(res.errorMessage || '获取菜单列表失败');
      }
    } catch (error) {
      console.error('加载菜单数据失败:', error);
      message.error('加载菜单数据失败');
    } finally {
      setLoading(false);
    }
  };

  // 初始化默认菜单
  const handleInitMenus = async () => {
    setInitLoading(true);
    try {
      const res = await initDefaultMenus({});
      const errorCode = res.errorCode as string | number;
      if (errorCode === 0 || errorCode === '0') {
        message.success('菜单初始化成功');
        fetchMenus();
      } else {
        message.error(res.errorMessage || '菜单初始化失败');
      }
    } catch (error) {
      console.error('菜单初始化失败:', error);
      message.error('菜单初始化失败');
    } finally {
      setInitLoading(false);
    }
  };

  // 处理主表项选择
  const handleMainTableSelect = (record: MenuItemLocal) => {
    setSelectedMainMenuItem(record);
    
    // 从所有菜单数据中过滤出当前选中菜单的子菜单
    const allSubData: MenuItemLocal[] = [];
    menuData.forEach(menu => {
      if (menu.children && menu.children.length > 0) {
        menu.children.forEach((child: MenuItemLocal) => {
          const subItem: MenuItemLocal = {
            ...child,
            children: undefined,
            parentCode: menu.code,
            level: 2
          };
          allSubData.push(subItem);
        });
      }
    });
    
    const subData = allSubData.filter(item => item.parentCode === record.code);
    setSubTableData(subData);
    console.log('选中主表项:', record.menuName, '对应的副表数据:', subData);
  };

  // 处理菜单状态切换
  const handleStatusChange = async (record: MenuItemLocal, checked: boolean) => {
    try {
      console.log('切换菜单状态:', record.menuName, '当前状态:', record.active, '新状态:', checked ? 'Y' : 'N');
      
      // 构建更新参数，格式要与saveMenu期望的一致
      const params = {
        menuID: record.menuID || record.id ? String(record.menuID || record.id) : undefined,
        code: record.code || record.menuCode || '',
        label: record.label || record.menuName || '',
        parentCode: record.parentCode || '',
        menuLevel: record.parentCode ? 2 : 1,
        sortNo: record.sortNo || record.seqNo || 1,
        icon: record.icon || record.menuIcon || '',
        routePath: record.linkPath || record.routePath || record.menuPath || '',
        isVisible: 'Y',
        isActive: checked ? 'Y' : 'N'
      };
      
      // 调用保存菜单API
      const res = await saveMenu(params);
      const errorCode = res.errorCode as string | number;
      
      if (errorCode === 0 || errorCode === '0') {
        message.success(checked ? '已启用' : '已停用');
        
        // 更新本地数据
        const updatedSubTableData = subTableData.map(item => {
          if (item.code === record.code) {
            return { ...item, active: checked ? 'Y' : 'N', isActive: checked ? 'Y' : 'N' };
          }
          return item;
        });
        
        // 更新主表数据
        const updatedMainTableData = mainTableData.map(item => {
          if (item.code === record.code) {
            return { ...item, active: checked ? 'Y' : 'N', isActive: checked ? 'Y' : 'N' };
          }
          return item;
        });
        
        setSubTableData(updatedSubTableData);
        setMainTableData(updatedMainTableData);
        
        // 如果更新的是当前选中的主表项，也更新其状态
        if (selectedMainMenuItem && selectedMainMenuItem.code === record.code) {
          setSelectedMainMenuItem({
            ...selectedMainMenuItem,
            active: checked ? 'Y' : 'N',
            isActive: checked ? 'Y' : 'N'
          });
        }
        
        // 重新加载数据确保一致性
        fetchMenus();
      } else {
        message.error(res.errorMessage || '状态更新失败');
      }
    } catch (error) {
      console.error('切换菜单状态失败:', error);
      message.error('切换菜单状态失败');
    }
  };

  // 主表列定义（只显示序号、菜单编码、菜单名称）
  const mainTableColumns: ColumnsType<MenuItemLocal> = [
    {
      title: '序号',
      key: 'index',
      width: 80,
      render: (_, __, index) => (
        <div style={{ textAlign: 'center' }}>{index + 1}</div>
      )
    },
    {
      title: '菜单编码',
      dataIndex: 'menuCode',
      key: 'menuCode',
      width: 150
    },
    {
      title: '菜单名称',
      dataIndex: 'menuName',
      key: 'menuName',
      width: 200,
      render: (text: string) => (
        <span style={{ fontWeight: 'bold', fontSize: '14px' }}>{text}</span>
      )
    }
  ];

  // 副表列定义（显示二级菜单）
  const subTableColumns: ColumnsType<MenuItemLocal> = [
    {
      title: '序号',
      key: 'index',
      width: 60,
      render: (_, __, index) => index + 1
    },
    {
      title: '菜单编码',
      dataIndex: 'menuCode',
      key: 'menuCode',
      width: 150
    },
    {
      title: '菜单名称',
      dataIndex: 'menuName',
      key: 'menuName',
      width: 180
    },
    {
      title: '父菜单',
      dataIndex: 'parentCode',
      key: 'parentCode',
      width: 120,
      render: (parentCode: string) => parentCode || '-'
    },
    {
      title: '菜单路径',
      dataIndex: 'menuPath',
      key: 'menuPath',
      width: 200,
      ellipsis: true
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
      width: 100,
      render: (active: string, record: MenuItemLocal) => (
        <Switch
          checked={active === 'Y' || active === '1'}
          checkedChildren="启用"
          unCheckedChildren="停用"
          onChange={(checked) => handleStatusChange(record, checked)}
        />
      )
    },
    {
      title: '操作',
      key: 'action',
      width: 120,
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



  // 构建树形选择器数据
  const buildTreeSelectData = (menus: MenuItemLocal[]): DataNode[] => {
    return menus.map(menu => ({
      title: `${menu.menuName || menu.label} (${menu.menuCode || menu.code})`,
      value: menu.code || menu.menuCode || '',
      key: menu.code || menu.menuCode || '',
      children: menu.children && menu.children.length > 0 ? buildTreeSelectData(menu.children) : undefined
    }));
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
  const handleEdit = (record: MenuItemLocal) => {
    setEditingMenu(record);
    setModalTitle('编辑菜单');
    modalForm.setFieldsValue({
      menuCode: record.code || record.menuCode,
      menuName: record.label || record.menuName,
      menuType: record.menuType || 'page',
      menuIcon: record.icon || record.menuIcon,
      menuPath: record.linkPath || record.routePath || record.menuPath,
      parentCode: record.parentCode,
      sortNo: record.sortNo || record.seqNo,
      active: record.active || record.isActive || 'Y'
    });
    setModalVisible(true);
  };

  // 删除菜单
  const handleDelete = async (record: MenuItemLocal) => {
    try {
      const code = record.code || record.menuCode;
      const res = await deleteMenuApi({ code });
      const errorCode = res.errorCode as string | number;
      if (errorCode === 0 || errorCode === '0') {
        message.success('删除成功');
        fetchMenus();
      } else {
        message.error(res.errorMessage || '删除失败');
      }
    } catch (error) {
      console.error('删除菜单失败:', error);
      message.error('删除菜单失败');
    }
  };

  // 保存菜单 - 使用operatetable模式
  const handleSave = async () => {
    try {
      const values = await modalForm.validateFields();
      
      // 获取菜单ID用于编辑
      const menuID = editingMenu ? (editingMenu.menuID || editingMenu.id)?.toString() : '';
      
      const params = {
        menuID: menuID,
        code: values.menuCode,
        label: values.menuName,
        parentCode: values.parentCode || '',
        menuLevel: values.parentCode ? 2 : 1,
        sortNo: values.sortNo || 1,
        icon: values.menuIcon || '',
        routePath: values.menuPath || '',
        isVisible: 'Y',
        isActive: values.active
      };
      
      const res = await saveMenu(params);
      const errorCode = res.errorCode as string | number;
      if (errorCode === 0 || errorCode === '0') {
        message.success(editingMenu ? '修改成功' : '新增成功');
        setModalVisible(false);
        fetchMenus();
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch (error) {
      console.error('保存菜单失败:', error);
      message.error('保存菜单失败');
    }
  };

  // 搜索
  const handleSearch = () => {
    fetchMenus();
  };

  // 重置
  const handleReset = () => {
    setSearchName('');
    setSelectedMainMenuItem(null);
    fetchMenus();
  };

  // 初始化加载
  useEffect(() => {
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
              onPressEnter={handleSearch}
              style={{ width: 200 }}
              allowClear
            />
          </Col>
          <Col>
            <Space>
              <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>查询</Button>
              <Button icon={<ReloadOutlined />} onClick={handleReset}>重置</Button>
              <Button 
                icon={<MenuOutlined />} 
                onClick={handleInitMenus}
                loading={initLoading}
              >
                初始化菜单
              </Button>
              <Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增菜单</Button>
            </Space>
          </Col>
        </Row>
      </Card>
      
      <div style={{ display: 'flex', gap: 16 }}>
        {/* 主表：一级菜单 */}
        <Card 
          size="small" 
          style={{ width: '40%', marginBottom: 16 }}
          title="主表 - 一级菜单"
        >
          <Table
            columns={mainTableColumns}
            dataSource={mainTableData}
            rowKey="code"
            loading={loading}
            scroll={{ x: 800 }}
            size="small"
            pagination={false}
            onRow={(record) => ({
              onClick: () => handleMainTableSelect(record),
              style: { 
                cursor: 'pointer',
                backgroundColor: selectedMainMenuItem?.code === record.code ? '#f0f0f0' : 'transparent'
              }
            })}
          />
        </Card>

        {/* 副表：二级菜单 */}
        <Card 
          size="small" 
          style={{ width: '60%', marginBottom: 16 }}
          title={selectedMainMenuItem ? `副表 - ${selectedMainMenuItem.menuName} 的子菜单` : '副表 - 子菜单'}
        >
          <Table
            columns={subTableColumns}
            dataSource={subTableData}
            rowKey="code"
            loading={loading}
            scroll={{ x: 1000 }}
            size="small"
            pagination={false}
          />
        </Card>
      </div>

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
                <Input placeholder="请输入菜单编码" maxLength={50} disabled={!!editingMenu} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="menuName"
                label="菜单名称"
                rules={[{ required: true, message: '请输入菜单名称' }]}
              >
                <Input placeholder="请输入菜单名称" maxLength={100} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="parentCode"
                label="上级菜单"
              >
                <TreeSelect
                  placeholder="请选择上级菜单(不选则为顶级)"
                  treeData={buildTreeSelectData(menuData)}
                  allowClear
                  treeDefaultExpandAll
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="sortNo"
                label="排序号"
                rules={[{ required: true, message: '请输入排序号' }]}
              >
                <Input type="number" placeholder="请输入排序号" min={1} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="menuIcon"
                label="菜单图标"
              >
                <Input placeholder="请输入图标名称(如: UserOutlined)" maxLength={50} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="active"
                label="状态"
                rules={[{ required: true, message: '请选择状态' }]}
              >
                <Radio.Group>
                  <Radio value="Y">启用</Radio>
                  <Radio value="N">停用</Radio>
                </Radio.Group>
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={24}>
              <Form.Item
                name="menuPath"
                label="菜单路径/路由"
              >
                <Input placeholder="请输入菜单路径(如: /system/users)" maxLength={200} />
              </Form.Item>
            </Col>
          </Row>
        </Form>
      </Modal>
    </div>
  );
};

export default Menus;
