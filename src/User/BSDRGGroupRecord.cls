Class User.BSDRGGroupRecord Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGGroupRecord ]
{

Parameter %JSONREFERENCE = "ID";

/// ========================================
/// 基础信息字段
/// ========================================
/// HIS唯一就诊ID（病案ID）- 用于关联病案
Property AdmID As %String [ SqlColumnNumber = 2, SqlFieldName = AdmID ];

Index AdmID On AdmID;

/// 病案号
Property MedcasNo As %String [ SqlColumnNumber = 3, SqlFieldName = MedcasNo ];

/// 患者姓名
Property PatientName As %String [ SqlColumnNumber = 4, SqlFieldName = PatientName ];

/// 医保个人编号
Property PsnNo As %String [ SqlColumnNumber = 5, SqlFieldName = PsnNo ];

/// 参保地
Property InsuranceAreaCode As %String [ SqlColumnNumber = 6, SqlFieldName = InsuranceAreaCode ];

/// 就医地
Property mdtrtareaAreaCode As %String [ SqlColumnNumber = 7, SqlFieldName = MdtrtareaAreaCode ];

/// 医保险种
Property InsuType As %String [ SqlColumnNumber = 8, SqlFieldName = InsuType ];

/// 性别 1=男 2=女
Property Sex As %String [ SqlColumnNumber = 9, SqlFieldName = Sex ];

/// 年龄
Property Age As %Integer [ SqlColumnNumber = 10, SqlFieldName = Age ];

/// ========================================
/// 诊断信息字段
/// ========================================
/// 主诊断代码
Property MainDiagnosisCode As %String [ Required, SqlColumnNumber = 11, SqlFieldName = MainDiagnosisCode ];

/// 主诊断名称
Property MainDiagnosisName As %String [ Required, SqlColumnNumber = 12, SqlFieldName = MainDiagnosisName ];

/// 主诊断类型编码  ADD入院 OPD门诊 DIS出院
Property DiaTypeCode As %String [ Required, SqlColumnNumber = 13, SqlFieldName = DiaTypeCode ];

/// 病种编码
Property DiagnosisCode As %String [ SqlColumnNumber = 14, SqlFieldName = DiagnosisCode ];

/// 病种名称
Property DiagnosisName As %String [ SqlColumnNumber = 15, SqlFieldName = DiagnosisName ];

/// 主手术代码
Property MainOperationCode As %String [ SqlColumnNumber = 16, SqlFieldName = MainOperationCode ];

/// 主手术名称
Property MainOperationName As %String [ SqlColumnNumber = 17, SqlFieldName = MainOperationName ];

/// 入院时间
Property AdmDateTime As %DateTime [ SqlColumnNumber = 18, SqlFieldName = AdmDateTime ];

/// 出院时间
Property DiscgDateTime As %DateTime [ SqlColumnNumber = 19, SqlFieldName = DiscgDateTime ];

/// 结算时间
Property SettleDateTime As %DateTime [ SqlColumnNumber = 20, SqlFieldName = SettleDateTime ];

/// DRG编码
Property DRG As %String [ Required, SqlColumnNumber = 21, SqlFieldName = DRG ];

Index DRG On DRG;

/// DRG指向HB_DRGCoreAlgorithmData
Property DRGDr As HBDRGCoreAlgorithmData [ Required, SqlColumnNumber = 22, SqlFieldName = DRG_Dr ];

/// DRG描述
Property DRGDesc As %String(MAXLEN = 200) [ Required, SqlColumnNumber = 23, SqlFieldName = DRGDesc ];

/// 权重
Property Weight As %Decimal(SCALE = 4) [ SqlColumnNumber = 24, SqlFieldName = Weight ];

/// 基准费用
Property BenchmarkCost As %Decimal(SCALE = 2) [ SqlColumnNumber = 25, SqlFieldName = BenchmarkCost ];

/// CC标志 1=有合并症 0=无
Property CCFlag As %String [ SqlColumnNumber = 26, SqlFieldName = CCFlag ];

/// MCC标志 1=有严重合并症 0=无
Property MCCFlag As %String [ SqlColumnNumber = 27, SqlFieldName = MCCFlag ];

/// 风险等级 高/中/低
Property RiskLevel As %String [ SqlColumnNumber = 28, SqlFieldName = RiskLevel ];

/// 分组时间
Property GroupTime As %TimeStamp [ SqlColumnNumber = 29, SqlFieldName = GroupTime ];

Index GroupTime On GroupTime;

/// ========================================
/// 机构信息字段
/// ========================================
/// 省 指向CB_Province
Property ProvinceDr As CBProvince [ SqlColumnNumber = 30, SqlFieldName = Province_Dr ];

Index Province On ProvinceDr;

/// 市 指向CB_City
Property CityDr As CBCity [ SqlColumnNumber = 31, SqlFieldName = City_Dr ];

Index City On CityDr;

/// 医疗机构代码
Property FixmedinsCode As %String [ Required, SqlColumnNumber = 32, SqlFieldName = FixmedinsCode ];

Index FixmedinsCode On FixmedinsCode;

/// 医疗机构名称
Property FixmedinsName As %String [ Required, SqlColumnNumber = 33, SqlFieldName = FixmedinsName ];

/// HIS科室编码
Property Department As %String [ SqlColumnNumber = 34, SqlFieldName = Department ];

/// HIS科室名称名称
Property DepartmentDesc As %String [ SqlColumnNumber = 35, SqlFieldName = DepartmentDesc ];

/// ========================================
/// 系统字段
/// ========================================
/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 36, SqlFieldName = CreateDate ];

