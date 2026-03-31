Class User.CBGroupLinkTableAuth Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_GroupLinkTableAuth ]
{

Parameter %JSONREFERENCE = "ID";

///  指向角色和表关联表
Relationship CBGTAParRef As CBGroupLinkTable [ Cardinality = parent, Inverse = ChildCBGroupLinkTableAuth, Required, SqlFieldName = CBGTA_ParRef ];

/// 权限
Property HosAuthTypeDr As CBHospGroupAuthType [ Required, SqlColumnNumber = 3, SqlFieldName = HosAuthType_Dr ];

/// 权限
Property OPAuthTypeDr As CBOperateAuthType [ Required, SqlColumnNumber = 4, SqlFieldName = OPAuthType_Dr ];

Index HosOPAuth On (CBGTAParRef, HosAuthTypeDr, OPAuthTypeDr) [ Unique ];

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 5, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 6, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 7, SqlFieldName = CreateDate ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 8, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBGroupLinkTableAuthDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>HosAuthTypeDr</Value>
</Value>
<Value name="3">
<Value>OPAuthTypeDr</Value>
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
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("A")</DataLocation>
<DefaultData>CBGroupLinkTableAuthDefaultData</DefaultData>
<IdLocation>^CBGroupLinkTableC("A")</IdLocation>
<IndexLocation>^CBGroupLinkTableAuthI</IndexLocation>
<StreamLocation>^CBGroupLinkTableAuthS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
