/// DRG-HIS交互信息表（包含HIS病案首页信息、医保结算清单信息）
Class User.BSDRGInteractionInfo Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGInteractionInfo ]
{

Parameter %JSONREFERENCE = "ID";

/// 病案号 
Property MedcasNo As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 2, SqlFieldName = MedcasNo ];

Index MedcasNo On MedcasNo;

/// 住院号 
Property IptOtpNo As %String(MAXLEN = 50) [ SqlColumnNumber = 3, SqlFieldName = IptOtpNo ];

/// HIS唯一就诊号
Property HISAdmID As %String [ SqlColumnNumber = 4, SqlFieldName = HISAdmID ];

Index HISAdmID On HISAdmID;

/// 医保就诊流水号 
Property MdtrtID As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 5, SqlFieldName = MdtrtID ];

/// 医保结算ID 
Property SettleID As %String [ SqlColumnNumber = 6, SqlFieldName = SettleID ];

/// 医保个人编号 
Property PsnNo As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 7, SqlFieldName = PsnNo ];

/// 人员姓名 
Property PsnName As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 8, SqlFieldName = PsnName ];

/// 性别  男、女、其他
Property Gend As %String [ SqlColumnNumber = 9, SqlFieldName = Gend ];

/// 年龄
Property Age As %String [ SqlColumnNumber = 10, SqlFieldName = Age ];

/// 新生儿出生天数
Property AgeGroupDays As %String [ SqlColumnNumber = 11, SqlFieldName = AgeGroupDays ];

/// 新生儿标志
Property NewBornFlag As %String [ SqlColumnNumber = 12, SqlFieldName = NewBornFlag ];

/// 证件类型 
Property CertType As %String [ SqlColumnNumber = 13, SqlFieldName = CertType ];

/// 证件号码
Property CertNo As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 14, SqlFieldName = CertNo ];

Index CertNo On CertNo;

Index AdmIndex On (MedcasNo, HISAdmID, CertNo) [ Unique ];

/// 工作单位及地址
Property EmprAddr As %String(MAXLEN = 500) [ SqlColumnNumber = 15, SqlFieldName = EmprAddr ];

/// 联系电话
Property Tel As %String [ SqlColumnNumber = 16, SqlFieldName = Tel ];

/// HIS科室编码
Property Department As %String [ SqlColumnNumber = 17, SqlFieldName = Department ];

/// HIS科室名称
Property DepartmentDesc As %String [ SqlColumnNumber = 18, SqlFieldName = DepartmentDesc ];

/// HIS医生编码
Property Doctor As %String [ SqlColumnNumber = 19, SqlFieldName = Doctor ];

/// HIS医生名称
Property DoctorName As %String [ SqlColumnNumber = 20, SqlFieldName = DoctorName ];

/// 主诊断编码
Property mainDiagnosisCode As %String [ SqlColumnNumber = 21, SqlFieldName = mainDiagnosisCode ];

/// 主诊断名称
Property mainDiagnosisDesc As %String [ SqlColumnNumber = 22, SqlFieldName = mainDiagnosisDesc ];

/// 主手术操作编码
Property mainOperationCode As %String [ SqlColumnNumber = 23, SqlFieldName = mainOperationCode ];

/// 主手术操作名称
Property mainOperationDesc As %String [ SqlColumnNumber = 24, SqlFieldName = mainOperationDesc ];

/// 参保地区划代码 
Property InsuplcAdmdvs As %String [ SqlColumnNumber = 25, SqlFieldName = InsuplcAdmdvs ];

/// 参保地区划名称
Property InsuplcAdmdvsDesc As %String [ SqlColumnNumber = 26, SqlFieldName = InsuplcAdmdvsDesc ];

/// 险种类型代码
Property InsuType As %String [ SqlColumnNumber = 27, SqlFieldName = InsuType ];

/// 险种类型名称
Property InsuTypeDesc As %String [ SqlColumnNumber = 28, SqlFieldName = InsuTypeDesc ];

/// 医保基金付费方式名称
Property HifPayWayName As %String [ SqlColumnNumber = 29, SqlFieldName = HifPayWayName ];

