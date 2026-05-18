/**
 * DRG/DIP 分组接口统一封装
 * 
 * 所有分组功能统一调用 02010001 DRG分组器接口
 * 入参规范统一，支持多种分组场景：
 * - 病案分组（从病案首页数据转换）
 * - 结算清单分组（从结算清单数据转换）
 * - 自定义分组（直接输入参数）
 */

import { invoke } from './request';

/**
 * 统一分组接口 - 02010001 DRG分组器（小驼峰入参）
 * @param params 统一分组参数（小驼峰格式）
 * @returns 分组结果（小驼峰格式）
 */
export const drgGroup = (params: DRGGroupParamsLowerCamel) => {
  // 直接发送小驼峰格式给后端
  return invoke('02010001', [params]);
};

/**
 * 批量分组接口（小驼峰入参）
 * @param paramsList 分组参数数组
 * @returns 批量分组结果
 */
export const drgGroupBatch = (paramsList: DRGGroupParamsLowerCamel[]) => {
  // 直接发送小驼峰格式给后端
  return invoke('02010001', paramsList);
};

/**
 * 小驼峰转大驼峰（入参转换）
 */
const convertToUpperCamel = (params: DRGGroupParamsLowerCamel): DRGGroupParams => {
  return {
    MainDiagnosisCode: params.mainDiagnosisCode || '',
    MainOperationCode: params.mainOperationCode || '',
    Sex: params.sex,
    Age: params.age,
    AgeGroupDays: params.ageGroupDays,
    NewbornFlag: params.newbornFlag,
    RespiratorTime: params.respiratorTime,
    ECMOFlag: params.ecmoFlag,
    TransplantFlag: params.transplantFlag,
    MarrowTransplantFlag: params.marrowTransplantFlag,
    HIVFlag: params.hivFlag,
    TraumaLevel: params.traumaLevel,
    Department: params.department,
    DischargeType: params.dischargeType,
    HospitalDays: params.hospitalDays,
    TotalCost: params.totalCost,
    Weight: params.weight,
    MedicalRecordId: params.medicalRecordId,
    AdmissionNo: params.admissionNo,
    DiseInfo: params.diseInfo?.map(d => ({
      MainFlag: d.mainFlag,
      DiagSn: d.diagSn,
      DiagCode: d.diagCode,
      DiagName: d.diagName,
    })),
    OprnInfo: params.oprnInfo?.map(o => ({
      MainFlag: o.mainFlag,
      OprnSn: o.oprnSn,
      OprnCode: o.oprnCode,
      OprnName: o.oprnName,
    })),
  };
};

/**
 * 大驼峰转小驼峰（出参转换）
 * 根据最新的返回参数结构转换
 */
export const convertResultToLowerCamel = (result: DRGGroupResult): DRGGroupResultLowerCamel => {
  const data = result.result || (result as any).result || result as any;
  
  // 解析最新的返回参数结构
  const complicationInfo = data?.complicationInfo || data?.ComplicationInfo || [];
  const drgInfo = data?.drgInfo || data?.DrgInfo || [];
  
  // 获取第一个DRG作为主要展示
  const primaryDRG = drgInfo.length > 0 ? drgInfo[0] : null;
  
  // 判断合并症状态
  const hasComplication = complicationInfo.length > 0;
  
  // 解析医疗机构算法信息
  const hospAlgorithmInfo = data?.hospAlgorithmInfo || data?.HospAlgorithmInfo || [];
  
  return {
    errorCode: result.errorCode,
    errorMessage: result.errorMessage,
    // DRG相关信息
    code: primaryDRG?.code || primaryDRG?.Code || '',
    desc: primaryDRG?.desc || primaryDRG?.Desc || '',
    drg: primaryDRG?.code || primaryDRG?.Code || '',
    drgDesc: primaryDRG?.desc || primaryDRG?.Desc || '',
    // MDC信息
    mdc: data?.mdc || data?.MDC || '',
    mdcDesc: data?.mdcDesc || data?.MDCDesc || '',
    // 权重和费用信息
    weight: data?.weight || data?.Weight || 0,
    benchmarkCost: data?.benchmarkCost || data?.BenchmarkCost || 0,
    riskLevel: data?.riskLevel || data?.RiskLevel || '低',
    // 合并症信息
    ccFlag: hasComplication,
    mccFlag: false, // 新结构中暂未明确MCC标识
    // 合并症信息数组
    complicationInfo: complicationInfo,
    // DRG信息数组
    drgInfo: drgInfo,
    // 医疗机构算法信息数组
    hospAlgorithmInfo: hospAlgorithmInfo,
    checkTime: data?.checkTime || data?.CheckTime || new Date().toLocaleString(),
  };
};

