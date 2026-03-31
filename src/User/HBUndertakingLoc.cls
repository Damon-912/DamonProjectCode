/// 承接部门
Class User.HBUndertakingLoc Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_UndertakingLoc ]
{

Parameter %JSONREFERENCE = "ID";

/// 医院ID 指向医院表CB_Hospital  空为公共
Property HospitalDr As CBHospital [ SqlColumnNumber = 2, SqlFieldName = Hospital_Dr ];

Index HospID On HospitalDr;

/// 代码 
Property Code As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = Code ];

Index Code On Code [ Unique ];

/// 描述 非空
Property Descripts As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = Descripts ];

Index Desc On Descripts [ Unique ];

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 5, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 6, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 7, SqlFieldName = CreateDate ];

/// 创建时间 指向用户表 HB_User
Property CreateTime As %Time [ Required, SqlColumnNumber = 8, SqlFieldName = CreateTime ];

/// 创建人员ID 与USER表里的ID相同
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 9, SqlFieldName = CreateUser_Dr ];

/// 更新日期 
Property UpdateDate As %Date [ SqlColumnNumber = 10, SqlFieldName = UpdateDate ];

/// 更新时间 
Property UpdateTime As %Time [ SqlColumnNumber = 11, SqlFieldName = UpdateTime ];

/// 更新人员 指向人员表
Property UpdateUserDr As HBUser [ SqlColumnNumber = 12, SqlFieldName = UpdateUser_Dr ];

Storage Default
{
<Data name="HBUndertakingLocDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>HospitalDr</Value>
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
<Value>UpdateDate</Value>
</Value>
<Value name="11">
<Value>UpdateTime</Value>
</Value>
<Value name="12">
<Value>UpdateUserDr</Value>
</Value>
</Data>
<DataLocation>^HBUndertakingLocD</DataLocation>
<DefaultData>HBUndertakingLocDefaultData</DefaultData>
<IdLocation>^HBUndertakingLocD</IdLocation>
<IndexLocation>^HBUndertakingLocI</IndexLocation>
<StreamLocation>^HBUndertakingLocS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
