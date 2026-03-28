/**
 * 系统管理接口
 * 
 * 包含用户管理、角色管理、菜单管理、接口配置等功能
 */

import { invoke } from './request';
import type { ApiResponse, Pagination, PageResult } from './basicData';

// ========== 接口服务配置 (02010404, 02010405, 02010412) ==========

/** 接口服务记录 */
export interface InterfaceServiceItem {
  key: string;
  id: string;
  code: string;
  descripts: string;
  className: string;
  methodName: string;
  serviceType: string;
  startDate: string;
  stopDate: string;
  productCatID: number;
  productCatDesc: string;
  productModuleID: number;
  productModuleDesc: string;
  seqNo: string;
  sessionFlag: string;
  tokenFlag: string;
  tokenOverTime: string;
  rwServiceTypeID: string;
  rwServiceTypeDesc: string;
  isActive?: string;
}

/** 保存接口服务参数 */
export interface SaveInterfaceServiceParams {
  interfaceId?: string;
  code: string;
  descriptions: string;
  className: string;
  methodName: string;
  serviceType: string;
  seqNo?: string;
  startDate?: string;
  stopDate?: string;
  sessionFlag?: string;
  tokenFlag?: string;
}

/** 查询接口服务列表 (01010017) */
export const queryInterfaceServices = (
  params: {
    code?: string;
  },
  pagination: Pagination
): Promise<ApiResponse<PageResult<InterfaceServiceItem>>> => {
  return invoke('01010017', [params], undefined, pagination);
};

/** 保存接口服务 (02010405) */
export const saveInterfaceService = (
  params: SaveInterfaceServiceParams
): Promise<ApiResponse> => {
  return invoke('02010405', [params]);
};

/** 删除接口服务 (02010412) */
export const deleteInterfaceService = (
  interfaceId: string
): Promise<ApiResponse> => {
  return invoke('02010412', [{ interfaceId }]);
};