/**
 * 统一分组入参类型
 * 所有分组场景的入参都基于此类型
 */
export interface DRGGroupParams {
  /** 
   * 主诊断ICD-10编码（必填）
   * 与DiseInfo中MainFlag=1的诊断对应
   * 示例：I21.0
   */
  MainDiagnosisCode: string;

  /**
   * 诊断信息数组（ICD-10）
   * 可选，最多支持多个诊断
   */
  DiseInfo?: DiagnosisInfo[];

  /**
   * 主手术/操作ICD-9-CM-3编码
   * 与OprnInfo中MainFlag=1的手术对应
   */
  MainOperationCode?: string;

  /**
   * 手术/操作信息数组（ICD-9-CM-3）
   * 可选
   */
  OprnInfo?: OperationInfo[];

  /**
   * 性别：1=男, 2=女
   * 默认：1
   */
  Sex?: '1' | '2' | string;

  /**
   * 年龄（岁）
   * 默认：0
   */
  Age?: number;

  /**
   * 新生儿出生天数（0-28）
   * 有值时会自动设置NewbornFlag=1
   */
  AgeGroupDays?: number;

  /**
   * 新生儿标志：1=是, 0=否
   * 默认根据AgeGroupDays自动计算
   */
  NewbornFlag?: '1' | '0' | string;

  /**
   * 有创呼吸机使用时长（小时）
   * ≥96小时会进入MDCA先期分组
   * 默认：0
   */
  RespiratorTime?: number;

  /**
   * ECMO标志：1=是, 0=否
   * 有ECMO会进入MDCA先期分组
   * 默认：0
   */
  ECMOFlag?: '1' | '0' | string;

  /**
   * 器官移植标志：1=是, 0=否
   * 有移植会进入MDCA先期分组
   * 默认：0
   */
  TransplantFlag?: '1' | '0' | string;

  /**
   * 骨髓移植标志：1=是, 0=否
   * 有移植会进入MDCA先期分组
   * 默认：0
   */
  MarrowTransplantFlag?: '1' | '0' | string;

  /**
   * HIV感染标志：1=是, 0=否
   * 有HIV会进入MDCY先期分组
   * 默认：0
   */
  HIVFlag?: '1' | '0' | string;

  /**
   * 多发创伤等级（0-5）
   * ≥2级会进入MDCZ先期分组
   * 默认：0
   */
  TraumaLevel?: number;

  /**
   * 科室编码或名称
   * 可选
   */
  Department?: string;

  /**
   * 离院方式
   * 可选
   */
  DischargeType?: string;

  /**
   * 住院天数
   * 可选
   */
  HospitalDays?: number;

  /**
   * 总费用
   * 可选
   */
  TotalCost?: number;

  /**
   * 体重（新生儿用，单位：克）
   * 可选
   */
  Weight?: number;

  /**
   * 病案ID（用于批量分组时关联）
   * 可选，仅用于业务关联
   */
  MedicalRecordId?: string;

  /**
   * 住院号（用于业务关联）
   * 可选
   */
  AdmissionNo?: string;
}

/**
 * 诊断信息类型
 */
