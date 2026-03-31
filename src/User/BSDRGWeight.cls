Class User.BSDRGWeight Extends (%Persistent, %XML.Adaptor, %JSON.Adaptor) [ ClassType = persistent, SqlTableName = BS_DRGWeight ]
{

Parameter %JSONREFERENCE = "ID";

/// DRG编码 (必填,唯一)
Property DRGCode As %String(MAXLEN = 10) [ Required, SqlFieldName = DRGCode ];

Index IdxDRGCode On DRGCode [ Unique ];

/// DRG名称
Property DRGName As %String(MAXLEN = 200) [ SqlFieldName = DRGName ];

/// MDC编码
Property MDCCode As %String(MAXLEN = 10) [ SqlFieldName = MDCCode ];

Index IdxMDCCode On MDCCode;

/// ADRG编码
Property ADRGCode As %String(MAXLEN = 10) [ SqlFieldName = ADRGCode ];

Index IdxADRGCode On ADRGCode;

/// 权重 (精度4位小数)
Property Weight As %Decimal(SCALE = 4) [ SqlFieldName = Weight ];

/// 标准费用
Property StandardCost As %Decimal(SCALE = 2) [ SqlFieldName = StandardCost ];

/// 费用下限
Property LowerLimit As %Decimal(SCALE = 2) [ SqlFieldName = LowerLimit ];

/// 费用上限
Property UpperLimit As %Decimal(SCALE = 2) [ SqlFieldName = UpperLimit ];

/// 基准点数
Property BasePoint As %Decimal(SCALE = 2) [ SqlFieldName = BasePoint ];

/// 点数单价
Property PointPrice As %Decimal(SCALE = 4) [ SqlFieldName = PointPrice ];

/// 规则版本号 (如: CHS-DRG V1.0)
Property RuleVersion As %String(MAXLEN = 20) [ SqlFieldName = RuleVersion ];

Index IdxRuleVersion On RuleVersion;

/// 生效日期
Property StartDate As %Date [ SqlFieldName = StartDate ];

Index IdxStartDate On StartDate;

/// 失效日期 (空表示永久有效)
Property StopDate As %Date [ SqlFieldName = StopDate ];

/// 省 (指向CB_Province)
Property ProvinceDr As CBProvince [ SqlFieldName = Province_Dr ];

/// 市 (指向CB_City)
Property CityDr As CBCity [ SqlFieldName = City_Dr ];

/// 区 (指向CB_Area)
Property AreaDr As CBArea [ SqlFieldName = Area_Dr ];

/// 数据状态 active-启用 inactive-停用
Property DataStatus As %String(VALUELIST = ",active,inactive") [ InitialExpression = "active", SqlFieldName = DataStatus ];

Index IdxDataStatus On DataStatus;

/// 创建日期
Property CreateDate As %Date [ InitialExpression = {$PIECE($HOROLOG, ",")}, SqlFieldName = CreateDate ];

/// 创建时间
Property CreateTime As %Time [ InitialExpression = {$EXTRACT($HOROLOG, ",", 2)}, SqlFieldName = CreateTime ];

/// 创建人员ID (指向HB_User)
Property CreateUserDr As HBUser [ SqlFieldName = CreateUser_Dr ];

/// 更新日期
Property UpdateDate As %Date [ SqlFieldName = UpdateDate ];

/// 更新时间
Property UpdateTime As %Time [ SqlFieldName = UpdateTime ];

/// 更新人员ID (指向HB_User)
Property UpdateUserDr As HBUser [ SqlFieldName = UpdateUser_Dr ];

/// 备注
Property Remark As %String(MAXLEN = 99999) [ SqlFieldName = Remark ];

Storage Default
{
<Data name="BSDRGWeightDefaultData">
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
<Value>MDCCode</Value>
</Value>
<Value name="5">
<Value>ADRGCode</Value>
</Value>
<Value name="6">
<Value>Weight</Value>
</Value>
<Value name="7">
<Value>StandardCost</Value>
</Value>
<Value name="8">
<Value>LowerLimit</Value>
</Value>
<Value name="9">
<Value>UpperLimit</Value>
</Value>
<Value name="10">
<Value>BasePoint</Value>
</Value>
<Value name="11">
<Value>PointPrice</Value>
</Value>
<Value name="12">
<Value>RuleVersion</Value>
</Value>
<Value name="13">
<Value>StartDate</Value>
</Value>
<Value name="14">
<Value>StopDate</Value>
</Value>
<Value name="15">
<Value>ProvinceDr</Value>
</Value>
<Value name="16">
<Value>CityDr</Value>
</Value>
<Value name="17">
<Value>AreaDr</Value>
</Value>
<Value name="18">
<Value>DataStatus</Value>
</Value>
<Value name="19">
<Value>CreateDate</Value>
</Value>
<Value name="20">
<Value>CreateTime</Value>
</Value>
<Value name="21">
<Value>CreateUserDr</Value>
</Value>
<Value name="22">
<Value>UpdateDate</Value>
</Value>
<Value name="23">
<Value>UpdateTime</Value>
</Value>
<Value name="24">
<Value>UpdateUserDr</Value>
</Value>
<Value name="25">
<Value>Remark</Value>
</Value>
</Data>
<DataLocation>^User.BSDRGWeightD</DataLocation>
<DefaultData>BSDRGWeightDefaultData</DefaultData>
<IdLocation>^User.BSDRGWeightD</IdLocation>
<IndexLocation>^User.BSDRGWeightI</IndexLocation>
<StreamLocation>^User.BSDRGWeightS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
