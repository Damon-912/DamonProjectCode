/// DRG特异化分组内涵表 -- 存储各地医保局发布的特异化分组方案
/// DRG编码前3位即为ADRG编码，无需单独存储ADRGCode字段
Class User.HBDRGSpecialGroup Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_DRGSpecialGroup ]
{

Parameter %JSONREFERENCE = "ID";

/// DRG编码 必填（前3位为ADRG编码），大写排序
Property DRGCode As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 2, SqlFieldName = DRGCode ];

/// DRG编码索引
Index DRGCodeIdx On DRGCode;

/// DRG名称 必填
Property DRGName As %String(COLLATION = "UPPER", MAXLEN = 200, TRUNCATE = 1) [ Required, SqlColumnNumber = 3, SqlFieldName = DRGName ];

/// 主要诊断编码（逗号分隔多个）
Property PrincipalDiagnosis As %String(MAXLEN = 500) [ SqlColumnNumber = 4, SqlFieldName = PrincipalDiagnosis ];

/// 主要诊断名称
Property PrincipalDiagnosisName As %String(MAXLEN = 2000) [ SqlColumnNumber = 5, SqlFieldName = PrincipalDiagnosisName ];

/// 次要诊断编码（逗号分隔多个）
Property SecondaryDiagnosis As %String(MAXLEN = 500) [ SqlColumnNumber = 6, SqlFieldName = SecondaryDiagnosis ];

/// 次要诊断名称
Property SecondaryDiagnosisName As %String(MAXLEN = 2000) [ SqlColumnNumber = 7, SqlFieldName = SecondaryDiagnosisName ];

/// 主要手术编码（逗号分隔多个）
Property MajorProcedure As %String(MAXLEN = 500) [ SqlColumnNumber = 8, SqlFieldName = MajorProcedure ];

/// 主要手术名称
Property MajorProcedureName As %String(MAXLEN = 2000) [ SqlColumnNumber = 9, SqlFieldName = MajorProcedureName ];

/// 次要手术编码（逗号分隔多个）
Property SecondaryProcedure As %String(MAXLEN = 500) [ SqlColumnNumber = 10, SqlFieldName = SecondaryProcedure ];

/// 次要手术名称
Property SecondaryProcedureName As %String(MAXLEN = 2000) [ SqlColumnNumber = 11, SqlFieldName = SecondaryProcedureName ];

/// 入组因素说明（结构化：+表示AND，或表示OR）
Property GroupFactors As %String(MAXLEN = 200) [ SqlColumnNumber = 12, SqlFieldName = GroupFactors ];

/// 备注
Property Remark As %String(MAXLEN = 500) [ SqlColumnNumber = 13, SqlFieldName = Remark ];

/// 行政区划代码 必填
Property Admvs As %String(MAXLEN = 10, TRUNCATE = 1) [ Required, SqlColumnNumber = 14, SqlFieldName = Admvs ];

/// 省 指向CB_Province 必填
Property ProvinceDr As CBProvince [ Required, SqlColumnNumber = 15, SqlFieldName = Province_Dr ];

/// 市 指向CB_City 必填
Property CityDr As CBCity [ Required, SqlColumnNumber = 16, SqlFieldName = City_Dr ];

/// 分组方案年份 必填
Property Year As %String(MAXLEN = 4, TRUNCATE = 1) [ Required, SqlColumnNumber = 17, SqlFieldName = Year ];

/// 生效日期
Property StartDate As %Date [ SqlColumnNumber = 18, SqlFieldName = StartDate ];

/// 失效日期
Property StopDate As %Date [ SqlColumnNumber = 19, SqlFieldName = StopDate ];

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 20, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 21, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 22, SqlFieldName = CreateUser_Dr ];

/// (Admvs, ProvinceDr, CityDr, Year) 联合索引
Index AdmvsProvCityYearIdx On (Admvs, ProvinceDr, CityDr, Year);

Storage Default
{
<Data name="HBDRGSpecialGroupDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DRGCode</Value>
</Value>
<Value name="3">
<Value>DRGName</Value>
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
<Value>GroupFactors</Value>
</Value>
<Value name="13">
<Value>Remark</Value>
</Value>
<Value name="14">
<Value>Admvs</Value>
</Value>
<Value name="15">
<Value>ProvinceDr</Value>
</Value>
<Value name="16">
<Value>CityDr</Value>
</Value>
<Value name="17">
<Value>Year</Value>
</Value>
<Value name="18">
<Value>StartDate</Value>
</Value>
<Value name="19">
<Value>StopDate</Value>
</Value>
<Value name="20">
<Value>CreateDate</Value>
</Value>
<Value name="21">
<Value>CreateTime</Value>
</Value>
<Value name="22">
<Value>CreateUserDr</Value>
</Value>
</Data>
<DataLocation>^HBDRGSpecialGroupD</DataLocation>
<DefaultData>HBDRGSpecialGroupDefaultData</DefaultData>
<IdLocation>^HBDRGSpecialGroupD</IdLocation>
<IndexLocation>^HBDRGSpecialGroupI</IndexLocation>
<StreamLocation>^HBDRGSpecialGroupS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
