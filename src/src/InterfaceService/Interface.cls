Class src.InterfaceService.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存接口服务配置
/// Code:		 01020001 -> 01010016
ClassMethod SaveInterfaceServiceConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.InterfaceServiceConfig).SaveInterfaceServiceConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询接口服务配置
/// Code:		 01020002 -> 01010017
ClassMethod GetInterfaceServiceConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.InterfaceService.InterfaceServiceConfig).GetInterfaceServiceConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询接口服务配置下拉数据
/// Code:		 01020003 -> 01010018
ClassMethod GetInterfaceServiceSelectData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.InterfaceService.InterfaceServiceConfig).GetSelectData(postObj)
}

}
