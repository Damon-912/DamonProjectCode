Class src.Component.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存组件主表配置
/// Code:		 01020006 -> 01010021
ClassMethod SaveReactComponentConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).SaveReactComponentConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件主表配置
/// Code:		 01020007 -> 01010022
ClassMethod GetReactComponentConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).GetReactComponentConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存组件table表配置
/// Code:		 01020008 -> 01010023
ClassMethod SaveReactComTableConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).SaveReactComTableConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件table表配置
/// Code:		 01020009 -> 01010024
ClassMethod GetReactComTableConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).GetReactComTableConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存组件table表配置
/// Code:		 01020010 -> 01010025
ClassMethod SaveReactComFieldConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).SaveReactComFieldConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件table表配置
/// Code:		 01020011 -> 01010026
ClassMethod GetReactComFieldConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).GetReactComFieldConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件table下拉数据
/// Code:		 01020012 -> 01010027
ClassMethod GetComTableSelectData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).GetComTableSelectData()
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件field下拉数据
/// Code:		 01020013 -> 01010028
ClassMethod GetFieldType(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).GetFieldType()
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 删除组件table数据
/// Code:		 01020014 -> 01010029
ClassMethod DeleteReactComTableConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).DeleteReactComTableConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 删除组件field数据
/// Code:		 01020015 -> 01010030
ClassMethod DeleteReactComFieldConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).DeleteReactComFieldConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存组建列权限配置信息
/// Code:		 01010038
ClassMethod SaveComponetAuthConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).SaveComponetAuthConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 删除组件配置权限
/// Code:		 01010039
ClassMethod DeleteComponetAuthConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).DeleteComponetAuthConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 获取用户组件编辑权限
/// Code:		 01010040
ClassMethod GetGroupAuthLevel(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).GetGroupAuthLevel(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 获取动态表头
/// Code:		 01040073
ClassMethod GetComponetTableData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).GetComponetTableData(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存组件form表配置
/// Code:		 01010044
ClassMethod SaveReactComFormConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).SaveReactComFormConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件form表配置
/// Code:		 01010045
ClassMethod GetReactComFormConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).GetReactComFormConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存组件form表配置
/// Code:		 01010046
ClassMethod SaveReactComBtnConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).SaveReactComBtnConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件form表配置
/// Code:		 01010047
ClassMethod GetReactComBtnConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).GetReactComBtnConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 删除组件table数据
/// Code:		 01010048
ClassMethod DeleteReactFormConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).DeleteReactFormConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 删除组件field数据
/// Code:		 01010049
ClassMethod DeleteReactComBtnConfig(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).DeleteReactComBtnConfig(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 组件数据排序
/// Code:		 01010051
ClassMethod SaveReactComSeq(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).SaveReactComSeq(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 复制组件数据
/// Code:		 01010052
ClassMethod CopyComponent(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).CopyComponent(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-9-19
/// Description: 获取关联与跳转数据
/// Code:		 01040288
ClassMethod GetLinkFieldList(postData As %String)
{
	new (postData)
	quit ##class(src.Component.ReactComponent).GetLinkFieldList(postData)
}

/// Creator:     HYG
/// CreatDate:   2024-05-19
/// Description: 菜单获取动态表头
/// Code:		 01040073
ClassMethod GetMenuComponetTableData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).GetMenuComponetTableData(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 保存组件整合
/// Code:		 01010060
ClassMethod SaveReactComponentInteger(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).SaveReactComponentInteger(postObj)
}

/// Creator:     TC
/// CreatDate:   2022-06-30
/// Description: 查询组件(维护界面用)
/// Code:		 01010061
ClassMethod GetReactComponentInteger(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Component.ReactComponent).GetReactComponentInteger(postObj)
}

}
