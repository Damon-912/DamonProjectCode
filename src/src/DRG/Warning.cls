Import SQLUSER

/// 预警服务类
/// 提供预警规则管理、预警记录查询、预警处理等功能
/// 
/// 接口Code规范: 020101xx
/// 
/// 查询接口返回格式: {errorCode:"0", errorMessage:"", result:{rows:[], total:0}}
/// 分页参数从 pagination 中获取，查询条件从 params 中获取
Class src.DRG.Warning Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 设置成功返回结果（封装重复逻辑）
ClassMethod SetSuccessResult(code As %String, message As %String) As %Library.DynamicObject
{
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage=message

	set result={}
	set result.code=code
	set result.desc=message
	set result.checkTime=$ZDATETIME($HOROLOG,3)
    set resultObj.result=result
    
    quit resultObj
}

/// 设置错误返回结果（封装重复逻辑）
ClassMethod SetErrorResult(errorCode As %String, errorMsg As %String) As %Library.DynamicObject
{
	set resultObj={}
	set resultObj.errorCode= errorCode
	set resultObj.errorMessage= errorMsg

	set result={}
	set result.code=""
	set result.desc=""
	set result.checkTime= $ZDATETIME($HOROLOG,3)
    set resultObj.result= result
    
    quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询预警规则列表
/// Table:       BS_DRGWarningRule
/// Code:        02010101
/// Input:       {"params":[{}], "pagination":[{"pageSize":20,"currentPage":1}]}
/// Output:      {errorCode:"0", errorMessage:"", result:{rows:[], total:0}}
ClassMethod QueryWarningRules(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try
	{
        // 1. 获取分页参数
        if (jsonObj.%IsDefined("pagination")'=0) 
        {
            set pagationObj=jsonObj.pagination.%Get(0)
            set pageSize=pagationObj.pageSize
            set currentPage=pagationObj.currentPage
        }
        
        // 2. 获取查询条件
        set params=jsonObj.params.%Get(0)
        set ruleCode=params.ruleCode
        set ruleName=params.ruleName
        set ruleType=params.ruleType
        set isActive=params.isActive
        
        // 3. 构建查询SQL
        set sql =" SELECT ID,RuleCode,RuleName,RuleDesc,RuleType,ThresholdType,ThresholdValue,"
                _" MDCCode,ADRGCode,DRGCode,WarningLevel,IsActive,SeqNo,"
                _" CreateDate,CreateTime,Remark "
                _" FROM BS_DRGWarningRule WHERE 1=1"
        
        if (ruleCode'="")
        {
            set sql=sql_" AND RuleCode LIKE '%"_ruleCode_"%'" 
        }
        if (ruleName'="")
        {
            set sql=sql_" AND RuleName LIKE '%"_ruleName_"%'" 
        }
        if (ruleType'="")
        {
            set sql=sql_" AND RuleType = '"_ruleType_"'" 
        }
        if (isActive'="")
        {
            set sql=sql_" AND IsActive = '"_isActive_"'" 
        }
        
        set sql=sql_" ORDER BY SeqNo, ID"
        
        // 4. 执行查询
        set sqlObj=##class(%SQL.Statement).%New(1)
        set sc=sqlObj.%Prepare(sql)
        set result=sqlObj.%Execute()
        while result.%Next()	
        {
            set dataObj={}
            set dataObj.id=result.%Get("ID")
            set dataObj.ruleCode=result.%Get("RuleCode")
            set dataObj.ruleName=result.%Get("RuleName")
            set dataObj.ruleDesc=result.%Get("RuleDesc")
            set dataObj.ruleType=result.%Get("RuleType")
            set dataObj.thresholdType=result.%Get("ThresholdType")
            set dataObj.thresholdValue=result.%Get("ThresholdValue")
            set dataObj.mdcCode=result.%Get("MDCCode")
            set dataObj.adrgCode=result.%Get("ADRGCode")
            set dataObj.drgCode=result.%Get("DRGCode")
            set dataObj.warningLevel=result.%Get("WarningLevel")
            set dataObj.isActive=result.%Get("IsActive")
            set dataObj.seqNo=result.%Get("SeqNo")
            set dataObj.createDate=result.%Get("CreateDate") //$zd(result.%Get("CreateDate"),3)
            set dataObj.createTime=result.%Get("CreateTime") //$zt(result.%Get("CreateTime"),1)
            set dataObj.remark=result.%Get("Remark")
            
            set count=count+1
            // 分页处理：使用 continue 语句
            if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
            do dataArr.%Push(dataObj)
        }
        
        set resultObj.result.rows=dataArr
        set resultObj.result.total=count		
	}
    catch(e) 
    {
        set status=e.AsStatus()
        set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
        set errorInfo="查询预警规则列表异常：类="_$ClassName()_"，入参="_jsonObj.%ToJSON()_""
        set errorLogID=##class(src.Interface.Message).InsErrRecord("02010101",errorInfo,errorMessage)
        set resultObj={}
        set resultObj.errorCode="02010101"
        set resultObj.errorMessage="查询预警规则列表异常（日志ID："_errorLogID_"）："_errorMessage
    }

    quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 保存预警规则（新增/修改）
/// Table:       BS_DRGWarningRule
/// Code:        02010102
/// Input:       {"params":[{}]}
/// Output:      {errorCode:"0", errorMessage:"保存成功", result:{}}
ClassMethod SaveWarningRule(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"保存成功","result":{}}
	try
	{
        // 1. 获取参数
        set params=jsonObj.params.%Get(0)
        set ruleId=params.ruleId
        set ruleCode=params.ruleCode
        set ruleName=params.ruleName
        set ruleDesc=params.ruleDesc
        set ruleType=params.ruleType
        set thresholdType=params.thresholdType
        set thresholdValue=params.thresholdValue
        set mdcCode=params.mdcCode
        set adrgCode=params.adrgCode
        set drgCode=params.drgCode
        set warningLevel=params.warningLevel
        set isActive=params.isActive
        set seqNo=params.seqNo
        set remark=params.remark
        
        // 2. 必填参数校验
        if (ruleCode="") 
        {
            set resultObj.errorCode="-1"
            set resultObj.errorMessage="规则编码不能为空"
            quit 
        }
        if (ruleName="") 
        {
            set resultObj.errorCode="-1"
            set resultObj.errorMessage="规则名称不能为空"
            quit 
        }
        if (ruleType="") 
        {
            set resultObj.errorCode="-1"
            set resultObj.errorMessage="规则类型不能为空"
            quit 
        }
        
        // 3. 检查编码唯一性
        if (ruleId="") 
        {
            &sql(SELECT ID INTO :existId FROM BS_DRGWarningRule WHERE RuleCode = :ruleCode)
            if (SQLCODE = 0) && (existId '= "") 
            {
                set resultObj.errorCode="-2"
                set resultObj.errorMessage="规则编码已存在"
                quit 
            }
        }
        
        // 4. 保存数据
        if (ruleId="") 
        {
            // 新增
            set obj=##class(User.BSDRGWarningRule).%New()
            set obj.CreateDate=+$h
            set obj.CreateTime=$p($h,",",2)
        } 
        else 
        {
            // 修改
            set obj=##class(User.BSDRGWarningRule).%OpenId(ruleId)
            if (obj="") 
            {
                set resultObj.errorCode="-3"
                set resultObj.errorMessage="规则不存在"
                quit 
            }
        }
        
        set obj.RuleCode=ruleCode
        set obj.RuleName=ruleName
        set obj.RuleDesc=ruleDesc
        set obj.RuleType=ruleType
        set obj.ThresholdType=thresholdType
        set obj.ThresholdValue=thresholdValue
        set obj.MDCCode=mdcCode
        set obj.ADRGCode=adrgCode
        set obj.DRGCode=drgCode
        set obj.WarningLevel=warningLevel
        set obj.IsActive=isActive //$s(isActive="Y":1,isActive="1":1,isActive="是":1,1:0)
        set obj.SeqNo=seqNo
        set obj.UpdateDate=+$h
        set obj.UpdateTime=$p($h,",",2)
        set obj.Remark=remark
        
        set sc=obj.%Save()
        if ($$$ISOK(sc)) 
        {
            set resultObj.errorCode="0"
            set resultObj.errorMessage="保存成功"
        } 
        else 
        {
            set resultObj.errorCode="-4"
            set resultObj.errorMessage="保存失败"
        }
	}
    catch(e) 
    {
        set status=e.AsStatus()
        set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
        set errorInfo="保存预警规则异常：类="_$ClassName()_"，入参="_jsonObj.%ToJSON()_""
        set errorLogID=##class(src.Interface.Message).InsErrRecord("02010102",errorInfo,errorMessage)
        set resultObj={}
        set resultObj.errorCode="02010102"
        set resultObj.errorMessage="保存预警规则异常（日志ID："_errorLogID_"）："_errorMessage
    }

    quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 删除预警规则
/// Table:       BS_DRGWarningRule
/// Code:        02010105
/// Input:       {"params":[{"ruleId":"123"}]}
/// Output:      {errorCode:"0", errorMessage:"删除成功", result:{}}
ClassMethod DeleteWarningRule(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"删除成功","result":{}}
	try
	{
        set params=jsonObj.params.%Get(0)
        set ruleId=params.ruleId
        
        if (ruleId="") 
        {
            set resultObj.errorCode="-1"
            set resultObj.errorMessage="规则ID不能为空"
            quit 
        }
        
        // 检查是否存在关联的预警记录
        &sql(SELECT COUNT(*) INTO :cnt FROM BS_DRGWarningRecord WHERE Rule_Dr = :ruleId)
        if (cnt>0) 
        {
            set resultObj.errorCode="-2"
            set resultObj.errorMessage="该规则存在关联的预警记录，无法删除"
            quit 
        }
        
        &sql(DELETE FROM BS_DRGWarningRule WHERE ID = :ruleId)
        if (SQLCODE=0) 
        {
            set resultObj.errorCode="0"
            set resultObj.errorMessage="删除成功"
        } 
        else 
        {
            set resultObj.errorCode="-3"
            set resultObj.errorMessage="删除失败"
        }
	}
    catch(e) 
    {
        set status=e.AsStatus()
        set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
        set errorInfo="删除预警规则异常：类="_$ClassName()_"，入参="_jsonObj.%ToJSON()_""
        set errorLogID=##class(src.Interface.Message).InsErrRecord("02010105",errorInfo,errorMessage)
        set resultObj={}
        set resultObj.errorCode="02010105"
        set resultObj.errorMessage="删除预警规则异常（日志ID："_errorLogID_"）："_errorMessage
    }

    quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询预警记录列表
/// Table:       BS_DRGWarningRecord
/// Code:        02010103
/// Input:       {"params":[{}], "pagination":[{"pageSize":20,"currentPage":1}]}
/// Output:      {errorCode:"0", errorMessage:"", result:{rows:[], total:0}}
ClassMethod QueryWarningRecords(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try
	{
        // 1. 获取分页参数
        if (jsonObj.%IsDefined("pagination")'=0) 
        {
            set pagationObj=jsonObj.pagination.%Get(0)
            set pageSize=pagationObj.pageSize
            set currentPage=pagationObj.currentPage
        }
        
        // 2. 获取查询条件
        set params=jsonObj.params.%Get(0)
        set warningNo=params.warningNo
        set ruleCode=params.ruleCode
        set warningType=params.warningType
        set warningStatus=params.warningStatus
        set startDate=params.startDate
        set endDate=params.endDate
        set deptCode=params.deptCode
        set doctorCode=params.doctorCode
        set patientName=params.patientName
        set hisAdmId=params.hisAdmId
        
        // 3. 构建查询SQL
        set sql =" SELECT ID,WarningNo,RuleCode,RuleName,WarningType,WarningLevel,"
                _" HISAdmID,PatientName,DeptCode,DeptName,DoctorCode,DoctorName,"
                _" DRGCode,DRGName,TotalFee,InsuranceFee,DRGPayStandard,"
                _" DiffAmount,DiffRate,WarningMessage,WarningStatus,"
                _" WarningDate,WarningTime,ProcessUser_Dr,ProcessDate,ProcessTime,"
                _" ProcessRemark FROM BS_DRGWarningRecord WHERE 1=1"
        
        if (warningNo'="")
        {
            set sql=sql_" AND WarningNo LIKE '%"_warningNo_"%'" 
        }
        if (ruleCode'="")
        {
            set sql=sql_" AND RuleCode = '"_ruleCode_"'" 
        }
        if (warningType'="")
        {
            set sql=sql_" AND WarningType = '"_warningType_"'" 
        }
        if (warningStatus'="")
        {
            set sql=sql_" AND WarningStatus = '"_warningStatus_"'" 
        }
        if (startDate'="")
        {
            set sql=sql_" AND WarningDate >= '"_startDate_"'" 
        }
        if (endDate'="")
        {
            set sql=sql_" AND WarningDate <= '"_endDate_"'" 
        }
        if (deptCode'="")
        {
            set sql=sql_" AND DeptCode = '"_deptCode_"'" 
        }
        if (doctorCode'="")
        {
            set sql=sql_" AND DoctorCode = '"_doctorCode_"'" 
        }
        if (patientName'="")
        {
            set sql=sql_" AND PatientName LIKE '%"_patientName_"%'" 
        }
        if (hisAdmId'="")
        {
            set sql=sql_" AND HISAdmID LIKE '%"_hisAdmId_"%'" 
        }
        
        set sql=sql_" ORDER BY WarningDate DESC, WarningTime DESC, ID DESC"
        
        // 4. 执行查询
        set sqlObj=##class(%SQL.Statement).%New(1)
        set sc=sqlObj.%Prepare(sql)
        set result=sqlObj.%Execute()
        while result.%Next()	
        {
            set dataObj={}
            set dataObj.id=result.%Get("ID")
            set dataObj.warningNo=result.%Get("WarningNo")
            set dataObj.ruleCode=result.%Get("RuleCode")
            set dataObj.ruleName=result.%Get("RuleName")
            set dataObj.warningType=result.%Get("WarningType")
            set dataObj.warningLevel=result.%Get("WarningLevel")
            set dataObj.hisAdmId=result.%Get("HISAdmID")
            set dataObj.patientName=result.%Get("PatientName")
            set dataObj.deptCode=result.%Get("DeptCode")
            set dataObj.deptName=result.%Get("DeptName")
            set dataObj.doctorCode=result.%Get("DoctorCode")
            set dataObj.doctorName=result.%Get("DoctorName")
            set dataObj.drgCode=result.%Get("DRGCode")
            set dataObj.drgName=result.%Get("DRGName")
            set dataObj.totalFee=result.%Get("TotalFee")
            set dataObj.insuranceFee=result.%Get("InsuranceFee")
            set dataObj.drgPayStandard=result.%Get("DRGPayStandard")
            set dataObj.diffAmount=result.%Get("DiffAmount")
            set dataObj.diffRate=result.%Get("DiffRate")
            set dataObj.warningMessage=result.%Get("WarningMessage")
            set dataObj.warningStatus=result.%Get("WarningStatus")
            set dataObj.warningDate=$zd(result.%Get("WarningDate"),3)
            set dataObj.warningTime=$zt(result.%Get("WarningTime"),1)
            set dataObj.processUser=result.%Get("ProcessUser_Dr")
            set dataObj.processDate=$zd(result.%Get("ProcessDate"),3)
            set dataObj.processTime=$zt(result.%Get("ProcessTime"),1)
            set dataObj.processRemark=result.%Get("ProcessRemark")
            
            set count=count+1
            // 分页处理：使用 continue 语句
            if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
            do dataArr.%Push(dataObj)
        }
        
        set resultObj.result.rows=dataArr
        set resultObj.result.total=count		
	}
    catch(e) 
    {
        set status=e.AsStatus()
        set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
        set errorInfo="查询预警记录列表异常：类="_$ClassName()_"，入参="_jsonObj.%ToJSON()_""
        set errorLogID=##class(src.Interface.Message).InsErrRecord("02010103",errorInfo,errorMessage)
        set resultObj={}
        set resultObj.errorCode="02010103"
        set resultObj.errorMessage="查询预警记录列表异常（日志ID："_errorLogID_"）："_errorMessage
    }

    quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 处理预警（确认/忽略）
/// Table:       BS_DRGWarningRecord
/// Code:        02010104
/// Input:       {"params":[{"warningId":"123","processStatus":"processed","processRemark":"处理备注"}]}
/// Output:      {errorCode:"0", errorMessage:"处理成功", result:{}}
ClassMethod ProcessWarning(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"处理成功","result":{}}
	try
	{
        set params=jsonObj.params.%Get(0)
        set warningId=params.warningId
        set processStatus=params.processStatus
        set processRemark=params.processRemark
        
        if (warningId="") 
        {
            set resultObj.errorCode="-1"
            set resultObj.errorMessage="预警记录ID不能为空"
            quit 
        }
        
        // 更新预警记录处理状态
        set obj=##class(User.BSDRGWarningRecord).%OpenId(warningId)
        if (obj="") 
        {
            set resultObj.errorCode="-2"
            set resultObj.errorMessage="预警记录不存在"
            quit 
        }
        
        // 状态映射
        set statusMap=$s(processStatus="processed":"02",processStatus="ignored":"03",processStatus="已确认":"02",processStatus="已忽略":"03",1:processStatus)
        set obj.WarningStatus=statusMap
        set obj.ProcessUserDr=""
        set obj.ProcessDate=+$h
        set obj.ProcessTime=$p($h,",",2)
        set obj.ProcessRemark=processRemark
        
        set sc=obj.%Save()
        if ($$$ISOK(sc)) 
        {
            set resultObj.errorCode="0"
            set resultObj.errorMessage="处理成功"
        } 
        else 
        {
            set resultObj.errorCode="-3"
            set resultObj.errorMessage="处理失败"
        }
	}
    catch(e) 
    {
        set status=e.AsStatus()
        set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
        set errorInfo="处理预警异常：类="_$ClassName()_"，入参="_jsonObj.%ToJSON()_""
        set errorLogID=##class(src.Interface.Message).InsErrRecord("02010104",errorInfo,errorMessage)
        set resultObj={}
        set resultObj.errorCode="02010104"
        set resultObj.errorMessage="处理预警异常（日志ID："_errorLogID_"）："_errorMessage
    }

    quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 预警统计分析
/// Code: 02010106
ClassMethod QueryWarningStats(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
	new (jsonObj)
	set params = ##class(%DynamicArray).%New()
	try
	{
        set resultObj = ..SetSuccessResult("0","")
        
        if (jsonObj = "") || (jsonObj.params = "") 
        {
            set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
            quit 
        }
        
        set params = jsonObj.params.%Get(0)
        set startDate = $GET(params.startDate,"")
        set endDate = $GET(params.endDate,"")
        
        // 构建日期条件
        set dateWhere = ""
        if (startDate '= "") {
            set dateWhere = dateWhere _ " AND WarningDate >= '" _ startDate _ "'"
        }
        if (endDate '= "") {
            set dateWhere = dateWhere _ " AND WarningDate <= '" _ endDate _ "'"
        }
        
        // 初始化统计对象
        set stats={}
        set stats.totalCount = 0
        set stats.pendingCount = 0
        set stats.processedCount = 0
        
        // 使用%SQL.Statement执行查询
        set tStatement = ##class(%SQL.Statement).%New()
        set tStatement.%SelectMode = 1
        
        // 统计总数
        set totalSql = "SELECT COUNT(*) As Total FROM BS_DRGWarningRecord WHERE 1=1" _ dateWhere
        set tStatus = tStatement.%Prepare(totalSql)
        if ($$$ISOK(tStatus)) {
            set rs = tStatement.%Execute()
            if (rs.%Next()) {
                set stats.totalCount = rs.Total
            }
        }
        
        // 待处理数
        set pendingSql = "SELECT COUNT(*) As Cnt FROM BS_DRGWarningRecord WHERE WarningStatus = '01'" _ dateWhere
        set tStatus = tStatement.%Prepare(pendingSql)
        if ($$$ISOK(tStatus)) {
            set rs = tStatement.%Execute()
            if (rs.%Next()) {
                set stats.pendingCount = rs.Cnt
            }
        }
        
        // 已处理数
        set processedSql = "SELECT COUNT(*) As Cnt FROM BS_DRGWarningRecord WHERE WarningStatus IN ('02','03','04','05')" _ dateWhere
        set tStatus = tStatement.%Prepare(processedSql)
        if ($$$ISOK(tStatus)) {
            set rs = tStatement.%Execute()
            if (rs.%Next()) {
                set stats.processedCount = rs.Cnt
            }
        }
        
        // 按类型统计
        set typeStatsArr = []
        set typeSql = "SELECT WarningType, COUNT(*) As Cnt FROM BS_DRGWarningRecord WHERE 1=1" _ dateWhere _ " GROUP BY WarningType"
        set tStatus = tStatement.%Prepare(typeSql)
        if ($$$ISOK(tStatus)) {
            set rs = tStatement.%Execute()
            while (rs.%Next()) {
                set typeItem={}
                set typeItem.type = $s(rs.WarningType="01":"费用超支", rs.WarningType="02":"低倍率", rs.WarningType="03":"高倍率", rs.WarningType="04":"编码异常", rs.WarningType="05":"分解住院", 1:rs.WarningType)
                set typeItem.count = rs.Cnt
                do typeStatsArr.%Push(typeItem)
            }
        }
        set stats.typeStats = typeStatsArr
        
        // 按级别统计
        set levelStatsArr = []
        set levelSql = "SELECT WarningLevel, COUNT(*) As Cnt FROM BS_DRGWarningRecord WHERE 1=1" _ dateWhere _ " GROUP BY WarningLevel"
        set tStatus = tStatement.%Prepare(levelSql)
        if ($$$ISOK(tStatus)) {
            set rs = tStatement.%Execute()
            while (rs.%Next()) {
                set levelItem={}
                set levelItem.level = $s(rs.WarningLevel=3:"高", rs.WarningLevel=2:"中", rs.WarningLevel=1:"低", 1:"other")
                set levelItem.count = rs.Cnt
                do levelStatsArr.%Push(levelItem)
            }
        }
        set stats.levelStats = levelStatsArr
        
        // 费用统计
        set feeSql = "SELECT SUM(DiffAmount) As TotalDiff, SUM(TotalFee) As TotalFee FROM BS_DRGWarningRecord WHERE 1=1" _ dateWhere
        set tStatus = tStatement.%Prepare(feeSql)
        if ($$$ISOK(tStatus)) {
            set rs = tStatement.%Execute()
            if (rs.%Next()) {
                set stats.totalDiff = rs.TotalDiff
                set stats.totalFee = rs.TotalFee
            }
        }
        
        set resultObj.result = stats
	}
    catch(e) 
    {
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "QueryWarningStats异常：类=" _ $ClassName() _ "，入参=" _ jsonObj.%ToJSON() _ "，错误：" _ errorMsg
        
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("02010106", errorInfo, errorMsg)
        set resultObj = ..SetErrorResult("-99", "QueryWarningStats异常（日志ID："_errorLogID_")："_errorMsg)
    }

    quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-03-20
/// Description: 新增预警记录（HIS调用接口）
/// Code: 02010107
ClassMethod AddWarningRecord(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
	new (jsonObj)
	set params = ##class(%DynamicArray).%New()
	try
	{
        set resultObj = ..SetSuccessResult("0","")
        
        if (jsonObj = "") || (jsonObj.params = "") 
        {
            set resultObj = ..SetErrorResult("-1", "入参异常：缺少params参数或参数为空")
            quit 
        }
        
        // 获取参数
        set params = jsonObj.params.%Get(0)
        set hisAdmId = params.hisAdmId
        set patientName = params.patientName
        set deptCode = params.deptCode
        set deptName = params.deptName
        set doctorCode = params.doctorCode
        set doctorName = params.doctorName
        set totalFee = params.totalFee
        set drgCode = params.drgCode
        set drgPayStandard = params.drgPayStandard
        set drgName = params.drgName
        set medicalRecordDr = params.medicalRecordDr
        set insuranceFee = params.insuranceFee
        set fixmedinsCode = params.fixmedinsCode
        set fixmedinsName = params.fixmedinsName
        set ruleType = params.ruleType
        
        // 验证必填参数
        if (hisAdmId = "") {
            set resultObj = ..SetErrorResult("-1", "HIS就诊ID不能为空")
            quit 
        }
        if (patientName = "") {
            set resultObj = ..SetErrorResult("-1", "患者姓名不能为空")
            quit 
        }
        if (totalFee = "") {
            set resultObj = ..SetErrorResult("-1", "医疗总费用不能为空")
            quit 
        }
        if (drgCode = "") {
            set resultObj = ..SetErrorResult("-1", "DRG编码不能为空")
            quit 
        }        
        if (deptCode = "") {
            set resultObj = ..SetErrorResult("-1", "科室编码不能为空")
            quit 
        }
        if (doctorCode = "") {
            set resultObj = ..SetErrorResult("-1", "医生编码不能为空")
            quit 
        }
        if (fixmedinsCode = "") {
            set resultObj = ..SetErrorResult("-1", "医疗机构代码不能为空")
            quit 
        }                
                
        //判断DRG支付标准
        set getPayStandard=0
        &sql(Select PayStandard into :getPayStandard from HB_DRGCoreAlgorithmData Where DRG=:drgCode and FixmedinsCode=:fixmedinsCode) 
        if (SQLCODE '= 0)||(getPayStandard = 0)
        {
            set resultObj = ..SetErrorResult("-1", "DRG支付标准金额为0,请检查DRG平台算法配置是否维护！")
            quit 	        
	    }   
	    else
	    {
		    set drgPayStandard = getPayStandard    
		}                           
        
        // 计算费用差异
        if (drgPayStandard '= 0) && (drgPayStandard '= "") 
        {
            set diffAmount = totalFee - drgPayStandard
            set diffRate = $s(drgPayStandard '= 0:(diffAmount / drgPayStandard * 100), 1:0)
        } 
        else 
        {
            set diffAmount = 0
            set diffRate = 0
        }
        
        // 查询匹配的预警规则
        set warningList = []
        
        // 使用%SQL.Statement执行查询
        set tStatement = ##class(%SQL.Statement).%New()
        set tStatement.%SelectMode = 1
        
        set rulesSql = "SELECT ID, RuleCode, RuleName, RuleType, ThresholdType, ThresholdValue, WarningLevel, DRGCode FROM BS_DRGWarningRule WHERE IsActive = 'Y' OR IsActive = '1'"
        set tStatus = tStatement.%Prepare(rulesSql)
        
        if ($$$ISOK(tStatus)) {
            set rs = tStatement.%Execute()
            while (rs.%Next()) {
                set ruleId = rs.ID
                set ruleCode = rs.RuleCode
                set ruleName = rs.RuleName
                set ruleTypeVal = rs.RuleType
                set thresholdType = rs.ThresholdType
                set thresholdValue = rs.ThresholdValue
                set warningLevel = rs.WarningLevel
                set ruleDrgCode = rs.DRGCode
                
                // DRG范围检查
                if ((ruleDrgCode '= "") && (ruleDrgCode '= drgCode)) {
                    continue
                }
                
                // ruleType过滤
                if (ruleType '= "") && (ruleTypeVal '= ruleType) {
                    continue
                }
                
                // 判断是否触发预警
                set isTrigger = ..CheckWarningTrigger(ruleTypeVal, thresholdType, thresholdValue, totalFee, drgPayStandard)
                
                if (isTrigger) {
                    // 创建预警记录
                    set wr = ##class(User.BSDRGWarningRecord).%New()
                    set wr.WarningNo = ..GenerateWarningNo()
                    set wr.RuleDr = ruleId
                    set wr.RuleCode = ruleCode
                    set wr.RuleName = ruleName
                    set wr.WarningType = ruleTypeVal
                    set wr.WarningLevel = warningLevel
                    set wr.MedicalRecordDr = medicalRecordDr
                    set wr.HISAdmID = hisAdmId
                    set wr.PatientName = patientName
                    set wr.DeptCode = deptCode
                    set wr.DeptName = deptName
                    set wr.DoctorCode = doctorCode
                    set wr.DoctorName = doctorName
                    set wr.TotalFee = totalFee
                    set wr.DRGCode = drgCode
                    set wr.DRGName = drgName
                    set wr.InsuranceFee = insuranceFee
                    set wr.DRGPayStandard = drgPayStandard
                    set wr.DiffAmount = diffAmount
                    set wr.DiffRate = diffRate
                    set wr.WarningStatus = "01"
                    set wr.WarningDate = +$h
                    set wr.WarningTime = $p($h,",",2)
                    set wr.FixmedinsCode = fixmedinsCode
                    set wr.FixmedinsName = fixmedinsName
                    
                    // 生成预警消息
                    set warningMsg = ..GenerateWarningMessage(ruleName, totalFee, drgPayStandard, diffAmount, diffRate)
                    set wr.WarningMessage = warningMsg
                    
                    set sc = wr.%Save()
                    if ($$$ISOK(sc)) {
                        set item={}
                        set item.warningId = wr.%Id()
                        set item.warningNo = wr.WarningNo
                        set item.ruleCode = ruleCode
                        set item.ruleName = ruleName
                        set item.warningLevel = warningLevel
                        set item.warningMessage = warningMsg
                        do warningList.%Push(item)
                    }
                }
            }
        }
        
        set resultObj.errorCode = "0"
        set resultObj.errorMessage = ""
        set resultObj.result = warningList
        set resultObj.count = warningList.%Size()
	}
    catch(e) 
    {
        set status = e.AsStatus()
        set errorCode = $piece(##class(%SYSTEM.Status).GetErrorCodes(status), ",")
        set errorMsg = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
        set errorInfo = "AddWarningRecord异常：类=" _ $ClassName() _ "，入参=" _ jsonObj.%ToJSON() _ "，错误：" _ errorMsg
        
        set errorLogID = ##class(src.Interface.Message).InsErrRecord("02010107", errorInfo, errorMsg)
        set resultObj = ..SetErrorResult("-99", "AddWarningRecord异常（日志ID："_errorLogID_")："_errorMsg)
    }

    quit resultObj
}

/// 检查预警是否触发
ClassMethod CheckWarningTrigger(ruleType As %String, thresholdType As %String, thresholdValue As %Numeric, totalFee As %Numeric, drgPayStandard As %Numeric) As %Boolean
{
    new (ruleType, thresholdType, thresholdValue, totalFee, drgPayStandard)
    
    set result = 0
    
    // ruleType: 01=费用超支, 02=低倍率, 03=高倍率, 04=编码异常, 05=分解住院
    
    if (ruleType = "01") {
        // 费用超支预警
        if (drgPayStandard '= "") && (thresholdValue '= "") {
            set threshold = drgPayStandard * thresholdValue / 100
            if (totalFee > threshold) {
                set result = 1
            }
        }
    }
    elseif (ruleType = "02") {
        // 低倍率预警
        if (drgPayStandard '= "") && (thresholdValue '= "") {
            set threshold = drgPayStandard * (100 - thresholdValue) / 100
            if (totalFee < threshold) {
                set result = 1
            }
        }
    }
    elseif (ruleType = "03") {
        // 高倍率预警
        if (drgPayStandard '= "") && (thresholdValue '= "") {
            set threshold = drgPayStandard * (100 + thresholdValue) / 100
            if (totalFee > threshold) {
                set result = 1
            }
        }
    }
    
    quit result
}

/// 生成预警消息
ClassMethod GenerateWarningMessage(ruleName As %String, totalFee As %Numeric, drgPayStandard As %Numeric, diffAmount As %Numeric, diffRate As %Numeric) As %String
{
    new (ruleName, totalFee, drgPayStandard, diffAmount, diffRate)
    
    set msg = ruleName _ "：患者费用总额" _ $fn(totalFee,2) _ "元"
    
    if (drgPayStandard '= "") {
        set msg = msg _ "，DRG支付标准" _ $fn(drgPayStandard,2) _ "元"
    }
    
    if (diffAmount > 0) {
        set msg = msg _ "，超出" _ $fn(diffAmount,2) _ "元"
    } elseif (diffAmount < 0) {
        set msg = msg _ "，低于" _ $fn(-diffAmount,2) _ "元"
    }
    
    if (diffRate '= 0) {
        if (diffRate > 0) {
            set msg = msg _ "（+" _ $fn(diffRate,2) _ "%）"
        } else {
            set msg = msg _ "（" _ $fn(diffRate,2) _ "%）"
        }
    }
    
    quit msg
}

/// 生成预警流水号
ClassMethod GenerateWarningNo() As %String
{
    quit "W"_$zd(+$h,"YYYYMMDD")_$tr($zt($p($h,",",2)),":","")_$r(6)
}

}
