Class User.BSDRGPatientPayInfo Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGPatientPayInfo ]
{

Parameter %JSONREFERENCE = "ID";

/// 医保就诊ID 
Property MdtrtId As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 2, SqlFieldName = MdtrtId ];

Index MdtrtId On MdtrtId;

/// 就医流水号 
Property MdtrtSn As %String(COLLATION = "UPPER", MAXLEN = 50) [ SqlColumnNumber = 3, SqlFieldName = MdtrtSn ];

/// 结算ID 
Property SetlId As %String(COLLATION = "UPPER", MAXLEN = 50) [ Required, SqlColumnNumber = 4, SqlFieldName = SetlId ];

Index SetlId On SetlId;

/// 基金支付类型 
Property FundPayType As %String [ Required, SqlColumnNumber = 5, SqlFieldName = FundPayType ];

Index FundPayType On FundPayType;

Index PayInfoIndex On (MdtrtId, SetlId, FundPayType);

/// 基金支付金额 
Property FundPayAmt As %String [ Required, SqlColumnNumber = 6, SqlFieldName = FundPayAmt ];

/// HIS就诊流水号 
Property HISAdmID As %String [ Required, SqlColumnNumber = 7, SqlFieldName = HISAdmID ];

/// 数据更新时间
Property UpdateTime As %DateTime [ SqlColumnNumber = 8, SqlFieldName = UpdateTime ];

Storage Default
{
<Data name="BSDRGPatientPayInfoDefaultData">
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
<Value>SetlId</Value>
</Value>
<Value name="5">
<Value>FundPayType</Value>
</Value>
<Value name="6">
<Value>FundPayAmt</Value>
</Value>
<Value name="7">
<Value>HISAdmID</Value>
</Value>
<Value name="8">
<Value>UpdateTime</Value>
</Value>
</Data>
<DataLocation>^BSDRGPatientPayInfoD</DataLocation>
<DefaultData>BSDRGPatientPayInfoDefaultData</DefaultData>
<IdLocation>^BSDRGPatientPayInfoD</IdLocation>
<IndexLocation>^BSDRGPatientPayInfoI</IndexLocation>
<StreamLocation>^BSDRGPatientPayInfoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
