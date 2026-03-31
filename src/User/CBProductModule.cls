/// 产品模块
Class User.CBProductModule Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_ProductModule ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 描述 非空
Property ProductCatDr As CBProductCat [ Required, SqlColumnNumber = 4, SqlFieldName = ProductCat_Dr ];

Index ProductCat On ProductCatDr;

Index CatCode On (ProductCatDr, Code) [ Unique ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ SqlColumnNumber = 5, SqlFieldName = ENDesc ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 6, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 7, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBProductModuleDefaultData">
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
<Value>ENDesc</Value>
</Value>
<Value name="6">
<Value>CreateDate</Value>
</Value>
<Value name="7">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>^CBProductModuleD</DataLocation>
<DefaultData>CBProductModuleDefaultData</DefaultData>
<IdLocation>^CBProductModuleD</IdLocation>
<IndexLocation>^CBProductModuleI</IndexLocation>
<StreamLocation>^CBProductModuleS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
