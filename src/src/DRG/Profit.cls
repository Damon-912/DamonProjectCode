/// 盈亏分析服务类
/// 提供科室/医生/病种盈亏统计分析功能
/// 
/// 接口Code规范: 020102xx
Class src.DRG.Profit Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询科室盈亏
/// Code: 02010201
ClassMethod QueryDeptProfit(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    // 获取参数
    set year = $lg(params,1)
    set month = $lg(params,2)
    set deptCode = $lg(params,3)
    set startDate = $lg(params,4)
    set endDate = $lg(params,5)
    set page = $lg(params,6)
    set limit = $lg(params,7)
    
    if (page = "") set page = 1
    if (limit = "") set limit = 20
    
    // 查询科室盈亏数据
    set dataList = ##class(%Library.DynamicArray).%New()
    
    // 如果指定了年月，则从汇总表查询
    if ((year '= "") && (month '= "")) {
        set rs = ##class(%ResultSet).%New()
        set rs.ClassName = "User.BSDRGDeptSummary"
        set rs.QueryName = "ByYearMonth"
        do rs.Execute(year, month)
        
        while (rs.Next()) {
            set item = ##class(%Library.DynamicObject).%New()
            set item.deptCode = rs.Data("DeptCode")
            set item.deptName = rs.Data("DeptName")
            set item.totalCaseCount = rs.Data("TotalCaseCount")
            set item.groupedCaseCount = rs.Data("GroupedCaseCount")
            set item.groupRate = rs.Data("GroupRate")
            set item.profitAmount = rs.Data("ProfitAmount")
            set item.profitRate = rs.Data("ProfitRate")
            set item.cmi = rs.Data("CMI")
            set item.avgFee = rs.Data("AvgFee")
            do dataList.%Push(item)
        }
    } else {
        // 从病案表实时统计
        set sql = "SELECT DeptCode, DeptName, COUNT(*) AS CaseCount, "_ 
                  "SUM(TotalFee) AS TotalFee, SUM(DRGPayStandard) AS PayStandard "_ 
                  "FROM BS_DRGMedInsuMedicalRecord WHERE 1=1"
        
        if (startDate '= "") {
            set sql = sql _ " AND AdmDate >= '" _ startDate _ "'"
        }
        if (endDate '= "") {
            set sql = sql _ " AND AdmDate <= '" _ endDate _ "'"
        }
        if (deptCode '= "") {
            set sql = sql _ " AND DeptCode = '" _ deptCode _ "'"
        }
        set sql = sql _ " GROUP BY DeptCode, DeptName"
        
        set rs = ##class(%ResultSet).%New()
        set rs.Query = sql
        do rs.Execute()
        
        while (rs.Next()) {
            set totalFee = rs.Data("TotalFee")
            set payStandard = rs.Data("PayStandard")
            set profitAmount = payStandard - totalFee
            
            set item = ##class(%Library.DynamicObject).%New()
            set item.deptCode = rs.Data("DeptCode")
            set item.deptName = rs.Data("DeptName")
            set item.totalCaseCount = rs.Data("CaseCount")
            set item.totalFee = totalFee
            set item.payStandard = payStandard
            set item.profitAmount = profitAmount
            if (totalFee > 0) {
                set item.profitRate = $fn((profitAmount / totalFee) * 100, "", 2)
            } else {
                set item.profitRate = 0
            }
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
/// Description: 查询医生盈亏
/// Code: 02010202
ClassMethod QueryDoctorProfit(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    // 获取参数
    set year = $lg(params,1)
    set month = $lg(params,2)
    set deptCode = $lg(params,3)
    set doctorCode = $lg(params,4)
    set startDate = $lg(params,5)
    set endDate = $lg(params,6)
    set page = $lg(params,7)
    set limit = $lg(params,8)
    
    if (page = "") set page = 1
    if (limit = "") set limit = 20
    
    // 查询医生盈亏数据
    set dataList = ##class(%Library.DynamicArray).%New()
    
    set sql = "SELECT AttendingDoctor AS DoctorCode, AttendingDoctorName AS DoctorName, "_ 
              "DeptCode, DeptName, COUNT(*) AS CaseCount, "_ 
              "SUM(TotalFee) AS TotalFee, SUM(DRGPayStandard) AS PayStandard "_ 
              "FROM BS_DRGMedInsuMedicalRecord WHERE 1=1"
    
    if (startDate '= "") {
        set sql = sql _ " AND AdmDate >= '" _ startDate _ "'"
    }
    if (endDate '= "") {
        set sql = sql _ " AND AdmDate <= '" _ endDate _ "'"
    }
    if (deptCode '= "") {
        set sql = sql _ " AND DeptCode = '" _ deptCode _ "'"
    }
    if (doctorCode '= "") {
        set sql = sql _ " AND AttendingDoctor = '" _ doctorCode _ "'"
    }
    
    set sql = sql _ " GROUP BY AttendingDoctor, AttendingDoctorName, DeptCode, DeptName"
    
    set rs = ##class(%ResultSet).%New()
    set rs.Query = sql
    do rs.Execute()
    
    while (rs.Next()) {
        set totalFee = rs.Data("TotalFee")
        set payStandard = rs.Data("PayStandard")
        set profitAmount = payStandard - totalFee
        
        set item = ##class(%Library.DynamicObject).%New()
        set item.doctorCode = rs.Data("DoctorCode")
        set item.doctorName = rs.Data("DoctorName")
        set item.deptCode = rs.Data("DeptCode")
        set item.deptName = rs.Data("DeptName")
        set item.caseCount = rs.Data("CaseCount")
        set item.totalFee = totalFee
        set item.payStandard = payStandard
        set item.profitAmount = profitAmount
        if (totalFee > 0) {
            set item.profitRate = $fn((profitAmount / totalFee) * 100, "", 2)
        } else {
            set item.profitRate = 0
        }
        do dataList.%Push(item)
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = dataList
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询病种盈亏
/// Code: 02010203
ClassMethod QueryDiseaseProfit(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    // 获取参数
    set year = $lg(params,1)
    set month = $lg(params,2)
    set drgCode = $lg(params,3)
    set dipCode = $lg(params,4)
    set startDate = $lg(params,5)
    set endDate = $lg(params,6)
    set page = $lg(params,7)
    set limit = $lg(params,8)
    
    if (page = "") set page = 1
    if (limit = "") set limit = 20
    
    // 查询病种盈亏数据
    set dataList = ##class(%Library.DynamicArray).%New()
    
    set sql = "SELECT DRGCode, DRGName, COUNT(*) AS CaseCount, "_ 
              "SUM(TotalFee) AS TotalFee, SUM(DRGPayStandard) AS PayStandard "_ 
              "FROM BS_DRGMedInsuMedicalRecord WHERE DRGCode IS NOT NULL"
    
    if (startDate '= "") {
        set sql = sql _ " AND AdmDate >= '" _ startDate _ "'"
    }
    if (endDate '= "") {
        set sql = sql _ " AND AdmDate <= '" _ endDate _ "'"
    }
    if (drgCode '= "") {
        set sql = sql _ " AND DRGCode = '" _ drgCode _ "'"
    }
    if (dipCode '= "") {
        set sql = sql _ " AND DIPCode = '" _ dipCode _ "'"
    }
    
    set sql = sql _ " GROUP BY DRGCode, DRGName ORDER BY CaseCount DESC"
    
    set rs = ##class(%ResultSet).%New()
    set rs.Query = sql
    do rs.Execute()
    
    while (rs.Next()) {
        set totalFee = rs.Data("TotalFee")
        set payStandard = rs.Data("PayStandard")
        set profitAmount = payStandard - totalFee
        set caseCount = rs.Data("CaseCount")
        
        set item = ##class(%Library.DynamicObject).%New()
        set item.drgCode = rs.Data("DRGCode")
        set item.drgName = rs.Data("DRGName")
        set item.caseCount = caseCount
        set item.totalFee = totalFee
        set item.payStandard = payStandard
        set item.profitAmount = profitAmount
        if (totalFee > 0) {
            set item.profitRate = $fn((profitAmount / totalFee) * 100, "", 2)
        } else {
            set item.profitRate = 0
        }
        if (caseCount > 0) {
            set item.avgFee = $fn(totalFee / caseCount, "", 2)
        } else {
            set item.avgFee = 0
        }
        do dataList.%Push(item)
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = dataList
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 盈亏趋势分析
/// Code: 02010204
ClassMethod QueryProfitTrend(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    set deptCode = $lg(params,1)
    set doctorCode = $lg(params,2)
    set startYear = $lg(params,3)
    set startMonth = $lg(params,4)
    set endYear = $lg(params,5)
    set endMonth = $lg(params,6)
    
    // 查询趋势数据
    set dataList = ##class(%Library.DynamicArray).%New()
    
    // 计算月份范围
    set year = startYear
    set month = startMonth
    while ((year < endYear) || ((year = endYear) && (month <= endMonth))) {
        set item = ##class(%Library.DynamicObject).%New()
        set item.year = year
        set item.month = month
        
        // 查询该月数据
        set rs = ##class(%ResultSet).%New()
        set rs.ClassName = "User.BSDRGDeptSummary"
        set rs.QueryName = "ByYearMonth"
        do rs.Execute(year, month)
        
        set totalProfit = 0
        set totalCaseCount = 0
        while (rs.Next()) {
            if (deptCode = "") || (rs.Data("DeptCode") = deptCode) {
                set totalProfit = totalProfit + rs.Data("ProfitAmount")
                set totalCaseCount = totalCaseCount + rs.Data("TotalCaseCount")
            }
        }
        
        set item.profitAmount = totalProfit
        set item.caseCount = totalCaseCount
        do dataList.%Push(item)
        
        // 下一个月
        set month = month + 1
        if (month > 12) {
            set month = 1
            set year = year + 1
        }
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = dataList
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 重新计算盈亏数据
/// Code: 02010205
ClassMethod RecalculateProfit(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    set year = $lg(params,1)
    set month = $lg(params,2)
    set deptCode = $lg(params,3)
    
    if ((year = "") || (month = "")) {
        set result.errorCode = "1001"
        set result.errorMessage = "年份和月份不能为空"
        quit result
    }
    
    // 计算科室汇总数据
    set sql = "SELECT DeptCode, DeptName, COUNT(*) AS CaseCount, "_ 
              "SUM(TotalFee) AS TotalFee, SUM(DRGPayStandard) AS PayStandard "_ 
              "FROM BS_DRGMedInsuMedicalRecord "_ 
              "WHERE $P(AdmDate,'-',1) = '" _ year _ "' AND $P(AdmDate,'-',2) = '" _ $fn(month,"",0) _ "'"
    
    if (deptCode '= "") {
        set sql = sql _ " AND DeptCode = '" _ deptCode _ "'"
    }
    set sql = sql _ " GROUP BY DeptCode, DeptName"
    
    set rs = ##class(%ResultSet).%New()
    set rs.Query = sql
    do rs.Execute()
    
    set count = 0
    while (rs.Next()) {
        // 检查是否已存在汇总记录
        set existRs = ##class(%ResultSet).%New()
        set existRs.ClassName = "User.BSDRGDeptSummary"
        set existRs.QueryName = "ByYearMonthDept"
        do existRs.Execute(year, month, rs.Data("DeptCode"))
        
        if (existRs.Next()) {
            // 更新
            set summary = ##class(User.BSDRGDeptSummary).%OpenId(existRs.Data("ID"))
        } else {
            // 新增
            set summary = ##class(User.BSDRGDeptSummary).%New()
            set summary.Year = year
            set summary.Month = month
            set summary.DeptCode = rs.Data("DeptCode")
        }
        
        set summary.DeptName = rs.Data("DeptName")
        set summary.TotalCaseCount = rs.Data("CaseCount")
        set summary.TotalFee = rs.Data("TotalFee")
        set summary.DRGPayStandard = rs.Data("PayStandard")
        set summary.ProfitAmount = rs.Data("PayStandard") - rs.Data("TotalFee")
        
        if (rs.Data("TotalFee") > 0) {
            set summary.ProfitRate = ((rs.Data("PayStandard") - rs.Data("TotalFee")) / rs.Data("TotalFee")) * 100
        }
        
        set summary.GroupedCaseCount = rs.Data("CaseCount")
        set summary.CreateDate = +$h
        
        do summary.%Save()
        set count = count + 1
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = {"recalculatedCount": count}
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询科室汇总
/// Code: 02010206
ClassMethod QueryDeptSummary(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    set year = $lg(params,1)
    set month = $lg(params,2)
    set deptCode = $lg(params,3)
    
    if ((year = "") || (month = "")) {
        set result.errorCode = "1001"
        set result.errorMessage = "年份和月份不能为空"
        quit result
    }
    
    set dataList = ##class(%Library.DynamicArray).%New()
    
    set rs = ##class(%ResultSet).%New()
    if (deptCode = "") {
        set rs.ClassName = "User.BSDRGDeptSummary"
        set rs.QueryName = "ByYearMonth"
        do rs.Execute(year, month)
    } else {
        set rs.ClassName = "User.BSDRGDeptSummary"
        set rs.QueryName = "ByYearMonthDept"
        do rs.Execute(year, month, deptCode)
    }
    
    while (rs.Next()) {
        set item = ##class(%Library.DynamicObject).%New()
        set item.deptCode = rs.Data("DeptCode")
        set item.deptName = rs.Data("DeptName")
        set item.totalCaseCount = rs.Data("TotalCaseCount")
        set item.groupedCaseCount = rs.Data("GroupedCaseCount")
        set item.groupRate = rs.Data("GroupRate")
        set item.totalFee = rs.Data("TotalFee")
        set item.drgPayStandard = rs.Data("DRGPayStandard")
        set item.profitAmount = rs.Data("ProfitAmount")
        set item.profitRate = rs.Data("ProfitRate")
        set item.cmi = rs.Data("CMI")
        set item.avgHospitalDays = rs.Data("AvgHospitalDays")
        set item.avgFee = rs.Data("AvgFee")
        do dataList.%Push(item)
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = dataList
    
    quit result
}

}
