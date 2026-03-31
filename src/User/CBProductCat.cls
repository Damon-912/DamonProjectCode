/// 产品分类
Class User.CBProductCat Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_ProductCat ]
{

Parameter %JSONREFERENCE = "ID";

/// 序号 此序号反映了项目的排列次序
Property SeqNo As %Integer [ SqlColumnNumber = 2, SqlFieldName = SeqNo ];

Index SeqNo On SeqNo;

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 5, SqlFieldName = ENDesc ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 6, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 7, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBProductCatDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SeqNo</Value>
</Value>
<Value name="3">
<Value>Code</Value>
</Value>
<Value name="4">
<Value>Descripts</Value>
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
<DataLocation>^CBProductCatD</DataLocation>
<DefaultData>CBProductCatDefaultData</DefaultData>
<IdLocation>^CBProductCatD</IdLocation>
<IndexLocation>^CBProductCatI</IndexLocation>
<StreamLocation>^CBProductCatS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
