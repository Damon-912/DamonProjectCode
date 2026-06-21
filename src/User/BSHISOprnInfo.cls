/// HIS患者手术信息表
Class User.BSHISOprnInfo Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_HISOprnInfo ]
{

Parameter %JSONREFERENCE = "ID";

/// 逻辑删除标记 0:正常 1:已删除
Property Deleted As %Integer [ InitialExpression = 0, Required, SqlColumnNumber = 2, SqlFieldName = Deleted ];

/// 删除日期
Property DeleteDate As %Date [ SqlColumnNumber = 3, SqlFieldName = DeleteDate ];

/// 删除时间
Property DeleteTime As %Time [ SqlColumnNumber = 4, SqlFieldName = DeleteTime ];

/// HIS就诊ID（外键→User.BSHISPatAdm）
Property AdmDr As User.BSHISPatAdm [ Required, SqlColumnNumber = 5, SqlFieldName = Adm_Dr ];

/// 手术序号（联合主键）
Property OprnSn As %Integer [ Required, SqlColumnNumber = 6, SqlFieldName = OprnSn ];

/// 主手术标志
Property MainFlag As %String(MAXLEN = 10) [ SqlColumnNumber = 7, SqlFieldName = MainFlag ];

/// 手术编码
Property OprnCode As %String(MAXLEN = 50) [ SqlColumnNumber = 8, SqlFieldName = OprnCode ];

/// 手术名称
Property OprnName As %String(MAXLEN = 200) [ SqlColumnNumber = 9, SqlFieldName = OprnName ];

/// 手术日期
Property OprnDate As %String(MAXLEN = 20) [ SqlColumnNumber = 10, SqlFieldName = OprnDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 11, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 12, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As User.HBUser [ Required, SqlColumnNumber = 13, SqlFieldName = CreateUser_Dr ];

/// 更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 14, SqlFieldName = UpdateDate ];

/// 更新时间
Property UpdateTime As %Time [ SqlColumnNumber = 15, SqlFieldName = UpdateTime ];

/// 主键索引
Index PKIndex On (AdmDr, OprnSn) [ PrimaryKey ];

/// 外键索引
Index AdmDrIndex On AdmDr;

Storage Default
{
<Data name="BSHISOprnInfoDefaultData">
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
<Value>OprnSn</Value>
</Value>
<Value name="7">
<Value>MainFlag</Value>
</Value>
<Value name="8">
<Value>OprnCode</Value>
</Value>
<Value name="9">
<Value>OprnName</Value>
</Value>
<Value name="10">
<Value>OprnDate</Value>
</Value>
<Value name="11">
<Value>CreateDate</Value>
</Value>
<Value name="12">
<Value>CreateTime</Value>
</Value>
<Value name="13">
<Value>CreateUserDr</Value>
</Value>
<Value name="14">
<Value>UpdateDate</Value>
</Value>
<Value name="15">
<Value>UpdateTime</Value>
</Value>
</Data>
<DataLocation>^BSHISOprnInfoD</DataLocation>
<DefaultData>BSHISOprnInfoDefaultData</DefaultData>
<IdLocation>^BSHISOprnInfoD</IdLocation>
<IndexLocation>^BSHISOprnInfoI</IndexLocation>
<StreamLocation>^BSHISOprnInfoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
