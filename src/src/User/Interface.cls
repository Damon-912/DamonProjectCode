Class src.User.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 用户分页信息查询
/// code: 01030101
ClassMethod FindUserDetail(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.User.User).FindUserDetail(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 新增用户信息
/// code: 01030102
ClassMethod AddUserConf(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.User.User).AddUserConf(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 修改用户信息
/// code: 01030103
ClassMethod UpdateUserConf(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.User.User).UpdateUserConf(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 新增用户申请
/// code: 01030105
ClassMethod UserApply(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.User.UserAuditLog).UserApply(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 审核用户申请
/// code: 01030106
ClassMethod Aduit(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.User.UserAuditLog).Aduit(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 查询用户申请分页信息
/// code: 01030107
ClassMethod FindApplyLog(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.User.UserAuditLog).FindApplyLog(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 查询用户申请详情
/// code: 01030108
ClassMethod UserAuditLogDetail(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.User.UserAuditLog).UserAuditLogDetail(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 保存用户权限角色
/// code: 01030109
ClassMethod SaveUserLogonLoc(postObj) As %Library.DynamicObject
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set id=jsonObj.userLogonLocID
	if id=""{
		quit ##class(src.User.UserLogonLoc).SaveUserLogonLoc(postObj)
	}else{
		quit ##class(src.User.UserLogonLoc).UpdateUserLogonLoc(postObj)
	}
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 删除用户权限角色
/// code: 01030110
ClassMethod DeleteUserLogon(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.User.UserLogonLoc).DeleteUserLogon(postObj)
}

/// Creator:     lyp
/// CreatDate:   2022-06-30
/// Description: 根据ID查询用户信息
/// code: 01030111
ClassMethod GetUserDetail(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.User.UserLogonLoc).GetGroupByUserId(postObj)
}

}
