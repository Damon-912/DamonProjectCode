Import SQLUSER

Class src.DRG.BasicData.DictionaryData Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存DRG基础数据表
/// Table:     	 HB_DRGBasicData
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod SaveDRGBasicData(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="保存成功"
	set resultObj.result={}
	try{
		set params=postObj.params.%Get(0)
		set session=postObj.session.%Get(0)
		set hospID=session.hospID
		set userID=session.userID
		
		set dictID=params.dictID
		set insuCode=params.insuCode
		set insuDesc=params.insuDesc
		set provinceID=params.provinceID
		set cityID=params.cityID
		set areaID=params.areaID
		
		set identification=params.identification
		set remark=params.remark
		
		set startDate=params.startDate
		set stopDate=params.stopDate				
		
		if (startDate'="")&&(stopDate'="")
		{
			set startDate=$zdh(startDate,3)
			set stopDate=$zdh(stopDate,3)
			
			if (startDate>stopDate)
			{
			    set resultObj.errorCode="01040014"
			    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040014")   
			    quit	
			}
		}
								
		if (insuCode=""){
			set resultObj.errorCode="01000006"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000006")   
			quit
		}
		if (insuDesc=""){
			set resultObj.errorCode="01000005"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000005")
			quit
		}
		if (provinceID=""){
			set resultObj.errorCode="01000007"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000007")
			quit
		}
		if (cityID=""){
			set resultObj.errorCode="01000008"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000008")
			quit
		}
		set data=[]
		set dataObj={}
		set dataObj.ID=dictID
		set dataObj.InsuCode=insuCode
		set dataObj.InsuDesc=insuDesc
		set dataObj.ProvinceDr=provinceID
		set dataObj.CityDr=cityID
		set dataObj.AreaDr=areaID
		set dataObj.StartDate=startDate
		set dataObj.StopDate=stopDate
		set dataObj.CreateUserDr=userID
		set dataObj.CreateDate=$zd($h,3)
		set dataObj.CreateTime=$zt($p($h,",",2),1)
		
		set dataObj.Identification=identification
		set dataObj.Remark=remark
		
		set insObj={}
		set insObj.className="User.HBDRGBasicData"
		set insObj.updateUserID=userID	
		set rtn=""
		do data.%Push(dataObj)
		set insObj.data=data
		if dictID=""{
			set rtn=##class(src.util.operatetable).Insert(.insObj)
		}else{
			set rtn=##class(src.util.operatetable).Update(.insObj)
		}
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
	    if errorCode'=0{
		    set resultObj.errorCode=errorCode
	    	set resultObj.errorMessage=errorMessage
	   	}
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存DRG基础数据出现问题:w ##class("_$ClassName()_").SaveDRGBasicData("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
 	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询DRG基础数据表
/// Table:     	 HB_DRGBasicData
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: w ##class(src.BasicData.Dictionaries).GetDictionariesList({"params":[{"status":"","insuDesc":""}],"pagination":[{"pageSize":20,"currentPage":1}],"code":"02020002","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"009kXpy1by","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod GetDRGBasicData(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try{
		if (jsonObj.%IsDefined("pagination")'=0) 
		{
			set pagationObj=jsonObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
			set currentPage=pagationObj.currentPage
		}
		set params=jsonObj.params.%Get(0)
		set insuDesc=params.insuDesc
		set status=params.status
		set sql =" SELECT ID,InsuCode,InsuDesc,Province_Dr as provinceID,"
		        _" Province_Dr->Descripts as provinceDesc,City_Dr as cityID,"
		        _" City_Dr->Descripts as cityDesc,Area_Dr as areaID,"
			    _" Area_Dr->Descripts as areaDesc,StartDate,StopDate,"
			    _" identification,Remark "
			    _" FROM HB_DRGBasicData where 1=1"
		
	    if insuDesc'=""
		{
		    set sql=sql_" and InsuDesc like '%"_insuDesc_"%'" 
	    }	
						
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)		
		{
			set startDate=result.%Get("startDate")
			set stopDate=result.%Get("StopDate")
			set dataObj={}
			set dataObj.dictID=result.%Get("ID")
			set dataObj.insuCode=result.%Get("InsuCode")
			set dataObj.insuDesc=result.%Get("InsuDesc")
			set dataObj.provinceID=result.%Get("provinceID")
			set dataObj.provinceDesc=result.%Get("provinceDesc")
			set dataObj.cityID=result.%Get("cityID")
			set dataObj.cityDesc=result.%Get("cityDesc")
			set dataObj.areaID=result.%Get("areaID")
			set dataObj.areaDesc=result.%Get("areaDesc")			
			set dataObj.identification=result.%Get("identification")
		    set dataObj.remark=result.%Get("remark")			
			set dataObj.startDate=startDate
			set dataObj.stopDate=stopDate
			//b ;; startDate
			
			if startDate'=""{
				set startDate=$zdh(startDate,3)
			}
			if stopDate'=""{
				set stopDate=$zdh(stopDate,3)
			}			
			
			set iStatus=..IsRecordActive(startDate,stopDate)
							
			if (iStatus)
			{
		    	set statusDesc="有效"
		     	set statusFlag="Y"				
			}
			else
			{
		    	set statusDesc="无效"
		     	set statusFlag="N"				
			}
															
			if status="Y"
			{
				continue:statusFlag="N"
			}
			elseif status="N"
			{
			    continue:statusFlag="Y"	
			}
			
			set dataObj.statusDesc=statusDesc
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询DRG基础数据出现问题:w ##class("_$ClassName()_").GetDRGBasicData("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除DRG基础数据表信息
/// Table:     	 HB_DRGBasicData
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod DeleteDRGBasicData(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		set dictID=params.dictID
		if dictID="" 
		{
			set resultObj.errorCode="05100128"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")  ///请选择一条数据
			quit
		}
		
		set oleDictID=""
		&sql(select count(ID) into:oleDictID from HB_DRGBasicDataSub where HBDictionaries_Dr=:dictID)
		if SQLCODE=100
		{
			set oleDictID=""
		}
		
		if oleDictID=""
		{
			set resultObj.errorCode="03000005"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("03000005")  ///子表存在数据不能删除父表记录
			quit
		}
		
		set delObj={},data=[]
		set delObj.className="User.HBDRGBasicData"
		set delObj.updateUserID=userID
		set dataObj={}
		set dataObj.ID=dictID
		do data.%Push(dataObj)
		set delObj.data=data
		;b ;0
		set rtn=##class(src.util.operatetable).Delete(.delObj) ;调用公共类方法记录修改日记
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage				
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="删除DRG基础数据出现问题:w ##class("_$ClassName()_").DeleteDRGBasicData("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存DRG基础数据明细
/// Table:     	 HB_DRGBasicDataSub
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: w ##class(src.BasicData.Dictionaries).SaveDictionariesDetailed({"params":[{"dictID":"4","code":"442432","desc":"居民身份证(户口薄)","startDate":"2022-07-06","error":false}],"code":"02020004","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"009kXpy1by","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod SaveDRGBasicDataSub(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="保存成功"
	set resultObj.result={}
	try
	{
		set params=postObj.params.%Get(0)
		set session=postObj.session.%Get(0)
		set hospID=session.hospID
		set userID=session.userID
		
		set id=params.id
		set dictID=params.dictID  
		set code=params.code
		set desc=params.desc
		set identification=params.identification
		set startDate=params.startDate
		set stopDate=params.stopDate
		if startDate=""
		{
			set startDate=$zd($h,3)
		}
		
		if (startDate'="")&&(stopDate'="")
		{
			set startDate=$zdh(startDate,3)
			set stopDate=$zdh(stopDate,3)
			
			if (startDate>stopDate)
			{
			    set resultObj.errorCode="01040014"
			    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040014")   
			    quit	
			}
		}		
		
		if (dictID="")
		{
			set resultObj.errorCode="01000010"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000010")   
			quit
		}
		if (code="")
		{
			set resultObj.errorCode="01000011"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000011")
			quit
		}
		if (desc="")
		{
			set resultObj.errorCode="01000012"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000012")
			quit
		}
		set data=[]
		set dataObj={}
		set dataObj.ID=id
		set dataObj.HBDictionariesDr=dictID
		set dataObj.Code=code
		set dataObj.Descripts=desc
		set dataObj.Identification=identification
		set dataObj.StartDate=startDate
		set dataObj.StopDate=stopDate
		set dataObj.CreateUserDr=userID
		set dataObj.CreateDate=$zd($h,3)
		set dataObj.CreateTime=$zt($p($h,",",2),1)
		set insObj={}
		set insObj.className="User.HBDRGBasicDataSub"
		set insObj.updateUserID=userID								
		
		set rtn=""
		do data.%Push(dataObj)
		set insObj.data=data												
	
		if id=""
		{
			set rtn=##class(src.util.operatetable).Insert(.insObj)
		}else{
			set rtn=##class(src.util.operatetable).Update(.insObj)
		}

		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
	    if errorCode'=0
	    {
		    set resultObj.errorCode=errorCode
	    	set resultObj.errorMessage=errorMessage
	   	}
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存DRG基础数据明细出现问题:w ##class("_$ClassName()_").SaveDRGBasicDataSub("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
 	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询DRG基础数据明细
/// Table:     	 HB_DRGBasicDataSub
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: w ##class(src.BasicData.Dictionaries).GetDictionariesDetailedList({"params":[{"status":"","desc":"","dictID":"4"}],"pagination":[{"pageSize":20,"currentPage":1}],"code":"02020005","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"009kXpy1by","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJOSN()
ClassMethod GetDRGBasicDataSub(jsonObj) As %Library.DynamicObject
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
		set dictID=params.dictID
		set desc=params.desc
		set status=params.status

		set sql=" SELECT ID,HBDictionaries_Dr as dictID,Code,Descripts,StartDate,StopDate,"
		       _" identification FROM HB_DRGBasicDataSub where HBDictionaries_Dr="_dictID
				
		if desc'=""
		{
			set sql=sql_" and Descripts like '%"_desc_"%'" 
		}	
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)	
		{
			set id=result.%Get("ID")
			set dictID=result.%Get("dictID")
			set code=result.%Get("Code")
			set desc=result.%Get("Descripts")
			set identification=result.%Get("identification")
			set startDate=result.%Get("StartDate")
			set stopDate=result.%Get("StopDate")
			set dataObj={}
			set dataObj.id=id
			set dataObj.dictID=dictID
			set dataObj.code=code
			set dataObj.desc=desc
			set dataObj.startDate=startDate
			set dataObj.stopDate=stopDate
			set dataObj.identification=identification
			
			if startDate'=""{
				set startDate=$zdh(startDate,3)
			}
			if stopDate'=""{
				set stopDate=$zdh(stopDate,3)
			}			
			
			set iStatus=..IsRecordActive(startDate,stopDate)
							
			if (iStatus)
			{
		    	set statusDesc="有效"
		     	set statusFlag="Y"				
			}
			else
			{
		    	set statusDesc="无效"
		     	set statusFlag="N"				
			}
															
			if status="Y"
			{
				continue:statusFlag="N"
			}
			elseif status="N"
			{
			    continue:statusFlag="Y"	
			}			
			
			set dataObj.statusDesc=statusDesc
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询DRG基础数据明细出现问题:w ##class("_$ClassName()_").GetDRGBasicDataSub("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage

	}
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除DRG基础数据明细
/// Table:     	 HB_DRGBasicDataSub
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod DeleteDRGBasicDataSub(jsonObj) As %Library.DynamicObject
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
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")  ///请选择一条数据
			quit
		}
		set delObj={},data=[]
		set delObj.className="User.HBDRGBasicDataSub"
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
	}
	catch(e)
	{
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="删除DRG基础数据明细出现问题:w ##class("_$ClassName()_").DeleteDRGBasicDataSub("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存(ADRG)核心疾病诊断相关分组规则列表
/// Table:     	 CB_DRGCoreGroupsList
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod SaveDRGCoreGroupsList(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="保存成功"
	set resultObj.result={}
	try{
		set params=postObj.params.%Get(0)
		set session=postObj.session.%Get(0)
		set hospID=session.hospID
		set userID=session.userID
		
		//set id=params.id
		set dictID=params.id  		
		set ADRG=params.adrg
		set ADRGDesc=params.adrgDesc
		set PrincipalDiagnosis=params.principalDiagnosis
		set PrincipalDiagnosisName=params.principalDiagnosisName
		set SecondaryDiagnosis=params.secondaryDiagnosis
		set SecondaryDiagnosisName=params.secondaryDiagnosisName
		
		set ThirdlyDiagnosis=params.thirdlyDiagnosis
		set ThirdlyDiagnosisName=params.thirdlyDiagnosisName		
		
		set MajorProcedure=params.majorProcedure		
		set MajorProcedureName=params.majorProcedureName
		set SecondaryProcedure=params.secondaryProcedure		
		set SecondaryProcedureName=params.secondaryProcedureName
		
		set ThirdlyProcedure=params.thirdlyProcedure		
		set ThirdlyProcedureName=params.thirdlyProcedureName		
		set UnionFlag=params.unionFlag
		set SelectionCriteria=params.selectionCriteria		
		set provinceID=params.provinceID
		set cityID=params.cityID		
		set startDate=params.startDate
		set stopDate=params.stopDate				
		
		if (startDate'="")&&(stopDate'="")
		{
			set startDate=$zdh(startDate,3)
			set stopDate=$zdh(stopDate,3)
			
			if (startDate>stopDate)
			{
			    set resultObj.errorCode="01040014"
			    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040014")   
			    quit	
			}
		}
		
		if (ADRG=""){
			set resultObj.errorCode="01000011"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000011")
			quit
		}
		if (ADRGDesc=""){
			set resultObj.errorCode="01000012"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000012")
			quit
		}						
		if (provinceID=""){
			set resultObj.errorCode="01000007"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000007")
			quit
		}
		if (cityID=""){
			set resultObj.errorCode="01000008"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000008")
			quit
		}
		
		set data=[]
		set dataObj={}
		set dataObj.ID=dictID
		set dataObj.ADRG=ADRG
		set dataObj.ADRGDesc=ADRGDesc
					
        set dataObj.PrincipalDiagnosis=PrincipalDiagnosis
		set dataObj.PrincipalDiagnosisName=PrincipalDiagnosisName
		set dataObj.SecondaryDiagnosis=SecondaryDiagnosis
		set dataObj.SecondaryDiagnosisName=SecondaryDiagnosisName		
		set dataObj.ThirdlyDiagnosis=ThirdlyDiagnosis
		set dataObj.ThirdlyDiagnosisName=ThirdlyDiagnosisName				
		set dataObj.MajorProcedure=MajorProcedure		
		set dataObj.MajorProcedureName=MajorProcedureName
		set dataObj.SecondaryProcedure=SecondaryProcedure		
		set dataObj.SecondaryProcedureName=SecondaryProcedureName		
		set dataObj.ThirdlyProcedure=ThirdlyProcedure		
		set dataObj.ThirdlyProcedureName=ThirdlyProcedureName
		set dataObj.UnionFlag=UnionFlag				
		set dataObj.SelectionCriteria=SelectionCriteria												
		set dataObj.ProvinceDr=provinceID
		set dataObj.CityDr=cityID		
		set dataObj.StartDate=startDate
		set dataObj.StopDate=stopDate
		
		set dataObj.CreateUserDr=userID
		set dataObj.CreateDate=$zd($h,3)
		set dataObj.CreateTime=$zt($p($h,",",2),1)
				
		set insObj={}
		set insObj.className="User.CBDRGCoreGroupsList"
		set insObj.updateUserID=userID	
		set rtn=""
		do data.%Push(dataObj)
		set insObj.data=data
		if dictID=""{
			set rtn=##class(src.util.operatetable).Insert(.insObj)
		}else{
			set rtn=##class(src.util.operatetable).Update(.insObj)
		}
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
	    if errorCode'=0{
		    set resultObj.errorCode=errorCode
	    	set resultObj.errorMessage=errorMessage
	   	}
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存核心疾病诊断相关分组(ADRG)规则列表数据出现问题:w ##class("_$ClassName()_").SaveDRGCoreGroupsList("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
 	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询(ADRG)核心疾病诊断相关分组规则列表
/// Table:     	 CB_DRGCoreGroupsList
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: w ##class(src.BasicData.Dictionaries).GetDictionariesList({"params":[{"status":"","insuDesc":""}],"pagination":[{"pageSize":20,"currentPage":1}],"code":"02020002","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"009kXpy1by","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod GetDRGCoreGroupsList(jsonObj) As %Library.DynamicObject
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
		set adrgDesc=params.adrgDesc
		set status=params.status
		set sql =" SELECT ID,ADRG,ADRGDesc,Province_Dr as ProvinceID,"
		        _" Province_Dr->Descripts as ProvinceDesc,City_Dr as CityID,"
		        _" City_Dr->Descripts as CityDesc,PrincipalDiagnosis,PrincipalDiagnosisName,"
		        _" SecondaryDiagnosis,SecondaryDiagnosisName,MajorProcedure,MajorProcedureName, "
		        _" SecondaryProcedure,SecondaryProcedureName,SelectionCriteria, "
		        _" StartDate,StopDate,ThirdlyDiagnosis,ThirdlyDiagnosisName,"
		        _" ThirdlyProcedure,ThirdlyProcedureName,UnionFlag "
			    _" FROM CB_DRGCoreGroupsList where 1=1"
			    
		if adrgDesc'=""
		{
			set sql=sql_" and ADRGDesc like '%"_adrgDesc_"%'" 
		}   
	
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)	
		{
			set startDate=result.%Get("StartDate")
			set stopDate=result.%Get("StopDate")
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.adrg=result.%Get("ADRG")
			set dataObj.adrgDesc=result.%Get("ADRGDesc")			
            set dataObj.principalDiagnosis=result.%Get("PrincipalDiagnosis")
		    set dataObj.principalDiagnosisName=result.%Get("PrincipalDiagnosisName")
		    set dataObj.secondaryDiagnosis=result.%Get("SecondaryDiagnosis")
		    set dataObj.secondaryDiagnosisName=result.%Get("SecondaryDiagnosisName")		   
		    set dataObj.thirdlyDiagnosis=result.%Get("ThirdlyDiagnosis")
		    set dataObj.thirdlyDiagnosisName=result.%Get("ThirdlyDiagnosisName")		   		

		    set dataObj.majorProcedure=result.%Get("MajorProcedure")		
		    set dataObj.majorProcedureName=result.%Get("MajorProcedureName")
		    set dataObj.secondaryProcedure=result.%Get("SecondaryProcedure")		
		    set dataObj.secondaryProcedureName=result.%Get("SecondaryProcedureName")
		    set dataObj.thirdlyProcedure=result.%Get("ThirdlyProcedure")		
		    set dataObj.thirdlyProcedureName=result.%Get("ThirdlyProcedureName")		   		   
		    set dataObj.unionFlag=result.%Get("UnionFlag")		   
		    set dataObj.selectionCriteria=result.%Get("SelectionCriteria")				
								
			set dataObj.provinceID=result.%Get("ProvinceID")
			set dataObj.provinceDesc=result.%Get("ProvinceDesc")
			set dataObj.cityID=result.%Get("CityID")
			set dataObj.cityDesc=result.%Get("CityDesc")			
			set dataObj.startDate=startDate
			set dataObj.stopDate=stopDate
				
			if startDate'=""{
				set startDate=$zdh(startDate,3)
			}
			if stopDate'=""{
				set stopDate=$zdh(stopDate,3)
			}			
			
			set iStatus=..IsRecordActive(startDate,stopDate)
							
			if (iStatus)
			{
		    	set statusDesc="有效"
		     	set statusFlag="Y"				
			}
			else
			{
		    	set statusDesc="无效"
		     	set statusFlag="N"				
			}
															
			if status="Y"
			{
				continue:statusFlag="N"
			}
			elseif status="N"
			{
			    continue:statusFlag="Y"	
			}	
			
			set dataObj.statusDesc=statusDesc
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询(ADRG)核心疾病诊断相关分组规则列表数据出现问题:w ##class("_$ClassName()_").GetDRGCoreGroupsList("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除(ADRG)核心疾病诊断相关分组规则列表
/// Table:     	 CB_DRGCoreGroupsList
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod DeleteDRGCoreGroupsList(jsonObj) As %Library.DynamicObject
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
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")  ///请选择一条数据
			quit
		}
		set delObj={},data=[]
		set delObj.className="User.CBDRGCoreGroupsList"
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
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="删除(ADRG)核心疾病诊断相关分组规则列表数据出现问题:w ##class("_$ClassName()_").DeleteDRGCoreGroupsList("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存按病种分值(DIP)付费病种库(2.0版)核心病种
/// Table:     	 CB_DIPCoreGroupsList
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod SaveDIPCoreGroupsList(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="保存成功"
	set resultObj.result={}
	try{
		set params=postObj.params.%Get(0)
		set session=postObj.session.%Get(0)
		set hospID=session.hospID
		set userID=session.userID
		
		set dictID=params.id
		set num=params.num  			
		set PrincipalDiagnosis=params.principalDiagnosis
		set PrincipalDiagnosisName=params.principalDiagnosisName	
		set MajorProcedure=params.majorProcedure		
		set MajorProcedureName=params.majorProcedureName
		set SecondaryProcedure=params.secondaryProcedure		
		set SecondaryProcedureName=params.secondaryProcedureName
		set SelectionCriteria=params.selectionCriteria		
		set provinceID=params.provinceID
		set cityID=params.cityID		
		set startDate=params.startDate
		set stopDate=params.stopDate
		
		if (startDate'="")&&(stopDate'="")
		{
			set startDate=$zdh(startDate,3)
			set stopDate=$zdh(stopDate,3)
			
			if (startDate>stopDate)
			{
			    set resultObj.errorCode="01040014"
			    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040014")   
			    quit	
			}
		}			
		
		//if (dictID=""){
		//	set resultObj.errorCode="01000010"
		//	set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000010")   
		//	quit
		//}

		if (PrincipalDiagnosis="")&&(MajorProcedure="")
		{
			set resultObj.errorCode="01040047"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040047")
			quit
		}		
								
		if (provinceID=""){
			set resultObj.errorCode="01000007"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000007")
			quit
		}
		
		if (cityID="")
		{
			set resultObj.errorCode="01000008"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000008")
			quit
		}
		
		set data=[]
		set dataObj={}
		set dataObj.ID=dictID
		set dataObj.Num=num
		//set dataObj.ADRG=ADRG
		//set dataObj.ADRGDesc=ADRGDesc
					
        set dataObj.PrincipalDiagnosis=PrincipalDiagnosis
		set dataObj.PrincipalDiagnosisName=PrincipalDiagnosisName
		set dataObj.MajorProcedure=MajorProcedure		
		set dataObj.MajorProcedureName=MajorProcedureName
		set dataObj.SecondaryProcedure=SecondaryProcedure		
		set dataObj.SecondaryProcedureName=SecondaryProcedureName
		//set dataObj.SelectionCriteria=SelectionCriteria		
										
		set dataObj.ProvinceDr=provinceID
		set dataObj.CityDr=cityID		
		set dataObj.StartDate=startDate
		set dataObj.StopDate=stopDate
		
		set dataObj.CreateUserDr=userID
		set dataObj.CreateDate=$zd($h,3)
		set dataObj.CreateTime=$zt($p($h,",",2),1)
				
		set insObj={}
		set insObj.className="User.CBDIPCoreGroupsList"
		set insObj.updateUserID=userID	
		set rtn=""
		do data.%Push(dataObj)
		set insObj.data=data
		if dictID=""{
			set rtn=##class(src.util.operatetable).Insert(.insObj)
		}else{
			set rtn=##class(src.util.operatetable).Update(.insObj)
		}
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
	    if errorCode'=0{
		    set resultObj.errorCode=errorCode
	    	set resultObj.errorMessage=errorMessage
	   	}
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存按病种分值(DIP)付费病种库(2.0版)核心病种数据出现问题:w ##class("_$ClassName()_").SaveDIPCoreGroupsList("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
 	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询按病种分值(DIP)付费病种库(2.0版)核心病种
/// Table:     	 CB_DIPCoreGroupsList
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: w ##class(src.BasicData.Dictionaries).GetDictionariesList({"params":[{"status":"","insuDesc":""}],"pagination":[{"pageSize":20,"currentPage":1}],"code":"02020002","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"009kXpy1by","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod GetDIPCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try
	{
		if (jsonObj.%IsDefined("pagination")'=0) 
		{
			set pagationObj=jsonObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
			set currentPage=pagationObj.currentPage
		}
		
		set params=jsonObj.params.%Get(0)
		set MajorProcedureName=params.majorProcedureName
		set PrincipalDiagnosisName=params.principalDiagnosisName
		set status=params.status

		set sql =" SELECT ID,Num,Province_Dr as ProvinceID,"
		        _" Province_Dr->Descripts as ProvinceDesc,City_Dr as CityID,"
		        _" City_Dr->Descripts as CityDesc,PrincipalDiagnosis,PrincipalDiagnosisName,"
		        _" MajorProcedure,MajorProcedureName,SecondaryProcedure,SecondaryProcedureName, "
		        _" StartDate,StopDate,CreateDate,CreateTime,CreateUser_Dr"
			    _" FROM CB_DIPCoreGroupsList where 1=1"
			    
		if MajorProcedureName'=""
		{
			set sql=sql_" and MajorProcedureName like '%"_MajorProcedureName_"%'" 
		}
		
		if PrincipalDiagnosisName'=""
		{
			set sql=sql_" and PrincipalDiagnosisName like '%"_PrincipalDiagnosisName_"%'" 
		}			

		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)	
		{
			set startDate=result.%Get("StartDate")
			set stopDate=result.%Get("StopDate")
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.num=result.%Get("Num")
            set dataObj.principalDiagnosis=result.%Get("PrincipalDiagnosis")
		    set dataObj.principalDiagnosisName=result.%Get("PrincipalDiagnosisName")

		    set dataObj.majorProcedure=result.%Get("MajorProcedure")		
		    set dataObj.majorProcedureName=result.%Get("MajorProcedureName")
		    set dataObj.secondaryProcedure=result.%Get("SecondaryProcedure")		
		    set dataObj.secondaryProcedureName=result.%Get("SecondaryProcedureName")
		    //set dataObj.selectionCriteria=SelectionCriteria				
								
			set dataObj.provinceID=result.%Get("ProvinceID")
			set dataObj.provinceDesc=result.%Get("ProvinceDesc")
			set dataObj.cityID=result.%Get("CityID")
			set dataObj.cityDesc=result.%Get("CityDesc")			
			set dataObj.startDate=startDate
			set dataObj.stopDate=stopDate
			set dataObj.createDate=result.%Get("CreateDate")
			set dataObj.createTime=result.%Get("CreateTime")
			set dataObj.createUserDr=result.%Get("CreateUser_Dr")
	
			if startDate'=""{
				set startDate=$zdh(startDate,3)
			}
			if stopDate'=""{
				set stopDate=$zdh(stopDate,3)
			}			
			
			set iStatus=..IsRecordActive(startDate,stopDate)
							
			if (iStatus)
			{
		    	set statusDesc="有效"
		     	set statusFlag="Y"				
			}
			else
			{
		    	set statusDesc="无效"
		     	set statusFlag="N"				
			}
															
			if status="Y"
			{
				continue:statusFlag="N"
			}
			elseif status="N"
			{
			    continue:statusFlag="Y"	
			}			
			
			set dataObj.statusDesc=statusDesc
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询按病种分值(DIP)付费病种库(2.0版)核心病种数据出现问题:w ##class("_$ClassName()_").GetDIPCoreGroupsList("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除按病种分值(DIP)付费病种库(2.0版)核心病种
/// Table:     	 CB_DIPCoreGroupsList
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod DeleteDIPCoreGroupsList(jsonObj) As %Library.DynamicObject
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
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")  ///请选择一条数据
			quit
		}
		set delObj={},data=[]
		set delObj.className="User.CBDIPCoreGroupsList"
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
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="删除按病种分值(DIP)付费病种库(2.0版)核心病种数据出现问题:w ##class("_$ClassName()_").DeleteDIPCoreGroupsList("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

ClassMethod IsRecordActive(startDate As %Date, stopDate As %Date) As %Boolean
{
    Set currentDate = +$Horolog
    
    // 处理空值：startDate为空视为最小日期，stopDate为空视为最大日期
    Set effectiveStart = $Select(startDate="":0, 1:startDate)  // 0 = 1840-12-31
    Set effectiveEnd = $Select(stopDate="":99999, 1:stopDate)  // 99999 = 未来日期
        
    Quit (effectiveStart <= currentDate) && (effectiveEnd >= currentDate)
}

}
