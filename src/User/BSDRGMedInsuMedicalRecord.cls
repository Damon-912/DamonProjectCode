Class User.BSDRGMedInsuMedicalRecord Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGMedInsuMedicalRecord ]
{

Parameter %JSONREFERENCE = "ID";

/// 就诊ID 
Property MdtrtId As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 2, SqlFieldName = MdtrtId ];

Index MdtrtId On MdtrtId;

/// 就医流水号 
Property MdtrtSn As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 3, SqlFieldName = MdtrtSn ];

Index MdtrtSn On MdtrtSn;

/// 人员编号 
Property PsnNo As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 4, SqlFieldName = PsnNo ];

Index PsnNo On PsnNo;

Index AdmIndex On (MdtrtSn, MdtrtId, PsnNo) [ Unique ];

/// 患者住院次数 
Property PatnIptCnt As %String [ SqlColumnNumber = 5, SqlFieldName = PatnIptCnt ];

/// 住院号 
Property IptOtpNo As %String(MAXLEN = 50) [ SqlColumnNumber = 6, SqlFieldName = IptOtpNo ];

/// 病案号 
Property MedcasNo As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 7, SqlFieldName = MedcasNo ];

/// 人员姓名 
Property PsnName As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 8, SqlFieldName = PsnName ];

/// 性别 
Property Gend As %String(MAXLEN = 50) [ SqlColumnNumber = 9, SqlFieldName = Gend ];

/// 出生日期 
Property Brdy As %String(MAXLEN = 50) [ SqlColumnNumber = 10, SqlFieldName = Brdy ];

/// 国籍
Property Ntly As %String(MAXLEN = 50) [ SqlColumnNumber = 11, SqlFieldName = Ntly ];

/// 国籍名称
Property NtlyName As %String [ SqlColumnNumber = 12, SqlFieldName = NtlyName ];

/// 新生儿出生体重
Property NwbBirWt As %String [ SqlColumnNumber = 13, SqlFieldName = NwbBirWt ];

/// 新生儿入院体重
Property NwbAdmWt As %String [ SqlColumnNumber = 14, SqlFieldName = NwbAdmWt ];

/// 出生地
Property Birplc As %String(MAXLEN = 500) [ SqlColumnNumber = 15, SqlFieldName = Birplc ];

/// 籍贯
Property Napl As %String [ SqlColumnNumber = 16, SqlFieldName = Napl ];

/// 民族名称
Property NatyName As %String [ SqlColumnNumber = 17, SqlFieldName = NatyName ];

/// 民族
Property Naty As %String [ SqlColumnNumber = 18, SqlFieldName = Naty ];

/// 证件号码
Property CertNo As %String [ SqlColumnNumber = 19, SqlFieldName = CertNo ];

/// 职业
Property Prfs As %String [ SqlColumnNumber = 20, SqlFieldName = Prfs ];

/// 婚姻状态
Property MrgStas As %String [ SqlColumnNumber = 21, SqlFieldName = MrgStas ];

/// 现住址-邮政编码
Property CurrAddrPoscode As %String [ SqlColumnNumber = 22, SqlFieldName = CurrAddrPoscode ];

/// 现住址
Property CurrAddr As %String(MAXLEN = 500) [ SqlColumnNumber = 23, SqlFieldName = CurrAddr ];

/// 个人联系电话
Property PsnTel As %String [ SqlColumnNumber = 24, SqlFieldName = PsnTel ];

/// 户口地址-省（自治区、直辖市）
Property ResdAddrProv As %String [ SqlColumnNumber = 25, SqlFieldName = ResdAddrProv ];

/// 户口地址-市（地区）
Property ResdAddrCity As %String [ SqlColumnNumber = 26, SqlFieldName = ResdAddrCity ];

/// 户口地址-县（区）
Property ResdAddrCoty As %String [ SqlColumnNumber = 27, SqlFieldName = ResdAddrCoty ];

/// 户口地址-乡（镇、街道办事处）
Property ResdAddrSubd As %String [ SqlColumnNumber = 28, SqlFieldName = ResdAddrSubd ];