/// 医保基金付费方式代码
Property HifPayWayCode As %String [ SqlColumnNumber = 30, SqlFieldName = HifPayWayCode ];

/// 医疗费用支付方式名称
Property MedFeePaymtdName As %String [ SqlColumnNumber = 31, SqlFieldName = MedFeePaymtdName ];

/// 医疗费用支付方式代码
Property MedfeePaymtdCode As %String [ SqlColumnNumber = 32, SqlFieldName = MedfeePaymtdCode ];

/// 自付金额
Property SelfpayAmt As %String [ SqlColumnNumber = 33, SqlFieldName = SelfpayAmt ];

/// 医疗费总额
Property MedfeeSumamt As %String [ SqlColumnNumber = 34, SqlFieldName = MedfeeSumamt ];

/// 一般医疗服务费
Property OrdnMedServfee As %String [ SqlColumnNumber = 35, SqlFieldName = OrdnMedServfee ];

/// 一般治疗操作费
Property OrdnTrtOprtFee As %String [ SqlColumnNumber = 36, SqlFieldName = OrdnTrtOprtFee ];

/// 护理费
Property NursFee As %String [ SqlColumnNumber = 37, SqlFieldName = NursFee ];

/// 综合医疗服务类其他费用
Property ComMedServOthFee As %String [ SqlColumnNumber = 38, SqlFieldName = ComMedServOthFee ];

/// 病理诊断费
Property PalgDiagFee As %String [ SqlColumnNumber = 39, SqlFieldName = PalgDiagFee ];

/// 实验室诊断费
Property LabDiagFee As %String [ SqlColumnNumber = 40, SqlFieldName = LabDiagFee ];

/// 影像学诊断费
Property RdhyDiagFee As %String [ SqlColumnNumber = 41, SqlFieldName = RdhyDiagFee ];

/// 临床诊断项目费
Property ClncDiseFee As %String [ SqlColumnNumber = 42, SqlFieldName = ClncDiseFee ];

/// 非手术治疗项目费
Property NsrgtrtItemFee As %String [ SqlColumnNumber = 43, SqlFieldName = NsrgtrtItemFee ];

/// 临床物理治疗费
Property ClncPhysTrtFee As %String [ SqlColumnNumber = 44, SqlFieldName = ClncPhysTrtFee ];

/// 手术治疗费
Property RgtrtTrtFee As %String [ SqlColumnNumber = 45, SqlFieldName = RgtrtTrtFee ];

/// 麻醉费
Property AnstFee As %String [ SqlColumnNumber = 46, SqlFieldName = AnstFee ];

/// 手术费
Property RgtrtFee As %String [ SqlColumnNumber = 47, SqlFieldName = RgtrtFee ];

/// 康复费
Property RhabFee As %String [ SqlColumnNumber = 48, SqlFieldName = RhabFee ];

/// 中医治疗费
Property TcmTrtFee As %String [ SqlColumnNumber = 49, SqlFieldName = TcmTrtFee ];

/// 西药费
Property WmFee As %String [ SqlColumnNumber = 50, SqlFieldName = WmFee ];

/// 抗菌药物费用
Property AbtlMednFee As %String [ SqlColumnNumber = 51, SqlFieldName = AbtlMednFee ];

/// 中成药费
Property TcmpatFee As %String [ SqlColumnNumber = 52, SqlFieldName = TcmpatFee ];

/// 中药饮片费
Property TcmherbFee As %String [ SqlColumnNumber = 53, SqlFieldName = TcmherbFee ];

/// 血费
Property BloFee As %String [ SqlColumnNumber = 54, SqlFieldName = BloFee ];

/// 白蛋白类制品费
Property AlbuFee As %String [ SqlColumnNumber = 55, SqlFieldName = AlbuFee ];

/// 球蛋白类制品费
Property GlonFee As %String [ SqlColumnNumber = 56, SqlFieldName = GlonFee ];

/// 凝血因子类制品费
Property ClotfacFee As %String [ SqlColumnNumber = 57, SqlFieldName = ClotfacFee ];

/// 细胞因子类制品费
Property CykiFee As %String [ SqlColumnNumber = 58, SqlFieldName = CykiFee ];

