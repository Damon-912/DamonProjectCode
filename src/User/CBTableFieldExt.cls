Class User.CBTableFieldExt Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_TableFieldExt ]
{

Parameter %JSONREFERENCE = "ID";

Relationship CBTFEParRef As CBTableData [ Cardinality = parent, Inverse = ChildCBTableFieldExt, Required, SqlFieldName = CBTFE_ParRef ];

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On (CBTFEParRef, Code);

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

/// 备注 
Property Notes As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 4, SqlFieldName = Notes ];

/// global取值序号 
Property DataValue As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 5, SqlFieldName = DataValue ];

/// 查询标志 
Property FindFlag As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 6, SqlFieldName = FindFlag ];

/// 编辑标志 
Property EditFlag As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 7, SqlFieldName = EditFlag ];

/// 列输出 
Property ColumnFlag As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 8, SqlFieldName = ColumnFlag ];

/// 列宽度 
Property ColumnWidth As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 9, SqlFieldName = ColumnWidth ];

/// 组件类型 
Property CompType As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = CompType ];

/// 指向表 
Property DirectTable As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 11, SqlFieldName = DirectTable ];

/// 显示字段名
Property ShowField As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 12, SqlFieldName = ShowField ];

/// 显示字段的取值序号 
Property DirectDataValue As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 13, SqlFieldName = DirectDataValue ];

/// 顺序号 
Property SeqNo As %Integer [ SqlColumnNumber = 14, SqlFieldName = SeqNo ];

/// 是否可以改变编辑标志 
Property ChangeEditFlag As %String [ SqlColumnNumber = 15, SqlFieldName = ChangeEditFlag ];

/// 是否可以改变编辑标志 
Property RequiredFlag As %String [ SqlColumnNumber = 16, SqlFieldName = RequiredFlag ];

/// 是否可以改变编辑标志 
Property ReadOnlyFlag As %String [ SqlColumnNumber = 17, SqlFieldName = ReadOnlyFlag ];

/// 级联关系字段
Property RelationFieldDrStr As %String [ SqlColumnNumber = 18, SqlFieldName = RelationFieldDrStr ];

Index RelField On RelationFieldDrStr;

/// 级联关系字段
Property RelationTableField As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 19, SqlFieldName = RelationTableField ];

/// 级联关系字段
Property GlobalName As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 20, SqlFieldName = GlobalName ];

/// list 类型
Property Collection As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 21, SqlFieldName = Collection ];

/// 有指向关系的索引名称
Property IndexCode As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 22, SqlFieldName = IndexCode ];

/// Code字段
Property CodeField As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 23, SqlFieldName = CodeField ];

/// Code字段限值
Property CodeFieldValue As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 24, SqlFieldName = CodeFieldValue ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 25, SqlFieldName = ENDesc ];

/// 是否可以改变编辑标志 
Property RemoteSearch As %String [ SqlColumnNumber = 26, SqlFieldName = RemoteSearch ];

