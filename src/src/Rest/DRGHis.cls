 Invoke Extends %RegisteredObject
Class src.Rest.DRGHis
{

	/// HIS数据同步接口调度
	/// pCode: 接口编码（02010060、02010061、02010062、02010067）
	/// pParams: 接口参数数组
	/// pSession: 会话信息数组
	/// pPagination: 分页参数数组
	/// 返回：%DynamicObject（包含errorCode、errorMessage、result）
	ClassMethod Invoke(pCode As %String, pParams As %Library.DynamicArray, pSession As %Library.DynamicArray, pPagination As %Library.DynamicArray) As %Library.DynamicObject
	{
        new (pCode, pParams, pSession, pPagination)
        set $zt="Error"
        set tResultObj={"errorCode":"-1","errorMessage":"未知接口编码","result":{}}
        try {
            if pCode="02010060" {
                set tRtn=..TriggerHisSync(pParams,pSession)
                set tResultObj=tRtn
                quit
            }
            if pCode="02010061" {
                set tRtn=..QueryHisSyncLogs(pParams,pPagination)
                set tResultObj=tRtn
                quit
            }
            if pCode="02010062" {
                set tRtn=..QuerySyncedPatients(pParams,pPagination)
                set tResultObj=tRtn
                quit
            }
            if pCode="02010067" {
                set tRtn=..GetHisPatientAdmInfo(pParams)
                set tResultObj=tRtn
                quit
            }
        } catch tException {
            set tResultObj.errorCode="-1"
            set tResultObj.errorMessage=$System.Status.GetErrorText(tException.AsStatus(),"cn")
        }
        quit tResultObj
    Error
        set $zt=""
        set tResultObj.errorCode="-1"
        set tResultObj.errorMessage=$ze
        quit tResultObj
}

	/// 触发HIS数据同步（02010060）
	ClassMethod TriggerHisSync(pParams As %Library.DynamicArray, pSession As %Library.DynamicArray) As %Library.DynamicObject
	{
        new (pParams,pSession)
        set $zt="Error"
        set tResultObj={"errorCode":"0","errorMessage":"","result":{"taskId":""}}
        try {
            set tParamObj=pParams.%Get(0)
            set tSyncType=$get(tParamObj.syncType,"incremental")
            set tHospID=$get(tParamObj.hospID,"25")
            if tSyncType="incremental" {
                set tRtn=##class(src.DRG.HISData.SyncEngine).IncrementalSync(tHospID,3)
            } else {
                set tStartDate=$get(tParamObj.startDate,"")
                set tEndDate=$get(tParamObj.endDate,"")
                set tRtn=##class(src.DRG.HISData.SyncEngine).FullSync(tHospID,tStartDate,tEndDate)
            }
            if tRtn.errorCode="0" {
                set tResultObj.result.taskId="TASK"_$replace($zd($h,3)_$replace($zt($p($h,",",2)),":","")
            } else {
                set tResultObj.errorCode=tRtn.errorCode
                set tResultObj.errorMessage=tRtn.errorMessage
            }
        } catch tException {
            set tResultObj.errorCode="-1"
            set tResultObj.errorMessage=$System.Status.GetErrorText(tException.AsStatus(),"cn")
        }
        quit tResultObj
    Error
        set $zt=""
        set tResultObj.errorCode="-1"
        set tResultObj.errorMessage=$ze
        quit tResultObj
}

	/// 查询HIS同步日志（02010061）
	ClassMethod QueryHisSyncLogs(pParams As %Library.DynamicArray, pPagination As %Library.DynamicArray) As %Library.DynamicObject
	{
        new (pParams,pPagination)
        set $zt="Error"
        set tResultObj={"errorCode":"0","errorMessage":"","result":{"rows":[],"total":0}}
        try {
            set tSQL="SELECT * FROM BS_HIS_SyncLog WHERE 1=1"
            set tParamsObj=pParams.%Get(0)
            if $get(tParamsObj.syncType)'="" {
                set tSQL=tSQL_" AND SyncType='"_$get(tParamsObj.syncType)_"'"
            }
            if $get(tParamsObj.status)'="" {
                set tSQL=tSQL_" AND StatusCode='"_$get(tParamsObj.status)_"'"
            }
            set tStmt=##class(%SQL.Statement).%New()
            do tStmt.%Prepare(tSQL)
            set tRS=tStmt.%Execute()
            set tRows=[]
            set tCount=0
            while tRS.%Next() {
                set tCount=tCount+1
                set tRow={"id":""}
                set tRow.id=tRS.%Get("ID")
                set tRow.taskName=tRS.%Get("TaskName")
                set tRow.syncType=tRS.%Get("SyncType")
                set tRow.status=tRS.%Get("StatusCode")
                set tRow.totalCount=tRS.%Get("TotalCount")
                set tRow.successCount=tRS.%Get("SuccessCount")
                set tRow.failedCount=tRS.%Get("FailedCount")
                set tRow.startTime=tRS.%Get("StartTime")
                set tRow.endTime=tRS.%Get("EndTime")
                do tRows.%Push(tRow)
            }
            set tResultObj.result.rows=tRows
            set tResultObj.result.total=tCount
        } catch tException {
            set tResultObj.errorCode="-1"
            set tResultObj.errorMessage=$System.Status.GetErrorText(tException.AsStatus(),"cn")
        }
        quit tResultObj
    Error
        set $zt=""
        set tResultObj.errorCode="-1"
        set tResultObj.errorMessage=$ze
        quit tResultObj
}

	/// 查询已同步患者病案数据（02010062）
	ClassMethod QuerySyncedPatients(pParams As %Library.DynamicArray, pPagination As %Library.DynamicArray) As %Library.DynamicObject
	{
        new (pParams,pPagination)
        set $zt="Error"
        set tResultObj={"errorCode":"0","errorMessage":"","result":{"rows":[],"total":0}}
        try {
            set tSQL="SELECT p.AdmID,p.PatMedicalNo,p.PatName,p.AdmDateTime,p.InLocDesc,p.AdmDocDesc,d.MainDiagnosisCode,d.MainOperationCode,d.TotalCost FROM BS_HIS_PatAdm p LEFT JOIN BS_HIS_DRGParams d ON p.AdmID=d.AdmID WHERE p.Deleted=0"
            set tParamsObj=pParams.%Get(0)
            if $get(tParamsObj.patientName)'="" {
                set tSQL=tSQL_" AND p.PatName LIKE '%"_$get(tParamsObj.patientName)_"%'"
            }
            if $get(tParamsObj.medicalRecordNo)'="" {
                set tSQL=tSQL_" AND p.PatMedicalNo LIKE '%"_$get(tParamsObj.medicalRecordNo)_"%'"
            }
            set tStmt=##class(%SQL.Statement).%New()
            do tStmt.%Prepare(tSQL)
            set tRS=tStmt.%Execute()
            set tRows=[]
            set tCount=0
            while tRS.%Next() {
                set tCount=tCount+1
                set tRow={"admissionNo":"","medicalRecordNo":"","patientName":"","sex":"","age":0,"department":"","doctor":"","mainDiagnosisCode":"","mainDiagnosisName":"","totalCost":0}
                set tRow.admissionNo=tRS.%Get("AdmID")
                set tRow.medicalRecordNo=tRS.%Get("PatMedicalNo")
                set tRow.patientName=tRS.%Get("PatName")
                set tRow.department=tRS.%Get("InLocDesc")
                set tRow.doctor=tRS.%Get("AdmDocDesc")
                set tRow.mainDiagnosisCode=tRS.%Get("MainDiagnosisCode")
                set tRow.totalCost=tRS.%Get("TotalCost")
                do tRows.%Push(tRow)
            }
            set tResultObj.result.rows=tRows
            set tResultObj.result.total=tCount
        } catch tException {
            set tResultObj.errorCode="-1"
            set tResultObj.errorMessage=$System.Status.GetErrorText(tException.AsStatus(),"cn")
        }
        quit tResultObj
    Error
        set $zt=""
        set tResultObj.errorCode="-1"
        set tResultObj.errorMessage=$ze
        quit tResultObj
}

	/// 获取HIS住院患者就诊信息列表 (02010067)
	ClassMethod GetHisPatientAdmInfo(pParams As %Library.DynamicArray) As %Library.DynamicObject
	{
		new (pParams)
		set $zt="Error"
		set tResultObj={"errorCode":"-1","errorMessage":"","result":[]}
		try {
			set tParamObj=pParams.%Get(0)
			set tStDate=$get(tParamObj.stDate,"")
			set tEndDate=$get(tParamObj.endDate,"")
			if tStDate="" || tEndDate="" {
				set tResultObj.errorCode="05100129"
				set tResultObj.errorMessage="开始日期和结束日期不能为空"
				quit
			}
			set tRtn=##class(src.DRG.HISData.HisDataService).GetInpatientData(tStDate,tEndDate)
			if tRtn.errorCode="0" {
				set tResultObj.result=tRtn.result
				set tResultObj.errorCode="0"
				set tResultObj.errorMessage=""
			} else {
				set tResultObj.errorCode=tRtn.errorCode
				set tResultObj.errorMessage=tRtn.errorMessage
			}
		} catch tException {
			set tResultObj.errorCode="-1"
			set tResultObj.errorMessage=$System.Status.GetErrorText(tException.AsStatus(),"cn")
		}
		quit tResultObj
	Error:
		set $zt=""
		set tResultObj.errorCode="-1"
		set tResultObj.errorMessage=$ze
		quit tResultObj
	}

}