export interface DiagnosisInfo {
  /** 主诊断标志：1=主诊断 */
  MainFlag: number;
  /** 诊断序号 */
  DiagSn: number;
  /** 诊断代码（ICD-10） */
  DiagCode: string;
  /** 诊断名称 */
  DiagName?: string;
}

/**
 * 手术/操作信息类型
 */
export interface OperationInfo {
  /** 主手术标志：1=主手术 */
  MainFlag: '1' | '0' | string;
  /** 手术序号 */
  OprnSn: number;
  /** 手术代码（ICD-9-CM-3） */
  OprnCode: string;
  /** 手术名称 */
  OprnName?: string;
}

/**
 * 分组结果返回类型
 */
export interface DRGGroupResult {
  /** 错误码，0表示成功 */
  errorCode: string;

  /** 错误信息 */
  errorMessage: string;

  /** 分组结果（兼容嵌套结构） */
  result?: {
    /** MDC代码 */
    mdc?: string;
    /** MDC描述 */
    mdcDesc?: string;
    /** 合并症信息数组 */
    complicationInfo?: Array<{
      diagCode: string;
      diagName: string;
      complication: string;
      complicationDesc: string;
    }>;
    /** DRG信息数组 */
    drgInfo?: Array<{
      code: string;
      desc: string;
    }>;
    /** 分组时间 */
    checkTime?: string;
  };
}

/**
 * 病案数据转换为分组参数
 * 用于从病案首页数据转换为02010001接口入参
 * 
 * @param medicalRecord 病案首页数据
 * @returns 统一分组参数
 */
export function convertMedicalRecordToParams(medicalRecord: MedicalRecordData): DRGGroupParams {
  // 构建诊断数组
  const diagnoses: DiagnosisInfo[] = [];
  if (medicalRecord.principalDiagnosisCode) {
    diagnoses.push({
      MainFlag: 1,
      DiagSn: 1,
      DiagCode: medicalRecord.principalDiagnosisCode,
      DiagName: medicalRecord.principalDiagnosisName
    });
  }
  if (medicalRecord.secondaryDiagnoses && medicalRecord.secondaryDiagnoses.length > 0) {
    medicalRecord.secondaryDiagnoses.forEach((diag, index) => {
      diagnoses.push({
        MainFlag: 0,
        DiagSn: index + 2,
        DiagCode: diag.code,
        DiagName: diag.name
      });
    });
  }

  // 构建手术数组
  const operations: OperationInfo[] = [];
  if (medicalRecord.principalProcedureCode) {
    operations.push({
      MainFlag: '1',
      OprnSn: 1,
      OprnCode: medicalRecord.principalProcedureCode,
      OprnName: medicalRecord.principalProcedureName
    });
  }
  if (medicalRecord.secondaryProcedures && medicalRecord.secondaryProcedures.length > 0) {
    medicalRecord.secondaryProcedures.forEach((op, index) => {
      operations.push({
        MainFlag: '0',
        OprnSn: index + 2,
        OprnCode: op.code,
        OprnName: op.name
      });
    });
  }

  // 自动判断新生儿
  const age = medicalRecord.age || 0;
  const ageGroupDays = medicalRecord.ageGroupDays || 0;
  const isNewborn = ageGroupDays > 0 && ageGroupDays <= 28;

  return {
    MainDiagnosisCode: medicalRecord.principalDiagnosisCode || '',
    DiseInfo: diagnoses.length > 0 ? diagnoses : undefined,
    MainOperationCode: medicalRecord.principalProcedureCode || '',
    OprnInfo: operations.length > 0 ? operations : undefined,
    Sex: medicalRecord.gender || '1',
    Age: age,
    AgeGroupDays: ageGroupDays,
    NewbornFlag: isNewborn ? '1' : '0',
    RespiratorTime: medicalRecord.respiratorTime || 0,
    ECMOFlag: medicalRecord.ecmoFlag ? '1' : '0',
    TransplantFlag: medicalRecord.transplantFlag ? '1' : '0',
    MarrowTransplantFlag: medicalRecord.marrowTransplantFlag ? '1' : '0',
    HIVFlag: medicalRecord.hivFlag ? '1' : '0',
    TraumaLevel: medicalRecord.traumaLevel || 0,
    Department: medicalRecord.deptCode || medicalRecord.deptName || '',
    HospitalDays: medicalRecord.hospitalDays || 0,
    TotalCost: medicalRecord.totalCost || 0,
    MedicalRecordId: medicalRecord.id || '',
    AdmissionNo: medicalRecord.admissionNo || ''
  };
}

