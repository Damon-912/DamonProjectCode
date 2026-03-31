Class User.BSBaseDataModifyLog Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_BaseDataModifyLog ]
{

Parameter %JSONREFERENCE = "ID";

/// 修改日期
Property ModifyDate As %Date [ Required, SqlColumnNumber = 2, SqlFieldName = ModifyDate ];

Index Date On ModifyDate;

/// 修改时间
Property ModifyTime As %Time [ Required, SqlColumnNumber = 3, SqlFieldName = ModifyTime ];

/// 修改人
Property ModifyUserDr As %String [ Required, SqlColumnNumber = 4, SqlFieldName = ModifyUser_Dr ];

Index User On ModifyUserDr;

/// IP地址
Property IPAddress As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 5, SqlFieldName = IPAddress ];

Index IPAddress On IPAddress;

/// Mac地址
Property MacAddress As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 6, SqlFieldName = MacAddress ];

Index MacAddress On MacAddress;

/// 医院ID 指向医院表CB_Hospital
Property HospitalDr As %String [ SqlColumnNumber = 7, SqlFieldName = Hospital_Dr ];

Index Hospital On HospitalDr;

/// 角色ID 指向角色表CB_Group
Property GroupDr As %String [ SqlColumnNumber = 8, SqlFieldName = Group_Dr ];

/// 科室ID 指向科室表HB_Loc
Property LocDr As %String [ SqlColumnNumber = 9, SqlFieldName = Loc_Dr ];

/// 修改表名
Property TableName As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = TableName ];

Index TableName On TableName;

/// 修改数据ID
Property TableDataID As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 11, SqlFieldName = TableDataID ];

Index TableDataID On TableDataID;

/// 修改前数据
Property BeforeData As %String(MAXLEN = 2000, TRUNCATE = 1) [ SqlColumnNumber = 12, SqlFieldName = BeforeData ];

/// 修改后数据
Property AfterData As %String(MAXLEN = 2000, TRUNCATE = 1) [ SqlColumnNumber = 13, SqlFieldName = AfterData ];

Storage Default
{
<Data name="BSBaseDataModifyLogDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ModifyDate</Value>
</Value>
<Value name="3">
<Value>ModifyTime</Value>
</Value>
<Value name="4">
<Value>ModifyUserDr</Value>
</Value>
<Value name="5">
<Value>IPAddress</Value>
</Value>
<Value name="6">
<Value>MacAddress</Value>
</Value>
<Value name="7">
<Value>HospitalDr</Value>
</Value>
<Value name="8">
<Value>GroupDr</Value>
</Value>
<Value name="9">
<Value>LocDr</Value>
</Value>
<Value name="10">
<Value>TableName</Value>
</Value>
<Value name="11">
<Value>TableDataID</Value>
</Value>
<Value name="12">
<Value>BeforeData</Value>
</Value>
<Value name="13">
<Value>AfterData</Value>
</Value>
</Data>
<DataLocation>^BSBaseDataModifyLogD</DataLocation>
<DefaultData>BSBaseDataModifyLogDefaultData</DefaultData>
<IdLocation>^BSBaseDataModifyLogD</IdLocation>
<IndexLocation>^BSBaseDataModifyLogI</IndexLocation>
<StreamLocation>^BSBaseDataModifyLogS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