/// 户口地址-村（街、路、弄等）
Property ResdAddrVil As %String [ SqlColumnNumber = 29, SqlFieldName = ResdAddrVil ];

/// 户口地址-门牌号码
Property ResdAddrHousnum As %String [ SqlColumnNumber = 30, SqlFieldName = ResdAddrHousnum ];

/// 户口地址- 邮政编码
Property ResdAddrPoscode As %String [ SqlColumnNumber = 31, SqlFieldName = ResdAddrPoscode ];

/// 户口地址
Property ResdAddr As %String(MAXLEN = 500) [ SqlColumnNumber = 32, SqlFieldName = ResdAddr ];

/// 工作单位联系电话
Property EmprTel As %String [ SqlColumnNumber = 33, SqlFieldName = EmprTel ];

/// 工作单位- 邮政编码
Property EmprPoscode As %String [ SqlColumnNumber = 34, SqlFieldName = EmprPoscode ];

/// 工作单位及地址
Property EmprAddr As %String(MAXLEN = 500) [ SqlColumnNumber = 35, SqlFieldName = EmprAddr ];

/// 联系人电话
Property ConerTel As %String [ SqlColumnNumber = 36, SqlFieldName = ConerTel ];

/// 联系人姓名
Property ConerName As %String [ SqlColumnNumber = 37, SqlFieldName = ConerName ];

/// 联系人地址
Property ConerAddr As %String [ SqlColumnNumber = 38, SqlFieldName = ConerAddr ];

/// 与联系人关系代码
Property ConerRltsCode As %String [ SqlColumnNumber = 39, SqlFieldName = ConerRltsCode ];

/// 入院途径名称
Property AdmWayName As %String [ SqlColumnNumber = 40, SqlFieldName = AdmWayName ];

/// 入院途径代码
Property AdmWayCode As %String [ SqlColumnNumber = 41, SqlFieldName = AdmWayCode ];

/// 治疗类别名称
Property TrtTypeName As %String [ SqlColumnNumber = 42, SqlFieldName = TrtTypeName ];

/// 治疗类别
Property TrtType As %String [ SqlColumnNumber = 43, SqlFieldName = TrtType ];

/// 入院科别
Property AdmCaty As %String [ SqlColumnNumber = 44, SqlFieldName = AdmCaty ];

/// 入院病房
Property AdmWard As %String [ SqlColumnNumber = 45, SqlFieldName = AdmWard ];

/// 入院日期
Property AdmDate As %DateTime [ SqlColumnNumber = 46, SqlFieldName = AdmDate ];

/// 出院日期
Property DscgDate As %DateTime [ SqlColumnNumber = 47, SqlFieldName = DscgDate ];

/// 出院科别
Property DscgCaty As %String [ SqlColumnNumber = 48, SqlFieldName = DscgCaty ];

/// 转科科别名称
Property RefldeptCatyName As %String [ SqlColumnNumber = 49, SqlFieldName = RefldeptCatyName ];

/// 出院病房
Property DscgWard As %String [ SqlColumnNumber = 50, SqlFieldName = DscgWard ];

/// 住院天数
Property IptDays As %String [ SqlColumnNumber = 51, SqlFieldName = IptDays ];

/// 药物过敏标志
Property DrugDicmFlag As %String [ SqlColumnNumber = 52, SqlFieldName = DrugDicmFlag ];

/// 过敏药物名称
Property DicmDrugName As %String [ SqlColumnNumber = 53, SqlFieldName = DicmDrugName ];

/// 死亡患者尸检标志
Property DieAutpFlag As %String [ SqlColumnNumber = 54, SqlFieldName = DieAutpFlag ];

/// ABO血型代码
Property AboCode As %String [ SqlColumnNumber = 55, SqlFieldName = AboCode ];

/// ABO血型名称
Property AboName As %String [ SqlColumnNumber = 56, SqlFieldName = AboName ];

/// Rh血型代码
Property RhCode As %String [ SqlColumnNumber = 57, SqlFieldName = RhCode ];

/// RH血型
Property RhName As %String [ SqlColumnNumber = 58, SqlFieldName = RhName ];

/// 死亡标志
Property DieFlag As %String [ SqlColumnNumber = 59, SqlFieldName = DieFlag ];

