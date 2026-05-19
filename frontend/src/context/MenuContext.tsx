/**
 * 菜单上下文
 * 
 * 提供全局菜单状态管理，支持动态加载用户菜单
 */

import React, { createContext, useContext, useState, useCallback, ReactNode } from 'react';
import type { MenuProps } from 'antd';
import type { MenuItem } from '../api/menu';

// Ant Design 图标映射
const iconMap: Record<string, React.ReactNode> = {
  DashboardOutlined: <span>📊</span>,
  PartitionOutlined: <span>📂</span>,
  MedicineBoxOutlined: <span>💊</span>,
  AlertOutlined: <span>⚠️</span>,
  DollarOutlined: <span>💰</span>,
  FileTextOutlined: <span>📄</span>,
  DatabaseOutlined: <span>🗄️</span>,
  TableOutlined: <span>📋</span>,
  UserOutlined: <span>👤</span>,
  SafetyOutlined: <span>🔒</span>,
};

/** 菜单上下文类型 */
interface MenuContextType {
  /** 菜单数据 */
  menus: MenuItem[];
  /** Ant Design 格式的菜单项 */
  menuItems: MenuProps['items'];
  /** 设置菜单数据 */
  setMenus: (menus: MenuItem[]) => void;
  /** 从登录结果加载菜单 */
  loadMenusFromLogin: (menus: MenuItem[]) => void;
  /** 清空菜单 */
  clearMenus: () => void;
  /** 菜单是否已加载 */
  isLoaded: boolean;
  /** 转换为 Ant Design 菜单格式 */
  convertToMenuItems: (menus: MenuItem[]) => MenuProps['items'];
}

/** 创建上下文 */
const MenuContext = createContext<MenuContextType | undefined>(undefined);

