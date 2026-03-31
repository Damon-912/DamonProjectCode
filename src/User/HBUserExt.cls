/// 人员扩展表
Class User.HBUserExt Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_UserExt ]
{

Parameter %JSONREFERENCE = "ID";

///  指向用户表 HB_User
Property UserDr As HBUser [ Required, SqlColumnNumber = 2, SqlFieldName = User_Dr ];

Index User On UserDr;

/// 字段配置
Property UserFieldDr As User.CBUserFieldConfig [ Required, SqlColumnNumber = 3, SqlFieldName = UserField_Dr ];

Index UserField On (UserDr As Exact, UserFieldDr As Exact);

/// 代码 
Property Code As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Code ];

Index Code On Code;

Index UserFieldCode On (UserDr, Code);

/// 描述
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 5, SqlFieldName = Descripts ];

/// 保存的数据
Property ExtValue As %String(MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 6, SqlFieldName = ExtValue ];

Index ExtValue On ExtValue;

/// 出参描述
Property RefDescripts As %String(MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 7, SqlFieldName = RefDescripts ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 8, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 9, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 10, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="HBUserExtDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>UserDr</Value>
</Value>
<Value name="3">
<Value>UserFieldDr</Value>
</Value>
<Value name="4">
<Value>Code</Value>
</Value>
<Value name="5">
<Value>Descripts</Value>
</Value>
<Value name="6">
<Value>ExtValue</Value>
</Value>
<Value name="7">
<Value>RefDescripts</Value>
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
<DataLocation>^HBUserExtD</DataLocation>
<DefaultData>HBUserExtDefaultData</DefaultData>
<ExtentSize>1</ExtentSize>
<IdLocation>^HBUserExtD</IdLocation>
<IndexLocation>^HBUserExtI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>6</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateTime">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>10</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ExtValue">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="RefDescripts">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="UserDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="UserFieldDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="Code">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="ExtValue">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="User">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="UserField">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="UserFieldCode">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^HBUserExtS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
