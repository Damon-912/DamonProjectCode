/// 字典明细表
Class User.HBDictionariesDateDetailed Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_DictionariesDateDetail ]
{

Parameter %JSONREFERENCE = "ID";

/// 平台字典 指向HBDictionaries
Property HBDictionariesDr As HBDictionaries [ Required, SqlColumnNumber = 2, SqlFieldName = HBDictionaries_Dr ];

Index Dict On HBDictionariesDr;

/// 代码 非空
Property Code As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

Index Code On Code;

// [ Unique ]

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 30, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Descripts ];

Index Desc On Descripts;

/// 标识码-分类
Property Identification As %String(MAXLEN = 30) [ SqlColumnNumber = 5, SqlFieldName = Identification ];

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 6, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 7, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 8, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 9, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 10, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="HBDictionariesDateDetailedDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>HBDictionariesDr</Value>
</Value>
<Value name="3">
<Value>Code</Value>
</Value>
<Value name="4">
<Value>Descripts</Value>
</Value>
<Value name="5">
<Value>StartDate</Value>
</Value>
<Value name="6">
<Value>StopDate</Value>
</Value>
<Value name="7">
<Value>CreateDate</Value>
</Value>
<Value name="8">
<Value>CreateTime</Value>
</Value>
<Value name="9">
<Value>CreateUserDr</Value>
</Value>
<Value name="10">
<Value>Identification</Value>
</Value>
</Data>
<DataLocation>^HBDictionarF5E8D</DataLocation>
<DefaultData>HBDictionariesDateDetailedDefaultData</DefaultData>
<IdLocation>^HBDictionarF5E8D</IdLocation>
<IndexLocation>^HBDictionarF5E8I</IndexLocation>
<StreamLocation>^HBDictionarF5E8S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
