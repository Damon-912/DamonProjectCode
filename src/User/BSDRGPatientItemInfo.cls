Class User.BSDRGPatientItemInfo Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_DRGPatientItemInfo ]
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

/// 医疗收费项目 
Property MedChrgItm As %String [ Required, SqlColumnNumber = 5, SqlFieldName = MedChrgItm ];

Index MedChrgItm On MedChrgItm;

Index ItemInfoIndex On (MdtrtId, SetlId, MedChrgItm);

/// 金额 
Property Amt As %String [ Required, SqlColumnNumber = 6, SqlFieldName = Amt ];

/// 甲类费用合计 
Property ClaaSumfee As %String [ Required, SqlColumnNumber = 7, SqlFieldName = ClaaSumfee ];

/// 乙类金额 
Property ClabAmt As %String [ Required, SqlColumnNumber = 8, SqlFieldName = ClabAmt ];

/// 全自费金额 
Property FulamtOwnpayAmt As %String [ Required, SqlColumnNumber = 9, SqlFieldName = FulamtOwnpayAmt ];

/// 其他金额 
Property OthAmt As %String [ Required, SqlColumnNumber = 10, SqlFieldName = OthAmt ];

/// HIS就诊流水号 
Property HISAdmID As %String [ Required, SqlColumnNumber = 11, SqlFieldName = HISAdmID ];

/// 数据更新时间
Property UpdateTime As %DateTime [ SqlColumnNumber = 12, SqlFieldName = UpdateTime ];

Storage Default
{
<Data name="BSDRGPatientItemInfoDefaultData">
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
<Value>MedChrgItm</Value>
</Value>
<Value name="6">
<Value>Amt</Value>
</Value>
<Value name="7">
<Value>ClaaSumfee</Value>
</Value>
<Value name="8">
<Value>ClabAmt</Value>
</Value>
<Value name="9">
<Value>FulamtOwnpayAmt</Value>
</Value>
<Value name="10">
<Value>OthAmt</Value>
</Value>
<Value name="11">
<Value>HISAdmID</Value>
</Value>
<Value name="12">
<Value>UpdateTime</Value>
</Value>
</Data>
<DataLocation>^User.BSDRGPatientItemInfoD</DataLocation>
<DefaultData>BSDRGPatientItemInfoDefaultData</DefaultData>
<IdLocation>^User.BSDRGPatientItemInfoD</IdLocation>
<IndexLocation>^User.BSDRGPatientItemInfoI</IndexLocation>
<StreamLocation>^User.BSDRGPatientItemInfoS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
