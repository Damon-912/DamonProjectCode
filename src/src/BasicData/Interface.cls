Class src.BasicData.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 保存平台字典
/// code: 01010010
ClassMethod SaveDictionaries(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Dictionaries).SaveDictionaries(postObj)
}

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 查询平台字典
/// 01010011
ClassMethod GetDictionariesList(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Dictionaries).GetDictionariesList(postObj)
}

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 删除平台字典
/// 01010012
ClassMethod DeleteDictionaries(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Dictionaries).DeleteDictionaries(postObj)
}

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 保存平台字典明细
/// 01010013
ClassMethod SaveDictionariesDetailed(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Dictionaries).SaveDictionariesDetailed(postObj)
}

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 查询平台字典明细
/// 01010014
ClassMethod GetDictionariesDetailedList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.BasicData.Dictionaries).GetDictionariesDetailedList(jsonObj)
}

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 删除平台字典明细
/// 01010015
ClassMethod DeleteDictionariesDetailed(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.BasicData.Dictionaries).DeleteDictionariesDetailed(jsonObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存接口服务配置
/// Code:		 01020001
ClassMethod SaveInterfaceServiceConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.InterfaceServiceConfig).SaveInterfaceServiceConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询接口服务配置
/// Code:		 01020002
ClassMethod GetInterfaceServiceConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.InterfaceServiceConfig).GetInterfaceServiceConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询接口服务配置下拉数据
/// Code:		 01020003
ClassMethod GetInterfaceServiceSelectData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.InterfaceServiceConfig).GetSelectData(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存消息提示配置
/// Code:		 01020004 -> 01010019
ClassMethod SaveMessageConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Interface.Message).SaveMessageConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询消息提示配置
/// Code:		 01020005 -> 01010020
ClassMethod GetMessageConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Interface.Message).GetMessageConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存组件主表配置
/// Code:		 01020006 -> 01010021
ClassMethod SaveReactComponentConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).SaveReactComponentConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件主表配置
/// Code:		 01020007 -> 01010022
ClassMethod GetReactComponentConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).GetReactComponentConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存组件table表配置
/// Code:		 01020008 -> 01010023
ClassMethod SaveReactComTableConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).SaveReactComTableConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件table表配置
/// Code:		 01020009 -> 01010024
ClassMethod GetReactComTableConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).GetReactComTableConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存组件table表配置
/// Code:		 01020010 -> 01010025
ClassMethod SaveReactComFieldConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).SaveReactComFieldConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件table表配置
/// Code:		 01020011 -> 01010026
ClassMethod GetReactComFieldConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).GetReactComFieldConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件table下拉数据
/// Code:		 01020012 -> 01010027
ClassMethod GetComTableSelectData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).GetComTableSelectData()
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件field下拉数据
/// Code:		 01020013 -> 01010028
ClassMethod GetFieldType(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).GetFieldType()
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 删除组件table数据
/// Code:		 01020014 -> 01010029
ClassMethod DeleteReactComTableConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).DeleteReactComTableConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 删除组件field数据
/// Code:		 01020015 -> 01010030
ClassMethod DeleteReactComFieldConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).DeleteReactComFieldConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存角色
/// Code:		 01020016 -> 01010031
ClassMethod SaveGroup(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).SaveGroup(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询角色
/// Code:		 01020017 -> 01010032
ClassMethod GetGroupList(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).GetGroupList(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 根据角色查询菜单
/// Code:		 01020018 -> 01010033
ClassMethod GetGroupMenuDetail(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).GetGroupMenuDetail(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 获取角色未添加的菜单
/// Code:		 01020019 -> 01010034
ClassMethod GetUnaddData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).GetUnaddData(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 删除角色菜单
/// Code:		 01020020 -> 01010035
ClassMethod DeleteGroupMenu(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).DeleteGroupMenu(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 角色菜单上下移保存
/// Code:		 01020021 -> 01010036
ClassMethod SaveMenuSort(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).SaveMenuSort(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存角色菜单
/// Code:		 01020022 -> 01010037
ClassMethod SaveGroupMenu(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).SaveGroupMenu(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询角色菜单
/// Code:		 3001
ClassMethod GetMenuByGroup(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).GetMenuByGroup(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询角色路由
/// Code:		 3002
ClassMethod GetGroupRouter(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).GetGroupRouter(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 获取动态表头
/// Code:		 01040073
ClassMethod GetComponetTableData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).GetComponetTableData(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存组建列权限配置信息
/// Code:		 01010038
ClassMethod SaveComponetAuthConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).SaveComponetAuthConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 删除组件配置权限
/// Code:		 01010039
ClassMethod DeleteComponetAuthConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.ReactComponentConfig).DeleteComponetAuthConfig(postObj)
}

/// Creator:     liangjiaquan
/// CreatDate:   2022-10-12
/// Description: 获取产品分类字典
/// Code:		 2308
ClassMethod GetProductCat(postData)
{
	new (postData)
	quit ##class(src.BasicData.ProductCat).GetProductCat()
}

/// Creator:     liangjiaquan
/// CreatDate:   2022-10-12
/// Description: 获取产品模块字典
/// Code:		 2309
ClassMethod GetProductModule(postData)
{
	new (postData)
	quit ##class(src.BasicData.ProductCat).GetProductModule(postData)
}

/// Creator:     HYG
/// CreatDate:   2022-10-12
/// Description: 获取性别下拉数据
/// Code:		01010054 
ClassMethod GetSexData(postData)
{
	new (postData)
	quit ##class(src.BasicData.SelectDate).GetSexData(postData)
}

/// Creator:     HYG
/// CreatDate:   2022-10-12
/// Description: 获取证件下拉数据
/// Code:		 01010055
ClassMethod GetCredTypeData(postData)
{
	new (postData)
	quit ##class(src.BasicData.SelectDate).GetCredTypeData(postData)
}

}
