Import SQLUSER

/// HIS数据同步引擎
/// 提供增量同步、全量同步、同步日志保存等功能
Class src.DRG.HISData.SyncEngine Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 增量同步
/// pHospID: 医院ID
/// pLookbackDays: 回溯天数（默认3天）
/// 返回：%DynamicObject，包含errorCode、errorMessage、successCount、failedCount
ClassMethod IncrementalSync(pHospCode As %String, pLookbackDays As %Integer = 3) As %Library.DynamicObject
{
    new (pHospCode, pLookbackDays, tLastSyncTime, tStartDays, tStartStr, tEndStr, tLogObj, tCallObj, tRtn, tMapRtn, tResultObj, tStatusCode, tMapRtnErrorMessage)
    set tResultObj = {"errorCode":"0","errorMessage":"","successCount":0,"failedCount":0}
    set tLogObj = {"taskName":"IncrementalSync","syncType":"incremental","startTime":""}
    try {
        // 1. 获取上次同步时间，计算开始日期
        set tLastSyncTime = ..GetLastSyncTime(pHospCode)
        if tLastSyncTime = "" 
        {
            set tStartDays = $h - 30          // 无记录时默认30天前
        } 
        else 
        {
            set tLastSyncH = $zdth(tLastSyncTime, 3)
            if tLastSyncH = "" 
            {
                set tStartDays = $h - 30
            } 
            else 
            {
                set tStartDays = $piece(tLastSyncH, ",", 1) - pLookbackDays
            }
        }
        
        set tStartStr = $zd(tStartDays, 3)    // yyyy-mm-dd
        set tEndStr = $zd($h, 3)              // 当前日期
        set tLogObj.startTime = tStartStr _ " 00:00:00"

        // 2. 构造调用 HisDataService.GetInpatientData 的参数对象
        set paramsArray = []
        do paramsArray.%Push({"stDate":(tStartStr), "endDate":(tEndStr)})
        set sessionArray = []
        do sessionArray.%Push({"hospCode":(pHospCode), "hospID":(pHospCode)})
        set tCallObj = {"params":(paramsArray), "session":(sessionArray)}

        // 3. 调用 HIS 数据获取服务
        set tRtn = ##class(src.DRG.HISData.HisDataService).GetInpatientData(tCallObj)
        if tRtn.errorCode '= "0" 
        {
            set tResultObj.errorCode = tRtn.errorCode
            set tResultObj.errorMessage = tRtn.errorMessage
            do ..SaveSyncLog(tLogObj, "failed", 0, 0, tResultObj.errorMessage)
            quit
        }

        // 4. 映射并保存数据
        set tMapRtn = ##class(src.DRG.HISData.DataMapper).MapAndSave(tRtn.result)
        set tResultObj.successCount = tMapRtn.successCount
        set tResultObj.failedCount = tMapRtn.failedCount
        do ..UpdateLastSyncTime(pHospID, tEndStr)   // 更新最后同步时间

        // 5. 记录同步日志
        set tStatusCode = $select(tMapRtn.failedCount > 0 : "partial", 1 : "success")
        do ..SaveSyncLog(tLogObj, tStatusCode, tMapRtn.successCount, tMapRtn.failedCount, tMapRtn.%Get("errorMessage"))

    } catch tException {
        set tResultObj.errorCode = "-1"
        set tResultObj.errorMessage = $System.Status.GetErrorText(tException.AsStatus(), "cn")
        do ..SaveSyncLog(tLogObj, "failed", 0, 0, tResultObj.errorMessage)
    }
    quit tResultObj
}

