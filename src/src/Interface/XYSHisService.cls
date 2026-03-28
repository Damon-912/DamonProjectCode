Class src.Interface.XYSHisService Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock, Not SqlRowIdPrivate ]
{

/// w ##class(src.Interface.XYSHisService).XYSHisService({"params":[{"stDate":"2024-06-20","endDate":"2024-06-25","auditFlag":"Y","stasType":"Y"}],"code":"02020126","session":[{"userID":"267","locID":"","groupID":"11","groupDesc":"医保专员","hospID":"11","sessionID":"WjbIl5cQh6","hospCode":"H21","language":"","deviceID":"","hostName":"","ipv4":"","ipv6":"","mac":""}]},"HIS","Cloudinsunew")
/// w ##class(src.Interface.XYSHisService).XYSHisService({"code":"YJ001","message":"{\"patName\":\"杨萌萌\",\"patNameSpell\":\"YMM\",\"patSex\":\"女\",\"patAge\":\"42岁\",\"patID\":\"0001504935\",\"patAddress\":\"北京市北京市辖区朝阳区六里屯街道\",\"patNation\":\"汉族\",\"IDCardNo\":\"130705198205150025\",\"patBirthDate\":\"1982-05-15\",\"patMobile\":\"13269960993\",\"patMedicalNo\":\"\",\"admDate\":\"2025-01-02\",\"hospCode\":\"H12\",\"admLocCode\":\"H121011YZK\",\"admDoctorCode\":\"120018\",\"admNo\":\"OP2025010200038\",\"admType\":\"O\",\"appList\":[{\"appNo\":\"H12AppNo202501020097\",\"appDate\":\"2025-01-02\",\"appTime\":\"09:18:54\",\"appPurpose\":\"\",\"HPIllness\":\"\",\"sign\":\"\",\"chiefComplaint\":\"\",\"ordData\":[{\"ordID\":\"2390471||23170212\",\"medCatDesc\":\"检查\",\"medSubCatDesc\":\"特检科检查\",\"medCode\":\"TJK000231\",\"medDesc\":\"眼底照相(欧堡)\",\"outerMedCode\":\"\",\"outerMedDesc\":\"\",\"ordPrice\":\"155.00\",\"ordQty\":1,\"ordStatusCode\":\"E\",\"ordBillCode\":\"P\",\"ordPriorityCode\":\"NORM\",\"ordLocCode\":\"H121011YZK\",\"ordLocDesc\":\"泪道与眼整形科\",\"ordReLocCode\":\"H121000TJK\",\"ordReLocDesc\":\"特检科\",\"ordDoctorCode\":\"120018\",\"ordDoctorDesc\":\"张晓林\",\"ordDate\":\"2025-01-02\",\"ordTime\":\"09:16:42\",\"EMFlag\":\"\",\"note\":\"\",\"partList\":[{\"partID\":\"3||9\",\"partCode\":\"ou\",\"partStatusCode\":\"V\"}]},{\"ordID\":\"2390471||23170215\",\"medCatDesc\":\"检查\",\"medSubCatDesc\":\"特检科检查\",\"medCode\":\"S000872\",\"medDesc\":\"光学相干断层成像（OCT）\",\"outerMedCode\":\"\",\"outerMedDesc\":\"\",\"ordPrice\":\"200.00\",\"ordQty\":1,\"ordStatusCode\":\"E\",\"ordBillCode\":\"P\",\"ordPriorityCode\":\"NORM\",\"ordLocCode\":\"H121011YZK\",\"ordLocDesc\":\"泪道与眼整形科\",\"ordReLocCode\":\"H121000TJK\",\"ordReLocDesc\":\"特检科\",\"ordDoctorCode\":\"120018\",\"ordDoctorDesc\":\"张晓林\",\"ordDate\":\"2025-01-02\",\"ordTime\":\"09:16:42\",\"EMFlag\":\"\",\"note\":\"\",\"partList\":[{\"partID\":\"3||9\",\"partCode\":\"ou\",\"partStatusCode\":\"V\"}]}]},{\"appNo\":\"H12AppNo202501020098\",\"appDate\":\"2025-01-02\",\"appTime\":\"09:18:54\",\"appPurpose\":\"\",\"HPIllness\":\"\",\"sign\":\"\",\"chiefComplaint\":\"\",\"ordData\":[{\"ordID\":\"2390471||23170217\",\"medCatDesc\":\"处置治疗\",\"medSubCatDesc\":\"眼科治疗\",\"medCode\":\"GYZL000069\",\"medDesc\":\"角膜地形图(眼表仪)\",\"outerMedCode\":\"\",\"outerMedDesc\":\"\",\"ordPrice\":\"140.00\",\"ordQty\":1,\"ordStatusCode\":\"E\",\"ordBillCode\":\"P\",\"ordPriorityCode\":\"NORM\",\"ordLocCode\":\"H121011YZK\",\"ordLocDesc\":\"泪道与眼整形科\",\"ordReLocCode\":\"H120000GYS\",\"ordReLocDesc\":\"干眼治疗室\",\"ordDoctorCode\":\"120018\",\"ordDoctorDesc\":\"张晓林\",\"ordDate\":\"2025-01-02\",\"ordTime\":\"09:16:42\",\"EMFlag\":\"\",\"note\":\"\",\"partList\":[]},{\"ordID\":\"2390471||23170218\",\"medCatDesc\":\"处置治疗\",\"medSubCatDesc\":\"眼科治疗\",\"medCode\":\"GYZL000060\",\"medDesc\":\"泪液分泌功能检查(干眼仪)a\",\"outerMedCode\":\"\",\"outerMedDesc\":\"\",\"ordPrice\":\"50.00\",\"ordQty\":1,\"ordStatusCode\":\"E\",\"ordBillCode\":\"P\",\"ordPriorityCode\":\"NORM\",\"ordLocCode\":\"H121011YZK\",\"ordLocDesc\":\"泪道与眼整形科\",\"ordReLocCode\":\"H120000GYS\",\"ordReLocDesc\":\"干眼治疗室\",\"ordDoctorCode\":\"120018\",\"ordDoctorDesc\":\"张晓林\",\"ordDate\":\"2025-01-02\",\"ordTime\":\"09:16:42\",\"EMFlag\":\"\",\"note\":\"\",\"partList\":[]}]}],\"diagList\":[{\"ID\":\"2203375||3922077\",\"ICD10Code\":\"H10.900\",\"ICD10\":\"结膜炎\",\"DiagDir\":\"角结膜病\",\"Remarks\":\"\",\"MainFlag\":\"Y\"},{\"ID\":\"2203375||3922078\",\"ICD10Code\":\"H16.202\",\"ICD10\":\"干眼症\",\"DiagDir\":\"干眼症\",\"Remarks\":\"\",\"MainFlag\":\"N\"}]}","orgCode":"1001"},"H12","BJYWReceivePacsData12")
/// ServerIP：http://123.22.10.29:8469
/// ##class(src.Interface.XYSHisService).XYSHisService(InputData,"HIS","CloudInsu23","","http://10.1.10.29:8469")
ClassMethod XYSHisService(InputData, externalCode, ServicePublishCode, Timeout = "", ServerIP = "")
{
	new (InputData, externalCode, ServicePublishCode, Timeout,ServerIP)
	if (ServicePublishCode="Cloudinsunew")&(ServerIP="")
	{
		//医保平台走直连，不再走中台 by 20240627 HYG
		set httpStream=..CloudinsunService(InputData)
		quit httpStream
	}
 	set inputObj={}
	set externalData={}
	set externalData.externalCode=externalCode
	set externalData.ServicePublishCode=ServicePublishCode
	set externalData.ServerIP=ServerIP
	set inputObj.externalData=externalData
	set inputObj.InputData=InputData
	set postStream=##class(%GlobalCharacterStream).%New()
	do inputObj.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.6:52773/External/hipExternalMutiple"
	do httprequest.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	set httprequest.EntityBody = postStream
	set:Timeout'="" httprequest.Timeout=Timeout
	set src=httprequest.Post(url,0) 
	set httpStream=httprequest.HttpResponse.Data
	quit httpStream
}

ClassMethod XYSEPSPService(inputObj)
{
	new (inputObj)
	set postStream=##class(%GlobalCharacterStream).%New()
	do inputObj.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.6:52773/EPSPExternal/espExternalMutiple"
	do httprequest.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	set httprequest.EntityBody = postStream
	set src=httprequest.Post(url,0) 
	set httpStream=httprequest.HttpResponse.Data
	quit httpStream
}

/// 电子发票各个医院前置机
/// w ##class(src.Interface.XYSHisService).ElectronService({"placeCode":"819","operator":"李玉峰","remark":"测试","billNoList":[{"billCode":"428001","billBatchCode":"44060119","copyNum":4999,"billBgnNo":"0007525141","billEndNo":"0007530140"}]},"billStockOut").Read()
ClassMethod ElectronServiceNew(Data, ServicePublishCode, HospID)
{
	new (Data, ServicePublishCode,HospID)
	set inputObj={"externalData":{"externalCode":"DHCC","ServicePublishCode":(ServicePublishCode)}}
	set inputObj.InputData=Data
	set httpStream=##class(src.Interface.XYSHisService).XYSYunHisService(inputObj, "4403001","FrontEndProcessorZYY")
	quit httpStream
}

/// 电子发票
/// w ##class(src.Interface.XYSHisService).ElectronService({"placeCode":"819","operator":"李玉峰","remark":"测试","billNoList":[{"billCode":"428001","billBatchCode":"44060119","copyNum":4999,"billBgnNo":"0007525141","billEndNo":"0007530140"}]},"billStockOut").Read()
ClassMethod ElectronService(Data, ServicePublishCode, HospID)
{
	new (Data, ServicePublishCode,HospID)
	set inputObj={"externalData":{"externalCode":"DHCC","ServicePublishCode":(ServicePublishCode)}}
	set postStream=##class(%GlobalCharacterStream).%New()
	set inputObj.InputData=Data
	do inputObj.%ToJSON(.postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.6:52773/External/hipExternalMutiple"
	do httprequest.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	set httprequest.EntityBody = postStream
	set src=httprequest.Post(url,0) 
	set httpStream=httprequest.HttpResponse.Data
	quit httpStream
}

/// 腾讯云平台
ClassMethod XYSYunHisService(InputData, externalCode, ServicePublishCode)
{
	set inputObj={}
	set externalData={}
	set externalData.externalCode=externalCode
	set externalData.ServicePublishCode=ServicePublishCode
	set inputObj.externalData=externalData
	set inputObj.InputData=InputData
	set postStream=##class(%GlobalCharacterStream).%New()
	do inputObj.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.6:52773/External/hipExternalMutiple"
	do httprequest.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	set httprequest.EntityBody = postStream
	set src=httprequest.Post(url,0) 
	set httpStream=httprequest.HttpResponse.Data
	quit httpStream
}

ClassMethod XYS195Service(InputData)
{
	set postStream=##class(%GlobalCharacterStream).%New()
	do InputData.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	// set url="http://xys.szxys.cn:3087/External/hipExternalMutiple"
	//set url="http://172.18.100.85:52773/External/hipExternalMutiple"
	set url="http://172.16.2.6:52773/HIPFrontEnd/hipInternalMutiple"
	do httprequest.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	set httprequest.EntityBody = postStream
	set src=httprequest.Post(url,0) 
	set httpStream=httprequest.HttpResponse.Data
	quit httpStream
}

/// 统一支付平台
ClassMethod XYSUPPService(postObj)
{
	set postStream=##class(%GlobalCharacterStream).%New()
	do postObj.%ToJSON(postStream)
	set request=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.10:52773/UPPExternal/UPPExternalMutiple2"
	do request.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	set request.EntityBody = postStream
	set request.Timeout=90
	set src=request.Post(url,0) 
	set httpStream=request.HttpResponse.Data
	quit httpStream
}

/// w ##class(src.Interface.XYSHisService).YBService("","")
ClassMethod YBService(InputData, HospID)
{
 	//set inputStrChange="{inParams:\"""_343234343_"\""}"
 	set inputStrChange={"params": [{"admID": "489","insuAdmID": "66","userID": "162","locID": "42","hospID": "25","groupID": "315","ip": "10.9.3.202","process": "F04.06.04.01"}],"code": "05210050"}
 	//set inputStrChange={"inParams":(inputStrChange.%ToJSON())}
 	b 
	set inputStrChange=$ZCONVERT(inputStrChange.%ToJSON(),"O","URL")
	set url="http://"_"127.0.0.1"_":62534/XYSWCFService/DynamicLoadingDLL?&input={""inputDir"":""ReadYBCard/INSUYBAHSYB.dll"",""clsName"":""INSUYBAHSYB.INSUYBAHSYB"",""funcName"":""InsuREGPay"",""dllInput"":"_inputStrChange_"}"
	b ;11

	set httprequest=##class(%Net.HttpRequest).%New()
	Set httprequest.ContentType="application/json"
	do httprequest.EntityBody.SetAttribute("Conten-Type","application/json")
	set httprequest.Params=url 
	set httprequest.Timeout=100
	set src=httprequest.Get(url)
	set httprequest.Timeout=100
	set outobj={}
	b  ;;;
	if $$$ISERR(src) 
	{
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(src),",")
	    set errorMessage=$System.Status.GetErrorText(src,"cn")
	    set outobj.errorCode=errorCode
	    set outobj.errorMessage=errorMessage
	    quit outobj
	}
	set oupto=httprequest.HttpResponse.Data.Read()
	set oupto=##class(src.Insurance.Preservation.InsuPayData).HttpOutstr(oupto)
	set outobj=##class(%DynamicAbstractObject).%FromJSON(oupto)
	b  ;;;
	quit outobj
}

ClassMethod HCRMService(InputData, externalCode, ServicePublishCode)
{
	set inputObj={}
	set inputObj.hisCode=externalCode
	set inputObj.serviceCode=ServicePublishCode
	set inputObj.serviceInput=InputData
	set postStream=##class(%GlobalCharacterStream).%New()
	do inputObj.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.6:52773/prmp/PRMPforHIS"
	do httprequest.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	set httprequest.EntityBody = postStream
	set src=httprequest.Post(url) 
	set httpStream=httprequest.HttpResponse.Data
	b ;2324
	quit httpStream
}

/// 调用本地服务
ClassMethod BDService(InputData, funcName, clsName, inputDir, url)
{
	new (InputData, funcName, clsName,inputDir,url)
	set input={}
	set input.inputDir=inputDir
	set input.clsName=clsName
	set input.funcName=funcName
    set input.dllInput=InputData.%ToJSON() 
    set httprequest=##class(%Net.HttpRequest).%New()
	set httprequest.ContentType="application/json"  
	do httprequest.EntityBody.SetAttribute("Conten-Type","application/json;charset=gb2312") 
	set httprequest.Timeout=500000
	set url=url_"?&input="_input.%ToJSON()
	set src=httprequest.Get(url) 
	set oupto=httprequest.HttpResponse.Data.Read()
	quit:oupto="" oupto
	set rtn={}.%FromJSON(({}.%FromJSON(oupto).d))
	quit rtn
}

/// w ##class(src.Interface.XYSHisService).HisService()
ClassMethod HisService(InputData)
{
	new (InputData)
	set postStream=##class(%GlobalCharacterStream).%New()
	do InputData.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.6:52773/bdhealth/sysInternalMutiple"
	do httprequest.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	set httprequest.EntityBody = postStream
	set httprequest.Timeout=500000
	set src=httprequest.Post(url,0) 
	set httpStream=httprequest.HttpResponse.Data
	quit httpStream
}

/// 新电子病历接口(2.14)
/// creator：DYK
/// data：2023-11-09
/// w ##class(src.Interface.XYSHisService).NewEMRService()
ClassMethod NewEMRService(InputData)
{
	new (InputData)
	set postStream=##class(%GlobalCharacterStream).%New()
	do InputData.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.14:52773/EMRService/sysInternalMutiple"
	do httprequest.SetHeader("Authorization","Basic cHVydWk6cHIxMjM0")
	set httprequest.EntityBody = postStream
	set httprequest.Timeout=500000
	set src=httprequest.Post(url,0)
	set httpStream=httprequest.HttpResponse.Data
	set rtn={}.%FromJSON(httpStream)
	//b ;rtn
	quit rtn
}

/// 新病历session串(2.14)
/// creator：DYK
/// data：2023-11-09
/// w ##class(src.Interface.XYSHisService).GetEMRSession()
ClassMethod GetEMRSession()
{
	 set ret={},session={}
	 set param={"params":[{"username":"admin","password":"abc123"}],"code":"1011"}
	 set ret=..NewEMRService(param)
	 set:ret.errorCode="0" session=ret.result
	 return session
}

/// w ##class(src.Interface.XYSHisService).INSUService({"params":[{"businessCode":"BloodTransfusionList4601","businessID":"Blood20220901","output":{"errorCode":"-1","errorMessage":"未能加载文件或程序集“file:///C:\\ProgramData\\prykNT\\prBrowser\\bin\\service\\plugins\\INSUNew\\PTMedInsuInterface.dll”或它的某一个依赖项。系统找不到指定的文件。"},"input":{"params":[{"data":[{"mdtrt_sn":"Blood20220901","mdtrt_id":"Blood20220901","psn_no":"","palg_no":"Blood20220901","frozen_no":"Blood20220901","cma_date":"2022-09-01","rpot_date":"2022-09-03","cma_matl":"穿刺细胞","clnc_dise":"甲状线结节","exam_fnd":"甲状线结节","sabc":"甲状线结节","palg_diag":"甲状线结节","rpot_doc":"测试医生","vali_flag":"N","abo_code":"B","rh_code":"Rh(-)","bld_natu_code":"01","bld_abo_code":"B","bld_rh_code":"Rh(-)","bld_cat_code":"15","bld_amt":"200","bld_amt_unt":"ml","bld_defs_type_code":"1","bld_cnt":1,"bld_time":"2022-09-01 07:53:30","bld_rea":"失血过多"}]}],"businessType":"P1","funNO":"4601","session":[{"userID":"135","locID":1,"groupID":"1","groupDesc":"管理员","hospID":"7","sessionID":"wysaDkSmTz","hospCode":"H11","language":"CN","deviceID":"ATM\\huang","hostName":"ATM\\huang","ipv4":"192.168.0.11","ipv6":"fe80::c4f6:e7c2:2c91:15e5%5","mac":"A0-E7-0B-67-F3-31"}],"interfaceinfo":{"medInsuInterfaceID":"2","hospitalID":7,"interfaceNO":"A","interfaceName":"基线版医保","hospitalNO":"H23010301130","hospitalLevel":"3","centerURL":"http://200.200.1.111:11120/fsi/api","centerURL2":"","dLLName":"HaErBinMI.dll","areaCode":"230100","useFlag":"True","hospitalName":"哈尔滨普瑞眼科医院","serialNO":1,"ID":"2","operatorNO":"admin","operatorName":"系统管理员"}}}],"code":"02020007","session":[{"userID":"135","locID":1,"groupID":"1","groupDesc":"管理员","hospID":"7","sessionID":"wysaDkSmTz","hospCode":"H11","language":"CN","deviceID":"ATM\\huang","hostName":"ATM\\huang","ipv4":"192.168.0.11","ipv6":"fe80::c4f6:e7c2:2c91:15e5%5","mac":"A0-E7-0B-67-F3-31"}]})
ClassMethod INSUService(InputData)
{
	new (InputData)
	set postStream=##class(%GlobalCharacterStream).%New()
	do InputData.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.10:52773/cloudInsu/sysInternalMutiple"
	do httprequest.SetHeader("Authorization","Basic cHJfaHlnOmpqMTIzNDU2")
	set httprequest.EntityBody = postStream
	set src=httprequest.Post(url,0) 
	set httpStream=httprequest.HttpResponse.Data
	quit httpStream
}

/// 微信平台
ClassMethod WeChatService(postObj)
{
	new (postObj)
	set postStream=##class(%GlobalCharacterStream).%New()
	do postObj.%ToJSON(postStream)
	set request=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.10:52773/WeChat/sysMutiple"
	do request.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	set request.EntityBody = postStream
	set src=request.Post(url,0)
	set httpStream=request.HttpResponse.Data
	quit httpStream
}

/// 南昌成都医保平台
ClassMethod MedInsuService(InputData)
{
	new (InputData)
	set postStream=##class(%GlobalCharacterStream).%New()
	do InputData.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	//set url="http://172.16.2.145:52773/insu/sysMedInsu"
	set url="http://172.16.2.10:52773/insu/sysMedInsu"
	;迁移后改为172.16.2.10
	do httprequest.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	set httprequest.EntityBody = postStream
	set src=httprequest.Post(url,0) 
	set httpStream=httprequest.HttpResponse.Data		
	quit httpStream
}

/// 飞书平台
ClassMethod FeiShuService(postObj)
{
	set postStream=##class(%GlobalCharacterStream).%New()
	do postObj.%ToJSON(postStream)
	set request=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.10:52773/feishuservice/sysString"
	do request.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	set request.EntityBody = postStream
	set src=request.Post(url,0) 
	set httpStream=request.HttpResponse.Data
	quit httpStream
}

/// 视光进销存服务
/// w ##class(src.Interface.XYSHisService).InventoryService({"externalData":{"externalCode":"HIS","ServicePublishCode":"updatePayStatus"},"InputData":{"patientNo":"0000968982","salesNo":"","billStatus":"TP","money":0,"billDate":"","billTime":"","deposit":168}}).Read()
ClassMethod InventoryService(postObj)
{
	new (postObj)
	if '$IsObject(postObj) {
		set postObj={}.%FromJSON(postObj)
	}
	set inputObj={}
	set externalData={}
	set externalData.externalCode="HIS"
	set externalData.ServicePublishCode="updatePayStatus"
	set inputObj.externalData=externalData
	set inputObj.InputData=postObj
	set httprequest=##class(%Net.HttpRequest).%New()
	do httprequest.SetHeader("Authorization","Basic cHJoaXA6cHJoaXBAMjAyMA==")
	do httprequest.EntityBody.Write(inputObj.%ToJSON())
	//set url="http://116.153.70.91/test/api/puwx/updatePayStatus.do"
	//set url="http://172.20.2.21:8066/oppsisystem/api/puwx/updatePayStatus.do"
	set url="http://172.16.2.6:52773/External/hipExternalMutiple"
	set ^TMP("InventoryService","Begin",$zd(+$h,3),$zt($p($h,",",2),1)_$p($zts,",",2))=inputObj.%ToJSON()
	set src=httprequest.Post(url)
	set httpStream=httprequest.HttpResponse.Data
	set retObj={}
	try {
		set retObj={}.%FromJSON(httpStream)
		set ^TMP("InventoryService","Return",$zd(+$h,3),$zt($p($h,",",2),1)_$p($zts,",",2))=retObj.%ToJSON()
	}catch(e){
		set ^TMP("InventoryService","ReturnErr",$zd(+$h,3),$zt($p($h,",",2),1)_$p($zts,",",2))=$replace(##class(%SYSTEM.Status).GetErrorText(e.AsStatus(),"cn"),"^"," ")
		set retObj={}
	}
	quit retObj
}

/// w ##class(src.Interface.XYSHisService).txtService122222()
ClassMethod txtService122222()
{
	set content=
	{
	    "type":"template",
	    "data":{
	        "template_id":"ctp_AAVTlDenhbob",    // 卡片id，参数必填。可在工具的我的卡片中，通过复制卡片 ID 获取。
	        "template_variable":
	        {    
	            "locName":"测试科室",    ;// 如果卡片模板内设置了变量，则可以在此处为变量（key）赋值（value）。
	            "outpatientVolume":"99999",
	            "doctorNum":"8888",
	            "admissionVolume":"7777",
	            "dataTime":"2023-11-30"
	        }       
	    }
	}.%ToJSON()
	set postObj={"params":[{"loc":"1376","receivetype":"chat_id","tolocID":"1377","msgtype":"interactive","content":(content)}],"code":"01010003","session":[{"userID":"162","locID":"42","groupID":"315","hospID":"25","sessionID":"6oTKMmiQhi","hospCode":"H03","language":"CN","hostName":"QQ5BH8NC58F2GH2\\Administrator","ipv4":"10.9.3.73","ipv6":"fe80::c81e:8f6c:302d:e62d%5","mac":"50-5B-C2-E4-9C-AD"}]}
	
	set httpStream=..FeiShuService(postObj)
	set resultObj={}.%FromJSON(httpStream)
	b ;???
	quit resultObj
}

/// 云医保平台
ClassMethod CloudinsunService(inputObj)
{
	new (inputObj)
#;	Set a = ##class(%GlobalCharacterStream).%New()
#;	Set sc = {"errorCode":"0","errorMessage":""}.%ToJSON(.a)
#;	Quit a
	set postStream=##class(%GlobalCharacterStream).%New()
	do inputObj.%ToJSON(postStream)
	set httprequest=##class(%Net.HttpRequest).%New()
	set url="http://172.16.2.10:52773/cloudInsu/sysInternalMutiple"
	set httprequest.EntityBody = postStream
	set httprequest.Timeout = 100
	do httprequest.SetHeader("Authorization","Basic cHJfaHlnOmpqMTIzNDU2")
	set src=httprequest.Post(url,0) 
	set httpStream=httprequest.HttpResponse.Data
	quit httpStream
}

/// 甘肃省医疗器械追溯监管系统 73
/// w ##class(src.Interface.XYSHisService).GSTraceBackToService({"qymc":"兰州普瑞雁滩门诊部","tyshxydm":"91620102571645128N","timestamp":"2024-06-26"},"HIS","PRODUDIGETLOG",73)
/// w ##class(src.Interface.XYSHisService).GSTraceBackToService("eyJyZXEiOnsiZXZlbnRfaWQiOiIxMDMwOTQ4Iiwic3ViX3R5cGUiOiJzaGQiLCJxeW1jIjoi5YWw5bee5pmu55Ge55y856eR5Yy76Zmi5pyJ6ZmQ6LSj5Lu75YWs5Y+4IiwidHlzaHh5ZG0iOiI5MTYyMDEwMjU2NjQwODY2MjMiLCJ0aW1lc3RhbXAiOiIyMDI0MDcxNjEwNTUwNDY3NyIsImRhdGFTZXQiOnsic2hkSW5mbyI6W3siQ1BNQ1RZTUMiOiLpnLLmmbDlvpflpJzmiLTlnovmlaPlhYnniYciLCJTSExYIjoiMDEiLCJTSERaQkgiOiIzNDA1MDEiLCJTSFNMIjoxLCJTSFNKIjoiMjAyNC0wNy0xNSIsIllTSFNMIjoxLCJUWVNIWFlETVNISkciOiI5MTM0MDUwME1BOEw5TkFLWDUiLCJTSERaIjoi5a6J5b6955yB6ams6Z6N5bGx5biC6YOR6JKy5riv5paw5Yy65Lit6aOe5aSn6YGT5YyX5q61NzUw5Y+3MTLmoIszLTIiLCJTSEpHTUMiOiLpqazpno3lsbHlurfmtL7ljLvnlpflmajmorDplIDllK7mnInpmZDlhazlj7giLCJGSERaQkgiOiJDSE42MjAxMDIiLCJTUE1DIjoi6Zyy5pmw5b6X5aSc5oi05Z6L5pWj5YWJ54mHIiwiVFlTSFhZRE1GSEpHIjoiOTE2MjAxMDI1NjY0MDg2NjIzIiwiVFlTSFhZRE1ZTVBTRFciOiI5MTYyMDEwMjU2NjQwODY2MjMiLCJGSEpHTUMiOiLlhbDlt57mma7nkZ7nnLznp5HljLvpmaLmnInpmZDotKPku7vlhazlj7giLCJZTVlYUUpaUlEiOiIyMDI4LTA3LTAzIiwiU1lEWUNQQlMiOiIxNzIwIiwiU0ZXQkxaVExDUCI6IjAiLCJESERCSCI6IjEwMzA5NDgiLCJTSERCSCI6IjEwMzA5NDgiLCJUWVNIWFlETVNDUVkiOiIiLCJDUExYIjoiMSIsIlNDUlEiOiIyMDI0LTA3LTA0IiwiU0NQSCI6IlRMMjQwNzAxNzI1IiwiR0dYSCI6IuWknOaItOWeiyIsIkZIREJIIjoiMTAzMDk0OCIsIlNDUVlNQyI6IiIsIkZIRFoiOiLnlJjogoPnnIHlhbDlt57luILnmb3pk7bot68yMjLlj7flhbDlt57mma7nkZ7nnLznp5HljLvpmaIiLCJZTVBTRFdNQyI6IuWFsOW3nuaZrueRnuecvOenkeWMu+mZouaciemZkOi0o+S7u+WFrOWPuCIsIlVESUlORk8iOlt7IkJaQ0oiOiIxIiwiUVhVREkiOiIwMTA4ODA5MDQ5MDc0NTIwMTcyODA3MDMxMFRMMjQwNzAxNzI1IiwiU1lKUVhVREkiOiIwMTA4ODA5MDQ5MDc0NTIwMTcyODA3MDMxMFRMMjQwNzAxNzI1In1dfV19fX0=","HIS","PROD-UDI-UPLOAD",58).Read()
ClassMethod GSTraceBackToService(InputData, externalCode, ServicePublishCode, HospID)
{
	new (InputData, externalCode, ServicePublishCode,HospID)
	//先获取token
	set token=""
	set tokenInfo=$g(^TMP("GSTraceBackToService","token",HospID))
	if tokenInfo'=""
	{
		set tokenObj={}.%FromJSON(tokenInfo)
		set expiresIn=tokenObj.expiresIn
		set tokenUpdateTime=tokenObj.tokenUpdateTime
		set datetimenum=$zdh($p(tokenUpdateTime," ",1),3)*100000+$zth($p(tokenUpdateTime," ",2))+expiresIn-600
		set newdatetimenum=$p($h,",",1)*100000+$p($h,",",2)
		if datetimenum>newdatetimenum
		{
			set token=tokenObj.token
		}
	}
	if token=""
	{
		set secretId=##class(src.Pharmacy.Common.AppCommon).GetAppPropValue("TraceBackTo","secretId","^^^"_HospID)
		set secretKey=##class(src.Pharmacy.Common.AppCommon).GetAppPropValue("TraceBackTo","secretKey","^^^"_HospID)
		set inputdata={
			"secretId": (secretId),
			"secretKey": (secretKey)
		}
		set Tokenstream=##class(src.Interface.XYSHisService).XYSHisService(inputdata,"HIS","GSTBTGetToken",100)      ;HIS调用中台
		set TokenstreamObj={}.%FromJSON(Tokenstream)
		if TokenstreamObj.code'=200
		{
			set outputObj={
				"errorCode":(TokenstreamObj.code),
				"errorMessage":(TokenstreamObj.message)
			}
			set outStream=##class(%GlobalCharacterStream).%New()
			do outputObj.%ToJSON(outStream)
			quit outStream
			
		}
		set dataobj={}.%FromJSON(TokenstreamObj.data)
		if dataobj.code'=200
		{
			set outputObj={
				"errorCode":(dataobj.code),
				"errorMessage":(dataobj.msg)
			}
			set outStream=##class(%GlobalCharacterStream).%New()
			do outputObj.%ToJSON(outStream)
			quit outStream
		}
		set token=dataobj.data.token
		set ^TMP("GSTraceBackToService","token",HospID)=dataobj.data.%ToJSON()
	}
	if ($IsObject(InputData)){
	 	set InputData=InputData.%ToJSON()
	}
	set inputObj={}
	set inputObj.headersData="Authorization:Bearer "_token
	set inputObj.body=InputData
	set httpStream=##class(src.Interface.XYSHisService).XYSHisService(inputObj,externalCode,ServicePublishCode)
	quit httpStream
}

/// InputData json对象
/// ServicePublishCode： SHYSXTCS 测试服务器  SHYSXT 正式服务器
/// sXxlx ：3.2 消息类型码 YY001 医院配送点基础信息传报 YY002	药品当前库存量数据传报 等等
/// w ##class(src.Interface.XYSHisService).SHYSXTToService({"HEAD":{"IP":"192.168.1.1","MAC":"00FFDCF15B5B","BZXX":""},"MAIN":{"DDBH":"123432","DDMXBH":""}},"YY021","SHYSXTCS",49)
ClassMethod SHYSXTToService(InputData, sXxlx, HospID)
{
	new (InputData, sXxlx, HospID)
	set outXml=""
	set flag=##class(src.Insurance.Operation.InsuranceBasicYNMH).JSONObjToXML(InputData,"XMLDATA",.outXml)
	set xmldata="<?xml version="""_"1.0"_""" encoding=""utf-8""?><XMLDATA>"_outXml_"</XMLDATA>"
	set sha160=$system.Encryption.SHAHash(160,$zcvt(xmldata, "O", "UTF8"))
	s sha160 = ##class(src.util.tool).Byte2Hex(sha160)
	s sha160 = $zconvert(sha160, "U")
	set sJgbm=##class(src.Pharmacy.Common.AppCommon).GetAppPropValue("YGYYPT","sJgbm","^^^"_HospID)
	if sXxlx["YY0"
	{
		;//药品
		set sPwd=##class(src.Pharmacy.Common.AppCommon).GetAppPropValue("YGYYPT","sPwd","^^^"_HospID)
		set sUser=##class(src.Pharmacy.Common.AppCommon).GetAppPropValue("YGYYPT","sUser","^^^"_HospID)
		set ServicePublishCode=##class(src.Pharmacy.Common.AppCommon).GetAppPropValue("YGYYPT","ServicePublishCode","^^^"_HospID)
		set inputobj={
			"arg0":(sUser),
			"arg1":(sPwd),
			"arg2":(sJgbm),
			"arg3":("1.0.0.0"),
			"arg4":(sXxlx),
			"arg5":(sha160),
			"arg6":(xmldata)
		}
	}elseif sXxlx["YY1"
	{
		;//耗材
		set sPwd=##class(src.Pharmacy.Common.AppCommon).GetAppPropValue("YGYYPT","sPwd2","^^^"_HospID)
		set sUser=##class(src.Pharmacy.Common.AppCommon).GetAppPropValue("YGYYPT","sUser2","^^^"_HospID)
		set ServicePublishCode=##class(src.Pharmacy.Common.AppCommon).GetAppPropValue("YGYYPT","QXServicePublishCode","^^^"_HospID)
		set inputobj={
			"sUser":(sUser),
			"sPwd":(sPwd),
			"sJgbm":(sJgbm),
			"sVersion":("1.0.0.0"),
			"sXxlx":(sXxlx),
			"sSign":(sha160),
			"xmlData":(xmldata)
		}
	}	
	b ;inputobj
	set ret=##class(src.Interface.XYSHisService).XYSHisService(inputobj,"HIS",ServicePublishCode)
	b ;555
	set resultObj=##class(src.util.tool).XMLToJSON($replace(ret.Read(9999999999999999999999),"'",""))	
	quit resultObj
}

}
