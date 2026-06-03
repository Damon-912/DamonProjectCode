Import SQLUSER

/// Creator:     系统
/// CreatDate:   2026-05-29
/// Description: DRG特异化分组独立匹配引擎
///              根据患者诊断组、手术组及地区信息，查询 HB_DRGSpecialGroup 规则表进行匹配
///              解耦自 GroupDevice，可独立用于事前预分组评估、批量规则校验等场景
///              零对 GroupDevice 的依赖
/// Usage:       Set result=##class(src.DRG.SpecialGroupEngine).Match(patientInfo, regionInfo, groupYear)
Class src.DRG.SpecialGroupEngine Extends %RegisteredObject
{

/// 将分隔符分割的编码字符串拆分为$LIST列表
/// 支持：英文逗号"," 中文逗号"，" 分号";" 斜杠"/" 空格" "作为分隔符
/// 注意：+ 不作为分隔符（保护ICD星剑号复合编码如 e88.906+h28.1*）
ClassMethod SplitCodes(codeStr As %String) As %List
{
	if (codeStr = "")
	{
		quit ""
	}
	
	; 将所有分隔符统一替换为英文逗号（不含 +）
	set normalized = $TRANSLATE(codeStr, "，;/ ", ",,,,")
	
	set list = ""
	set count = $LENGTH(normalized, ",")
	for i = 1:1:count
	{
		set oneCode = $ZSTRIP($PIECE(normalized, ",", i), "<>W")
		if (oneCode '= "")
		{
			set list = list _ $LISTBUILD(oneCode)
		}
	}
	quit list
}

/// 判断两个ICD编码是否匹配（双向包含/前缀关系）
/// 入参H25.900 能匹配 存储的H25.9、H25（子类→父类）
/// 入参H25     能匹配 存储的H25.9、H25.001（父类→子类）
/// H25.900 → H25.100（同级兄弟，互不为前缀） → false
ClassMethod IsCodeMatch(code1 As %String, code2 As %String) As %Boolean
{
	if (code1 = "") || (code2 = "")
	{
		quit 0
	}
	
	; 精确相等直接匹配
	if (code1 = code2)
	{
		quit 1
	}
	
	; 双向包含判断：一方是另一方的子串
	; code1包含code2 → code2是code1的前缀（如code1=H25.900, code2=H25）
	if ($FIND(code1, code2) = ($LENGTH(code2) + 1))
	{
		quit 1
	}
	; code2包含code1 → code1是code2的前缀（如code1=H25, code2=H25.9）
	if ($FIND(code2, code1) = ($LENGTH(code1) + 1))
	{
		quit 1
	}
	
	quit 0
}

/// Description: 解析GroupFactors结构化入组因素字符串
///              格式: "主要诊断+主要手术"  → [["主要诊断"],["主要手术"]]
///              格式: "主要诊断或次要诊断+主要手术" → [["主要诊断","次要诊断"],["主要手术"]]
///              + 表示 AND 关系，或 表示 OR 关系
/// Input:       groupFactors - 入组因素字符串
/// Output:      $List格式的二维结构：外层是AND关系的组列表，内层是OR关系的字段名列表
///              $LB($LB("1","2"), $LB("3")) 表示 (字段1或字段2)且(字段3)
///              字段映射: "主要诊断"→1, "次要诊断"→2, "主要手术"→3, "次要手术"→4
ClassMethod ParseGroupFactors(groupFactors As %String) As %List
{
	if (groupFactors = "") quit ""
	
	set result = ""
	; 按 + 号分割得到 AND 组
	set andGroups = $LENGTH(groupFactors, "+")
	for andIdx = 1:1:andGroups {
		set andGroup = $ZSTRIP($PIECE(groupFactors, "+", andIdx), "<>W")
		if (andGroup = "") continue
		
		; 在各 AND 组内按"或"分割得到 OR 项
		set orList = ""
		set orCount = $LENGTH(andGroup, "或")
		for orIdx = 1:1:orCount {
			set orItem = $ZSTRIP($PIECE(andGroup, "或", orIdx), "<>W")
			if (orItem = "") continue
			
			; 将中文字段名映射为数字编码
			if (orItem = "主要诊断") {
				set orList = orList _ $LISTBUILD(1)
			} elseif (orItem = "次要诊断") {
				set orList = orList _ $LISTBUILD(2)
			} elseif (orItem = "主要手术") {
				set orList = orList _ $LISTBUILD(3)
			} elseif (orItem = "次要手术") {
				set orList = orList _ $LISTBUILD(4)
			}
		}
		
		if ($LISTLENGTH(orList) > 0) {
			set result = result _ $LISTBUILD(orList)
		}
	}
	
	quit result
}

/// Description: 核心匹配逻辑（私有方法，被 Match 和 MatchByHospInfo 复用）
/// Input:       patientInfo - 患者诊断/手术数据
///              provinceDr - 省ID
///              cityDr - 市ID
///              admvs - 行政区划代码
///              groupYear - 分组方案年份
/// Output:      $LIST(matchDRGCode, matchDRGName, matchGroupFactors, matchRuleId, matchRemark)
///              未命中返回 ""
ClassMethod MatchSingle(patientInfo As %Library.DynamicObject, provinceDr As %String, cityDr As %String, admvs As %String, groupYear As %String) As %List [ Internal, Private ]
{
	; 内部匹配状态变量
	set matchDRGCode = ""
	set matchDRGName = ""
	set matchGroupFactors = ""
	set matchRuleId = ""
	set matchRemark = ""
	
	; 获取患者数据
	set mainDiagCode = patientInfo.mainDiagnosisCode
	set mainOperationCode = patientInfo.mainOperationCode
	set diseinfo = patientInfo.diseInfo
	if (diseinfo = "") || ('$ISOBJECT(diseinfo)) set diseinfo = ##class(%DynamicArray).%New()
	set oprninfo = patientInfo.oprnInfo
	if (oprninfo = "") || ('$ISOBJECT(oprninfo)) set oprninfo = ##class(%DynamicArray).%New()
	
	set adrgCode = patientInfo.adrg
	
	; 构建SQL查询（含Remark字段）
	set sql = " SELECT ID, DRGCode, DRGName, PrincipalDiagnosis, SecondaryDiagnosis,"
			_ " MajorProcedure, SecondaryProcedure, GroupFactors, Remark"
			_ " FROM HB_DRGSpecialGroup"
			_ " WHERE 1=1"
	
	if adrgCode '= "" {
		set sql = sql _ " AND LEFT(DRGCode,3)='"_adrgCode_"'"
	}
	if provinceDr '= "" {
		set sql = sql _ " AND Province_Dr='" _ provinceDr _ "'"
	}
	if cityDr '= "" {
		set sql = sql _ " AND City_Dr='" _ cityDr _ "'"
	}
	if (admvs '= "") {
		set admvsPrefix = $EXTRACT(admvs, 1, 4)
		set sql = sql _ " AND (Admvs='" _ admvs _ "' OR LEFT(Admvs,4)='" _ admvsPrefix _ "' OR Admvs='')"
	}
	if groupYear '= "" {
		set sql = sql _ " AND (Year='" _ groupYear _ "' OR Year IS NULL OR Year='')"
	}

	; 按DRGCode排序
	set sql = sql _ " ORDER BY DRGCode"
	
	set sqlObj = ##class(%SQL.Statement).%New(1)
	set sc = sqlObj.%Prepare(sql)
	if (sc '= 1) {
		quit ""
	}
	set rs = sqlObj.%Execute()
	
	; 逐条遍历匹配
	while rs.%Next() 
	{
		set ruleId = rs.ID
		set drgCode = rs.DRGCode
		set drgName = rs.DRGName
		set principalDiag = rs.PrincipalDiagnosis
		set secondaryDiag = rs.SecondaryDiagnosis
		set majorProc = rs.MajorProcedure
		set secondaryProc = rs.SecondaryProcedure
		set groupFactors = rs.GroupFactors
		set remark = rs.Remark
		
		; 解析GroupFactors获取匹配逻辑
		set parsedFactors = ..ParseGroupFactors(groupFactors)
		
		; 如果没有GroupFactors，默认所有非空字段为AND关系
		if (parsedFactors = "") {
			set parsedFactors = ""
			if principalDiag '= "" {
				set parsedFactors = parsedFactors _ $LISTBUILD($LISTBUILD(1))
			}
			if secondaryDiag '= "" {
				set parsedFactors = parsedFactors _ $LISTBUILD($LISTBUILD(2))
			}
			if majorProc '= "" {
				set parsedFactors = parsedFactors _ $LISTBUILD($LISTBUILD(3))
			}
			if secondaryProc '= "" {
				set parsedFactors = parsedFactors _ $LISTBUILD($LISTBUILD(4))
			}
		}
		
		; 按GroupFactors解析结果执行AND/OR匹配
		set matched = 1
		set andGroupCount = $LISTLENGTH(parsedFactors)
		
		for agIdx = 1:1:andGroupCount {
			set orList = $LISTGET(parsedFactors, agIdx)
			set orCount = $LISTLENGTH(orList)
			set orMatched = 0
			
			for oi = 1:1:orCount {
				set fieldCode = $LISTGET(orList, oi)
				set fieldMatched = 0
				
				if fieldCode = 1 {
					; 主要诊断匹配
					set fieldMatched = ..IsCodeMatch(mainDiagCode, principalDiag)
					if 'fieldMatched {
						set diagList = ..SplitCodes(principalDiag)
						set dlCount = $LISTLENGTH(diagList)
						for di = 1:1:dlCount {
							if ..IsCodeMatch(mainDiagCode, $LISTGET(diagList, di)) {
								set fieldMatched = 1
								quit
							}
						}
					}
					
				} elseif fieldCode = 2 {
					; 次要诊断匹配
					set secondaryDiagList = ..SplitCodes(secondaryDiag)
					set sdlCount = $LISTLENGTH(secondaryDiagList)
					for sj = 1:1:sdlCount {
						set oneRuleDiag = $LISTGET(secondaryDiagList, sj)
						if oneRuleDiag = "" continue
						
						set diSize = diseinfo.%Size()
						for di = 0:1:diSize - 1 {
							set diseItem = diseinfo.%Get(di)
							if (diseItem.mainFlag = "1") && (diseItem.diagSn = "1") { continue }
							set patientDiag = diseItem.diagCode
							if patientDiag = "" continue
							
							if ..IsCodeMatch(patientDiag, oneRuleDiag) {
								set fieldMatched = 1
								quit
							}
						}
						if fieldMatched quit
					}
					
				} elseif fieldCode = 3 {
					; 主要手术匹配
					set procList = ..SplitCodes(majorProc)
					set plCount = $LISTLENGTH(procList)
					for pi = 1:1:plCount {
						if ..IsCodeMatch(mainOperationCode, $LISTGET(procList, pi)) {
							set fieldMatched = 1
							quit
						}
					}
					
				} elseif fieldCode = 4 {
					; 次要手术匹配
					set secondaryProcList = ..SplitCodes(secondaryProc)
					set splCount = $LISTLENGTH(secondaryProcList)
					for sp = 1:1:splCount {
						set oneRuleProc = $LISTGET(secondaryProcList, sp)
						if oneRuleProc = "" continue
						
						set opSize = oprninfo.%Size()
						for oi2 = 0:1:opSize - 1 {
							set oprnItem = oprninfo.%Get(oi2)
							if (oprnItem.mainFlag = "1") && (oprnItem.oprnSn = "1") { continue }
							set patientProc = oprnItem.oprnCode
							if patientProc = "" continue
							
							if ..IsCodeMatch(patientProc, oneRuleProc) {
								set fieldMatched = 1
								quit
							}
						}
						if fieldMatched quit
					}
				}
				
				; OR组内任一匹配成功即通过
				if fieldMatched {
					set orMatched = 1
					quit
				}
			}
			
			; AND组内有一个未匹配则整条规则不命中
			if 'orMatched {
				set matched = 0
				quit
			}
		}
		
		; 全部AND组匹配成功 → 返回匹配结果（$LIST格式）
		if matched {
			set matchDRGCode = drgCode
			set matchDRGName = drgName
			set matchGroupFactors = groupFactors
			set matchRuleId = ruleId
			set matchRemark = remark
			
			quit  ; 匹配到第一条规则即返回
		}
	}
	
	; 未命中返回空
	if matchDRGCode = "" quit ""
	
	quit $LISTBUILD(matchDRGCode, matchDRGName, matchGroupFactors, matchRuleId, matchRemark)
}

