/// ADRG细分规则表--存储各地方ADRG细分规则配置
Class User.HBDRGSegmentationRules Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_DRGSegmentationRules ]
{

Parameter %JSONREFERENCE = "ID";

/// ADRG代码 非空
Property ADRG As %String(COLLATION = "UPPER", TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = ADRG ];

Index ADRGIdx On ADRG;

Index ADRGUnique On ADRG [ PrimaryKey, Unique ];

/// ADRG描述 非空
Property ADRGDesc As %String(COLLATION = "UPPER", MAXLEN = 200, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = ADRGDesc ];

/// 省 指向CB_Province
Property ProvinceDr As CBProvince [ Required, SqlColumnNumber = 4, SqlFieldName = Province_Dr ];

/// 市 指向CB_City
Property CityDr As CBCity [ Required, SqlColumnNumber = 5, SqlFieldName = City_Dr ];

/// 行政区划代码
Property Admvs As %String [ Required, SqlColumnNumber = 6, SqlFieldName = Admvs ];

/// 联合标志 0-否 1-是
Property UnionFlag As %String [ Required, SqlColumnNumber = 7, SqlFieldName = UnionFlag ];

/// 细分标志 0-否 1-是，
/// 如果不需要再细分，那么DRG编码第四位默认是9，需要细分的ADRG最后一位根据患者就诊信息进一步判断
Property SegmentationFlag As %String [ Required, SqlColumnNumber = 8, SqlFieldName = SegmentationFlag ];

/// 入组规则
Property SelectionCriteria As %String(MAXLEN = 500) [ SqlColumnNumber = 9, SqlFieldName = SelectionCriteria ];

/// 更新日期 系统自动产生
Property UpdateDate As %Date [ Required, SqlColumnNumber = 10, SqlFieldName = UpdateDate ];

/// 更新时间 系统自动产生
Property UpdateTime As %Time [ Required, SqlColumnNumber = 11, SqlFieldName = UpdateTime ];

/// 创建人员ID 指向HB_User表
Property UpdateUserDr As HBUser [ Required, SqlColumnNumber = 12, SqlFieldName = UpdateUser_Dr ];

Storage Default
{
<Data name="HBDRGSegmentationRulesDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ADRG</Value>
</Value>
<Value name="3">
<Value>ADRGDesc</Value>
</Value>
<Value name="4">
<Value>ProvinceDr</Value>
</Value>
<Value name="5">
<Value>CityDr</Value>
</Value>
<Value name="6">
<Value>Admvs</Value>
</Value>
<Value name="7">
<Value>UnionFlag</Value>
</Value>
<Value name="8">
<Value>SegmentationFlag</Value>
</Value>
<Value name="9">
<Value>SelectionCriteria</Value>
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
<DataLocation>^HBDRGSegmentationRulesD</DataLocation>
<DefaultData>HBDRGSegmentationRulesDefaultData</DefaultData>
<IdLocation>^HBDRGSegmentationRulesD</IdLocation>
<IndexLocation>^HBDRGSegmentationRulesI</IndexLocation>
<StreamLocation>^HBDRGSegmentationRulesS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
