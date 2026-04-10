import { useState, useEffect } from 'react';
import { Layout, Menu, Card, Row, Col, Statistic, Table, Tag, Progress, List, Avatar, Typography, Tabs, Input, Dropdown, Badge } from 'antd';
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
  HomeOutlined
} from '@ant-design/icons';
import type { MenuProps, TabsProps } from 'antd';
import './App.css';
import DRGCustomQuery from './pages/DRG/CustomQuery';
import ICDMapping from './pages/BasicData/ICDMapping';
import ICDQuery from './pages/BasicData/ICDQuery';
import ADRGRuleMaintenance from './pages/BasicData/ADRGRuleMaintenance';
import CoreAlgorithmConfig from './pages/BasicData/CoreAlgorithmConfig';
import BasicDataMaintenance from './pages/BasicData/BasicDataMaintenance';
import DIPDisease from './pages/BasicData/DIPDisease';
import TableDataMaintenance from './pages/BasicData/TableDataMaintenance';
import DRGCataLog from './pages/BasicData/DRGCataLog';
import DRGSegmentationRules from './pages/BasicData/DRGSegmentationRules';

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

// Profit pages
import ProfitDept from './pages/Profit/Dept';
import ProfitDoctor from './pages/Profit/Doctor';
import ProfitDisease from './pages/Profit/Disease';
import ProfitCostStructure from './pages/Profit/CostStructure';

// System pages
import SystemUsers from './pages/System/Users';
import SystemRoles from './pages/System/Roles';
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
  'basic-data-table': '基础表数据维护',
  'basic-data-icd-mapping': 'ICD编码映射',
  'basic-data-icd-query': 'ICD编码查询',
  'basic-data-adrg-rules': 'ADRG分组规则维护',
  'basic-data-core-algorithm': 'DRG算法配置维护',
  'basic-data-dip': 'DIP付费病种库',
  'basic-data-drg-catalog': 'DRGs目录信息表',
  'basic-data-segmentation-rules': 'ADRG细分规则表',
  'system-user': '用户管理',
  'system-role': '角色权限',
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
      { key: 'basic-data-icd-mapping', label: 'ICD编码映射' },
      { key: 'basic-data-icd-query', label: 'ICD编码查询' },
      { key: 'basic-data-adrg-rules', label: 'ADRG分组规则' },
      { key: 'basic-data-core-algorithm', label: 'DRG算法配置' },
      { key: 'basic-data-dip', label: 'DIP付费病种库' },
      { key: 'basic-data-drg-catalog', label: 'DRGs目录信息表' },
      { key: 'basic-data-segmentation-rules', label: 'ADRG细分规则表' },
    ],
  },
  {
    key: 'system',
    icon: <SafetyOutlined />,
    label: '系统管理',
    children: [
      { key: 'system-user', label: '用户管理' },
      { key: 'system-role', label: '角色权限' },
      { key: 'system-menu', label: '菜单配置' },
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

  const [collapsed, setCollapsed] = useState(false);
  const [currentMenu, setCurrentMenu] = useState('dashboard');
  const [menuSearch, setMenuSearch] = useState('');
  const [searchVisible, setSearchVisible] = useState(false);

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
      case 'basic-data-table':
        return <TableDataMaintenance />;
      case 'basic-data-dip':
        return <DIPDisease />;
      case 'basic-data-drg-catalog':
        return <DRGCataLog />;
      case 'basic-data-segmentation-rules':
        return <DRGSegmentationRules />;
      case 'system-user':
        return <SystemUsers />;
      case 'system-role':
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
          flexShrink: 0
        }}>
          <Title level={4} style={{ margin: 0 }}>{menuTitleMap[currentMenu] || '监控仪表盘'}</Title>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
            <Avatar icon={<UserOutlined />} style={{ backgroundColor: '#1890ff' }} />
            <Text>管理员</Text>
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
    </Layout>
  );
}

export default App;
