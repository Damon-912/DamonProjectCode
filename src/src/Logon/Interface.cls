Class src.Logon.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 校验登录用户
/// code: 01010001
ClassMethod IsValidUser(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Logon.Logon).IsValidUser(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 用户登录
/// code: 01010002
ClassMethod Logon(postObj) As %Library.DynamicObject
{
	new (postObj,%session)
	//Set ^zTest("2")=%session.SessionId
	quit ##class(src.Logon.Logon).Logon(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 用户注销
/// code: 01010003
ClassMethod Logout(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Logon.Logon).Logout(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 登录权限列表
/// code: 01010004
ClassMethod GetLogonGroupByUserId(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Logon.Logon).GetLogonGroupByUserId(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 下拉列表
/// code: 01010005
ClassMethod GetSelectList(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Logon.Logon).GetSelectList(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 修改默认登录角色
/// code: 01010041
ClassMethod UpdateLogonGroupById(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Logon.Logon).UpdateLogonGroupById(postObj)
}

}
