Class User.BSDRGSystemMenu Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGSystemMenu ]
{

Parameter %JSONREFERENCE = "ID";

/// 菜单编码
Property MenuCode As %String(COLLATION = "UPPER", MAXLEN = 30) [ Required, SqlColumnNumber = 2, SqlFieldName = MenuCode ];

/// 菜单名称
Property MenuName As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 3, SqlFieldName = MenuName ];

/// 父级菜单ID 0表示顶级菜单
Property ParentID As %String(COLLATION = "UPPER", MAXLEN = 30) [ SqlColumnNumber = 4, SqlFieldName = ParentID ];

/// 菜单路径
Property MenuPath As %String(COLLATION = "UPPER", MAXLEN = 100) [ SqlColumnNumber = 5, SqlFieldName = MenuPath ];

/// 菜单图标
Property MenuIcon As %String(COLLATION = "UPPER", MAXLEN = 50) [ SqlColumnNumber = 6, SqlFieldName = MenuIcon ];

/// 组件路径
Property Component As %String(COLLATION = "UPPER", MAXLEN = 100) [ SqlColumnNumber = 7, SqlFieldName = Component ];

/// 排序号
Property SeqNo As %Integer [ SqlColumnNumber = 8, SqlFieldName = SeqNo ];

/// 菜单层级
Property MenuLevel As %Integer [ SqlColumnNumber = 9, SqlFieldName = MenuLevel ];

/// 是否为叶子节点 Y/N
Property IsLeaf As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 10, SqlFieldName = IsLeaf ];

/// 是否启用 Y/N
Property IsActive As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 11, SqlFieldName = IsActive ];

/// 是否可见 Y/N
Property IsVisible As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 12, SqlFieldName = IsVisible ];

/// 菜单类型 (01:目录 02:菜单 03:按钮)
Property MenuType As %String(COLLATION = "UPPER", MAXLEN = 2) [ SqlColumnNumber = 13, SqlFieldName = MenuType ];

/// 权限标识
Property Permission As %String(COLLATION = "UPPER", MAXLEN = 100) [ SqlColumnNumber = 14, SqlFieldName = Permission ];

/// 创建日期
Property CreateDate As %Date [ Required, SqlColumnNumber = 15, SqlFieldName = CreateDate ];

/// 创建时间
Property CreateTime As %Time [ Required, SqlColumnNumber = 16, SqlFieldName = CreateTime ];

/// 备注
Property Remark As %String(MAXLEN = 200) [ SqlColumnNumber = 17, SqlFieldName = Remark ];

/// 索引 - 菜单编码唯一索引
Index MenuCode On MenuCode [ Unique ];

/// 索引 - 父级菜单
Index idxParent On ParentID;

/// 索引 - 菜单类型
Index idxMenuType On MenuType;

/// 索引 - 排序号
Index idxSeq On SeqNo;

Storage Default
{
<Data name="BSDRGSystemMenuDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MenuCode</Value>
</Value>
<Value name="3">
<Value>MenuName</Value>
</Value>
<Value name="4">
<Value>ParentID</Value>
</Value>
<Value name="5">
<Value>MenuPath</Value>
</Value>
<Value name="6">
<Value>MenuIcon</Value>
</Value>
<Value name="7">
<Value>Component</Value>
</Value>
<Value name="8">
<Value>SeqNo</Value>
</Value>
<Value name="9">
<Value>MenuLevel</Value>
</Value>
<Value name="10">
<Value>IsLeaf</Value>
</Value>
<Value name="11">
<Value>IsActive</Value>
</Value>
<Value name="12">
<Value>IsVisible</Value>
</Value>
<Value name="13">
<Value>MenuType</Value>
</Value>
<Value name="14">
<Value>Permission</Value>
</Value>
<Value name="15">
<Value>CreateDate</Value>
</Value>
<Value name="16">
<Value>CreateTime</Value>
</Value>
<Value name="17">
<Value>Remark</Value>
</Value>
</Data>
<DataLocation>^User.BSDRGSystemMenuD</DataLocation>
<DefaultData>BSDRGSystemMenuDefaultData</DefaultData>
<IdLocation>^User.BSDRGSystemMenuD</IdLocation>
<IndexLocation>^User.BSDRGSystemMenuI</IndexLocation>
<StreamLocation>^User.BSDRGSystemMenuS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
