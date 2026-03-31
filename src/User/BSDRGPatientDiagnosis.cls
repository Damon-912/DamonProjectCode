Class User.BSDRGPatientDiagnosis Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGPatientDiagnosis ]
{

Parameter %JSONREFERENCE = "ID";

/// 医保就诊ID 
Property MdtrtId As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 2, SqlFieldName = MdtrtId ];

Index MdtrtId On MdtrtId;

/// 就医流水号 
Property MdtrtSn As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 3, SqlFieldName = MdtrtSn ];

Index MdtrtSn On MdtrtSn;

/// 住院病案首页流水号 
Property IptMedcasHmpgSn As %String [ Required, SqlColumnNumber = 4, SqlFieldName = IptMedcasHmpgSn ];

/// 病理号 
Property PalgNo As %String [ SqlColumnNumber = 5, SqlFieldName = PalgNo ];

/// 住院患者疾病诊断类型代码 
Property IptPatnDisediagTypeCode As %String [ Required, SqlColumnNumber = 6, SqlFieldName = IptPatnDisediagTypeCode ];

Index IptPatnDisediagTypeCode On IptPatnDisediagTypeCode;

/// 疾病诊断类型 
Property DisediagType As %String [ SqlColumnNumber = 7, SqlFieldName = DisediagType ];

Index DisediagType On DisediagType;

/// 主诊断标志 
Property MaindiagFlag As %String [ SqlColumnNumber = 8, SqlFieldName = MaindiagFlag ];

/// 诊断代码 
Property DiagCode As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 9, SqlFieldName = DiagCode ];

Index DiagCode On DiagCode;

Index MainDiag On (MdtrtId, IptPatnDisediagTypeCode, DiagCode) [ Unique ];

/// 诊断名称 
Property DiagName As %String [ SqlColumnNumber = 10, SqlFieldName = DiagName ];

/// 院内诊断代码 
Property InhospDiagCode As %String [ SqlColumnNumber = 11, SqlFieldName = InhospDiagCode ];

/// 院内诊断名称 
Property InhospDiagName As %String [ SqlColumnNumber = 12, SqlFieldName = InhospDiagName ];

/// 入院疾病病情名称 
Property AdmDiseCondName As %String [ SqlColumnNumber = 13, SqlFieldName = AdmDiseCondName ];

/// 入院疾病病情代码 
Property AdmDiseCondCode As %String [ SqlColumnNumber = 14, SqlFieldName = AdmDiseCondCode ];

/// 入院病情 
Property AdmCond As %String [ SqlColumnNumber = 15, SqlFieldName = AdmCond ];

/// 入院时病情代码 
Property AdmCondCode As %String [ SqlColumnNumber = 16, SqlFieldName = AdmCondCode ];

/// 最高诊断依据 
Property HighDiagEvid As %String [ SqlColumnNumber = 17, SqlFieldName = HighDiagEvid ];

/// 分化程度 
Property BkupDeg As %String [ SqlColumnNumber = 18, SqlFieldName = BkupDeg ];

/// 分化程度代码 
Property BkupDegCode As %String [ SqlColumnNumber = 19, SqlFieldName = BkupDegCode ];

/// 有效标志 
Property ValiFlag As %String [ Required, SqlColumnNumber = 20, SqlFieldName = ValiFlag ];

/// HIS就诊流水号 
Property HISAdmID As %String [ SqlColumnNumber = 21, SqlFieldName = HISAdmID ];

/// 数据更新时间
Property UpdateTime As %DateTime [ SqlColumnNumber = 22, SqlFieldName = UpdateTime ];

Storage Default
{
<Data name="BSDRGPatientDiagnosisDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MdtrtId</Value>
</Value>
<Value name="3">
<Value>MdtrtSn</Value>
</Value>
<Value name="4">
<Value>IptMedcasHmpgSn</Value>
</Value>
<Value name="5">
<Value>PalgNo</Value>
</Value>
<Value name="6">
<Value>IptPatnDisediagTypeCode</Value>
</Value>
<Value name="7">
<Value>DisediagType</Value>
</Value>
<Value name="8">
<Value>MaindiagFlag</Value>
</Value>
<Value name="9">
<Value>DiagCode</Value>
</Value>
<Value name="10">
<Value>DiagName</Value>
</Value>
<Value name="11">
<Value>InhospDiagCode</Value>
</Value>
<Value name="12">
<Value>InhospDiagName</Value>
</Value>
<Value name="13">
<Value>AdmDiseCondName</Value>
</Value>
<Value name="14">
<Value>AdmDiseCondCode</Value>
</Value>
<Value name="15">
<Value>AdmCond</Value>
</Value>
<Value name="16">
<Value>AdmCondCode</Value>
</Value>
<Value name="17">
<Value>HighDiagEvid</Value>
</Value>
<Value name="18">
<Value>BkupDeg</Value>
</Value>
<Value name="19">
<Value>BkupDegCode</Value>
</Value>
<Value name="20">
<Value>ValiFlag</Value>
</Value>
<Value name="21">
<Value>HISAdmID</Value>
</Value>
<Value name="22">
<Value>UpdateTime</Value>
</Value>
</Data>
<DataLocation>^BSDRGPatientDiagnosisD</DataLocation>
<DefaultData>BSDRGPatientDiagnosisDefaultData</DefaultData>
<IdLocation>^BSDRGPatientDiagnosisD</IdLocation>
<IndexLocation>^BSDRGPatientDiagnosisI</IndexLocation>
<StreamLocation>^BSDRGPatientDiagnosisS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
