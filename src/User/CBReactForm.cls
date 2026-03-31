Class User.CBReactForm Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_ReactForm ]
{

Parameter %JSONREFERENCE = "ID";

/// 组件表ID
Property CBReactComDr As CBReactComponent [ Required, SqlColumnNumber = 2, SqlFieldName = CBReactCom_Dr ];

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

Index Code On (CBReactComDr, Code) [ Unique ];

/// 描述 非空
Property Descripts As %String(MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Descripts ];

/// 序号
Property SeqNo As %String [ SqlColumnNumber = 5, SqlFieldName = SeqNo ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 300, TRUNCATE = 1) [ SqlColumnNumber = 6, SqlFieldName = ENDesc ];

/// 提示信息 
Property Placeholder As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 7, SqlFieldName = Placeholder ];

/// 字段类型
Property FieldTypeDr As CBConfigFieldType [ SqlColumnNumber = 8, SqlFieldName = FieldType_Dr ];

/// 回调方法
Property Callback As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 9, SqlFieldName = Callback ];

/// 描述介绍
Property Doubt As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = Doubt ];

/// 关联类名
Property ClassName As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 11, SqlFieldName = ClassName ];

/// 关联方法
Property MethodName As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 12, SqlFieldName = MethodName ];

/// 关联取值
Property LinkValueDr As %String [ SqlColumnNumber = 13, SqlFieldName = LinkValue_Dr ];

/// 占位
Property Col As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 14, SqlFieldName = Col ];

/// 跳转到
Property JumpDr As CBReactForm [ SqlColumnNumber = 15, SqlFieldName = Jump_Dr ];

/// 标签占位
Property LabelCol As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 16, SqlFieldName = LabelCol ];

/// 元素占位
Property WrapperCol As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 17, SqlFieldName = WrapperCol ];

/// 是否必填
Property Required As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 18, SqlFieldName = Required ];

/// 是否只读
Property Disabled As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 19, SqlFieldName = Disabled ];

/// 是否显示
Property Display As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 20, SqlFieldName = Display ];

/// 是否无效
Property Valid As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 21, SqlFieldName = Valid ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ SqlColumnNumber = 22, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 23, SqlFieldName = CreateUser_Dr ];

/// 关联取值接口代码
Property LinkCode As %String [ SqlColumnNumber = 24, SqlFieldName = LinkCode ];

/// 默认值
Property Default As %String [ SqlColumnNumber = 25, SqlFieldName = Default ];

/// 参数
Property Params As %String(COLLATION = "UPPER", MAXLEN = 3000, TRUNCATE = 1) [ SqlColumnNumber = 26, SqlFieldName = Params ];

/// 数据集元素id
Property ElementFieldDr As User.CBElementField [ SqlColumnNumber = 27, SqlFieldName = ElementField_Dr ];

Index ElementField On ElementFieldDr;

Storage Default
{
<Data name="CBReactFormDefaultData">
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
<Value>SeqNo</Value>
</Value>
<Value name="6">
<Value>ENDesc</Value>
</Value>
<Value name="7">
<Value>Placeholder</Value>
</Value>
<Value name="8">
<Value>FieldTypeDr</Value>
</Value>
<Value name="9">
<Value>Callback</Value>
</Value>
<Value name="10">
<Value>Doubt</Value>
</Value>
<Value name="11">
<Value>ClassName</Value>
</Value>
<Value name="12">
<Value>MethodName</Value>
</Value>
<Value name="13">
<Value>LinkValueDr</Value>
</Value>
<Value name="14">
<Value>Col</Value>
</Value>
<Value name="15">
<Value>JumpDr</Value>
</Value>
<Value name="16">
<Value>LabelCol</Value>
</Value>
<Value name="17">
<Value>WrapperCol</Value>
</Value>
<Value name="18">
<Value>Required</Value>
</Value>
<Value name="19">
<Value>Disabled</Value>
</Value>
<Value name="20">
<Value>Display</Value>
</Value>
<Value name="21">
<Value>Valid</Value>
</Value>
<Value name="22">
<Value>CreateDate</Value>
</Value>
<Value name="23">
<Value>CreateUserDr</Value>
</Value>
<Value name="24">
<Value>LinkCode</Value>
</Value>
<Value name="25">
<Value>Default</Value>
</Value>
<Value name="26">
<Value>Params</Value>
</Value>
<Value name="27">
<Value>ElementFieldDr</Value>
</Value>
</Data>
<DataLocation>^CBReactFormD</DataLocation>
<DefaultData>CBReactFormDefaultData</DefaultData>
<ExtentSize>1</ExtentSize>
<IdLocation>^CBReactFormD</IdLocation>
<IndexLocation>^CBReactFormI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="CBReactComDr">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Callback">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ClassName">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Code">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Col">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateDate">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="CreateUserDr">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Default">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Descripts">
<AverageFieldSize>8</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Disabled">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Display">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Doubt">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="ENDesc">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="FieldTypeDr">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="JumpDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="LabelCol">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="LinkCode">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="LinkValueDr">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="MethodName">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Params">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Placeholder">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Required">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="SeqNo">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Valid">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="WrapperCol">
<AverageFieldSize>4</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<SQLMap name="Code">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^CBReactFormS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
