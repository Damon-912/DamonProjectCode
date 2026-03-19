/// 接口服务类
Class User.CBMapInterface Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_MapInterface ]
{

Parameter %JSONREFERENCE = "ID";

/// 代码
Property Code As %String(COLLATION = "UPPER", MAXLEN = 8) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts;

/// 类名
Property ClassName As %String(COLLATION = "UPPER", MAXLEN = 100) [ Required, SqlColumnNumber = 4, SqlFieldName = ClassName ];

/// 方法名
Property MethodName As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 5, SqlFieldName = MethodName ];

Index Method On (ClassName, MethodName) [ Unique ];

/// 生效日期
Property StartDate As %Date [ SqlColumnNumber = 6, SqlFieldName = StartDate ];

/// 失效日期
Property StopDate As %Date [ SqlColumnNumber = 7, SqlFieldName = StopDate ];

/// 服务类型
Property ServiceType As %String(DISPLAYLIST = ",Search,Add,Update,Delete", TRUNCATE = 1, VALUELIST = ",S,A,U,D") [ Required, SqlColumnNumber = 8, SqlFieldName = ServiceType ];

/// 产品分类
Property ProductCatDr As User.CBProductCat [ SqlColumnNumber = 9, SqlFieldName = ProductCat_Dr ];

/// 产品模块
Property ProductModuleDr As User.CBProductModule [ SqlColumnNumber = 10, SqlFieldName = ProductModule_Dr ];

/// 序号
Property SeqNo As %String(COLLATION = "UPPER", MAXLEN = 4) [ SqlColumnNumber = 11, SqlFieldName = SeqNo ];

/// 服务器地址
Property ServiceIP As %String(COLLATION = "UPPER", MAXLEN = 30) [ SqlColumnNumber = 12, SqlFieldName = ServiceIP ];

/// 是否验证session
Property SessionFlag As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 13, SqlFieldName = SessionFlag ];

/// 是否验证token
Property TokenFlag As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 14, SqlFieldName = TokenFlag ];

/// token 超时时间 单位分钟
Property TokenOverTime As %String(COLLATION = "UPPER", MAXLEN = 5) [ SqlColumnNumber = 15, SqlFieldName = TokenOverTime ];

/// 读写类型
Property RWServiceTypeDr As User.CBSysServiceType [ SqlColumnNumber = 16, SqlFieldName = RWServiceType_Dr ];

Storage Default
{
<Data name="CBMapInterfaceDefaultData">
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
<Value>ClassName</Value>
</Value>
<Value name="5">
<Value>MethodName</Value>
</Value>
<Value name="6">
<Value>StartDate</Value>
</Value>
<Value name="7">
<Value>StopDate</Value>
</Value>
<Value name="8">
<Value>ServiceType</Value>
</Value>
<Value name="9">
<Value>ProductCatDr</Value>
</Value>
<Value name="10">
<Value>ProductModuleDr</Value>
</Value>
<Value name="11">
<Value>SeqNo</Value>
</Value>
<Value name="12">
<Value>ServiceIP</Value>
</Value>
<Value name="13">
<Value>SessionFlag</Value>
</Value>
<Value name="14">
<Value>TokenFlag</Value>
</Value>
<Value name="15">
<Value>TokenOverTime</Value>
</Value>
<Value name="16">
<Value>RWServiceTypeDr</Value>
</Value>
</Data>
<DataLocation>^CBMapInterfaceD</DataLocation>
<DefaultData>CBMapInterfaceDefaultData</DefaultData>
<IdLocation>^CBMapInterfaceD</IdLocation>
<IndexLocation>^CBMapInterfaceI</IndexLocation>
<StreamLocation>^CBMapInterfaceS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
