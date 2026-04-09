/**
 * 预警相关API接口
 * 服务类: src.DRG.Warning
 * 接口Code规范: 020101xx
 * 
 * 参数格式: 数组形式 [{ ruleCode: 'xxx', ruleName: 'xxx', ... }]
 * 后端使用 params.%Get(0).ruleCode 方式访问
 */

import { invoke } from './request';

/**
 * 查询预警规则列表
 * @param params 查询参数
 * @param pagination 分页参数
 * @returns 预警规则列表
 */
export async function queryWarningRules(
  params?: {
    ruleCode?: string;
    ruleName?: string;
    ruleType?: string;
    isActive?: string;
  },
  pagination?: {
    pageSize?: number;
    currentPage?: number;
  }
) {
  return invoke('02010101', [{
    ruleCode: params?.ruleCode || '',
    ruleName: params?.ruleName || '',
    ruleType: params?.ruleType || '',
    isActive: params?.isActive || '',
  }], undefined, {
    pageSize: pagination?.pageSize || 20,
    currentPage: pagination?.currentPage || 1,
  });
}

/**
 * 保存预警规则（新增/修改）
 * @param data 规则数据
 * @returns 保存结果
 */
export async function saveWarningRule(data: {
  ruleId?: string;
  ruleCode: string;
  ruleName: string;
  ruleDesc?: string;
  ruleType: string;
  thresholdType?: string;
  thresholdValue?: number;
  mdcCode?: string;
  adrgCode?: string;
  drgCode?: string;
  warningLevel?: number;
  isActive?: string;
  seqNo?: number;
  remark?: string;
}) {
  return invoke('02010102', [{
    ruleId: data.ruleId || '',
    ruleCode: data.ruleCode,
    ruleName: data.ruleName,
    ruleDesc: data.ruleDesc || '',
    ruleType: data.ruleType,
    thresholdType: data.thresholdType || '',
    thresholdValue: data.thresholdValue || 0,
    mdcCode: data.mdcCode || '',
    adrgCode: data.adrgCode || '',
    drgCode: data.drgCode || '',
    warningLevel: data.warningLevel || 2,
    isActive: data.isActive || 'Y',
    seqNo: data.seqNo || 0,
    remark: data.remark || '',
  }]);
}

/**
 * 删除预警规则
 * @param ruleId 规则ID
 * @returns 删除结果
 */
export async function deleteWarningRule(ruleId: string) {
  return invoke('02010105', [{
    ruleId: ruleId,
  }]);
}

/**
 * 查询预警记录列表
 * @param params 查询参数
 * @param pagination 分页参数
 * @returns 预警记录列表
 */
export async function queryWarningRecords(
  params?: {
    warningNo?: string;
    ruleCode?: string;
    warningType?: string;
    warningStatus?: string;
    startDate?: string;
    endDate?: string;
    deptCode?: string;
    doctorCode?: string;
    patientName?: string;
    hisAdmId?: string;
  },
  pagination?: {
    pageSize?: number;
    currentPage?: number;
  }
) {
  return invoke('02010103', [{
    warningNo: params?.warningNo || '',
    ruleCode: params?.ruleCode || '',
    warningType: params?.warningType || '',
    warningStatus: params?.warningStatus || '',
    startDate: params?.startDate || '',
    endDate: params?.endDate || '',
    deptCode: params?.deptCode || '',
    doctorCode: params?.doctorCode || '',
    patientName: params?.patientName || '',
    hisAdmId: params?.hisAdmId || '',
  }], undefined, {
    pageSize: pagination?.pageSize || 20,
    currentPage: pagination?.currentPage || 1,
  });
}

/**
 * 处理预警（确认/忽略）
 * @param warningId 预警记录ID
 * @param processStatus 处理状态：processed-已处理, ignored-已忽略
 * @param processRemark 处理备注
 * @returns 处理结果
 */
