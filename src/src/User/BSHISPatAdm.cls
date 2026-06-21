Class User.BSHISPatAdm Extends (src.util.DynamicObject.Adapter, %Persistent, %XML.Adaptor)
{
ClassType = persistent;
Inheritance = right;
Not ProcedureBlock;
SqlRowIdName = ID;
SqlTableName = BS_HIS_PatAdm;

/// 逻辑删除标记
/// 0: 正常
/// 1: 已删除
Property Deleted As %Integer [ InitialExpression = 0, Required ];

/// 删除日期
Property DeleteDate As %Date;

/// 删除时间
Property DeleteTime As %Time;

/// HIS就诊ID（主键，来自HIS接口admID）
Property AdmID As %String(MAXLEN = 100) [ Required ];

/// HIS患者ID（来自HIS接口patID）
Property PatID As %String(MAXLEN = 100) [ Required ];

/// 患者姓名
Property PatName As %String(MAXLEN = 100);

/// 性别编码
Property PatSexCode As %String(MAXLEN = 10);

/// 性别描述
Property PatSexDesc As %String(MAXLEN = 20);

/// 住院号
Property PatNo As %String(MAXLEN = 50);

/// 病案号
Property PatMedicalNo As %String(MAXLEN = 50);

/// 主治医师描述
Property AdmDocDesc As %String(MAXLEN = 50);

/// 责任护士描述
Property AdmNurDesc As %String(MAXLEN = 50);

/// 入院时间
Property AdmDateTime As %TimeStamp;

/// 入院天数
Property AdmInDays As %Integer;

/// 入院诊断
Property AdmDiag As %String(MAXLEN = 500);

/// 入院科室描述
Property InLocDesc As %String(MAXLEN = 100);

/// 入院病区描述
Property InWardDesc As %String(MAXLEN = 100);

/// 医疗机构代码
Property FixmedinsCode As %String(MAXLEN = 50);

/// 医疗机构名称
Property FixmedinsName As %String(MAXLEN = 200);

/// 创建日期
Property CreateDate As %Date [ InitialExpression = {$zdateh($horolog, 5)} ];

/// 创建时间
Property CreateTime As %Time [ InitialExpression = {$ztimeh($horolog, 3)} ];

/// 更新日期
Property UpdateDate As %Date;

/// 更新时间
Property UpdateTime As %Time;

/// 主键索引
Index AdmIDIndex On AdmID As Exact [ PrimaryKey ];

/// 病案号索引
Index PatMedicalNoIndex On PatMedicalNo As Exact;

/// 入院时间索引
Index AdmDateTimeIndex On AdmDateTime As Exact;

/// 删除标记索引
Index DeletedIndex On Deleted As Exact;

}
