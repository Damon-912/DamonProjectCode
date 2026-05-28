/// DRG字典表（自引用：ParentDr=NULL为类型，ParentDr非空为字典项）
Class User.CBDRGDictTable Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_DRGDictTable ]
{

Parameter %JSONREFERENCE = "ID";

/// 父级ID 自引用：NULL=字典类型，非NULL=所属类型的ID
Property ParentDr As CBDRGDictTable [ SqlColumnNumber = 2, SqlFieldName = Parent_Dr ];

Index ParentIndex On ParentDr;

/// 编码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

/// 名称 非空
Property Name As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Name ];

/// 状态 Y=启用 N=停用
Property Status As %String(MAXLEN = 1) [ Required, SqlColumnNumber = 5, SqlFieldName = Status ];

/// 排序号
Property SortNo As %Integer [ SqlColumnNumber = 6, SqlFieldName = SortNo ];

/// 备注/说明
Property Remark As %String(MAXLEN = 99999) [ SqlColumnNumber = 7, SqlFieldName = Remark ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ SqlColumnNumber = 8, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ SqlColumnNumber = 9, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 10, SqlFieldName = CreateUser_Dr ];

/// 唯一索引：同一类型下编码唯一
Index CodeIndex On (ParentDr, Code) [ Unique ];

Storage Default
{
<Data name="CBDRGDictTableDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ParentDr</Value>
</Value>
<Value name="3">
<Value>Code</Value>
</Value>
<Value name="4">
<Value>Name</Value>
</Value>
<Value name="5">
<Value>Status</Value>
</Value>
<Value name="6">
<Value>SortNo</Value>
</Value>
<Value name="7">
<Value>Remark</Value>
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
</Data>
<DataLocation>^CBDRGDictTableD</DataLocation>
<DefaultData>CBDRGDictTableDefaultData</DefaultData>
<IdLocation>^CBDRGDictTableD</IdLocation>
<IndexLocation>^CBDRGDictTableI</IndexLocation>
<StreamLocation>^CBDRGDictTableS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
