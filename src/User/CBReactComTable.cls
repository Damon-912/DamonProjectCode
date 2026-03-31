/// 组件table表
Class User.CBReactComTable Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_ReactComTable ]
{

Parameter %JSONREFERENCE = "ID";

/// 组件表ID
Property CBReactComDr As CBReactComponent [ Required, SqlColumnNumber = 2, SqlFieldName = CBReactCom_Dr ];

/// 代码 非空 
Property Code As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

Index Code On (CBReactComDr, Code) [ Unique ];

/// 描述 非空
Property Descripts As %String(MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Descripts ];

/// 类型 列类型为column，按钮类型为button  按钮类型无宽度，无先后顺序，无是否显示，无是否打印，无是否导出属性
Property Type As %String(DISPLAYLIST = ",Column,Button", TRUNCATE = 1, VALUELIST = ",C,B") [ Required, SqlColumnNumber = 5, SqlFieldName = Type ];

/// 宽度
Property Width As %String [ SqlColumnNumber = 6, SqlFieldName = Width ];

/// 先后顺序 
Property SeqNo As %Integer [ SqlColumnNumber = 7, SqlFieldName = SeqNo ];

/// 是否显示
Property Display As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 8, SqlFieldName = Display ];

/// 是否打印
Property Print As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 9, SqlFieldName = Print ];

/// 是否导出
Property Export As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 10, SqlFieldName = Export ];

/// 关联方法
Property LinkMethod As %String [ SqlColumnNumber = 11, SqlFieldName = LinkMethod ];

/// 关联服务
Property LinkService As %String [ SqlColumnNumber = 12, SqlFieldName = LinkService ];

/// 对齐方式
Property Align As %String(DISPLAYLIST = ",left,right,center", TRUNCATE = 1, VALUELIST = ",left,right,center") [ SqlColumnNumber = 13, SqlFieldName = Align ];

/// 列是否固定，可选 true(等效于 left) 'left' 'right'
Property Fixed As %String(DISPLAYLIST = ",left,right", TRUNCATE = 1, VALUELIST = ",left,right") [ SqlColumnNumber = 14, SqlFieldName = Fixed ];

/// 是否显示标题
Property Visible As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 15, SqlFieldName = Visible ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 16, SqlFieldName = ENDesc ];

/// 字段类型
Property FieldTypeDr As CBConfigFieldType [ SqlColumnNumber = 17, SqlFieldName = FieldType_Dr ];

/// 参数
Property Params As %String(COLLATION = "UPPER", MAXLEN = 3000, TRUNCATE = 1) [ SqlColumnNumber = 18, SqlFieldName = Params ];

/// 输入与描述
Property Doubt As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 19, SqlFieldName = Doubt ];

Storage Default
{
<Data name="CBReactComTableDefaultData">
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
<Value>Descripts</Value>
</Value>
<Value name="5">
<Value>Type</Value>
</Value>
<Value name="6">
<Value>Width</Value>
</Value>
<Value name="7">
<Value>SeqNo</Value>
</Value>
<Value name="8">
<Value>Display</Value>
</Value>
<Value name="9">
<Value>Print</Value>
</Value>
<Value name="10">
<Value>Export</Value>
</Value>
<Value name="11">
<Value>LinkMethod</Value>
</Value>
<Value name="12">
<Value>LinkService</Value>
</Value>
<Value name="13">
<Value>Align</Value>
</Value>
<Value name="14">
<Value>Fixed</Value>
</Value>
<Value name="15">
<Value>Visible</Value>
</Value>
<Value name="16">
<Value>ENDesc</Value>
</Value>
<Value name="17">
<Value>FieldTypeDr</Value>
</Value>
<Value name="18">
<Value>Params</Value>
</Value>
<Value name="19">
<Value>Doubt</Value>
</Value>
</Data>
<DataLocation>^CBReactComTableD</DataLocation>
<DefaultData>CBReactComTableDefaultData</DefaultData>
<ExtentSize>143</ExtentSize>
<IdLocation>^CBReactComTableD</IdLocation>
<IndexLocation>^CBReactComTableI</IndexLocation>
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
<Property name="CBReactComDr">
<AverageFieldSize>3.52</AverageFieldSize>
<Selectivity>5.0000%</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>10.85</AverageFieldSize>
<OutlierSelectivity>.055944:"code"</OutlierSelectivity>
<Selectivity>0.9441%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>9.83</AverageFieldSize>
<OutlierSelectivity>.055944:"代码"</OutlierSelectivity>
<Selectivity>0.9633%</Selectivity>
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
<Property name="FieldTypeDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Fixed">
<AverageFieldSize>2.12</AverageFieldSize>
<OutlierSelectivity>.972028:</OutlierSelectivity>
<Selectivity>1.3986%</Selectivity>
</Property>
<Property name="LinkMethod">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="LinkService">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Print">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="SeqNo">
<AverageFieldSize>2.01</AverageFieldSize>
<OutlierSelectivity>.993007:</OutlierSelectivity>
<Selectivity>0.6993%</Selectivity>
</Property>
<Property name="Type">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Visible">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Width">
<AverageFieldSize>3.49</AverageFieldSize>
<OutlierSelectivity>.741259:100</OutlierSelectivity>
<Selectivity>4.3124%</Selectivity>
</Property>
<SQLMap name="Code">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-8</BlockCount>
</SQLMap>
<StreamLocation>^CBReactComTableS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