Index CreateDate On CreateDate;

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 37, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 38, SqlFieldName = CreateUser_Dr ];

/// 最后更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 39, SqlFieldName = UpdateDate ];

/// 最后更新时间
Property UpdateTime As %Time [ SqlColumnNumber = 40, SqlFieldName = UpdateTime ];

/// 最后更新人员
Property UpdateUserDr As HBUser [ SqlColumnNumber = 41, SqlFieldName = UpdateUser_Dr ];

/// 分组阶段 1.事前 2.事中 3.事后
Property GroupStage As %String [ SqlColumnNumber = 42, SqlFieldName = GroupStage ];

/// 备注
Property Remark As %String(MAXLEN = 99999) [ SqlColumnNumber = 43, SqlFieldName = Remark ];

/// 有效标志 1=有效 0=无效
Property ActiveFlag As %String [ InitialExpression = "1", SqlColumnNumber = 44, SqlFieldName = ActiveFlag ];

Index ActiveFlag On ActiveFlag;

/// 联合手术标志 1是 0否
Property UnionOprnFlag As %String [ InitialExpression = "0", SqlColumnNumber = 45, SqlFieldName = UnionOprnFlag ];

/// ========================================
/// 复合索引
/// ========================================
/// 创建日期+DRG 复合索引（用于按日期和DRG查询）
Index CreateDateDRG On (CreateDate, DRG);

/// AdmID+ActiveFlag 复合索引（用于查询有效记录）
Index AdmActive On (AdmID, ActiveFlag);

Storage Default
{
<Data name="BSDRGGroupRecordDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>AdmID</Value>
</Value>
<Value name="3">
<Value>MedcasNo</Value>
</Value>
<Value name="4">
<Value>PatientName</Value>
</Value>
<Value name="5">
<Value>Sex</Value>
</Value>
<Value name="6">
<Value>Age</Value>
</Value>
<Value name="7">
<Value>MainDiagnosisCode</Value>
</Value>
<Value name="8">
<Value>MainDiagnosisName</Value>
</Value>
<Value name="9">
<Value>DiaTypeCode</Value>
</Value>
<Value name="10">
<Value>DiagnosisCode</Value>
</Value>
<Value name="11">
<Value>DiagnosisName</Value>
</Value>
<Value name="12">
<Value>MainOperationCode</Value>
</Value>
<Value name="13">
<Value>MainOperationName</Value>
</Value>
<Value name="14">
<Value>DRG</Value>
</Value>
<Value name="15">
<Value>DRGDr</Value>
</Value>
<Value name="16">
<Value>DRGDesc</Value>
</Value>
<Value name="17">
<Value>Weight</Value>
</Value>
<Value name="18">
<Value>BenchmarkCost</Value>
</Value>
<Value name="19">
<Value>CCFlag</Value>
</Value>
<Value name="20">
<Value>MCCFlag</Value>
</Value>
<Value name="21">
<Value>RiskLevel</Value>
</Value>
<Value name="22">
<Value>GroupTime</Value>
</Value>
<Value name="23">
<Value>ProvinceDr</Value>
</Value>
<Value name="24">
<Value>CityDr</Value>
</Value>
<Value name="25">
<Value>FixmedinsCode</Value>
</Value>
<Value name="26">
<Value>FixmedinsName</Value>
</Value>
<Value name="27">
<Value>Department</Value>
</Value>
<Value name="28">
<Value>DepartmentDesc</Value>
</Value>
<Value name="29">
<Value>CreateDate</Value>
</Value>
<Value name="30">
<Value>CreateTime</Value>
</Value>
<Value name="31">
<Value>CreateUserDr</Value>
</Value>
<Value name="32">
<Value>UpdateDate</Value>
</Value>
<Value name="33">
<Value>UpdateTime</Value>
</Value>
<Value name="34">
<Value>UpdateUserDr</Value>
</Value>
<Value name="35">
<Value>Remark</Value>
</Value>
<Value name="36">
<Value>ActiveFlag</Value>
</Value>
<Value name="37">
<Value>GroupStage</Value>
</Value>
<Value name="38">
<Value>PsnNo</Value>
</Value>
<Value name="39">
<Value>InsuranceAreaCode</Value>
</Value>
<Value name="40">
<Value>InsuType</Value>
</Value>
<Value name="41">
<Value>AdmDateTime</Value>
</Value>
<Value name="42">
<Value>DiscgDateTime</Value>
</Value>
<Value name="43">
<Value>SettleDateTime</Value>
</Value>
<Value name="44">
<Value>mdtrtareaAreaCode</Value>
</Value>
<Value name="45">
<Value>UnionOprnFlag</Value>
</Value>
</Data>
<DataLocation>^BSDRGGroupRecordD</DataLocation>
<DefaultData>BSDRGGroupRecordDefaultData</DefaultData>
<IdLocation>^BSDRGGroupRecordD</IdLocation>
<IndexLocation>^BSDRGGroupRecordI</IndexLocation>
<StreamLocation>^BSDRGGroupRecordS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
