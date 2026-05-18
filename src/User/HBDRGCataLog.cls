/// DRG目录表--收录各地方DRGs目录
Class User.HBDRGCataLog Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_DRGCataLog ]
{

Parameter %JSONREFERENCE = "ID";

/// DRGs代码 非空
Property Code As %String(COLLATION = "UPPER", TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code;

/// DRGs描述 非空
Property Descripts As %String(COLLATION = "UPPER", TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

/// 省 指向CB_Province
Property ProvinceDr As CBProvince [ Required, SqlColumnNumber = 4, SqlFieldName = Province_Dr ];

/// 市 指向CB_City
Property CityDr As CBCity [ Required, SqlColumnNumber = 5, SqlFieldName = City_Dr ];

Index DataIndex On (Code, ProvinceDr, CityDr) [ Unique ];

/// 行政区划代码
Property Admvs As %String [ Required, SqlColumnNumber = 6, SqlFieldName = Admvs ];

/// 更新日期 系统自动产生
Property UpdateDate As %Date [ Required, SqlColumnNumber = 7, SqlFieldName = UpdateDate ];

/// 更新时间 系统自动产生
Property UpdateTime As %Time [ Required, SqlColumnNumber = 8, SqlFieldName = UpdateTime ];

/// 创建人员ID 指向HB_User表
Property UpdateUserDr As HBUser [ Required, SqlColumnNumber = 9, SqlFieldName = UpdateUser_Dr ];

Storage Default
{
<Data name="HBDRGCataLogDefaultData">
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
<Value>Version</Value>
</Value>
<Value name="5">
<Value>ProvinceDr</Value>
</Value>
<Value name="6">
<Value>CityDr</Value>
</Value>
<Value name="7">
<Value>Admvs</Value>
</Value>
<Value name="8">
<Value>FixmedinsCode</Value>
</Value>
<Value name="9">
<Value>FixmedinsName</Value>
</Value>
<Value name="10">
<Value>UpdateDate</Value>
</Value>
<Value name="11">
<Value>UpdateTime</Value>
</Value>
<Value name="12">
<Value>UpdateUserDr</Value>
</Value>
</Data>
<DataLocation>^HBDRGCataLogD</DataLocation>
<DefaultData>HBDRGCataLogDefaultData</DefaultData>
<IdLocation>^HBDRGCataLogD</IdLocation>
<IndexLocation>^HBDRGCataLogI</IndexLocation>
<StreamLocation>^HBDRGCataLogS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
