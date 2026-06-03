Class User.HBDRGCoreAlgorithmData Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_DRGCoreAlgorithmData ]
{

Parameter %JSONREFERENCE = "ID";

/// DRG
Property DRG As %String [ Required, SqlColumnNumber = 2, SqlFieldName = DRG ];

/// 描述
Property DRGDESC As %String [ Required, SqlColumnNumber = 3, SqlFieldName = DRGDESC ];

/// 基准点数(Points)
Property Points As %String [ SqlColumnNumber = 4, SqlFieldName = Points ];

/// 预估点值(pip value)
Property PipValue As %String [ SqlColumnNumber = 5, SqlFieldName = PipValue ];

/// 病组差异系数(Disease group difference of variation)
Property DGDOV As %String [ SqlColumnNumber = 6, SqlFieldName = DGDOV ];

/// 支付标准
Property PayStandard As %String [ SqlColumnNumber = 7, SqlFieldName = PayStandard ];

/// 高倍率（费用偏高倍率阈值）
Property HighMultiplier As %String [ SqlColumnNumber = 8, SqlFieldName = HighMultiplier ];

/// 低倍率（费用偏低倍率阈值）
Property LowMultiplier As %String [ SqlColumnNumber = 9, SqlFieldName = LowMultiplier ];

/// 权重（病组权重）
Property Weight As %String [ SqlColumnNumber = 10, SqlFieldName = Weight ];

/// 年份（分组方案年份，4位数字）
Property Year As %String(MAXLEN = 4) [ Required, SqlColumnNumber = 11, SqlFieldName = Year ];

/// 省 指向CB_Province
Property ProvinceDr As CBProvince [ Required, SqlColumnNumber = 12, SqlFieldName = Province_Dr ];

Index Province On ProvinceDr;

/// 市 指向CB_City
Property CityDr As CBCity [ Required, SqlColumnNumber = 13, SqlFieldName = City_Dr ];

Index City On CityDr;

/// 生效日期 真正开始使用日期
Property StartDate As %Date [ SqlColumnNumber = 14, SqlFieldName = StartDate ];

/// 失效日期 此日期开始不能用,不填说明一直可用,如果不可用需要看此日期
Property StopDate As %Date [ SqlColumnNumber = 15, SqlFieldName = StopDate ];

/// 险种
Property InsuType As %String [ SqlColumnNumber = 16, SqlFieldName = InsuType ];

/// 就医地区划代码
Property MdtrtArea As %String [ SqlColumnNumber = 17, SqlFieldName = MdtrtArea ];

/// 医疗机构等级
Property MedinsLv As %String [ SqlColumnNumber = 18, SqlFieldName = MedinsLv ];

/// 医疗机构名称
Property FixmedinsName As %String [ Required, SqlColumnNumber = 19, SqlFieldName = FixmedinsName ];

/// 医疗机构代码
Property FixmedinsCode As %String [ Required, SqlColumnNumber = 20, SqlFieldName = FixmedinsCode ];

Index FixmedinsCode On FixmedinsCode;

Index Index On (DRG, ProvinceDr, CityDr, FixmedinsCode, Year);

/// 创建日期 系统自动产生
Property CreateDate As %Date [ Required, SqlColumnNumber = 21, SqlFieldName = CreateDate ];

/// 创建时间 系统自动产生
Property CreateTime As %Time [ Required, SqlColumnNumber = 22, SqlFieldName = CreateTime ];

/// 创建人员ID 指向HB_User表
Property CreateUserDr As HBUser [ Required, SqlColumnNumber = 23, SqlFieldName = CreateUser_Dr ];

/// 标识码-分类
Property Identification As %String [ SqlColumnNumber = 24, SqlFieldName = Identification ];

/// 备注
Property Remark As %String(MAXLEN = 99999) [ SqlColumnNumber = 25, SqlFieldName = Remark ];

Storage Default
{
<Data name="HBDRGCoreAlgorithmDataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DRG</Value>
</Value>
<Value name="3">
<Value>DRGDESC</Value>
</Value>
<Value name="4">
<Value>Points</Value>
</Value>
<Value name="5">
<Value>PipValue</Value>
</Value>
<Value name="6">
<Value>DGDOV</Value>
</Value>
<Value name="7">
<Value>PayStandard</Value>
</Value>
<Value name="8">
<Value>ProvinceDr</Value>
</Value>
<Value name="9">
<Value>CityDr</Value>
</Value>
<Value name="10">
<Value>StartDate</Value>
</Value>
<Value name="11">
<Value>StopDate</Value>
</Value>
<Value name="12">
<Value>InsuType</Value>
</Value>
<Value name="13">
<Value>MdtrtArea</Value>
</Value>
<Value name="14">
<Value>MedinsLv</Value>
</Value>
<Value name="15">
<Value>FixmedinsName</Value>
</Value>
<Value name="16">
<Value>FixmedinsCode</Value>
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
<Value>Identification</Value>
</Value>
<Value name="21">
<Value>Remark</Value>
</Value>
<Value name="22">
<Value>Year</Value>
</Value>
<Value name="23">
<Value>HighMultiplier</Value>
</Value>
<Value name="24">
<Value>LowMultiplier</Value>
</Value>
<Value name="25">
<Value>Weight</Value>
</Value>
</Data>
<DataLocation>^HBDRGCoreAlgorithmDataD</DataLocation>
<DefaultData>HBDRGCoreAlgorithmDataDefaultData</DefaultData>
<IdLocation>^HBDRGCoreAlgorithmDataD</IdLocation>
<IndexLocation>^HBDRGCoreAlgorithmDataI</IndexLocation>
<StreamLocation>^HBDRGCoreAlgorithmDataS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
