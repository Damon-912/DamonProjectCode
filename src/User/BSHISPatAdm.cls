/// HIS患者入院信息表
Class User.BSHISPatAdm Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_HISPatAdm ]
{

Parameter %JSONREFERENCE = "ID";

/// HIS就诊ID（主键，来自HIS接口admID）
Property AdmID As %String [ Required, SqlColumnNumber = 2, SqlFieldName = AdmID ];

/// 医保个人编码
Property PsnNo As %String [ SqlColumnNumber = 3, SqlFieldName = PsnNo ];

/// HIS患者ID（来自HIS接口patID）
Property PatID As %String [ Required, SqlColumnNumber = 4, SqlFieldName = PatID ];

/// 患者姓名
Property PatName As %String [ SqlColumnNumber = 5, SqlFieldName = PatName ];

/// 年龄
Property Age As %String [ SqlColumnNumber = 6, SqlFieldName = Age ];

/// 性别编码
Property PatSexCode As %String [ SqlColumnNumber = 7, SqlFieldName = PatSexCode ];

/// 性别描述
Property PatSexDesc As %String [ SqlColumnNumber = 8, SqlFieldName = PatSexDesc ];

/// 住院号
Property PatNo As %String [ SqlColumnNumber = 9, SqlFieldName = PatNo ];

/// 病案号
Property PatMedicalNo As %String [ SqlColumnNumber = 10, SqlFieldName = PatMedicalNo ];

/// 就医地区划代码
Property MdtrtArea As %String [ SqlColumnNumber = 11, SqlFieldName = MdtrtArea ];

/// 参保地区划代码
Property AdmvsArea As %String [ SqlColumnNumber = 12, SqlFieldName = AdmvsArea ];

/// 险种
Property InsuType As %String [ SqlColumnNumber = 13, SqlFieldName = InsuType ];

/// 病种编码
Property DiagnosisCode As %String [ SqlColumnNumber = 14, SqlFieldName = DiagnosisCode ];

/// 病种名称
Property DiagnosisName As %String [ SqlColumnNumber = 15, SqlFieldName = DiagnosisName ];

/// 分组阶段
Property GroupStage As %String [ SqlColumnNumber = 16, SqlFieldName = GroupStage ];

/// HIS诊断类型
Property DiaTypeCode As %String [ SqlColumnNumber = 17, SqlFieldName = DiaTypeCode ];

/// 主诊断代码
Property MainDiagnosisCode As %String [ SqlColumnNumber = 18, SqlFieldName = MainDiagnosisCode ];

/// 主手术代码
Property MainOperationCode As %String [ SqlColumnNumber = 19, SqlFieldName = MainOperationCode ];

/// 总费用
Property SumAmt As %String [ SqlColumnNumber = 20, SqlFieldName = SumAmt ];

/// 主治医师代码
Property AdmDocCode As %String [ SqlColumnNumber = 21, SqlFieldName = AdmDocCode ];

/// 主治医师描述
Property AdmDocDesc As %String [ SqlColumnNumber = 22, SqlFieldName = AdmDocDesc ];

/// 责任护士代码
Property AdmNurCode As %String [ SqlColumnNumber = 23, SqlFieldName = AdmNurCode ];

/// 责任护士描述
Property AdmNurDesc As %String [ SqlColumnNumber = 24, SqlFieldName = AdmNurDesc ];

/// 入院时间
Property AdmDateTime As %TimeStamp [ SqlColumnNumber = 25, SqlFieldName = AdmDateTime ];

/// 入院天数
Property AdmInDays As %Integer [ SqlColumnNumber = 26, SqlFieldName = AdmInDays ];

/// 入院诊断
Property AdmDiag As %String [ SqlColumnNumber = 27, SqlFieldName = AdmDiag ];

/// 入院科室描述
Property InLocDesc As %String [ SqlColumnNumber = 28, SqlFieldName = InLocDesc ];

/// 入院病区描述
Property InWardDesc As %String [ SqlColumnNumber = 29, SqlFieldName = InWardDesc ];

/// 医疗机构代码
Property FixmedinsCode As %String [ SqlColumnNumber = 30, SqlFieldName = FixmedinsCode ];

/// 医疗机构名称
Property FixmedinsName As %String [ SqlColumnNumber = 31, SqlFieldName = FixmedinsName ];

/// 分组入参
Property GroupParam As %String(MAXLEN = 99999) [ SqlColumnNumber = 32, SqlFieldName = GroupParam ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ SqlColumnNumber = 33, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ SqlColumnNumber = 34, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As User.HBUser [ Required, SqlColumnNumber = 35, SqlFieldName = CreateUser_Dr ];

/// 更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 36, SqlFieldName = UpdateDate ];

/// 更新时间
Property UpdateTime As %Time [ SqlColumnNumber = 37, SqlFieldName = UpdateTime ];

/// 逻辑删除标记 0:正常 1:已删除
Property Deleted As %Integer [ InitialExpression = 0, Required, SqlColumnNumber = 38, SqlFieldName = Deleted ];

/// 删除日期
Property DeleteDate As %Date [ SqlColumnNumber = 39, SqlFieldName = DeleteDate ];

/// 删除时间
Property DeleteTime As %Time [ SqlColumnNumber = 40, SqlFieldName = DeleteTime ];

/// 主键索引
Index AdmIDIndex On AdmID [ PrimaryKey ];

/// 病案号索引
Index PatMedicalNoIndex On PatMedicalNo As Exact;

Storage Default
{
<Data name="BSHISPatAdmDefaultData">
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
<Value>AdmID</Value>
</Value>
<Value name="6">
<Value>PatID</Value>
</Value>
<Value name="7">
<Value>PatName</Value>
</Value>
<Value name="8">
<Value>PatSexCode</Value>
</Value>
<Value name="9">
<Value>PatSexDesc</Value>
</Value>
<Value name="10">
<Value>PatNo</Value>
</Value>
<Value name="11">
<Value>PatMedicalNo</Value>
</Value>
<Value name="12">
<Value>AdmDocDesc</Value>
</Value>
<Value name="13">
<Value>AdmNurDesc</Value>
</Value>
<Value name="14">
<Value>AdmDateTime</Value>
</Value>
<Value name="15">
<Value>AdmInDays</Value>
</Value>
<Value name="16">
<Value>AdmDiag</Value>
</Value>
<Value name="17">
<Value>InLocDesc</Value>
</Value>
<Value name="18">
<Value>InWardDesc</Value>
</Value>
<Value name="19">
<Value>FixmedinsCode</Value>
</Value>
<Value name="20">
<Value>FixmedinsName</Value>
</Value>
<Value name="21">
<Value>CreateDate</Value>
</Value>
<Value name="22">
<Value>CreateTime</Value>
</Value>
<Value name="23">
<Value>CreateUserDr</Value>
</Value>
<Value name="24">
<Value>UpdateDate</Value>
</Value>
<Value name="25">
<Value>UpdateTime</Value>
</Value>
<Value name="26">
<Value>PsnNo</Value>
</Value>
<Value name="27">
<Value>Age</Value>
</Value>
<Value name="28">
<Value>MdtrtArea</Value>
</Value>
<Value name="29">
<Value>AdmvsArea</Value>
</Value>
<Value name="30">
<Value>InsuType</Value>
</Value>
<Value name="31">
<Value>DiagnosisCode</Value>
</Value>
<Value name="32">
<Value>DiagnosisName</Value>
</Value>
<Value name="33">
<Value>GroupStage</Value>
</Value>
<Value name="34">
<Value>DiaTypeCode</Value>
</Value>
<Value name="35">
<Value>MainDiagnosisCode</Value>
</Value>
<Value name="36">
<Value>MainOperationCode</Value>
</Value>
<Value name="37">
<Value>SumAmt</Value>
</Value>
<Value name="38">
<Value>AdmDocCode</Value>
</Value>
<Value name="39">
<Value>AdmNurCode</Value>
</Value>
<Value name="40">
<Value>GroupParam</Value>
</Value>
</Data>
<DataLocation>^BSHISPatAdmD</DataLocation>
<DefaultData>BSHISPatAdmDefaultData</DefaultData>
<IdLocation>^BSHISPatAdmD</IdLocation>
<IndexLocation>^BSHISPatAdmI</IndexLocation>
<StreamLocation>^BSHISPatAdmS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
