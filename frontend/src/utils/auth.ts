/**
 * 登录状态管理工具函数
 * 
 * 提供session的存储、获取、清除和登录状态检查功能
 */

import type { LogonResult } from '../api/logon';

const SESSION_KEY = 'drg_session';
const USER_INFO_KEY = 'drg_user_info';

/**
 * 保存session信息到localStorage
 * @param session 登录返回的session信息
 */
export const setSession = (session: LogonResult): void => {
  try {
    localStorage.setItem(SESSION_KEY, JSON.stringify(session));
  } catch (e) {
    console.error('保存session失败:', e);
  }
};

/**
 * 从localStorage获取session信息
 * @returns session信息或null
 */
export const getSession = (): LogonResult | null => {
  try {
    const sessionStr = localStorage.getItem(SESSION_KEY);
    if (sessionStr) {
      return JSON.parse(sessionStr);
    }
  } catch (e) {
    console.error('读取session失败:', e);
  }
  return null;
};

/**
 * 清除localStorage中的session信息
 */
export const clearSession = (): void => {
  try {
    localStorage.removeItem(SESSION_KEY);
    localStorage.removeItem(USER_INFO_KEY);
  } catch (e) {
    console.error('清除session失败:', e);
  }
};

/**
 * 检查用户是否已登录
 * @returns true表示已登录，false表示未登录
 */
export const isAuthenticated = (): boolean => {
  const session = getSession();
  return !!session && !!session.sessionID;
};

/**
 * 获取当前登录用户的userID
 * @returns userID或空字符串
 */
export const getCurrentUserId = (): string => {
  const session = getSession();
  return session?.userID || '';
};

/**
 * 获取当前登录用户的用户名
 * @returns 用户名或空字符串
 */
export const getCurrentUserName = (): string => {
  const session = getSession();
  return session?.userName || '';
};

/**
 * 获取当前登录医院ID
 * @returns 医院ID或空字符串
 */
export const getCurrentHospId = (): string => {
  const session = getSession();
  return session?.hospID || '';
};

/**
 * 获取当前登录医院名称
 * @returns 医院名称或空字符串
 */
export const getCurrentHospName = (): string => {
  const session = getSession();
  return session?.hospDesc || '';
};

/**
 * 获取当前登录角色ID
 * @returns 角色ID或空字符串
 */
export const getCurrentGroupId = (): string => {
  const session = getSession();
  return session?.groupID || '';
};

/**
 * 获取当前登录角色名称
 * @returns 角色名称或空字符串
 */
export const getCurrentGroupName = (): string => {
  const session = getSession();
  return session?.groupDesc || '';
};

/**
 * 保存验证通过的用户信息（用于登录选择页面传递）
 * @param userInfo 用户基本信息
 */
export const setTempUserInfo = (userInfo: {
  userID: string;
  userCode: string;
  userName: string;
}): void => {
  try {
    localStorage.setItem(USER_INFO_KEY, JSON.stringify(userInfo));
  } catch (e) {
    console.error('保存用户信息失败:', e);
  }
};

/**
 * 获取临时保存的用户信息
 * @returns 用户基本信息或null
 */
export const getTempUserInfo = (): {
  userID: string;
  userCode: string;
  userName: string;
} | null => {
  try {
    const userInfoStr = localStorage.getItem(USER_INFO_KEY);
    if (userInfoStr) {
      return JSON.parse(userInfoStr);
    }
  } catch (e) {
    console.error('读取用户信息失败:', e);
  }
  return null;
};

/**
 * 清除临时保存的用户信息
 */
export const clearTempUserInfo = (): void => {
  try {
    localStorage.removeItem(USER_INFO_KEY);
  } catch (e) {
    console.error('清除用户信息失败:', e);
  }
};
