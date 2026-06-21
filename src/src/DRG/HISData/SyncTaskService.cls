Import SQLUSER

/// HIS数据同步任务服务
Class src.DRG.HISData.SyncTaskService Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 执行同步任务（接口02010078）
/// pHospCode: 医院代码
/// pSyncType: 同步类型（incremental/full）
/// pLookbackDays: 回溯天数（增量同步用）
/// pStartDate: 开始日期（全量同步用）
/// pEndDate: 结束日期（全量同步用）
/// 返回：%DynamicObject，包含errorCode、errorMessage、result
ClassMethod ExecuteSyncTask(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
    //new (resultObj, params, hospCode, syncType, lookbackDays, startDate, endDate, rtn)
    set resultObj = {"errorCode":"-1","errorMessage":"","result":{}}
    try {
        set params = jsonObj.params.%Get(0)
        set hospCode = params.%Get("hospCode")
        // 使用 %Get 获取属性，并设置默认值
        set syncType = params.%Get("syncType", "incremental")
        set lookbackDays = +params.%Get("lookbackDays", 3)
        set startDate = params.%Get("startDate")
        set endDate = params.%Get("endDate")

        if hospCode = "" {
            set resultObj.errorCode = "04000001"
            set resultObj.errorMessage = "医院代码不能为空"
            quit
        }

        if syncType = "incremental" {
            // 增量同步
            set rtn = ##class(src.DRG.HISData.SyncEngine).IncrementalSync(hospCode, lookbackDays)
        } elseif syncType = "full" {
            // 全量同步
            if startDate = "" || endDate = "" {
                set resultObj.errorCode = "04000002"
                set resultObj.errorMessage = "全量同步必须指定开始和结束日期"
                quit
            }
            set rtn = ##class(src.DRG.HISData.SyncEngine).FullSync(hospCode, startDate, endDate)
        } else {
            set resultObj.errorCode = "04000003"
            set resultObj.errorMessage = "不支持的同步类型："_syncType
            quit
        }

        // 判断返回值（假设 rtn 是动态对象）
        if rtn.%Get("errorCode") = "0" {
            set resultObj.errorCode = "0"
            set resultObj.errorMessage = "同步任务执行完成"
            set resultObj.result = rtn
        } else {
            set resultObj.errorCode = rtn.%Get("errorCode")
            set resultObj.errorMessage = rtn.%Get("errorMessage")
        }
    }
    catch tException {
        set resultObj.errorCode = "-1"
        set resultObj.errorMessage = $System.Status.GetErrorText(tException.AsStatus(), "cn")
    }
    quit resultObj
}

/// 查询同步配置（接口02010079）
ClassMethod GetSyncConfig(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
    //new (resultObj, params, hospCode, sql, stmt, sc, rs, configObj)
    set resultObj={"errorCode":"-1","errorMessage":"","result":{}}
    try {
        set params = jsonObj.params.%Get(0)
        set hospCode = params.hospCode

        if hospCode = "" {
            set resultObj.errorCode = "04000001"
            set resultObj.errorMessage = "医院代码不能为空"
            quit
        }

        set sql = "SELECT * FROM BS_HISSyncConfig WHERE HospCode = ?"
        set stmt = ##class(%SQL.Statement).%New()
        set sc = stmt.%Prepare(sql)
        if $$$ISERR(sc) {
            set resultObj.errorCode = "-1"
            set resultObj.errorMessage = "SQL准备失败："_$System.Status.GetErrorText(sc,"cn")
            quit
        }

        set rs = stmt.%Execute(hospCode)   // 结果集对象
        if rs.%Next() {
            set configObj = {
                "id": (rs.%Get("ID")),
                "hospCode": (rs.%Get("HospCode")),
                "syncType": (rs.%Get("SyncType")),
                "frequency": (rs.%Get("Frequency")),
                "scheduledTime": (rs.%Get("ScheduledTime")),
                "lookbackDays": (rs.%Get("LookbackDays")),
                "enabled": (rs.%Get("Enabled")),
                "lastSyncTime": (rs.%Get("LastSyncTime")),
                "status": (rs.%Get("Status")),
                "errorMessage": (rs.%Get("ErrorMessage"))
            }
            set resultObj.result = configObj
        } else {
            // 没有配置记录，返回默认配置
            set defaultConfig = {
                "hospCode": (hospCode),
                "syncType": "incremental",
                "frequency": "daily",
                "scheduledTime": "00:00",
                "lookbackDays": 3,
                "enabled": false
            }
            set resultObj.result = defaultConfig
        }

        set resultObj.errorCode = "0"
    }
    catch tException {
        set resultObj.errorCode = "-1"
        set resultObj.errorMessage = $System.Status.GetErrorText(tException.AsStatus(),"cn")
    }
    quit resultObj
}

