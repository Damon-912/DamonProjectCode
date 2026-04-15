/**
 * 菜单相关接口
 * 
 * 提供菜单管理、角色菜单权限配置等功能
 * 后端接口已重构为使用src.util.operatetable模式
 */

import { invoke, getDefaultSession } from './request';
import type { ApiResponse } from './basicData';

// ========== 类型定义 ==========

/** 菜单项 */
export interface MenuItem {
  id?: string;                 // 菜单ID（CB_Menu.RowID）
  key?: string;                // 树形组件key
  code: string;                // 菜单编码
  label: string;               // 菜单名称
  icon?: string;
  seqNo?: number;
  linkAddress?: string;
  linkPath?: string;
  menuGroup?: string | number; // 菜单组标志（'Y'/1 或 'N'/0）
  preMenuDr?: number;          // 上级菜单ID
  mainMenuDr?: number;         // 主菜单ID（1=父菜单，2=子菜单）
  menuLevel?: number;          // 菜单层级（1=一级，2=二级）
  parentCode?: string;         // 父菜单编码
  children?: MenuItem[];
}

/** 获取用户菜单参数 */
export interface GetUserMenusParams {
  userCode: string;
  groupID?: string;
}

/** 获取角色菜单参数 */
export interface GetRoleMenusParams {
  roleCode: string;
}

/** 保存角色菜单参数 */
export interface SaveRoleMenusParams {
  roleCode: string;
  menuCodes: string[];
}

/** 保存角色菜单参数(使用MenuDetailId) */
export interface SaveRoleMenusByGroupParams {
  groupID: string;
  menuDetailIds: number[];
}

// ========== API 函数 ==========

/**
 * 获取用户菜单(根据角色获取)
 * code: 10010007
 */
export const getUserMenus = (
  params: GetUserMenusParams
): Promise<ApiResponse<MenuItem[]>> => {
  return invoke('10010007', [params]);
};

/**
 * 获取角色菜单权限
 * code: 10010005
 */
export const getRoleMenus = (
  params: GetRoleMenusParams
): Promise<ApiResponse<string[]>> => {
  return invoke('10010005', [params]);
};

/**
 * 保存角色菜单权限
 * code: 10010006
 */
export const saveRoleMenus = (
  params: SaveRoleMenusParams
): Promise<ApiResponse> => {
  return invoke('10010006', [params]);
};

/**
 * 获取菜单树形结构
 * code: 10010001
 */
export const getMenuTree = (
  params?: {}
): Promise<ApiResponse<MenuItem[]>> => {
  return invoke('10010001', [params || {}]);
};

/**
 * 初始化默认菜单
 * code: 10010004
 * 后端已重构为使用operatetable模式
 */
export const initDefaultMenus = (
  params?: {}
): Promise<ApiResponse> => {
  const session = getDefaultSession();
  return invoke('10010004', [params || {}], session);
};

/**
 * 保存菜单(新增/修改)
 * code: 10010002
 * 后端已重构为使用operatetable模式，入参格式：{ params: [...], session: [...] }
 */
export const saveMenu = (
  params: {
    menuID?: string;       // 菜单ID，为空则新增
    code: string;          // 菜单编码
    label: string;         // 菜单名称
    parentCode?: string;   // 上级菜单编码
    menuLevel?: number;    // 菜单层级
    sortNo?: number;       // 排序号
    icon?: string;         // 菜单图标
    routePath?: string;    // 路由路径
    isVisible?: string;    // 是否可见 Y/N
    isActive?: string;     // 是否启用 Y/N
  }
): Promise<ApiResponse> => {
  const session = getDefaultSession();
  return invoke('10010002', [{ code: params.code, label: params.label, parentCode: params.parentCode || '', menuLevel: params.menuLevel || 1, sortNo: params.sortNo || 1, icon: params.icon || '', routePath: params.routePath || '', isVisible: params.isVisible || 'Y', isActive: params.isActive || 'Y', menuID: params.menuID || '' }], session);
};

/**
 * 删除菜单
 * code: 10010003
 * 后端已重构为使用operatetable模式，入参格式：{ params: [...], session: [...] }
 */
export const deleteMenu = (
  params: { code: string }
): Promise<ApiResponse> => {
  const session = getDefaultSession();
  return invoke('10010003', [params], session);
};

/**
 * 获取菜单树(从CBMenuDetail)
 * 后端新增方法: 10010008
 */
export const getMenuTreeFromDetail = (
  params?: {}
): Promise<ApiResponse<MenuItem[]>> => {
  return invoke('10010008', [params || {}]);
};

/**
 * 保存角色菜单权限(使用GroupID)
 * 后端新增方法: 10010009
 */
export const saveRoleMenusByGroup = (
  params: SaveRoleMenusByGroupParams
): Promise<ApiResponse> => {
  return invoke('10010009', [params]);
};