/// 检查用一次性医用材料费
Property ExamDspoMatlFee As %String [ SqlColumnNumber = 59, SqlFieldName = ExamDspoMatlFee ];

/// 治疗用一次性医用材料费
Property TrtDspoMatlFee As %String [ SqlColumnNumber = 60, SqlFieldName = TrtDspoMatlFee ];

/// 手术用一次性医用材料费
Property OprnDspoMatlFee As %String [ SqlColumnNumber = 61, SqlFieldName = OprnDspoMatlFee ];

/// 其他费
Property OthFee As %String [ SqlColumnNumber = 62, SqlFieldName = OthFee ];

/// 票据代码
Property BillCode As %String [ SqlColumnNumber = 63, SqlFieldName = BillCode ];

/// 票据号码
Property BillNo As %String [ SqlColumnNumber = 64, SqlFieldName = BillNo ];

/// 业务流水号
Property BizSn As %String [ SqlColumnNumber = 65, SqlFieldName = BizSn ];

/// 医保支付方式
Property HiPaymtd As %String [ SqlColumnNumber = 66, SqlFieldName = HiPaymtd ];

/// 医疗费用总额
Property TotalAmt As %String [ Required, SqlColumnNumber = 67, SqlFieldName = TotalAmt ];

/// 入院时间
Property AdmDateTime As %DateTime [ SqlColumnNumber = 68, SqlFieldName = AdmDateTime ];

/// 出院时间
Property DscgDateTime As %DateTime [ SqlColumnNumber = 69, SqlFieldName = DscgDateTime ];

/// 结算时间
Property SettlementDateTime As %DateTime [ SqlColumnNumber = 70, SqlFieldName = SettlementDateTime ];

/// 数据更新时间
Property UpdateDateTime As %DateTime [ SqlColumnNumber = 71, SqlFieldName = UpdateDateTime ];

/// 呼吸机使用时长
Property RespiratorTime As %String [ SqlColumnNumber = 72, SqlFieldName = RespiratorTime ];

/// ECMO标志
Property ECMOFlag As %String [ SqlColumnNumber = 73, SqlFieldName = ECMOFlag ];

/// 器官移植标志
Property TransplantFlag As %String [ SqlColumnNumber = 74, SqlFieldName = TransplantFlag ];

/// 骨髓移植标志
Property MarrowTransplantFlag As %String [ SqlColumnNumber = 75, SqlFieldName = MarrowTransplantFlag ];

/// HIV感染标志
Property HIVFlag As %String [ SqlColumnNumber = 76, SqlFieldName = HIVFlag ];

/// 创伤等级
Property TraumaLevel As %String [ SqlColumnNumber = 77, SqlFieldName = TraumaLevel ];

/// 住院天数
Property IptDays As %String [ SqlColumnNumber = 78, SqlFieldName = IptDays ];

/// 定点医疗机构代码
Property FixmedinsCode As %String [ SqlColumnNumber = 79, SqlFieldName = FixmedinsCode ];

/// 定点医疗机构名称
Property FixmedinsName As %String [ SqlColumnNumber = 80, SqlFieldName = FixmedinsName ];

/// 分组状态
Property GroupStatus As %String [ SqlColumnNumber = 81, SqlFieldName = GroupStatus ];

/// DRG
Property DRG As %String [ SqlColumnNumber = 82, SqlFieldName = DRG ];

/// DRG描述
Property DRGDesc As %String [ SqlColumnNumber = 83, SqlFieldName = DRGDesc ];

/// 病案首页数据类型 1.数据流 2.URL 
Property FileType As %String [ SqlColumnNumber = 84, SqlFieldName = FileType ];

/// 病案首页数据流
Property EMRFile As %String(MAXLEN = 99999) [ SqlColumnNumber = 85, SqlFieldName = EMRFileInfo ];

/// 结算清单数据流
Property SettleBillFile As %String(MAXLEN = 99999) [ SqlColumnNumber = 86, SqlFieldName = SettleBillFile ];

/// 疾病诊断信息
Property DiseInfo As %String(MAXLEN = 99999) [ SqlColumnNumber = 87, SqlFieldName = DiseInfo ];

/// 手术操作信息
Property OprnInfo As %String(MAXLEN = 99999) [ SqlColumnNumber = 88, SqlFieldName = OprnInfo ];

