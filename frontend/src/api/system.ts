/**
 * 系统管理接口
 * 
 * 包含用户管理、角色管理、菜单管理、接口配置等功能
 */

import { invoke } from './request';
import type { ApiResponse, Pagination, PageResult } from './basicData';

// ========== 用户管理 (01030101-01030111) ==========

/** 用户列表项 - 01030101接口返回，只包含用户基本信息 */
export interface UserItem {
  userDr: number;           // 用户ID
  userCode: string;         // 用户编码
  userName: string;         // 用户姓名
  sexID?: number;           // 性别ID
  sexDesc?: string;         // 性别描述
  mobile?: string;          // 手机号
  credTypeID?: number;      // 证件类型ID
  credTypeDesc?: string;    // 证件类型描述
  credNo?: string;          // 证件号
  image?: string;           // 头像
  introduce?: string;       // 简介
  createdByDr?: number;     // 创建人ID
  creatUserDesc?: string;   // 创建人姓名
  createdDate?: string;     // 创建日期
  createdTime?: string;     // 创建时间
  startDate?: string;       // 启用日期
  stopDate?: string;        // 停用日期
  statusFlag?: string;      // 状态 Y/N
  nickname?: string;        // 昵称
  mail?: string;            // 邮箱
  workMobile?: string;      // 工作手机
  birthDate?: string;       // 出生日期
}

/** 用户详情 */
export interface UserDetailItem extends UserItem {
  password?: string;        // 密码
  userLogonLoc?: UserLogonLocItem[];  // 权限角色列表
}

/** 用户申请记录项 */
export interface UserAuditLogItem {
  id: number;               // 申请记录ID
  code?: string;            // 编码
  descripts?: string;       // 姓名
  sexDr?: number;           // 性别ID
  sexDesc?: string;         // 性别描述
  hospitalDr?: number;      // 医院ID
  hospDesc?: string;        // 医院名称
  mobile?: string;          // 手机号
  credTypeID?: number;      // 证件类型ID (后端返回)
  credTypeDesc?: string;    // 证件类型描述
  credNo?: string;          // 证件号
  image?: string;           // 头像
  introduce?: string;       // 简介
  auditUserDr?: number;     // 审核人ID
  auditUserDesc?: string;   // 审核人姓名
  auditGroupDr?: number;    // 审核组ID
  auditGroupDesc?: string;  // 审核组名称
  auditStatus?: string;     // 审核状态 R=待审核 Y=已通过 N=已驳回
  auditRemarks?: string;    // 审核备注
  applyDate?: string;       // 申请日期
  applyTime?: string;       // 申请时间
  applyDateTime?: string;   // 申请日期时间
  createdByDr?: number;     // 创建人ID
  createDateTime?: string;  // 创建日期时间
}

/** 用户权限角色项 */
export interface UserLogonLocItem {
  userLogonLocID?: number;  // 权限角色记录ID
  userID?: number;          // 用户ID
  userDesc?: string;        // 用户姓名
  hospID?: number;          // 医院ID
  hospDesc?: string;        // 医院名称
  hospCode?: string;        // 医院编码
  groupID?: number;         // 角色组ID
  groupDesc?: string;       // 角色组名称
  isDefault?: string;       // 是否默认 Y/N
  updateDate?: string;      // 更新日期
  updateTime?: string;      // 更新时间
  startDate?: string;       // 开始日期
  stopDate?: string;        // 结束日期
}

/** 新增/编辑用户参数 */
export interface SaveUserParams {
  userDr?: number;          // 用户ID（为空则新增）
  userID?: string;          // 当前操作用户ID
  userName: string;         // 用户姓名（必填）
  mobile: string;           // 手机号（必填，11位）
  sexID?: string;           // 性别ID（必填）
  credTypeID?: string;      // 证件类型ID
  credNo?: string;          // 证件号
  birthDate?: string;       // 出生日期
  workMobile?: string;      // 工作手机
  mail?: string;            // 邮箱
  nickname?: string;        // 昵称
  image?: string;           // 头像
  introduce?: string;       // 简介
  hospID?: string;          // 所属医院ID（可选，现在通过角色管理）
  hospDesc?: string;        // 医院名称
  startDate: string;        // 启用日期（必填）
  stopDate?: string;        // 停用日期
  statusFlag?: string;      // 状态 Y/N（默认Y）
  createdDate?: string;     // 创建日期（编辑时保留）
  createdTime?: string;     // 创建时间（编辑时保留）
}

