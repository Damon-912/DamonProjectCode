/// 医疗机构
Class User.CBHospital Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_Hospital ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码 
Property Code As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 医院级别标记 指向医院级别表 CB_HospGrade
Property HospGradeDr As CBHospGrade [ SqlColumnNumber = 4, SqlFieldName = HospGrade_Dr ];

Index Grade On HospGradeDr;

/// 医院类型 医院类型表 CB_HospType
Property HospTypeDr As CBHospType [ Required, SqlColumnNumber = 5, SqlFieldName = HospType_Dr ];

Index HosType On HospTypeDr;

/// 医院性质 医院性质表 CB_HospNature
Property HospNatureDr As CBHospNature [ Required, SqlColumnNumber = 6, SqlFieldName = HospNature_Dr ];

Index HosNat On HospNatureDr;

/// 省标记 指向省  CB_Province
Property ProvIDDr As CBProvince [ Required, SqlColumnNumber = 7, SqlFieldName = ProvID_Dr ];

Index Prov On ProvIDDr;

/// 市标记 指向市 CB_City
Property CityIDDr As CBCity [ Required, SqlColumnNumber = 8, SqlFieldName = CityID_Dr ];

Index City On CityIDDr;

/// 区/县标记 指向县/区 CB_Area
Property AreaIDDr As CBArea [ Required, SqlColumnNumber = 9, SqlFieldName = AreaID_Dr ];

Index Area On AreaIDDr;

/// 使用状态 Y/N
Property Active As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 10, SqlFieldName = Active ];

/// 组织机构代码 
Property OrganizationCode As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 11, SqlFieldName = OrganizationCode ];

/// 营业执照 
Property Businesslicense As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 12, SqlFieldName = Businesslicense ];

/// 生效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StartDate As %Date [ SqlColumnNumber = 13, SqlFieldName = StartDate ];

/// 失效日期 系统自动产生
Property StopDate As %Date [ SqlColumnNumber = 14, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 15, SqlFieldName = CreateDate ];

/// 创建时间 指向用户表 HB_User
Property CreateTime As %Time [ Required, SqlColumnNumber = 16, SqlFieldName = CreateTime ];

/// 创建人员ID 与USER表里的ID相同
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 17, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBHospitalDefaultData">
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
<Value>HospGradeDr</Value>
</Value>
<Value name="5">
<Value>HospTypeDr</Value>
</Value>
<Value name="6">
<Value>HospNatureDr</Value>
</Value>
<Value name="7">
<Value>ProvIDDr</Value>
</Value>
<Value name="8">
<Value>CityIDDr</Value>
</Value>
<Value name="9">
<Value>AreaIDDr</Value>
</Value>
<Value name="10">
<Value>Active</Value>
</Value>
<Value name="11">
<Value>OrganizationCode</Value>
</Value>
<Value name="12">
<Value>Businesslicense</Value>
</Value>
<Value name="13">
<Value>StartDate</Value>
</Value>
<Value name="14">
<Value>StopDate</Value>
</Value>
<Value name="15">
<Value>CreateDate</Value>
</Value>
<Value name="16">
<Value>CreateTime</Value>
</Value>
<Value name="17">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>^CBHospitalD</DataLocation>
<DefaultData>CBHospitalDefaultData</DefaultData>
<ExtentSize>3</ExtentSize>
<IdLocation>^CBHospitalD</IdLocation>
<IndexLocation>^CBHospitalI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Active">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="AreaIDDr">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Businesslicense">
<AverageFieldSize>6</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="CityIDDr">
<AverageFieldSize>4.33</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>6.33</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="CreateTime">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>13.33</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="HospGradeDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="HospNatureDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="HospTypeDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="OrganizationCode">
<AverageFieldSize>6.67</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="ProvIDDr">
<AverageFieldSize>3.67</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="StartDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="StopDate">
<AverageFieldSize>7</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<SQLMap name="Area">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="City">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Code">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Desc">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Grade">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="HosNat">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="HosType">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Prov">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^CBHospitalS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
