/**
 * 基础数据管理接口
 * 
 * 包含ICD编码映射和ICD编码查询相关接口
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

// ========== ICD编码映射 (02010022, 02010023) ==========

/** ICD编码映射记录 */
export interface IcdMappingItem {
  id: string;
  code: string;
  descripts: string;
  icd: string;
  icdDesc: string;
  provinceId: string;
  provinceDesc: string;
  cityId: string;
  cityDesc: string;
  versionNo: string;
  updateDate: string;
  updateTime: string;
  updateUserDr: string;
  updateUserDesc: string;
  identification: string;
  remark: string;
}

/** 查询映射关系参数 */
export interface QueryIcdMappingParams {
  id?: string;
  code?: string;
  descripts?: string;
  icd?: string;
  icdDesc?: string;
  provinceID?: string;
  cityID?: string;
  versionNo?: string;
}

/** 保存映射关系参数 */
export interface SaveIcdMappingParams {
  id?: string;
  code: string;
  descripts: string;
  icd: string;
  icdDesc: string;
  versionNo: string;
  provinceID: string;
  cityID: string;
  updateUserID?: string;
}

/** 医保ICD编码记录 */
export interface MedInsuIcdItem {
  id: string;
  dictId: string;
  code: string;
  desc: string;
  startDate: string;
  stopDate: string;
  provinceId: string;
  provinceDesc: string;
  cityId: string;
  cityDesc: string;
  identification: string;
  statusDesc: string;
}

/** 查询医保ICD编码参数 */
export interface QueryMedInsuIcdParams {
  versionNo: string;
  provinceId: string;
  cityId: string;
  code?: string;
  desc?: string;
  status?: string;
}

