Class User.BSErrorRecord Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_ErrorRecord ]
{

Parameter %JSONREFERENCE = "ID";

/// 日期 
Property ErrDate As %Date [ Required, SqlColumnNumber = 2, SqlFieldName = ErrDate ];

Index ErrDate On ErrDate;

/// 时间 
Property ErrTime As %Time [ Required, SqlColumnNumber = 3, SqlFieldName = ErrTime ];

/// 模块功能 
Property AppCode As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 4, SqlFieldName = AppCode ];

Index AppCode On AppCode;

/// 错误信息 
Property ErrInfo As %String(COLLATION = "UPPER", MAXLEN = 5000, TRUNCATE = 1) [ SqlColumnNumber = 5, SqlFieldName = ErrInfo ];

/// 错误值 
Property ErrValue As %String(COLLATION = "UPPER", MAXLEN = 5000, TRUNCATE = 1) [ SqlColumnNumber = 6, SqlFieldName = ErrValue ];

Storage Default
{
<Data name="BSErrorRecordDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ErrDate</Value>
</Value>
<Value name="3">
<Value>ErrTime</Value>
</Value>
<Value name="4">
<Value>AppCode</Value>
</Value>
<Value name="5">
<Value>ErrInfo</Value>
</Value>
<Value name="6">
<Value>ErrValue</Value>
</Value>
</Data>
<DataLocation>^User.BSErrorRecordD</DataLocation>
<DefaultData>BSErrorRecordDefaultData</DefaultData>
<IdLocation>^User.BSErrorRecordD</IdLocation>
<IndexLocation>^User.BSErrorRecordI</IndexLocation>
<StreamLocation>^User.BSErrorRecordS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
