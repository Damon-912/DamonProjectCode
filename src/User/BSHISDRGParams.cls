/// HIS DRG分组参数表
Class User.BSHISDRGParams Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_HISDRGParams ]
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

/// 医保个人编号
Property PsnNo As %String(MAXLEN = 50) [ SqlColumnNumber = 6, SqlFieldName = PsnNo ];

/// 医保统筹区代码
Property InsuranceAreaCode As %String(MAXLEN = 20) [ SqlColumnNumber = 7, SqlFieldName = InsuranceAreaCode ];

/// 医保就诊地区代码
Property MdtrtareaAreaCode As %String(MAXLEN = 20) [ SqlColumnNumber = 8, SqlFieldName = MdtrtareaAreaCode ];

/// 医保类型
Property InsuType As %String(MAXLEN = 20) [ SqlColumnNumber = 9, SqlFieldName = InsuType ];

/// 诊断编码
Property DiagnosisCode As %String(MAXLEN = 50) [ SqlColumnNumber = 10, SqlFieldName = DiagnosisCode ];

/// 诊断名称
Property DiagnosisName As %String(MAXLEN = 100) [ SqlColumnNumber = 11, SqlFieldName = DiagnosisName ];

/// 分组阶段
Property GroupStage As %Integer [ SqlColumnNumber = 12, SqlFieldName = GroupStage ];

/// 诊断类型编码
Property DiaTypeCode As %String(MAXLEN = 20) [ SqlColumnNumber = 13, SqlFieldName = DiaTypeCode ];

/// 联合手术标志
Property UnionOprnFlag As %Integer [ SqlColumnNumber = 14, SqlFieldName = UnionOprnFlag ];

/// 主诊断编码
Property MainDiagnosisCode As %String(MAXLEN = 50) [ SqlColumnNumber = 15, SqlFieldName = MainDiagnosisCode ];

/// 主手术编码
Property MainOperationCode As %String(MAXLEN = 50) [ SqlColumnNumber = 16, SqlFieldName = MainOperationCode ];

/// 性别
Property Sex As %String(MAXLEN = 10) [ SqlColumnNumber = 17, SqlFieldName = Sex ];

/// 年龄
Property Age As %Integer [ SqlColumnNumber = 18, SqlFieldName = Age ];

/// 年龄组天数
Property AgeGroupDays As %String(MAXLEN = 20) [ SqlColumnNumber = 19, SqlFieldName = AgeGroupDays ];

/// 新生儿标志
Property NewbornFlag As %String(MAXLEN = 10) [ SqlColumnNumber = 20, SqlFieldName = NewbornFlag ];

/// 呼吸机时间
Property RespiratorTime As %String(MAXLEN = 20) [ SqlColumnNumber = 21, SqlFieldName = RespiratorTime ];

/// ECMO标志
Property EcmoFlag As %String(MAXLEN = 10) [ SqlColumnNumber = 22, SqlFieldName = EcmoFlag ];

/// 移植标志
Property TransplantFlag As %String(MAXLEN = 10) [ SqlColumnNumber = 23, SqlFieldName = TransplantFlag ];

/// 骨髓移植标志
Property MarrowTransplantFlag As %String(MAXLEN = 10) [ SqlColumnNumber = 24, SqlFieldName = MarrowTransplantFlag ];

/// HIV标志
Property HivFlag As %String(MAXLEN = 10) [ SqlColumnNumber = 25, SqlFieldName = HivFlag ];

/// 创伤等级
Property TraumaLevel As %String(MAXLEN = 20) [ SqlColumnNumber = 26, SqlFieldName = TraumaLevel ];

/// 科室
Property Department As %String(MAXLEN = 50) [ SqlColumnNumber = 27, SqlFieldName = Department ];

/// 科室描述
Property DepartmentDesc As %String(MAXLEN = 100) [ SqlColumnNumber = 28, SqlFieldName = DepartmentDesc ];

/// 出院类型
Property DischargeType As %String(MAXLEN = 20) [ SqlColumnNumber = 29, SqlFieldName = DischargeType ];

/// 住院天数
Property HospitalDays As %Integer [ SqlColumnNumber = 30, SqlFieldName = HospitalDays ];

/// 总费用
Property TotalCost As %Numeric [ SqlColumnNumber = 31, SqlFieldName = TotalCost ];

/// 病案号
Property MedicalRecordID As %String(MAXLEN = 50) [ SqlColumnNumber = 32, SqlFieldName = MedicalRecordID ];

/// HIS就诊ID（字符串副本）
Property HisAdmId As %String(MAXLEN = 50) [ SqlColumnNumber = 33, SqlFieldName = HisAdmId ];

/// 患者姓名
Property PatientName As %String(MAXLEN = 100) [ SqlColumnNumber = 34, SqlFieldName = PatientName ];

/// 科室编码
Property DeptCode As %String(MAXLEN = 50) [ SqlColumnNumber = 35, SqlFieldName = DeptCode ];

/// 科室名称
Property DeptName As %String(MAXLEN = 100) [ SqlColumnNumber = 36, SqlFieldName = DeptName ];