/// 科主任姓名
Property DeptdrtName As %String [ SqlColumnNumber = 60, SqlFieldName = DeptdrtName ];

/// 主任( 副主任)医师姓名
Property ChfdrName As %String [ SqlColumnNumber = 61, SqlFieldName = ChfdrName ];

/// 主治医生姓名
Property AtddrName As %String [ SqlColumnNumber = 62, SqlFieldName = AtddrName ];

/// 主诊医师姓名
Property ChfpdrName As %String [ SqlColumnNumber = 63, SqlFieldName = ChfpdrName ];

/// 住院医师姓名
Property IptDrName As %String [ SqlColumnNumber = 64, SqlFieldName = IptDrName ];

/// 责任护士姓名
Property RespNursName As %String [ SqlColumnNumber = 65, SqlFieldName = RespNursName ];

/// 进修医师姓名
Property TrainDrName As %String [ SqlColumnNumber = 66, SqlFieldName = TrainDrName ];

/// 实习医师姓名
Property IntnDrName As %String [ SqlColumnNumber = 67, SqlFieldName = IntnDrName ];

/// 编码员姓名
Property CodrName As %String [ SqlColumnNumber = 68, SqlFieldName = CodrName ];

/// 质控医师姓名
Property QltctrlDrName As %String [ SqlColumnNumber = 69, SqlFieldName = QltctrlDrName ];

/// 质控护士姓名
Property QltctrlNursName As %String [ SqlColumnNumber = 70, SqlFieldName = QltctrlNursName ];

/// 病案质量名称
Property MedcasQltName As %String [ SqlColumnNumber = 71, SqlFieldName = MedcasQltName ];

/// 病案质量代码
Property MedcasQltCode As %String [ SqlColumnNumber = 72, SqlFieldName = MedcasQltCode ];

/// 质控日期
Property QltctrlDate As %String [ SqlColumnNumber = 73, SqlFieldName = QltctrlDate ];

/// 离院方式名称
Property DscgWayName As %String [ SqlColumnNumber = 74, SqlFieldName = DscgWayName ];

/// 离院方式
Property DscgWay As %String [ SqlColumnNumber = 75, SqlFieldName = DscgWay ];

/// 拟接收医疗机构代码
Property AcpMedinsCode As %String [ SqlColumnNumber = 76, SqlFieldName = AcpMedinsCode ];

/// 拟接收医疗机构名称
Property AcpMedinsName As %String [ SqlColumnNumber = 77, SqlFieldName = AcpMedinsName ];

/// 出院 31天内再住院计划标志
Property Dscg31daysRinpFlag As %String [ SqlColumnNumber = 78, SqlFieldName = Dscg31daysRinpFlag ];

/// 出院31天内再住院目的
Property Dscg31daysRinpPup As %String [ SqlColumnNumber = 79, SqlFieldName = Dscg31daysRinpPup ];

/// 损伤、中毒的外部原因
Property DamgIntxExtRea As %String [ SqlColumnNumber = 80, SqlFieldName = DamgIntxExtRea ];

/// 损伤、中毒的外部原因疾病编码
Property DamgIntxExtReaDisecode As %String [ SqlColumnNumber = 81, SqlFieldName = DamgIntxExtReaDisecode ];

/// 颅脑损伤患者入院前昏迷时长
Property BrnDamgBfadmComaDura As %String [ SqlColumnNumber = 82, SqlFieldName = BrnDamgBfadmComaDura ];

/// 颅脑损伤患者入院后昏迷时长
Property BrnDamgAfadmComaDura As %String [ SqlColumnNumber = 83, SqlFieldName = BrnDamgAfadmComaDura ];

/// 呼吸机使用时长
Property VentUsedDura As %String [ SqlColumnNumber = 84, SqlFieldName = VentUsedDura ];

/// 确诊日期
Property CnfmDate As %String [ SqlColumnNumber = 85, SqlFieldName = CnfmDate ];

/// 患者疾病诊断对照
Property PatnDiseDiagCrsp As %String [ SqlColumnNumber = 86, SqlFieldName = PatnDiseDiagCrsp ];

