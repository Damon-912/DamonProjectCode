/**
 * 盈亏分析模块接口
 * 
 * 包含科室盈亏、医生盈亏、病种盈亏相关接口
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

// ========== 科室盈亏 (02010201) ==========

/** 科室盈亏记录 */
export interface DeptProfitItem {
  deptCode: string;
  deptName: string;
  totalCaseCount: number;
  groupedCaseCount: number;
  groupRate: number;
  totalFee: number;
  payStandard: number;
  profitAmount: number;
  profitRate: number;
  cmi: number;
  avgFee: number;
  avgHospitalDays: number;
}

/** 查询科室盈亏参数 */
export interface QueryDeptProfitParams {
  year?: string;
  month?: string;
  deptCode?: string;
  startDate?: string;
  endDate?: string;
}

/** 查询科室盈亏 (02010201) */
export const queryDeptProfit = (
  params: QueryDeptProfitParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<DeptProfitItem>>> => {
  return invoke('02010201', [params], undefined, pagination);
};

/** 科室盈亏统计 */
export interface DeptProfitStatistics {
  totalDeptCount: number;
  totalCaseCount: number;
  totalProfitAmount: number;
  avgProfitRate: number;
  profitDeptCount: number;
  lossDeptCount: number;
  balanceDeptCount: number;
  topProfitDepts: Array<{
    deptCode: string;
    deptName: string;
    profitAmount: number;
    profitRate: number;
  }>;
  topLossDepts: Array<{
    deptCode: string;
    deptName: string;
    profitAmount: number;
    profitRate: number;
  }>;
}

/** 获取科室盈亏统计 (02010206) */
export const getDeptProfitStatistics = (
  params: {
    year?: string;
    month?: string;
    startDate?: string;
    endDate?: string;
  }
): Promise<ApiResponse<DeptProfitStatistics>> => {
  return invoke('02010206', [params]);
};

// ========== 医生盈亏 (02010202) ==========

/** 医生盈亏记录 */
export interface DoctorProfitItem {
  doctorCode: string;
  doctorName: string;
  deptCode: string;
  deptName: string;
  caseCount: number;
  totalFee: number;
  payStandard: number;
  profitAmount: number;
  profitRate: number;
  avgFee: number;
  avgPayment: number;
  avgProfit: number;
}

/** 查询医生盈亏参数 */
export interface QueryDoctorProfitParams {
  year?: string;
  month?: string;
  deptCode?: string;
  doctorCode?: string;
  startDate?: string;
  endDate?: string;
}

/** 查询医生盈亏 (02010202) */
export const queryDoctorProfit = (
  params: QueryDoctorProfitParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<DoctorProfitItem>>> => {
  return invoke('02010202', [params], undefined, pagination);
};

/** 医生盈亏统计 */
export interface DoctorProfitStatistics {
  totalDoctorCount: number;
  totalCaseCount: number;
  totalProfitAmount: number;
  avgProfitRate: number;
  profitDoctorCount: number;
  lossDoctorCount: number;
  balanceDoctorCount: number;
  topProfitDoctors: Array<{
    doctorCode: string;
    doctorName: string;
    deptName: string;
    profitAmount: number;
    profitRate: number;
  }>;
  topLossDoctors: Array<{
    doctorCode: string;
    doctorName: string;
    deptName: string;
    profitAmount: number;
    profitRate: number;
  }>;
}

/** 获取医生盈亏统计 */
export const getDoctorProfitStatistics = (
  params: {
    year?: string;
    month?: string;
    deptCode?: string;
    startDate?: string;
    endDate?: string;
  }
): Promise<ApiResponse<DoctorProfitStatistics>> => {
  return invoke('02010202', [{ ...params, statistics: true }]);
};

// ========== 病种盈亏 (02010203) ==========

/** 病种盈亏记录 */
export interface DiseaseProfitItem {
  drgCode: string;
  drgName: string;
  dipCode?: string;
  dipName?: string;
  caseCount: number;
  totalFee: number;
  payStandard: number;
  profitAmount: number;
  profitRate: number;
  avgFee: number;
  avgPayment: number;
  avgProfit: number;
  weight?: number;
}

/** 查询病种盈亏参数 */
export interface QueryDiseaseProfitParams {
  year?: string;
  month?: string;
  drgCode?: string;
  dipCode?: string;
  startDate?: string;
  endDate?: string;
}

/** 查询病种盈亏 (02010203) */
export const queryDiseaseProfit = (
  params: QueryDiseaseProfitParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<DiseaseProfitItem>>> => {
  return invoke('02010203', [params], undefined, pagination);
};

/** 病种盈亏统计 */
export interface DiseaseProfitStatistics {
  totalDiseaseCount: number;
  totalCaseCount: number;
  totalProfitAmount: number;
  avgProfitRate: number;
  profitDiseaseCount: number;
  lossDiseaseCount: number;
  balanceDiseaseCount: number;
  topProfitDiseases: Array<{
    drgCode: string;
    drgName: string;
    caseCount: number;
    profitAmount: number;
    profitRate: number;
  }>;
  topLossDiseases: Array<{
    drgCode: string;
    drgName: string;
    caseCount: number;
    profitAmount: number;
    profitRate: number;
  }>;
}

/** 获取病种盈亏统计 */
export const getDiseaseProfitStatistics = (
  params: {
    year?: string;
    month?: string;
    startDate?: string;
    endDate?: string;
  }
): Promise<ApiResponse<DiseaseProfitStatistics>> => {
  return invoke('02010203', [{ ...params, statistics: true }]);
};

// ========== 盈亏趋势分析 (02010204) ==========

/** 盈亏趋势数据 */
export interface ProfitTrendItem {
  year: string;
  month: string;
  profitAmount: number;
  caseCount: number;
  totalFee: number;
  payStandard: number;
}

/** 查询盈亏趋势参数 */
export interface QueryProfitTrendParams {
  deptCode?: string;
  doctorCode?: string;
  startYear?: string;
  startMonth?: string;
  endYear?: string;
  endMonth?: string;
}

/** 查询盈亏趋势分析 (02010204) */
export const queryProfitTrend = (
  params: QueryProfitTrendParams
): Promise<ApiResponse<ProfitTrendItem[]>> => {
  return invoke('02010204', [params]);
};

// ========== 重新计算盈亏 (02010205) ==========

/** 重新计算盈亏参数 */
export interface RecalculateProfitParams {
  year: string;
  month: string;
  deptCode?: string;
}

/** 重新计算盈亏 (02010205) */
export const recalculateProfit = (
  params: RecalculateProfitParams
): Promise<ApiResponse<{ recalculatedCount: number }>> => {
  return invoke('02010205', [params]);
};

// ========== 费用结构分析 ==========

/** 费用结构分析记录 */
export interface CostStructureItem {
  deptCode?: string;
  deptName?: string;
  doctorCode?: string;
  doctorName?: string;
  drgCode?: string;
  drgName?: string;
  caseCount: number;
  totalFee: number;
  drugCost: number;
  drugCostRatio: number;
  materialCost: number;
  materialCostRatio: number;
  serviceCost: number;
  serviceCostRatio: number;
  examCost: number;
  examCostRatio: number;
  otherCost: number;
  otherCostRatio: number;
}

/** 查询费用结构分析参数 */
export interface QueryCostStructureParams {
  year?: string;
  month?: string;
  deptCode?: string;
  doctorCode?: string;
  drgCode?: string;
  startDate?: string;
  endDate?: string;
}

/** 查询费用结构分析 */
export const queryCostStructure = (
  params: QueryCostStructureParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<CostStructureItem>>> => {
  return invoke('02010207', [params], undefined, pagination);
};

/** 费用结构统计 */
export interface CostStructureStatistics {
  totalCaseCount: number;
  totalFee: number;
  totalDrugCost: number;
  totalMaterialCost: number;
  totalServiceCost: number;
  totalExamCost: number;
  totalOtherCost: number;
  avgDrugCostRatio: number;
  avgMaterialCostRatio: number;
  avgServiceCostRatio: number;
  avgExamCostRatio: number;
  avgOtherCostRatio: number;
}

/** 获取费用结构统计 */
export const getCostStructureStatistics = (
  params: {
    year?: string;
    month?: string;
    deptCode?: string;
    doctorCode?: string;
    drgCode?: string;
    startDate?: string;
    endDate?: string;
  }
): Promise<ApiResponse<CostStructureStatistics>> => {
  return invoke('02010207', [{ ...params, statistics: true }]);
};
