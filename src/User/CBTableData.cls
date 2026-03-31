Class User.CBTableData Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_TableData ]
{

Parameter %JSONREFERENCE = "ID";

Relationship ChildCBTableFieldExt As CBTableFieldExt [ Cardinality = children, Inverse = CBTFEParRef ];

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

/// 备注 
Property Notes As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 4, SqlFieldName = ClassName ];

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 5, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 6, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ InitialExpression = {+$h}, SqlColumnNumber = 7, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 8, SqlFieldName = CreateUser_Dr ];

/// 备注 
Property FieldSort As %String(COLLATION = "UPPER", MAXLEN = 800, TRUNCATE = 1) [ SqlColumnNumber = 9, SqlFieldName = FieldSort ];

/// 安全等级 
Property SafeClassificat As %String(COLLATION = "UPPER", MAXLEN = 800, TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = SafeClassificat ];

/// 列数 
Property ColNum As %String(COLLATION = "UPPER", MAXLEN = 800, TRUNCATE = 1) [ SqlColumnNumber = 11, SqlFieldName = ColNum ];

/// 父表 
Property TableDataRef As CBTableData [ SqlColumnNumber = 12, SqlFieldName = TableDataRef ];

Index TableRef On TableDataRef;

/// 产品模块
Property ProductModuleDr As CBProductModule [ SqlColumnNumber = 13, SqlFieldName = ProductModule_Dr ];

/// global
Property GlobalName As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 14, SqlFieldName = GlobalName ];

/// 医院标志 表里是否有字段指向医院表
Property HospitalFlag As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 15, SqlFieldName = HospitalFlag ];

/// 常用
Property FrequeUse As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 16, SqlFieldName = FrequeUse ];

/// 简写
Property ShortDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 17, SqlFieldName = ShortDesc ];

/// 编辑标志
Property EditFlag As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 18, SqlFieldName = EditFlag ];

/// 远程调用
Property RemoteFlag As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 19, SqlFieldName = RemoteFlag ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 20, SqlFieldName = ENDesc ];

Storage Default
{
<Data name="CBTableDataDefaultData">
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
<Value>StartDate</Value>
</Value>
<Value name="6">
<Value>StopDate</Value>
</Value>
<Value name="7">
<Value>CreateDate</Value>
</Value>
<Value name="8">
<Value>CreateUserDr</Value>
</Value>
<Value name="9">
<Value>FieldSort</Value>
</Value>
<Value name="10">
<Value>SafeClassificat</Value>
</Value>
<Value name="11">
<Value>ColNum</Value>
</Value>
<Value name="12">
<Value>TableDataRef</Value>
</Value>
<Value name="13">
<Value>ProductModuleDr</Value>
</Value>
<Value name="14">
<Value>GlobalName</Value>
</Value>
<Value name="15">
<Value>HospitalFlag</Value>
</Value>
<Value name="16">
<Value>FrequeUse</Value>
</Value>
<Value name="17">
<Value>ShortDesc</Value>
</Value>
<Value name="18">
<Value>EditFlag</Value>
</Value>
<Value name="19">
<Value>RemoteFlag</Value>
</Value>
<Value name="20">
<Value>ENDesc</Value>
</Value>
</Data>
<DataLocation>^CBTableDataD</DataLocation>
<DefaultData>CBTableDataDefaultData</DefaultData>
<ExtentSize>424</ExtentSize>
<IdLocation>^CBTableDataD</IdLocation>
<IndexLocation>^CBTableDataI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>2.75</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>18.81</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="ColNum">
<AverageFieldSize>1</AverageFieldSize>
<OutlierSelectivity>.919811:4</OutlierSelectivity>
<Selectivity>1.3365%</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>2.85</AverageFieldSize>
<OutlierSelectivity>.429245:</OutlierSelectivity>
<Selectivity>0.5596%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>.17</AverageFieldSize>
<OutlierSelectivity>.832547:</OutlierSelectivity>
<Selectivity>8.3726%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>5.49</AverageFieldSize>
<Selectivity>0.2370%</Selectivity>
</Property>
<Property name="ENDesc">
<AverageFieldSize>14.97</AverageFieldSize>
<OutlierSelectivity>.264151:</OutlierSelectivity>
<Selectivity>0.2405%</Selectivity>
</Property>
<Property name="EditFlag">
<AverageFieldSize>.54</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="FieldSort">
<AverageFieldSize>34.06</AverageFieldSize>
<OutlierSelectivity>.688679:</OutlierSelectivity>
<Selectivity>0.2358%</Selectivity>
</Property>
<Property name="FrequeUse">
<AverageFieldSize>.62</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="GlobalName">
<AverageFieldSize>16.06</AverageFieldSize>
<OutlierSelectivity>.375:</OutlierSelectivity>
<Selectivity>0.2358%</Selectivity>
</Property>
<Property name="HospitalFlag">
<AverageFieldSize>.17</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="Notes">
<AverageFieldSize>.06</AverageFieldSize>
<OutlierSelectivity>.992925:</OutlierSelectivity>
<Selectivity>0.2358%</Selectivity>
</Property>
<Property name="ProductModuleDr">
<AverageFieldSize>.28</AverageFieldSize>
<OutlierSelectivity>.806604:</OutlierSelectivity>
<Selectivity>1.2087%</Selectivity>
</Property>
<Property name="RemoteFlag">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="SafeClassificat">
<AverageFieldSize>1</AverageFieldSize>
<OutlierSelectivity>.995283:</OutlierSelectivity>
<Selectivity>0.2358%</Selectivity>
</Property>
<Property name="ShortDesc">
<AverageFieldSize>.02</AverageFieldSize>
<OutlierSelectivity>.997642:</OutlierSelectivity>
<Selectivity>0.2358%</Selectivity>
</Property>
<Property name="StartDate">
<AverageFieldSize>5</AverageFieldSize>
<OutlierSelectivity>.167453:65071</OutlierSelectivity>
<Selectivity>0.6404%</Selectivity>
</Property>
<Property name="StopDate">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="TableDataRef">
<AverageFieldSize>.3</AverageFieldSize>
<OutlierSelectivity>.877358:</OutlierSelectivity>
<Selectivity>0.3956%</Selectivity>
</Property>
<SQLMap name="Code">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-320</BlockCount>
</SQLMap>
<SQLMap name="TableRef">
<BlockCount>-8</BlockCount>
</SQLMap>
<StreamLocation>^CBTableDataS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
