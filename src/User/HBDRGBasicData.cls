Class User.HBDRGBasicData Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_DRGBasicData ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码 非空
Property InsuCode As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = InsuCode ];

// Index Code On InsuCode [ Unique ];

/// 描述 非空
Property InsuDesc As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = InsuDesc ];

/// 省 指向CB_Province
Property ProvinceDr As CBProvince [ Required, SqlColumnNumber = 4, SqlFieldName = Province_Dr ];

/// 市 指向CB_City
Property CityDr As CBCity [ Required, SqlColumnNumber = 5, SqlFieldName = City_Dr ];

Index DataIndex On (InsuCode, ProvinceDr, CityDr);

/// 区 指向CB_Area
Property AreaDr As CBArea [ SqlColumnNumber = 6, SqlFieldName = Area_Dr ];

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 7, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 8, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ SqlColumnNumber = 9, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ SqlColumnNumber = 10, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 11, SqlFieldName = CreateUser_Dr ];

/// 标识码-分类
Property Identification As %String [ SqlColumnNumber = 12, SqlFieldName = Identification ];

/// 备注
Property Remark As %String(MAXLEN = 99999) [ SqlColumnNumber = 13, SqlFieldName = Remark ];

Storage Default
{
<Data name="HBDRGBasicDataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>InsuCode</Value>
</Value>
<Value name="3">
<Value>InsuDesc</Value>
</Value>
<Value name="4">
<Value>ProvinceDr</Value>
</Value>
<Value name="5">
<Value>CityDr</Value>
</Value>
<Value name="6">
<Value>AreaDr</Value>
</Value>
<Value name="7">
<Value>StartDate</Value>
</Value>
<Value name="8">
<Value>StopDate</Value>
</Value>
<Value name="9">
<Value>CreateDate</Value>
</Value>
<Value name="10">
<Value>CreateTime</Value>
</Value>
<Value name="11">
<Value>CreateUserDr</Value>
</Value>
<Value name="12">
<Value>Identification</Value>
</Value>
<Value name="13">
<Value>Remark</Value>
</Value>
</Data>
<DataLocation>^HBDRGBasicDataD</DataLocation>
<DefaultData>HBDRGBasicDataDefaultData</DefaultData>
<IdLocation>^HBDRGBasicDataD</IdLocation>
<IndexLocation>^HBDRGBasicDataI</IndexLocation>
<StreamLocation>^HBDRGBasicDataS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
