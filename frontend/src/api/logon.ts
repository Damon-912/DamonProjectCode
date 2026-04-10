/**
 * 登录相关接口
 * 
 * 包含用户验证、登录、获取登录权限列表、登出等功能
 */

import { invoke } from './request';
import type { ApiResponse, Pagination, PageResult } from './basicData';

// ========== 接口类型定义 ==========

/** 用户验证结果 */
export interface ValidUserResult {
  userID: string;
  userCode: string;
  userName: string;
  groupID?: string;
  groupDesc?: string;
  hospID?: string;
  hospDesc?: string;
  langID?: number;
  langDesc?: string;
  othLocFlag?: string;
}

/** 登录参数 */
export interface LogonParams {
  userID: string;
  userName: string;
  passWord: string;
  loginGroupID: string;
  loginHospID: string;
  IP?: string;
  mac?: string;
  deviceID?: string;
  userLogonType?: string;
}

/** 登录结果 */
export interface LogonResult {
  userID: string;
  userCode: string;
  userName: string;
  locID?: string;
  locDesc?: string;
  groupID: string;
  groupDesc: string;
  hospID: string;
  hospCode?: string;
  hospDesc: string;
  langID?: number;
  langDesc?: string;
  changeFlag?: string;
  changeDesc?: string;
  lastLoginDate?: string;
  lastLoginTime?: string;
  directorAuth?: string;
  defaultMenuType?: string;
  titleDesc?: string;
  userYBCode?: string;
  hospYBCode?: string;
  path?: string;
  sessionID: string;
  errorMessageTime?: string;
  language?: string;
  messageTime?: number;
}

/** 用户登录权限项 */
export interface UserLogonLocItem {
  userLogonLocID?: number;
  userID?: number;
  userDesc?: string;
  hospID?: number;
  hospDesc?: string;
  hospCode?: string;
  groupID?: number;
  groupDesc?: string;
  isDefault?: string;
  updateDate?: string;
  updateTime?: string;
  startDate?: string;
  stopDate?: string;
}

/** 验证用户参数 */
export interface IsValidUserParams {
  userName: string;
  passWord: string;
  phoneCheck?: string;
  mobileFlag?: string;
}

/** 获取登录权限列表参数 */
export interface GetLogonGroupParams {
  userID: string;
  userCode?: string;
  currentLocFlag?: string;
  language?: string;
}

/** 登出参数 */
export interface LogoutParams {
  userID?: string;
  sessionID?: string;
}

// ========== API 函数 ==========

/**
 * 验证用户（code: 01010001）
 * 验证用户名密码是否正确，返回用户基本信息
 */
export const isValidUser = (
  params: IsValidUserParams
): Promise<ApiResponse<ValidUserResult[]>> => {
  return invoke('01010001', [params]);
};

/**
 * 用户登录（code: 01010002）
 * 完成登录，建立session
 */
export const logon = (
  params: LogonParams
): Promise<ApiResponse<LogonResult[]>> => {
  return invoke('01010002', [params]);
};

/**
 * 获取用户登录权限列表（code: 01010004）
 * 根据用户ID查询该用户可选的登录权限列表（医院+角色组合）
 */
export const getLogonGroupByUserId = (
  params: GetLogonGroupParams
): Promise<ApiResponse<{ rows: UserLogonLocItem[] }>> => {
  return invoke('01010004', [params]);
};

/**
 * 用户登出（code: 01010003）
 */
export const logout = (
  params?: LogoutParams
): Promise<ApiResponse> => {
  return invoke('01010003', [params || {}]);
};

/**
 * 修改默认登录角色（code: 01010041）
 */
export const updateLogonGroupById = (
  params: {
    userLogonLocID: number;
    isDefault: string;
  }
): Promise<ApiResponse> => {
  return invoke('01010041', [params]);
};