/// 医生编码
Property DoctorCode As %String(MAXLEN = 50) [ SqlColumnNumber = 37, SqlFieldName = DoctorCode ];

/// 医生姓名
Property DoctorName As %String(MAXLEN = 100) [ SqlColumnNumber = 38, SqlFieldName = DoctorName ];

/// 总费用（副本）
Property TotalFee As %Numeric [ SqlColumnNumber = 39, SqlFieldName = TotalFee ];

/// 病案号（副本）
Property MedicalRecordDr As %String(MAXLEN = 50) [ SqlColumnNumber = 40, SqlFieldName = MedicalRecordDr ];

/// 医保定点机构编码
Property FixmedinsCode As %String(MAXLEN = 50) [ SqlColumnNumber = 41, SqlFieldName = FixmedinsCode ];

/// 医保定点机构名称
Property FixmedinsName As %String(MAXLEN = 100) [ SqlColumnNumber = 42, SqlFieldName = FixmedinsName ];

/// DRG参数状态 0:成功 1:HIS返回错误
Property DrgParamsStatus As %String(MAXLEN = 10) [ InitialExpression = "0", SqlColumnNumber = 43, SqlFieldName = DrgParamsStatus ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 44, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 45, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As User.HBUser [ Required, SqlColumnNumber = 46, SqlFieldName = CreateUser_Dr ];

/// 更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 47, SqlFieldName = UpdateDate ];

/// 更新时间
Property UpdateTime As %Time [ SqlColumnNumber = 48, SqlFieldName = UpdateTime ];

/// 主键索引
Index AdmDrIndex On AdmDr [ PrimaryKey ];

Storage Default
{
<Data name="BSHISDRGParamsDefaultData">
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
<Value>PsnNo</Value>
</Value>
<Value name="7">
<Value>InsuranceAreaCode</Value>
</Value>
<Value name="8">
<Value>MdtrtareaAreaCode</Value>
</Value>
<Value name="9">
<Value>InsuType</Value>
</Value>
<Value name="10">
<Value>DiagnosisCode</Value>
</Value>
<Value name="11">
<Value>DiagnosisName</Value>
</Value>
<Value name="12">
<Value>GroupStage</Value>
</Value>
<Value name="13">
<Value>DiaTypeCode</Value>
</Value>
<Value name="14">
<Value>UnionOprnFlag</Value>
</Value>
<Value name="15">
<Value>MainDiagnosisCode</Value>
</Value>
<Value name="16">
<Value>MainOperationCode</Value>
</Value>
<Value name="17">
<Value>Sex</Value>
</Value>
<Value name="18">
<Value>Age</Value>
</Value>
<Value name="19">
<Value>AgeGroupDays</Value>
</Value>
<Value name="20">
<Value>NewbornFlag</Value>
</Value>
<Value name="21">
<Value>RespiratorTime</Value>
</Value>
<Value name="22">
<Value>EcmoFlag</Value>
</Value>
<Value name="23">
<Value>TransplantFlag</Value>
</Value>
<Value name="24">
<Value>MarrowTransplantFlag</Value>
</Value>
<Value name="25">
<Value>HivFlag</Value>
</Value>
<Value name="26">
<Value>TraumaLevel</Value>
</Value>
<Value name="27">
<Value>Department</Value>
</Value>
<Value name="28">
<Value>DepartmentDesc</Value>
</Value>
<Value name="29">
<Value>DischargeType</Value>
</Value>
<Value name="30">
<Value>HospitalDays</Value>
</Value>
<Value name="31">
<Value>TotalCost</Value>
</Value>
<Value name="32">
<Value>MedicalRecordID</Value>
</Value>
<Value name="33">
<Value>HisAdmId</Value>
</Value>
<Value name="34">
<Value>PatientName</Value>
</Value>
<Value name="35">
<Value>DeptCode</Value>
</Value>
<Value name="36">
<Value>DeptName</Value>
</Value>
<Value name="37">
<Value>DoctorCode</Value>
</Value>
<Value name="38">
<Value>DoctorName</Value>
</Value>
<Value name="39">
<Value>TotalFee</Value>
</Value>
<Value name="40">
<Value>MedicalRecordDr</Value>
</Value>
<Value name="41">
<Value>FixmedinsCode</Value>
</Value>
<Value name="42">
<Value>FixmedinsName</Value>
</Value>
<Value name="43">
<Value>DrgParamsStatus</Value>
</Value>
<Value name="44">
<Value>CreateDate</Value>
</Value>
<Value name="45">
<Value>CreateTime</Value>
</Value>
<Value name="46">
<Value>CreateUserDr</Value>
</Value>
<Value name="47">
<Value>UpdateDate</Value>
</Value>
<Value name="48">
<Value>UpdateTime</Value>
</Value>
</Data>
<DataLocation>^BSHISDRGParamsD</DataLocation>
<DefaultData>BSHISDRGParamsDefaultData</DefaultData>
<IdLocation>^BSHISDRGParamsD</IdLocation>
<IndexLocation>^BSHISDRGParamsI</IndexLocation>
<StreamLocation>^BSHISDRGParamsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
