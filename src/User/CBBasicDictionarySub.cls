/// 基础字典明细表
Class User.CBBasicDictionarySub Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_BasicDictionarySub ]
{

Parameter %JSONREFERENCE = "ID";

Relationship BDParRef As CBBasicDictionary [ Cardinality = parent, Inverse = ChildBD, Required, SqlFieldName = BD_ParRef ];

/// 代码
Property Code As %String(COLLATION = "UPPER") [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

/// 描述
Property Descripts As %String [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

/// 禁用 Y/N
Property Status As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 4, SqlFieldName = Status ];

/// 更新日期 
Property UpdateDate As %Date [ SqlColumnNumber = 5, SqlFieldName = UpdateDate ];

/// 更新时间 
Property UpdateTime As %Time [ SqlColumnNumber = 6, SqlFieldName = UpdateTime ];

/// 更新人员 
Property UpdateUserDr As HBUser [ SqlColumnNumber = 7, SqlFieldName = UpdateUser_Dr ];

/// 默认值 
Property DefaultValue As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ SqlColumnNumber = 8, SqlFieldName = DefaultValue ];

/// 序号 
Property SeqNo As %Integer [ SqlColumnNumber = 9, SqlFieldName = SeqNo ];

/// 属性值 
Property Value As %String(MAXLEN = 1000) [ SqlColumnNumber = 10, SqlFieldName = Value ];

Index ParRefCode On (BDParRef, Code) [ Unique ];

Index Code On Code;

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 11, SqlFieldName = ENDesc ];

Storage Default
{
<Data name="CBBasicDictionarySubDefaultData">
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
<Value>Status</Value>
</Value>
<Value name="5">
<Value>UpdateDate</Value>
</Value>
<Value name="6">
<Value>UpdateTime</Value>
</Value>
<Value name="7">
<Value>UpdateUserDr</Value>
</Value>
<Value name="8">
<Value>DefaultValue</Value>
</Value>
<Value name="9">
<Value>SeqNo</Value>
</Value>
<Value name="10">
<Value>Value</Value>
</Value>
<Value name="11">
<Value>ENDesc</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("S")</DataLocation>
<DefaultData>CBBasicDictionarySubDefaultData</DefaultData>
<IdLocation>^CBBasicDictionaryC("S")</IdLocation>
<IndexLocation>^CBBasicDictionarySubI</IndexLocation>
<StreamLocation>^CBBasicDictionarySubS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