/// Description: 特异化分组匹配入口（单地区）
///              根据患者诊断/手术数据和地区信息，查询特异化分组规则表进行匹配
/// Input:       patientInfo - %DynamicObject，包含：
///                 mainDiagnosisCode - 主诊断编码
///                 mainOperationCode - 主手术编码  
///                 diseInfo - 诊断信息数组（各元素含 mainFlag, diagSn, diagCode）
///                 oprnInfo - 手术信息数组（各元素含 mainFlag, oprnSn, oprnCode）
///              regionInfo - %DynamicObject，包含：
///                 provinceDr - 省ID
///                 cityDr - 市ID
///                 admvs - 行政区划代码
///              groupYear - 分组方案年份
/// Output:      %DynamicObject
///              匹配成功: { errorCode:"0", errorMessage:"", result:{ drgCode, drgDesc, matchRuleId, groupFactors, remark } }
///              匹配失败: { errorCode:"-1", errorMessage:"未命中特异化分组规则" }
///              参数错误: { errorCode:"-1", errorMessage:"缺少地区信息，无法执行特异化分组匹配" }
///              异常:     { errorCode:"-99", errorMessage:"特异化分组匹配异常：..." }
/// Debug:       w ##class(src.DRG.SpecialGroupEngine).Match({}, {}, "").%ToJSON()
ClassMethod Match(patientInfo As %Library.DynamicObject, regionInfo As %Library.DynamicObject, groupYear As %String) As %Library.DynamicObject
{
	set resultObj = ##class(%DynamicObject).%New()
	set resultObj.errorCode = "-1"
	set resultObj.errorMessage = "未命中特异化分组规则"
	set resultObj.result = ##class(%DynamicObject).%New()
	
	try 
	{
		; 地区校验
		set provinceDr = regionInfo.provinceDr
		set cityDr = regionInfo.cityDr
		set admvs = regionInfo.admvs
		
		if (provinceDr = "") && (cityDr = "") {
			set resultObj.errorMessage = "缺少地区信息，无法执行特异化分组匹配"
			quit
		}
		
		; 年份默认当前年份
		if (groupYear = "") set groupYear = $PIECE($ZDATE($HOROLOG, 3), "-", 1)
		
		; 调用核心匹配逻辑
		set matchResult = ..MatchSingle(patientInfo, provinceDr, cityDr, admvs, groupYear)
		
		if (matchResult '= "") {
			set resultObj.errorCode = "0"
			set resultObj.errorMessage = ""
			
			set matchDRGCode = $LISTGET(matchResult, 1)
			set matchDRGName = $LISTGET(matchResult, 2)
			set matchGroupFactors = $LISTGET(matchResult, 3)
			set matchRuleId = $LISTGET(matchResult, 4)
			set matchRemark = $LISTGET(matchResult, 5)
			
			if ('$ISOBJECT(resultObj.result)) || (resultObj.result = "") {
				set resultObj.result = ##class(%DynamicObject).%New()
			}
			
			set resultObj.result.drgCode = matchDRGCode
			if matchGroupFactors '= "" {
				set resultObj.result.drgDesc = matchDRGName _ "（特异化分组：" _ matchGroupFactors _ "）"
			} else {
				set resultObj.result.drgDesc = matchDRGName _ "（特异化分组）"
			}
			set resultObj.result.matchRuleId = matchRuleId
			set resultObj.result.groupFactors = matchGroupFactors
			set resultObj.result.remark = matchRemark
		}
		
	} catch(e) {
		set status = e.AsStatus()
		set errorMessage = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
		set resultObj.errorCode = "-99"
		set resultObj.errorMessage = "特异化分组匹配异常：" _ errorMessage
	}
	
	quit resultObj
}

