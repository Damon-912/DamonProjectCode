Class User.BSHISDRGParams Extends (src.util.DynamicObject.Adapter, %Persistent, %XML.Adaptor)
{
ClassType = persistent;
Inheritance = right;
Not ProcedureBlock;
SqlRowIdName = ID;
SqlTableName = BS_HIS_DRGParams;

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

/// 医保个人编号
Property PsnNo As %String(MAXLEN = 50);

/// 医保统筹区代码
Property InsuranceAreaCode As %String(MAXLEN = 20);

/// 医保就诊地区代码
Property MdtrtareaAreaCode As %String(MAXLEN = 20);

/// 医保类型
Property InsuType As %String(MAXLEN = 20);

/// 诊断编码
Property DiagnosisCode As %String(MAXLEN = 50);

/// 诊断名称
Property DiagnosisName As %String(MAXLEN = 100);

/// 分组阶段
Property GroupStage As %Integer;

/// 诊断类型编码
Property DiaTypeCode As %String(MAXLEN = 20);

/// 联合手术标志
Property UnionOprnFlag As %Integer;

/// 主诊断编码
Property MainDiagnosisCode As %String(MAXLEN = 50);

/// 主手术编码
Property MainOperationCode As %String(MAXLEN = 50);

/// 性别
Property Sex As %String(MAXLEN = 10);

/// 年龄
Property Age As %Integer;

/// 年龄组天数
Property AgeGroupDays As %String(MAXLEN = 20);

/// 新生儿标志
Property NewbornFlag As %String(MAXLEN = 10);

/// 呼吸机时间
Property RespiratorTime As %String(MAXLEN = 20);

/// ECMO标志
Property EcmoFlag As %String(MAXLEN = 10);

/// 移植标志
Property TransplantFlag As %String(MAXLEN = 10);

/// 骨髓移植标志
Property MarrowTransplantFlag As %String(MAXLEN = 10);

/// HIV标志
Property HivFlag As %String(MAXLEN = 10);

/// 创伤等级
Property TraumaLevel As %String(MAXLEN = 20);

/// 科室
Property Department As %String(MAXLEN = 50);

/// 科室描述
Property DepartmentDesc As %String(MAXLEN = 100);

/// 出院类型
Property DischargeType As %String(MAXLEN = 20);

/// 住院天数
Property HospitalDays As %Integer;

/// 总费用
Property TotalCost As %Numeric;

/// 病案号
Property MedicalRecordID As %String(MAXLEN = 50);

/// HIS就诊ID（字符串副本）
Property HisAdmId As %String(MAXLEN = 50);

/// 患者姓名
Property PatientName As %String(MAXLEN = 100);

/// 科室编码
Property DeptCode As %String(MAXLEN = 50);

/// 科室名称
Property DeptName As %String(MAXLEN = 100);

/// 医生编码
Property DoctorCode As %String(MAXLEN = 50);

/// 医生姓名
Property DoctorName As %String(MAXLEN = 100);

/// 总费用（副本）
Property TotalFee As %Numeric;

/// 病案号（副本）
Property MedicalRecordDr As %String(MAXLEN = 50);

/// 医保定点机构编码
Property FixmedinsCode As %String(MAXLEN = 50);

/// 医保定点机构名称
Property FixmedinsName As %String(MAXLEN = 100);

/// DRG参数状态
/// 0: 成功
/// 1: HIS返回错误
Property DrgParamsStatus As %String(MAXLEN = 10) [ InitialExpression = "0" ];

/// 创建日期
Property CreateDate As %Date [ InitialExpression = {$zdateh($h, 5)} ];

/// 创建时间
Property CreateTime As %Time [ InitialExpression = {$ztimeh($h, 3)} ];

/// 主键索引
Index AdmDrIndex On AdmDr As Exact [ PrimaryKey ];

}
