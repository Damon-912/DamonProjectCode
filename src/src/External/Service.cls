Class src.External.Service Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock, Not SqlRowIdPrivate ]
{

Parameter UppUrl [ Final ] = "http://127.0.0.1:52773/UPPExternal/UPPExternalMutiple";

/// w ##class(src.External.Service).HisService({"params":[{"userName":"","passWord":"","loginLocID":"338","loginGroupID":"1","loginHospID":"67","deviceID":"","IP":"10.1.23.29","userLogonType":"03","mac":""}],"code":"1011"})
ClassMethod HisService(InputData, HospCode)
{
	new (InputData,HospCode,hisServiceConfig,url,httprequest,postStream,httpStream)
	set hisServiceConfig=InputData.hisServiceConfig
	
	// 如果没传递配置，使用默认配置
	if '$IsObject(hisServiceConfig) {
		set hisServiceConfig={"hisIP":"172.16.1.6","hisPort":"52773","hisURL":"bdhealth/","authorization":"Basic cHJoaXA6cHJoaXBAMjAyMA=="}
	}
	
	set postStream=##class(%GlobalCharacterStream).%New()
	do InputData.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	
	// 拼接URL（支持http/https协议）
	set protocol="http://"
	if hisServiceConfig.hisProtocol'="" {
		set protocol=hisServiceConfig.hisProtocol_"://"
	} elseif hisServiceConfig.hisPort="443" {
		set protocol="https://"
	}
	set url=protocol_hisServiceConfig.hisIP
	if hisServiceConfig.hisPort'="" && (hisServiceConfig.hisPort'="80") && (hisServiceConfig.hisPort'="443") {
		set url=url_":"_hisServiceConfig.hisPort
	}
	
	// 确保URL路径正确（不再硬编码sysInternalMutiple）
	set hisURL=hisServiceConfig.hisURL
	// 移除hisURL开头的斜杠（避免URL出现双斜杠）
	if $extract(hisURL,1)="/" {
		set hisURL=$extract(hisURL,2,*)
	}
	// 确保hisURL以斜杠结尾
	if (hisURL'="") && ($extract(hisURL,*)'="/") {
		set hisURL=hisURL_"/"
	}
	set url=url_"/"_hisURL
	
	// 设置Authorization头
	if hisServiceConfig.authorization'="" {
		do httprequest.SetHeader("Authorization",hisServiceConfig.authorization)
	}
	
	// 日志：输出实际调用的URL
	write "调用HIS服务URL：",url,!
	
	set httprequest.EntityBody = postStream
	set src=httprequest.Post(url,0) 
	;//b ;3333
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
