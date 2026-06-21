/// HIS数据同步配置表
Class User.BSHISSyncConfig Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_HISSyncConfig ]
{

Parameter %JSONREFERENCE = "ID";

/// 逻辑删除标记 0:正常 1:已删除
Property Deleted As %Integer [ InitialExpression = 0, Required, SqlColumnNumber = 2, SqlFieldName = Deleted ];

/// 删除日期
Property DeleteDate As %Date [ SqlColumnNumber = 3, SqlFieldName = DeleteDate ];

/// 删除时间
Property DeleteTime As %Time [ SqlColumnNumber = 4, SqlFieldName = DeleteTime ];

/// 医院代码（关联CB_Hospital.Code）
Property HospCode As %String(MAXLEN = 50) [ Required, SqlColumnNumber = 5, SqlFieldName = HospCode ];

/// 同步类型：incremental/full
Property SyncType As %String(MAXLEN = 20) [ Required, SqlColumnNumber = 6, SqlFieldName = SyncType ];

/// 频率：manual/hourly/daily/weekly
Property Frequency As %String(MAXLEN = 20) [ Required, SqlColumnNumber = 7, SqlFieldName = Frequency ];

/// 定时时间
Property ScheduledTime As %String(MAXLEN = 50) [ SqlColumnNumber = 8, SqlFieldName = ScheduledTime ];

/// 增量同步回溯天数
Property LookbackDays As %Integer [ InitialExpression = 3, SqlColumnNumber = 9, SqlFieldName = LookbackDays ];

/// 是否启用
Property Enabled As %Boolean [ InitialExpression = 0, SqlColumnNumber = 10, SqlFieldName = Enabled ];

/// 最后同步时间
Property LastSyncTime As %TimeStamp [ SqlColumnNumber = 11, SqlFieldName = LastSyncTime ];

/// 状态：idle/running/error
Property Status As %String(MAXLEN = 20) [ InitialExpression = "idle", SqlColumnNumber = 12, SqlFieldName = Status ];

/// 错误信息
Property ErrorMessage As %String(MAXLEN = 2000) [ SqlColumnNumber = 13, SqlFieldName = ErrorMessage ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 14, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 15, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As User.HBUser [ Required, SqlColumnNumber = 16, SqlFieldName = CreateUser_Dr ];

/// 更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 17, SqlFieldName = UpdateDate ];

/// 更新时间
Property UpdateTime As %Time [ SqlColumnNumber = 18, SqlFieldName = UpdateTime ];

/// 更新用户ID 指向HB_User表
Property UpdateUserDr As User.HBUser [ SqlColumnNumber = 19, SqlFieldName = UpdateUser_Dr ];

/// 医院代码索引
Index HospCodeIndex On HospCode As Exact;

/// 启用状态索引
Index EnabledIndex On Enabled As Exact;

/// 状态索引
Index StatusIndex On Status As Exact;

Storage Default
{
<Data name="BSHISSyncConfigDefaultData">
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
<Value>HospCode</Value>
</Value>
<Value name="6">
<Value>SyncType</Value>
</Value>
<Value name="7">
<Value>Frequency</Value>
</Value>
<Value name="8">
<Value>ScheduledTime</Value>
</Value>
<Value name="9">
<Value>LookbackDays</Value>
</Value>
<Value name="10">
<Value>Enabled</Value>
</Value>
<Value name="11">
<Value>LastSyncTime</Value>
</Value>
<Value name="12">
<Value>Status</Value>
</Value>
<Value name="13">
<Value>ErrorMessage</Value>
</Value>
<Value name="14">
<Value>CreateDate</Value>
</Value>
<Value name="15">
<Value>CreateTime</Value>
</Value>
<Value name="16">
<Value>CreateUserDr</Value>
</Value>
<Value name="17">
<Value>UpdateDate</Value>
</Value>
<Value name="18">
<Value>UpdateTime</Value>
</Value>
<Value name="19">
<Value>UpdateUserDr</Value>
</Value>
</Data>
<DataLocation>^BSHISSyncConfigD</DataLocation>
<DefaultData>BSHISSyncConfigDefaultData</DefaultData>
<IdLocation>^BSHISSyncConfigD</IdLocation>
<IndexLocation>^BSHISSyncConfigI</IndexLocation>
<StreamLocation>^BSHISSyncConfigS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
