/// HIS连接配置表
Class User.CBHISConnectionConfig Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_HISConnectionConfig ]
{

Parameter %JSONREFERENCE = "ID";

/// 医院代码 非空
Property HospCode As %String(COLLATION = "UPPER", MAXLEN = 20, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = HospCode ];

Index HospCodeIdx On HospCode [ Unique ];

/// 医保机构代码 非空
Property FixmedinsCode As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = FixmedinsCode ];

/// 医保机构名称 非空
Property FixmedinsName As %String(COLLATION = "UPPER", MAXLEN = 100, TRUNCATE = 1) [ Required, SqlColumnNumber = 4, SqlFieldName = FixmedinsName ];

/// HIS服务器IP 非空
Property HisIP As %String(COLLATION = "UPPER", MAXLEN = 50, TRUNCATE = 1) [ Required, SqlColumnNumber = 5, SqlFieldName = HisIP ];

/// HIS服务器端口
Property HisPort As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ SqlColumnNumber = 6, SqlFieldName = HisPort ];

/// HIS服务URL 非空
Property HisURL As %String(COLLATION = "UPPER", MAXLEN = 200, TRUNCATE = 1) [ Required, SqlColumnNumber = 7, SqlFieldName = HisURL ];

/// 认证信息 非空
Property Authorization As %String(COLLATION = "UPPER", MAXLEN = 500, TRUNCATE = 1) [ Required, SqlColumnNumber = 8, SqlFieldName = Authorization ];

/// 使用状态 Y/N
Property Active As %String(DISPLAYLIST = ",Yes,No", TRUNCATE = 1, VALUELIST = ",Y,N") [ Required, SqlColumnNumber = 9, SqlFieldName = Active ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ SqlColumnNumber = 10, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ SqlColumnNumber = 11, SqlFieldName = CreateTime ];

/// 创建人员ID 指向用户表
Property CreateUserDr As HBUser [ SqlColumnNumber = 12, SqlFieldName = CreateUser_Dr ];

/// 更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 13, SqlFieldName = UpdateDate ];

/// 更新时间
Property UpdateTime As %Time [ SqlColumnNumber = 14, SqlFieldName = UpdateTime ];

/// 更新人员ID 指向用户表
Property UpdateUserDr As HBUser [ SqlColumnNumber = 15, SqlFieldName = UpdateUser_Dr ];

Storage Default
{
<Data name="CBHISConnectionConfigDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>HospCode</Value>
</Value>
<Value name="3">
<Value>FixmedinsCode</Value>
</Value>
<Value name="4">
<Value>FixmedinsName</Value>
</Value>
<Value name="5">
<Value>HisIP</Value>
</Value>
<Value name="6">
<Value>HisPort</Value>
</Value>
<Value name="7">
<Value>HisURL</Value>
</Value>
<Value name="8">
<Value>Authorization</Value>
</Value>
<Value name="9">
<Value>Active</Value>
</Value>
<Value name="10">
<Value>CreateDate</Value>
</Value>
<Value name="11">
<Value>CreateTime</Value>
</Value>
<Value name="12">
<Value>CreateUserDr</Value>
</Value>
<Value name="13">
<Value>UpdateDate</Value>
</Value>
<Value name="14">
<Value>UpdateTime</Value>
</Value>
<Value name="15">
<Value>UpdateUserDr</Value>
</Value>
</Data>
<DataLocation>^CBHISConnectionConfigD</DataLocation>
<DefaultData>CBHISConnectionConfigDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^CBHISConnectionConfigD</IdLocation>
<IndexLocation>^CBHISConnectionConfigI</IndexLocation>
<StreamLocation>^CBHISConnectionConfigS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