/** 用户申请参数 */
export interface UserApplyParams {
  code?: string;            // 编码
  descripts: string;        // 姓名（必填）
  sexID?: string;           // 性别ID（必填）
  mobile: string;           // 手机号（必填）
  credTypeID?: string;      // 证件类型ID
  credNo?: string;          // 证件号
  hospitalID: string;       // 所属医院ID（必填）
  introduce?: string;       // 简介
  auditGroupID?: string;    // 审核组ID
  password?: string;        // 密码
}

/** 审核参数 */
export interface AuditParams {
  userAuditLogID: number;   // 申请记录ID（必填）
  auditStatus: string;      // 审核状态 Y=通过 N=驳回（必填）
  auditRemarks?: string;    // 审核备注
}

/** 角色分配参数 */
export interface SaveUserLogonLocParams {
  userLogonLocID?: number;  // 记录ID（为空则新增）
  userID?: number;          // 用户ID
  hospID: string;           // 医院ID（必填）
  groupID: string;          // 角色组ID（必填）
  isDefault?: string;       // 是否默认 Y/N（默认N）
}

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

// ========== 用户管理 API 函数 (01030101-01030111) ==========

/** 查询用户列表 (01030101) - 服务端分页
 * 后端会根据session中的groupID自动进行医院数据权限过滤
 */
export const queryUsers = (
  params: {
    code?: string;           // 用户编码
    descripts?: string;      // 用户姓名
    status?: string;         // 状态 Y/N/all
    hospID?: string;         // 医院ID
    groupID?: string;        // 角色组ID
  },
  pagination: Pagination
): Promise<ApiResponse<PageResult<UserItem>>> => {
  return invoke('01030101', [params], undefined, pagination);
};

/** 新增/编辑用户 (01030102)
 * 后端使用session.userID作为创建人和更新人
 * userDr为空时新增，有值时编辑
 */
export const saveUser = (
  params: SaveUserParams
): Promise<ApiResponse> => {
  return invoke('01030102', [params]);
};

/** 查询用户申请记录列表 (01030107) - 服务端分页 */
export const queryApplyLogs = (
  params: {
    auditStatus?: string;    // 审核状态 R=待审核 Y=已通过 N=已驳回
    hospitalID?: string;     // 医院ID
    beginDate?: string;      // 开始日期
    endDate?: string;        // 结束日期
  },
  pagination: Pagination
): Promise<ApiResponse<PageResult<UserAuditLogItem>>> => {
  return invoke('01030107', [params], undefined, pagination);
};

/** 查询用户申请详情 (01030108) */
export const getUserAuditLogDetail = (
  params: {
    userAuditLogID: number;  // 申请记录ID
  }
): Promise<ApiResponse<UserAuditLogItem>> => {
  return invoke('01030108', [params]);
};

/** 提交用户注册申请 (01030105)
 * 申请状态默认为"R"(待审核)
 */
export const submitUserApply = (
  params: UserApplyParams
): Promise<ApiResponse> => {
  return invoke('01030105', [params]);
};

/** 审核用户申请 (01030106)
 * 后端使用session.userID作为审核人
 * auditStatus: Y=通过 N=驳回
 */
export const auditUserApply = (
  params: AuditParams
): Promise<ApiResponse> => {
  return invoke('01030106', [params]);
};

/** 保存/更新用户权限角色 (01030109)
 * 后端使用session.userID作为更新人
 * userLogonLocID为空时新增，有值时更新
 */
export const saveUserLogonLoc = (
  params: SaveUserLogonLocParams
): Promise<ApiResponse> => {
  return invoke('01030109', [params]);
};

/** 删除用户权限角色 (01030110)
 * 后端使用session.userID作为更新人
 */
export const deleteUserLogonLoc = (
  params: {
    userLogonLocID: number;  // 权限角色记录ID
  }
): Promise<ApiResponse> => {
  return invoke('01030110', [params]);
};

/** 查询用户详情含角色列表 (01030111) */
export const getUserDetail = (
  params: {
    userID: number;          // 用户ID
  }
): Promise<ApiResponse<{ rows: UserLogonLocItem[] }>> => {
  return invoke('01030111', [params]);
};

/** 删除用户医院关联记录 (01030112)
 * 删除 HB_UserLinkHosp 表中的记录
 * 在删除用户角色时同步调用
 */
export const deleteUserLinkHosp = (
  params: {
    userID: number;          // 用户ID
    hospID: number;          // 医院ID
  }
): Promise<ApiResponse> => {
  return invoke('01030112', [params]);
};

