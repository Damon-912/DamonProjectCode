Class User.HBTableAuth Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_TableAuth ]
{

Parameter %JSONREFERENCE = "ID";

/// 根据Type的不同，保存的ID对应的表不同
Property DataID As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 2, SqlFieldName = DataID ];

/// Type分为 医院 H，角色 G，用户 U。
Property Type As %String(COLLATION = "UPPER", DISPLAYLIST = ",Hospital,Group,User", TRUNCATE = 1, VALUELIST = ",H,G,U") [ Required, SqlColumnNumber = 3, SqlFieldName = Type ];

Index Type On (Type, DataID, ComponentDr, ComTableDr);

/// 组件ID
Property ComponentDr As CBReactComponent [ Required, SqlColumnNumber = 4, SqlFieldName = Component_Dr ];

/// 列ID
Property ComTableDr As CBReactComTable [ Required, SqlColumnNumber = 5, SqlFieldName = ComTable_Dr ];

/// 先后顺序 
Property SeqNo As %Integer [ SqlColumnNumber = 6, SqlFieldName = SeqNo ];

/// 是否显示
Property Display As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 7, SqlFieldName = Display ];

/// 是否打印
Property Print As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 8, SqlFieldName = Print ];

/// 是否导出
Property Export As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 9, SqlFieldName = Export ];

/// 创建用户
Property UserDr As HBUser [ SqlColumnNumber = 10, SqlFieldName = User_Dr ];

/// 组件元素描述
Property Title As %String [ SqlColumnNumber = 11, SqlFieldName = Title ];

/// 组件元素宽度
Property Width As %String [ SqlColumnNumber = 12, SqlFieldName = Width ];

/// 对齐方式
Property Align As %String(DISPLAYLIST = ",left,right,center", TRUNCATE = 1, VALUELIST = ",left,right,center") [ SqlColumnNumber = 13, SqlFieldName = Align ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 14, SqlFieldName = ENDesc ];

/// 列是否固定，可选 true(等效于 left) 'left' 'right'
Property Fixed As %String(DISPLAYLIST = ",left,right", TRUNCATE = 1, VALUELIST = ",left,right") [ SqlColumnNumber = 15, SqlFieldName = Fixed ];

/// 医院ID 指向医院表CB_Hospital
Property HospitalDr As CBHospital [ SqlColumnNumber = 16, SqlFieldName = Hospital_Dr ];

Index HospID On HospitalDr;

Index HospType On (Type, DataID, HospitalDr, ComponentDr, ComTableDr) [ Unique ];

/// 是否加密
Property Encrypt As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 17, SqlFieldName = Encrypt ];

Storage Default
{
<Data name="HBTableAuthDefaultData">
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
<Value>ComTableDr</Value>
</Value>
<Value name="6">
<Value>SeqNo</Value>
</Value>
<Value name="7">
<Value>Display</Value>
</Value>
<Value name="8">
<Value>Print</Value>
</Value>
<Value name="9">
<Value>Export</Value>
</Value>
<Value name="10">
<Value>UserDr</Value>
</Value>
<Value name="11">
<Value>Title</Value>
</Value>
<Value name="12">
<Value>Width</Value>
</Value>
<Value name="13">
<Value>Align</Value>
</Value>
<Value name="14">
<Value>ENDesc</Value>
</Value>
<Value name="15">
<Value>Fixed</Value>
</Value>
<Value name="16">
<Value>HospitalDr</Value>
</Value>
<Value name="17">
<Value>Encrypt</Value>
</Value>
</Data>
<DataLocation>^HBTableAuthD</DataLocation>
<DefaultData>HBTableAuthDefaultData</DefaultData>
<ExtentSize>17</ExtentSize>
<IdLocation>^HBTableAuthD</IdLocation>
<IndexLocation>^HBTableAuthI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Align">
<AverageFieldSize>8</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ComTableDr">
<AverageFieldSize>3.94</AverageFieldSize>
<Selectivity>5.8824%</Selectivity>
</Property>
<Property name="ComponentDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="DataID">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Display">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ENDesc">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Export">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Fixed">
<AverageFieldSize>2.71</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Print">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="SeqNo">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>5.8824%</Selectivity>
</Property>
<Property name="Title">
<AverageFieldSize>10</AverageFieldSize>
<Selectivity>5.8824%</Selectivity>
</Property>
<Property name="Type">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="UserDr">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Width">
<AverageFieldSize>4.12</AverageFieldSize>
<Selectivity>14.2857%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="Type">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^HBTableAuthS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
