/// ICD编码映射表
Class User.HBDRGICDVersionMapping Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_DRGICDVersionMapping ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码 非空
Property Code As %String [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

/// 描述 非空
Property Descripts As %String [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

/// 医保ICD代码
Property ICD As %String [ Required, SqlColumnNumber = 4, SqlFieldName = ICD ];

/// 医保ICD描述
Property ICDDesc As %String [ Required, SqlColumnNumber = 5, SqlFieldName = ICDDesc ];

/// 版本
Property VersionNo As %String [ SqlColumnNumber = 6, SqlFieldName = VersionNo ];

/// 省 指向CB_Province
Property ProvinceDr As CBProvince [ Required, SqlColumnNumber = 7, SqlFieldName = Province_Dr ];

/// 市 指向CB_City
Property CityDr As CBCity [ Required, SqlColumnNumber = 8, SqlFieldName = City_Dr ];

/// 更新日期 系统自动产生
Property UpdateDate As %Date [ SqlColumnNumber = 9, SqlFieldName = UpdateDate ];

/// 更新时间 系统自动产生
Property UpdateTime As %Time [ SqlColumnNumber = 10, SqlFieldName = UpdateTime ];

/// 更新人员ID 指向HB_User表
Property UpdateUserDr As HBUser [ SqlColumnNumber = 11, SqlFieldName = UpdateUser_Dr ];

/// 标识码-分类
Property Identification As %String [ SqlColumnNumber = 12, SqlFieldName = Identification ];

/// 备注
Property Remark As %String(MAXLEN = 99999) [ SqlColumnNumber = 13, SqlFieldName = Remark ];

Storage Default
{
<Data name="HBDRGICDVersionMappingDefaultData">
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
<Value>ICD</Value>
</Value>
<Value name="5">
<Value>ICDDesc</Value>
</Value>
<Value name="6">
<Value>VersionNo</Value>
</Value>
<Value name="7">
<Value>ProvinceDr</Value>
</Value>
<Value name="8">
<Value>CityDr</Value>
</Value>
<Value name="9">
<Value>UpdateDate</Value>
</Value>
<Value name="10">
<Value>UpdateTime</Value>
</Value>
<Value name="11">
<Value>UpdateUserDr</Value>
</Value>
<Value name="12">
<Value>Identification</Value>
</Value>
<Value name="13">
<Value>Remark</Value>
</Value>
</Data>
<DataLocation>^HBDRGICDVersionMappingD</DataLocation>
<DefaultData>HBDRGICDVersionMappingDefaultData</DefaultData>
<IdLocation>^HBDRGICDVersionMappingD</IdLocation>
<IndexLocation>^HBDRGICDVersionMappingI</IndexLocation>
<StreamLocation>^HBDRGICDVersionMappingS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
