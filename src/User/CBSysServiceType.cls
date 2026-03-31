/// 读写服务类型
Class User.CBSysServiceType Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_SysServiceType ]
{

Parameter %JSONREFERENCE = "ID";

/// 备用
Property Reserve As %String [ SqlColumnNumber = 2, SqlFieldName = Reserve ];

/// 代码
Property Code As %String(COLLATION = "UPPER", MAXLEN = 20) [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 4, SqlFieldName = Descripts ];

Index Desc On Descripts;

/// 服务器地址
Property ServiceIP As %String(COLLATION = "UPPER", MAXLEN = 30) [ SqlColumnNumber = 5, SqlFieldName = ServiceIP ];

/// 端口
Property Port As %String(COLLATION = "UPPER", MAXLEN = 8) [ SqlColumnNumber = 6, SqlFieldName = Port ];

/// 授权
Property Authorization As %String(COLLATION = "UPPER", MAXLEN = 100) [ Required, SqlColumnNumber = 7, SqlFieldName = Authorization ];

/// url
Property url As %String(COLLATION = "UPPER", MAXLEN = 100) [ SqlColumnNumber = 8, SqlFieldName = url ];

Storage Default
{
<Data name="CBSysServiceTypeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Reserve</Value>
</Value>
<Value name="3">
<Value>Code</Value>
</Value>
<Value name="4">
<Value>Descripts</Value>
</Value>
<Value name="5">
<Value>ServiceIP</Value>
</Value>
<Value name="6">
<Value>Port</Value>
</Value>
<Value name="7">
<Value>Authorization</Value>
</Value>
<Value name="8">
<Value>url</Value>
</Value>
</Data>
<DataLocation>^CBSysServiceTypeD</DataLocation>
<DefaultData>CBSysServiceTypeDefaultData</DefaultData>
<IdLocation>^CBSysServiceTypeD</IdLocation>
<IndexLocation>^CBSysServiceTypeI</IndexLocation>
<StreamLocation>^CBSysServiceTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
