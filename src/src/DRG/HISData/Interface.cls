Class src.DRG.HISData.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 获取HIS住院患者就诊信息、诊断信息、手术信息
/// code: 02010067		 
/// Input:{"params":[{"":""}]}
/// Debug
ClassMethod GetInpatientData(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.HISData.HisDataService).GetInpatientData(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 获取HIS住院患者费用信息
/// code: 02010068		 
/// Input:{"params":[{"":""}]}
/// Debug
ClassMethod GetInpatientFeeData(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.HISData.HisDataService).GetInpatientFeeData(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存HIS服务配置
/// code: 02010069		 
/// Input:{"params":[{"":""}]}
/// Debug
ClassMethod SaveHisServiceConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.HISData.ConfigService).SaveHisServiceConfig(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 获取HIS服务配置
/// code: 02010070		 
/// Input:{"params":[{"":""}]}
/// Debug
ClassMethod GetHisServiceConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.HISData.ConfigService).GetHisServiceConfig(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询已同步患者信息
/// code: 02010075		 
/// Input:{"params":[{"patientName":"","medicalRecordNo":"","admDateStart":"","admDateEnd":"","pageSize":20,"currentPage":1}]}
/// Debug
ClassMethod GetSyncedPatients(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.HISData.HisDataService).QuerySyncedPatients(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询患者详情（就诊信息、诊断列表、手术列表）
/// code: 02010076		 
/// Input:{"params":[{"admID":""}]}
/// Debug
ClassMethod GetPatientDetail(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.HISData.HisDataService).QueryPatientDetail(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询同步日志
/// code: 02010077		 
/// Input:{"params":[{"syncType":"","statusCode":"","startDate":"","endDate":"","pageSize":20,"currentPage":1}]}
/// Debug
ClassMethod GetSyncLogs(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.HISData.HisDataService).QuerySyncLogs(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-06-16
/// Description: 执行同步任务（手动）
/// code: 02010078		 
/// Input:{"params":[{"hospCode":"H34010400768","syncType":"incremental","lookbackDays":3}]}
/// Debug
ClassMethod ExecuteSyncTask(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.HISData.SyncTaskService).ExecuteSyncTask(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-06-16
/// Description: 查询同步配置
/// code: 02010079		 
/// Input:{"params":[{"hospCode":"H34010400768"}]}
/// Debug
ClassMethod GetSyncConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.HISData.SyncTaskService).GetSyncConfig(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-06-16
/// Description: 保存同步配置
/// code: 02010080		 
/// Input:{"params":[{"hospCode":"H34010400768","syncType":"incremental","frequency":"daily","scheduledTime":"00:00","lookbackDays":3,"enabled":true}]}
/// Debug
ClassMethod SaveSyncConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.HISData.SyncTaskService).SaveSyncConfig(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-06-16
/// Description: 查询同步状态
/// code: 02010081		 
/// Input:{"params":[{"hospCode":"H34010400768"}]}
/// Debug
ClassMethod GetSyncStatus(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.HISData.SyncTaskService).GetSyncStatus(jsonObj)
}

}
