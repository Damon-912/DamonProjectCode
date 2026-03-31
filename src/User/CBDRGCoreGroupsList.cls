/// 核心疾病诊断相关分组(ADRG)规则列表
/// 说明：关联规则包含主要诊断、次要诊断、主要手术操作、次要手术操作进行分组
Class User.CBDRGCoreGroupsList Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_DRGCoreGroupsList ]
{

Parameter %JSONREFERENCE = "ID";

/// ADRG代码 非空
Property ADRG As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = ADRG ];

/// ADRG名称 非空
Property ADRGDesc As %String [ Required, SqlColumnNumber = 3, SqlFieldName = ADRGDesc ];

/// 主要诊断
Property PrincipalDiagnosis As %String [ SqlColumnNumber = 4, SqlFieldName = PrincipalDiagnosis ];

/// 主要诊断名称 
Property PrincipalDiagnosisName As %String [ SqlColumnNumber = 5, SqlFieldName = PrincipalDiagnosisName ];

/// 其它诊断
Property SecondaryDiagnosis As %String [ SqlColumnNumber = 6, SqlFieldName = SecondaryDiagnosis ];

/// 其它诊断名称 
Property SecondaryDiagnosisName As %String [ SqlColumnNumber = 7, SqlFieldName = SecondaryDiagnosisName ];

/// 第三诊断
Property ThirdlyDiagnosis As %String [ SqlColumnNumber = 8, SqlFieldName = ThirdlyDiagnosis ];

/// 第三诊断名称 
Property ThirdlyDiagnosisName As %String [ SqlColumnNumber = 9, SqlFieldName = ThirdlyDiagnosisName ];

/// 主要手术或操作
Property MajorProcedure As %String [ SqlColumnNumber = 10, SqlFieldName = MajorProcedure ];

/// 主要手术或操作名称 
Property MajorProcedureName As %String [ SqlColumnNumber = 11, SqlFieldName = MajorProcedureName ];

/// 其他手术或操作
Property SecondaryProcedure As %String [ SqlColumnNumber = 12, SqlFieldName = SecondaryProcedure ];

/// 其他手术或操作名称 
Property SecondaryProcedureName As %String [ SqlColumnNumber = 13, SqlFieldName = SecondaryProcedureName ];

/// 第三手术或操作
Property ThirdlyProcedure As %String [ SqlColumnNumber = 14, SqlFieldName = ThirdlyProcedure ];

/// 第三手术或操作名称 
Property ThirdlyProcedureName As %String [ SqlColumnNumber = 15, SqlFieldName = ThirdlyProcedureName ];

/// 入组条件 
Property SelectionCriteria As %String [ SqlColumnNumber = 16, SqlFieldName = SelectionCriteria ];

/// 联合规则标志 1是0否
Property UnionFlag As %String [ InitialExpression = "0", SqlColumnNumber = 17, SqlFieldName = UnionFlag ];

/// 省 指向CB_Province
Property ProvinceDr As CBProvince [ Required, SqlColumnNumber = 18, SqlFieldName = Province_Dr ];

Index Province On ProvinceDr;

/// 市 指向CB_City
Property CityDr As CBCity [ Required, SqlColumnNumber = 19, SqlFieldName = City_Dr ];

Index City On CityDr;

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ Required, SqlColumnNumber = 20, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 21, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 22, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 23, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 24, SqlFieldName = CreateUser_Dr ];

Storage Default
{
<Data name="CBDRGCoreGroupsListDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ADRG</Value>
</Value>
<Value name="3">
<Value>ADRGDesc</Value>
</Value>
<Value name="4">
<Value>PrincipalDiagnosis</Value>
</Value>
<Value name="5">
<Value>PrincipalDiagnosisName</Value>
</Value>
<Value name="6">
<Value>SecondaryDiagnosis</Value>
</Value>
<Value name="7">
<Value>SecondaryDiagnosisName</Value>
</Value>
<Value name="8">
<Value>MajorProcedure</Value>
</Value>
<Value name="9">
<Value>MajorProcedureName</Value>
</Value>
<Value name="10">
<Value>SecondaryProcedure</Value>
</Value>
<Value name="11">
<Value>SecondaryProcedureName</Value>
</Value>
<Value name="12">
<Value>SelectionCriteria</Value>
</Value>
<Value name="13">
<Value>ProvinceDr</Value>
</Value>
<Value name="14">
<Value>CityDr</Value>
</Value>
<Value name="15">
<Value>StartDate</Value>
</Value>
<Value name="16">
<Value>StopDate</Value>
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
<Value>ThirdlyDiagnosis</Value>
</Value>
<Value name="21">
<Value>ThirdlyDiagnosisName</Value>
</Value>
<Value name="22">
<Value>ThirdlyProcedure</Value>
</Value>
<Value name="23">
<Value>ThirdlyProcedureName</Value>
</Value>
<Value name="24">
<Value>UnionFlag</Value>
</Value>
</Data>
<DataLocation>^CBDRGCoreGroupsListD</DataLocation>
<DefaultData>CBDRGCoreGroupsListDefaultData</DefaultData>
<IdLocation>^CBDRGCoreGroupsListD</IdLocation>
<IndexLocation>^CBDRGCoreGroupsListI</IndexLocation>
<StreamLocation>^CBDRGCoreGroupsListS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
