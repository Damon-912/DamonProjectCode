Class User.BSDRGWarningRecord Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGWarningRecord ]
{

Parameter %JSONREFERENCE = "ID";

/// ========================================
/// 预警标识信息
/// ========================================
/// 预警流水号
Property WarningNo As %String [ Required, SqlColumnNumber = 2, SqlFieldName = WarningNo ];

Index WarningNo On WarningNo [ Unique ];

/// 关联规则ID
Property RuleDr As BSDRGWarningRule [ SqlColumnNumber = 3, SqlFieldName = Rule_Dr ];

Index RuleDr On RuleDr;

/// 关联规则编码
Property RuleCode As %String [ SqlColumnNumber = 4, SqlFieldName = RuleCode ];

Index RuleCode On RuleCode;

/// 关联规则名称
Property RuleName As %String [ SqlColumnNumber = 5, SqlFieldName = RuleName ];

/// ========================================
/// 预警类型与级别
/// ========================================
/// 预警类型 01=费用超支, 02=低倍率, 03=高倍率, 04=编码异常, 05=分解住院
Property WarningType As %String [ Required, SqlColumnNumber = 6, SqlFieldName = WarningType ];

Index WarningType On WarningType;

/// 预警级别 1=低, 2=中, 3=高
Property WarningLevel As %String [ SqlColumnNumber = 7, SqlFieldName = WarningLevel ];

Index WarningLevel On WarningLevel;

/// ========================================
/// 病案信息
/// ========================================
/// 病案ID
Property MedicalRecordDr As %String [ SqlColumnNumber = 8, SqlFieldName = MedicalRecord_Dr ];

/// HIS就诊ID
Property HISAdmID As %String [ Required, SqlColumnNumber = 9, SqlFieldName = HISAdmID ];

Index HISAdmID On HISAdmID;

/// 患者姓名
Property PatientName As %String [ Required, SqlColumnNumber = 10, SqlFieldName = PatientName ];

/// ========================================
/// 科室与医生信息
/// ========================================
/// 科室编码
Property DeptCode As %String [ SqlColumnNumber = 11, SqlFieldName = DeptCode ];

Index DeptCode On DeptCode;

/// 科室名称
Property DeptName As %String [ SqlColumnNumber = 12, SqlFieldName = DeptName ];

/// 医生编码
Property DoctorCode As %String [ SqlColumnNumber = 13, SqlFieldName = DoctorCode ];

Index DoctorCode On DoctorCode;

/// 医生姓名
Property DoctorName As %String [ SqlColumnNumber = 14, SqlFieldName = DoctorName ];

/// ========================================
/// DRG分组信息
/// ========================================
/// DRG编码
Property DRGCode As %String [ Required, SqlColumnNumber = 15, SqlFieldName = DRGCode ];

Index DRGCode On DRGCode;

/// DRG名称
Property DRGName As %String [ SqlColumnNumber = 16, SqlFieldName = DRGName ];

/// ========================================
/// 费用信息
/// ========================================
/// 医疗总费用
Property TotalFee As %Decimal(SCALE = 2) [ Required, SqlColumnNumber = 17, SqlFieldName = TotalFee ];

/// 医保结算费用
Property InsuranceFee As %Decimal(SCALE = 2) [ SqlColumnNumber = 18, SqlFieldName = InsuranceFee ];

/// DRG支付标准
Property DRGPayStandard As %Decimal(SCALE = 2) [ SqlColumnNumber = 19, SqlFieldName = DRGPayStandard ];

/// 费用差异金额
Property DiffAmount As %Decimal(SCALE = 2) [ SqlColumnNumber = 20, SqlFieldName = DiffAmount ];

/// 费用差异率(%)
Property DiffRate As %Decimal(SCALE = 2) [ SqlColumnNumber = 21, SqlFieldName = DiffRate ];

/// ========================================
/// 预警消息与状态
/// ========================================
/// 预警消息
Property WarningMessage As %String(MAXLEN = 1000) [ SqlColumnNumber = 22, SqlFieldName = WarningMessage ];

/// 预警状态 01=待处理, 02=已确认, 03=已忽略, 04=已申诉, 05=已解决
Property WarningStatus As %String [ InitialExpression = "01", SqlColumnNumber = 23, SqlFieldName = WarningStatus ];

Index WarningStatus On WarningStatus;

/// 预警日期
Property WarningDate As %Date [ Required, SqlColumnNumber = 24, SqlFieldName = WarningDate ];

Index WarningDate On WarningDate;

/// 预警时间
Property WarningTime As %Time [ Required, SqlColumnNumber = 25, SqlFieldName = WarningTime ];

/// ========================================
/// 处理信息
/// ========================================
/// 处理人
Property ProcessUserDr As %String [ SqlColumnNumber = 26, SqlFieldName = ProcessUser_Dr ];

/// 处理日期
Property ProcessDate As %Date [ SqlColumnNumber = 27, SqlFieldName = ProcessDate ];

/// 处理时间
Property ProcessTime As %Time [ SqlColumnNumber = 28, SqlFieldName = ProcessTime ];

/// 处理备注
Property ProcessRemark As %String(MAXLEN = 1000) [ SqlColumnNumber = 29, SqlFieldName = ProcessRemark ];

/// ========================================
/// 机构信息
/// ========================================
/// 医疗机构代码
Property FixmedinsCode As %String [ SqlColumnNumber = 30, SqlFieldName = FixmedinsCode ];

Index FixmedinsCode On FixmedinsCode;

/// 医疗机构名称
Property FixmedinsName As %String [ SqlColumnNumber = 31, SqlFieldName = FixmedinsName ];

/// ========================================
/// 复合索引
/// ========================================
/// 日期+状态 复合索引
Index DateStatus On (WarningDate, WarningStatus);

/// 日期+类型 复合索引
Index DateType On (WarningDate, WarningType);

/// 日期+DRG 复合索引
Index DateDRG On (WarningDate, DRGCode);

/// 就诊+DRG 复合索引
Index AdmDRG On (HISAdmID, DRGCode);

Storage Default
{
<Data name="BSDRGWarningRecordDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>WarningNo</Value>
</Value>
<Value name="3">
<Value>RuleDr</Value>
</Value>
<Value name="4">
<Value>RuleCode</Value>
</Value>
<Value name="5">
<Value>RuleName</Value>
</Value>
<Value name="6">
<Value>WarningType</Value>
</Value>
<Value name="7">
<Value>WarningLevel</Value>
</Value>
<Value name="8">
<Value>MedicalRecordDr</Value>
</Value>
<Value name="9">
<Value>HISAdmID</Value>
</Value>
<Value name="10">
<Value>PatientName</Value>
</Value>
<Value name="11">
<Value>DeptCode</Value>
</Value>
<Value name="12">
<Value>DeptName</Value>
</Value>
<Value name="13">
<Value>DoctorCode</Value>
</Value>
<Value name="14">
<Value>DoctorName</Value>
</Value>
<Value name="15">
<Value>DRGCode</Value>
</Value>
<Value name="16">
<Value>DRGName</Value>
</Value>
<Value name="17">
<Value>TotalFee</Value>
</Value>
<Value name="18">
<Value>InsuranceFee</Value>
</Value>
<Value name="19">
<Value>DRGPayStandard</Value>
</Value>
<Value name="20">
<Value>DiffAmount</Value>
</Value>
<Value name="21">
<Value>DiffRate</Value>
</Value>
<Value name="22">
<Value>WarningMessage</Value>
</Value>
<Value name="23">
<Value>WarningStatus</Value>
</Value>
<Value name="24">
<Value>WarningDate</Value>
</Value>
<Value name="25">
<Value>WarningTime</Value>
</Value>
<Value name="26">
<Value>ProcessUserDr</Value>
</Value>
<Value name="27">
<Value>ProcessDate</Value>
</Value>
<Value name="28">
<Value>ProcessTime</Value>
</Value>
<Value name="29">
<Value>ProcessRemark</Value>
</Value>
<Value name="30">
<Value>FixmedinsCode</Value>
</Value>
<Value name="31">
<Value>FixmedinsName</Value>
</Value>
</Data>
<DataLocation>^User.BSDRGWarningRecordD</DataLocation>
<DefaultData>BSDRGWarningRecordDefaultData</DefaultData>
<IdLocation>^User.BSDRGWarningRecordD</IdLocation>
<IndexLocation>^User.BSDRGWarningRecordI</IndexLocation>
<StreamLocation>^User.BSDRGWarningRecordS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
