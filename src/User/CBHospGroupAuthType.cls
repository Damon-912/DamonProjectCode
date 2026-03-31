Class User.CBHospGroupAuthType Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_HospGroupAuthType ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ SqlColumnNumber = 4, SqlFieldName = ENDesc ];

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 5, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 6, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 7, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 8, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBHospGroupAuthTypeDefaultData">
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
<Value>StartDate</Value>
</Value>
<Value name="6">
<Value>StopDate</Value>
</Value>
<Value name="7">
<Value>CreateDate</Value>
</Value>
<Value name="8">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>^CBHospGroupAuthTypeD</DataLocation>
<DefaultData>CBHospGroupAuthTypeDefaultData</DefaultData>
<ExtentSize>4</ExtentSize>
<IdLocation>^CBHospGroupAuthTypeD</IdLocation>
<IndexLocation>^CBHospGroupAuthTypeI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>2.5</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="ENDesc">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="StartDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="StopDate">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="Code">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Desc">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^CBHospGroupAuthTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
