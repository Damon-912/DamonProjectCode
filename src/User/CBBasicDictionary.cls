/// 基础字典表
Class User.CBBasicDictionary Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_BasicDictionary ]
{

Parameter %JSONREFERENCE = "ID";

Relationship ChildBD As CBBasicDictionarySub [ Cardinality = children, Inverse = BDParRef ];

/// 代码
Property Code As %String(COLLATION = "UPPER") [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

/// 描述(用途)
Property Descripts As %String [ Required, SqlColumnNumber = 4, SqlFieldName = Descripts ];

/// 产品分类
Property ProductCatDr As User.CBProductCat [ Required, SqlColumnNumber = 5, SqlFieldName = ProductCat_Dr ];

/// 产品模块
Property ProductModuleDr As User.CBProductModule [ Required, SqlColumnNumber = 6, SqlFieldName = ProductModule_Dr ];

/// 禁用 Y/N
Property Status As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 7, SqlFieldName = Status ];

/// 更新日期 
Property UpdateDate As %Date [ SqlColumnNumber = 8, SqlFieldName = UpdateDate ];

/// 更新时间 
Property UpdateTime As %Time [ SqlColumnNumber = 9, SqlFieldName = UpdateTime ];

/// 更新人员 
Property UpdateUserDr As HBUser [ SqlColumnNumber = 10, SqlFieldName = UpdateUser_Dr ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 11, SqlFieldName = ENDesc ];

Index Code On Code [ Unique ];

Storage Default
{
<Data name="CBBasicDictionaryDefaultData">
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
<Value>ProductCatDr</Value>
</Value>
<Value name="5">
<Value>ProductModuleDr</Value>
</Value>
<Value name="6">
<Value>Status</Value>
</Value>
<Value name="7">
<Value>UpdateDate</Value>
</Value>
<Value name="8">
<Value>UpdateTime</Value>
</Value>
<Value name="9">
<Value>UpdateUserDr</Value>
</Value>
<Value name="10">
<Value>ENDesc</Value>
</Value>
</Data>
<DataLocation>^CBBasicDictionaryD</DataLocation>
<DefaultData>CBBasicDictionaryDefaultData</DefaultData>
<IdLocation>^CBBasicDictionaryD</IdLocation>
<IndexLocation>^CBBasicDictionaryI</IndexLocation>
<StreamLocation>^CBBasicDictionaryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
