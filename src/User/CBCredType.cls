Class User.CBCredType Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_CredType ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码 非空  
Property Code As %String(COLLATION = "UPPER", MAXLEN = 4) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 25, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts;

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 4, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 5, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 6, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 7, SqlFieldName = CreateUser_Dr ];

/// 关联国标 指向HB_User表
/// Property NationalDr As User.CBNationalDataElement [ SqlColumnNumber = 8, SqlFieldName = National_Dr ];
/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 9, SqlFieldName = ENDesc ];

Storage Default
{
<Data name="CBCredTypeDefaultData">
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
<Value>StartDate</Value>
</Value>
<Value name="5">
<Value>StopDate</Value>
</Value>
<Value name="6">
<Value>CreateDate</Value>
</Value>
<Value name="7">
<Value>CreateUserDr</Value>
</Value>
<Value name="8">
<Value>ENDesc</Value>
</Value>
</Data>
<DataLocation>^CBCredTypeD</DataLocation>
<DefaultData>CBCredTypeDefaultData</DefaultData>
<IdLocation>^CBCredTypeD</IdLocation>
<IndexLocation>^CBCredTypeI</IndexLocation>
<StreamLocation>^CBCredTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
