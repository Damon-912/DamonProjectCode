/**
 * 医疗机构管理接口
 * 
 * 接口代码:
 * 01050101 - 新增医疗机构
 * 01050102 - 修改医疗机构  
 * 01050104 - 删除医疗机构
 * 01050103 - 查询医疗机构分页
 */

import { invoke } from './request';
import type { ApiResponse, Pagination, PageResult } from './basicData';

/** 医疗机构记录 - 匹配后端返回字段 */
/** 
 * 后端字段映射说明：
 * - HospGrade_Dr -> hospGradeID
 * - ProvID_Dr -> provIDID
 * - CityID_Dr -> cityIDID
 * - AreaID_Dr -> areaIDID
 */
export interface HospitalItem {
  ID: string;
  hospitalID: string;
  code: string;
  descripts: string;
  hospGradeID?: number;
  gradeDesc?: string;
  hospTypeID: string;
  typeDesc?: string;
  hospNatureID: string;
  natureDesc?: string;
  provIDID: number;
  proDesc?: string;
  cityIDID: number;
  cityDesc?: string;
  areaIDID: number;
  areaDesc?: string;
  active: string;
  policyTypeID: string;
  policyTypeDesc: string;
  organizationCode: string;
  businesslicense: string;
  createDate?: string;
  createTime?: string;
}

/** 保存医疗机构参数 - 匹配后端期望字段 */
export interface SaveHospitalParams {
  hospitalID?: string;  // 修改医疗机构时使用ID
  code: string;
  descripts: string;
  hospGradeID?: string;
  hospTypeID: string;
  hospNatureID: string;
  provIDID: string;
  cityIDID: string;
  areaIDID?: string;
  policyTypeID: string;
  active: string;
  organizationCode?: string;
  businesslicense?: string;
  startDate?: string;
}

/** 查询医疗机构参数 */
export interface QueryHospitalParams {
  organizationCode?: string;
  desc?: string;
  active?: string;
}

/** 查询医疗机构列表 (01050103) */
export const queryHospitals = (
  params: QueryHospitalParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<HospitalItem>>> => {
  return invoke('01050103', [params], undefined, pagination);
};

/** 保存医疗机构 (01050101 - 新增, 01050102 - 修改) */
export const saveHospital = (
  params: SaveHospitalParams
): Promise<ApiResponse> => {
  if (params.hospitalID) {
    // 修改
    return invoke('01050102', [params]);
  }
  // 新增
  return invoke('01050101', [params]);
};

/** 删除医疗机构 (01050104) */
export const deleteHospital = (
  id: number
): Promise<ApiResponse> => {
  return invoke('01050104', [{ ID: id }]);
};
