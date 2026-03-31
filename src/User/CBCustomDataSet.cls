/// 自定义数据集
Class User.CBCustomDataSet Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_CustomDataSet ]
{

Parameter %JSONREFERENCE = "ID";

/// 自定义数据集代码
Property Code As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 自定义数据集描述
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 100) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 接口服务
Property ServiceInterfaceDr As User.CBMapInterface [ Required, SqlColumnNumber = 4, SqlFieldName = ServiceInterface_Dr ];

Index SCode On ServiceInterfaceDr [ Unique ];

/// 是否返回多行
Property MultipleRows As %String(COLLATION = "UPPER", DISPLAYLIST = ",Yes,No", MAXLEN = 1, TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 5, SqlFieldName = MultipleRows ];

/// 使用类型(如 公共元素字段值 Element E 等等)
Property UseType As %String(COLLATION = "UPPER", DISPLAYLIST = ",Element", MAXLEN = 1, TRUNCATE = 1, VALUELIST = ",E") [ Required, SqlColumnNumber = 6, SqlFieldName = UseType ];

Storage Default
{
<Data name="CBCustomDataSetDefaultData">
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
<Value>ServiceInterfaceDr</Value>
</Value>
<Value name="5">
<Value>MultipleRows</Value>
</Value>
<Value name="6">
<Value>UseType</Value>
</Value>
</Data>
<DataLocation>^CBCustomDataSetD</DataLocation>
<DefaultData>CBCustomDataSetDefaultData</DefaultData>
<IdLocation>^CBCustomDataSetD</IdLocation>
<IndexLocation>^CBCustomDataSetI</IndexLocation>
<StreamLocation>^CBCustomDataSetS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