/// 全量同步
/// pHospID: 医院ID
/// pStartDate: 开始日期（YYYY-MM-DD）
/// pEndDate: 结束日期（YYYY-MM-DD）
/// 返回：%DynamicObject，包含errorCode、errorMessage、successCount、failedCount
ClassMethod FullSync(pHospID As %String, pStartDate As %String, pEndDate As %String) As %Library.DynamicObject
{
	new (tLogObj,tStartDate,tEndDate,tCurrentDate,tSegmentDays,tTotalSuccess,tTotalFailed,tSegmentEnd,tStartStr,tEndStr,tRtn,tMapRtn,tResultObj,tStatusCode)
	//set $zt="Error"
	set tResultObj={"errorCode":"0","errorMessage":"","successCount":"0","failedCount":"0"}
	try {
		set tLogObj={"taskName":"FullSync","syncType":"full","startTime":""}
		set tLogObj.startTime=$zd($h,5)_" "_$piece($zt($p($h,",",2)),":",1)_":00"
		set tStartDate=$zdateh(pStartDate,5)
		set tEndDate=$zdateh(pEndDate,5)
		set tCurrentDate=tStartDate
		set tSegmentDays=7
		set tTotalSuccess=0
		set tTotalFailed=0
		while tCurrentDate<=tEndDate {
			set tSegmentEnd=$select(tCurrentDate+tSegmentDays-1>tEndDate:tEndDate,1:tCurrentDate+tSegmentDays-1)
			set tStartStr=$zd(tCurrentDate,5)
			set tEndStr=$zd(tSegmentEnd,5)
			set tRtn=##class(src.DRG.HISData.HisDataService).GetInpatientData(tStartStr,tEndStr)
			if tRtn.errorCode="0" {
				set tMapRtn=##class(src.DRG.HISData.DataMapper).MapAndSave(tRtn.result)
				set tTotalSuccess=tTotalSuccess+tMapRtn.successCount
				set tTotalFailed=tTotalFailed+tMapRtn.failedCount
			} else {
				set tTotalFailed=tTotalFailed+1
			}
			set tCurrentDate=tSegmentEnd+1
		}
		set tResultObj.successCount=tTotalSuccess
		set tResultObj.failedCount=tTotalFailed
		set tStatusCode=$select(tTotalFailed>0:"partial",1:"success")
		do ..SaveSyncLog(tLogObj,tStatusCode,tTotalSuccess,tTotalFailed,"")
	} catch tException {
		set tResultObj.errorCode="-1"
		set tResultObj.errorMessage=$System.Status.GetErrorText(tException.AsStatus(),"cn")
		do ..SaveSyncLog(tLogObj,"failed",0,0,1,tResultObj.errorMessage)
	}
	quit tResultObj
}

/// 获取最后同步时间
/// pHospID: 医院ID
/// 返回：最后同步时间（%TimeStamp格式）
ClassMethod GetLastSyncTime(pHospID As %String) As %TimeStamp
{
	new (tLastSyncTime)
	//set $zt="Error"
	set tLastSyncTime=""
	try {
		set tLastSyncTime=$get(^BSHISSync("LastSyncTime",pHospID))
		if tLastSyncTime="" {
			set tLastSyncTime=""
		}
	} catch {
	}
	quit tLastSyncTime
}

/// 更新最后同步时间
/// pHospID: 医院ID
/// pTime: 同步时间
ClassMethod UpdateLastSyncTime(pHospID As %String, pTime As %String) As %Status
{
	new (tSC)
	//set $zt="Error"
	//set tSC=$$$OK()
	try {
		set ^BSHISSync("LastSyncTime",pHospID)=pTime
	} catch tException {
		set tSC=tException.AsStatus()
	}
	quit tSC
}

/// 保存同步日志
/// pLogObj: 日志对象（包含taskName、syncType、startTime）
/// pStatusCode: 状态码（success/failed/partial）
/// pSuccessCount: 成功记录数
/// pFailedCount: 失败记录数
/// pErrorMessage: 错误信息
ClassMethod SaveSyncLog(pLogObj As %Library.DynamicObject, pStatusCode As %String, pSuccessCount As %Integer, pFailedCount As %Integer, pErrorMessage As %String) As %Status
{
	new (tObj,tSaveSC,tSC)
	//set $zt="Error"
	//set tSC=$$OK()
	try {
		set tObj=##class(User.BSHISSyncLog).%New()
		set tObj.TaskName=pLogObj.taskName
		set tObj.SyncType=pLogObj.syncType
		set tObj.StartTime=pLogObj.startTime
		set tObj.EndTime=$zd($h,5)_" "_$piece($zt($p($h,",",2)),":",1)_":00"
		set tObj.StatusCode=pStatusCode
		set tObj.TotalCount=pSuccessCount+pFailedCount
		set tObj.SuccessCount=pSuccessCount
		set tObj.FailedCount=pFailedCount
		set tObj.ErrorMessage=pErrorMessage
		set tSaveSC=tObj.%Save()
		if $$$ISERR(tSaveSC) {
			set tSC=tSaveSC
		}
	} catch tException {
		set tSC=tException.AsStatus()
	}
	quit tSC
}

}
