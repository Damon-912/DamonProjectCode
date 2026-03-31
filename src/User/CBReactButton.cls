Class User.CBReactButton Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_ReactButton ]
{

Parameter %JSONREFERENCE = "ID";

/// 组件表ID
Property CBReactComDr As CBReactComponent [ Required, SqlColumnNumber = 2, SqlFieldName = CBReactCom_Dr ];

/// 代码 非空 
Property Code As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

Index Code On (CBReactComDr, Code) [ Unique ];

/// 描述 非空
Property Title As %String(MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Title ];

/// 图标
Property Icon As %String [ SqlColumnNumber = 5, SqlFieldName = Icon ];

/// 点击事件 
Property OnClick As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 6, SqlFieldName = OnClick ];

/// 类型 
Property TypeDr As CBBasicDictionarySub [ SqlColumnNumber = 7, SqlFieldName = Type_Dr ];

/// 按钮大小
Property SizeDr As CBBasicDictionarySub [ SqlColumnNumber = 8, SqlFieldName = Size_Dr ];

/// 形状
Property ShapeDr As CBBasicDictionarySub [ SqlColumnNumber = 9, SqlFieldName = Shape_Dr ];

/// 跳转地址
Property Href As %String(COLLATION = "UPPER", MAXLEN = 300, TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = Href ];

/// target属性
Property Target As %String [ SqlColumnNumber = 11, SqlFieldName = Target ];

/// 背景透明
Property Ghost As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 12, SqlFieldName = Ghost ];

/// 关联方法
Property Block As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 13, SqlFieldName = Block ];

/// 是否无效
Property Valid As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 14, SqlFieldName = Valid ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ SqlColumnNumber = 15, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 16, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBReactButtonDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CBReactComDr</Value>
</Value>
<Value name="3">
<Value>Code</Value>
</Value>
<Value name="4">
<Value>Title</Value>
</Value>
<Value name="5">
<Value>Icon</Value>
</Value>
<Value name="6">
<Value>OnClick</Value>
</Value>
<Value name="7">
<Value>TypeDr</Value>
</Value>
<Value name="8">
<Value>SizeDr</Value>
</Value>
<Value name="9">
<Value>ShapeDr</Value>
</Value>
<Value name="10">
<Value>Href</Value>
</Value>
<Value name="11">
<Value>Target</Value>
</Value>
<Value name="12">
<Value>Ghost</Value>
</Value>
<Value name="13">
<Value>Block</Value>
</Value>
<Value name="14">
<Value>Valid</Value>
</Value>
<Value name="15">
<Value>CreateDate</Value>
</Value>
<Value name="16">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>^CBReactButtonD</DataLocation>
<DefaultData>CBReactButtonDefaultData</DefaultData>
<ExtentSize>2</ExtentSize>
<IdLocation>^CBReactButtonD</IdLocation>
<IndexLocation>^CBReactButtonI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Block">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CBReactComDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>6</AverageFieldSize>
<Selectivity>50.0000%</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Ghost">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Href">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Icon">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="OnClick">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ShapeDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="SizeDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Target">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Title">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="TypeDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Valid">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^CBReactButtonS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
