/**
 * 系统管理接口
 * 
 * 包含用户管理、角色管理、菜单管理、接口配置等功能
 */

import { invoke } from './request';
import type { ApiResponse, Pagination, PageResult } from './basicData';

// ========== 接口服务配置 (01010017, 01010016, 01010018) ==========

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
  id?: string;           // 接口ID，为空则新增
  key?: string;          // 接口key（从查询接口返回）
  code: string;          // 接口代码
  descripts: string;     // 接口描述（注意：后端字段名是descripts）
  className: string;     // 类名
  methodName: string;    // 方法名
  serviceType: string;   // 服务类型 S/A/U/D
  seqNo?: string;        // 序号
  startDate?: string;    // 启用日期
  stopDate?: string;     // 停用日期
  sessionFlag?: string;  // 是否验证session Y/N
  tokenFlag?: string;    // 是否验证token Y/N
  tokenOverTime?: string;// token超时时间(分钟)
  productCatID?: string; // 产品分类ID
  productModuleID?: string; // 产品模块ID
  rwServiceTypeID?: string; // 读写服务类型ID
}

/** 下拉数据 */
export interface InterfaceDropdownData {
  productCats: { id: string; name: string }[];
  productModules: { id: string; name: string }[];
  serviceTypes: { code: string; name: string }[];
}

/** 查询接口服务列表 (01010017) - 服务端分页 */
export const queryInterfaceServices = (
  params: {
    code?: string;
    descripts?: string;  // 接口描述
    className?: string;
    methodName?: string;
    serviceType?: string;
    status?: string;  // Y:有效 N:无效
  },
  pagination: Pagination
): Promise<ApiResponse<PageResult<InterfaceServiceItem>>> => {
  return invoke('01010017', [params], undefined, pagination);
};

/** 保存接口服务 (01010016) */
export const saveInterfaceService = (
  params: SaveInterfaceServiceParams
): Promise<ApiResponse> => {
  return invoke('01010016', [params]);
};

/** 查询接口服务配置下拉数据 (01010018) 
 * 产品分类列表传空，产品模块列表传空
 * 服务类型列表：查询(S)、新增(A)、修改(U)、删除(D)
 */
export const queryInterfaceDropdownData = (
): Promise<ApiResponse<InterfaceDropdownData>> => {
  return invoke('01010018', [{}]);
};
