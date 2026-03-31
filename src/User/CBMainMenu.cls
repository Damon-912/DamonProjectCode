Class User.CBMainMenu Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_MainMenu ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空 
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts;

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ SqlColumnNumber = 4, SqlFieldName = ENDesc ];

/// 更新日期 系统自动产生
Property UpdateDate As %Date [ Required, SqlColumnNumber = 5, SqlFieldName = UpdateDate ];

/// 更新时间 
Property UpdateTime As %Time [ Required, SqlColumnNumber = 6, SqlFieldName = UpdateTime ];

/// 更新人 指向HB_User表
Property UpdateUserDr As HBUser [ Required, SqlColumnNumber = 7, SqlFieldName = UpdateUser_Dr ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property EndDate As %Date [ SqlColumnNumber = 8, SqlFieldName = EndDate ];

Storage Default
{
<Data name="CBMainMenuDefaultData">
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
<Value>ENDesc</Value>
</Value>
<Value name="5">
<Value>UpdateDate</Value>
</Value>
<Value name="6">
<Value>UpdateTime</Value>
</Value>
<Value name="7">
<Value>EndDate</Value>
</Value>
<Value name="8">
<Value>UpdateUserDr</Value>
</Value>
</Data>
<DataLocation>^CBMainMenuD</DataLocation>
<DefaultData>CBMainMenuDefaultData</DefaultData>
<IdLocation>^CBMainMenuD</IdLocation>
<IndexLocation>^CBMainMenuI</IndexLocation>
<StreamLocation>^CBMainMenuS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
