import { useState, useEffect, useRef } from 'react';
import { Layout, Menu, Card, Row, Col, Statistic, Table, Tag, Progress, List, Avatar, Typography, Tabs, Input, Dropdown, Badge, Button, Popconfirm, message, Modal, Form } from 'antd';
import dayjs from 'dayjs';
import 'dayjs/locale/zh-cn';
import {
  DashboardOutlined,
  PartitionOutlined,
  MedicineBoxOutlined,
  AlertOutlined,
  DollarOutlined,
  FileTextOutlined,
  DatabaseOutlined,
  SettingOutlined,
  UserOutlined,
  MenuOutlined,
  WarningOutlined,
  SafetyOutlined,
  SearchOutlined,
  TableOutlined,
  AppstoreOutlined,
  CodeOutlined,
  ExperimentOutlined,
  CalculatorOutlined,
  CloseOutlined,
  HomeOutlined,
  LogoutOutlined,
  DownOutlined,
  LockOutlined,
  SyncOutlined,
  SwapOutlined
} from '@ant-design/icons';
import type { MenuProps, TabsProps } from 'antd';
import './App.css';
import { invoke } from './api/request';
import { getUserMenus } from './api/menu';
import { getSession, setTempUserInfo } from './utils/auth';
import { encryptPassword } from './utils/encryption';
import { MenuProvider, useMenu, defaultMenuItems } from './context/MenuContext';
import DRGCustomQuery from './pages/DRG/CustomQuery';
import Login from './pages/Login';
import SelectHospRole from './pages/Login/SelectHospRole';
import ICDMapping from './pages/BasicData/ICDMapping';
import ICDQuery from './pages/BasicData/ICDQuery';
import ADRGRuleMaintenance from './pages/BasicData/ADRGRuleMaintenance';
import CoreAlgorithmConfig from './pages/BasicData/DRGCoreAlgorithmConfig';
import BasicDataMaintenance from './pages/BasicData/BasicDataMaintenance';
import DIPDisease from './pages/BasicData/DIPDisease';
import TableDataMaintenance from './pages/BasicData/TableDataMaintenance';
import DRGCataLog from './pages/BasicData/DRGCataLog';
import DRGSegmentationRules from './pages/BasicData/DRGSegmentationRules';
import SpecialDRGGrouping from './pages/BasicData/SpecialDRGGrouping';
import DIPCoreAlgorithmConfig from './pages/BasicData/DIPCoreAlgorithmConfig';
import DRGDictManagement from './pages/BasicData/DRGDictManagement';

// DRG pages
import DRGWorkbench from './pages/DRG/Workbench';
import DRGResults from './pages/DRG/Results';

// DIP pages
import DIPWorkbench from './pages/DIP/Workbench';
import DIPDiseaseQuery from './pages/DIP/DiseaseQuery';
import DIPVarianceAnalysis from './pages/DIP/VarianceAnalysis';

// Warning pages
import WarningCenter from './pages/Warning/Center';
import WarningRules from './pages/Warning/Rules';
import WarningRecords from './pages/Warning/Records';
import WarningAnalysis from './pages/Warning/Analysis';

// Profit pages
import ProfitDept from './pages/Profit/Dept';
import ProfitDoctor from './pages/Profit/Doctor';
import ProfitDisease from './pages/Profit/Disease';
import ProfitCostStructure from './pages/Profit/CostStructure';

// System pages
import SystemUsers from './pages/System/Users';
import SystemRoles from './pages/System/Roles';
// import SystemRoleManage from './pages/System/RoleManage'; // 文件不存在，已注释
import SystemMenus from './pages/System/Menus';
import SystemInterfaces from './pages/System/Interfaces';
import SystemInterfaceLogs from './pages/System/InterfaceLogs';
import SystemHospitals from './pages/System/Hospitals';

// HIS Data pages
import HISMedicalRecords from './pages/HIS/MedicalRecords';
import HISSettlement from './pages/HIS/Settlement';
import HISDataSync from './pages/HIS/DataSync';

const { Header, Sider, Content } = Layout;
const { Title, Text } = Typography;

// 登录状态类型
type AuthState = 'login' | 'select' | 'authenticated';

// 扁平化菜单项用于搜索
interface FlatMenuItem {
  key: string;
  label: string;
  icon?: React.ReactNode;
}

const flattenMenuItems = (items: MenuProps['items']): FlatMenuItem[] => {
  const result: FlatMenuItem[] = [];
  items?.forEach(item => {
    if (item && 'key' in item && 'label' in item && item.key !== 'dashboard') {
      result.push({ 
        key: item.key as string, 
        label: item.label as string, 
        icon: 'icon' in item ? (item as any).icon : undefined 
      });
    }
    if (item && 'children' in item && item.children) {
      result.push(...flattenMenuItems(item.children));
    }
  });
  return result;
};

