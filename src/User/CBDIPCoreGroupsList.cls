/// 按病种分值（DIP）付费病种库（2.0版）核心病种列表（合计9520组）
/// 说明：关联规则包含主要诊断代码、主要诊断名称、主要手术操作代码、主要手术操作名称、相关手术操作代码、相关手术操作名称
Class User.CBDIPCoreGroupsList Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_DIPCoreGroupsList ]
{

Parameter %JSONREFERENCE = "ID";

/// 编号 非空
Property Num As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = Num ];

Index Num On Num;

Index DataIndex On Num [ Unique ];

/// 主要诊断代码
Property PrincipalDiagnosis As %String [ SqlColumnNumber = 3, SqlFieldName = PrincipalDiagnosis ];

/// 主要诊断名称 
Property PrincipalDiagnosisName As %String [ SqlColumnNumber = 4, SqlFieldName = PrincipalDiagnosisName ];

/// 主要手术或操作代码
Property MajorProcedure As %String [ SqlColumnNumber = 5, SqlFieldName = MajorProcedure ];

/// 主要手术或操作名称 
Property MajorProcedureName As %String [ SqlColumnNumber = 6, SqlFieldName = MajorProcedureName ];

/// 相关手术或操作代码
Property SecondaryProcedure As %String [ SqlColumnNumber = 7, SqlFieldName = SecondaryProcedure ];

/// 相关手术或操作名称 
Property SecondaryProcedureName As %String [ SqlColumnNumber = 8, SqlFieldName = SecondaryProcedureName ];

/// 省 指向CB_Province
Property ProvinceDr As CBProvince [ Required, SqlColumnNumber = 9, SqlFieldName = Province_Dr ];

Index Province On ProvinceDr;

/// 市 指向CB_City 
Property CityDr As CBCity [ Required, SqlColumnNumber = 10, SqlFieldName = City_Dr ];

Index City On CityDr;

/// 就医地区划代码
Property MdtrtArea As %String [ SqlColumnNumber = 11, SqlFieldName = MdtrtArea ];

/// 医疗机构等级
Property MedinsLv As %String [ SqlColumnNumber = 12, SqlFieldName = MedinsLv ];

Index Index On (PrincipalDiagnosis, MajorProcedure, ProvinceDr, CityDr, MedinsLv);

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 13, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 14, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 15, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 16, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 17, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBDIPCoreGroupsListDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Num</Value>
</Value>
<Value name="3">
<Value>PrincipalDiagnosis</Value>
</Value>
<Value name="4">
<Value>PrincipalDiagnosisName</Value>
</Value>
<Value name="5">
<Value>MajorProcedure</Value>
</Value>
<Value name="6">
<Value>MajorProcedureName</Value>
</Value>
<Value name="7">
<Value>SecondaryProcedure</Value>
</Value>
<Value name="8">
<Value>SecondaryProcedureName</Value>
</Value>
<Value name="9">
<Value>ProvinceDr</Value>
</Value>
<Value name="10">
<Value>CityDr</Value>
</Value>
<Value name="11">
<Value>StartDate</Value>
</Value>
<Value name="12">
<Value>StopDate</Value>
</Value>
<Value name="13">
<Value>CreateDate</Value>
</Value>
<Value name="14">
<Value>CreateTime</Value>
</Value>
<Value name="15">
<Value>CreateUserDr</Value>
</Value>
<Value name="16">
<Value>MdtrtArea</Value>
</Value>
<Value name="17">
<Value>MedinsLv</Value>
</Value>
</Data>
<DataLocation>^CBDIPCoreGroupsListD</DataLocation>
<DefaultData>CBDIPCoreGroupsListDefaultData</DefaultData>
<IdLocation>^CBDIPCoreGroupsListD</IdLocation>
<IndexLocation>^CBDIPCoreGroupsListI</IndexLocation>
<StreamLocation>^CBDIPCoreGroupsListS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
