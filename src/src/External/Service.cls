Class src.External.Service Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock, Not SqlRowIdPrivate ]
{

Parameter UppUrl [ Final ] = "http://127.0.0.1:52773/UPPExternal/UPPExternalMutiple";

/// w ##class(src.External.Service).HisService({"params":[{"userName":"","passWord":"","loginLocID":"338","loginGroupID":"1","loginHospID":"67","deviceID":"","IP":"10.1.23.29","userLogonType":"03","mac":""}],"code":"1011"})
ClassMethod HisService(InputData, HospID)
{
	new (InputData,HospID)
	set postStream=##class(%GlobalCharacterStream).%New()
	do InputData.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.6:52773/bdhealth/sysInternalMutiple"
	set HisIP=##class(src.Config.ModuleConfig).GetConfigByCode("HisIP",HospID)
	if HisIP'["http"{
		set HisIP="http://"_HisIP
	}
	set HisPort=##class(src.Config.ModuleConfig).GetConfigByCode("HisPort",HospID)
	set HisURL=##class(src.Config.ModuleConfig).GetConfigByCode("HisURL",HospID)
	set Authorization=##class(src.Config.ModuleConfig).GetConfigByCode("Authorization",HospID)
	set:Authorization'["Basic" Authorization="Basic "_Authorization
	set url=HisIP_":"_HisPort_HisURL
	do httprequest.SetHeader("Authorization",Authorization)
	set httprequest.EntityBody = postStream
	set src=httprequest.Post(url,0) 
	;b ;3333
	set httpStream=httprequest.HttpResponse.Data
	quit httpStream
}

ClassMethod UppService(postObj)
{
	new (postObj)
	set retObj={}
	try {
		set errorCode=0,errorMessage="成功",result={}
		set postStream=##class(%GlobalCharacterStream).%New()
		do postObj.%ToJSON(postStream)
		set httprequest=##class(%Net.HttpRequest).%New()
		do httprequest.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
		set httprequest.EntityBody = postStream
		set httprequest.Timeout=120
		set src=httprequest.Post(..#UppUrl,0) 
		set httpStream=httprequest.HttpResponse.Data
		set retObj=##class(%Library.DynamicObject).%FromJSON(httpStream)
	}catch(e){
		set errorCode=-1
	    set errorMessage=$System.Status.GetErrorText(e.AsStatus(),"cn")
	    set retObj={
			"errorCode":(errorCode),
			"errorMessage":(errorMessage)
		}
	}
	
	quit retObj
}

}