// 递归过滤菜单
const filterMenuItems = (items: MenuProps['items'], searchText: string): MenuProps['items'] => {
  if (!searchText) return items;
  const lowerSearch = searchText.toLowerCase();
  return items?.map(item => {
    if (!item) return item;
    const itemLabel = ('label' in item ? item.label : '') as string;
    const matchSelf = itemLabel.toLowerCase().includes(lowerSearch);
    if ('children' in item && item.children) {
      const filteredChildren = filterMenuItems(item.children, searchText);
      const hasMatchingChild = filteredChildren && filteredChildren.length > 0;
      if (matchSelf || hasMatchingChild) {
        return { ...item, children: filteredChildren };
      }
      return null;
    }
    return matchSelf ? item : null;
  }).filter(Boolean) as MenuProps['items'];
};

// 菜单key到标题的映射
const menuTitleMap: Record<string, string> = {
  'dashboard': '监控仪表盘',
  'drg-workbench': 'DRG分组工作台',
  'drg-custom-query': 'DRG分组器',
  'drg-results': '分组结果查询',
  'drg-batch': '批量分组任务',
  'dip-workbench': 'DIP分组工作台',
  'dip-values': '病种分值查询',
  'dip-analysis': '分值偏差分析',
  'warning-monitor': '预警监控中心',
  'warning-rules': '预警规则配置',
  'warning-records': '预警处理记录',
  'warning-analysis': '费用预警分析',
  'profit-dept': '科室盈亏报表',
  'profit-doctor': '医生盈亏分析',
  'profit-disease': '病种盈亏统计',
  'profit-structure': '费用结构分析',
  'qc-center': '质控检查中心',
  'qc-issues': '质控问题列表',
  'qc-stats': '质控统计报表',
  'data-records': '病案数据查询',
  'data-settlement': '结算清单管理',
  'data-sync': '数据同步监控',
  'basic-data-dict': 'DRG基础数据维护',
  'basic-data-drg-dict': '字典数据管理',
  'basic-data-table': '基础表数据维护',
  'basic-data-icd-mapping': 'ICD编码映射',
  'basic-data-icd-query': 'ICD编码查询',
  'basic-data-adrg-rules': 'ADRG分组规则维护',
  'basic-data-core-algorithm': 'DRG算法配置维护',
  'basic-data-dip': 'DIP付费病种库',
  'basic-data-drg-catalog': 'DRG目录信息',
  'basic-data-segmentation-rules': 'ADRG细分规则',
  'basic-data-special-grouping': '特异化DRG分组规则',
  'basic-data-dip-core-algorithm': 'DIP算法配置',
  'dip-core-algorithm': 'DIP算法配置',
  'system-user': '用户管理',
  'system-role': '角色权限',
  'system-role-manage': '角色管理',
  'system-menu': '菜单配置',
  'system-hospital': '医疗机构管理',
  'system-api': '接口服务配置',
  'system-logs': '接口日志',
};

const menuItems: MenuProps['items'] = [
  {
    key: 'dashboard',
    icon: <DashboardOutlined />,
    label: '监控仪表盘',
  },
  {
    key: 'drg',
    icon: <PartitionOutlined />,
    label: 'DRG业务',
    children: [
      { key: 'drg-workbench', label: '分组工作台' },
      { key: 'drg-custom-query', label: 'DRG分组器' },
      { key: 'drg-results', label: '分组结果查询' },
      { key: 'drg-batch', label: '批量分组任务' },
    ],
  },
  {
    key: 'dip',
    icon: <MedicineBoxOutlined />,
    label: 'DIP业务',
    children: [
      { key: 'dip-workbench', label: 'DIP分组工作台' },
      { key: 'dip-values', label: '病种分值查询' },
      { key: 'dip-analysis', label: '分值偏差分析' },
    ],
  },
  {
    key: 'warning',
    icon: <AlertOutlined />,
    label: '费用预警',
    children: [
      { key: 'warning-monitor', label: '预警监控中心' },
      { key: 'warning-analysis', label: '费用预警分析' },
      { key: 'warning-rules', label: '预警规则配置' },
      { key: 'warning-records', label: '预警处理记录' },
    ],
  },
  {
    key: 'profit',
    icon: <DollarOutlined />,
    label: '盈亏分析',
    children: [
      { key: 'profit-dept', label: '科室盈亏报表' },
      { key: 'profit-doctor', label: '医生盈亏分析' },
      { key: 'profit-disease', label: '病种盈亏统计' },
      { key: 'profit-structure', label: '费用结构分析' },
    ],
  },
  {
    key: 'qc',
    icon: <FileTextOutlined />,
    label: '病案质控',
    children: [
      { key: 'qc-center', label: '质控检查中心' },
      { key: 'qc-issues', label: '质控问题列表' },
      { key: 'qc-stats', label: '质控统计报表' },
    ],
  },
  {
    key: 'data',
    icon: <DatabaseOutlined />,
    label: 'HIS数据',
    children: [
      { key: 'data-records', label: '病案数据查询' },
      { key: 'data-settlement', label: '结算清单管理' },
      { key: 'data-sync', label: '数据同步监控' },
    ],
  },
  {
    key: 'basic-data',
    icon: <TableOutlined />,
    label: '数据管理',
    children: [
      { key: 'basic-data-dict', label: 'DRG基础数据' },
      { key: 'basic-data-drg-dict', label: '字典管理' },
      { key: 'basic-data-icd-mapping', label: 'ICD编码映射' },
      { key: 'basic-data-icd-query', label: 'ICD编码查询' },
      { key: 'basic-data-adrg-rules', label: 'ADRG分组规则' },
      { key: 'basic-data-core-algorithm', label: 'DRG算法配置' },
      { key: 'basic-data-dip', label: 'DIP付费病种库' },
      { key: 'basic-data-drg-catalog', label: 'DRG目录信息' },
      { key: 'basic-data-segmentation-rules', label: 'ADRG细分规则' },
      { key: 'basic-data-special-grouping', label: '特异化分组内涵表' },
      { key: 'basic-data-dip-core-algorithm', label: 'DIP算法配置' },
    ],
  },
  {
    key: 'user',
    icon: <UserOutlined />,
    label: '用户管理',
    children: [
      { key: 'system-user', label: '用户管理' },
      { key: 'system-role', label: '角色权限' },
      { key: 'system-menu', label: '菜单配置' },
    ],
  },
  {
    key: 'system',
    icon: <SafetyOutlined />,
    label: '系统管理',
    children: [
      { key: 'system-hospital', label: '医疗机构管理' },
      { key: 'system-api', label: '接口服务配置' },
      { key: 'system-logs', label: '接口日志' },
    ],
  },
];

