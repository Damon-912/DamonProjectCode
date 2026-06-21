Class User.BSHISOprnInfo Extends (src.util.DynamicObject.Adapter, %Persistent, %XML.Adaptor)
{
ClassType = persistent;
Inheritance = right;
Not ProcedureBlock;
SqlRowIdName = ID;
SqlTableName = BS_HIS_OprnInfo;

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

/// 手术序号（联合主键）
Property OprnSn As %Integer [ Required ];

/// 主手术标志
Property MainFlag As %String(MAXLEN = 10);

/// 手术编码
Property OprnCode As %String(MAXLEN = 50);

/// 手术名称
Property OprnName As %String(MAXLEN = 200);

/// 手术日期
Property OprnDate As %String(MAXLEN = 20);

/// 创建日期
Property CreateDate As %Date [ InitialExpression = {$zdateh($h, 5)} ];

/// 创建时间
Property CreateTime As %Time [ InitialExpression = {$ztimeh($h, 3)} ];

/// 主键索引
Index PKIndex On (AdmDr, OprnSn) As Exact [ PrimaryKey ];

}
