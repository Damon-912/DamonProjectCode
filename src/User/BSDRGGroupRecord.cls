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

Property PatientName As %String [ SqlColumnNumber = 4, SqlFieldName = PatientName ];

/// 患者姓名
/// 性别 1=男 2=女
Property Sex As %String [ SqlColumnNumber = 5, SqlFieldName = Sex ];

/// 年龄
Property Age As %Integer [ SqlColumnNumber = 6, SqlFieldName = Age ];

/// ========================================
/// 诊断信息字段
/// ========================================
/// 主诊断代码
Property MainDiagnosisCode As %String [ SqlColumnNumber = 7, SqlFieldName = MainDiagnosisCode ];

/// 主诊断名称
Property MainDiagnosisName As %String(MAXLEN = 200) [ SqlColumnNumber = 8, SqlFieldName = MainDiagnosisName ];

/// 主手术代码
Property MainOperationCode As %String [ SqlColumnNumber = 9, SqlFieldName = MainOperationCode ];

/// 主手术名称
Property MainOperationName As %String(MAXLEN = 200) [ SqlColumnNumber = 10, SqlFieldName = MainOperationName ];

/// ========================================
/// DRG分组结果字段
/// ========================================
/// MDC主诊断大类编码
Property MDC As %String [ SqlColumnNumber = 11, SqlFieldName = MDC ];

Index MDC On MDC;

/// MDC描述
Property MDCDesc As %String(MAXLEN = 100) [ SqlColumnNumber = 12, SqlFieldName = MDCDesc ];

/// ADRG编码
Property ADRG As %String [ SqlColumnNumber = 13, SqlFieldName = ADRG ];

Index ADRG On ADRG;

/// ADRG描述
Property ADRGDesc As %String(MAXLEN = 100) [ SqlColumnNumber = 14, SqlFieldName = ADRGDesc ];

/// DRG编码
Property DRG As %String [ SqlColumnNumber = 15, SqlFieldName = DRG ];

Index DRG On DRG;

/// DRG指向HB_DRGCoreAlgorithmData
Property DRGDr As HBDRGCoreAlgorithmData [ SqlColumnNumber = 16, SqlFieldName = DRG_Dr ];

/// DRG描述
Property DRGDesc As %String(MAXLEN = 200) [ SqlColumnNumber = 17, SqlFieldName = DRGDesc ];

/// 权重
Property Weight As %Decimal(SCALE = 4) [ SqlColumnNumber = 18, SqlFieldName = Weight ];

/// 基准费用
Property BenchmarkCost As %Decimal(SCALE = 2) [ SqlColumnNumber = 19, SqlFieldName = BenchmarkCost ];

/// CC标志 1=有合并症 0=无
Property CCFlag As %String [ SqlColumnNumber = 20, SqlFieldName = CCFlag ];

/// MCC标志 1=有严重合并症 0=无
Property MCCFlag As %String [ SqlColumnNumber = 21, SqlFieldName = MCCFlag ];

/// 风险等级 高/中/低
Property RiskLevel As %String [ SqlColumnNumber = 22, SqlFieldName = RiskLevel ];

/// 分组时间
Property GroupTime As %TimeStamp [ SqlColumnNumber = 23, SqlFieldName = GroupTime ];

Index GroupTime On GroupTime;

/// ========================================
/// 机构信息字段
/// ========================================
/// 省 指向CB_Province
Property ProvinceDr As CBProvince [ SqlColumnNumber = 24, SqlFieldName = Province_Dr ];

Index Province On ProvinceDr;

/// 市 指向CB_City
Property CityDr As CBCity [ SqlColumnNumber = 25, SqlFieldName = City_Dr ];

Index City On CityDr;

/// 医疗机构代码
Property FixmedinsCode As %String [ SqlColumnNumber = 26, SqlFieldName = FixmedinsCode ];

Index FixmedinsCode On FixmedinsCode;

/// 医疗机构名称
Property FixmedinsName As %String(MAXLEN = 200) [ SqlColumnNumber = 27, SqlFieldName = FixmedinsName ];

/// 科室
Property Department As %String [ SqlColumnNumber = 28, SqlFieldName = Department ];

/// ========================================
/// 系统字段
/// ========================================
/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 29, SqlFieldName = CreateDate ];

Index CreateDate On CreateDate;

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 30, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ SqlColumnNumber = 31, SqlFieldName = CreateUser_Dr ];

/// 最后更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 32, SqlFieldName = UpdateDate ];

/// 最后更新时间
Property UpdateTime As %Time [ SqlColumnNumber = 33, SqlFieldName = UpdateTime ];

/// 最后更新人员
Property UpdateUserDr As HBUser [ SqlColumnNumber = 34, SqlFieldName = UpdateUser_Dr ];

/// 备注
Property Remark As %String(MAXLEN = 99999) [ SqlColumnNumber = 35, SqlFieldName = Remark ];

/// 有效标志 1=有效 0=无效
Property ActiveFlag As %String [ InitialExpression = "1", SqlColumnNumber = 36, SqlFieldName = ActiveFlag ];

Index ActiveFlag On ActiveFlag;

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
<Value>HISAdmID</Value>
</Value>
<Value name="3">
<Value>AdmissionNo</Value>
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
<Value>MainOperationCode</Value>
</Value>
<Value name="10">
<Value>MainOperationName</Value>
</Value>
<Value name="11">
<Value>MDC</Value>
</Value>
<Value name="12">
<Value>MDCDesc</Value>
</Value>
<Value name="13">
<Value>ADRG</Value>
</Value>
<Value name="14">
<Value>ADRGDesc</Value>
</Value>
<Value name="15">
<Value>DRG</Value>
</Value>
<Value name="16">
<Value>DRGDr</Value>
</Value>
<Value name="17">
<Value>DRGDesc</Value>
</Value>
<Value name="18">
<Value>Weight</Value>
</Value>
<Value name="19">
<Value>BenchmarkCost</Value>
</Value>
<Value name="20">
<Value>CCFlag</Value>
</Value>
<Value name="21">
<Value>MCCFlag</Value>
</Value>
<Value name="22">
<Value>RiskLevel</Value>
</Value>
<Value name="23">
<Value>GroupTime</Value>
</Value>
<Value name="24">
<Value>ProvinceDr</Value>
</Value>
<Value name="25">
<Value>CityDr</Value>
</Value>
<Value name="26">
<Value>FixmedinsCode</Value>
</Value>
<Value name="27">
<Value>FixmedinsName</Value>
</Value>
<Value name="28">
<Value>Department</Value>
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
<Value>AdmID</Value>
</Value>
<Value name="38">
<Value>MedcasNo</Value>
</Value>
</Data>
<DataLocation>^User.BSDRGGroupRecordD</DataLocation>
<DefaultData>BSDRGGroupRecordDefaultData</DefaultData>
<IdLocation>^User.BSDRGGroupRecordD</IdLocation>
<IndexLocation>^User.BSDRGGroupRecordI</IndexLocation>
<StreamLocation>^User.BSDRGGroupRecordS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
