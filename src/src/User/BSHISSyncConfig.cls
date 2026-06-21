Class User.BSHISSyncConfig Extends (%Persistent, %XML.Adaptor)
{
ClassType = persistent;
Inheritance = right;
Not ProcedureBlock;
SqlRowIdName = ID;
SqlTableName = BS_HIS_SyncConfig;

/// 主键ID
Property ID As %String(MAXLEN = 50) [ Required ];

/// 医院代码（关联CB_Hospital.Code）
Property HospCode As %String(MAXLEN = 50) [ Required ];

/// 同步类型：incremental/full
Property SyncType As %String(MAXLEN = 20) [ Required ];

/// 频率：manual/hourly/daily/weekly
Property Frequency As %String(MAXLEN = 20) [ Required ];

/// 定时时间
Property ScheduledTime As %String(MAXLEN = 50);

/// 增量同步回溯天数
Property LookbackDays As %Integer [ InitialExpression = 3 ];

/// 是否启用
Property Enabled As %Boolean [ InitialExpression = 0 ];

/// 最后同步时间
Property LastSyncTime As %TimeStamp;

/// 状态：idle/running/error
Property Status As %String(MAXLEN = 20) [ InitialExpression = "idle" ];

/// 错误信息
Property ErrorMessage As %String(MAXLEN = 2000);

/// 创建用户
Property CreateUserDr As %String(MAXLEN = 50);

/// 创建日期
Property CreateDate As %Date [ InitialExpression = {$zdateh($horolog, 5)} ];

/// 创建时间
Property CreateTime As %Time [ InitialExpression = {$ztimeh($horolog, 3)} ];

/// 更新用户
Property UpdateUserDr As %String(MAXLEN = 50);

/// 更新日期
Property UpdateDate As %Date;

/// 更新时间
Property UpdateTime As %Time;

/// 医院代码索引
Index HospCodeIndex On HospCode As Exact;

/// 启用状态索引
Index EnabledIndex On Enabled As Exact;

/// 状态索引
Index StatusIndex On Status As Exact;

}