const dashboardData = [
  { title: '本月出院病历', value: 1248, suffix: '份', color: '#1890ff' },
  { title: '已分组病历', value: 1186, suffix: '份', color: '#52c41a' },
  { title: '未分组病历', value: 62, suffix: '份', color: '#faad14' },
  { title: '分组成功率', value: 95.0, suffix: '%', color: '#722ed1' },
];

const drgStats = [
  { rank: 1, drg: 'ES23', name: '呼吸系统肿瘤', count: 86, rate: 6.9 },
  { rank: 2, drg: 'FB23', name: '心脏介入治疗', count: 72, rate: 5.8 },
  { rank: 3, drg: 'IC13', name: '关节置换', count: 65, rate: 5.2 },
  { rank: 4, drg: 'GC13', name: '消化系统其他手术', count: 58, rate: 4.6 },
  { rank: 5, drg: 'BR23', name: '神经系统肿瘤', count: 52, rate: 4.2 },
];

const warningData = [
  { level: 'high', title: '超费用预警', count: 23, desc: '费用超出DRG支付标准' },
  { level: 'medium', title: '低风险死亡', count: 5, desc: 'DRG低风险组发生死亡' },
  { level: 'low', title: '再入院预警', count: 18, desc: '7天内非计划再入院' },
];

// 标签页类型定义
interface TabItem {
  key: string;
  label: string;
  closable: boolean;
}

