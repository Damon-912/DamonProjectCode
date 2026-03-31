/// 公共元素集
Class User.CBElementField Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_ElementField ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码
Property Code As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code;

/// 描述
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 100) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts;

/// 字段类型
Property FieldTypeDr As CBConfigFieldType [ Required, SqlColumnNumber = 4, SqlFieldName = FieldType_Dr ];

Index FieldType On FieldTypeDr;

/// 接口服务
Property CustomDataDr As User.CBCustomDataSet [ SqlColumnNumber = 5, SqlFieldName = CustomData_Dr ];

Index CustomData On CustomDataDr [ Unique ];

/// 字段分类
Property FieldClassDr As User.CBFieldClass [ Required, SqlColumnNumber = 6, SqlFieldName = FieldClass_Dr ];

Index FieldClass On FieldClassDr;

Index ClassCode On (FieldClassDr, Code) [ Unique ];

/// 输入域描述
Property Doubt As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 7, SqlFieldName = Doubt ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ InitialExpression = {+$h}, SqlColumnNumber = 8, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 9, SqlFieldName = CreateUser_Dr ];

/// 字段集
Property CustomDataStr As %String(MAXLEN = 1000) [ SqlColumnNumber = 10, SqlFieldName = CustomDataStr ];

Storage Default
{
<Data name="CBElementFieldDefaultData">
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
<Value>FieldTypeDr</Value>
</Value>
<Value name="5">
<Value>CustomDataDr</Value>
</Value>
<Value name="6">
<Value>FieldClassDr</Value>
</Value>
<Value name="7">
<Value>Doubt</Value>
</Value>
<Value name="8">
<Value>CreateDate</Value>
</Value>
<Value name="9">
<Value>CreateUserDr</Value>
</Value>
<Value name="10">
<Value>CustomDataStr</Value>
</Value>
</Data>
<DataLocation>^CBElementFieldD</DataLocation>
<DefaultData>CBElementFieldDefaultData</DefaultData>
<ExtentSize>2</ExtentSize>
<IdLocation>^CBElementFieldD</IdLocation>
<IndexLocation>^CBElementFieldI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>8</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CustomDataDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>10</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Doubt">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="FieldClassDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="FieldTypeDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="ClassCode">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Code">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="CustomData">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Desc">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="FieldClass">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="FieldType">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^CBElementFieldS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
