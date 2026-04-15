/**
 * DIP业务模块接口
 * 
 * 包含DIP分组、病种分值查询、分值偏差分析相关接口
 */

import { invoke } from './request';

// ========== 类型定义 ==========

/** 通用接口响应 */
export interface ApiResponse<T = any> {
  errorCode: string;
  errorMessage: string;
  result?: T;
  rowIDArr?: any[];  // 新增/保存操作返回的记录ID数组
}

/** 分页参数 */
export interface Pagination {
  pageSize: number;
  currentPage: number;
  sortColumn?: string;
  sortOrder?: string;
}

/** 分页结果 */
export interface PageResult<T = any> {
  rows: T[];
  total: number;
}

// ========== DIP分组工作台 ==========

/** DIP分组参数 */
export interface DIPGroupParams {
  // 患者基本信息
  patientId?: string;
  admissionNo?: string;
  name?: string;
  sex?: string;
  age?: number;
  
  // 诊断信息
  mainDiagnosisCode: string;
  mainDiagnosisName?: string;
  otherDiagnoses?: Array<{
    code: string;
    name?: string;
  }>;
  
  // 手术信息
  mainProcedureCode?: string;
  mainProcedureName?: string;
  otherProcedures?: Array<{
    code: string;
    name?: string;
  }>;
  
  // 费用信息
  totalCost?: number;
  drugCost?: number;
  materialCost?: number;
  serviceCost?: number;
  
  // 其他信息
  department?: string;
  doctor?: string;
  hospitalDays?: number;
  admissionDate?: string;
  dischargeDate?: string;
}

/** DIP分组结果 */
export interface DIPGroupResult {
  id: string;
  admissionNo: string;
  patientName: string;
  
  // 分组结果
  dipCode: string;
  dipName: string;
  points: number;
  paymentStandard: number;
  
  // 费用信息
  totalCost: number;
  drugCost: number;
  materialCost: number;
  serviceCost: number;
  paymentAmount: number;
  balance: number;
  
  // 分组信息
  groupName: string;
  groupDesc: string;
  
  // 状态
  status: string;
  statusDesc: string;
  
  // 时间
  groupTime: string;
}

/** DIP分组查询参数 */
export interface DIPGroupQueryParams {
  admissionNo?: string;
  patientName?: string;
  dipCode?: string;
  status?: string;
  startDate?: string;
  endDate?: string;
}

/** DIP分组 (02010041) */
export const dipGroup = (
  params: DIPGroupParams
): Promise<ApiResponse<DIPGroupResult>> => {
  return invoke('02010041', [params]);
};

