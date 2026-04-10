Class src.DRG.BasicData.InterFace Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存DRG基础数据
/// code: 02010010
ClassMethod SaveDRGBasicData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.BasicData.DictionaryData).SaveDRGBasicData(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询DRG基础数据
/// 02010011
ClassMethod GetDRGBasicData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.BasicData.DictionaryData).GetDRGBasicData(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除DRG基础数据
/// 02010012
ClassMethod DeleteDRGBasicData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.BasicData.DictionaryData).DeleteDRGBasicData(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存DRG基础数据明细
/// 02010013
ClassMethod SaveDRGBasicDataSub(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.BasicData.DictionaryData).SaveDRGBasicDataSub(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询DRG基础数据明细
/// 02010014
ClassMethod GetDRGBasicDataSub(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).GetDRGBasicDataSub(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除DRG基础数据明细
/// 02010015
ClassMethod DeleteDRGBasicDataSub(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).DeleteDRGBasicDataSub(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存(ADRG)核心疾病诊断相关分组规则列表
/// 02010016
ClassMethod SaveDRGCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).SaveDRGCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询(ADRG)核心疾病诊断相关分组规则列表
/// 02010017
ClassMethod GetDRGCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).GetDRGCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除(ADRG)核心疾病诊断相关分组规则列表
/// 02010018
ClassMethod DeleteDRGCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).DeleteDRGCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存按病种分值(DIP)付费病种库(2.0版)核心病种
/// 02010019
ClassMethod SaveDIPCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).SaveDIPCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询按病种分值(DIP)付费病种库(2.0版)核心病种
/// 02010020
ClassMethod GetDIPCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).GetDIPCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除按病种分值(DIP)付费病种库(2.0版)核心病种
/// 02010021
ClassMethod DeleteDIPCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).DeleteDIPCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询医保ICD编码信息
/// 02010022
ClassMethod GetMedInsuICDInfo(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).GetMedInsuICDInfo(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询各地方版本ICD编码信息
/// 02010037
ClassMethod GetICDInfo(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).GetICDInfo(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: ICD编码导入预览（校验数据并返回预览结果）
/// 02010038
ClassMethod PreviewImportICD(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).PreviewImportICD(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 确认导入ICD编码信息
/// 02010039
ClassMethod ConfirmImportICD(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).ConfirmImportICD(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 下载ICD编码导入模板
/// 02010040
ClassMethod DownloadImportTemplate(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).DownloadImportTemplate(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存医保ICD编码映射关系
/// 02010023
ClassMethod UpdateICDMappingInfo(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).UpdateMappingInfo(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除医保ICD编码映射关系
/// 02010024
ClassMethod DeleteICDMappingInfo(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.ICDInfo).DeleteMappingInfo(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询医保ICD编码映射关系
/// 02010025
ClassMethod GetICDMappingInfo(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.ICDInfo).QueryMappingInfo(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存DRG核心算法配置
/// 02010032
ClassMethod UpdateDRGCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.CoreAlgorithm).UpdateDRGCoreAlgorithm(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询DRG核心算法配置
/// 02010033
ClassMethod GetDRGCoreAlgorithm(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.CoreAlgorithm).GetDRGCoreAlgorithm(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除DRG核心算法配置
/// 02010034
ClassMethod DeleteDRGCoreAlgorithm(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.CoreAlgorithm).DeleteDRGCoreAlgorithm(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 查询DRG目录信息
/// 02010041
ClassMethod GetDRGCataLogList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGCataLog).GetDRGCataLogList(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 保存/更新DRG目录信息
/// 02010042
ClassMethod SaveDRGCataLog(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGCataLog).SaveDRGCataLog(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 删除DRG目录信息
/// 02010043
ClassMethod DeleteDRGCataLog(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGCataLog).DeleteDRGCataLog(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 查询ADRG细分规则
/// 02010044
ClassMethod GetDRGSegmentationRulesList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGRSegmentationRules).GetDRGSegmentationRulesList(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 保存/更新ADRG细分规则
/// 02010045
ClassMethod SaveDRGSegmentationRules(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGRSegmentationRules).SaveDRGSegmentationRules(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 删除ADRG细分规则
/// 02010046
ClassMethod DeleteDRGSegmentationRules(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGRSegmentationRules).DeleteDRGSegmentationRules(jsonObj)
}

}
