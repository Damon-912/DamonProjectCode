/// 市表
Class User.CBCity Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_City ]
{

Parameter %JSONREFERENCE = "ID";

/// 序号 此序号反映了项目的排列次序
Property SeqNo As %Integer [ SqlColumnNumber = 2, SqlFieldName = SeqNo ];

Index SeqNo On SeqNo;

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 6, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 省 指向CB_Province
Property ProvinceDr As CBProvince [ Required, SqlColumnNumber = 5, SqlFieldName = Province_Dr ];

Index Province On ProvinceDr;

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 6, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 7, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 8, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 9, SqlFieldName = CreateUser_Dr ];

/// 邮编
Property ZIPCode As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = ZIPCode ];

/// 关联国标 指向HB_User表
Property NationalDr As User.CBNationalDataElement [ SqlColumnNumber = 11, SqlFieldName = National_Dr ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 12, SqlFieldName = ENDesc ];

Storage Default
{
<Data name="CBCityDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SeqNo</Value>
</Value>
<Value name="3">
<Value>Code</Value>
</Value>
<Value name="4">
<Value>Descripts</Value>
</Value>
<Value name="5">
<Value>ProvinceDr</Value>
</Value>
<Value name="6">
<Value>StartDate</Value>
</Value>
<Value name="7">
<Value>StopDate</Value>
</Value>
<Value name="8">
<Value>CreateDate</Value>
</Value>
<Value name="9">
<Value>CreateUserDr</Value>
</Value>
<Value name="10">
<Value>ZIPCode</Value>
</Value>
<Value name="11">
<Value>NationalDr</Value>
</Value>
<Value name="12">
<Value>ENDesc</Value>
</Value>
</Data>
<DataLocation>^CBCityD</DataLocation>
<DefaultData>CBCityDefaultData</DefaultData>
<IdLocation>^CBCityD</IdLocation>
<IndexLocation>^CBCityI</IndexLocation>
<StreamLocation>^CBCityS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
