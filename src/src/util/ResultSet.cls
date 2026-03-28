/// Author:      gjg
/// Data:        2022-2-17
/// Descripts:   封装的输出结果集工具
/// Notice：     在try catch，while,for 等等中 输出的结果对象无法直接quit程序，可以通过再代码块外创建初始化成功结果集。
Class src.util.ResultSet Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 成功的返回
ClassMethod Success(result = "", errorMessage = "成功", errorCode = 0)
{
	new (result,errorMessage,errorCode)
	set obj={}
	set obj.errorCode=errorCode
	set obj.errorMessage=errorMessage
	if (result'=""){
		set obj.result=result
	}
	quit obj
}

/// 失败的返回
ClassMethod Fail(errorMessage = "错误", errorCode = -1)
{
	new (errorMessage,errorCode)
	set obj={}
	set obj.errorCode=errorCode
	set obj.errorMessage=errorMessage
	quit obj
}

/// 参数错误的返回
ClassMethod ParamFail(errorMessage = "")
{
	new (errorMessage)
	set obj={}
	set obj.errorCode=-1
	if (errorMessage'=""){
		set obj.errorMessage=errorMessage
	}else{
		set obj.errorMessage="缺少必要参数"
	}
	quit obj
}

/// trycatch的返回
/// param :e 传入的异常
ClassMethod CatchFail(e)
{
	new (e)
	set status=e.AsStatus()	
	set obj={}
	set obj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	set obj.errorMessage=##class(%SYSTEM.Status).GetErrorText(status,"cn")
	quit obj
}

/// 系统状态类错误的返回
/// param :status  $System.Status
ClassMethod StatusFail(status)
{
	new (status)
	set obj={}
	set obj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	set obj.errorMessage=$System.Status.GetErrorText(status)
	quit obj
}

/// 维护的错误接口
/// param :errorCode 维护的错误代码   languageID  CB_Language表ID   before 前方拼接的字符串  after  后方拼接的字符串
ClassMethod FailInfoByCode(errorCode, languageID = "", before = "", after = "")
{
	new (errorCode,languageID,before,after)
	set obj={}
	set obj.errorCode=errorCode
	set errorMessage=##class(src.Interface.Message).GetErrorMessage(errorCode,languageID)
	set obj.errorMessage=before_errorMessage_after
	quit obj
}

/// trycatch的返回
/// param :e 传入的异常    errorInfo  异常信息（如："获取角色列表出错:w ##class("_$ClassName()_").GetGroupList("_jsonObj.%ToJSON()_")"）
ClassMethod CatchFailToLog(e, errorInfo = "", errorCode = "")
{
	new (e,errorInfo,errorCode)
	set status=e.AsStatus()
	set rowId=##class(src.Interface.Message).InsErrRecord($piece(##class(%SYSTEM.Status).GetErrorCodes(status),","),errorInfo,$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," "))
	if (errorCode'=""){
		quit ..FailInfoByCode(errorCode)
	}else{
		quit ..FailInfoByCode("04000007","","",rowId)   ;程序错误,错误代码：
	}
}

}
