Class src.Insurance.Interface Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     gjg
/// CreatDate:   2022-07-21
/// Description: 获取医保登记信息
/// code:        02020001
ClassMethod GetRegisterInfo(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Insurance.RegisterInfoQuery).GetRegisterInfo(postObj)
}

/// Creator:     gjg
/// CreatDate:   2022-07-21
/// Description: 获取医保结算信息
/// code:        02020002
ClassMethod GetMedInsuSettlement(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Insurance.RegisterInfoQuery).GetMedInsuSettlement(postObj)
}

/// Creator:     gjg
/// CreatDate:   2022-07-21
/// Description: 根据医保就诊号获取医保上传费用明细
/// code:        02020003
ClassMethod GetMedInsuFeeUploadRecordByMdtrtID(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Insurance.RegisterInfoQuery).GetMedInsuFeeUploadRecordByMdtrtID(postObj)
}

/// Creator:     zxz
/// CreatDate:   2022-07-21
/// Description: 获取医保日志
/// code:        0202004
ClassMethod GetMedInsuTransactionLog(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.Insurance.RegisterInfoQuery).GetMedInsuTransactionLog(postObj)
}

}