/**
 * 结算清单数据转换为分组参数
 * 用于从结算清单数据转换为02010001接口入参
 * 
 * @param settlement 结算清单数据
 * @returns 统一分组参数
 */
export function convertSettlementToParams(settlement: SettlementData): DRGGroupParams {
  // 构建诊断数组
  const diagnoses: DiagnosisInfo[] = [];
  if (settlement.principalDiagnosisCode) {
    diagnoses.push({
      MainFlag: 1,
      DiagSn: 1,
      DiagCode: settlement.principalDiagnosisCode,
      DiagName: settlement.principalDiagnosisName
    });
  }
  if (settlement.secondaryDiagnoses && settlement.secondaryDiagnoses.length > 0) {
    settlement.secondaryDiagnoses.forEach((diag, index) => {
      diagnoses.push({
        MainFlag: 0,
        DiagSn: index + 2,
        DiagCode: diag.code,
        DiagName: diag.name
      });
    });
  }

  // 构建手术数组
  const operations: OperationInfo[] = [];
  if (settlement.principalProcedureCode) {
    operations.push({
      MainFlag: '1',
      OprnSn: 1,
      OprnCode: settlement.principalProcedureCode,
      OprnName: settlement.principalProcedureName
    });
  }
  if (settlement.secondaryProcedures && settlement.secondaryProcedures.length > 0) {
    settlement.secondaryProcedures.forEach((op, index) => {
      operations.push({
        MainFlag: '0',
        OprnSn: index + 2,
        OprnCode: op.code,
        OprnName: op.name
      });
    });
  }

  const ageGroupDays = settlement.ageGroupDays || 0;
  const isNewborn = ageGroupDays > 0 && ageGroupDays <= 28;

  return {
    MainDiagnosisCode: settlement.principalDiagnosisCode || '',
    DiseInfo: diagnoses.length > 0 ? diagnoses : undefined,
    MainOperationCode: settlement.principalProcedureCode || '',
    OprnInfo: operations.length > 0 ? operations : undefined,
    Sex: settlement.gender || '1',
    Age: settlement.age || 0,
    AgeGroupDays: ageGroupDays,
    NewbornFlag: isNewborn ? '1' : '0',
    RespiratorTime: settlement.respiratorTime || 0,
    ECMOFlag: settlement.ecmoFlag ? '1' : '0',
    TransplantFlag: settlement.transplantFlag ? '1' : '0',
    MarrowTransplantFlag: settlement.marrowTransplantFlag ? '1' : '0',
    HIVFlag: settlement.hivFlag ? '1' : '0',
    TraumaLevel: settlement.traumaLevel || 0,
    Department: settlement.deptCode || settlement.deptName || '',
    HospitalDays: settlement.hospitalDays || 0,
    TotalCost: settlement.totalCost || 0,
    MedicalRecordId: settlement.id || '',
    AdmissionNo: settlement.admissionNo || ''
  };
}

/**
 * 病案首页数据类型
 */
export interface MedicalRecordData {
  id?: string;
  admissionNo?: string;
  
  // 诊断信息
  principalDiagnosisCode?: string;
  principalDiagnosisName?: string;
  secondaryDiagnoses?: { code: string; name: string }[];
  
