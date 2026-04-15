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
   * 1. 嵌套结构（有 children 数组）
   * 2. 平铺结构（使用 mainMenuDr 表示父子关系）
   */
  const convertToMenuItems = useCallback((menuList: MenuItem[]): MenuProps['items'] => {
    if (!menuList || menuList.length === 0) {
      console.log('[MenuContext] 菜单列表为空');
      return [];
    }

    // 调试日志：输出原始菜单数据
    console.log('[MenuContext] 原始菜单数据:', menuList);
    console.log('[MenuContext] 检查 parentCode 字段:', menuList.map(m => ({
      code: m.code,
      label: m.label,
      mainMenuDr: m.mainMenuDr,
      menuLevel: m.menuLevel,
      parentCode: m.parentCode
    })));

    // 用于判断是否为菜单组的辅助函数
    const isMenuGroup = (menuGroup: any): boolean => {
      return menuGroup === 'Y' || menuGroup === 1 || menuGroup === '1';
    };

    // 检查是否为嵌套结构（有 children 数组）
    const hasNestedStructure = menuList.some(m => m.children && m.children.length > 0);

    if (hasNestedStructure) {
      // 处理嵌套结构
      const result: MenuProps['items'] = [];
      menuList.forEach(menu => {
        if (isMenuGroup(menu.menuGroup) && menu.children && menu.children.length > 0) {
          const childrenItems: MenuProps['items'] = [];
          menu.children.forEach(child => {
            if (isMenuGroup(child.menuGroup)) {
              child.children?.forEach(subChild => {
                childrenItems.push({
                  key: subChild.code || subChild.key,
                  label: subChild.label,
                });
              });
            } else {
              childrenItems.push({
                key: child.code || child.key,
                label: child.label,
              });
            }
          });
          result.push({
            key: menu.code || menu.key,
            label: menu.label,
            icon: iconMap[menu.icon || ''] || undefined,
            children: childrenItems.length > 0 ? childrenItems : undefined,
          });
        } else if (!isMenuGroup(menu.menuGroup)) {
          result.push({
            key: menu.code || menu.key,
            label: menu.label,
            icon: iconMap[menu.icon || ''] || undefined,
          });
        }
      });
      return result;
    } else {
      // 处理平铺结构（使用 mainMenuDr 表示层级关系）
      // mainMenuDr = 1 表示一级菜单（父菜单），mainMenuDr = 2 表示二级菜单（子菜单）
      const parentMenus: MenuProps['items'] = [];
      const childrenMap: Record<string, MenuProps['items']> = {};

      // 第一步：找出所有父菜单（mainMenuDr = 1）
      menuList.forEach(menu => {
        const key = menu.code || menu.key;
        if (!key) return;
        
        // mainMenuDr = 1 或 menuLevel = 1 表示父菜单
        if (menu.mainMenuDr === 1 || menu.menuLevel === 1) {
          const menuItem = {
            key: key,
            label: menu.label,
            icon: iconMap[menu.icon || ''] || undefined,
          };
          parentMenus.push(menuItem);
          if (!childrenMap[key]) {
            childrenMap[key] = [];
          }
        }
      });

      console.log('[MenuContext] 识别到的父菜单:', parentMenus);

      // 第二步：处理子菜单（mainMenuDr = 2），根据 parentCode 关联到父菜单
      menuList.forEach(menu => {
        const key = menu.code || menu.key;
        if (!key) return;
        
        // mainMenuDr = 2 或 menuLevel = 2 表示子菜单
        if ((menu.mainMenuDr === 2 || menu.menuLevel === 2) && menu.parentCode) {
          const parentKey = menu.parentCode;
          const menuItem = {
            key: key,
            label: menu.label,
          };
          
          console.log(`[MenuContext] 处理子菜单: ${menu.label}, parentCode=${menu.parentCode}, 父菜单key=${parentKey}`);
          
          if (!childrenMap[parentKey]) {
            childrenMap[parentKey] = [];
          }
          childrenMap[parentKey]!.push(menuItem);
        }
      });

      console.log('[MenuContext] childrenMap:', childrenMap);

      // 组装父子关系
      const result = parentMenus.map(parent => ({
        ...parent,
        children: childrenMap[parent!.key as string] && childrenMap[parent!.key as string]!.length > 0
          ? childrenMap[parent!.key as string]
          : undefined,
      }));

      console.log('[MenuContext] 最终菜单结果:', result);
      return result;
    }
  }, []);

  /** 从登录结果加载菜单 */
  const loadMenusFromLogin = useCallback((loginMenus: MenuItem[]) => {
    if (loginMenus && loginMenus.length > 0) {
      setMenus(loginMenus);
      setIsLoaded(true);
    }
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
    ],
  },
  {
    key: 'user',
    icon: iconMap['UserOutlined'],
    label: '用户管理',
    children: [
      { key: 'system-user', label: '用户管理' },
      { key: 'system-role-manage', label: '角色管理' },
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
