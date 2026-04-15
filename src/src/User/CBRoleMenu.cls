/// 角色菜单权限表
/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 存储角色与菜单的对应关系
/// 遵从CB表规范
Class User.CBRoleMenu Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_RoleMenu ]
{

/// 角色编码
Property RoleCode As %String(MAXLEN = 100) [ Required ];

/// 菜单编码(外键指向CBMenu)
Property MenuCode As %String(MAXLEN = 100) [ Required ];

/// 创建日期
Property CreateDate As %Date [ InitialExpression = {$zdateh($horolog, 5)} ];

/// 创建时间
Property CreateTime As %Time [ InitialExpression = {$zdt($horolog, 8)} ];

/// 创建用户(外键)
Property CreateUserDr As User.HBUser [ SqlColumnNumber = 6 ];

/// 删除标记(0=正常,1=已删除)
Property Deleted As %Integer [ InitialExpression = 0, Required ];

/// 删除时间
Property DeleteTime As %TimeStamp;

/// 角色菜单唯一索引(防止重复)
Index RoleMenuIndex On (RoleCode, MenuCode) [ Unique ];

/// 角色编码索引
Index RoleCodeIndex On RoleCode As Exact;

/// 菜单编码索引
Index MenuCodeIndex On MenuCode As Exact;

/// 创建用户索引
Index CreateUserDrIndex On CreateUserDr As Exact;

/// 删除标记索引
Index DeletedIndex On Deleted As Exact;

Storage Default
{
<Data name="CBRoleMenuDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RoleCode</Value>
</Value>
<Value name="3">
<Value>MenuCode</Value>
</Value>
<Value name="4">
<Value>CreateDate</Value>
</Value>
<Value name="5">
<Value>CreateTime</Value>
</Value>
<Value name="6">
<Value>CreateUserDr</Value>
</Value>
<Value name="7">
<Value>Deleted</Value>
</Value>
<Value name="8">
<Value>DeleteTime</Value>
</Value>
</Data>
<DataLocation>^CBRoleMenuD</DataLocation>
<DefaultData>CBRoleMenuDefaultData</DefaultData>
<IdLocation>^CBRoleMenuD</IdLocation>
<IndexLocation>^CBRoleMenuI</IndexLocation>
<StreamLocation>^CBRoleMenuS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