/// Description: 根据医疗机构数组（hospInfo）循环匹配各地特异化DRG分组方案
///              逐家医院查询 CB_Hospital 获取其所在地区的 provinceDr、cityDr、admvs
///              对每家医院分别调用核心匹配逻辑，命中第一家即返回
/// Input:       patientInfo - %DynamicObject，患者诊断/手术数据（同 Match）
///              hospInfo - %DynamicArray，医疗机构数组，每个元素含：
///                 code - 医疗机构编码（OrganizationCode，对应 CB_Hospital）
///                 name - 医疗机构名称
///                 hisHospCode - HIS医院代码（可选）
///              groupYear - 分组方案年份
/// Output:      %DynamicObject
///              匹配成功: { errorCode:"0", errorMessage:"", 
///                         result:{ drgCode, drgDesc, matchRuleId, groupFactors, remark, 
///                                  hospCode, hospName, admvs } }
///              全部未命中: { errorCode:"-1", errorMessage:"未命中特异化分组规则" }
///              无hospInfo: { errorCode:"-1", errorMessage:"缺少医疗机构信息，无法执行特异化分组匹配" }
/// Debug:       w ##class(src.DRG.SpecialGroupEngine).MatchByHospInfo({}, [], "").%ToJSON()
ClassMethod MatchByHospInfo(patientInfo As %Library.DynamicObject, hospInfo As %Library.DynamicArray, groupYear As %String) As %Library.DynamicObject
{
	set resultObj = ##class(%DynamicObject).%New()
	set resultObj.errorCode = "-1"
	set resultObj.errorMessage = "未命中特异化分组规则"
	set resultObj.result = ##class(%DynamicObject).%New()
	
	try 
	{
		; 校验 hospInfo
		if ('$ISOBJECT(hospInfo)) || (hospInfo.%Size() = 0) 
		{
			set resultObj.errorMessage = "缺少医疗机构信息，无法执行特异化分组匹配"
			quit
		}
		
		; 年份默认当前年份
		if (groupYear = "") set groupYear = $PIECE($ZDATE($HOROLOG, 3), "-", 1)
		
		; 循环每家医院
		set hospCount = hospInfo.%Size()
		for hi = 0:1:hospCount - 1 
		{
			set hospItem = hospInfo.%Get(hi)
			set hospCode = hospItem.code
			if hospCode = "" continue
			
			; 查询 CB_Hospital 获取该医院的省市和行政区划信息
			set (provinceDr, cityDr, admvs) = ""
			&sql(SELECT ProvID_Dr, CityID_Dr, CityID_Dr->Code INTO :provinceDr, :cityDr, :admvs 
			     FROM CB_Hospital WHERE OrganizationCode = :hospCode)
			
			if (SQLCODE '= 0) continue
			if (provinceDr = "") && (cityDr = "") continue
			
			; 调用核心匹配逻辑
			set matchResult = ..MatchSingle(patientInfo, provinceDr, cityDr, admvs, groupYear)
			
			if (matchResult '= "") {
				set resultObj.errorCode = "0"
				set resultObj.errorMessage = ""
				
				set matchDRGCode = $LISTGET(matchResult, 1)
				set matchDRGName = $LISTGET(matchResult, 2)
				set matchGroupFactors = $LISTGET(matchResult, 3)
				set matchRuleId = $LISTGET(matchResult, 4)
				set matchRemark = $LISTGET(matchResult, 5)
				
				if ('$ISOBJECT(resultObj.result)) || (resultObj.result = "") 
				{
					set resultObj.result = ##class(%DynamicObject).%New()
				}
				
				set resultObj.result.drgCode = matchDRGCode
				if matchGroupFactors '= "" 
				{
					set resultObj.result.drgDesc = matchDRGName _patientInfo.adrg_"（特异化分组：" _ matchGroupFactors _ "）"
				} 
				else 
				{
					set resultObj.result.drgDesc = matchDRGName _patientInfo.adrg_"（特异化分组）"
				}
				set resultObj.result.matchRuleId = matchRuleId
				set resultObj.result.groupFactors = matchGroupFactors
				set resultObj.result.remark = matchRemark
				set resultObj.result.hospCode = hospCode
				set resultObj.result.hospName = hospItem.name
				set resultObj.result.admvs = admvs
				
				quit  ; 命中第一家即返回
			}
		}
		
	} catch(e) {
		set status = e.AsStatus()
		set errorMessage = $replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"), "^", " ")
		set resultObj.errorCode = "-99"
		set resultObj.errorMessage = "特异化分组匹配异常：" _ errorMessage
	}
	
	quit resultObj
}

}