Storage Default
{
<Data name="CBTableFieldExtDefaultData">
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
<Value>Notes</Value>
</Value>
<Value name="5">
<Value>DataValue</Value>
</Value>
<Value name="6">
<Value>FindFlag</Value>
</Value>
<Value name="7">
<Value>EditFlag</Value>
</Value>
<Value name="8">
<Value>ColumnFlag</Value>
</Value>
<Value name="9">
<Value>ColumnWidth</Value>
</Value>
<Value name="10">
<Value>CompType</Value>
</Value>
<Value name="11">
<Value>DirectTable</Value>
</Value>
<Value name="12">
<Value>ShowField</Value>
</Value>
<Value name="13">
<Value>DirectDataValue</Value>
</Value>
<Value name="14">
<Value>SeqNo</Value>
</Value>
<Value name="15">
<Value>ChangeEditFlag</Value>
</Value>
<Value name="16">
<Value>RequiredFlag</Value>
</Value>
<Value name="17">
<Value>ReadOnlyFlag</Value>
</Value>
<Value name="18">
<Value>RelationFieldDrStr</Value>
</Value>
<Value name="19">
<Value>RelationTableField</Value>
</Value>
<Value name="20">
<Value>GlobalName</Value>
</Value>
<Value name="21">
<Value>Collection</Value>
</Value>
<Value name="22">
<Value>IndexCode</Value>
</Value>
<Value name="23">
<Value>CodeField</Value>
</Value>
<Value name="24">
<Value>CodeFieldValue</Value>
</Value>
<Value name="25">
<Value>ENDesc</Value>
</Value>
<Value name="26">
<Value>RemoteSearch</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("O")</DataLocation>
<DefaultData>CBTableFieldExtDefaultData</DefaultData>
<ExtentSize>3984</ExtentSize>
<IdLocation>^CBTableDataC("O")</IdLocation>
<IndexLocation>^CBTableFieldExtI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>8.44</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CBTFEParRef">
<AverageFieldSize>2.71</AverageFieldSize>
<Selectivity>0.3538%</Selectivity>
</Property>
<Property name="ChangeEditFlag">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>49.9999%</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>8.49</AverageFieldSize>
<Selectivity>1.2866%</Selectivity>
</Property>
<Property name="CodeField">
<AverageFieldSize>.53</AverageFieldSize>
<OutlierSelectivity>.867725:</OutlierSelectivity>
<Selectivity>13.2274%</Selectivity>
</Property>
<Property name="CodeFieldValue">
<AverageFieldSize>.13</AverageFieldSize>
<OutlierSelectivity>.867725:</OutlierSelectivity>
<Selectivity>4.4090%</Selectivity>
</Property>
<Property name="Collection">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ColumnFlag">
<AverageFieldSize>1</AverageFieldSize>
<OutlierSelectivity>.984127:"Y"</OutlierSelectivity>
<Selectivity>1.5873%</Selectivity>
</Property>
<Property name="ColumnWidth">
<AverageFieldSize>.48</AverageFieldSize>
<OutlierSelectivity>.761905:</OutlierSelectivity>
<Selectivity>11.9047%</Selectivity>
</Property>
<Property name="CompType">
<AverageFieldSize>3.96</AverageFieldSize>
<Selectivity>14.2857%</Selectivity>
</Property>
<Property name="DataValue">
<AverageFieldSize>1.26</AverageFieldSize>
<Selectivity>3.8438%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>4.23</AverageFieldSize>
<Selectivity>1.3857%</Selectivity>
</Property>
<Property name="DirectDataValue">
<AverageFieldSize>.2</AverageFieldSize>
<OutlierSelectivity>.804233:</OutlierSelectivity>
<Selectivity>4.8941%</Selectivity>
</Property>
<Property name="DirectTable">
<AverageFieldSize>2.87</AverageFieldSize>
<OutlierSelectivity>.798942:</OutlierSelectivity>
<Selectivity>0.7832%</Selectivity>
</Property>
<Property name="ENDesc">
<AverageFieldSize>8.42</AverageFieldSize>
<OutlierSelectivity>.248677:</OutlierSelectivity>
<Selectivity>1.2071%</Selectivity>
</Property>
<Property name="EditFlag">
<AverageFieldSize>1</AverageFieldSize>
<OutlierSelectivity>.862434:"Y"</OutlierSelectivity>
<Selectivity>13.7565%</Selectivity>
</Property>
<Property name="FindFlag">
<AverageFieldSize>.25</AverageFieldSize>
<OutlierSelectivity>.751323:</OutlierSelectivity>
<Selectivity>12.4338%</Selectivity>
</Property>
<Property name="GlobalName">
<AverageFieldSize>2.52</AverageFieldSize>
<OutlierSelectivity>.867725:</OutlierSelectivity>
<Selectivity>0.8063%</Selectivity>
</Property>
<Property name="IndexCode">
<AverageFieldSize>2.14</AverageFieldSize>
<OutlierSelectivity>.920635:</OutlierSelectivity>
<Selectivity>0.6232%</Selectivity>
</Property>
<Property name="Notes">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ReadOnlyFlag">
<AverageFieldSize>.06</AverageFieldSize>
<OutlierSelectivity>.936508:</OutlierSelectivity>
<Selectivity>3.1738%</Selectivity>
</Property>
<Property name="RelationFieldDrStr">
<AverageFieldSize>.03</AverageFieldSize>
<OutlierSelectivity>.994709:</OutlierSelectivity>
<Selectivity>0.0252%</Selectivity>
</Property>
<Property name="RelationTableField">
<AverageFieldSize>.05</AverageFieldSize>
<OutlierSelectivity>.994709:</OutlierSelectivity>
<Selectivity>0.0252%</Selectivity>
</Property>
<Property name="RemoteSearch">
<AverageFieldSize>1</AverageFieldSize>
<OutlierSelectivity>.996296:</OutlierSelectivity>
<Selectivity>0.0370%</Selectivity>
</Property>
<Property name="RequiredFlag">
<AverageFieldSize>.85</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="SeqNo">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ShowField">
<AverageFieldSize>1.76</AverageFieldSize>
<Selectivity>49.9999%</Selectivity>
</Property>
<Property name="childsub">
<AverageFieldSize>3.73</AverageFieldSize>
<Selectivity>0.0251%</Selectivity>
</Property>
<SQLMap name="Code">
<BlockCount>-48</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-320</BlockCount>
</SQLMap>
<SQLMap name="RelField">
<BlockCount>-28</BlockCount>
</SQLMap>
<StreamLocation>^CBTableFieldExtS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
