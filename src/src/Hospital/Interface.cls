Class src.Hospital.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 新增医疗机构信息
/// code: 03020109
ClassMethod AddHospConf(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Hospital.Hospital).AddHospConf(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 修改医疗机构信息
/// code: 03020110
ClassMethod UpdateHospConf(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Hospital.Hospital).UpdateHospConf(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 删除医疗机构信息
/// code: 03020111
ClassMethod DeleteHospConf(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Hospital.Hospital).DeleteHospConf(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 查询医疗机构信息分页
/// code: 03020112
ClassMethod FindHospDetail(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Hospital.Hospital).FindHospDetail(postObj)
}

/// Creator:     HYG
/// CreatDate:   2022-06-30
/// Description: 查询医疗机构信息
/// code: 03020112
ClassMethod FindHospDetailList(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Hospital.Hospital).FindHospDetailList(postObj)
}

}
