Class User.HBModuleConfig Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_ModuleConfig ]
{

Parameter %JSONREFERENCE = "ID";

/// 配置类型
Property ModuleConfigDr As HBModuleConfigType [ Required, SqlColumnNumber = 2, SqlFieldName = ModuleConfig_Dr ];

Index ModuleConfig On ModuleConfigDr [ Unique ];

/// 配置值
Property ConfigValues As %String(COLLATION = "UPPER", MAXLEN = 2000, TRUNCATE = 1) [ SqlColumnNumber = 3, SqlFieldName = ConfigValues ];

/// 更新日期
Property UpdateDate As %Date [ Required, SqlColumnNumber = 4, SqlFieldName = UpdateDate ];

/// 更新时间
Property UpdateTime As %Time [ Required, SqlColumnNumber = 5, SqlFieldName = UpdateTime ];

/// 更新人
Property UpdateUserDr As HBUser [ Required, SqlColumnNumber = 6, SqlFieldName = UpdateUser_Dr ];

Storage Default
{
<Data name="HBModuleConfigDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ModuleConfigDr</Value>
</Value>
<Value name="3">
<Value>ConfigValues</Value>
</Value>
<Value name="4">
<Value>UpdateDate</Value>
</Value>
<Value name="5">
<Value>UpdateTime</Value>
</Value>
<Value name="6">
<Value>UpdateUserDr</Value>
</Value>
</Data>
<DataLocation>^HBModuleConfigD</DataLocation>
<DefaultData>HBModuleConfigDefaultData</DefaultData>
<IdLocation>^HBModuleConfigD</IdLocation>
<IndexLocation>^HBModuleConfigI</IndexLocation>
<StreamLocation>^HBModuleConfigS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