function App() {
  // 强制设置 dayjs 为中文，确保 DatePicker 等组件显示中文
  useEffect(() => {
    dayjs.locale('zh-cn');
  }, []);

  // 登录状态管理
  const [authState, setAuthState] = useState<AuthState>('login');
  const [userInfo, setUserInfo] = useState<{ userName: string; hospName: string; roleName: string; userID?: string } | null>(null);

  // ★ 标记是否为"切换登录"操作，用于判断是否需要关闭所有已打开标签页
  const isSwitchingLogin = useRef(false);

  // 修改密码弹窗状态
  const [pwdModalVisible, setPwdModalVisible] = useState(false);
  const [pwdForm] = Form.useForm();
  const [pwdLoading, setPwdLoading] = useState(false);

  // 主应用状态（必须在条件渲染之前声明所有hooks）
  const [collapsed, setCollapsed] = useState(false);
  const [currentMenu, setCurrentMenu] = useState('dashboard');
  const [menuSearch, setMenuSearch] = useState('');
  const [searchVisible, setSearchVisible] = useState(false);

  // 使用菜单上下文获取动态菜单
  const { menuItems: dynamicMenuItems, clearMenus, isLoaded, loadMenusFromLogin } = useMenu();

  // 使用动态菜单（如果有）或默认菜单
  const menuItems = isLoaded && dynamicMenuItems.length > 0 ? dynamicMenuItems : defaultMenuItems;
  
  // ★ 运行时日志：记录当前菜单状态，便于排查角色菜单过滤问题
  useEffect(() => {
    console.log('[App] 菜单状态 - isLoaded:', isLoaded, '| dynamicMenuItems.length:', dynamicMenuItems.length, '| 实际使用菜单项数:', menuItems?.length);
    if (dynamicMenuItems.length > 0) {
      console.log('[App] ★ 使用角色动态菜单:', JSON.stringify(dynamicMenuItems, null, 2));
    } else if (!isLoaded) {
      console.warn('[App] ⚠️ 菜单未加载(isLoaded=false)，使用默认全量菜单（所有用户看到所有菜单）');
    } else {
      console.warn('[App] ⚠️ 菜单已加载但为空(isLoaded=true, dynamicMenuItems=[])，当前角色无菜单权限');
    }
  }, [isLoaded, dynamicMenuItems, menuItems]);

  // 获取用户菜单的函数
  const fetchUserMenus = async (session: NonNullable<ReturnType<typeof getSession>>) => {
    try {
      const groupID = session.groupID || '';
      const userCode = session.userCode || '';
      console.log('[App] fetchUserMenus 开始, userCode:', userCode, 'groupID:', groupID);
      
      const res = await getUserMenus({
        userCode,
        groupID
      });
      
      console.log('[App] getUserMenus原始响应:', JSON.stringify(res, null, 2));
      
      // getUserMenus 返回的是 MenuItem[] 或 ApiResponse<MenuItem[]>
      let menus: any[] | null = null;
      if (String(res.errorCode) === '0' && res.result) {
        if (Array.isArray(res.result)) {
          menus = res.result;
        } else if ((res.result as any)?.rows && Array.isArray((res.result as any).rows)) {
          menus = (res.result as any).rows;
        }
      }
      
      if (menus && menus.length > 0) {
        console.log('[App] 从后端获取到用户菜单:', menus.length, '项, groupID:', groupID);
        loadMenusFromLogin(menus);
      } else {
        console.warn('[App] 获取用户菜单失败或无权限菜单, groupID:', groupID, ', errorMessage:', res.errorMessage);
        // ★ 即使菜单为空也标记已加载，避免回退到默认全量菜单
        loadMenusFromLogin([]);
      }
    } catch (error) {
      console.error('[App] 获取用户菜单异常:', error);
      // 异常时也标记已加载，避免回退到默认菜单
      loadMenusFromLogin([]);
    }
  };

  // 检查登录状态
  useEffect(() => {
    const session = getSession();
    console.log('检查登录状态 - Session数据:', JSON.stringify(session, null, 2));
    
    if (session && session.sessionID) {
      console.log('Session loaded, 设置用户信息:', {
        userName: session.userName,
        hospName: session.hospDesc,
        roleName: session.groupDesc,
        userID: session.userID
      });
      
      setAuthState('authenticated');
      setUserInfo({
        userName: session.userName || '管理员',
        hospName: session.hospDesc || session.hospID || '',
        roleName: session.groupDesc || session.groupID || '',
        userID: session.userID || ''
      });
      
      // 刷新后如果菜单未加载，尝试从session恢复或重新获取
      if (!isLoaded) {
        console.log('[App] 刷新后菜单未加载，尝试恢复...');
        
        // 优先从session恢复菜单
        if (session.menus && session.menus.length > 0) {
          console.log('[App] 从session恢复菜单:', session.menus.length, '项');
          loadMenusFromLogin(session.menus);
        } else {
          // session中没有菜单，重新从后端获取
          console.log('[App] session中无菜单，重新从后端获取...');
          fetchUserMenus(session);
        }
      }
    }
  }, [isLoaded]);

  // 处理登出
  const handleLogout = () => {
    localStorage.removeItem('drg_session');
    clearMenus(); // 清空菜单
    // ★ 关闭所有已打开的标签页，确保再次登录时以全新状态开始
    setOpenTabs([{ key: 'dashboard', label: '监控仪表盘', closable: false }]);
    setCurrentMenu('dashboard');
    setAuthState('login');
    setUserInfo(null);
    message.success('已登出');
  };

  // 处理切换登录角色
  const handleSwitchLogin = () => {
    // ★ 标记为切换登录操作，登录成功后需要关闭所有标签页
    isSwitchingLogin.current = true;
    
    // 保存当前用户信息到临时存储，避免重新输入密码
    if (userInfo?.userID && userInfo?.userName) {
      const session = getSession();
      setTempUserInfo({
        userID: userInfo.userID,
        userCode: session?.userCode || '',
        userName: userInfo.userName
      });
    }
    // 清除当前session和菜单
    localStorage.removeItem('drg_session');
    clearMenus();
    // 跳转到选择角色页面
    setAuthState('select');
    setUserInfo(null);
    message.success('请选择新的登录角色');
  };

  // 处理打开修改密码弹窗
  const handleOpenPwdModal = () => {
    pwdForm.resetFields();
    setPwdModalVisible(true);
  };

  // 处理修改密码
  const handleChangePassword = async () => {
    try {
      const values = await pwdForm.validateFields();
      setPwdLoading(true);

      // 从 session 获取 userID
      const session = getSession();
      const userID = session?.userID || userInfo?.userID;
      
      console.log('修改密码 - userID:', userID);
      console.log('修改密码 - session:', session);
      
      if (!userID) {
        message.error('获取用户信息失败，请重新登录');
        setPwdLoading(false);
        return;
      }

      // 加密密码（与登录时一致）
      const encryptedOldPassword = encryptPassword(values.oldPassword);
      const encryptedNewPassword = encryptPassword(values.newPassword);
      const encryptedConfirmPassword = encryptPassword(values.confirmPassword);
      
      console.log('原密码加密:', encryptedOldPassword);
      console.log('新密码加密:', encryptedNewPassword);

      // 调用修改密码接口 01040090
      const res = await invoke('01040090', [{
        userID: String(userID),
        originPassword: encryptedOldPassword,
        password: encryptedNewPassword,
        confirmPassword: encryptedConfirmPassword
      }]);

      if (String(res.errorCode) === '0') {
        message.success('密码修改成功，请重新登录');
        setPwdModalVisible(false);
        // 修改成功后登出
        handleLogout();
      } else {
        message.error(res.errorMessage || '密码修改失败');
      }
    } catch (error) {
      console.error('修改密码失败:', error);
      message.error('修改密码失败');
    } finally {
      setPwdLoading(false);
    }
  };

  // 处理初始化登录密码
  const handleInitPassword = () => {
    Modal.confirm({
      title: '确认初始化',
      content: `确定要将您的登录密码初始化为"123456"吗？`,
      okText: '确定',
      cancelText: '取消',
      async onOk() {
        setPwdLoading(true);
        try {
          const session = getSession();
          const userID = session?.userID || userInfo?.userID;

          if (!userID) {
            message.error('获取用户信息失败，请重新登录');
            setPwdLoading(false);
            return;
          }

          const res = await invoke('01040091', [{
            userID: String(userID),
            password: '123456',
            confirmPassword: '123456'
          }]);

          if (String(res.errorCode) === '0') {
            message.success('密码初始化成功，已设置为"123456"');
            setPwdModalVisible(false);
          } else {
            message.error(res.errorMessage || '密码初始化失败');
          }
        } catch (error) {
          console.error('初始化密码失败:', error);
          message.error('初始化密码失败');
        } finally {
          setPwdLoading(false);
        }
      }
    });
  };



  // 获取扁平化的菜单列表用于搜索
  const flatMenuList = flattenMenuItems(menuItems);

  // 搜索结果
  const searchResults = menuSearch
    ? flatMenuList.filter(item => item.label.toLowerCase().includes(menuSearch.toLowerCase()))
    : [];

  // 处理搜索选中
  const handleSearchSelect = ({ key }: { key: string }) => {
    handleMenuClick(key);
    setMenuSearch('');
    setSearchVisible(false);
  };

  // 根据搜索过滤菜单
  const filteredMenuItems = filterMenuItems(menuItems, menuSearch);
  // 已打开的标签页列表
  const [openTabs, setOpenTabs] = useState<TabItem[]>([
    { key: 'dashboard', label: '监控仪表盘', closable: false }
  ]);

  // 处理菜单点击 - 打开新标签或切换到已有标签
  const handleMenuClick = (key: string) => {
    const title = menuTitleMap[key] || key;
    // 检查标签是否已存在
    const existingTab = openTabs.find(tab => tab.key === key);
    if (existingTab) {
      setCurrentMenu(key);
    } else {
      // 新增标签页
      setOpenTabs([...openTabs, { key, label: title, closable: key !== 'dashboard' }]);
      setCurrentMenu(key);
    }
  };

  // 关闭标签页
  const handleCloseTab = (key: string) => {
    if (key === 'dashboard') return; // 不允许关闭首页
    const newTabs = openTabs.filter(tab => tab.key !== key);
    setOpenTabs(newTabs);
    // 如果关闭的是当前标签，切换到最后一个标签
    if (currentMenu === key) {
      const newCurrent = newTabs.length > 0 ? newTabs[newTabs.length - 1].key : 'dashboard';
      setCurrentMenu(newCurrent);
    }
  };

  // 标签页切换
  const handleTabChange = (key: string) => {
    setCurrentMenu(key);
  };

  // 根据菜单key渲染对应的组件
  const renderContent = (key: string) => {
    switch (key) {
      case 'dashboard':
        return (
          <div style={{ padding: 16, width: '100%', height: '100%' }}>
            {/* 统计卡片 */}
            <Row gutter={[16, 16]} style={{ marginBottom: 24, width: '100%' }}>
              {dashboardData.map((item, index) => (
                <Col xs={24} sm={12} md={6} key={index}>
                  <Card style={{ width: '100%' }}>
                    <Statistic
                      title={item.title}
                      value={item.value}
                      suffix={item.suffix}
                      valueStyle={{ color: item.color }}
                    />
                  </Card>
                </Col>
              ))}
            </Row>
            
            {/* 图表区域 */}
            <Row gutter={[16, 16]} style={{ width: '100%' }}>
              <Col xs={24} lg={16}>
                <Card title="DRG分组病历TOP5" extra={<a href="#">更多</a>} style={{ width: '100%' }}>
                  <Table 
                    dataSource={drgStats} 
                    columns={columns} 
                    pagination={false}
                    rowKey="rank"
                    size="small"
                  />
                </Card>
              </Col>
              <Col xs={24} lg={8}>
                <Card title="费用预警" style={{ width: '100%' }}>
                  <List
                    itemLayout="horizontal"
                    dataSource={warningData}
                    renderItem={(item) => (
                      <List.Item>
                        <List.Item.Meta
                          avatar={<Avatar icon={<WarningOutlined />} style={{ 
                            backgroundColor: item.level === 'high' ? '#ff4d4f' : item.level === 'medium' ? '#faad14' : '#1890ff'
                          }} />}
                          title={item.title}
                          description={item.desc}
                        />
                        <Tag color={item.level === 'high' ? 'red' : item.level === 'medium' ? 'orange' : 'blue'}>
                          {item.count}条
                        </Tag>
                      </List.Item>
                    )}
                  />
                </Card>
              </Col>
            </Row>
          </div>
        );
      case 'drg-custom-query':
        return <DRGCustomQuery />;
      case 'drg-workbench':
        return <DRGWorkbench />;
      case 'drg-results':
        return <DRGResults />;
      case 'drg-batch':
        return <Card><div style={{ textAlign: 'center', padding: 60 }}><Text>批量分组任务开发中...</Text></div></Card>;
      case 'dip-workbench':
        return <DIPWorkbench />;
      case 'dip-values':
        return <DIPDiseaseQuery />;
      case 'dip-analysis':
        return <DIPVarianceAnalysis />;
      case 'warning-monitor':
        return <WarningCenter />;
      case 'warning-analysis':
        return <WarningAnalysis />;
      case 'warning-rules':
        return <WarningRules />;
      case 'warning-records':
        return <WarningRecords />;
      case 'profit-dept':
        return <ProfitDept />;
      case 'profit-doctor':
        return <ProfitDoctor />;
      case 'profit-disease':
        return <ProfitDisease />;
      case 'profit-structure':
        return <ProfitCostStructure />;
      case 'qc-center':
        return <WarningCenter />;
      case 'qc-issues':
        return <WarningCenter />;
      case 'qc-stats':
        return <WarningCenter />;
      case 'data-records':
        return <HISMedicalRecords />;
      case 'data-settlement':
        return <HISSettlement />;
      case 'data-sync':
        return <HISDataSync />;
      case 'basic-data-icd-mapping':
        return <ICDMapping />;
      case 'basic-data-icd-query':
        return <ICDQuery />;
      case 'basic-data-adrg-rules':
        return <ADRGRuleMaintenance />;
      case 'basic-data-core-algorithm':
        return <CoreAlgorithmConfig />;
      case 'basic-data-dict':
        return <BasicDataMaintenance />;
      case 'basic-data-drg-dict':
        return <DRGDictManagement />;
      case 'basic-data-table':
        return <TableDataMaintenance />;
      case 'basic-data-dip':
        return <DIPDisease />;
      case 'basic-data-drg-catalog':
        return <DRGCataLog />;
      case 'basic-data-segmentation-rules':
        return <DRGSegmentationRules />;
      case 'basic-data-special-grouping':
        return <SpecialDRGGrouping />;
      case 'basic-data-dip-core-algorithm':
      case 'dip-core-algorithm':
        return <DIPCoreAlgorithmConfig />;
      case 'system-user':
        return <SystemUsers />;
      case 'system-role':
      case 'system-role-manage':
        return <SystemRoles />;
      case 'system-menu':
        return <SystemMenus />;
      case 'system-hospital':
        return <SystemHospitals />;
      case 'system-api':
        return <SystemInterfaces />;
      case 'system-logs':
        return <SystemInterfaceLogs />;
      default:
        return (
          <Card>
            <div style={{ textAlign: 'center', padding: 60, color: '#999' }}>
              <MenuOutlined style={{ fontSize: 48, marginBottom: 16 }} />
              <Title level={4}>功能开发中...</Title>
              <Text>当前模块：{key}</Text>
            </div>
          </Card>
        );
    }
  };

    const columns = [
    { title: '排名', dataIndex: 'rank', key: 'rank', width: 60 },
    { title: 'DRG编码', dataIndex: 'drg', key: 'drg', width: 80 },
    { title: 'DRG名称', dataIndex: 'name', key: 'name' },
    { title: '病例数', dataIndex: 'count', key: 'count', width: 80 },
    { 
      title: '占比', 
      dataIndex: 'rate', 
      key: 'rate', 
      width: 120,
      render: (rate: number) => <Progress percent={rate} size="small" /> 
    },
  ];

  // 标签页配置
  const tabItems: TabsProps['items'] = openTabs.map(tab => ({
    key: tab.key,
    label: (
      <span>
        {tab.key === 'dashboard' && <HomeOutlined style={{ marginRight: 6 }} />}
        {tab.label}
        {tab.closable && (
          <CloseOutlined
            style={{ marginLeft: 8, fontSize: 10, verticalAlign: 'middle' }}
            onClick={(e) => {
              e.stopPropagation();
              handleCloseTab(tab.key);
            }}
          />
        )}
      </span>
    ),
    closable: tab.closable,
    children: renderContent(tab.key)
  }));

  // 根据登录状态渲染不同内容
  if (authState === 'login') {
    return (
      <Login onLoginSuccess={() => setAuthState('select')} />
    );
  }

  if (authState === 'select') {
    return (
      <SelectHospRole
        onSelectSuccess={() => {
          // 登录成功后，从 session 中读取用户信息并设置
          const session = getSession();
          if (session) {
            console.log('登录成功，设置用户信息:', {
              userName: session.userName,
              hospName: session.hospDesc,
              roleName: session.groupDesc,
              userID: session.userID
            });
            
            // ★ 切换登录时关闭所有已打开的标签页
            if (isSwitchingLogin.current) {
              console.log('[App] 切换登录完成，关闭所有标签页');
              setOpenTabs([{ key: 'dashboard', label: '监控仪表盘', closable: false }]);
              setCurrentMenu('dashboard');
              isSwitchingLogin.current = false;
            }
            
            setUserInfo({
              userName: session.userName || '管理员',
              hospName: session.hospDesc || session.hospID || '',
              roleName: session.groupDesc || session.groupID || '',
              userID: session.userID || ''
            });
          }
          setAuthState('authenticated');
        }}
        onBack={() => setAuthState('login')}
      />
    );
  }

  return (
    <Layout style={{ minHeight: '100vh', display: 'flex', flexDirection: 'row' }}>
      <Sider
        width={280}
        style={{ display: 'flex', flexDirection: 'column', overflow: 'hidden' }}
        collapsible
        collapsed={collapsed}
        onCollapse={setCollapsed}
        theme="dark"
      >
        <div style={{
          height: 64,
          display: 'flex',
          alignItems: 'center',
          justifyContent: collapsed ? 'center' : 'flex-start',
          borderBottom: '1px solid rgba(255,255,255,0.1)',
          padding: collapsed ? 0 : '0 12px'
        }}>
          <MedicineBoxOutlined style={{ fontSize: 24, color: '#1890ff', marginRight: collapsed ? 0 : 8 }} />
          {!collapsed && (
            <span style={{
              color: '#fff',
              fontSize: 18,
              fontWeight: 700,
              whiteSpace: 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis'
            }}>
              DRG/DIP医保控费预警系统
            </span>
          )}
        </div>
        {/* 菜单搜索框 */}
        {!collapsed && (
          <div style={{ padding: '12px 12px 8px 12px' }}>
            <Dropdown
              open={searchVisible && menuSearch.length > 0}
              onOpenChange={setSearchVisible}
              dropdownRender={() => (
                <div style={{
                  background: '#fff',
                  borderRadius: 6,
                  boxShadow: '0 6px 16px 0 rgba(0, 0, 0, 0.15)',
                  maxHeight: 320,
                  overflow: 'auto'
                }}>
                  {searchResults.length > 0 ? (
                    searchResults.map(item => (
                      <div
                        key={item.key}
                        onClick={() => handleSearchSelect({ key: item.key })}
                        style={{
                          padding: '10px 16px',
                          cursor: 'pointer',
                          color: '#333',
                          display: 'flex',
                          alignItems: 'center',
                          gap: 8
                        }}
                        onMouseEnter={e => (e.currentTarget.style.background = '#f5f5f5')}
                        onMouseLeave={e => (e.currentTarget.style.background = 'transparent')}
                      >
                        {item.icon && <span style={{ color: '#1890ff' }}>{item.icon}</span>}
                        <span>{item.label}</span>
                      </div>
                    ))
                  ) : (
                    <div style={{ padding: '16px', textAlign: 'center', color: '#999' }}>
                      未找到匹配的菜单
                    </div>
                  )}
                </div>
              )}
            >
              <Input
                prefix={<SearchOutlined style={{ color: 'rgba(255,255,255,0.45)' }} />}
                placeholder="搜索菜单..."
                value={menuSearch}
                onChange={e => {
                  setMenuSearch(e.target.value);
                  setSearchVisible(true);
                }}
                onFocus={() => menuSearch && setSearchVisible(true)}
                style={{
                  background: 'rgba(255,255,255,0.1)',
                  border: 'none',
                  borderRadius: 4,
                  color: '#fff'
                }}
                className="menu-search-input"
              />
            </Dropdown>
          </div>
        )}
        <Menu
          theme="dark"
          defaultSelectedKeys={['dashboard']}
          selectedKeys={[currentMenu]}
          mode="inline"
          items={filteredMenuItems}
          onClick={({key}) => handleMenuClick(key)}
          style={{ flex: 1, borderRight: 0 }}
        />
        <div style={{
          padding: '16px',
          borderTop: '1px solid rgba(255,255,255,0.1)',
          textAlign: collapsed ? 'center' : 'left',
          color: 'rgba(255,255,255,0.65)',
          fontSize: 12
        }}>
          {!collapsed ? (
            <>
              <div style={{ marginBottom: 8 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <div style={{ width: 8, height: 8, background: '#52c41a', borderRadius: '50%' }}></div>
                  <span>系统运行正常</span>
                </div>
              </div>
              <div style={{ opacity: 0.7 }}>版本: v1.0.0</div>
            </>
          ) : (
            <div style={{ width: 8, height: 8, background: '#52c41a', borderRadius: '50%', margin: '0 auto' }}></div>
          )}
        </div>
      </Sider>
      <Layout style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
        <Header style={{ 
          background: '#fff', 
          padding: '0 16px', 
          display: 'flex', 
          alignItems: 'center', 
          justifyContent: 'space-between',
          borderBottom: '1px solid #f0f0f0',
          flexShrink: 0,
          width: '100%'
        }}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <Title level={4} style={{ margin: 0 }}>{menuTitleMap[currentMenu] || '监控仪表盘'}</Title>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, flexShrink: 0 }}>
            <div style={{ textAlign: 'right', lineHeight: 1.5 }}>
              <div style={{ fontSize: 14, fontWeight: 500, whiteSpace: 'nowrap' }}>{userInfo?.userName || '管理员'}</div>
              <div style={{ fontSize: 12, color: '#8c8c8c', whiteSpace: 'nowrap' }}>
                {userInfo?.roleName || '未分配角色'} | {userInfo?.hospName || '未选择医院'}
              </div>
            </div>
            <Dropdown
              menu={{
                items: [
                  {
                    key: 'switch-login',
                    icon: <SwapOutlined />,
                    label: '切换登录',
                    onClick: handleSwitchLogin
                  },
                  {
                    type: 'divider'
                  },
                  {
                    key: 'password',
                    icon: <LockOutlined />,
                    label: '修改密码',
                    onClick: handleOpenPwdModal
                  },
                  {
                    type: 'divider'
                  },
                  {
                    key: 'logout',
                    icon: <LogoutOutlined />,
                    label: '退出登录',
                    onClick: handleLogout
                  }
                ]
              }}
              placement="bottomRight"
            >
              <Button type="text" icon={<DownOutlined />} style={{ color: '#8c8c8c' }}>
                操作
              </Button>
            </Dropdown>
          </div>
        </Header>
        <Content style={{ 
          margin: 0, 
          padding: 0, 
          background: '#f5f5f5', 
          flex: 1, 
          display: 'flex', 
          flexDirection: 'column',
          overflow: 'hidden',
          width: '100%',
          boxSizing: 'border-box'
        }}>
          <Tabs
            activeKey={currentMenu}
            onChange={handleTabChange}
            type="card"
            size="small"
            style={{ background: '#fff' }}
            tabBarStyle={{ marginBottom: 0, background: '#fff' }}
            items={tabItems}
            hideAdd
          />
        </Content>
      </Layout>

      {/* 修改密码弹窗 */}
      <Modal
        title="修改密码"
        open={pwdModalVisible}
        onCancel={() => setPwdModalVisible(false)}
        width={400}
        footer={[
          <Button            
            key="init" 
            icon={<SyncOutlined />} 
            onClick={handleInitPassword}
            loading={pwdLoading}
            danger
          >
            初始化登录密码
          </Button>,
          <Button key="submit" type="primary" onClick={handleChangePassword} loading={pwdLoading}>
            确定
          </Button>,
          <Button key="cancel" onClick={() => setPwdModalVisible(false)}>
            取消
          </Button>          
        ]}
      >
        <Form
          form={pwdForm}
          layout="vertical"
          style={{ marginTop: 16 }}
        >
          <Form.Item
            name="oldPassword"
            label="原密码"
            rules={[{ required: true, message: '请输入原密码' }]}
          >
            <Input.Password placeholder="请输入原密码" />
          </Form.Item>
          <Form.Item
            name="newPassword"
            label="新密码"
            rules={[
              { required: true, message: '请输入新密码' },
              { min: 6, message: '密码长度不能少于6位' }
            ]}
          >
            <Input.Password placeholder="请输入新密码" />
          </Form.Item>
          <Form.Item
            name="confirmPassword"
            label="确认新密码"
            rules={[
              { required: true, message: '请确认新密码' },
              ({ getFieldValue }) => ({
                validator(_, value) {
                  if (!value || getFieldValue('newPassword') === value) {
                    return Promise.resolve();
                  }
                  return Promise.reject(new Error('两次输入的密码不一致'));
                },
              }),
            ]}
          >
            <Input.Password placeholder="请再次输入新密码" />
          </Form.Item>
        </Form>
      </Modal>
    </Layout>
  );
}

// 使用 MenuProvider 包裹导出
const AppWithProvider = () => (
  <MenuProvider>
    <App />
  </MenuProvider>
);

export default AppWithProvider;
