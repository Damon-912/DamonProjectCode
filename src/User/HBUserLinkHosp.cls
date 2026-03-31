/// 医院用户
Class User.HBUserLinkHosp Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_UserLinkHosp ]
{

Parameter %JSONREFERENCE = "ID";

///  指向用户表 HB_User
Property UserDr As HBUser [ Required, SqlColumnNumber = 2, SqlFieldName = User_Dr ];

Index User On UserDr;

/// 医院 指向CB_Hospital
Property HospDr As CBHospital [ Required, SqlColumnNumber = 3, SqlFieldName = Hosp_Dr ];

Index Hosp On HospDr;

Index HospUser On (HospDr, UserDr) [ Unique ];

/// 生效日期 
Property StartDate As %Date [ Required, SqlColumnNumber = 4, SqlFieldName = StartDate ];

/// 截止日期 
Property StopDate As %Date [ SqlColumnNumber = 5, SqlFieldName = StopDate ];

/// 创建人 指向 人员表 HB_User
Property CreatedByDr As HBUser [ Required, SqlColumnNumber = 6, SqlFieldName = CreatedBy_Dr ];

/// 创建日期 
Property CreatedDate As %Date [ Required, SqlColumnNumber = 7, SqlFieldName = CreatedDate ];

/// 创建时间 
Property CreatedTime As %Time [ Required, SqlColumnNumber = 8, SqlFieldName = CreatedTime ];

Storage Default
{
<Data name="HBUserLinkHospDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>UserDr</Value>
</Value>
<Value name="3">
<Value>HospDr</Value>
</Value>
<Value name="4">
<Value>StartDate</Value>
</Value>
<Value name="5">
<Value>StopDate</Value>
</Value>
<Value name="6">
<Value>CreatedByDr</Value>
</Value>
<Value name="7">
<Value>CreatedDate</Value>
</Value>
<Value name="8">
<Value>CreatedTime</Value>
</Value>
</Data>
<DataLocation>^HBUserLinkHospD</DataLocation>
<DefaultData>HBUserLinkHospDefaultData</DefaultData>
<ExtentSize>3</ExtentSize>
<IdLocation>^HBUserLinkHospD</IdLocation>
<IndexLocation>^HBUserLinkHospI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreatedByDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreatedDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreatedTime">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="HospDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="UserDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<SQLMap name="Hosp">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="User">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^HBUserLinkHospS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