  // 手术信息
  principalProcedureCode?: string;
  principalProcedureName?: string;
  secondaryProcedures?: { code: string; name: string }[];
  
  // 患者信息
  gender?: string;
  age?: number;
  ageGroupDays?: number;
  respiratorTime?: number;
  ecmoFlag?: boolean;
  transplantFlag?: boolean;
  marrowTransplantFlag?: boolean;
  hivFlag?: boolean;
  traumaLevel?: number;
  
  // 科室信息
  deptCode?: string;
  deptName?: string;
  hospitalDays?: number;
  totalCost?: number;
  weight?: number;
}

/**
 * 结算清单数据类型
 */
export interface SettlementData {
  id?: string;
  admissionNo?: string;
  
  // 诊断信息
  principalDiagnosisCode?: string;
  principalDiagnosisName?: string;
  secondaryDiagnoses?: { code: string; name: string }[];
  
  // 手术信息
  principalProcedureCode?: string;
  principalProcedureName?: string;
  secondaryProcedures?: { code: string; name: string }[];
  
  // 患者信息
  gender?: string;
  age?: number;
  ageGroupDays?: number;
  respiratorTime?: number;
  ecmoFlag?: boolean;
  transplantFlag?: boolean;
  marrowTransplantFlag?: boolean;
  hivFlag?: boolean;
  traumaLevel?: number;
  
  // 科室信息
  deptCode?: string;
  deptName?: string;
  hospitalDays?: number;
  totalCost?: number;
}

/**
 * 构建分组路径显示字符串
 * @param result 分组结果
 * @returns 分组路径字符串
 */
export function buildGroupingPath(result: DRGGroupResult['result'] | null): string {
  if (!result) return '';
  
  // 从结果中获取MDC
  const mdc = result.mdc || '-';
  
  // 从DRG数组中获取第一个代码
  const drgArray = result.drgInfo || [];
  const drg = drgArray.length > 0 ? drgArray[0].code : '-';
  
  // 新结构中没有ADRG，直接显示MDC → DRG
  return `${mdc} → ${drg}`;
}

/**
 * 获取先期分组说明
 * @param params 分组参数
 * @returns 先期分组说明
 */
export function getPreMDCDescription(params: DRGGroupParams): string {
  if (params.TransplantFlag === '1') {
    return 'MDCA - 器官移植病例（先期分组）';
  }
  if (params.MarrowTransplantFlag === '1') {
    return 'MDCA - 骨髓移植病例（先期分组）';
  }
  if (params.ECMOFlag === '1') {
    return 'MDCA - ECMO治疗病例（先期分组）';
  }
  if ((params.RespiratorTime || 0) >= 96) {
    return 'MDCA - 呼吸机≥96小时（先期分组）';
  }
  if (params.NewbornFlag === '1' || (params.AgeGroupDays || 0) > 0) {
    return 'MDCP - 新生儿疾病（先期分组）';
  }
  if (params.HIVFlag === '1') {
    return 'MDCY - HIV感染病例（先期分组）';
  }
  if ((params.TraumaLevel || 0) >= 2) {
    return 'MDCZ - 多发严重创伤（先期分组）';
  }
  return '常规MDC - 通过主诊断匹配';
};

// ========== 小驼峰类型定义（前端使用） ==========

/**
 * 统一分组入参（小驼峰格式）
 */