export async function processWarning(
  warningId: string,
  processStatus: 'processed' | 'ignored',
  processRemark?: string
) {
  return invoke('02010104', [{
    warningId: warningId,
    processStatus: processStatus,
    processRemark: processRemark || '',
  }]);
}

/**
 * 预警统计分析
 * @param params 统计参数
 * @returns 统计结果
 */
export async function queryWarningStats(params?: {
  startDate?: string;
  endDate?: string;
}) {
  return invoke('02010106', [{
    startDate: params?.startDate || '',
    endDate: params?.endDate || '',
  }]);
}

/**
 * 新增预警记录（HIS调用接口）
 * @param data 预警记录数据
 * @returns 新增结果
 */
export async function addWarningRecord(data: {
  /** HIS就诊ID（必填） */
  hisAdmId: string;
  /** 患者姓名（必填） */
  patientName: string;
  /** 科室编码 */
  deptCode?: string;
  /** 科室名称 */
  deptName?: string;
  /** 医生编码 */
  doctorCode?: string;
  /** 医生姓名 */
  doctorName?: string;
  /** 医疗总费用（必填） */
  totalFee: number;
  /** DRG编码（必填） */
  drgCode: string;
  /** DRG支付标准 */
  drgPayStandard?: number;
  /** DRG名称 */
  drgName?: string;
  /** 病案ID */
  medicalRecordDr?: string;
  /** 医保结算费用 */
  insuranceFee?: number;
  /** 医疗机构代码 */
  fixmedinsCode?: string;
  /** 医疗机构名称 */
  fixmedinsName?: string;
  /** 指定预警类型（可选，不传则按规则自动匹配） */
  ruleType?: string;
}) {
  return invoke('02010107', [{
    hisAdmId: data.hisAdmId,
    patientName: data.patientName,
    deptCode: data.deptCode || '',
    deptName: data.deptName || '',
    doctorCode: data.doctorCode || '',
    doctorName: data.doctorName || '',
    totalFee: data.totalFee,
    drgCode: data.drgCode,
    drgPayStandard: data.drgPayStandard || 0,
    drgName: data.drgName || '',
    medicalRecordDr: data.medicalRecordDr || '',
    insuranceFee: data.insuranceFee || 0,
    fixmedinsCode: data.fixmedinsCode || '',
    fixmedinsName: data.fixmedinsName || '',
    ruleType: data.ruleType || '',
  }]);
}

/**
 * 预警统计数据类型
 */
export interface WarningStats {
  totalCount: number;
  pendingCount: number;
  processedCount: number;
  typeStats: {
    '01'?: number;
    '02'?: number;
    '03'?: number;
    '04'?: number;
    '05'?: number;
  };
  levelStats: {
    high?: number;
    medium?: number;
    low?: number;
  };
  totalDiff?: number;
  totalFee?: number;
}

/**
 * 预警规则数据类型
 */
export interface WarningRule {
  id: string;
  ruleCode: string;
  ruleName: string;
  ruleDesc?: string;
  ruleType: string;
  thresholdType?: string;
  thresholdValue?: number;
  mdcCode?: string;
  adrgCode?: string;
  drgCode?: string;
  deptCode?: string;
  warningLevel: number;
  isActive: string;
  seqNo?: number;
  createUserDr?: string;
  createDate?: string;
  createTime?: string;
  remark?: string;
}

/**
 * 预警记录数据类型
 */
export interface WarningRecord {
  id: string;
  warningNo: string;
  ruleCode: string;
  ruleName: string;
  warningType: string;
  warningLevel: number;
  hisAdmId: string;
  patientName: string;
  deptCode?: string;
  deptName?: string;
  doctorCode?: string;
  doctorName?: string;
  drgCode: string;
  drgName?: string;
  totalFee: number;
  insuranceFee?: number;
  drgPayStandard?: number;
  diffAmount?: number;
  diffRate?: number;
  warningMessage?: string;
  warningStatus: string;
  warningDate: string;
  warningTime: string;
  processUser?: string;
  processDate?: string;
  processTime?: string;
  processRemark?: string;
}
