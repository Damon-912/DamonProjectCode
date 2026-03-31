Class User.CBModifyLogConfig Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_ModifyLogConfig ]
{

Parameter %JSONREFERENCE = "ID";

/// 修改表名
Property TableName As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 2, SqlFieldName = TableName ];

Index TableName On TableName;

/// 创建日期
Property CreateDate As %Date [ Required, SqlColumnNumber = 3, SqlFieldName = CreateDate ];

Index Date On CreateDate;

/// 创建时间
Property CreateTime As %Time [ Required, SqlColumnNumber = 4, SqlFieldName = CreateTime ];

/// 创建人
Property CreateUserDr As %String [ Required, SqlColumnNumber = 5, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBModifyLogConfigDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>TableName</Value>
</Value>
<Value name="3">
<Value>CreateDate</Value>
</Value>
<Value name="4">
<Value>CreateTime</Value>
</Value>
<Value name="5">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>^CBModifyLogConfigD</DataLocation>
<DefaultData>CBModifyLogConfigDefaultData</DefaultData>
<ExtentSize>1</ExtentSize>
<IdLocation>^CBModifyLogConfigD</IdLocation>
<IndexLocation>^CBModifyLogConfigI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateTime">
<AverageFieldSize>7</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="TableName">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="Date">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="TableName">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^CBModifyLogConfigS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
