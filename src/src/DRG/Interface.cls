Class src.DRG.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 分组器
/// code: 02010001		 
/// Input:{"params":[{"":""}]}
/// Debug
ClassMethod Device(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.GroupDevice).Device(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 分组预警 - 组合分组器+费用预警两个接口
/// code: 02010002		 
/// Input:{"params":[{"":""}]}
/// Debug
ClassMethod DeviceFeeWarning(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.GroupDevice).DeviceFeeWarning(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: DIP分值查询
/// code: 02010003		 
/// Input:{"params":[{"":""}]}
/// Debug
ClassMethod GetDIPGroupScore(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.GroupDevice).GetDIPGroupScore(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 从HIS平台获取病案首页信息更新病案首页表
/// Code: 02010028
ClassMethod GetMedicalRecordFromHIS(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.MedicalRecord).GetMedicalRecordFromHIS(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存病案首页信息
/// Code: 02010026
ClassMethod SaveMedInsuMedicalRecord(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.MedicalRecord).SaveMedInsuMedicalRecord(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询病案首页信息表
/// Table: BS_DRGMedInsuMedicalRecord
/// Code: 02010027
ClassMethod QueryMedicalRecord(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.MedicalRecord).QueryMedicalRecord(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 从HIS平台获取结算清单信息更新DRG结算清单表
/// Code: 02010029
ClassMethod GetSettlementInfoFromHIS(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.MedicalRecord).GetSettlementInfoFromHIS(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存结算清单信息
/// Table: BS_DRGMedInsuSettleMentInfo
/// Code: 02010030		
ClassMethod SaveMedInsuSettleMentInfo(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.MedicalRecord).SaveMedInsuSettleMentInfo(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询结算清单信息表
/// Table: BS_DRGMedInsuSettleMentInfo
/// Code: 02010031		
ClassMethod QuerySettleMentInfo(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.MedicalRecord).QuerySettleMentInfo(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存DRG分组记录
/// Table: BS_DRGGroupRecord
/// Code: 02010035		
ClassMethod SaveDRGGroupRecord(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.GroupDevice).SaveDRGGroupRecord(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询DRG分组记录表
/// Table: BS_DRGGroupRecord
/// Code: 02010036		
ClassMethod QueryDRGGroupRecord(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.GroupDevice).QueryDRGGroupRecord(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 按病案首页信息进行DRG分组
/// Code:		
ClassMethod DRGGroup(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.GroupDevice).GetDRGGroup(postObj)
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询系统用户列表
/// Code: 02010401
ClassMethod QuerySystemUsers(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
	quit ##class(src.DRG.User).QuerySystemUsers(postObj)
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 保存系统用户
/// Code: 02010402
ClassMethod SaveSystemUser(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
	quit ##class(src.DRG.User).SaveSystemUser(postObj)
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询系统菜单
/// Code: 02010403
ClassMethod QuerySystemMenus(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
   	new (postObj)
	quit ##class(src.DRG.User).QuerySystemMenus(postObj)
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 获取用户菜单权限
/// Code: 02010408
ClassMethod GetUserMenus(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
   	new (postObj)
	quit ##class(src.DRG.User).GetUserMenus(postObj)
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询系统角色
/// Code: 02010406
ClassMethod QuerySystemRoles(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
   	new (postObj)
	quit ##class(src.DRG.User).QuerySystemRoles(postObj)
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 保存系统角色
/// Code: 02010407
ClassMethod SaveSystemRole(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
   	new (postObj)
	quit ##class(src.DRG.User).SaveSystemRole(postObj)
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 保存角色菜单权限
/// Code: 02010409
ClassMethod SaveRoleMenu(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
   	new (postObj)
	quit ##class(src.DRG.User).SaveRoleMenu(postObj)
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 用户登录
/// Code: 02010410
ClassMethod UserLogin(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
   	new (postObj)
	quit ##class(src.DRG.User).UserLogin(postObj)
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 用户登出
/// Code: 02010411
ClassMethod UserLogout(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
   	new (postObj)
	quit ##class(src.DRG.User).UserLogout(postObj)
}

/// 通用方法根据起始和截至时间判断有效/失效
ClassMethod IsRecordActive(startDate As %Date, stopDate As %Date) As %Boolean
{
    Set currentDate = +$Horolog
    
    // 处理空值：startDate为空视为最小日期，stopDate为空视为最大日期
    Set effectiveStart = $Select(startDate="":0, 1:startDate)  // 0 = 1840-12-31
    Set effectiveEnd = $Select(stopDate="":99999, 1:stopDate)  // 99999 = 未来日期
        
    Quit (effectiveStart <= currentDate) && (effectiveEnd >= currentDate)
}

}
