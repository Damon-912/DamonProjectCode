Class User.HBButtonAuth Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_ButtonAuth ]
{

Parameter %JSONREFERENCE = "ID";

/// 根据Type的不同，保存的ID对应的表不同
Property DataID As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 2, SqlFieldName = DataID ];

/// Type分为 医院 H，角色 G，用户 U。 --属性修改
Property Type As %String(COLLATION = "UPPER", DISPLAYLIST = ",Hospital,Group,User", TRUNCATE = 1, VALUELIST = ",H,G,U") [ Required, SqlColumnNumber = 3, SqlFieldName = Type ];

Index Type On (Type, DataID, ComponentDr, ButtonDr);

/// 组件ID
Property ComponentDr As CBReactComponent [ Required, SqlColumnNumber = 4, SqlFieldName = Component_Dr ];

/// 表单元素ID
Property ButtonDr As User.CBReactButton [ Required, SqlColumnNumber = 5, SqlFieldName = Button_Dr ];

/// 图标
Property Icon As %String [ SqlColumnNumber = 6, SqlFieldName = Icon ];

/// 创建用户
Property UserDr As HBUser [ SqlColumnNumber = 7, SqlFieldName = User_Dr ];

/// 医院ID 指向医院表CB_Hospital
Property HospitalDr As CBHospital [ SqlColumnNumber = 8, SqlFieldName = Hospital_Dr ];

Index HospID On HospitalDr;

Index HospType On (Type, DataID, HospitalDr, ComponentDr, ButtonDr) [ Unique ];

Storage Default
{
<Data name="HBButtonAuthDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DataID</Value>
</Value>
<Value name="3">
<Value>Type</Value>
</Value>
<Value name="4">
<Value>ComponentDr</Value>
</Value>
<Value name="5">
<Value>ButtonDr</Value>
</Value>
<Value name="6">
<Value>Icon</Value>
</Value>
<Value name="7">
<Value>UserDr</Value>
</Value>
<Value name="8">
<Value>HospitalDr</Value>
</Value>
</Data>
<DataLocation>^HBButtonAuthD</DataLocation>
<DefaultData>HBButtonAuthDefaultData</DefaultData>
<ExtentSize>2</ExtentSize>
<IdLocation>^HBButtonAuthD</IdLocation>
<IndexLocation>^HBButtonAuthI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="ButtonDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="ComponentDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="DataID">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="HospitalDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Icon">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Type">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="UserDr">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="HospID">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="HospType">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Type">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^HBButtonAuthS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
