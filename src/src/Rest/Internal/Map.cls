/// gjg
/// 2022-6-29
/// 入口类
Class src.Rest.Internal.Map Extends (%RegisteredObject, %XML.Adaptor, %CSP.REST)
{

Parameter HandleCorsRequest = 1;

Parameter CONVERTINPUTSTREAM = 1;

Parameter UseSession As Integer = 0;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/sysInternalString/:input" Method="GET" Call="getStringParams"/>
<Route Url="/sysInternalMutiple" Method="POST" Call="postMutipleParams" />
<Route Url="/sysInternalMutipleEncrypt" Method="POST" Call="postMutipleParamsEncrypt" />
<Route Url="/sysInternalMutipleSign" Method="POST" Call="postMutipleParamsSign" />
<Route Url="/fileUpload" Method="POST" Call="uploadFile" />
</Routes>
}

ClassMethod getStringParams(input As %String = "") As %Status
{
	#Dim e as %Exception.AbstractException
	#Dim status as %Status
	Try {
		If $Data(%response) Set %response.ContentType="application/json"
		If $Data(%response) Set %response.CharSet="UTF-8"
		set str=""
		set outputobj={}
		set outputobj.errorCode="0"
		set outputobj.errorMessage="收到了"_input
		;do outputobj.%ToJSON()
		write outputobj.%ToJSON()
	} Catch (e) {
		Set status=e.AsStatus()
		Do ..ErrorHandler(status)
    }    
    Quit $$$OK
}

ClassMethod postMutipleParams() As %Status
{
    #Dim e as %Exception.AbstractException
    #Dim status as %Status
    #Dim %response As %CSP.Response
	Set postObj=##class(%DynamicObject).%FromJSON(%request.Content)
    Try {
	    set rtn=..CheckLisence()
	    quit:rtn'=0
		If $Data(%response) Set %response.ContentType="application/json"
		If $Data(%response) Set %response.CharSet="UTF-8"
		Set rtn=##class(src.Rest.Internal.Interface).postMutipleParams(.postObj)
    } Catch (e) {
		Set status=e.AsStatus()
		Do ..ErrorHandler(status)
    }
    Quit $$$OK
}

ClassMethod postMutipleParamsEncrypt() As %Status
{
    #Dim e as %Exception.AbstractException
    #Dim status as %Status
    #Dim %response As %CSP.Response
	set postObj=%request.Content.Read(999999999999)
    Try {
	    set rtn=..CheckLisence()
	    quit:rtn'=0
		If $Data(%response) Set %response.ContentType="application/json"
		If $Data(%response) Set %response.CharSet="UTF-8"
		Set rtn=##class(src.Rest.Internal.Interface).postMutipleParamsEncrypt(.postObj)
    } Catch (e) {
		Set status=e.AsStatus()
		Do ..ErrorHandler(status)
    }
    Quit $$$OK
}

ClassMethod postMutipleParamsSign() As %Status
{
    #Dim e as %Exception.AbstractException
    #Dim status as %Status
    #Dim %response As %CSP.Response
	set host=%request.Host
	Set postObj=##class(%DynamicObject).%FromJSON(%request.Content)
    Try {
	    set rtn=..CheckLisence()
	    quit:rtn'=0
		If $Data(%response) Set %response.ContentType="application/json"
		If $Data(%response) Set %response.CharSet="UTF-8"
		set postObj.host=host
		Set rtn=##class(src.Rest.Internal.Interface).postMutipleParamsSign(.postObj)
    } Catch (e) {
		Set status=e.AsStatus()
		Do ..ErrorHandler(status)
    }
    Quit $$$OK
}

ClassMethod uploadFile()
{
	#Dim e as %Exception.AbstractException
    #Dim sc as %Status
    #Dim %response As %CSP.Response
    Try {
		If $Data(%response) Set %response.ContentType="application/json"
		If $Data(%response) Set %response.CharSet="UTF-8"
		Set request = %request
    	Set rtn = ##class(src.Rest.Internal.Interface).UploadFile(request)
   		write rtn.%ToJSON()
    } Catch (e) {
		Set status=e.AsStatus()
		Do ..ErrorHandler(status)
    }
	Quit $$$OK
}

ClassMethod CheckLisence()
{
	quit 0	//不再验证授权码 modify by liangjiaquan 2022.2.27
	set iv1=##class(src.util.Lisence.Operation).%GetParameter("IV1")
	set iv2=##class(src.util.Lisence.Operation).%GetParameter("IV2")
	set iv3=##class(src.util.Lisence.Operation).%GetParameter("IV3")
	set iv4=##class(src.util.Lisence.Operation).%GetParameter("IV4")
	set iv5=##class(src.util.Lisence.Operation).%GetParameter("IV5")
	set code=$e(iv1,1,1)_$e(iv2,2,2)_$e(iv3,3,3)_$e(iv4,4,4)_$e(iv5,5,5)
	set rtn=##class(src.util.Lisence.Operation).CheckLisence(code,{})
	set checkValue=$p(rtn,"^",1)
	if checkValue="0"{
	}else{
		Quit ..ErrorHandlerCode(checkValue,"授权码错误")
	}
	quit checkValue
}

ClassMethod ErrorHandler(status)
{
    #Dim errorCode, errorMessage as %String;
    set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
    set errorMessage=##class(%SYSTEM.Status).GetOneStatusText(status,"","cn")
    Quit ..ErrorHandlerCode(errorCode,errorMessage)
}

ClassMethod ErrorHandlerCode(errorCode, errorMessage) As %Status
{
	set outputobj={}
	set outputobj.errorCode=errorCode
	set outputobj.errorMessage=errorMessage
	write outputobj.%ToJSON()
    quit $$$OK
}

}
