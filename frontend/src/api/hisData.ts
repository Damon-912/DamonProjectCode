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


// ========== HIS数据同步专用接口 (02010067) ==========

/** 获取HIS患者就诊信息 (02010067) */
export const getHisPatientAdmInfo = (
  params: {
    admID: string;
    hospID?: string;
  }
): Promise<ApiResponse<any>> => {
  return invoke('02010067', [params]);
};

/**
 * 获取HIS住院患者列表 (02010067)
 * 入参：stDate（开始日期）、endDate（结束日期）
 */
export const getHisInpatientList = (
  params: { stDate: string; endDate: string }
): Promise<ApiResponse<any>> => {
  return invoke('02010067', [params]);
};

// ========== 已同步患者查询 (02010075) ==========

/** 已同步患者查询参数 */
export interface QuerySyncedPatientsParams {
  patientName?: string;
  medicalRecordNo?: string;
  admDateStart?: string;
  admDateEnd?: string;
}

/** 已同步患者记录 */
export interface SyncedPatientItem {
  admissionNo: string;
  medicalRecordNo: string;
  patientName: string;
  sex: string;
  age: number;
  department: string;
  doctor: string;
  mainDiagnosisCode: string;
  mainDiagnosisName: string;
  mainProcedureCode: string;
  mainProcedureName: string;
  totalCost: number;
  admissionDate: string;
  dischargeDate: string;
}

/**
 * 查询已同步患者列表 (02010075)
 * 用于HIS数据同步监控页面
 */
export const querySyncedPatients = (
  params: QuerySyncedPatientsParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<SyncedPatientItem>>> => {
  return invoke('02010075', [params], undefined, pagination);
};

// ========== 患者详情查询 (02010076) ==========

/** 患者详情 */
export interface PatientDetail {
  admInfo: {
    admDr: string;
    admissionNo: string;
    patID: string;
    medicalRecordNo: string;
    patientName: string;
    sexCode: string;
    sexDesc: string;
    patNo: string;
    admDocDesc: string;
    admNurDesc: string;
    admDateTime: string;
    admInDays: number;
    admDiag: string;
    inLocDesc: string;
    inWardDesc: string;
    createDate: string;
    createTime: string;
  };
  diseList: Array<{
    diseSn: number;
    diseCode: string;
    diseName: string;
    mainFlag: string;
    diseType: string;
  }>;
  oprnList: Array<{
    oprnSn: number;
    oprnCode: string;
    oprnName: string;
    mainFlag: string;
    oprnDate: string;
  }>;
}

/** 查询患者详情 (02010076) */
export const queryPatientDetail = (
  params: { admID: string }
): Promise<ApiResponse<PatientDetail>> => {
  return invoke('02010076', [params]);
};

// ========== 同步日志查询 (02010077) ==========

/** 同步日志记录 */
export interface SyncLogItem {
  id: number;
  taskName: string;
  syncType: string;
  startTime: string;
  endTime: string;
  statusCode: string;
  totalCount: number;
  successCount: number;
  failedCount: number;
  errorMessage: string;
}

/** 查询同步日志参数 */
export interface QuerySyncLogsParams {
  syncType?: string;
  statusCode?: string;
  startDate?: string;
  endDate?: string;
}

/**
 * 查询同步日志列表 (02010077)
 * 用于HIS数据同步日志查询页面
 */
export const querySyncLogs = (
  params: QuerySyncLogsParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<SyncLogItem>>> => {
  return invoke('02010077', [params], undefined, pagination);
};

// ========== HIS同步任务管理 (02010078, 02010079, 02010080, 02010081) ==========

/** 执行同步任务参数 */
export interface ExecuteSyncTaskParams {
  hospCode: string;
  syncType: string;  // incremental/full
  lookbackDays?: number;
  startDate?: string;
  endDate?: string;
}

/** 同步配置 */
export interface SyncConfig {
  id?: string;
  hospCode: string;
  syncType: string;
  frequency: string;  // manual/hourly/daily/weekly
  scheduledTime?: string;
  lookbackDays?: number;
  enabled?: boolean;
}

/** 同步状态 */
export interface SyncStatus {
  status: string;
  lastSyncTime?: string;
  lastSyncStatus?: string;
  errorMessage?: string;
}

/**
 * 执行同步任务 (02010078)
 */
export const executeSyncTask = (
  params: ExecuteSyncTaskParams
): Promise<ApiResponse<any>> => {
  return invoke('02010078', [params]);
};

/**
 * 查询同步配置 (02010079)
 */
export const getSyncConfig = (
  params: { hospCode: string }
): Promise<ApiResponse<SyncConfig>> => {
  return invoke('02010079', [params]);
};

/**
 * 保存同步配置 (02010080)
 */
export const saveSyncConfig = (
  params: SyncConfig
): Promise<ApiResponse<any>> => {
  return invoke('02010080', [params]);
};

/**
 * 查询同步状态 (02010081)
 */
export const getSyncStatus = (
  params: { hospCode: string }
): Promise<ApiResponse<SyncStatus>> => {
  return invoke('02010081', [params]);
};

// ========== HIS服务配置管理 (02010069, 02010070) ==========

/** HIS服务配置 */
export interface HisServiceConfig {
  hisProtocol?: string;  // http 或 https
  hisIP: string;
  hisPort: string;
  hisURL: string;
  authorization: string;
}

/**
 * 获取HIS服务配置 (02010070)
 * 用于同步HIS数据前获取服务连接配置
 */
export const getHisServiceConfig = (
  params: { hospCode: string }
): Promise<ApiResponse<HisServiceConfig>> => {
  return invoke('02010070', [params]);
};

/**
 * 保存HIS服务配置 (02010069)
 */
export const saveHisServiceConfig = (
  params: HisServiceConfig & { hospCode: string }
): Promise<ApiResponse<any>> => {
  return invoke('02010069', [params]);
};