/** 查询DIP分组记录 (02010042) */
export const queryDIPGroupRecords = (
  params: DIPGroupQueryParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<DIPGroupResult>>> => {
  return invoke('02010042', [params], undefined, pagination);
};

/** 批量DIP分组 (02010043) */
export const batchDIPGroup = (
  params: {
    admissionNos: string[];
  }
): Promise<ApiResponse<{
  totalCount: number;
  successCount: number;
  failCount: number;
  failList: Array<{
    admissionNo: string;
    errorMsg: string;
  }>;
}>> => {
  return invoke('02010043', [params]);
};

// ========== 病种分值查询 ==========

/** DIP病种分值记录 */
export interface DIPPointsItem {
  id: string;
  dipCode: string;
  dipName: string;
  points: number;
  paymentStandard: number;
  
  // 诊断信息
  mainDiagnosisCode: string;
  mainDiagnosisName: string;
  otherDiagnosisCodes?: string;
  
  // 手术信息
  mainProcedureCode?: string;
  mainProcedureName?: string;
  otherProcedureCodes?: string;
  
  // 地区信息
  provinceId: string;
  provinceDesc: string;
  cityId: string;
  cityDesc: string;
  
  // 生效时间
  startDate: string;
  stopDate?: string;
  
  // 状态
  status: string;
  statusDesc: string;
}

/** DIP病种分值查询参数 */
export interface DIPPointsQueryParams {
  dipCode?: string;
  dipName?: string;
  mainDiagnosisCode?: string;
  mainDiagnosisName?: string;
  provinceId?: string;
  cityId?: string;
  status?: string;
}

/** 查询DIP病种分值 (02010044) */
export const queryDIPPoints = (
  params: DIPPointsQueryParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<DIPPointsItem>>> => {
  return invoke('02010044', [params], undefined, pagination);
};

// ========== 分值偏差分析 ==========

/** DIP分值偏差分析记录 */
export interface DIPVarianceItem {
  id: string;
  admissionNo: string;
  patientName: string;
  department: string;
  doctor: string;
  
  // 分组结果
  dipCode: string;
  dipName: string;
  points: number;
  paymentStandard: number;
  
  // 费用信息
  totalCost: number;
  drugCost: number;
  materialCost: number;
  serviceCost: number;
  paymentAmount: number;
  balance: number;
  
  // 偏差分析
  varianceAmount: number;
  varianceRate: number;
  varianceLevel: string; // high/medium/low
  varianceDesc: string;
  
  // 时间
  admissionDate: string;
  dischargeDate: string;
  groupTime: string;
}

/** DIP分值偏差分析查询参数 */
export interface DIPVarianceQueryParams {
  admissionNo?: string;
  patientName?: string;
  department?: string;
  doctor?: string;
  dipCode?: string;
  dipName?: string;
  varianceLevel?: string;
  startDate?: string;
  endDate?: string;
}

/** DIP分值偏差统计 */
export interface DIPVarianceStatistics {
  totalCases: number;
  totalCost: number;
  totalPayment: number;
  totalVariance: number;
  
  highVarianceCount: number;
  mediumVarianceCount: number;
  lowVarianceCount: number;
  
  avgVarianceRate: number;
  avgVarianceAmount: number;
  
  // Top5偏差病种
  topVarianceDips: Array<{
    dipCode: string;
    dipName: string;
    count: number;
    avgVariance: number;
  }>;
  
  // 科室偏差排行
  deptVarianceRank: Array<{
    department: string;
    count: number;
    avgVariance: number;
    totalVariance: number;
  }>;
}

/** 查询DIP分值偏差分析 (02010045) */
export const queryDIPVariance = (
  params: DIPVarianceQueryParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<DIPVarianceItem>>> => {
  return invoke('02010045', [params], undefined, pagination);
};

/** 获取DIP分值偏差统计 (02010046) */
export const getDIPVarianceStatistics = (
  params: {
    startDate?: string;
    endDate?: string;
    department?: string;
    varianceLevel?: string;
  }
): Promise<ApiResponse<DIPVarianceStatistics>> => {
  return invoke('02010046', [params]);
};

// ========== DIP病种目录 (与basicData.ts中的DIP病种库对应) ==========

/** DIP病种目录记录 */
export interface DIPCatalogItem {
  id: string;
  num: string;
  principalDiagnosis: string;
  principalDiagnosisName: string;
  majorProcedure: string;
  majorProcedureName: string;
  secondaryProcedure?: string;
  secondaryProcedureName?: string;
  provinceID: string;
  provinceDesc: string;
  cityID: string;
  cityDesc: string;
  startDate: string;
  stopDate?: string;
  status: string;
  statusDesc: string;
}

/** 查询DIP病种目录参数 */
export interface DIPCatalogQueryParams {
  principalDiagnosisName?: string;
  majorProcedureName?: string;
  provinceID?: string;
  cityID?: string;
  status?: string;
}

/** 查询DIP病种目录 (02010020 - 复用basicData中的接口) */
export const queryDIPCatalog = (
  params: DIPCatalogQueryParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<DIPCatalogItem>>> => {
  return invoke('02010020', [params], undefined, pagination);
};
