/// 预警服务类
/// 提供预警规则管理、预警记录查询、预警处理等功能
/// 
/// 接口Code规范: 020101xx
Class src.DRG.Warning Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询预警规则列表
/// Code: 02010101
ClassMethod QueryWarningRules(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    // 获取参数
    set ruleCode = $lg(params,1)
    set ruleName = $lg(params,2)
    set ruleType = $lg(params,3)
    set isActive = $lg(params,4)
    set page = $lg(params,5)
    set limit = $lg(params,6)
    
    if (page = "") set page = 1
    if (limit = "") set limit = 20
    
    // 查询数据
    set sql = "SELECT ID, RuleCode, RuleName, RuleDesc, RuleType, ThresholdType, "_ 
              "ThresholdValue, MDCCode, ADRGCode, DRGCode, WarningLevel, IsActive, "_ 
              "SeqNo, CreateDate, CreateTime FROM BS_DRGWarningRule WHERE 1=1"
    
    if (ruleCode '= "") {
        set sql = sql _ " AND RuleCode LIKE '%" _ ruleCode _ "%'"
    }
    if (ruleName '= "") {
        set sql = sql _ " AND RuleName LIKE '%" _ ruleName _ "%'"
    }
    if (ruleType '= "") {
        set sql = sql _ " AND RuleType = '" _ ruleType _ "'"
    }
    if (isActive '= "") {
        set sql = sql _ " AND IsActive = '" _ isActive _ "'"
    }
    
    set sql = sql _ " ORDER BY SeqNo"
    
    // 执行查询返回数据列表
    set dataList = ##class(%Library.DynamicArray).%New()
    
    // 返回成功结果
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = dataList
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 保存预警规则
/// Code: 02010102
ClassMethod SaveWarningRule(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    // 获取参数
    set ruleId = $lg(params,1)
    set ruleCode = $lg(params,2)
    set ruleName = $lg(params,3)
    set ruleDesc = $lg(params,4)
    set ruleType = $lg(params,5)
    set thresholdType = $lg(params,6)
    set thresholdValue = $lg(params,7)
    set mdcCode = $lg(params,8)
    set adrgCode = $lg(params,9)
    set drgCode = $lg(params,10)
    set warningLevel = $lg(params,11)
    set isActive = $lg(params,12)
    set seqNo = $lg(params,13)
    set userId = $lg(session,1)
    
    // 验证必填参数
    if (ruleCode = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "规则编码不能为空"
        quit result
    }
    if (ruleName = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "规则名称不能为空"
        quit result
    }
    if (ruleType = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "规则类型不能为空"
        quit result
    }
    
    // 保存数据
    if (ruleId = "") {
        // 新增
        set obj = ##class(User.BSDRGWarningRule).%New()
        set obj.CreateDate = +$h
        set obj.CreateTime = $p($h,",",2)
        set obj.CreateUserDr = userId
    } else {
        // 修改
        set obj = ##class(User.BSDRGWarningRule).%OpenId(ruleId)
    }
    
    set obj.RuleCode = ruleCode
    set obj.RuleName = ruleName
    set obj.RuleDesc = ruleDesc
    set obj.RuleType = ruleType
    set obj.ThresholdType = thresholdType
    set obj.ThresholdValue = thresholdValue
    set obj.MDCCode = mdcCode
    set obj.ADRGCode = adrgCode
    set obj.DRGCode = drgCode
    set obj.WarningLevel = warningLevel
    set obj.IsActive = isActive
    set obj.SeqNo = seqNo
    set obj.UpdateDate = +$h
    set obj.UpdateTime = $p($h,",",2)
    set obj.UpdateUserDr = userId
    
    set sc = obj.%Save()
    if ($$$ISOK(sc)) {
        set result.errorCode = "0"
        set result.errorMessage = ""
        set result.result = {"id": (obj.%Id())}
    } else {
        set result.errorCode = "3001"
        set result.errorMessage = "保存失败:"_$system.Status.GetErrorText(sc)
    }
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 删除预警规则
/// Code: 02010105
ClassMethod DeleteWarningRule(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    set ruleId = $lg(params,1)
    
    if (ruleId = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "规则ID不能为空"
        quit result
    }
    
    set sc = ##class(User.BSDRGWarningRule).%DeleteId(ruleId)
    if ($$$ISOK(sc)) {
        set result.errorCode = "0"
        set result.errorMessage = ""
    } else {
        set result.errorCode = "3001"
        set result.errorMessage = "删除失败"
    }
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询预警记录列表
/// Code: 02010103
ClassMethod QueryWarningRecords(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    // 获取参数
    set warningNo = $lg(params,1)
    set ruleCode = $lg(params,2)
    set warningType = $lg(params,3)
    set warningStatus = $lg(params,4)
    set startDate = $lg(params,5)
    set endDate = $lg(params,6)
    set deptCode = $lg(params,7)
    set doctorCode = $lg(params,8)
    set page = $lg(params,9)
    set limit = $lg(params,10)
    
    if (page = "") set page = 1
    if (limit = "") set limit = 20
    
    // 查询数据
    set dataList = ##class(%Library.DynamicArray).%New()
    
    // 返回成功结果
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = dataList
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 处理预警
/// Code: 02010104
ClassMethod ProcessWarning(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    set warningId = $lg(params,1)
    set processStatus = $lg(params,2)
    set processRemark = $lg(params,3)
    set userId = $lg(session,1)
    
    if (warningId = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "预警记录ID不能为空"
        quit result
    }
    
    // 更新预警记录处理状态
    set obj = ##class(User.BSDRGWarningRecord).%OpenId(warningId)
    if (obj = "") {
        set result.errorCode = "2001"
        set result.errorMessage = "预警记录不存在"
        quit result
    }
    
    set obj.WarningStatus = processStatus
    set obj.ProcessUserDr = userId
    set obj.ProcessDate = +$h
    set obj.ProcessTime = $p($h,",",2)
    set obj.ProcessRemark = processRemark
    
    set sc = obj.%Save()
    if ($$$ISOK(sc)) {
        set result.errorCode = "0"
        set result.errorMessage = ""
    } else {
        set result.errorCode = "3001"
        set result.errorMessage = "处理失败"
    }
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 预警统计分析
/// Code: 02010106
ClassMethod QueryWarningStats(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    set startDate = $lg(params,1)
    set endDate = $lg(params,2)
    
    // 统计各类型预警数量
    set stats = ##class(%Library.DynamicObject).%New()
    
    // 返回成功结果
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = stats
    
    quit result
}

/// 生成预警流水号
ClassMethod GenerateWarningNo() As %String
{
    quit "W"_$zd(+$h,"YYYYMMDD")_$tr($zt($p($h,",",2)),":","")_$r(6)
}

/// 执行预警检查
/// 根据配置的预警规则检查病案数据
ClassMethod ExecuteWarningCheck(medicalRecordId As %String) As %Library.DynamicObject
{
    new (medicalRecordId)
    
    set result = ##class(%Library.DynamicObject).%New()
    
    // 获取病案信息
    set mr = ##class(User.BSDRGMedInsuMedicalRecord).%OpenId(medicalRecordId)
    if (mr = "") {
        set result.errorCode = "2001"
        set result.errorMessage = "病案不存在"
        quit result
    }
    
    // 查询所有启用的预警规则
    set rs = ##class(%ResultSet).%New()
    set rs.ClassName = "User.BSDRGWarningRule"
    set rs.QueryName = "ByIsActive"
    set rs.Param(1) = "Y"
    do rs.Execute()
    
    set warningList = ##class(%Library.DynamicArray).%New()
    
    while (rs.Next()) {
        set ruleId = rs.Data("ID")
        set ruleCode = rs.Data("RuleCode")
        set ruleName = rs.Data("RuleName")
        set ruleType = rs.Data("RuleType")
        set thresholdType = rs.Data("ThresholdType")
        set thresholdValue = rs.Data("ThresholdValue")
        set warningLevel = rs.Data("WarningLevel")
        
        // 根据规则类型执行检查
        set isTrigger = ..CheckRuleTrigger(ruleType, thresholdType, thresholdValue, mr)
        
        if (isTrigger) {
            // 创建预警记录
            set wr = ##class(User.BSDRGWarningRecord).%New()
            set wr.WarningNo = ..GenerateWarningNo()
            set wr.RuleDr = ruleId
            set wr.RuleCode = ruleCode
            set wr.RuleName = ruleName
            set wr.WarningType = ruleType
            set wr.WarningLevel = warningLevel
            set wr.MedicalRecordDr = medicalRecordId
            set wr.HISAdmID = mr.HISAdmID
            set wr.PatientName = mr.PatientName
            set wr.DeptCode = mr.DeptCode
            set wr.DeptName = mr.DeptName
            set wr.DoctorCode = mr.AttendingDoctor
            set wr.DoctorName = mr.AttendingDoctorName
            set wr.TotalFee = mr.TotalFee
            set wr.DRGCode = mr.DRGCode
            set wr.WarningStatus = "01"  // 待处理
            set wr.WarningDate = +$h
            set wr.WarningTime = $p($h,",",2)
            set wr.FixmedinsCode = mr.FixmedinsCode
            set wr.FixmedinsName = mr.FixmedinsName
            
            do wr.%Save()
            
            set item = ##class(%Library.DynamicObject).%New()
            set item.warningNo = wr.WarningNo
            set item.ruleCode = ruleCode
            set item.ruleName = ruleName
            do warningList.%Push(item)
        }
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = warningList
    
    quit result
}

/// 检查规则是否触发
ClassMethod CheckRuleTrigger(ruleType, thresholdType, thresholdValue, mr As User.BSDRGMedInsuMedicalRecord) As %Boolean
{
    new (ruleType, thresholdType, thresholdValue, mr)
    
    set result = 0
    
    // 01:费用超支检查
    if (ruleType = "01") {
        // 比较费用与DRG支付标准
        if (mr.TotalFee > thresholdValue) {
            set result = 1
        }
    }
    // 02:低倍率检查
    elseif (ruleType = "02") {
        // 费用低于DRG支付标准的百分比
        if (mr.TotalFee < (mr.DRGPayStandard * thresholdValue / 100)) {
            set result = 1
        }
    }
    // 03:高倍率检查
    elseif (ruleType = "03") {
        // 费用高于DRG支付标准的百分比
        if (mr.TotalFee > (mr.DRGPayStandard * thresholdValue / 100)) {
            set result = 1
        }
    }
    
    quit result
}

}
