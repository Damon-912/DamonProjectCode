/// HIS患者诊断信息表
Class User.BSHISDiseInfo Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_HISDiseInfo ]
{

Parameter %JSONREFERENCE = "ID";

/// 逻辑删除标记 0:正常 1:已删除
Property Deleted As %Integer [ InitialExpression = 0, Required, SqlColumnNumber = 2, SqlFieldName = Deleted ];

/// 删除日期
Property DeleteDate As %Date [ SqlColumnNumber = 3, SqlFieldName = DeleteDate ];

/// 删除时间
Property DeleteTime As %Time [ SqlColumnNumber = 4, SqlFieldName = DeleteTime ];

/// HIS就诊ID外键（指向BSHISPatAdm.AdmID）
Property AdmDr As User.BSHISPatAdm [ Required, SqlColumnNumber = 5, SqlFieldName = Adm_Dr ];

/// 诊断序号（对应接口diagSn，从1开始）
Property DiagSn As %Integer [ Required, SqlColumnNumber = 6, SqlFieldName = DiagSn ];

/// 主诊断标志（对应接口mainFlag，1=主诊断，0=其他诊断）
Property MainFlag As %Integer [ InitialExpression = 0, SqlColumnNumber = 7, SqlFieldName = MainFlag ];

/// 诊断代码（对应接口diagCode）
Property DiagCode As %String(MAXLEN = 20) [ SqlColumnNumber = 8, SqlFieldName = DiagCode ];

/// 诊断名称（对应接口diagName）
Property DiagName As %String(MAXLEN = 100) [ SqlColumnNumber = 9, SqlFieldName = DiagName ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 10, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 11, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As User.HBUser [ Required, SqlColumnNumber = 12, SqlFieldName = CreateUser_Dr ];

/// 更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 13, SqlFieldName = UpdateDate ];

/// 更新时间
Property UpdateTime As %Time [ SqlColumnNumber = 14, SqlFieldName = UpdateTime ];

/// 索引：AdmDr + DiagSn（联合主键）
Index PKIndex On (AdmDr, DiagSn) [ PrimaryKey ];

/// 外键索引
Index AdmDrIndex On AdmDr;

Storage Default
{
<Data name="BSHISDiseInfoDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Deleted</Value>
</Value>
<Value name="3">
<Value>DeleteDate</Value>
</Value>
<Value name="4">
<Value>DeleteTime</Value>
</Value>
<Value name="5">
<Value>AdmDr</Value>
</Value>
<Value name="6">
<Value>DiagSn</Value>
</Value>
<Value name="7">
<Value>MainFlag</Value>
</Value>
<Value name="8">
<Value>DiagCode</Value>
</Value>
<Value name="9">
<Value>DiagName</Value>
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
</Data>
<DataLocation>^BSHISDiseInfoD</DataLocation>
<DefaultData>BSHISDiseInfoDefaultData</DefaultData>
<IdLocation>^BSHISDiseInfoD</IdLocation>
<IndexLocation>^BSHISDiseInfoI</IndexLocation>
<StreamLocation>^BSHISDiseInfoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
