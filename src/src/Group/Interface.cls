Class src.Group.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     HYG
/// CreatDate:   2022-06-30
/// Description: 菜单初始化
/// code: 03010001
ClassMethod GetInitialize(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Group.MenuDetail).GetInitialize(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 新增菜单配
/// code: 03010001
ClassMethod AddMenuConf(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Group.MenuDetail).AddMenuConf(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 修改菜单配置
/// code: 03010002
ClassMethod UpdateMenuConf(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Group.MenuDetail).UpdateMenuConf(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 删除菜单配置
/// code: 03010003
ClassMethod DeleteMenuConf(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Group.MenuDetail).DeleteMenuConf(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 查询菜单配置分页
/// code: 03010004
ClassMethod FindMenuDetail(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Group.MenuDetail).FindMenuDetail(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 查询菜单配置列表
/// code: 03010005
ClassMethod FindMenuList(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Group.MenuDetail).FindMenuList(postObj)
}

/// Creator:     HYG
/// CreatDate:   2022-06-30
/// Description: 角色初始化
/// code: 03010001
ClassMethod GetGroupInitialize(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).GetGroupInitialize(postObj)
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

/// Creator:     HYG
/// CreatDate:   2024-05-23
/// Description: 数据权限类型下拉框
/// Code:		 
ClassMethod DataAuthorityType(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).DataAuthorityType(postObj)
}

/// Creator:     HYG
/// CreatDate:   2024-05-23
/// Description: 角色下拉框
/// Code:		 01010057
ClassMethod GetGroupSelect(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.BasicData.Group).GetGroupSelect(postObj)
}

/// Creator:     HYG
/// CreatDate:   2024-05-23
/// Description: 查询医院角色菜单
/// Code:		 
ClassMethod FindGroupMenuAuthDetail(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Group.HospGroupMenuAuth).FindGroupMenuAuthDetail(postObj)
}

/// Creator:     HYG
/// CreatDate:   2024-05-23
/// Description: 保存医院角色菜单表
/// Code:		 
ClassMethod SaveGroupMenuAuth(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Group.HospGroupMenuAuth).SaveGroupMenuAuth(postObj)
}

/// Creator:     HYG
/// CreatDate:   2024-05-19
/// Description: 角色菜单获取动态表头
/// Code:		 01010062
ClassMethod GetGroupMenuComponetTableData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Group.HospGroupMenuAuth).GetGroupMenuComponetTableData(postObj)
}

/// Creator:     HYG
/// CreatDate:   2024-05-19
/// Description: 保存角色菜单动态表头
/// Code:		 01010063
ClassMethod SaveGroupMenuComponetTableData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Group.HospGroupMenuAuth).SaveGroupMenuComponetTableData(postObj)
}

}