/** 菜单提供组件 */
export const MenuProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [menus, setMenus] = useState<MenuItem[]>([]);
  const [isLoaded, setIsLoaded] = useState(false);

  /** 转换为 Ant Design 菜单格式
   * 支持两种数据结构：
   * 1. 嵌套结构（有 children 数组且包含有效子菜单）
   * 2. 平铺结构（使用 mainMenuDr 表示父子关系）
   * 
   * 注意：后端可能返回字符串类型的 mainMenuDr/menuLevel（如 "1"/"2"），
   * 需要做类型兼容处理。
   */
  const convertToMenuItems = useCallback((menuList: MenuItem[]): MenuProps['items'] => {
    if (!menuList || menuList.length === 0) {
      console.log('[MenuContext] 菜单列表为空');
      return [];
    }

    // 调试日志：输出原始菜单数据及其类型
    console.log('[MenuContext] ====== 原始菜单数据 ======');
    console.log('[MenuContext] 菜单总数:', menuList.length);
    console.log('[MenuContext] 各菜单字段详情:', menuList.map(m => ({
      code: m.code,
      label: m.label,
      mainMenuDr: m.mainMenuDr,
      'mainMenuDr_type': typeof m.mainMenuDr,
      menuLevel: m.menuLevel,
      'menuLevel_type': typeof m.menuLevel,
      parentCode: m.parentCode,
      hasChildren: !!(m.children && m.children.length > 0),
      menuGroup: m.menuGroup,
      'menuGroup_type': typeof m.menuGroup,
    })));

    // ★ 辅助函数：兼容数字和字符串类型的层级判断
    const toNum = (val: any): number => {
      if (val === null || val === undefined) return 0;
      return Number(val);
    };

    // 用于判断是否为菜单组的辅助函数
    const isMenuGroup = (menuGroup: any): boolean => {
      const str = String(menuGroup || '').toUpperCase();
      return str === 'Y' || str === '1';
    };

    // ★ 检查是否为有效嵌套结构（有 children 数组且非空）
    const hasNestedStructure = menuList.some(m => {
      const children = m.children;
      return Array.isArray(children) && children.length > 0;
    });

    console.log('[MenuContext] 数据结构判断: hasNestedStructure=', hasNestedStructure);

    if (hasNestedStructure) {
      console.log('[MenuContext] → 使用嵌套结构模式处理');
      // 处理嵌套结构
      const result: MenuProps['items'] = [];
      menuList.forEach(menu => {
        if (isMenuGroup(menu.menuGroup) && menu.children && menu.children.length > 0) {
          const childrenItems: MenuProps['items'] = [];
          menu.children.forEach(child => {
            if (isMenuGroup(child.menuGroup)) {
              child.children?.forEach(subChild => {
                childrenItems.push({
                  key: subChild.code || subChild.key || '',
                  label: subChild.label || '',
                });
              });
            } else {
              childrenItems.push({
                key: child.code || child.key || '',
                label: child.label || '',
              });
            }
          });
          result.push({
            key: menu.code || menu.key || '',
            label: menu.label || '',
            icon: iconMap[menu.icon || ''] || undefined,
            children: childrenItems.length > 0 ? childrenItems : undefined,
          });
        } else if (!isMenuGroup(menu.menuGroup)) {
          result.push({
            key: menu.code || menu.key || '',
            label: menu.label || '',
            icon: iconMap[menu.icon || ''] || undefined,
          });
        }
      });
      console.log('[MenuContext] 嵌套结构转换结果:', result.length, '项');
      return result;
    } else {
      console.log('[MenuContext] → 使用平铺结构模式处理（mainMenuDr/parentCode）');
      // 处理平铺结构（使用 mainMenuDr 表示层级关系）
      // ★ 兼容数字和字符串：mainMenuDr === 1 或 "1" 表示一级菜单（父菜单）
      const parentMenus: MenuProps['items'] = [];
      const childrenMap: Record<string, MenuProps['items']> = {};

      // 第一步：找出所有父菜单（mainMenuDr = 1 或 menuLevel = 1）
      menuList.forEach(menu => {
        const key = (menu.code || menu.key || '') as string;
        if (!key) return;
        
        const md = toNum(menu.mainMenuDr);
        const ml = toNum(menu.menuLevel);
        
        // mainMenuDr = 1 或 menuLevel = 1 表示父菜单
        if (md === 1 || ml === 1) {
          console.log(`[MenuContext] 识别到父菜单: key=${key}, label=${menu.label}, mainMenuDr=${menu.mainMenuDr}(${typeof menu.mainMenuDr}), menuLevel=${menu.menuLevel}(${typeof menu.menuLevel})`);
          const menuItem = {
            key: key,
            label: menu.label || '',
            icon: iconMap[menu.icon || ''] || undefined,
          };
          parentMenus.push(menuItem);
          if (!childrenMap[key]) {
            childrenMap[key] = [];
          }
        }
      });

      console.log('[MenuContext] 识别到的父菜单数量:', parentMenus.length);

      // ★ 如果通过 mainMenuDr/menuLevel 没有找到父菜单，尝试另一种策略：
      // 将所有菜单作为顶级菜单（没有层级信息时兜底显示）
      if (parentMenus.length === 0) {
        console.warn('[MenuContext] ⚠️ 未识别到任何父菜单(mainMenuDr/menuLevel均不匹配)!');
        console.log('[MenuContext] 尝试兜底策略: 将所有菜单作为顶级菜单展示');
        
        // 兜底：区分有 parentCode 和无 parentCode 的菜单
        const topMenus: MenuProps['items'] = [];
        const childMenus: { key: string; label: string; parentKey: string }[] = [];
        
        menuList.forEach(menu => {
          const key = (menu.code || menu.key || '') as string;
          if (!key) return;
          
          if (menu.parentCode) {
            childMenus.push({ key, label: menu.label || '', parentKey: menu.parentCode });
          } else {
            topMenus.push({
              key,
              label: menu.label || '',
              icon: iconMap[menu.icon || ''] || undefined,
            });
          }
        });
        
        // 尝试将 childMenus 关联到正确的父菜单
        childMenus.forEach(child => {
          const parent = topMenus.find(p => p!.key === child.parentKey);
          if (parent) {
            if (!childrenMap[child.parentKey]) {
              childrenMap[child.parentKey] = [];
            }
            childrenMap[child.parentKey]!.push({ key: child.key, label: child.label });
          } else {
            // 父菜单不存在，作为顶级菜单添加
            topMenus.push({ key: child.key, label: child.label });
          }
        });
        
        const result = topMenus.map(parent => ({
          ...parent,
          children: childrenMap[parent!.key as string] && childrenMap[parent!.key as string]!.length > 0
            ? childrenMap[parent!.key as string]
            : undefined,
        }));
        
        console.log('[MenuContext] 兜底转换结果:', result.length, '项');
        return result;
      }

      // 第二步：处理子菜单（mainMenuDr = 2 或 menuLevel = 2），根据 parentCode 关联到父菜单
      menuList.forEach(menu => {
        const key = (menu.code || menu.key || '') as string;
        if (!key) return;
        
        const md = toNum(menu.mainMenuDr);
        const ml = toNum(menu.menuLevel);
        
        // mainMenuDr = 2 或 menuLevel = 2 表示子菜单
        if ((md === 2 || ml === 2) && menu.parentCode) {
          const parentKey = menu.parentCode;
          const menuItem = {
            key: key,
            label: menu.label || '',
          };
          
          console.log(`[MenuContext] 处理子菜单: key=${key}, label=${menu.label}, parentCode=${parentKey}, mainMenuDr=${menu.mainMenuDr}(${typeof menu.mainMenuDr})`);
          
          if (!childrenMap[parentKey]) {
            childrenMap[parentKey] = [];
          }
          childrenMap[parentKey]!.push(menuItem);
        }
      });

      // ★ 处理孤儿子菜单：如果 childrenMap 中有 key 对应的子菜单，但 parentMenus 中没有该父菜单
      // 则自动创建父菜单组（后端可能只分配了叶子菜单，但没有分配父级菜单组）
      const orphanParentKeys = Object.keys(childrenMap).filter(
        pk => !parentMenus.some(p => (p as any)?.key === pk)
      );
      
      if (orphanParentKeys.length > 0) {
        // 已知父菜单的友好标签映射
        const parentLabelMap: Record<string, string> = {
          'user': '用户管理',
          'basic-data': '数据管理',
          'system': '系统管理',
          'drg': 'DRG业务',
          'dip': 'DIP业务',
          'warning': '费用预警',
          'profit': '盈亏分析',
          'qc': '病案质控',
          'data': 'HIS数据',
        };
        // 父菜单图标映射
        const parentIconKeyMap: Record<string, string> = {
          'user': 'UserOutlined',
          'basic-data': 'TableOutlined',
          'system': 'SafetyOutlined',
          'data': 'DatabaseOutlined',
        };
        
        console.warn('[MenuContext] ⚠️ 发现孤儿子菜单，自动创建父菜单:', orphanParentKeys);
        orphanParentKeys.forEach(pk => {
          parentMenus.push({
            key: pk,
            label: parentLabelMap[pk] || pk,
            icon: iconMap[parentIconKeyMap[pk] || ''] || undefined,
          });
        });
      }

      console.log('[MenuContext] childrenMap keys:', Object.keys(childrenMap));

      // 组装父子关系
      const result = parentMenus.map(parent => ({
        ...parent,
        children: childrenMap[parent!.key as string] && childrenMap[parent!.key as string]!.length > 0
          ? childrenMap[parent!.key as string]
          : undefined,
      }));

      console.log('[MenuContext] 平铺结构最终菜单结果:', result.length, '项:', JSON.stringify(result));
      return result;
    }
  }, []);

  /** 从登录结果加载菜单（支持空菜单，表示角色无任何菜单权限） */
  const loadMenusFromLogin = useCallback((loginMenus: MenuItem[]) => {
    console.log('[MenuContext] loadMenusFromLogin 被调用, 菜单数量:', loginMenus?.length || 0);
    // ★ 即使菜单为空也要标记已加载，避免回退到默认全量菜单
    setMenus(loginMenus || []);
    setIsLoaded(true);
  }, []);

  /** 清空菜单 */
  const clearMenus = useCallback(() => {
    setMenus([]);
    setIsLoaded(false);
  }, []);

  /** 转换为 Ant Design 菜单格式 */
  const menuItems = convertToMenuItems(menus);

  const value: MenuContextType = {
    menus,
    menuItems,
    setMenus,
    loadMenusFromLogin,
    clearMenus,
    isLoaded,
    convertToMenuItems,
  };

  return (
    <MenuContext.Provider value={value}>
      {children}
    </MenuContext.Provider>
  );
};

