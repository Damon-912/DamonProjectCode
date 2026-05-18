/// DIP算法配置
Class User.HBDIPCoreAlgorithmData Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_DIPCoreAlgorithmData ]
{

Parameter %JSONREFERENCE = "ID";

/// 主要诊断代码
Property PrincipalDiagnosis As %String [ Required, SqlColumnNumber = 2, SqlFieldName = PrincipalDiagnosis ];

/// 主要诊断名称 
Property PrincipalDiagnosisName As %String [ Required, SqlColumnNumber = 3, SqlFieldName = PrincipalDiagnosisName ];

/// 主要手术或操作代码
Property MajorProcedure As %String [ SqlColumnNumber = 4, SqlFieldName = MajorProcedure ];

/// 主要手术或操作名称 
Property MajorProcedureName As %String [ SqlColumnNumber = 5, SqlFieldName = MajorProcedureName ];

/// 相关手术或操作代码
Property SecondaryProcedure As %String [ SqlColumnNumber = 6, SqlFieldName = SecondaryProcedure ];

/// 相关手术或操作名称 
Property SecondaryProcedureName As %String [ SqlColumnNumber = 7, SqlFieldName = SecondaryProcedureName ];

/// 省 指向CB_Province
Property ProvinceDr As CBProvince [ Required, SqlColumnNumber = 8, SqlFieldName = Province_Dr ];

Index Province On ProvinceDr;

/// 市 指向CB_City 
Property CityDr As CBCity [ Required, SqlColumnNumber = 9, SqlFieldName = City_Dr ];

Index City On CityDr;

/// 就医地区划代码
Property MdtrtArea As %String [ SqlColumnNumber = 10, SqlFieldName = MdtrtArea ];

/// 医疗机构等级 1：一级;2：二级;3：三级
Property MedinsLv As %String [ Required, SqlColumnNumber = 11, SqlFieldName = MedinsLv ];

Index Index On (PrincipalDiagnosis, MajorProcedure, ProvinceDr, CityDr, MedinsLv);

/// 平均费用(average cost)
Property AverageCost As %String [ SqlColumnNumber = 12, SqlFieldName = AverageCost ];

/// 基准分值(score value)
Property ScoreValue As %String [ Required, SqlColumnNumber = 13, SqlFieldName = ScoreValue ];

/// 调节系数(adjustment coefficient)
Property AdjustCoefficient As %String [ SqlColumnNumber = 14, SqlFieldName = AdjustCoefficient ];

/// 一级调节系数(Primary adjustment coefficient)
Property PrimaryAdjustCoefficient As %String [ SqlColumnNumber = 15, SqlFieldName = PrimaryAdjustCoefficient ];

/// 二级调节系数(Secondary adjustment coefficient)
Property SecondaryAdjustCoefficient As %String [ SqlColumnNumber = 16, SqlFieldName = SecondaryAdjustCoefficient ];

/// 三级调节系数(Third adjustment coefficient)
Property ThirdAdjustCoefficient As %String [ SqlColumnNumber = 17, SqlFieldName = ThirdAdjustCoefficient ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 18, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 19, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 20, SqlFieldName = CreateUser_Dr ];

/// 年份（分组方案年份，4位数字）
Property Year As %String(MAXLEN = 4) [ SqlColumnNumber = 21, SqlFieldName = Year ];

Storage Default
{
<Data name="HBDIPCoreAlgorithmDataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PrincipalDiagnosis</Value>
</Value>
<Value name="3">
<Value>PrincipalDiagnosisName</Value>
</Value>
<Value name="4">
<Value>MajorProcedure</Value>
</Value>
<Value name="5">
<Value>MajorProcedureName</Value>
</Value>
<Value name="6">
<Value>SecondaryProcedure</Value>
</Value>
<Value name="7">
<Value>SecondaryProcedureName</Value>
</Value>
<Value name="8">
<Value>ProvinceDr</Value>
</Value>
<Value name="9">
<Value>CityDr</Value>
</Value>
<Value name="10">
<Value>MdtrtArea</Value>
</Value>
<Value name="11">
<Value>MedinsLv</Value>
</Value>
<Value name="12">
<Value>ScoreValue</Value>
</Value>
<Value name="13">
<Value>AdjustCoefficient</Value>
</Value>
<Value name="14">
<Value>PrimaryAdjustCoefficient</Value>
</Value>
<Value name="15">
<Value>SecondaryAdjustCoefficient</Value>
</Value>
<Value name="16">
<Value>ThirdAdjustCoefficient</Value>
</Value>
<Value name="17">
<Value>CreateDate</Value>
</Value>
<Value name="18">
<Value>CreateTime</Value>
</Value>
<Value name="19">
<Value>CreateUserDr</Value>
</Value>
<Value name="20">
<Value>AverageCost</Value>
</Value>
<Value name="21">
<Value>Year</Value>
</Value>
</Data>
<DataLocation>^HBDIPCoreAlgorithmDataD</DataLocation>
<DefaultData>HBDIPCoreAlgorithmDataDefaultData</DefaultData>
<IdLocation>^HBDIPCoreAlgorithmDataD</IdLocation>
<IndexLocation>^HBDIPCoreAlgorithmDataI</IndexLocation>
<StreamLocation>^HBDIPCoreAlgorithmDataS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
