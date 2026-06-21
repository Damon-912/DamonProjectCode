Class User.BSHISSyncLog Extends (src.util.DynamicObject.Adapter, %Persistent, %XML.Adapter)
{
ClassType = persistent;
Inheritance = right;
Not ProcedureBlock;
SqlRowIdName = ID;
SqlTableName = BS_HIS_SyncLog;

/// 逻辑删除标记
/// 0: 正常
/// 1: 已删除
Property Deleted As %Integer [ InitialExpression = 0, Required ];

/// 删除日期
Property DeleteDate As %Date;

/// 删除时间
Property DeleteTime As %Time;

/// 任务名称
Property TaskName As %String(MAXLEN = 100);

/// 同步类型（incremental/full/manual）
Property SyncType As %String(MAXLEN = 20);

/// 开始时间
Property StartTime As %TimeStamp;

/// 结束时间
Property EndTime As %TimeStamp;

/// 状态码
/// success: 成功
/// failed: 失败
/// partial: 部分成功
Property StatusCode As %String(MAXLEN = 20);

/// 总记录数
Property TotalCount As %Integer;

/// 成功记录数
Property SuccessCount As %Integer;

/// 失败记录数
Property FailedCount As %Integer;

/// 错误信息
Property ErrorMessage As %String(MAXLEN = 2000);

/// 创建日期
Property CreateDate As %Date [ InitialExpression = {$zdateh($h, 5)} ];

/// 创建时间
Property CreateTime As %Time [ InitialExpression = {$ztimeh($h, 3)} ];

/// 主键索引
Index IDIndex On ID As Exact [ PrimaryKey ];

/// 创建日期索引
Index CreateDateIndex On CreateDate As Exact;

/// 同步类型索引
Index SyncTypeIndex On SyncType As Exact;

/// 状态码索引
Index StatusCodeIndex On StatusCode As Exact;

}