/** 使用菜单上下文 */
export const useMenu = (): MenuContextType => {
  const context = useContext(MenuContext);
  if (!context) {
    throw new Error('useMenu must be used within a MenuProvider');
  }
  return context;
};

/** 导出默认菜单配置(备用) */
export const defaultMenuItems: MenuProps['items'] = [
  {
    key: 'dashboard',
    icon: iconMap['DashboardOutlined'],
    label: '监控仪表盘',
  },
  {
    key: 'drg',
    icon: iconMap['PartitionOutlined'],
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
    icon: iconMap['MedicineBoxOutlined'],
    label: 'DIP业务',
    children: [
      { key: 'dip-workbench', label: 'DIP分组工作台' },
      { key: 'dip-values', label: '病种分值查询' },
      { key: 'dip-analysis', label: '分值偏差分析' },
    ],
  },
  {
    key: 'warning',
    icon: iconMap['AlertOutlined'],
    label: '费用预警',
    children: [
      { key: 'warning-monitor', label: '预警监控中心' },
      { key: 'warning-rules', label: '预警规则配置' },
      { key: 'warning-records', label: '预警处理记录' },
    ],
  },
  {
    key: 'profit',
    icon: iconMap['DollarOutlined'],
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
    icon: iconMap['FileTextOutlined'],
    label: '病案质控',
    children: [
      { key: 'qc-center', label: '质控检查中心' },
      { key: 'qc-issues', label: '质控问题列表' },
      { key: 'qc-stats', label: '质控统计报表' },
    ],
  },
  {
    key: 'data',
    icon: iconMap['DatabaseOutlined'],
    label: 'HIS数据',
    children: [
      { key: 'data-records', label: '病案数据查询' },
      { key: 'data-settlement', label: '结算清单管理' },
      { key: 'data-sync', label: '数据同步监控' },
    ],
  },
  {
    key: 'basic-data',
    icon: iconMap['TableOutlined'],
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
      { key: 'basic-data-dip-core-algorithm', label: 'DIP算法配置' },
    ],
  },
  {
    key: 'user',
    icon: iconMap['UserOutlined'],
    label: '用户管理',
    children: [
      { key: 'system-user', label: '用户管理' },
      { key: 'system-role', label: '角色管理' },
      { key: 'system-menu', label: '菜单配置' },
    ],
  },
  {
    key: 'system',
    icon: iconMap['SafetyOutlined'],
    label: '系统管理',
    children: [
      { key: 'system-hospital', label: '医疗机构管理' },
      { key: 'system-api', label: '接口服务配置' },
      { key: 'system-logs', label: '接口日志' },
    ],
  },
];

export default MenuContext;
