Class src.Config.RaqSoft Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 获取润乾报表参数设置
/// Code:
/// w ##class(src.Config.RaqSoft).GetParams({"code":"01010050","session":[{"userID":"135","locID":1,"groupID":"1","groupDesc":"管理员","hospID":"7","sessionID":"KbDsQFeQ0U","hospCode":"H11","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod GetParams(postObj)
{
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set session=postObj.session.%Get(0)
		set hospID=session.hospID
		set hospCode=session.hospCode
		///获取HIS数据
		b ;; hospCode
		set postObj={"params":[{"hospCode":(hospCode)}],"code":"01040290"}  ///,"session":(postObj.session)
		set ret=##class(src.External.Service).HisService(postObj,hospID)	
		set obj=##class(%Library.DynamicObject).%FromJSON(ret)
		b ;; obj
		set path=""
		if obj.errorCode=0{
			set path=obj.result.path
   		}else{
	   		set resultObj.errorCode=obj.errorCode
	   		set resultObj.errorMessage=obj.errorMessage
	   		quit
	   	}
	   	set resultObj.result.path=path
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="获取润乾报表参数设置出现问题:w ##class("_$ClassName()_").GetParams("_postObj.%ToJSON()_")"
		b ;; errorMessage
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
	quit resultObj
}

}
