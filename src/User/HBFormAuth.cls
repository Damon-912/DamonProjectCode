Class User.HBFormAuth Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_FormAuth ]
{

Parameter %JSONREFERENCE = "ID";

/// Type分为 医院 H，角色 G，用户 U。 --属性修改
Property Type As %String(COLLATION = "UPPER", DISPLAYLIST = ",Hospital,Group,User", TRUNCATE = 1, VALUELIST = ",H,G,U") [ Required, SqlColumnNumber = 3, SqlFieldName = Type ];

Index Type On (Type, DataID, ComponentDr, ComFormDr);

/// 根据Type的不同，保存的ID对应的表不同
Property DataID As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 2, SqlFieldName = DataID ];

/// 组件ID
Property ComponentDr As CBReactComponent [ Required, SqlColumnNumber = 4, SqlFieldName = Component_Dr ];

/// 表单元素ID
Property ComFormDr As User.CBReactForm [ Required, SqlColumnNumber = 5, SqlFieldName = ComForm_Dr ];

/// 先后顺序 
Property SeqNo As %Integer [ SqlColumnNumber = 6, SqlFieldName = SeqNo ];

/// 占位
Property Col As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 7, SqlFieldName = Col ];

/// 跳转到
Property JumpDr As CBReactForm [ SqlColumnNumber = 8, SqlFieldName = Jump_Dr ];

/// 标签占位
Property LabelCol As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 9, SqlFieldName = LabelCol ];

/// 元素占位
Property WrapperCol As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = WrapperCol ];

/// 创建用户
Property UserDr As HBUser [ SqlColumnNumber = 11, SqlFieldName = User_Dr ];

/// 医院ID 指向医院表CB_Hospital
Property HospitalDr As CBHospital [ SqlColumnNumber = 12, SqlFieldName = Hospital_Dr ];

Index HospID On HospitalDr;

Index HospType On (Type, DataID, HospitalDr, ComponentDr, ComFormDr) [ Unique ];

Storage Default
{
<Data name="HBFormAuthDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Type</Value>
</Value>
<Value name="3">
<Value>DataID</Value>
</Value>
<Value name="4">
<Value>ComponentDr</Value>
</Value>
<Value name="5">
<Value>ComFormDr</Value>
</Value>
<Value name="6">
<Value>SeqNo</Value>
</Value>
<Value name="7">
<Value>Col</Value>
</Value>
<Value name="8">
<Value>JumpDr</Value>
</Value>
<Value name="9">
<Value>LabelCol</Value>
</Value>
<Value name="10">
<Value>WrapperCol</Value>
</Value>
<Value name="11">
<Value>UserDr</Value>
</Value>
<Value name="12">
<Value>HospitalDr</Value>
</Value>
</Data>
<DataLocation>^HBFormAuthD</DataLocation>
<DefaultData>HBFormAuthDefaultData</DefaultData>
<ExtentSize>5</ExtentSize>
<IdLocation>^HBFormAuthD</IdLocation>
<IndexLocation>^HBFormAuthI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Col">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ComFormDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
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
<Property name="JumpDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="LabelCol">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="SeqNo">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>20.0000%</Selectivity>
</Property>
<Property name="Type">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="UserDr">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="WrapperCol">
<AverageFieldSize>2</AverageFieldSize>
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
<StreamLocation>^HBFormAuthS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
