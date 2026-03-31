/**
 * HIS数据模块接口
 * 
 * 包含病案数据查询、结算清单管理、数据同步监控相关接口
 */

import { invoke } from './request';

// ========== 类型定义 ==========

/** 通用接口响应 */
export interface ApiResponse<T = any> {
  errorCode: string;
  errorMessage: string;
  result?: T;
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

// ========== 病案数据查询 (02010027) ==========

/** 病案记录 */
export interface MedicalRecordItem {
  id: string;
  admissionNo: string;
  medicalRecordNo: string;
  patientName: string;
  sex: string;
  sexDesc: string;
  age: number;
  idCard: string;
  
  // 就诊信息
  admissionDate: string;
  dischargeDate: string;
  hospitalDays: number;
  department: string;
  departmentName: string;
  doctor: string;
  doctorName: string;
  
  // 诊断信息
  mainDiagnosisCode: string;
  mainDiagnosisName: string;
  otherDiagnoses: string;
  
  // 手术信息
  mainProcedureCode: string;
  mainProcedureName: string;
  otherProcedures: string;
  
  // 费用信息
  totalCost: number;
  drugCost: number;
  materialCost: number;
  serviceCost: number;
  examCost: number;
  otherCost: number;
  
  // DRG/DIP分组信息
  drgCode: string;
  drgName: string;
  dipCode: string;
  dipName: string;
  groupStatus: string;
  groupStatusDesc: string;
  groupTime: string;
  