/// 住院患者疾病诊断对照代码
Property PatnDiseDiagCrspCode As %String [ SqlColumnNumber = 87, SqlFieldName = PatnDiseDiagCrspCode ];

/// 住院患者诊断符合情况
Property IptPatnDiagInscp As %String [ SqlColumnNumber = 88, SqlFieldName = IptPatnDiagInscp ];

/// 住院患者诊断符合情况代码
Property IptPatnDiagInscpCode As %String [ SqlColumnNumber = 89, SqlFieldName = IptPatnDiagInscpCode ];

/// 出院治疗结果
Property DscgTrtRslt As %String [ SqlColumnNumber = 90, SqlFieldName = DscgTrtRslt ];

/// 出院治疗结果代码
Property DscgTrtRsltCode As %String [ SqlColumnNumber = 91, SqlFieldName = DscgTrtRsltCode ];

/// 医疗机构组织机构代码
Property MedinsOrgcode As %String [ SqlColumnNumber = 92, SqlFieldName = MedinsOrgcode ];

/// 年龄
Property Age As %String [ SqlColumnNumber = 93, SqlFieldName = Age ];

/// 过敏源
Property Aise As %String [ SqlColumnNumber = 94, SqlFieldName = Aise ];

/// 研究生实习医师姓名
Property PoteIntnDrName As %String [ SqlColumnNumber = 95, SqlFieldName = PoteIntnDrName ];

/// 乙肝表面抗原（HBsAg）
Property Hbsag As %String [ SqlColumnNumber = 96, SqlFieldName = Hbsag ];

/// 丙型肝炎抗体（HCV-Ab）
Property HcvAb As %String [ SqlColumnNumber = 97, SqlFieldName = HcvAb ];

/// 抢救次数
Property RescCnt As %String [ SqlColumnNumber = 98, SqlFieldName = RescCnt ];

/// 抢救成功次数
Property RescSuccCnt As %String [ SqlColumnNumber = 99, SqlFieldName = RescSuccCnt ];

/// 手术、治疗、检查、诊断为本院第一例
Property HospDiseFsttime As %String [ SqlColumnNumber = 100, SqlFieldName = HospDiseFsttime ];

/// 医保基金付费方式名称
Property HifPayWayName As %String [ SqlColumnNumber = 101, SqlFieldName = HifPayWayName ];

/// 医保基金付费方式代码
Property HifPayWayCode As %String [ SqlColumnNumber = 102, SqlFieldName = HifPayWayCode ];

/// 医疗费用支付方式名称
Property MedFeePaymtdName As %String [ SqlColumnNumber = 103, SqlFieldName = MedFeePaymtdName ];

/// 医疗费用支付方式代码
Property MedfeePaymtdCode As %String [ SqlColumnNumber = 104, SqlFieldName = MedfeePaymtdCode ];

/// 自付金额
Property SelfpayAmt As %String [ SqlColumnNumber = 105, SqlFieldName = SelfpayAmt ];

/// 医疗费总额
Property MedfeeSumamt As %String [ SqlColumnNumber = 106, SqlFieldName = MedfeeSumamt ];

/// 一般医疗服务费
Property OrdnMedServfee As %String [ SqlColumnNumber = 107, SqlFieldName = OrdnMedServfee ];

/// 一般治疗操作费
Property OrdnTrtOprtFee As %String [ SqlColumnNumber = 108, SqlFieldName = OrdnTrtOprtFee ];

/// 护理费
Property NursFee As %String [ SqlColumnNumber = 109, SqlFieldName = NursFee ];

/// 综合医疗服务类其他费用
Property ComMedServOthFee As %String [ SqlColumnNumber = 110, SqlFieldName = ComMedServOthFee ];

/// 病理诊断费
Property PalgDiagFee As %String [ SqlColumnNumber = 111, SqlFieldName = PalgDiagFee ];

/// 实验室诊断费
Property LabDiagFee As %String [ SqlColumnNumber = 112, SqlFieldName = LabDiagFee ];

/// 影像学诊断费
Property RdhyDiagFee As %String [ SqlColumnNumber = 113, SqlFieldName = RdhyDiagFee ];

