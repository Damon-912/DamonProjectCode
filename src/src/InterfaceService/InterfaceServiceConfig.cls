/// 接口服务配置
Class src.InterfaceService.InterfaceServiceConfig Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 保存读写类型配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.InterfaceService.InterfaceServiceConfig).SaveSysServiceTypeConfig()
ClassMethod SaveSysServiceTypeConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set dataObj={},dataArr=[]
		set dataObj.ID=params.id
		set dataObj.HospDr=$case(params.hospID'="",1:params.hospID,:session.hospID)
		set dataObj.Code=params.code
		set dataObj.Descripts=params.descripts
		set dataObj.ServiceIP=params.serviceIP
		set dataObj.Port=params.port
		set dataObj.Authorization=params.authorization
		do dataArr.%Push(dataObj)
		;b	;12121
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className="User.CBSysServiceType"			
		set operateObj.data=dataArr		
		if params.id=""{
			set rtn=##class(src.util.operatetable).Insert(.operateObj) ;调用公共类方法记录修改日记
		}else{				
			set rtn=##class(src.util.operatetable).Update(.operateObj) ;调用公共类方法记录修改日记
		}
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		if errorCode'="0"{
			set resultObj.errorCode=errorCode
			set resultObj.errorMessage=errorMessage
			quit
		}
		
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="保存读写类型配置出错:w ##class("_$ClassName()_").SaveSysServiceTypeConfig("_jsonObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 获取读写类型配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.InterfaceService.InterfaceServiceConfig).GetSysServiceTypeConfig({"params":[{"hospID":"6","code":"hh","descripts":"xixi"}]})
ClassMethod GetSysServiceTypeConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try{
		if (jsonObj.%IsDefined("pagination")'=0) {
			set pagationObj=jsonObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
			set currentPage=pagationObj.currentPage
		}
		set params=jsonObj.params.%Get(0)
		set compareHospID=params.hospID
		set compareCode=params.code
		set compareDescripts=params.descripts
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_SysServiceType"		
		if (compareHospID'="")||(compareCode'="")||(compareDescripts'="") 
		{
			set sql=sql_" WHERE 1=1"
			set:(compareCode'="") sql=sql_" AND Code LIKE '%"_compareCode_"%'"
			set:(compareDescripts'="") sql=sql_" AND Descripts LIKE '%"_compareDescripts_"%'"
		}
		b	;111
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.serviceIP=result.%Get("ServiceIP")
			set dataObj.port=result.%Get("Port")
			set dataObj.authorization=result.%Get("Authorization")
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="获取读写类型配置出错:w ##class("_$ClassName()_").GetSysServiceTypeConfig("_jsonObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")	
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 删除读写类型配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.InterfaceService.InterfaceServiceConfig).DeleteSysServiceTypeConfig()
ClassMethod DeleteSysServiceTypeConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		if params.id="" 
		{
			set resultObj.errorCode="05100128"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")
			quit
		}
		
		set delObj={},data=[]
		set delObj.className="User.CBSysServiceType"
		set delObj.updateUserID=userID
		set dataObj={}
		set dataObj.ID=params.id
		do data.%Push(dataObj)
		set delObj.data=data
		;b ;0
		set rtn=##class(src.util.operatetable).Delete(.delObj) ;调用公共类方法记录修改日记
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage		
		
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="删除读写类型配置出错:w ##class("_$ClassName()_").DeleteSysServiceTypeConfig("_jsonObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")	
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 保存接口服务配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.InterfaceService.InterfaceServiceConfig).SaveInterfaceServiceConfig()
ClassMethod SaveInterfaceServiceConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set dataObj={},dataArr=[]
		set dataObj.ID=params.id
		set dataObj.Code=params.code
		set dataObj.Descripts=params.descripts
		set dataObj.ClassName=params.className
		set dataObj.MethodName=params.methodName
		set dataObj.StartDate=params.startDate		
		set dataObj.StopDate=params.stopDate
		set dataObj.ServiceType=params.serviceType
		set dataObj.ProductCatDr=params.productCatID
		set dataObj.ProductModuleDr=params.productModuleID		
		set dataObj.SeqNo=params.seqNo
		set dataObj.ServiceIP=params.serviceIP
		set dataObj.SessionFlag=params.sessionFlag
		set dataObj.TokenFlag=params.tokenFlag		
		set dataObj.TokenOverTime=params.tokenOverTime
		set dataObj.RWServiceTypeDr=params.rwServiceTypeID
		do dataArr.%Push(dataObj)
		;b	;12121
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className="User.CBMapInterface"			
		set operateObj.data=dataArr		
		if params.id=""{
			set rtn=##class(src.util.operatetable).Insert(.operateObj) ;调用公共类方法记录修改日记
		}else{				
			set rtn=##class(src.util.operatetable).Update(.operateObj) ;调用公共类方法记录修改日记
		}
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		if errorCode'="0"{
			set resultObj.errorCode=errorCode
			set resultObj.errorMessage=errorMessage
			quit
		}
		
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="保存接口服务配置出错:w ##class("_$ClassName()_").SaveInterfaceServiceConfig("_jsonObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")	
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 获取接口服务配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.InterfaceService.InterfaceServiceConfig).GetInterfaceServiceConfig({"params":[{"describe":"性别","status":"2"}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"","sortOrder":""}],"code":"01010017","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"2qxKMKf160","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]})
ClassMethod GetInterfaceServiceConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try{
		if (jsonObj.%IsDefined("pagination")'=0) {
			set pagationObj=jsonObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
			set currentPage=pagationObj.currentPage
		}
		set params=jsonObj.params.%Get(0)		
		set compareCode=params.code
		set compareDescripts=params.describe
		set compareClassName=params.className
		set compareMethodName=params.methodName
		set status=params.status
		set tStatement = ##class(%SQL.Statement).%New(1)  
		set sql="SELECT ProductCat_Dr->Descripts AS productCatDesc,ProductModule_Dr -> Descripts AS productModuleDesc,RWServiceType_Dr -> Descripts AS rwServiceTypeDesc,* FROM CB_MapInterface"		
		
		set sql=sql_" WHERE 1=1"
		set:(compareCode'="") sql=sql_" and Code LIKE '%"_compareCode_"%'"
		set:(compareDescripts'="") sql=sql_" AND Descripts LIKE '%"_compareDescripts_"%'"
		set:(compareClassName'="") sql=sql_" AND ClassName LIKE '%"_compareClassName_"%'"
		set:(compareMethodName'="") sql=sql_" AND MethodName LIKE '%"_compareMethodName_"%'"
		if (status'="") {
			set:status="1" sql=sql_" AND StartDate <"_(+$h+1)_" and (StopDate is NULL or StopDate >"_+$h_")"
			set:status="0" sql=sql_" AND StartDate >"_(+$h)_" and (StopDate is NULL or StopDate <"_+$h_")"
		}
		b	;111
		set sc=tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.key=result.%Get("ID")
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.className=result.%Get("ClassName")
			set dataObj.methodName=result.%Get("MethodName")
			set dataObj.startDate=result.%Get("StartDate")			
			set dataObj.stopDate=result.%Get("StopDate")
			set dataObj.serviceType=result.%Get("ServiceType")
			set dataObj.productCatID=result.%Get("ProductCat_Dr")
			set dataObj.productCatDesc=result.%Get("productCatDesc")
			set dataObj.productModuleID=result.%Get("ProductModule_Dr")
			set dataObj.productModuleDesc=result.%Get("productModuleDesc")
			set dataObj.seqNo=result.%Get("SeqNo")
			set dataObj.sessionFlag=result.%Get("SessionFlag")
			set dataObj.tokenFlag=result.%Get("TokenFlag")			
			set dataObj.tokenOverTime=result.%Get("TokenOverTime")
			set dataObj.rwServiceTypeID=result.%Get("RWServiceType_Dr")
			set dataObj.rwServiceTypeDesc=result.%Get("rwServiceTypeDesc")
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="获取接口服务配置出错:w ##class("_$ClassName()_").GetInterfaceServiceConfig("_jsonObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")	
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 获取接口服务下拉数据
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.InterfaceService.InterfaceServiceConfig).GetSelectData({"session":[{"hospID":6}]}).%ToJSON()  
ClassMethod GetSelectData(jsonObj) As %Library.DynamicObject
{
	
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set resultObj.result.status=##class(src.InterfaceService.InterfaceServiceConfig).FindStatusData()
		set resultObj.result.serviceType=##class(src.InterfaceService.InterfaceServiceConfig).GetServiceTypeData()
		set resultObj.result.productCat=##class(src.InterfaceService.InterfaceServiceConfig).GetProductCatData()
		set postObj={},postArr=[]
		do postArr.%Push(postObj)
		set post={}
		set post.params=postArr
		set resultObj.result.rwServiceType=##class(src.InterfaceService.InterfaceServiceConfig).GetSysServiceTypeConfig(post).result.Data
		set resultObj.result.productModule=##class(src.InterfaceService.InterfaceServiceConfig).GetProductModuleData({"params":[{"productCatID":""}]})
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="获取接口服务下拉数据出错:w ##class("_$ClassName()_").GetSelectData("_jsonObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")
	}
	quit resultObj
}

/// 状态下拉数据
/// Debug：		 w ##class(src.InterfaceService.InterfaceServiceConfig).FindStatusData()
ClassMethod FindStatusData() As %Library.DynamicAbstractObject
{
	set dataArr=[]
	set dataObj={}
	set dataObj.id=2
	set dataObj.code="All"
	set dataObj.descripts="所有"
	set dataObj.enDescripts=""
	set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(dataObj.descripts)
	do dataArr.%Push(dataObj)
	set dataObj={}
	set dataObj.id=1
	set dataObj.code="Valid"
	set dataObj.descripts="生效"
	set dataObj.enDescripts=""
	set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(dataObj.descripts)
	do dataArr.%Push(dataObj)
	set dataObj={}
	set dataObj.id=0
	set dataObj.code="Invalid"
	set dataObj.descripts="失效"
	set dataObj.enDescripts=""
	set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(dataObj.descripts)
	do dataArr.%Push(dataObj)
	
	Quit dataArr
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 获取服务类型下拉数据
/// code:		 
/// Input:		
/// Debug：		 w ##class(src.InterfaceService.InterfaceServiceConfig).GetServiceTypeData().%ToJSON()  
ClassMethod GetServiceTypeData() As %Library.DynamicObject
{
	new
	set dataArr=[]
    try{
        set dataObj={}
        set dataObj.id="S"
        set dataObj.code="search"
        set dataObj.descripts="查询"
        set dataObj.enDescripts="search"
        set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(dataObj.descripts)
        do dataArr.%Push(dataObj)
        
        set dataObj={}
        set dataObj.id="A"
        set dataObj.code="add"
        set dataObj.descripts="新增"
        set dataObj.enDescripts="add"
        set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(dataObj.descripts)
        do dataArr.%Push(dataObj)
        
        set dataObj={}
        set dataObj.id="U"
        set dataObj.code="update"
        set dataObj.descripts="修改"
        set dataObj.enDescripts="update"
        set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(dataObj.descripts)
        do dataArr.%Push(dataObj)
        
        set dataObj={}
        set dataObj.id="D"
        set dataObj.code="delete"
        set dataObj.descripts="删除"
        set dataObj.enDescripts="delete"
        set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(dataObj.descripts)
        do dataArr.%Push(dataObj)
    }catch(e){
	    set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="获取接口服务下拉数据出错:w ##class("_$ClassName()_").GetServiceTypeData()"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")
    }
    quit dataArr
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 获取产品分类下拉数据
/// code:		 
/// Input:		
/// Debug：		 w ##class(src.InterfaceService.InterfaceServiceConfig).GetProductCatData().%ToJSON()  
ClassMethod GetProductCatData() As %Library.DynamicObject
{
	set dataArr=[]
	try{
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_ProductCat"
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.descriptsSPCode=result.%Get("ENDesc")
			do dataArr.%Push(dataObj)
		}	
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="获取产品分类下拉数据出错:w ##class("_$ClassName()_").GetProductCatData()"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")
	}
	
	quit dataArr
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 获取产品模块下拉数据
/// code:		 
/// Input:		
/// Debug：		 w ##class(src.InterfaceService.InterfaceServiceConfig).GetProductModuleData({"params":[{"productCatID":1}]}).%ToJSON()  
ClassMethod GetProductModuleData(jsonObj) As %Library.DynamicObject
{
	set dataArr=[]
	try{
		set params=jsonObj.params.%Get(0)
		set productCatID=params.productCatID
		;quit:productCatID=""
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_ProductModule"
		if productCatID'="" {
			set sql=sql_" where ProductCat_Dr = "_productCatID
		}
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.descriptsSPCode=result.%Get("ENDesc")
			set dataObj.productCatID=result.%Get("ProductCat_Dr")
			do dataArr.%Push(dataObj)
		}	
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="获取产品模块下拉数据出错:w ##class("_$ClassName()_").GetProductModuleData("_jsonObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")
	}
	
	quit dataArr
}

}
