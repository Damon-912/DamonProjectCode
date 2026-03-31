/// 元素字段分类
Class User.CBFieldClass Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_FieldClass ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码
Property Code As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 100) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ InitialExpression = {+$h}, SqlColumnNumber = 4, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 5, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBFieldClassDefaultData">
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
</Data>
<DataLocation>^CBFieldClassD</DataLocation>
<DefaultData>CBFieldClassDefaultData</DefaultData>
<ExtentSize>1</ExtentSize>
<IdLocation>^CBFieldClassD</IdLocation>
<IndexLocation>^CBFieldClassI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>9</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>10</AverageFieldSize>
<Selectivity>1</Selectivity>
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
<StreamLocation>^CBFieldClassS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