/** 保存用户医院关联记录 (01030113)
 * 新增或更新 HB_UserLinkHosp 表中的记录
 * 在保存用户角色时同步调用
 */
export const saveUserLinkHosp = (
  params: {
    userID: number;          // 用户ID
    hospID: number;          // 医院ID
  }
): Promise<ApiResponse> => {
  return invoke('01030113', [params]);
};

// ========== 角色管理 API 函数 (01010031-01010037, 01010057) ==========

/** 角色项 - 01010032接口返回 */
export interface GroupItem {
  id: number;                // 角色ID
  code: string;             // 角色编码
  descripts: string;        // 角色名称
  enDesc?: string;           // 英文名称
  mainInterface?: string;    // 主界面
  mainInterfaceTitle?: string; // 主界面名称
  operCodeTable?: string;    // 操作码表
  sendMsgToAllUser?: string; // 发送消息给所有用户
  safeClassificat?: string;  // 安全级别
  safeClassificatCode?: string; // 安全级别代码
  safeClassificatDesc?: string; // 安全级别描述
  columnEdit?: string;      // 允许列编辑
  layoutEdit?: string;       // 允许布局编辑
  defaultMenuType?: string;  // 默认菜单类型
  tokenOverTime?: string;    // token超时时间
  startDate?: string;        // 启用日期
  endDate?: string;         // 停用日期
}

/** 角色下拉选项项 */
export interface GroupOptionItem {
  id: number;               // 角色ID
  code: string;             // 角色编码
  descripts: string;       // 角色名称
}

/** 查询角色下拉列表 (01010057)
 * 注意：该接口返回格式为 result: [] 而非 result: { rows: [] }
 */
export const queryGroupOptions = (
  params: {
    active?: string;         // 状态 Y/N，默认Y
  } = {}
): Promise<ApiResponse<GroupOptionItem[]>> => {
  return invoke('01010057', [params]);
};

/** 查询角色列表 (01010032) - 服务端分页
 * 支持按角色编码、角色名称过滤
 */
export const queryGroupList = (
  params: {
    code?: string;           // 角色编码
    descripts?: string;      // 角色名称
  },
  pagination: Pagination
): Promise<ApiResponse<PageResult<GroupItem>>> => {
  return invoke('01010032', [params], undefined, pagination);
};

/** 保存角色 (01010031)
 * id为空时新增，有值时编辑
 */
export const saveGroup = (
  params: {
    id?: string;             // 角色ID（为空则新增）
    code: string;            // 角色编码（必填）
    descripts: string;       // 角色名称（必填）
    enDesc?: string;        // 英文名称
    mainInterface?: string;  // 主界面
    operCodeTable?: string;  // 操作码表 Y/N
    sendMsgToAllUser?: string; // 发送消息给所有用户 Y/N
    safeClassificat?: string; // 安全级别
    columnEdit?: string;     // 允许列编辑 Y/N
    layoutEdit?: string;     // 允许布局编辑 Y/N
    defaultMenuType?: string; // 默认菜单类型
    startDate?: string;      // 启用日期
    endDate?: string;        // 停用日期
  }
): Promise<ApiResponse> => {
  return invoke('01010031', [params]);
};

/** 查询角色菜单详情 (01010033)
 * 获取指定角色的菜单列表
 * 返回格式: { result: { total, rows: [{ menuDetailID, menuDetailCode, ... }] } }
 */
export const getGroupMenuDetail = (
  params: {
    groupID: string;        // 角色ID（必填）
    type?: string;          // 类型
  }
): Promise<ApiResponse<{ total: number; rows: Array<{ menuDetailID: string }> }>> => {
  return invoke('01010033', [params]);
};

/** 保存角色菜单 (01010037)
 * 批量保存角色的菜单权限
 * 格式: { groupID, type: "1", preMenuGroupID: "", menuDetail: [{ menuDetailID, seqNo, preMenuGroupID }] }
 */
export const saveGroupMenu = (
  params: {
    groupID: string;        // 角色ID（必填）
    type?: string;          // 类型，默认为"1"
    preMenuGroupID?: string; // 上级菜单组ID
    menuDetail: Array<{     // 菜单详情数组
      menuDetailID: string; // 菜单ID
      seqNo?: string;
      preMenuGroupID?: string;
    }>;
  }
): Promise<ApiResponse> => {
  return invoke('01010037', [{
    groupID: params.groupID,
    type: params.type || '1',
    preMenuGroupID: params.preMenuGroupID || '',
    menuDetail: params.menuDetail
  }]);
};
