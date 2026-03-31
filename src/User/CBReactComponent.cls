/// 组件主表
Class User.CBReactComponent Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_ReactComponent ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code;

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

/// 路径
Property Path As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 4, SqlFieldName = Path ];

/// 组件地址 
Property ComAddress As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 5, SqlFieldName = ComAddress ];

/// 备注 
Property Note As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ SqlColumnNumber = 6, SqlFieldName = Note ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ SqlColumnNumber = 7, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 8, SqlFieldName = CreateUser_Dr ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", TRUNCATE = 1) [ SqlColumnNumber = 9, SqlFieldName = ENDesc ];

Storage Default
{
<Data name="CBReactComponentDefaultData">
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
<Value>Path</Value>
</Value>
<Value name="5">
<Value>ComAddress</Value>
</Value>
<Value name="6">
<Value>Note</Value>
</Value>
<Value name="7">
<Value>CreateDate</Value>
</Value>
<Value name="8">
<Value>CreateUserDr</Value>
</Value>
<Value name="9">
<Value>ENDesc</Value>
</Value>
</Data>
<DataLocation>^CBReactComponentD</DataLocation>
<DefaultData>CBReactComponentDefaultData</DefaultData>
<IdLocation>^CBReactComponentD</IdLocation>
<IndexLocation>^CBReactComponentI</IndexLocation>
<StreamLocation>^CBReactComponentS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
