Class User.BSDRGWarningRule Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGWarningRule ]
{

Parameter %JSONREFERENCE = "ID";

/// ========================================
/// 规则基础信息
/// ========================================
/// 规则编码（唯一）
Property RuleCode As %String [ Required, SqlColumnNumber = 2, SqlFieldName = RuleCode ];

Index RuleCode On RuleCode [ Unique ];

/// 规则名称
Property RuleName As %String [ Required, SqlColumnNumber = 3, SqlFieldName = RuleName ];

/// 规则描述
Property RuleDesc As %String(MAXLEN = 500) [ SqlColumnNumber = 4, SqlFieldName = RuleDesc ];

/// ========================================
/// 规则类型
/// ========================================
/// 规则类型 01=费用超支, 02=低倍率, 03=高倍率, 04=编码异常, 05=分解住院
Property RuleType As %String [ Required, SqlColumnNumber = 5, SqlFieldName = RuleType ];

Index RuleType On RuleType;

/// 阈值类型 01=百分比, 02=固定值
Property ThresholdType As %String [ SqlColumnNumber = 6, SqlFieldName = ThresholdType ];

/// 阈值
Property ThresholdValue As %Decimal(SCALE = 2) [ SqlColumnNumber = 7, SqlFieldName = ThresholdValue ];

/// ========================================
/// DRG范围限定
/// ========================================
/// MDC编码限定
Property MDCCode As %String [ SqlColumnNumber = 8, SqlFieldName = MDCCode ];

Index MDCCode On MDCCode;

/// ADRG编码限定
Property ADRGCode As %String [ SqlColumnNumber = 9, SqlFieldName = ADRGCode ];

Index ADRGCode On ADRGCode;

/// DRG编码限定
Property DRGCode As %String [ SqlColumnNumber = 10, SqlFieldName = DRGCode ];

Index DRGCode On DRGCode;

/// ========================================
/// 预警级别与状态
/// ========================================
/// 预警级别 1=低, 2=中, 3=高
Property WarningLevel As %String [ SqlColumnNumber = 11, SqlFieldName = WarningLevel ];

Index WarningLevel On WarningLevel;

/// 是否启用 1=是, 0=否
Property IsActive As %String [ InitialExpression = "1", SqlColumnNumber = 12, SqlFieldName = IsActive ];

Index IsActive On IsActive;

/// 排序序号
Property SeqNo As %Integer [ SqlColumnNumber = 13, SqlFieldName = SeqNo ];

/// ========================================
/// 系统字段
/// ========================================
/// 创建日期
Property CreateDate As %Date [ Required, SqlColumnNumber = 14, SqlFieldName = CreateDate ];

Index CreateDate On CreateDate;

/// 创建时间
Property CreateTime As %Time [ Required, SqlColumnNumber = 15, SqlFieldName = CreateTime ];

/// 创建人员
Property CreateUserDr As %String [ SqlColumnNumber = 16, SqlFieldName = CreateUser_Dr ];

/// 更新日期
Property UpdateDate As %Date [ SqlColumnNumber = 17, SqlFieldName = UpdateDate ];

/// 更新时间
Property UpdateTime As %Time [ SqlColumnNumber = 18, SqlFieldName = UpdateTime ];

/// 更新人员
Property UpdateUserDr As %String [ SqlColumnNumber = 19, SqlFieldName = UpdateUser_Dr ];

/// 备注
Property Remark As %String(MAXLEN = 99999) [ SqlColumnNumber = 20, SqlFieldName = Remark ];

/// ========================================
/// 复合索引
/// ========================================
/// 规则类型+启用状态 复合索引
Index TypeActive On (RuleType, IsActive);

/// Storage
Storage Default
{
<Data name="BSDRGWarningRuleDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RuleCode</Value>
</Value>
<Value name="3">
<Value>RuleName</Value>
</Value>
<Value name="4">
<Value>RuleDesc</Value>
</Value>
<Value name="5">
<Value>RuleType</Value>
</Value>
<Value name="6">
<Value>ThresholdType</Value>
</Value>
<Value name="7">
<Value>ThresholdValue</Value>
</Value>
<Value name="8">
<Value>MDCCode</Value>
</Value>
<Value name="9">
<Value>ADRGCode</Value>
</Value>
<Value name="10">
<Value>DRGCode</Value>
</Value>
<Value name="11">
<Value>WarningLevel</Value>
</Value>
<Value name="12">
<Value>IsActive</Value>
</Value>
<Value name="13">
<Value>SeqNo</Value>
</Value>
<Value name="14">
<Value>CreateDate</Value>
</Value>
<Value name="15">
<Value>CreateTime</Value>
</Value>
<Value name="16">
<Value>CreateUserDr</Value>
</Value>
<Value name="17">
<Value>UpdateDate</Value>
</Value>
<Value name="18">
<Value>UpdateTime</Value>
</Value>
<Value name="19">
<Value>UpdateUserDr</Value>
</Value>
<Value name="20">
<Value>Remark</Value>
</Value>
</Data>
<DataLocation>^User.BSDRGWarningRuleD</DataLocation>
<DefaultData>BSDRGWarningRuleDefaultData</DefaultData>
<Description>
<![CDATA[Storage]]></Description>
<IdLocation>^User.BSDRGWarningRuleD</IdLocation>
<IndexLocation>^User.BSDRGWarningRuleI</IndexLocation>
<StreamLocation>^User.BSDRGWarningRuleS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