export interface DRGGroupParamsLowerCamel {
  /** 主诊断ICD-10编码（必填） */
  mainDiagnosisCode: string;
  /** 主手术ICD-9-CM-3编码 */
  mainOperationCode?: string;
  /** 诊断信息数组 */
  diseInfo?: DiagnosisInfoLowerCamel[];
  /** 手术/操作信息数组 */
  oprnInfo?: OperationInfoLowerCamel[];
  /** 性别：1=男, 2=女 */
  sex?: string;
  /** 年龄（岁） */
  age?: number;
  /** 新生儿天数（0-28） */
  ageGroupDays?: number;
  /** 新生儿标志：1=是, 0=否 */
  newbornFlag?: string;
  /** 呼吸机时长（小时） */
  respiratorTime?: number;
  /** ECMO标志：1=是, 0=否 */
  ecmoFlag?: string;
  /** 器官移植标志：1=是, 0=否 */
  transplantFlag?: string;
  /** 骨髓移植标志：1=是, 0=否 */
  marrowTransplantFlag?: string;
  /** HIV感染标志：1=是, 0=否 */
  hivFlag?: string;
  /** 创伤等级 */
  traumaLevel?: number;
  /** 科室 */
  department?: string;
  /** 离院方式 */
  dischargeType?: string;
  /** 住院天数 */
  hospitalDays?: number;
  /** 总费用 */
  totalCost?: number;
  /** 体重（新生儿） */
  weight?: number;
  /** 病案ID */
  medicalRecordId?: string;
  /** 住院号 */
  admissionNo?: string;
  /** 医疗机构信息数组 */
  hospInfo?: HospInfoLowerCamel[];
  /** 分组方案年份（4位数字，如 2026），医疗机构信息不为空时必填 */
  groupYear?: number;
}

/**
 * 医疗机构信息（小驼峰）
 */
export interface HospInfoLowerCamel {
  /** HIS机构代码 */
  hisHospCode: string;
  /** 医疗机构代码 */
  code?: string;
  /** 医疗机构名称 */
  name?: string;
}

/**
 * 诊断信息（小驼峰）
 */
export interface DiagnosisInfoLowerCamel {
  /** 主诊断标志：1=主诊断 */
  mainFlag: number;
  /** 诊断序号 */
  diagSn: number;
  /** 诊断代码（ICD-10） */
  diagCode: string;
  /** 诊断名称 */
  diagName?: string;
}

/**
 * 手术/操作信息（小驼峰）
 */
export interface OperationInfoLowerCamel {
  /** 主手术标志：1=主手术 */
  mainFlag: string;
  /** 手术序号 */
  oprnSn: number;
  /** 手术代码（ICD-9-CM-3） */
  oprnCode: string;
  /** 手术名称 */
  oprnName?: string;
}

/**
 * 分组结果（小驼峰格式）
 */
export interface DRGGroupResultLowerCamel {
  errorCode: string;
  errorMessage: string;
  /** DRG代码 */
  code: string;
  /** DRG描述 */
  desc: string;
  /** MDC代码 */
  mdc: string;
  /** MDC描述 */
  mdcDesc: string;
  /** DRG代码（同code） */
  drg: string;
  /** DRG描述（同desc） */
  drgDesc: string;
  /** 权重 */
  weight: number;
  /** 标杆费用 */
  benchmarkCost: number;
  /** 风险等级 */
  riskLevel: string;
  /** 是否合并症 */
  ccFlag: boolean;
  /** 是否严重合并症 */
  mccFlag: boolean;
  /** 分组时间 */
  checkTime: string;
  /** 合并症信息数组 */
  complicationInfo?: Array<{
    diagCode: string;
    diagName: string;
    complication: string;
    complicationDesc: string;
  }>;
  /** DRG信息数组 */
  drgInfo?: Array<{
    code: string;
    desc: string;
  }>;
  /** 医疗机构算法信息数组 */
  hospAlgorithmInfo?: Array<{
    totalCost: any;
    hisHospCode: string;
    hospCode: string;
    hospName: string;
    drg: string;
    drgDesc: string;
    points: string | number;
    pipValue: string | number;
    dgdov: string | number;
    payStandard: string | number;
    /** 实际使用的分组方案年份 */
    groupPlanYear?: string | number;
    /** 当前费用总额 */
    totalAmt?: string | number;
    /** 预估盈利 */
    preProfit?: string | number;
    /** 预估亏损 */
    preLoss?: string | number;
    /** 差异率 */
    discrepancyRate?: string | number;
  }>;
}
