/// HIS数据同步日志表
Class User.BSHISSyncLog Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_HISSyncLog ]
{

Parameter %JSONREFERENCE = "ID";

/// 逻辑删除标记 0:正常 1:已删除
Property Deleted As %Integer [ InitialExpression = 0, Required, SqlColumnNumber = 2, SqlFieldName = Deleted ];

/// 删除日期
Property DeleteDate As %Date [ SqlColumnNumber = 3, SqlFieldName = DeleteDate ];

/// 删除时间
Property DeleteTime As %Time [ SqlColumnNumber = 4, SqlFieldName = DeleteTime ];

/// 任务名称
Property TaskName As %String(MAXLEN = 100) [ SqlColumnNumber = 5, SqlFieldName = TaskName ];

/// 同步类型（incremental/full/manual）
Property SyncType As %String(MAXLEN = 20) [ SqlColumnNumber = 6, SqlFieldName = SyncType ];

/// 开始时间
Property StartTime As %TimeStamp [ SqlColumnNumber = 7, SqlFieldName = StartTime ];

/// 结束时间
Property EndTime As %TimeStamp [ SqlColumnNumber = 8, SqlFieldName = EndTime ];

/// 状态码 success:成功 failed:失败 partial:部分成功
Property StatusCode As %String(MAXLEN = 20) [ SqlColumnNumber = 9, SqlFieldName = StatusCode ];

/// 总记录数
Property TotalCount As %Integer [ SqlColumnNumber = 10, SqlFieldName = TotalCount ];

/// 成功记录数
Property SuccessCount As %Integer [ SqlColumnNumber = 11, SqlFieldName = SuccessCount ];

/// 失败记录数
Property FailedCount As %Integer [ SqlColumnNumber = 12, SqlFieldName = FailedCount ];

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

/// 创建日期索引
Index CreateDateIndex On CreateDate;

/// 同步类型索引
Index SyncTypeIndex On SyncType;

/// 状态码索引
Index StatusCodeIndex On StatusCode;

Storage Default
{
<Data name="BSHISSyncLogDefaultData">
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
<Value>TaskName</Value>
</Value>
<Value name="6">
<Value>SyncType</Value>
</Value>
<Value name="7">
<Value>StartTime</Value>
</Value>
<Value name="8">
<Value>EndTime</Value>
</Value>
<Value name="9">
<Value>StatusCode</Value>
</Value>
<Value name="10">
<Value>TotalCount</Value>
</Value>
<Value name="11">
<Value>SuccessCount</Value>
</Value>
<Value name="12">
<Value>FailedCount</Value>
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
</Data>
<DataLocation>^BSHISSyncLogD</DataLocation>
<DefaultData>BSHISSyncLogDefaultData</DefaultData>
<IdLocation>^BSHISSyncLogD</IdLocation>
<IndexLocation>^BSHISSyncLogI</IndexLocation>
<StreamLocation>^BSHISSyncLogS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
