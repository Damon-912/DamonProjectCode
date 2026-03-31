Class User.BSDRGSystemRole Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGSystemRole ]
{

Parameter %JSONREFERENCE = "ID";

/// 角色编码
Property RoleCode As %String(COLLATION = "UPPER", MAXLEN = 30) [ Required, SqlColumnNumber = 2, SqlFieldName = RoleCode ];

/// 角色名称
Property RoleName As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 3, SqlFieldName = RoleName ];

/// 角色描述
Property RoleDesc As %String(MAXLEN = 200) [ SqlColumnNumber = 4, SqlFieldName = RoleDesc ];

/// 角色类型 (01:系统管理员 02:科室管理员 03:普通用户)
Property RoleType As %String(COLLATION = "UPPER", MAXLEN = 2) [ SqlColumnNumber = 5, SqlFieldName = RoleType ];

/// 是否启用 Y/N
Property IsActive As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 6, SqlFieldName = IsActive ];

/// 排序号
Property SeqNo As %Integer [ SqlColumnNumber = 7, SqlFieldName = SeqNo ];

/// 创建日期
Property CreateDate As %Date [ Required, SqlColumnNumber = 8, SqlFieldName = CreateDate ];

/// 创建时间
Property CreateTime As %Time [ Required, SqlColumnNumber = 9, SqlFieldName = CreateTime ];

/// 创建人
Property CreateUserDr As %String(COLLATION = "UPPER", MAXLEN = 50) [ SqlColumnNumber = 10, SqlFieldName = CreateUser_Dr ];

/// 备注
Property Remark As %String(MAXLEN = 500) [ SqlColumnNumber = 11, SqlFieldName = Remark ];

/// 索引 - 角色编码唯一索引
Index RoleCode On RoleCode [ Unique ];

Storage Default
{
<Data name="BSDRGSystemRoleDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RoleCode</Value>
</Value>
<Value name="3">
<Value>RoleName</Value>
</Value>
<Value name="4">
<Value>RoleDesc</Value>
</Value>
<Value name="5">
<Value>RoleType</Value>
</Value>
<Value name="6">
<Value>IsActive</Value>
</Value>
<Value name="7">
<Value>SeqNo</Value>
</Value>
<Value name="8">
<Value>CreateDate</Value>
</Value>
<Value name="9">
<Value>CreateTime</Value>
</Value>
<Value name="10">
<Value>CreateUserDr</Value>
</Value>
<Value name="11">
<Value>Remark</Value>
</Value>
</Data>
<DataLocation>^User.BSDRGSystemRoleD</DataLocation>
<DefaultData>BSDRGSystemRoleDefaultData</DefaultData>
<IdLocation>^User.BSDRGSystemRoleD</IdLocation>
<IndexLocation>^User.BSDRGSystemRoleI</IndexLocation>
<StreamLocation>^User.BSDRGSystemRoleS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
