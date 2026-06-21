Class User.BSHISDiseInfo Extends (src.util.DynamicObject.Adapter, %Persistent, %XML.Adaptor)
{
ClassType = persistent;
Inheritance = right;
Not ProcedureBlock;
SqlRowIdName = ID;
SqlTableName = BS_HIS_DiseInfo;

/// 逻辑删除标记
/// 0: 正常
/// 1: 已删除
Property Deleted As %Integer [ InitialExpression = 0, Required ];

/// 删除日期
Property DeleteDate As %Date;

/// 删除时间
Property DeleteTime As %Time;

/// HIS就诊ID（外键→User.BSHISPatAdm，联合主键）
Property AdmDr As User.BSHISPatAdm [ Required ];

/// 诊断序号（联合主键，数组中的第几条）
Property DiseSn As %Integer [ Required ];

/// 诊断编码
Property DiseCode As %String(MAXLEN = 50);

/// 诊断名称
Property DiseName As %String(MAXLEN = 200);

/// 主诊断标志
/// Y: 主诊断
/// N: 其他诊断
Property MainFlag As %String(MAXLEN = 10);

/// 诊断类型
Property DiseType As %String(MAXLEN = 50);

/// 创建日期
Property CreateDate As %Date [ InitialExpression = {$zdateh($h, 5)} ];

/// 创建时间
Property CreateTime As %Time [ InitialExpression = {$ztimeh($h, 3)} ];

/// 主键索引
Index PKIndex On (AdmDr, DiseSn) As Exact [ PrimaryKey ];

}