/// 临床诊断项目费
Property ClncDiseFee As %String [ SqlColumnNumber = 114, SqlFieldName = ClncDiseFee ];

/// 非手术治疗项目费
Property NsrgtrtItemFee As %String [ SqlColumnNumber = 115, SqlFieldName = NsrgtrtItemFee ];

/// 临床物理治疗费
Property ClncPhysTrtFee As %String [ SqlColumnNumber = 116, SqlFieldName = ClncPhysTrtFee ];

/// 手术治疗费
Property RgtrtTrtFee As %String [ SqlColumnNumber = 117, SqlFieldName = RgtrtTrtFee ];

/// 麻醉费
Property AnstFee As %String [ SqlColumnNumber = 118, SqlFieldName = AnstFee ];

/// 手术费
Property RgtrtFee As %String [ SqlColumnNumber = 119, SqlFieldName = RgtrtFee ];

/// 康复费
Property RhabFee As %String [ SqlColumnNumber = 120, SqlFieldName = RhabFee ];

/// 中医治疗费
Property TcmTrtFee As %String [ SqlColumnNumber = 121, SqlFieldName = TcmTrtFee ];

/// 西药费
Property WmFee As %String [ SqlColumnNumber = 122, SqlFieldName = WmFee ];

/// 抗菌药物费用
Property AbtlMednFee As %String [ SqlColumnNumber = 123, SqlFieldName = AbtlMednFee ];

/// 中成药费
Property TcmpatFee As %String [ SqlColumnNumber = 124, SqlFieldName = TcmpatFee ];

/// 中药饮片费
Property TcmherbFee As %String [ SqlColumnNumber = 125, SqlFieldName = TcmherbFee ];

/// 血费
Property BloFee As %String [ SqlColumnNumber = 126, SqlFieldName = BloFee ];

/// 白蛋白类制品费
Property AlbuFee As %String [ SqlColumnNumber = 127, SqlFieldName = AlbuFee ];

/// 球蛋白类制品费
Property GlonFee As %String [ SqlColumnNumber = 128, SqlFieldName = GlonFee ];

/// 凝血因子类制品费
Property ClotfacFee As %String [ SqlColumnNumber = 129, SqlFieldName = ClotfacFee ];

/// 细胞因子类制品费
Property CykiFee As %String [ SqlColumnNumber = 130, SqlFieldName = CykiFee ];

/// 检查用一次性医用材料费
Property ExamDspoMatlFee As %String [ SqlColumnNumber = 131, SqlFieldName = ExamDspoMatlFee ];

/// 治疗用一次性医用材料费
Property TrtDspoMatlFee As %String [ SqlColumnNumber = 132, SqlFieldName = TrtDspoMatlFee ];

/// 手术用一次性医用材料费
Property OprnDspoMatlFee As %String [ SqlColumnNumber = 133, SqlFieldName = OprnDspoMatlFee ];

/// 其他费
Property OthFee As %String [ SqlColumnNumber = 134, SqlFieldName = OthFee ];

/// 艾滋病毒抗体（HIV-Ab）
Property HivAb As %String [ SqlColumnNumber = 135, SqlFieldName = HivAb ];

/// 有效标志
Property ValiFlag As %String [ SqlColumnNumber = 136, SqlFieldName = ValiFlag ];

/// 定点医药机构编号
Property FixmedinsCode As %String [ SqlColumnNumber = 137, SqlFieldName = FixmedinsCode ];

/// 门诊中医诊断代码
Property CmDiagnoseCode As %String [ SqlColumnNumber = 138, SqlFieldName = CmDiagnoseCode ];

/// 门诊中医诊断
Property MzcmDiagnose As %String [ SqlColumnNumber = 139, SqlFieldName = MzcmDiagnose ];

/// 诊断信息
Property DiseInfo As %String(MAXLEN = 99999) [ SqlColumnNumber = 140, SqlFieldName = DiseInfo ];

/// 手术及操作信息
Property OprnInfo As %String(MAXLEN = 99999) [ SqlColumnNumber = 141, SqlFieldName = OprnInfo ];

/// 重症监护信息
Property ICUInfo As %String(MAXLEN = 99999) [ SqlColumnNumber = 142, SqlFieldName = ICUInfo ];