  // 状态
  status: string;
  statusDesc: string;
}

/** 查询病案数据参数 */
export interface QueryMedicalRecordParams {
  admissionNo?: string;
  medicalRecordNo?: string;
  patientName?: string;
  idCard?: string;
  department?: string;
  doctor?: string;
  mainDiagnosisCode?: string;
  drgCode?: string;
  dipCode?: string;
  groupStatus?: string;
  startDate?: string;
  endDate?: string;
}

/** 查询病案数据 (02010027) */
export const queryMedicalRecords = (
  params: QueryMedicalRecordParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<MedicalRecordItem>>> => {
  return invoke('02010027', [params], undefined, pagination);
};

/** 病案详情 */
export interface MedicalRecordDetail extends MedicalRecordItem {
  // 基本信息扩展
  birthDate: string;
  nationality: string;
  nativePlace: string;
  occupation: string;
  maritalStatus: string;
  
  // 入院信息
  admissionType: string;
  admissionCondition: string;
  dischargeType: string;
  dischargeCondition: string;
  
  // 诊断明细
  diagnosisList: Array<{
    type: string;
    code: string;
    name: string;
  }>;
  
  // 手术明细
  procedureList: Array<{
    date: string;
    code: string;
    name: string;
    level: string;
  }>;
  
  // 费用明细
  costDetail: {
    drug: Array<{ name: string; amount: number }>;
    material: Array<{ name: string; amount: number }>;
    service: Array<{ name: string; amount: number }>;
    exam: Array<{ name: string; amount: number }>;
  };
}

/** 查询病案详情 (02010028) */
export const queryMedicalRecordDetail = (
  admissionNo: string
): Promise<ApiResponse<MedicalRecordDetail>> => {
  return invoke('02010028', [{ admissionNo }]);
};

/** 保存病案数据 (02010026) */
export const saveMedicalRecord = (
  params: Partial<MedicalRecordItem>
): Promise<ApiResponse> => {
  return invoke('02010026', [params]);
};

// ========== 结算清单管理 (02010029, 02010030, 02010031) ==========

/** 结算清单记录 */
export interface SettlementItem {
  id: string;
  settlementNo: string;
  admissionNo: string;
  medicalRecordNo: string;
  patientName: string;
  sex: string;
  sexDesc: string;
  age: number;
  idCard: string;
  
  // 就诊信息
  admissionDate: string;
  dischargeDate: string;
  hospitalDays: number;
  department: string;
  departmentName: string;
  doctor: string;
  doctorName: string;
  
  // 诊断信息
  mainDiagnosisCode: string;
  mainDiagnosisName: string;
  otherDiagnoses: string;
  
  // 手术信息
  mainProcedureCode: string;
  mainProcedureName: string;
  otherProcedures: string;
  
  // 费用信息
  totalCost: number;
  selfPay: number;
  insurancePay: number;
  
  // DRG/DIP结算信息
  drgCode: string;
  drgName: string;
  dipCode: string;
  dipName: string;
  paymentStandard: number;
  settlementAmount: number;
  balance: number;
  
  // 结算状态
  settlementStatus: string;
  settlementStatusDesc: string;
  settlementDate: string;
  settlementTime: string;
  
  // 医保信息
  insuranceType: string;
  insuranceTypeDesc: string;
  insuranceCardNo: string;
}

/** 查询结算清单参数 */
export interface QuerySettlementParams {
  settlementNo?: string;
  admissionNo?: string;
  medicalRecordNo?: string;
  patientName?: string;
  idCard?: string;
  department?: string;
  settlementStatus?: string;
  insuranceType?: string;
  startDate?: string;
  endDate?: string;
}

/** 查询结算清单 (02010031) */
export const querySettlements = (
  params: QuerySettlementParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<SettlementItem>>> => {
  return invoke('02010031', [params], undefined, pagination);
};

/** 结算清单详情 */
export interface SettlementDetail extends SettlementItem {
  // 费用明细
  costDetail: {
    westernMedicine: number;
    chineseMedicine: number;
    herbalMedicine: number;
    material: number;
    exam: number;
    treatment: number;
    surgery: number;
    nursing: number;
    bed: number;
    other: number;
  };
  
  // 医保结算明细
  insuranceDetail: {
    totalAmount: number;
    fundPay: number;
    personalPay: number;
    cashPay: number;
    accountPay: number;
  };
}

/** 查询结算清单详情 (02010030) */
export const querySettlementDetail = (
  settlementNo: string
): Promise<ApiResponse<SettlementDetail>> => {
  return invoke('02010030', [{ settlementNo }]);
};

/** 保存结算清单 (02010029) */
export const saveSettlement = (
  params: Partial<SettlementItem>
): Promise<ApiResponse> => {
  return invoke('02010029', [params]);
};

/** 删除结算清单 (02010035) */
export const deleteSettlement = (
  settlementNo: string
): Promise<ApiResponse> => {
  return invoke('02010035', [{ settlementNo }]);
};

/** 提交结算 (02010036) */
export const submitSettlement = (
  settlementNo: string
): Promise<ApiResponse> => {
  return invoke('02010036', [{ settlementNo }]);
};

/** 取消结算 (02010037) */
export const cancelSettlement = (
  settlementNo: string
): Promise<ApiResponse> => {
  return invoke('02010037', [{ settlementNo }]);
};

// ========== 数据同步监控 (02010050, 02010051, 02010052) ==========

/** 同步任务记录 */
export interface SyncTaskItem {
  id: string;
  taskName: string;
  taskType: string;
  taskTypeDesc: string;
  dataSource: string;
  dataSourceDesc: string;
  
  // 同步范围
  startDate: string;
  endDate: string;
  department?: string;
  departmentName?: string;
  
  // 同步统计
  totalCount: number;
  successCount: number;
  failCount: number;
  skipCount: number;
  
  // 状态
  status: string;
  statusDesc: string;
  progress: number;
  
  // 时间
  startTime: string;
  endTime?: string;
  duration?: number;
  
  // 创建信息
  createUser: string;
  createUserName: string;
  createTime: string;
  
  // 错误信息
  errorMsg?: string;
}

/** 查询同步任务参数 */
export interface QuerySyncTaskParams {
  taskName?: string;
  taskType?: string;
  dataSource?: string;
  status?: string;
  startDate?: string;
  endDate?: string;
}

/** 查询同步任务 (02010050) */
export const querySyncTasks = (
  params: QuerySyncTaskParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<SyncTaskItem>>> => {
  return invoke('02010050', [params], undefined, pagination);
};

/** 同步任务详情 */
export interface SyncTaskDetail extends SyncTaskItem {
  // 同步明细
  detailList: Array<{
    id: string;
    admissionNo: string;
    patientName: string;
    operation: string;
    status: string;
    statusDesc: string;
    errorMsg?: string;
    syncTime: string;
  }>;
}

/** 查询同步任务详情 (02010051) */
export const querySyncTaskDetail = (
  taskId: string
): Promise<ApiResponse<SyncTaskDetail>> => {
  return invoke('02010051', [{ taskId }]);
};

/** 创建同步任务参数 */
export interface CreateSyncTaskParams {
  taskName: string;
  taskType: string;
  dataSource: string;
  startDate: string;
  endDate: string;
  department?: string;
}

/** 创建同步任务 (02010052) */
export const createSyncTask = (
  params: CreateSyncTaskParams
): Promise<ApiResponse<{ taskId: string }>> => {
  return invoke('02010052', [params]);
};

/** 取消同步任务 (02010053) */
export const cancelSyncTask = (
  taskId: string
): Promise<ApiResponse> => {
  return invoke('02010053', [{ taskId }]);
};

/** 删除同步任务 (02010054) */
export const deleteSyncTask = (
  taskId: string
): Promise<ApiResponse> => {
  return invoke('02010054', [{ taskId }]);
};

/** 重新执行同步任务 (02010055) */
export const retrySyncTask = (
  taskId: string
): Promise<ApiResponse> => {
  return invoke('02010055', [{ taskId }]);
};

/** 数据同步统计 */
export interface SyncStatistics {
  totalTaskCount: number;
  runningTaskCount: number;
  successTaskCount: number;
  failTaskCount: number;
  
  todaySyncCount: number;
  todaySuccessCount: number;
  todayFailCount: number;
  
  last7DaysStats: Array<{
    date: string;
    totalCount: number;
    successCount: number;
    failCount: number;
  }>;
  
  dataSourceStats: Array<{
    dataSource: string;
    dataSourceDesc: string;
    totalCount: number;
    successCount: number;
    failCount: number;
  }>;
}

/** 获取数据同步统计 (02010056) */
export const getSyncStatistics = (
  params: {
    startDate?: string;
    endDate?: string;
  }
): Promise<ApiResponse<SyncStatistics>> => {
  return invoke('02010056', [params]);
};

// ========== 数据质量检查 (02010057, 02010058) ==========

/** 数据质量检查记录 */
export interface DataQualityItem {
  id: string;
  checkType: string;
  checkTypeDesc: string;
  checkItem: string;
  checkItemDesc: string;
  
  // 检查对象
  admissionNo: string;
  patientName: string;
  department: string;
  departmentName: string;
  
  // 检查结果
  checkResult: string;
  checkResultDesc: string;
  issueDesc: string;
  suggestion: string;
  
  // 处理状态
  status: string;
  statusDesc: string;
  handleUser?: string;
  handleTime?: string;
  handleRemark?: string;
  
  // 时间
  checkTime: string;
}

/** 查询数据质量检查参数 */
export interface QueryDataQualityParams {
  checkType?: string;
  checkItem?: string;
  admissionNo?: string;
  patientName?: string;
  department?: string;
  checkResult?: string;
  status?: string;
  startDate?: string;
  endDate?: string;
}

/** 查询数据质量检查 (02010057) */
export const queryDataQuality = (
  params: QueryDataQualityParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<DataQualityItem>>> => {
  return invoke('02010057', [params], undefined, pagination);
};

/** 处理数据质量问题 (02010058) */
export const handleDataQualityIssue = (
  params: {
    id: string;
    handleRemark: string;
  }
): Promise<ApiResponse> => {
  return invoke('02010058', [params]);
};

/** 数据质量统计 */
export interface DataQualityStatistics {
  totalCheckCount: number;
  normalCount: number;
  warningCount: number;
  errorCount: number;
  
  pendingHandleCount: number;
  handledCount: number;
  ignoredCount: number;
  
  checkTypeStats: Array<{
    checkType: string;
    checkTypeDesc: string;
    totalCount: number;
    warningCount: number;
    errorCount: number;
  }>;
  
  departmentStats: Array<{
    department: string;
    departmentName: string;
    totalCount: number;
    warningCount: number;
    errorCount: number;
  }>;
}

/** 获取数据质量统计 (02010059) */
export const getDataQualityStatistics = (
  params: {
    startDate?: string;
    endDate?: string;
  }
): Promise<ApiResponse<DataQualityStatistics>> => {
  return invoke('02010059', [params]);
};
