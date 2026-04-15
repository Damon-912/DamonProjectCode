Import SQLUSER

/// Menu接口路由定义类
/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 提供菜单管理的REST接口路由
Class src.Menu.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 获取菜单树形结构
/// code: 10010001
ClassMethod GetMenuTree(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Menu.Service).GetMenuTree(postObj)
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 保存菜单(新增/修改)
/// code: 10010002
ClassMethod SaveMenu(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Menu.Service).SaveMenu(postObj)
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 删除菜单(逻辑删除)
/// code: 10010003
ClassMethod DeleteMenu(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Menu.Service).DeleteMenu(postObj)
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 初始化默认菜单(从App.tsx导入)
/// code: 10010004
ClassMethod InitDefaultMenus(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Menu.Service).InitDefaultMenus(postObj)
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 获取角色菜单权限
/// code: 10010005
ClassMethod GetRoleMenus(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Menu.Service).GetRoleMenus(postObj)
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 保存角色菜单权限
/// code: 10010006
ClassMethod SaveRoleMenus(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Menu.Service).SaveRoleMenus(postObj)
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 获取用户菜单(登录后调用)
/// code: 10010007
ClassMethod GetUserMenus(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Menu.Service).GetUserMenus(postObj)
}

}
