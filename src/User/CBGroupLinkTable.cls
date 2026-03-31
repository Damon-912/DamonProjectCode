Class User.CBGroupLinkTable Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_GroupLinkTable ]
{

Parameter %JSONREFERENCE = "ID";

Relationship ChildCBGroupLinkTableAuth As CBGroupLinkTableAuth [ Cardinality = children, Inverse = CBGTAParRef ];

/// 指向基础数据分类表
Property GroupDr As CBGroup [ Required, SqlColumnNumber = 2, SqlFieldName = Group_Dr ];

/// 类名
Property TableDataDr As CBTableData [ Required, SqlColumnNumber = 3, SqlFieldName = TableData_Dr ];

Index TableGroup On (GroupDr, TableDataDr) [ Unique ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 4, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 5, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBGroupLinkTableDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>GroupDr</Value>
</Value>
<Value name="3">
<Value>TableDataDr</Value>
</Value>
<Value name="4">
<Value>CreateDate</Value>
</Value>
<Value name="5">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>^CBGroupLinkTableD</DataLocation>
<DefaultData>CBGroupLinkTableDefaultData</DefaultData>
<ExtentSize>1</ExtentSize>
<IdLocation>^CBGroupLinkTableD</IdLocation>
<IndexLocation>^CBGroupLinkTableI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="GroupDr">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="TableDataDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="TableGroup">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^CBGroupLinkTableS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
