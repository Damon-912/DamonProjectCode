/// 用户-机构-角色
Class User.HBUserLogonLoc Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_UserLogonLoc ]
{

Parameter %JSONREFERENCE = "ID";

///  指向用户表 HB_User
Property UserDr As HBUser [ Required, SqlColumnNumber = 2, SqlFieldName = User_Dr ];

Index User On UserDr;

/// 医院 指向CB_Hospital
Property HospDr As CBHospital [ Required, SqlColumnNumber = 3, SqlFieldName = Hosp_Dr ];

Index Hosp On HospDr;

/// 角色 指向CB_Group
Property GroupDr As CBGroup [ Required, SqlColumnNumber = 4, SqlFieldName = Group_Dr ];

Index Group On GroupDr;

/// 是否默认 Y 是,N 否
Property IsDefault As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 5, SqlFieldName = IsDefault ];

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 6, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 7, SqlFieldName = StopDate ];

/// 更新日期 系统自动产生
Property UpdateDate As %Date [ Required, SqlColumnNumber = 8, SqlFieldName = UpdateDate ];

/// 更新时间 系统自动产生
Property UpdateTime As %Time [ Required, SqlColumnNumber = 9, SqlFieldName = UpdateTime ];

/// 更新人员ID 指向用户表 HB_User
Property UpdateUserDr As HBUser [ Required, SqlColumnNumber = 10, SqlFieldName = UpdateUser_Dr ];

Storage Default
{
<Data name="HBUserLogonLocDefaultData">
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
<Value>GroupDr</Value>
</Value>
<Value name="5">
<Value>IsDefault</Value>
</Value>
<Value name="6">
<Value>StartDate</Value>
</Value>
<Value name="7">
<Value>StopDate</Value>
</Value>
<Value name="8">
<Value>UpdateDate</Value>
</Value>
<Value name="9">
<Value>UpdateTime</Value>
</Value>
<Value name="10">
<Value>UpdateUserDr</Value>
</Value>
</Data>
<DataLocation>^HBUserLogonLocD</DataLocation>
<DefaultData>HBUserLogonLocDefaultData</DefaultData>
<ExtentSize>7</ExtentSize>
<IdLocation>^HBUserLogonLocD</IdLocation>
<IndexLocation>^HBUserLogonLocI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="GroupDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="HospDr">
<AverageFieldSize>3</AverageFieldSize>
<OutlierSelectivity>.857143:6</OutlierSelectivity>
<Selectivity>14.2857%</Selectivity>
</Property>
<Property name="IsDefault">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="UpdateDate">
<AverageFieldSize>5</AverageFieldSize>
<OutlierSelectivity>.857143:66302</OutlierSelectivity>
<Selectivity>14.2857%</Selectivity>
</Property>
<Property name="UpdateTime">
<AverageFieldSize>7</AverageFieldSize>
<OutlierSelectivity>.714286:65729</OutlierSelectivity>
<Selectivity>14.2857%</Selectivity>
</Property>
<Property name="UpdateUserDr">
<AverageFieldSize>3.29</AverageFieldSize>
<OutlierSelectivity>.857143:1</OutlierSelectivity>
<Selectivity>14.2857%</Selectivity>
</Property>
<Property name="UserDr">
<AverageFieldSize>5</AverageFieldSize>
<OutlierSelectivity>.714286:135</OutlierSelectivity>
<Selectivity>14.2857%</Selectivity>
</Property>
<SQLMap name="Group">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Hosp">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^HBUserLogonLocS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
