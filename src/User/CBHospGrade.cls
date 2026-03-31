Class User.CBHospGrade Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_HospGrade ]
{

/// 代码 
Property Code As %String(COLLATION = "UPPER", MAXLEN = 4, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 初级   一级   二级  三级  特级, 与收费项标准价格相关联
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 4, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 5, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 6, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 7, SqlFieldName = CreateTime ];

/// 创建人员ID 指向用户表 HB_User
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 8, SqlFieldName = CreateUser_Dr ];

/// 英文描述 
Property ENDesc As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ SqlColumnNumber = 9, SqlFieldName = ENDesc ];

Storage Default
{
<Data name="CBHospGradeDefaultData">
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
<Value>StartDate</Value>
</Value>
<Value name="5">
<Value>StopDate</Value>
</Value>
<Value name="6">
<Value>CreateDate</Value>
</Value>
<Value name="7">
<Value>CreateTime</Value>
</Value>
<Value name="8">
<Value>CreateUserDr</Value>
</Value>
<Value name="9">
<Value>ENDesc</Value>
</Value>
</Data>
<DataLocation>^CBHospGradeD</DataLocation>
<DefaultData>CBHospGradeDefaultData</DefaultData>
<IdLocation>^CBHospGradeD</IdLocation>
<IndexLocation>^CBHospGradeI</IndexLocation>
<StreamLocation>^CBHospGradeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