/// HIS返回结果
Property HISReturn As %String(MAXLEN = 99999) [ SqlColumnNumber = 143, SqlFieldName = HISReturn ];

/// 数据更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 144, SqlFieldName = UpdateDate ];

/// 数据更新时间
Property UpdateTime As %DateTime [ SqlColumnNumber = 145, SqlFieldName = UpdateTime ];

/// DRG分组结果
Property DRG As %String [ SqlColumnNumber = 146, SqlFieldName = DRG ];

/// HIS就诊流水号
Property HISAdmID As %String [ SqlColumnNumber = 147, SqlFieldName = HISAdmID ];

Index HISAdmID On HISAdmID;

Index HISAdmIndex On (MdtrtSn, MdtrtId, PsnNo, HISAdmID, MedcasNo) [ Unique ];

Storage Default
{
<Data name="BSDRGMedInsuMedicalRecordDefaultData">
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
<Value>PsnNo</Value>
</Value>
<Value name="5">
<Value>PatnIptCnt</Value>
</Value>
<Value name="6">
<Value>IptNo</Value>
</Value>
<Value name="7">
<Value>MedcasNo</Value>
</Value>
<Value name="8">
<Value>PsnName</Value>
</Value>
<Value name="9">
<Value>Gend</Value>
</Value>
<Value name="10">
<Value>Brdy</Value>
</Value>
<Value name="11">
<Value>Ntly</Value>
</Value>
<Value name="12">
<Value>NtlyName</Value>
</Value>
<Value name="13">
<Value>NwbBirWt</Value>
</Value>
<Value name="14">
<Value>NwbAdmWt</Value>
</Value>
<Value name="15">
<Value>Birplc</Value>
</Value>
<Value name="16">
<Value>Napl</Value>
</Value>
<Value name="17">
<Value>NatyName</Value>
</Value>
<Value name="18">
<Value>Naty</Value>
</Value>
<Value name="19">
<Value>Certno</Value>
</Value>
<Value name="20">
<Value>Prfs</Value>
</Value>
<Value name="21">
<Value>MrgStas</Value>
</Value>
<Value name="22">
<Value>CurrAddrPoscode</Value>
</Value>
<Value name="23">
<Value>CurrAddr</Value>
</Value>
<Value name="24">
<Value>PsnTel</Value>
</Value>
<Value name="25">
<Value>ResdAddrProv</Value>
</Value>
<Value name="26">
<Value>ResdAddrCity</Value>
</Value>
<Value name="27">
<Value>ResdAddrCoty</Value>
</Value>
<Value name="28">
<Value>ResdAddrSubd</Value>
</Value>
<Value name="29">
<Value>ResdAddrVil</Value>
</Value>
<Value name="30">
<Value>ResdAddrHousnum</Value>
</Value>
<Value name="31">
<Value>ResdAddrPoscode</Value>
</Value>
<Value name="32">
<Value>ResdAddr</Value>
</Value>
<Value name="33">
<Value>EmprTel</Value>
</Value>
<Value name="34">
<Value>EmprPoscode</Value>
</Value>
<Value name="35">
<Value>EmprAddr</Value>
</Value>
<Value name="36">
<Value>ConerTel</Value>
</Value>
<Value name="37">
<Value>ConerName</Value>
</Value>
<Value name="38">
<Value>ConerAddr</Value>
</Value>
<Value name="39">
<Value>ConerRltsCode</Value>
</Value>
<Value name="40">
<Value>AdmWayName</Value>
</Value>
<Value name="41">
<Value>AdmWayCode</Value>
</Value>
<Value name="42">
<Value>TrtTypeName</Value>
</Value>
<Value name="43">
<Value>TrtType</Value>
</Value>
<Value name="44">
<Value>AdmCaty</Value>
</Value>
<Value name="45">
<Value>AdmWard</Value>
</Value>
<Value name="46">
<Value>AdmDate</Value>
</Value>
<Value name="47">
<Value>DscgDate</Value>
</Value>
<Value name="48">
<Value>DscgCaty</Value>
</Value>
<Value name="49">
<Value>RefldeptCatyName</Value>
</Value>
<Value name="50">
<Value>DscgWard</Value>
</Value>
<Value name="51">
<Value>IptDays</Value>
</Value>
<Value name="52">
<Value>DrugDicmFlag</Value>
</Value>
<Value name="53">
<Value>DicmDrugName</Value>
</Value>
<Value name="54">
<Value>DieAutpFlag</Value>
</Value>
<Value name="55">
<Value>AboCode</Value>
</Value>
<Value name="56">
<Value>AboName</Value>
</Value>
<Value name="57">
<Value>RhCode</Value>
</Value>
<Value name="58">
<Value>RhName</Value>
</Value>
<Value name="59">
<Value>DieFlag</Value>
</Value>
<Value name="60">
<Value>DeptdrtName</Value>
</Value>
<Value name="61">
<Value>ChfdrName</Value>
</Value>
<Value name="62">
<Value>AtddrName</Value>
</Value>
<Value name="63">
<Value>ChfpdrName</Value>
</Value>
<Value name="64">
<Value>IptDrName</Value>
</Value>
<Value name="65">
<Value>RespNursName</Value>
</Value>
<Value name="66">
<Value>TrainDrName</Value>
</Value>
<Value name="67">
<Value>IntnDrName</Value>
</Value>
<Value name="68">
<Value>CodrName</Value>
</Value>
<Value name="69">
<Value>QltctrlDrName</Value>
</Value>
<Value name="70">
<Value>QltctrlNursName</Value>
</Value>
<Value name="71">
<Value>MedcasQltName</Value>
</Value>
<Value name="72">
<Value>MedcasQltCode</Value>
</Value>
<Value name="73">
<Value>QltctrlDate</Value>
</Value>
<Value name="74">
<Value>DscgWayName</Value>
</Value>
<Value name="75">
<Value>DscgWay</Value>
</Value>
<Value name="76">
<Value>AcpMedinsCode</Value>
</Value>
<Value name="77">
<Value>AcpMedinsName</Value>
</Value>
<Value name="78">
<Value>Dscg31daysRinpFlag</Value>
</Value>
<Value name="79">
<Value>Dscg31daysRinpPup</Value>
</Value>
<Value name="80">
<Value>DamgIntxExtRea</Value>
</Value>
<Value name="81">
<Value>DamgIntxExtReaDisecode</Value>
</Value>
<Value name="82">
<Value>BrnDamgBfadmComaDura</Value>
</Value>
<Value name="83">
<Value>BrnDamgAfadmComaDura</Value>
</Value>
<Value name="84">
<Value>VentUsedDura</Value>
</Value>
<Value name="85">
<Value>CnfmDate</Value>
</Value>
<Value name="86">
<Value>PatnDiseDiagCrsp</Value>
</Value>
<Value name="87">
<Value>PatnDiseDiagCrspCode</Value>
</Value>
<Value name="88">
<Value>IptPatnDiagInscp</Value>
</Value>
<Value name="89">
<Value>IptPatnDiagInscpCode</Value>
</Value>
<Value name="90">
<Value>DscgTrtRslt</Value>
</Value>
<Value name="91">
<Value>DscgTrtRsltCode</Value>
</Value>
<Value name="92">
<Value>MedinsOrgcode</Value>
</Value>
<Value name="93">
<Value>Age</Value>
</Value>
<Value name="94">
<Value>Aise</Value>
</Value>
<Value name="95">
<Value>PoteIntnDrName</Value>
</Value>
<Value name="96">
<Value>Hbsag</Value>
</Value>
<Value name="97">
<Value>HcvAb</Value>
</Value>
<Value name="98">
<Value>RescCnt</Value>
</Value>
<Value name="99">
<Value>RescSuccCnt</Value>
</Value>
<Value name="100">
<Value>HospDiseFsttime</Value>
</Value>
<Value name="101">
<Value>HifPayWayName</Value>
</Value>
<Value name="102">
<Value>HifPayWayCode</Value>
</Value>
<Value name="103">
<Value>MedFeePaymtdName</Value>
</Value>
<Value name="104">
<Value>MedfeePaymtdCode</Value>
</Value>
<Value name="105">
<Value>SelfpayAmt</Value>
</Value>
<Value name="106">
<Value>MedfeeSumamt</Value>
</Value>
<Value name="107">
<Value>OrdnMedServfee</Value>
</Value>
<Value name="108">
<Value>OrdnTrtOprtFee</Value>
</Value>
<Value name="109">
<Value>NursFee</Value>
</Value>
<Value name="110">
<Value>ComMedServOthFee</Value>
</Value>
<Value name="111">
<Value>PalgDiagFee</Value>
</Value>
<Value name="112">
<Value>LabDiagFee</Value>
</Value>
<Value name="113">
<Value>RdhyDiagFee</Value>
</Value>
<Value name="114">
<Value>ClncDiseFee</Value>
</Value>
<Value name="115">
<Value>NsrgtrtItemFee</Value>
</Value>
<Value name="116">
<Value>ClncPhysTrtFee</Value>
</Value>
<Value name="117">
<Value>RgtrtTrtFee</Value>
</Value>
<Value name="118">
<Value>AnstFee</Value>
</Value>
<Value name="119">
<Value>RgtrtFee</Value>
</Value>
<Value name="120">
<Value>RhabFee</Value>
</Value>
<Value name="121">
<Value>TcmTrtFee</Value>
</Value>
<Value name="122">
<Value>WmFee</Value>
</Value>
<Value name="123">
<Value>AbtlMednFee</Value>
</Value>
<Value name="124">
<Value>TcmpatFee</Value>
</Value>
<Value name="125">
<Value>TcmherbFee</Value>
</Value>
<Value name="126">
<Value>BloFee</Value>
</Value>
<Value name="127">
<Value>AlbuFee</Value>
</Value>
<Value name="128">
<Value>GlonFee</Value>
</Value>
<Value name="129">
<Value>ClotfacFee</Value>
</Value>
<Value name="130">
<Value>CykiFee</Value>
</Value>
<Value name="131">
<Value>ExamDspoMatlFee</Value>
</Value>
<Value name="132">
<Value>TrtDspoMatlFee</Value>
</Value>
<Value name="133">
<Value>OprnDspoMatlFee</Value>
</Value>
<Value name="134">
<Value>OthFee</Value>
</Value>
<Value name="135">
<Value>valiFlag</Value>
</Value>
<Value name="136">
<Value>FixmedinsCode</Value>
</Value>
<Value name="137">
<Value>Diseinfo</Value>
</Value>
<Value name="138">
<Value>OprnInfo</Value>
</Value>
<Value name="139">
<Value>IcuInfo</Value>
</Value>
<Value name="140">
<Value>HISReturn</Value>
</Value>
<Value name="141">
<Value>UpdateTime</Value>
</Value>
<Value name="142">
<Value>DRG</Value>
</Value>
<Value name="143">
<Value>HISAdmID</Value>
</Value>
<Value name="144">
<Value>UpdateDate</Value>
</Value>
<Value name="145">
<Value>IptOtpNo</Value>
</Value>
<Value name="146">
<Value>HivAb</Value>
</Value>
<Value name="147">
<Value>CmDiagnoseCode</Value>
</Value>
<Value name="148">
<Value>MzcmDiagnose</Value>
</Value>
<Value name="149">
<Value>ValiFlag</Value>
</Value>
<Value name="150">
<Value>DiseinfoDr</Value>
</Value>
<Value name="151">
<Value>OprnInfoDr</Value>
</Value>
<Value name="152">
<Value>IcuInfoDr</Value>
</Value>
<Value name="153">
<Value>DiseInfo</Value>
</Value>
<Value name="154">
<Value>ICUInfo</Value>
</Value>
<Value name="155">
<Value>CertNo</Value>
</Value>
</Data>
<DataLocation>^BSDRGMedInsF2C8D</DataLocation>
<DefaultData>BSDRGMedInsuMedicalRecordDefaultData</DefaultData>
<IdLocation>^BSDRGMedInsF2C8D</IdLocation>
<IndexLocation>^BSDRGMedInsF2C8I</IndexLocation>
<StreamLocation>^BSDRGMedInsF2C8S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