/** 查询ICD编码映射关系 (02010025) */
export const queryIcdMapping = (
  params: QueryIcdMappingParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<IcdMappingItem>>> => {
  return invoke('02010025', [params], undefined, pagination);
};

/** 保存ICD编码映射关系 (02010023) */
export const saveIcdMapping = (
  params: SaveIcdMappingParams
): Promise<ApiResponse> => {
  return invoke('02010023', [params]);
};

/** 删除ICD编码映射关系 (02010023) */
export const deleteIcdMapping = (
  id: string
): Promise<ApiResponse> => {
  return invoke('02010023', [{ id }]);
};

/** 查询医保ICD编码信息 (02010022) */
export const queryMedInsuIcdInfo = (
  params: QueryMedInsuIcdParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<MedInsuIcdItem>>> => {
  return invoke('02010022', [params], undefined, pagination);
};

// ========== ICD编码查询 (02010037) ==========

/** ICD编码信息记录 */
export interface IcdInfoItem {
  id: string;
  code: string;
  desc: string;
  version: string;
  startDate: string;
  stopDate: string;
  provinceId: string;
  provinceDesc: string;
  cityId: string;
  cityDesc: string;
  createDate: string;
  createTime: string;
  createUserDr: string;
  createUserDesc: string;
  remark: string;
  statusDesc: string;
}

/** 查询ICD编码信息参数 */
export interface QueryIcdInfoParams {
  version: string;
  provinceID: string;
  cityID: string;
  code?: string;
  descripts?: string;
  status?: string;
}

/** 查询各地方版本ICD编码信息 (02010037) */
export const queryIcdInfo = (
  params: QueryIcdInfoParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<IcdInfoItem>>> => {
  return invoke('02010037', [params], undefined, pagination);
};

// ========== ADRG分组规则维护 (02010016, 02010017, 02010018) ==========

/** ADRG规则记录 */
export interface AdrgRuleItem {
  id: string;
  adrg: string;
  adrgDesc: string;
  principalDiagnosis: string;
  principalDiagnosisName: string;
  secondaryDiagnosis: string;
  secondaryDiagnosisName: string;
  thirdlyDiagnosis: string;
  thirdlyDiagnosisName: string;
  majorProcedure: string;
  majorProcedureName: string;
  secondaryProcedure: string;
  secondaryProcedureName: string;
  thirdlyProcedure: string;
  thirdlyProcedureName: string;
  unionFlag: string;
  segmentationFlag: string;
  selectionCriteria: string;
  provinceId: string;
  provinceDesc: string;
  cityId: string;
  cityDesc: string;
  startDate: string;
  stopDate: string;
  statusDesc: string;
}

/** 保存ADRG规则参数 */
export interface SaveAdrgRuleParams {
  id?: string;
  adrg: string;
  adrgDesc: string;
  principalDiagnosis: string;
  principalDiagnosisName: string;
  secondaryDiagnosis: string;
  secondaryDiagnosisName: string;
  thirdlyDiagnosis: string;
  thirdlyDiagnosisName: string;
  majorProcedure: string;
  majorProcedureName: string;
  secondaryProcedure: string;
  secondaryProcedureName: string;
  thirdlyProcedure: string;
  thirdlyProcedureName: string;
  unionFlag: string;
  segmentationFlag: string;
  selectionCriteria: string;
  provinceId: string;
  cityId: string;
  startDate: string;
  stopDate: string;
}

/** 查询ADRG规则参数 */
export interface QueryAdrgRuleParams {
  adrg?: string;
  adrgDesc?: string;
  status?: string;
}

/** 查询ADRG规则列表 (02010017) */
export const queryAdrgRules = (
  params: QueryAdrgRuleParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<AdrgRuleItem>>> => {
  return invoke('02010017', [params], undefined, pagination);
};

/** 保存ADRG规则 (02010016) */
export const saveAdrgRule = (
  params: SaveAdrgRuleParams
): Promise<ApiResponse> => {
  return invoke('02010016', [params]);
};

/** 删除ADRG规则 (02010018) */
export const deleteAdrgRule = (
  id: string
): Promise<ApiResponse> => {
  return invoke('02010018', [{ id }]);
};

// ========== DRG核心算法配置维护 (02010032, 02010033, 02010034) ==========

/** DRG核心算法配置记录 */
export interface CoreAlgorithmItem {
  id: string;
  drg: string;
  drgDesc: string;
  points: string;
  pipValue: string;
  PipValue?: string;
  pIPValue?: string;
  dgdov: string;
  payStandard: string;
  PayStandard?: string;
  pay_standard?: string;
  insuType: string;
  mdtrtArea: string;
  medinsLv: string;
  provinceId: string;
  provinceID?: string;
  provinceDesc: string;
  cityId: string;
  cityID?: string;
  cityDesc: string;
  startDate: string;
  stopDate: string;
  fixmedinsCode: string;
  fixmedinsName: string;
  identification: string;
  remark: string;
  statusDesc: string;
}

/** 保存DRG核心算法配置参数 */
export interface SaveCoreAlgorithmParams {
  id?: string;
  drg: string;
  drgDesc: string;
  points: string;
  pipValue: string;
  dgdov: string;
  payStandard: string;
  insuType: string;
  mdtrtArea: string;
  medinsLv: string;
  fixmedinsCode: string;
  fixmedinsName: string;
  provinceDr: string;
  cityID: string;
  startDate: any;
  stopDate: any;
  identification: string;
  remark: string;
}

/** 查询DRG核心算法配置参数 */
export interface QueryCoreAlgorithmParams {
  drg?: string;
  fixmedinsName?: string;
  fixmedinsCode?: string;
  provinceID?: string;
  cityID?: string;
  insuType?: string;
  status?: string;
}

/** 查询DRG核心算法配置 (02010033) */
export const queryCoreAlgorithm = (
  params: QueryCoreAlgorithmParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<CoreAlgorithmItem>>> => {
  return invoke('02010033', [params], undefined, pagination);
};

/** 保存DRG核心算法配置 (02010032) */
export const saveCoreAlgorithm = (
  params: SaveCoreAlgorithmParams
): Promise<ApiResponse> => {
  return invoke('02010032', [params]);
};

/** 删除DRG核心算法配置 (02010034) */
export const deleteCoreAlgorithm = (
  id: string
): Promise<ApiResponse> => {
  return invoke('02010034', [{ id }]);
};

// ========== DIP付费病种库 (02010019, 02010020, 02010021) ==========

/** DIP病种记录 */
export interface DipDiseaseItem {
  id: string;
  num: string;
  principalDiagnosis: string;
  principalDiagnosisName: string;
  majorProcedure: string;
  majorProcedureName: string;
  secondaryProcedure: string;
  secondaryProcedureName: string;
  provinceID: string;
  provinceDesc: string;
  cityID: string;
  cityDesc: string;
  startDate: string;
  stopDate: string;
  createDate: string;
  createTime: string;
  createUserDr: string;
  statusDesc: string;
}

/** 保存DIP病种参数 */
export interface SaveDipDiseaseParams {
  id?: string;
  num?: string;
  principalDiagnosis: string;
  principalDiagnosisName: string;
  majorProcedure: string;
  majorProcedureName: string;
  secondaryProcedure?: string;
  secondaryProcedureName?: string;
  provinceID: string;
  cityID: string;
  startDate: string;
  stopDate?: string;
}

/** 查询DIP病种参数 */
export interface QueryDipDiseaseParams {
  principalDiagnosisName?: string;
  majorProcedureName?: string;
  status?: string;
}

/** 查询DIP付费病种库 (02010020) */
export const queryDipDiseases = (
  params: QueryDipDiseaseParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<DipDiseaseItem>>> => {
  return invoke('02010020', [params], undefined, pagination);
};

/** 保存DIP付费病种库 (02010019) */
export const saveDipDisease = (
  params: SaveDipDiseaseParams
): Promise<ApiResponse> => {
  return invoke('02010019', [params]);
};

/** 删除DIP付费病种库 (02010021) */
export const deleteDipDisease = (
  id: string
): Promise<ApiResponse> => {
  return invoke('02010021', [{ id }]);
};

// ========== DRG基础数据维护 (02010010, 02010011, 02010012, 02010013, 02010014, 02010015) ==========

/** DRG基础数据主表记录 */
export interface BasicDataItem {
  id: string;
  dictID: string;  // 用于查询明细的关联ID
  insuCode: string;
  insuDesc: string;
  provinceDr?: string;  // 兼容旧字段
  provinceID?: string;  // 新字段名
  provinceName: string;
  provinceDesc: string;
  cityDr?: string;  // 兼容旧字段
  cityID?: string;  // 新字段名
  cityName: string;
  cityDesc: string;
  areaDr?: string;  // 兼容旧字段
  areaID?: string;  // 新字段名
  areaName: string;
  startDate: string;
  stopDate: string;
  createDate: string;
  createTime: string;
  identification: string;
  remark: string;
}

/** DRG基础数据明细记录 - 字段名与后端接口一致 */
export interface BasicDataSubItem {
  id: string;
  dictID: string;
  code: string;
  desc: string;
  identification: string;
  startDate: string;
  stopDate: string;
  statusDesc: string;
  createDate?: string;
  createTime?: string;
  remark?: string;
}

/** 保存/更新DRG基础数据参数 */
export interface SaveBasicDataParams {
  dictID?: string;  // id改为dictID，为空表示新增，非空表示更新
  insuCode: string;
  insuDesc: string;
  provinceID: string;
  cityID: string;
  areaID?: string;
  startDate: string;
  stopDate?: string;
  identification?: string;
  remark?: string;
}

/** 查询DRG基础数据参数 */
export interface QueryBasicDataParams {
  insuCode?: string;
  insuDesc?: string;
  provinceDr?: string;
  cityDr?: string;
  identification?: string;
  isActive?: string;
  status?: string;
}

/** 保存/更新DRG基础数据明细参数 */
export interface SaveBasicDataSubParams {
  id?: string;
  dictID: string;
  code: string;
  desc: string;
  identification?: string;
  startDate: string;
  stopDate?: string;
  remark?: string;
}

/** 查询DRG基础数据明细参数 */
export interface QueryBasicDataSubParams {
  dictID: string;
  Code?: string;
  desc?: string;
  status?: string;
  insuCode?: string;
}

/** 保存DRG基础数据 (02010010) */
export const saveBasicData = (
  params: SaveBasicDataParams
): Promise<ApiResponse> => {
  return invoke('02010010', [params]);
};

/** 查询DRG基础数据 (02010011) */
export const queryBasicData = (
  params: QueryBasicDataParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<BasicDataItem>>> => {
  return invoke('02010011', [params], undefined, pagination);
};

/** 删除DRG基础数据 (02010012) */
export const deleteBasicData = (
  id: string
): Promise<ApiResponse> => {
  return invoke('02010012', [{ id }]);
};

/** 保存DRG基础数据明细 (02010013) */
export const saveBasicDataSub = (
  params: SaveBasicDataSubParams
): Promise<ApiResponse> => {
  return invoke('02010013', [params]);
};

/** 查询DRG基础数据明细 (02010014) */
export const queryBasicDataSub = (
  params: QueryBasicDataSubParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<BasicDataSubItem>>> => {
  return invoke('02010014', [params], undefined, pagination);
};

/** 删除DRG基础数据明细 (02010015) */
export const deleteBasicDataSub = (
  id: string
): Promise<ApiResponse> => {
  return invoke('02010015', [{ id }]);
};

// ========== 医院查询 (03020113) ==========

/** 医院记录 */
export interface HospitalItem {
  id: string;
  fixmedinsCode: string;
  fixmedinsName: string;
  fixmedinsType: string;
  fixmedinsLv: string;
  provinceId: string;
  provinceDesc: string;
  cityId: string;
  cityDesc: string;
  countyId: string;
  countyDesc: string;
  status: string;
  statusDesc: string;
}

/** 查询医院参数 */
export interface QueryHospitalParams {
  fixmedinsName?: string;
  fixmedinsCode?: string;
  provinceId?: string;
  cityId?: string;
  countyId?: string;
  status?: string;
}

/** 查询医院列表 (03020113) */
export const queryHospitalList = (
  params: QueryHospitalParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<HospitalItem>>> => {
  return invoke('03020113', [params], undefined, pagination);
};

// ========== 省市区下拉数据 (01010007, 01010008) ==========

/** 省下拉数据项 */
export interface ProvinceItem {
  id: string;
  code: string;
  descripts: string;
  descriptsSPCode: string;
}

/** 市下拉数据项 */
export interface CityItem {
  id: string;
  code: string;
  descripts: string;
  descriptsSPCode: string;
}

/** 获取省下拉数据 (01010007) */
export const getProvinceData = (
  countryID?: string
): Promise<ApiResponse<ProvinceItem[]>> => {
  return invoke('01010007', [{ countryID: countryID || '' }]);
};

/** 获取市下拉数据 (01010008) */
export const getCityData = (
  provinceID: string
): Promise<ApiResponse<CityItem[]>> => {
  return invoke('01010008', [{ provinceID }]);
};

/** 区县下拉数据项 */
export interface AreaItem {
  id: string;
  code: string;
  descripts: string;
  descriptsSPCode: string;
}

/** 获取区县下拉数据 (01010009) */
export const getAreaData = (
  cityID: string
): Promise<ApiResponse<AreaItem[]>> => {
  return invoke('01010009', [{ cityID }]);
};

// ========== 政策类型下拉数据 (01010065) ==========

/** 政策类型下拉数据项 */
export interface PolicyTypeItem {
  id: string;
  code: string;
  descripts: string;
  descriptsSPCode: string;
}

/** 获取政策类型下拉数据 (01010065) */
export const getPolicyTypeData = (): Promise<ApiResponse<PolicyTypeItem[]>> => {
  return invoke('01010065', [{}]);
};

// ========== 医疗机构查询 (01010064) ==========

/** 医疗机构记录 */
export interface HospitalInfoItem {
  id: string;
  code: string;
  descripts: string;
  descriptsSPCode: string;
  MedinsLv?: string;
  medinsLv?: string;
}

/** 查询医疗机构参数 */
export interface QueryHospitalInfoParams {
  active: string;
  descripts: string;
}

/** 查询医疗机构信息 (01010064) */
export const queryHospitalInfo = (
  params: QueryHospitalInfoParams
): Promise<ApiResponse<HospitalInfoItem[]>> => {
  return invoke('01010064', [params]);
};

// ========== ICD编码导入 (02010038, 02010039, 02010040) ==========

/** ICD导入预览数据项 */
export interface IcdImportPreviewItem {
  rowNum: number;
  code: string;
  desc: string;
  version: string;
  startDate: string;
  stopDate: string;
  remark: string;
  status: 'valid' | 'duplicate' | 'invalid';
  statusDesc: string;
  errorMsg?: string;
}

/** ICD导入预览结果 */
export interface IcdImportPreviewResult {
  totalCount: number;
  validCount: number;
  invalidCount: number;
  duplicateCount: number;
  previewList: IcdImportPreviewItem[];
}

/** ICD导入结果 */
export interface IcdImportResult {
  totalCount: number;
  successCount: number;
  failCount: number;
  duplicateCount: number;
  newCount: number;
  failList: Array<{
    rowNum: number;
    code: string;
    errorMsg: string;
  }>;
  reportUrl?: string;
}

/** ICD导入参数 */
export interface IcdImportParams {
  provinceID: string;
  cityID: string;
  fileData: string;
  fileName: string;
}

/** 下载ICD导入模板 (02010040) */
export const downloadIcdTemplate = (): Promise<ApiResponse<{ fileName: string; fileData: string; contentType: string }>> => {
  return invoke('02010040', []);
};

/** ICD编码导入预览 (02010038) */
export const previewIcdImport = (
  params: IcdImportParams
): Promise<ApiResponse<IcdImportPreviewResult>> => {
  return invoke('02010038', [params]);
};

/** ICD编码确认导入 (02010039) */
export const confirmIcdImport = (
  params: IcdImportParams
): Promise<ApiResponse<IcdImportResult>> => {
  return invoke('02010039', [params]);
};

// ========== DRG目录信息 (02010041, 02010042, 02010043, 02010044, 02010045, 02010046) ==========

/** DRG目录信息记录 */
export interface HBDRGCataLogItem {
  id: string;
  code: string;
  descripts: string;
  provinceID: string;
  provinceDesc: string;
  cityID: string;
  cityDesc: string;
}

/** 查询DRG目录信息参数 */
export interface QueryHBDRGCataLogParams {
  code?: string;
  descripts?: string;
  provinceID?: string;
  cityID?: string;
}

/** 保存DRG目录信息参数 */
export interface SaveHBDRGCataLogParams {
  id?: string;
  code: string;
  descripts: string;
  provinceDr: string;
  cityDr: string;
  admvs: string;
}

/** 查询DRG目录信息 (02010041) */
export const queryHBDRGCataLog = (
  params: QueryHBDRGCataLogParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<HBDRGCataLogItem>>> => {
  return invoke('02010041', [params], undefined, pagination);
};

/** 保存DRG目录信息 (02010042) */
export const saveHBDRGCataLog = (
  params: SaveHBDRGCataLogParams
): Promise<ApiResponse> => {
  return invoke('02010042', [params]);
};

/** 删除DRG目录信息 (02010043) */
export const deleteHBDRGCataLog = (
  id: string
): Promise<ApiResponse> => {
  return invoke('02010043', [{ id }]);
};

// ========== DRG目录导入 (02010047, 02010048, 02010049) ==========

/** DRG目录导入预览数据项 */
export interface DrgImportPreviewItem {
  rowNum: number;
  code: string;
  descripts: string;
  admvs: string;
  status: 'valid' | 'duplicate' | 'invalid';
  errorMsg?: string;
}

/** DRG目录导入预览结果 */
export interface DrgImportPreviewResult {
  totalCount: number;
  validCount: number;
  invalidCount: number;
  duplicateCount: number;
  previewList: DrgImportPreviewItem[];
}

/** DRG目录导入结果 */
export interface DrgImportResult {
  totalCount: number;
  successCount: number;
  failCount: number;
  duplicateCount: number;
  newCount: number;
  failList: Array<{
    rowNum: number;
    code: string;
    errorMsg: string;
  }>;
  reportUrl?: string;
}

/** DRG目录导入参数 */
export interface DrgImportParams {
  provinceID: string;
  cityID: string;
  fileData: string;
  fileName: string;
}

/** 下载DRG目录导入模板 (02010049) */
export const downloadDrgTemplate = (): Promise<ApiResponse<{ fileName: string; fileData: string; contentType: string }>> => {
  return invoke('02010049', []);
};

/** DRG目录导入预览 (02010047) */
export const previewDrgImport = (
  params: DrgImportParams
): Promise<ApiResponse<DrgImportPreviewResult>> => {
  return invoke('02010047', [params]);
};

/** DRG目录确认导入 (02010048) */
export const confirmDrgImport = (
  params: DrgImportParams
): Promise<ApiResponse<DrgImportResult>> => {
  return invoke('02010048', [params]);
};

// ========== ADRG细分规则 (02010044, 02010045, 02010046) ==========

/** ADRG细分规则记录 */
export interface HBDRGSegmentationRulesItem {
  id: string;
  adrg: string;
  adrgDesc: string;
  admvs: string;
  unionFlag: string;
  segmentationFlag: string;
  selectionCriteria: string;
  provinceID: string;
  provinceDesc: string;
  cityID: string;
  cityDesc: string;
}

/** 查询ADRG细分规则参数 */
export interface QueryHBDRGSegmentationRulesParams {
  adrg?: string;
  adrgDesc?: string;
  provinceID?: string;
  cityID?: string;
}

/** 保存ADRG细分规则参数 */
export interface SaveHBDRGSegmentationRulesParams {
  id?: string;
  adrg: string;
  adrgDesc: string;
  provinceDr: string;
  cityDr: string;
  admvs: string;
  unionFlag: string;
  segmentationFlag: string;
  selectionCriteria?: string;
}

/** 查询ADRG细分规则 (02010044) */
export const queryHBDRGSegmentationRules = (
  params: QueryHBDRGSegmentationRulesParams,
  pagination: Pagination
): Promise<ApiResponse<PageResult<HBDRGSegmentationRulesItem>>> => {
  return invoke('02010044', [params], undefined, pagination);
};

/** 保存ADRG细分规则 (02010045) */
export const saveHBDRGSegmentationRules = (
  params: SaveHBDRGSegmentationRulesParams
): Promise<ApiResponse> => {
  return invoke('02010045', [params]);
};

/** 删除ADRG细分规则 (02010046) */
export const deleteHBDRGSegmentationRules = (
  id: string
): Promise<ApiResponse> => {
  return invoke('02010046', [{ id }]);
};
