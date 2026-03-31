Class User.BSDRGPatientOperation Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGPatientOperation ]
{

Parameter %JSONREFERENCE = "ID";

/// 医保就诊ID 
Property MdtrtId As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 2, SqlFieldName = MdtrtId ];

Index MdtrtId On MdtrtId;

/// 就医流水号 
Property MdtrtSn As %String(COLLATION = "UPPER", MAXLEN = 50) [ SqlColumnNumber = 3, SqlFieldName = MdtrtSn ];

Index MdtrtSn On MdtrtSn;

/// 住院病案首页流水号 
Property IptMedcasHmpgSn As %String [ Required, SqlColumnNumber = 4, SqlFieldName = IptMedcasHmpgSn ];

/// 手术操作日期 
Property OprnOprtDate As %String [ SqlColumnNumber = 5, SqlFieldName = OprnOprtDate ];

/// 手术操作名称 
Property OprnOprtName As %String [ SqlColumnNumber = 6, SqlFieldName = OprnOprtName ];

/// 手术操作代码 
Property OprnOprtCode As %String [ SqlColumnNumber = 7, SqlFieldName = OprnOprtCode ];

Index OprnOprtCode On OprnOprtCode;

/// 手术操作序列号 
Property OprnOprtSn As %String [ SqlColumnNumber = 8, SqlFieldName = OprnOprtSn ];

Index OprnOprtSn On (MdtrtId, MdtrtSn, OprnOprtCode, OprnOprtSn) [ Unique ];

/// 手术级别代码 
Property OprnLvCode As %String [ SqlColumnNumber = 9, SqlFieldName = OprnLvCode ];

/// 手术级别名称 
Property OprnLvName As %String [ SqlColumnNumber = 10, SqlFieldName = OprnLvName ];

/// 手术者姓名 
Property OperName As %String [ SqlColumnNumber = 11, SqlFieldName = OperName ];

/// 助手Ⅰ姓名 
Property Asit1Name As %String [ SqlColumnNumber = 12, SqlFieldName = Asit1Name ];

/// 助手Ⅱ姓名 
Property AsitName2 As %String [ SqlColumnNumber = 13, SqlFieldName = AsitName2 ];

/// 手术切口愈合等级 
Property SincHealLv As %String [ SqlColumnNumber = 14, SqlFieldName = SincHealLv ];

/// 手术切口愈合等级代码 
Property SincHealLvCode As %String [ SqlColumnNumber = 15, SqlFieldName = SincHealLvCode ];

/// 麻醉-方法名称 
Property AnstMtdName As %String [ SqlColumnNumber = 16, SqlFieldName = AnstMtdName ];

/// 麻醉-方法代码 
Property AnstMtdCode As %String [ SqlColumnNumber = 17, SqlFieldName = AnstMtdCode ];

/// 麻醉医师姓名 
Property AnstDrName As %String [ SqlColumnNumber = 18, SqlFieldName = AnstDrName ];

/// 手术操作部位 
Property OprnOperPart As %String [ SqlColumnNumber = 19, SqlFieldName = OprnOperPart ];

/// 手术操作部位代码 
Property OprnOperPartCode As %String [ SqlColumnNumber = 20, SqlFieldName = OprnOperPartCode ];

/// 手术持续时间 
Property OprnConTime As %String [ SqlColumnNumber = 21, SqlFieldName = OprnConTime ];

/// 麻醉分级名称 
Property AnstLvName As %String [ SqlColumnNumber = 22, SqlFieldName = AnstLvName ];

/// 麻醉分级代码 
Property AnstLvCode As %String [ SqlColumnNumber = 23, SqlFieldName = AnstLvCode ];

/// 手术患者类型 
Property OprnPatnType As %String [ SqlColumnNumber = 24, SqlFieldName = OprnPatnType ];

/// 手术患者类型代码 
Property OprnPatnTypeCode As %String [ SqlColumnNumber = 25, SqlFieldName = OprnPatnTypeCode ];

/// 主要手术标志 
Property MainOprnFlag As %String [ SqlColumnNumber = 26, SqlFieldName = MainOprnFlag ];

/// 麻醉ASA分级代码 
Property AnstAsaLvCode As %String [ SqlColumnNumber = 27, SqlFieldName = AnstAsaLvCode ];

/// 麻醉ASA分级名称 
Property AnstAsaLvName As %String [ SqlColumnNumber = 28, SqlFieldName = AnstAsaLvName ];

/// 麻醉药物代码 
Property AnstMednCode As %String [ SqlColumnNumber = 29, SqlFieldName = AnstMednCode ];

/// 麻醉药物名称 
Property AnstMednName As %String [ SqlColumnNumber = 30, SqlFieldName = AnstMednName ];

/// 麻醉药物剂量 
Property AnstMednDos As %String [ SqlColumnNumber = 31, SqlFieldName = AnstMednDos ];

/// 计量单位 
Property Unt As %String [ SqlColumnNumber = 32, SqlFieldName = Unt ];

