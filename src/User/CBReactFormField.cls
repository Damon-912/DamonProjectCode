/// 组件字段表
Class User.CBReactFormField Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_ReactFormField ]
{

Parameter %JSONREFERENCE = "ID";

/// 组件表ID
Property CBReactComDr As CBReactComponent [ Required, SqlColumnNumber = 2, SqlFieldName = CBReactCom_Dr ];

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

Index Code On (CBReactComDr, Code) [ Unique ];

/// 描述 非空
Property Descripts As %String(MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Descripts ];

/// 是否必填
Property Required As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 5, SqlFieldName = Required ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 300, TRUNCATE = 1) [ SqlColumnNumber = 6, SqlFieldName = ENDesc ];

/// 表单Message 
Property Message As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 7, SqlFieldName = Message ];

/// 表单Message 英文描述
Property MessageEN As %String(COLLATION = "UPPER", MAXLEN = 300, TRUNCATE = 1) [ SqlColumnNumber = 8, SqlFieldName = MessageEN ];

/// 字段类型
Property FieldTypeDr As CBConfigFieldType [ SqlColumnNumber = 9, SqlFieldName = FieldType_Dr ];

/// 长度限制
Property Length As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = Length ];

/// 焦点跳转顺序
Property FocusIndex As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 11, SqlFieldName = FocusIndex ];

/// 后缀
Property Suffix As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 12, SqlFieldName = Suffix ];

/// 是否无效
Property Disabled As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 13, SqlFieldName = Disabled ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ SqlColumnNumber = 14, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 15, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBReactFormFieldDefaultData">
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
<Value>Required</Value>
</Value>
<Value name="6">
<Value>ENDesc</Value>
</Value>
<Value name="7">
<Value>Message</Value>
</Value>
<Value name="8">
<Value>MessageEN</Value>
</Value>
<Value name="9">
<Value>FieldTypeDr</Value>
</Value>
<Value name="10">
<Value>Length</Value>
</Value>
<Value name="11">
<Value>FocusIndex</Value>
</Value>
<Value name="12">
<Value>Suffix</Value>
</Value>
<Value name="13">
<Value>Disabled</Value>
</Value>
<Value name="14">
<Value>CreateDate</Value>
</Value>
<Value name="15">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>^CBReactFormFieldD</DataLocation>
<DefaultData>CBReactFormFieldDefaultData</DefaultData>
<IdLocation>^CBReactFormFieldD</IdLocation>
<IndexLocation>^CBReactFormFieldI</IndexLocation>
<StreamLocation>^CBReactFormFieldS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
