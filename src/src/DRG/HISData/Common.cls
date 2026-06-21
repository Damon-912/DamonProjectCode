#Import SQLUSER

/// HIS数据同步公共类
/// 提供通用的返回结果封装方法
Class src.DRG.HISData.Common Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 设置错误返回结果（封装重复逻辑）
ClassMethod SetErrorResult(errorCode As %String, errorMsg As %String) As %Library.DynamicObject
{
	set resultObj={}
	set resultObj.errorCode=errorCode
	set resultObj.errorMessage=errorMsg
	
	set result={}
	set result.code=""
	set result.desc=""
	set result.checkTime=$ZDATETIME($HOROLOG,3)
    set resultObj.result=result
    
    quit resultObj
}

/// 设置成功返回结果（封装重复逻辑）
ClassMethod SetSuccessResult(code As %String, message As %String) As %Library.DynamicObject
{
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage=message
	
	set result={}
	set result.code=code
	set result.desc=message
	set result.checkTime=$ZDATETIME($HOROLOG,3)
    set resultObj.result=result
    
    quit resultObj
}

}