/// 麻醉开始时间 
Property AnstBegnTime As %String [ SqlColumnNumber = 33, SqlFieldName = AnstBegnTime ];

/// 麻醉结束时间 
Property AnstEndTime As %String [ SqlColumnNumber = 34, SqlFieldName = AnstEndTime ];

/// 麻醉合并症代码 
Property AnstCopnCode As %String [ SqlColumnNumber = 35, SqlFieldName = AnstCopnCode ];

/// 麻醉合并症名称 
Property AnstCopnName As %String [ SqlColumnNumber = 36, SqlFieldName = AnstCopnName ];

/// 麻醉合并症描述 
Property AnstCopnDscr As %String [ SqlColumnNumber = 37, SqlFieldName = AnstCopnDscr ];

/// 复苏室开始时间 
Property PacuBegnTime As %String [ SqlColumnNumber = 38, SqlFieldName = PacuBegnTime ];

/// 复苏室结束时间 
Property PacuEndTime As %String [ SqlColumnNumber = 39, SqlFieldName = PacuEndTime ];

/// 取消手术标志 
Property CancOprnFlag As %String [ SqlColumnNumber = 40, SqlFieldName = CancOprnFlag ];

/// 有效标志 
Property ValiFlag As %String [ SqlColumnNumber = 41, SqlFieldName = ValiFlag ];

/// HIS就诊流水号 
Property HISAdmID As %String [ SqlColumnNumber = 42, SqlFieldName = HISAdmID ];

/// 数据更新时间
Property UpdateTime As %DateTime [ SqlColumnNumber = 43, SqlFieldName = UpdateTime ];

Storage Default
{
<Data name="BSDRGPatientOperationDefaultData">
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
<Value>OprnOprtDate</Value>
</Value>
<Value name="6">
<Value>OprnOprtName</Value>
</Value>
<Value name="7">
<Value>OprnOprtCode</Value>
</Value>
<Value name="8">
<Value>OprnOprtSn</Value>
</Value>
<Value name="9">
<Value>OprnLvCode</Value>
</Value>
<Value name="10">
<Value>OprnLvName</Value>
</Value>
<Value name="11">
<Value>OperName</Value>
</Value>
<Value name="12">
<Value>Asit1Name</Value>
</Value>
<Value name="13">
<Value>AsitName2</Value>
</Value>
<Value name="14">
<Value>SincHealLv</Value>
</Value>
<Value name="15">
<Value>SincHealLvCode</Value>
</Value>
<Value name="16">
<Value>AnstMtdName</Value>
</Value>
<Value name="17">
<Value>AnstMtdCode</Value>
</Value>
<Value name="18">
<Value>AnstDrName</Value>
</Value>
<Value name="19">
<Value>OprnOperPart</Value>
</Value>
<Value name="20">
<Value>OprnOperPartCode</Value>
</Value>
<Value name="21">
<Value>OprnConTime</Value>
</Value>
<Value name="22">
<Value>AnstLvName</Value>
</Value>
<Value name="23">
<Value>AnstLvCode</Value>
</Value>
<Value name="24">
<Value>OprnPatnType</Value>
</Value>
<Value name="25">
<Value>OprnPatnTypeCode</Value>
</Value>
<Value name="26">
<Value>MainOprnFlag</Value>
</Value>
<Value name="27">
<Value>AnstAsaLvCode</Value>
</Value>
<Value name="28">
<Value>AnstAsaLvName</Value>
</Value>
<Value name="29">
<Value>AnstMednCode</Value>
</Value>
<Value name="30">
<Value>AnstMednName</Value>
</Value>
<Value name="31">
<Value>AnstMednDos</Value>
</Value>
<Value name="32">
<Value>Unt</Value>
</Value>
<Value name="33">
<Value>AnstBegnTime</Value>
</Value>
<Value name="34">
<Value>AnstEndTime</Value>
</Value>
<Value name="35">
<Value>AnstCopnCode</Value>
</Value>
<Value name="36">
<Value>AnstCopnName</Value>
</Value>
<Value name="37">
<Value>AnstCopnDscr</Value>
</Value>
<Value name="38">
<Value>PacuBegnTime</Value>
</Value>
<Value name="39">
<Value>PacuEndTime</Value>
</Value>
<Value name="40">
<Value>CancOprnFlag</Value>
</Value>
<Value name="41">
<Value>ValiFlag</Value>
</Value>
<Value name="42">
<Value>HISAdmID</Value>
</Value>
<Value name="43">
<Value>UpdateTime</Value>
</Value>
</Data>
<DataLocation>^BSDRGPatientOperationD</DataLocation>
<DefaultData>BSDRGPatientOperationDefaultData</DefaultData>
<IdLocation>^BSDRGPatientOperationD</IdLocation>
<IndexLocation>^BSDRGPatientOperationI</IndexLocation>
<StreamLocation>^BSDRGPatientOperationS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