/// 保存同步配置（接口02010080）
ClassMethod SaveSyncConfig(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
    //new (resultObj, params, hospCode, configID, session, userID)
    //new (sql, stmt, sc, rs, existsID, configData, insObj, rtn)
    set resultObj={"errorCode":"-1","errorMessage":"","result":{}}
    try {
        // 参数检查
        if '$IsObject(jsonObj) || '$IsObject(jsonObj.params) || '$IsObject(jsonObj.session) {
            set resultObj.errorCode="04000001"
            set resultObj.errorMessage="无效的请求参数"
            quit
        }
        set params = jsonObj.params.%Get(0)
        set session = jsonObj.session.%Get(0)
        set hospCode = params.hospCode
        set configID = params.id
        set userID = session.userID

        if hospCode = "" {
            set resultObj.errorCode = "04000001"
            set resultObj.errorMessage = "医院代码不能为空"
            quit
        }

        // 查询是否存在配置
        set existsID = ""
        set sql = "SELECT ID FROM BS_HISSyncConfig WHERE HospCode = ?"
        set stmt = ##class(%SQL.Statement).%New()
        set sc = stmt.%Prepare(sql)
        if $$$ISERR(sc) {
            set resultObj.errorCode = "-1"
            set resultObj.errorMessage = "SQL准备失败："_$System.Status.GetErrorText(sc,"cn")
            quit
        }
        set rs = stmt.%Execute(hospCode)
        if rs.%Next() {
            set existsID = rs.%Get("ID")
        }

        // 构建配置数据（日期时间修正）
        set configData = {
            "HospCode": (hospCode),
            "SyncType": (params.syncType),
            "Frequency": (params.frequency),
            "ScheduledTime": (params.scheduledTime),
            "LookbackDays": (params.lookbackDays),
            "Enabled": (params.enabled),
            "UpdateUserDr": (userID),
            "UpdateDate": (+$h)          // 只取日期部分
        }

        if existsID = "" {
            set configData.ID = ""
            set configData.CreateUserDr = userID
            set configData.CreateDate = (+$h)      // 只取日期部分
            set configData.CreateTime = $p($h,",",2) // 时间秒数（若字段为 %Time）
        } else {
            set configData.ID = existsID
        }

        set insObj = {"className":"User.BSHISSyncConfig","updateUserID":(userID),"data":[]}
        do insObj.data.%Push(configData)

        if existsID = "" {
            set rtn = ##class(src.util.operatetable).Insert(.insObj)
        } else {
            set rtn = ##class(src.util.operatetable).Update(.insObj)
        }

        if rtn.errorCode '= 0 {
            set resultObj.errorCode = rtn.errorCode
            set resultObj.errorMessage = rtn.errorMessage
            quit
        }

        set resultObj.errorCode = "0"
        set resultObj.errorMessage = "同步配置保存成功"
    }
    catch tException {
        set resultObj.errorCode = "-1"
        set resultObj.errorMessage = $System.Status.GetErrorText(tException.AsStatus(),"cn")
    }
    quit resultObj
}

/// 查询同步状态（接口02010081）
ClassMethod GetSyncStatus(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
	new (resultObj, params, hospCode, sql, rset, sc)
	set resultObj={"errorCode":"-1","errorMessage":"","result":{}}
	try
	{
		set params=jsonObj.params.%Get(0)
		set hospCode=params.hospCode
		
		if hospCode="" {
			set resultObj.errorCode="04000001"
			set resultObj.errorMessage="医院代码不能为空"
			quit
		}
		
		///查询配置表中的状态
		set sql="SELECT Status, LastSyncTime, ErrorMessage FROM BS_HISSyncConfig WHERE HospCode = ?"
		set rset=##class(%SQL.Statement).%New()
		set sc=rset.%Prepare(sql)
		if $$$ISERR(sc) 
		{
			set resultObj.errorCode="-1"
			set resultObj.errorMessage="SQL准备失败："_$System.Status.GetErrorText(sc,"cn")
			quit
		}
		
		set rsetResult=rset.%Execute(hospCode)
		if rsetResult.%Next() 
		{
			set statusObj={"status":(rset.%Get("Status")),
			             "lastSyncTime":(rset.%Get("LastSyncTime")),
			             "lastSyncStatus":(""),
			             "errorMessage":(rset.%Get("ErrorMessage"))}
			set resultObj.result=statusObj
		} 
		else 
		{
			///没有配置记录
			set statusObj={"status":"idle",
			             "lastSyncTime":"",
			             "lastSyncStatus":"",
			             "errorMessage":""}
			set resultObj.result=statusObj
		}
		
		set resultObj.errorCode="0"
	}
	catch tException {
		set resultObj.errorCode="-1"
		set resultObj.errorMessage=$System.Status.GetErrorText(tException.AsStatus(),"cn")
	}
	quit resultObj
}

}
