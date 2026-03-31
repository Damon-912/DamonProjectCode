Class User.CBConfigFieldType Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_ConfigFieldType ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码 非空  
Property Code As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 15, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 4, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 5, SqlFieldName = CreateUser_Dr ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 6, SqlFieldName = ENDesc ];

Storage Default
{
<Data name="CBConfigFieldTypeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Code</Value>
</Value>
<Value name="3">
<Value>Descripts</Value>
</Value>
<Value name="4">
<Value>CreateDate</Value>
</Value>
<Value name="5">
<Value>CreateUserDr</Value>
</Value>
<Value name="6">
<Value>ENDesc</Value>
</Value>
</Data>
<DataLocation>^CBConfigFieldTypeD</DataLocation>
<DefaultData>CBConfigFieldTypeDefaultData</DefaultData>
<IdLocation>^CBConfigFieldTypeD</IdLocation>
<IndexLocation>^CBConfigFieldTypeI</IndexLocation>
<StreamLocation>^CBConfigFieldTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
