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
  Tabs,
  Tag,
  Radio,
  Switch,
} from 'antd';
import {
  PlusOutlined,
  SearchOutlined,
  ReloadOutlined,
  EditOutlined,
  SafetyOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { DataNode } from 'antd/es/tree';
import CustomPagination from '../../components/CustomPagination';
import { queryGroupList, saveGroup, getGroupMenuDetail, saveGroupMenu, type GroupItem } from '../../api/system';
import { getMenuTree } from '../../api/menu';
import { useDict } from '../../hooks/useDict';
import { getDictLabel } from '../../utils/dict';

const { TabPane } = Tabs;

/**
 * 检查响应是否成功（兼容字符串 '0' 和数字 0）
 */
const isSuccess = (errorCode: string | number | undefined): boolean => {
  return errorCode === '0' || errorCode === 0;
};

// 分页参数
interface PaginationParams {
  current: number;
  pageSize: number;
  total: number;
}

const Roles: React.FC = () => {
  // 字典数据
  const { options: safeClassOptions } = useDict('SAFE_CLASS');
  const { options: menuTypeOptions } = useDict('MENU_TYPE');
  const { map: yesNoMap } = useDict('YES_NO_FLAG');
  const { map: commonStatusMap } = useDict('COMMON_STATUS');

  const [form] = Form.useForm();
  const [data, setData] = useState<GroupItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState<PaginationParams>({
    current: 1,
    pageSize: 10,
    total: 0
  });
  
  // 查询条件
  const [searchCode, setSearchCode] = useState('');
  const [searchName, setSearchName] = useState('');

  // 角色编码序号（从100000开始）
  const [roleCodeCounter, setRoleCodeCounter] = useState<number>(100000);

  // 弹窗状态
  const [modalVisible, setModalVisible] = useState(false);
  const [modalTitle, setModalTitle] = useState('新增角色');
  const [editingRecord, setEditingRecord] = useState<GroupItem | null>(null);
  
  // 权限配置弹窗
  const [authVisible, setAuthVisible] = useState(false);
  const [authRecord, setAuthRecord] = useState<GroupItem | null>(null);
  const [menuTreeData, setMenuTreeData] = useState<DataNode[]>([]);
  const [selectedMenuIds, setSelectedMenuIds] = useState<string[]>([]);
  const [activeTab, setActiveTab] = useState('menu');
  const [authLoading, setAuthLoading] = useState(false);

  // 表格列定义
  const columns: ColumnsType<GroupItem> = [
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
          {getDictLabel(yesNoMap, value)}
        </Tag>
      )
    },
    {
      title: '允许布局编辑',
      dataIndex: 'layoutEdit',
      key: 'layoutEdit',
      width: 105,
      render: (value: string) => (
        <Tag color={value === 'Y' ? 'green' : 'default'}>
          {getDictLabel(yesNoMap, value)}
        </Tag>
      )
    },    
    {
      title: '生效日期',
      dataIndex: 'startDate',
      key: 'startDate',
      width: 120,
      render: (value) => value ? new Date(value).toLocaleDateString() : '-'
    },
    {
      title: '状态',
      key: 'status',
      width: 80,
      render: (_, record) => {
        // 根据生效日期和失效日期判断状态
        const now = new Date();
        const startDate = record.startDate ? new Date(record.startDate) : null;
        const endDate = record.endDate ? new Date(record.endDate) : null;
        
        const isActive = (!startDate || startDate <= now) && (!endDate || endDate >= now);
        
        return (
          <Tag color={isActive ? 'green' : 'red'}>
            {isActive ? '在用' : '停用'}
          </Tag>
        );
      }
    },
    {
      title: '失效日期',
      dataIndex: 'endDate',
      key: 'endDate',
      width: 120,
      render: (value) => value ? new Date(value).toLocaleDateString() : '-'
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
        </Space>
      )
    }
  ];

  // 查询角色列表
  const fetchData = async (page = pagination.current, size = pagination.pageSize) => {
    setLoading(true);
    try {
      const res = await queryGroupList(
        { code: searchCode, descripts: searchName },
        { pageSize: size, currentPage: page }
      );
      
      // 兼容字符串和数字类型的 errorCode
      if (isSuccess(res.errorCode) && res.result) {
        const resultData = res.result as any;
        setData(resultData.rows || []);
        setPagination(prev => ({
          ...prev,
          total: resultData.total || 0
        }));
      } else {
        message.error(res.errorMessage || '获取角色列表失败');
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
    setSearchName('');
    setPagination(prev => ({ ...prev, current: 1 }));
    fetchData(1, pagination.pageSize);
  };

  // 按序号生成6位数字编码
  const generateCode = () => {
    // 获取当前序号
    const currentCounter = roleCodeCounter;
    
    // 确保编码不超过999999
    if (currentCounter > 999999) {
      message.error('角色编码已达到最大值999999');
      return '999999';
    }
    
    // 直接使用当前序号作为编码
    const code = currentCounter.toString();
    
    console.log('生成的顺序编码:', code, '当前序号:', currentCounter);
    
    // 递增序号
    setRoleCodeCounter(prev => prev + 1);
    
    return code;
  };

  // 新增
  const handleAdd = () => {
    setEditingRecord(null);
    setModalTitle('新增角色');
    form.resetFields();
    
    // 先生成角色编码
    const newCode = generateCode();
    
    // 设置默认日期：生效日期为今天，失效日期为空
    const today = new Date();
    const todayStr = today.toISOString().split('T')[0];
    
    setModalVisible(true);
    
    // 使用 nextTick 确保在弹框渲染完成后设置表单值
    setTimeout(() => {
      form.setFieldsValue({
        code: newCode,
        operCodeTable: 'N',
        sendMsgToAllUser: 'N',
        safeClassificat: '1',
        columnEdit: 'N',
        layoutEdit: 'N',
        startDate: todayStr,
        endDate: undefined
      });
    }, 0);
  };

  // 编辑
  const handleEdit = (record: GroupItem) => {
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
        defaultMenuType: record.defaultMenuType,
        startDate: record.startDate,
        endDate: record.endDate
      });
    }, 0);
  };



  // 更新角色状态（在用/停用）
  const handleStatusChange = async (record: GroupItem, checked: boolean) => {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    
    try {
      const params = {
        id: String(record.id),
        code: record.code,
        descripts: record.descripts,
        startDate: record.startDate,
        endDate: checked ? undefined : today.toISOString().split('T')[0] // 停用时设置失效日期为今天
      };
      
      const res = await saveGroup(params as any);
      // 兼容字符串和数字类型的 errorCode
      if (isSuccess(res.errorCode)) {
        message.success(checked ? '已启用' : '已停用');
        fetchData(pagination.current, pagination.pageSize);
      } else {
        message.error(res.errorMessage || '状态更新失败');
      }
    } catch (error) {
      console.error('更新角色状态失败:', error);
      message.error('更新角色状态失败');
    }
  };

  // 保存角色
  const handleSave = async () => {
    try {
      const values = await form.validateFields();
      
      const params = {
        id: editingRecord ? String(editingRecord.id) : undefined,
        code: values.code,
        descripts: values.descripts,
        enDesc: values.enDesc,
        mainInterface: values.mainInterface,
        operCodeTable: values.operCodeTable,
        sendMsgToAllUser: values.sendMsgToAllUser,
        safeClassificat: values.safeClassificat,
        columnEdit: values.columnEdit,
        layoutEdit: values.layoutEdit,
        defaultMenuType: values.defaultMenuType,
        startDate: values.startDate,
        endDate: values.endDate || undefined,
      };
      
      const res = await saveGroup(params);
      // 兼容字符串和数字类型的 errorCode
      if (isSuccess(res.errorCode)) {
        message.success(editingRecord ? '修改成功' : '新增成功');
        setModalVisible(false);
        fetchData(pagination.current, pagination.pageSize);
      } else {
        message.error(res.errorMessage || '保存失败');
      }
    } catch (error) {
      console.error('保存角色失败:', error);
      message.error('保存角色失败');
    }
  };

  // 打开权限配置弹窗
  const handleAuth = async (record: GroupItem) => {
    setAuthRecord(record);
    setAuthVisible(true);
    setActiveTab('menu');
    setSelectedMenuIds([]);
    setMenuTreeData([]); // 清空旧数据
    setAuthLoading(true);
    
    try {
      // 先加载菜单树
      const menuRes = await getMenuTree({});
      console.log('菜单树响应:', menuRes);
      console.log('errorCode类型:', typeof menuRes.errorCode, '值:', menuRes.errorCode);
      console.log('result:', menuRes.result);
      
      // 兼容字符串和数字类型的 errorCode
      if (isSuccess(menuRes.errorCode) && menuRes.result) {
        const menuList = menuRes.result as any[];
        console.log('菜单列表长度:', menuList.length);
        
        const convertToTreeData = (menus: any[]): DataNode[] => {
          return menus.map(menu => ({
            key: String(menu.id || ''),
            title: menu.label || '',
            children: menu.children && menu.children.length > 0 
              ? convertToTreeData(menu.children) 
              : undefined
          }));
        };
        
        const treeData = convertToTreeData(menuList);
        console.log('转换后的树数据:', treeData);
        setMenuTreeData(treeData);
        
        // 再获取角色已配置的菜单
        const res = await getGroupMenuDetail({ groupID: String(record.id), type: '1' });
        console.log('角色菜单详情:', res);
        
        // 兼容字符串和数字类型的 errorCode
        if (isSuccess(res.errorCode) && res.result) {
          const resultData = res.result as any;
          if (resultData.rows && resultData.rows.length > 0) {
            const selectedIds = resultData.rows.map((r: any) => String(r.menuDetailID));
            console.log('已选中菜单IDs:', selectedIds);
            setSelectedMenuIds(selectedIds);
          }
        }
      } else {
        message.warning('获取菜单树失败: ' + (menuRes.errorMessage || '未知错误'));
      }
    } catch (error) {
      console.error('加载权限数据失败:', error);
      message.error('加载权限数据失败');
    } finally {
      setAuthLoading(false);
    }
  };

  // 保存权限配置
  const handleSaveAuth = async () => {
    if (!authRecord) return;
    try {
      const menuDetail = selectedMenuIds.map(menuId => ({
        menuDetailID: menuId,
        seqNo: '',
        preMenuGroupID: ''
      }));
      
      const res = await saveGroupMenu({
        groupID: String(authRecord.id),
        type: '1',
        preMenuGroupID: '',
        menuDetail
      });
      
      // 兼容字符串和数字类型的 errorCode
      if (isSuccess(res.errorCode)) {
        message.success('权限配置保存成功');
        setAuthVisible(false);
        
        // 提示用户重新登录以使权限生效
        Modal.confirm({
          title: '权限已更新',
          content: `角色"${authRecord.descripts}"的权限配置已保存。请重新登录使新权限生效。`,
          okText: '立即重新登录',
          cancelText: '稍后登录',
          onOk: () => {
            // 清除 session 并刷新页面回到登录页
            localStorage.removeItem('drg_session');
            window.location.href = '/';
          }
        });
      } else {
        message.error(res.errorMessage || '保存权限失败');
      }
    } catch (error) {
      console.error('保存权限失败:', error);
      message.error('保存权限失败');
    }
  };

  // Tree复选事件处理
  const handleTreeCheck = (checkedKeys: any) => {
    if (Array.isArray(checkedKeys)) {
      setSelectedMenuIds(checkedKeys.map(String));
    } else if (checkedKeys && typeof checkedKeys === 'object' && 'checked' in checkedKeys) {
      setSelectedMenuIds((checkedKeys.checked || []).map(String));
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
                <Input placeholder="系统自动生成6位数字编码" maxLength={6} disabled readOnly />
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
              <Form.Item name="enDesc" label="英文名称">
                <Input placeholder="请输入英文名称" maxLength={50} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="safeClassificat"
                label="安全级别"
                rules={[{ required: true, message: '请选择安全级别' }]}
              >
                <Radio.Group>
                  {safeClassOptions.map(opt => (
                    <Radio key={opt.value} value={opt.value}>{opt.label}</Radio>
                  ))}
                </Radio.Group>
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
                <Radio.Group>
                  <Radio value="Y">是</Radio>
                  <Radio value="N">否</Radio>
                </Radio.Group>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="layoutEdit"
                label="允许布局编辑"
                rules={[{ required: true, message: '请选择是否允许布局编辑' }]}
              >
                <Radio.Group>
                  <Radio value="Y">是</Radio>
                  <Radio value="N">否</Radio>
                </Radio.Group>
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
                <Radio.Group>
                  <Radio value="Y">是</Radio>
                  <Radio value="N">否</Radio>
                </Radio.Group>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="sendMsgToAllUser"
                label="发送消息给所有用户"
                rules={[{ required: true, message: '请选择' }]}
              >
                <Radio.Group>
                  <Radio value="Y">是</Radio>
                  <Radio value="N">否</Radio>
                </Radio.Group>
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="defaultMenuType" label="默认菜单类型">
                <Radio.Group>
                  {menuTypeOptions.map(opt => (
                    <Radio key={opt.value} value={opt.value}>{opt.label}</Radio>
                  ))}
                </Radio.Group>
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="mainInterface" label="主界面">
                <Input placeholder="请输入主界面" maxLength={50} />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item 
                name="startDate" 
                label="生效日期"
                rules={[{ required: true, message: '请选择生效日期' }]}
              >
                <Input type="date" placeholder="请选择生效日期" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="endDate" label="失效日期">
                <Input type="date" placeholder="请选择失效日期（可选）" />
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
            <div style={{ maxHeight: 400, overflow: 'auto', minHeight: 200 }}>
              {/* 调试信息 */}
              <div style={{ fontSize: 12, color: '#999', padding: '5px 0' }}>
                调试: loading={authLoading.toString()}, menuTreeData.length={menuTreeData.length}
              </div>
              {authLoading ? (
                <div style={{ textAlign: 'center', padding: '40px 0' }}>
                  <span>加载中...</span>
                </div>
              ) : menuTreeData.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '40px 0', color: '#999' }}>
                  <p>暂无菜单数据</p>
                  <p style={{ fontSize: 12 }}>请确保后端 IRIS 服务正常运行，并已初始化菜单数据</p>
                  <Button type="primary" size="small" onClick={() => handleAuth(authRecord!)} style={{ marginTop: 10 }}>
                    重新加载
                  </Button>
                </div>
              ) : (
                <Tree
                  checkable
                  treeData={menuTreeData}
                  checkedKeys={selectedMenuIds}
                  onCheck={handleTreeCheck}
                  selectable={false}
                />
              )}
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