/// 重症监护信息
Property ICUInfo As %String(MAXLEN = 99999) [ SqlColumnNumber = 89, SqlFieldName = ICUInfo ];

/// 门诊慢特病诊断信息
Property OpspDiseInfo As %String(MAXLEN = 99999) [ SqlColumnNumber = 90, SqlFieldName = OpspDiseInfo ];

/// 输血信息
Property BldInfo As %String(MAXLEN = 99999) [ SqlColumnNumber = 91, SqlFieldName = BldInfo ];

/// 基金支付信息
Property PayInfo As %String(MAXLEN = 99999) [ SqlColumnNumber = 92, SqlFieldName = PayInfo ];

/// 收费项目信息
Property ItemInfo As %String(MAXLEN = 99999) [ SqlColumnNumber = 93, SqlFieldName = ItemInfo ];

/// 备注
Property Remark As %String(MAXLEN = 99999) [ SqlColumnNumber = 94, SqlFieldName = Remark ];

Storage Default
{
<Data name="BSDRGInteractionInfoDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>MedcasNo</Value>
</Value>
<Value name="3">
<Value>IptOtpNo</Value>
</Value>
<Value name="4">
<Value>HISAdmID</Value>
</Value>
<Value name="5">
<Value>MdtrtID</Value>
</Value>
<Value name="6">
<Value>PsnNo</Value>
</Value>
<Value name="7">
<Value>PsnName</Value>
</Value>
<Value name="8">
<Value>Gend</Value>
</Value>
<Value name="9">
<Value>Age</Value>
</Value>
<Value name="10">
<Value>AgeGroupDays</Value>
</Value>
<Value name="11">
<Value>NewBornFlag</Value>
</Value>
<Value name="12">
<Value>CertType</Value>
</Value>
<Value name="13">
<Value>CertNo</Value>
</Value>
<Value name="14">
<Value>EmprAddr</Value>
</Value>
<Value name="15">
<Value>Tel</Value>
</Value>
<Value name="16">
<Value>Department</Value>
</Value>
<Value name="17">
<Value>DepartmentDesc</Value>
</Value>
<Value name="18">
<Value>Doctor</Value>
</Value>
<Value name="19">
<Value>DoctorName</Value>
</Value>
<Value name="20">
<Value>mainDiagnosisCode</Value>
</Value>
<Value name="21">
<Value>mainDiagnosisDesc</Value>
</Value>
<Value name="22">
<Value>mainOperationCode</Value>
</Value>
<Value name="23">
<Value>mainOperationDesc</Value>
</Value>
<Value name="24">
<Value>InsuplcAdmdvs</Value>
</Value>
<Value name="25">
<Value>InsuplcAdmdvsDesc</Value>
</Value>
<Value name="26">
<Value>InsuType</Value>
</Value>
<Value name="27">
<Value>InsuTypeDesc</Value>
</Value>
<Value name="28">
<Value>HifPayWayName</Value>
</Value>
<Value name="29">
<Value>HifPayWayCode</Value>
</Value>
<Value name="30">
<Value>MedFeePaymtdName</Value>
</Value>
<Value name="31">
<Value>MedfeePaymtdCode</Value>
</Value>
<Value name="32">
<Value>SelfpayAmt</Value>
</Value>
<Value name="33">
<Value>MedfeeSumamt</Value>
</Value>
<Value name="34">
<Value>OrdnMedServfee</Value>
</Value>
<Value name="35">
<Value>OrdnTrtOprtFee</Value>
</Value>
<Value name="36">
<Value>NursFee</Value>
</Value>
<Value name="37">
<Value>ComMedServOthFee</Value>
</Value>
<Value name="38">
<Value>PalgDiagFee</Value>
</Value>
<Value name="39">
<Value>LabDiagFee</Value>
</Value>
<Value name="40">
<Value>RdhyDiagFee</Value>
</Value>
<Value name="41">
<Value>ClncDiseFee</Value>
</Value>
<Value name="42">
<Value>NsrgtrtItemFee</Value>
</Value>
<Value name="43">
<Value>ClncPhysTrtFee</Value>
</Value>
<Value name="44">
<Value>RgtrtTrtFee</Value>
</Value>
<Value name="45">
<Value>AnstFee</Value>
</Value>
<Value name="46">
<Value>RgtrtFee</Value>
</Value>
<Value name="47">
<Value>RhabFee</Value>
</Value>
<Value name="48">
<Value>TcmTrtFee</Value>
</Value>
<Value name="49">
<Value>WmFee</Value>
</Value>
<Value name="50">
<Value>AbtlMednFee</Value>
</Value>
<Value name="51">
<Value>TcmpatFee</Value>
</Value>
<Value name="52">
<Value>TcmherbFee</Value>
</Value>
<Value name="53">
<Value>BloFee</Value>
</Value>
<Value name="54">
<Value>AlbuFee</Value>
</Value>
<Value name="55">
<Value>GlonFee</Value>
</Value>
<Value name="56">
<Value>ClotfacFee</Value>
</Value>
<Value name="57">
<Value>CykiFee</Value>
</Value>
<Value name="58">
<Value>ExamDspoMatlFee</Value>
</Value>
<Value name="59">
<Value>TrtDspoMatlFee</Value>
</Value>
<Value name="60">
<Value>OprnDspoMatlFee</Value>
</Value>
<Value name="61">
<Value>OthFee</Value>
</Value>
<Value name="62">
<Value>BillCode</Value>
</Value>
<Value name="63">
<Value>BillNo</Value>
</Value>
<Value name="64">
<Value>BizSn</Value>
</Value>
<Value name="65">
<Value>HiPaymtd</Value>
</Value>
<Value name="66">
<Value>TotalAmt</Value>
</Value>
<Value name="67">
<Value>AdmDateTime</Value>
</Value>
<Value name="68">
<Value>DscgDateTime</Value>
</Value>
<Value name="69">
<Value>SettlementDateTime</Value>
</Value>
<Value name="70">
<Value>UpdateDateTime</Value>
</Value>
<Value name="71">
<Value>RespiratorTime</Value>
</Value>
<Value name="72">
<Value>ECMOFlag</Value>
</Value>
<Value name="73">
<Value>TransplantFlag</Value>
</Value>
<Value name="74">
<Value>MarrowTransplantFlag</Value>
</Value>
<Value name="75">
<Value>HIVFlag</Value>
</Value>
<Value name="76">
<Value>TraumaLevel</Value>
</Value>
<Value name="77">
<Value>IptDays</Value>
</Value>
<Value name="78">
<Value>FixmedinsCode</Value>
</Value>
<Value name="79">
<Value>FixmedinsName</Value>
</Value>
<Value name="80">
<Value>GroupStatus</Value>
</Value>
<Value name="81">
<Value>DRG</Value>
</Value>
<Value name="82">
<Value>DRGDesc</Value>
</Value>
<Value name="83">
<Value>FileType</Value>
</Value>
<Value name="84">
<Value>EMRFileInfo</Value>
</Value>
<Value name="85">
<Value>SettleFileInfo</Value>
</Value>
<Value name="86">
<Value>DiseInfo</Value>
</Value>
<Value name="87">
<Value>OprnInfo</Value>
</Value>
<Value name="88">
<Value>ICUInfo</Value>
</Value>
<Value name="89">
<Value>OpspDiseInfo</Value>
</Value>
<Value name="90">
<Value>BldInfo</Value>
</Value>
<Value name="91">
<Value>PayInfo</Value>
</Value>
<Value name="92">
<Value>ItemInfo</Value>
</Value>
<Value name="93">
<Value>Remark</Value>
</Value>
<Value name="94">
<Value>EMRFile</Value>
</Value>
<Value name="95">
<Value>SettleBillFile</Value>
</Value>
<Value name="96">
<Value>SettleID</Value>
</Value>
</Data>
<DataLocation>^BSDRGInteractionInfoD</DataLocation>
<DefaultData>BSDRGInteractionInfoDefaultData</DefaultData>
<IdLocation>^User.BSDRGInteractionInfoD</IdLocation>
<IndexLocation>^BSDRGInteractionInfoI</IndexLocation>
<StreamLocation>^BSDRGInteractionInfoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
