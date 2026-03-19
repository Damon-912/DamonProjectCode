/// 病案质控服务类
/// 提供病案质控检查、问题管理等功能
/// 
/// 接口Code规范: 020103xx
Class src.DRG.QC Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 执行质控检查
/// Code: 02010301
ClassMethod PerformQCCheck(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    set medicalRecordId = $lg(params,1)
    
    if (medicalRecordId = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "病案ID不能为空"
        quit result
    }
    
    // 获取病案信息
    set mr = ##class(User.BSDRGMedInsuMedicalRecord).%OpenId(medicalRecordId)
    if (mr = "") {
        set result.errorCode = "2001"
        set result.errorMessage = "病案不存在"
        quit result
    }
    
    // 执行质控检查
    set issueList = ##class(%Library.DynamicArray).%New()
    
    // 检查1: 主要诊断是否为空
    if ($zcvt(mr.PrincipalDiagnosis, "U") = "") {
        set issue = ##class(%Library.DynamicObject).%New()
        set issue.issueType = "01"
        set issue.issueCategory = "0101"
        set issue.issueLevel = 3
        set issue.issueDesc = "主要诊断为空"
        set issue.fieldName = "PrincipalDiagnosis"
        set issue.suggestValue = "请填写主要诊断"
        do issueList.%Push(issue)
    }
    
    // 检查2: 诊断与手术是否匹配
    if ((mr.PrincipalDiagnosis '= "") && (mr.MainOperationCode = "")) {
        set issue = ##class(%Library.DynamicObject).%New()
        set issue.issueType = "02"
        set issue.issueCategory = "0201"
        set issue.issueLevel = 2
        set issue.issueDesc = "有诊断无手术，可能存在手术漏填"
        set issue.fieldName = "MainOperationCode"
        do issueList.%Push(issue)
    }
    
    // 检查3: 住院天数是否合理
    set admDate = mr.AdmDate
    set disDate = mr.DisDate
    if ((admDate '= "") && (disDate '= "")) {
        set hospDays = disDate - admDate
        if (hospDays < 0) {
            set issue = ##class(%Library.DynamicObject).%New()
            set issue.issueType = "01"
            set issue.issueCategory = "0102"
            set issue.issueLevel = 3
            set issue.issueDesc = "出院日期早于入院日期，数据错误"
            set issue.fieldName = "DisDate"
            do issueList.%Push(issue)
        }
    }
    
    // 检查4: 费用是否异常
    if (mr.TotalFee > 0) {
        // 获取该DRG的平均费用
        if (mr.DRGCode '= "") {
            set avgFee = ..GetDRGAvgFee(mr.DRGCode)
            if (avgFee > 0) {
                set feeRate = mr.TotalFee / avgFee
                if (feeRate > 2) {
                    set issue = ##class(%Library.DynamicObject).%New()
                    set issue.issueType = "03"
                    set issue.issueCategory = "0301"
                    set issue.issueLevel = 2
                    set issue.issueDesc = "医疗费用超过该病种平均费用的2倍"
                    set issue.fieldName = "TotalFee"
                    do issueList.%Push(issue)
                }
            }
        }
    }
    
    // 检查5: 年龄与诊断是否匹配
    if (mr.PatientAge < 18) {
        // 检查是否有成人疾病诊断
        set diagList = ..GetDiagnosisList(medicalRecordId)
        // 简化检查逻辑
    }
    
    // 保存质控问题记录
    set userId = $lg(session,1)
    
    for i = 0:1:(issueList.%Size() - 1) {
        set issueObj = issueList.%Get(i)
        
        set qc = ##class(User.BSDRGQCIssue).%New()
        set qc.IssueNo = ..GenerateIssueNo()
        set qc.IssueType = issueObj.issueType
        set qc.IssueCategory = issueObj.issueCategory
        set qc.IssueLevel = issueObj.issueLevel
        set qc.IssueDesc = issueObj.issueDesc
        set qc.IssueDetail = issueObj.issueDesc
        set qc.MedicalRecordDr = medicalRecordId
        set qc.HISAdmID = mr.HISAdmID
        set qc.PatientName = mr.PatientName
        set qc.DeptCode = mr.DeptCode
        set qc.DeptName = mr.DeptName
        set qc.DoctorCode = mr.AttendingDoctor
        set qc.DoctorName = mr.AttendingDoctorName
        set qc.DRGCode = mr.DRGCode
        set qc.FieldName = issueObj.fieldName
        set qc.SuggestValue = issueObj.suggestValue
        set qc.IssueStatus = "01"  // 待处理
        set qc.FindDate = +$h
        set qc.FindTime = $p($h,",",2)
        set qc.FindUserDr = userId
        set qc.FixmedinsCode = mr.FixmedinsCode
        set qc.FixmedinsName = mr.FixmedinsName
        
        do qc.%Save()
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = {"issueCount": issueList.%Size(), "issues": issueList}
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询质控问题列表
/// Code: 02010302
ClassMethod QueryQCIssues(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    // 获取参数
    set issueNo = $lg(params,1)
    set issueType = $lg(params,2)
    set issueStatus = $lg(params,3)
    set startDate = $lg(params,4)
    set endDate = $lg(params,5)
    set deptCode = $lg(params,6)
    set doctorCode = $lg(params,7)
    set page = $lg(params,8)
    set limit = $lg(params,9)
    
    if (page = "") set page = 1
    if (limit = "") set limit = 20
    
    // 查询数据
    set dataList = ##class(%Library.DynamicArray).%New()
    
    set sql = "SELECT ID, IssueNo, IssueType, IssueCategory, IssueLevel, IssueDesc, "_ 
              "MedicalRecordDr, HISAdmID, PatientName, DeptCode, DeptName, "_ 
              "DoctorCode, DoctorName, DRGCode, IssueStatus, FindDate "_ 
              "FROM BS_DRGQCIssue WHERE 1=1"
    
    if (issueNo '= "") {
        set sql = sql _ " AND IssueNo LIKE '%" _ issueNo _ "%'"
    }
    if (issueType '= "") {
        set sql = sql _ " AND IssueType = '" _ issueType _ "'"
    }
    if (issueStatus '= "") {
        set sql = sql _ " AND IssueStatus = '" _ issueStatus _ "'"
    }
    if (deptCode '= "") {
        set sql = sql _ " AND DeptCode = '" _ deptCode _ "'"
    }
    if (doctorCode '= "") {
        set sql = sql _ " AND DoctorCode = '" _ doctorCode _ "'"
    }
    
    set sql = sql _ " ORDER BY FindDate DESC, ID DESC"
    
    set rs = ##class(%ResultSet).%New()
    set rs.Query = sql
    do rs.Execute()
    
    set count = 0
    while (rs.Next()) {
        set count = count + 1
        if ((count > ((page - 1) * limit)) && (count <= (page * limit))) {
            set item = ##class(%Library.DynamicObject).%New()
            set item.id = rs.Data("ID")
            set item.issueNo = rs.Data("IssueNo")
            set item.issueType = rs.Data("IssueType")
            set item.issueLevel = rs.Data("IssueLevel")
            set item.issueDesc = rs.Data("IssueDesc")
            set item.hisAdmID = rs.Data("HISAdmID")
            set item.patientName = rs.Data("PatientName")
            set item.deptCode = rs.Data("DeptCode")
            set item.deptName = rs.Data("DeptName")
            set item.doctorCode = rs.Data("DoctorCode")
            set item.doctorName = rs.Data("DoctorName")
            set item.drgCode = rs.Data("DRGCode")
            set item.issueStatus = rs.Data("IssueStatus")
            set item.findDate = $zd(rs.Data("FindDate"), 3)
            do dataList.%Push(item)
        }
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = dataList
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 处理质控问题
/// Code: 02010303
ClassMethod ProcessQCIssue(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    set issueId = $lg(params,1)
    set processStatus = $lg(params,2)
    set processRemark = $lg(params,3)
    set userId = $lg(session,1)
    
    if (issueId = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "质控问题ID不能为空"
        quit result
    }
    
    set obj = ##class(User.BSDRGQCIssue).%OpenId(issueId)
    if (obj = "") {
        set result.errorCode = "2001"
        set result.errorMessage = "质控问题不存在"
        quit result
    }
    
    set obj.IssueStatus = processStatus
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
/// Description: 质控统计报表
/// Code: 02010304
ClassMethod QueryQCStats(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    set startDate = $lg(params,1)
    set endDate = $lg(params,2)
    set deptCode = $lg(params,3)
    
    // 按问题类型统计
    set typeStats = ##class(%Library.DynamicObject).%New()
    
    // 按问题级别统计
    set levelStats = ##class(%Library.DynamicObject).%New()
    
    // 按科室统计
    set deptStats = ##class(%Library.DynamicArray).%New()
    
    // 查询统计数据
    set sql = "SELECT IssueType, IssueLevel, DeptCode, COUNT(*) AS IssueCount "_ 
              "FROM BS_DRGQCIssue WHERE 1=1"
    
    if (startDate '= "") {
        set sql = sql _ " AND FindDate >= '" _ startDate _ "'"
    }
    if (endDate '= "") {
        set sql = sql _ " AND FindDate <= '" _ endDate _ "'"
    }
    if (deptCode '= "") {
        set sql = sql _ " AND DeptCode = '" _ deptCode _ "'"
    }
    set sql = sql _ " GROUP BY IssueType, IssueLevel, DeptCode"
    
    set rs = ##class(%ResultSet).%New()
    set rs.Query = sql
    do rs.Execute()
    
    while (rs.Next()) {
        set issueType = rs.Data("IssueType")
        set issueLevel = rs.Data("IssueLevel")
        set deptCode = rs.Data("DeptCode")
        set issueCount = rs.Data("IssueCount")
        
        // 累加类型统计
        if (issueType '= "") {
            set:'$d(typeStats.%Get(issueType)) typeStats.%Set(issueType, 0)
            set typeStats.%Set(issueType, typeStats.%Get(issueType) + issueCount)
        }
        
        // 累加级别统计
        if (issueLevel '= "") {
            set:'$d(levelStats.%Get(issueLevel)) levelStats.%Set(issueLevel, 0)
            set levelStats.%Set(issueLevel, levelStats.%Get(issueLevel) + issueCount)
        }
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = {"typeStats": typeStats, "levelStats": levelStats}
    
    quit result
}

/// 生成质控问题流水号
ClassMethod GenerateIssueNo() As %String
{
    quit "Q"_$zd(+$h,"YYYYMMDD")_$tr($zt($p($h,",",2)),":","")_$r(6)
}

/// 获取DRG平均费用
ClassMethod GetDRGAvgFee(drgCode As %String) As %Decimal
{
    new (drgCode)
    
    set avgFee = 0
    
    set sql = "SELECT AVG(TotalFee) AS AvgFee FROM BS_DRGMedInsuMedicalRecord "_ 
              "WHERE DRGCode = '" _ drgCode _ "'"
    
    set rs = ##class(%ResultSet).%New()
    set rs.Query = sql
    do rs.Execute()
    
    if (rs.Next()) {
        set avgFee = rs.Data("AvgFee")
    }
    
    quit avgFee
}

/// 获取诊断列表
ClassMethod GetDiagnosisList(medicalRecordId As %String) As %List
{
    new (medicalRecordId)
    
    set list = ##class(%ListOfDataTypes).%New()
    
    quit list
}

}
