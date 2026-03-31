/// 数据权限类型
Class User.CBDataAuthorityType Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_DataAuthorityType ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 安全等级 1,2,3
Property SafeClassificat As %Integer [ Required, SqlColumnNumber = 4, SqlFieldName = SafeClassificat ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 11, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 12, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBDataAuthorityTypeDefaultData">
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
<Value>SafeClassificat</Value>
</Value>
<Value name="5">
<Value>CreateDate</Value>
</Value>
<Value name="6">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>^CBDataAuthorityTypeD</DataLocation>
<DefaultData>CBDataAuthorityTypeDefaultData</DefaultData>
<ExtentSize>5</ExtentSize>
<IdLocation>^CBDataAuthorityTypeD</IdLocation>
<IndexLocation>^CBDataAuthorityTypeI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>5.6</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>7.6</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="SafeClassificat">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>20.0000%</Selectivity>
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
<StreamLocation>^CBDataAuthorityTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
