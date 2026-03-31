Class src.Hospital.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 新增医疗机构信息
/// code: 01050101
ClassMethod AddHospConf(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Hospital.Hospital).AddHospConf(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 修改医疗机构信息
/// code: 01050102
ClassMethod UpdateHospConf(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Hospital.Hospital).UpdateHospConf(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 删除医疗机构信息
/// code: 01050104
ClassMethod DeleteHospConf(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Hospital.Hospital).DeleteHospConf(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 查询医疗机构信息分页
/// code: 01050103
ClassMethod FindHospDetail(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Hospital.Hospital).FindHospDetail(postObj)
}

/// Creator:     HYG
/// CreatDate:   2022-06-30
/// Description: 查询医疗机构信息
/// code: 01050103
ClassMethod FindHospDetailList(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Hospital.Hospital).FindHospDetailList(postObj)
}

/// Creator:     System
/// CreatDate:   2026-03-29
/// Description: 初始化医疗机构接口配置到CB_MapInterface表
/// Debug:       d ##class(src.Hospital.Interface).InitInterfaceConfig()
ClassMethod InitInterfaceConfig() As %Status
{
	Set result = $$$OK
	Try {
		// 定义接口配置数据
		// Code, Descripts, ClassName, MethodName, ServiceType
		Set interfaces(1) = $ListBuild("01050101", "新增医疗机构信息", "src.Hospital.Interface", "AddHospConf", "A")
		Set interfaces(2) = $ListBuild("01050102", "修改医疗机构信息", "src.Hospital.Interface", "UpdateHospConf", "U")
		Set interfaces(3) = $ListBuild("01050104", "删除医疗机构信息", "src.Hospital.Interface", "DeleteHospConf", "D")
		Set interfaces(4) = $ListBuild("01050103", "查询医疗机构信息分页", "src.Hospital.Interface", "FindHospDetail", "S")
		
		Set key = ""
		For {
			Set key = $Order(interfaces(key))
			Quit:key=""
			
			Set data = interfaces(key)
			Set code = $ListGet(data, 1)
			Set desc = $ListGet(data, 2)
			Set className = $ListGet(data, 3)
			Set methodName = $ListGet(data, 4)
			Set serviceType = $ListGet(data, 5)
			
			// 检查是否已存在
			Set existingId = ##class(User.CBMapInterface).CodeExists(code)
			
			If existingId = "" {
				// 新增接口配置
				Set obj = ##class(User.CBMapInterface).%New()
				Set obj.Code = code
				Set obj.Descripts = desc
				Set obj.ClassName = className
				Set obj.MethodName = methodName
				Set obj.ServiceType = serviceType
				Set obj.SessionFlag = "Y"
				Set obj.TokenFlag = "N"
				Set obj.StartDate = $Piece($Horolog, ",", 1)
				
				Set sc = obj.%Save()
				If $$$ISERR(sc) {
					Write !, "保存接口 "_code_" 失败: "_$System.Status.GetErrorText(sc)
				} Else {
					Write !, "接口 "_code_" - "_desc_" 已添加"
				}
			} Else {
				Write !, "接口 "_code_" 已存在，跳过"
			}
		}
		
		Write !, !, "接口配置初始化完成"
	} Catch ex {
		Set result = ex.AsStatus()
		Write !, "初始化失败: "_$System.Status.GetErrorText(result)
	}
	
	Quit result
}

}
