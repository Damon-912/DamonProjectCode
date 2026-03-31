Class User.BSDRGRoleMenu Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGRoleMenu ]
{

Parameter %JSONREFERENCE = "ID";

/// 角色ID 指向BS_DRGSystemRole
Property RoleDr As User.BSDRGSystemRole [ Required, SqlColumnNumber = 2, SqlFieldName = Role_Dr ];

/// 菜单ID 指向BS_DRGSystemMenu
Property MenuDr As User.BSDRGSystemMenu [ Required, SqlColumnNumber = 3, SqlFieldName = Menu_Dr ];

/// 是否拥有该菜单的查看权限 Y/N
Property CanView As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 4, SqlFieldName = CanView ];

/// 是否拥有新增权限 Y/N
Property CanAdd As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 5, SqlFieldName = CanAdd ];

/// 是否拥有修改权限 Y/N
Property CanEdit As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 6, SqlFieldName = CanEdit ];

/// 是否拥有删除权限 Y/N
Property CanDelete As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 7, SqlFieldName = CanDelete ];

/// 是否拥有导出权限 Y/N
Property CanExport As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 8, SqlFieldName = CanExport ];

/// 创建日期
Property CreateDate As %Date [ Required, SqlColumnNumber = 9, SqlFieldName = CreateDate ];

/// 创建时间
Property CreateTime As %Time [ Required, SqlColumnNumber = 10, SqlFieldName = CreateTime ];

/// 创建人
Property CreateUserDr As %String(COLLATION = "UPPER", MAXLEN = 50) [ SqlColumnNumber = 11, SqlFieldName = CreateUser_Dr ];

/// 索引 - 按角色
Index idxRole On RoleDr;

/// 索引 - 按菜单
Index idxMenu On MenuDr;

/// 索引 - 角色+菜单唯一索引
Index idxRoleMenu On (RoleDr, MenuDr) [ Unique ];

Storage Default
{
<Data name="BSDRGRoleMenuDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RoleDr</Value>
</Value>
<Value name="3">
<Value>MenuDr</Value>
</Value>
<Value name="4">
<Value>CanView</Value>
</Value>
<Value name="5">
<Value>CanAdd</Value>
</Value>
<Value name="6">
<Value>CanEdit</Value>
</Value>
<Value name="7">
<Value>CanDelete</Value>
</Value>
<Value name="8">
<Value>CanExport</Value>
</Value>
<Value name="9">
<Value>CreateDate</Value>
</Value>
<Value name="10">
<Value>CreateTime</Value>
</Value>
<Value name="11">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>^User.BSDRGRoleMenuD</DataLocation>
<DefaultData>BSDRGRoleMenuDefaultData</DefaultData>
<IdLocation>^User.BSDRGRoleMenuD</IdLocation>
<IndexLocation>^User.BSDRGRoleMenuI</IndexLocation>
<StreamLocation>^User.BSDRGRoleMenuS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
