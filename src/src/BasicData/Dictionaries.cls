Import SQLUSER

Class src.BasicData.Dictionaries Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 保存平台字典
/// Table:     	 HB_Dictionaries
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod SaveDictionaries(postObj) As %Library.DynamicObject
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
		
		set Identification=params.identification
		set remark=params.remark
		
		set startDate=params.startDate
		set stopDate=params.stopDate
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
		set insObj.className="User.HBDictionaries"
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
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存平台字典出现问题:w ##class("_$ClassName()_").SaveDictionaries("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
 	quit resultObj
}

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 查询平台字典
/// Table:     	 HB_Dictionaries
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: w ##class(src.BasicData.Dictionaries).GetDictionariesList({"params":[{"status":"","insuDesc":""}],"pagination":[{"pageSize":20,"currentPage":1}],"code":"02020002","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"009kXpy1by","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod GetDictionariesList(jsonObj) As %Library.DynamicObject
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
		set insuDesc=params.insuDesc
		set status=params.status
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql =" SELECT ID,InsuCode,InsuDesc,Province_Dr as provinceID,"
		        _" Province_Dr->Descripts as provinceDesc,City_Dr as cityID,"
		        _" City_Dr->Descripts as cityDesc,Area_Dr as areaID,"
			    _" Area_Dr->Descripts as areaDesc,StartDate,StopDate,"
			    _" identification,Remark "
			    _" FROM HB_Dictionaries where 1=1"
		if insuDesc'=""
		{
			set sql=sql_" and InsuDesc like '%"_insuDesc_"%'" 
		}	
		b ;; sql
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){
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
			set statusDesc="有效"
			set statusFlag=""
			if ((startDate'="")&&(startDate>$h)){
				set statusDesc="失效"
				set statusFlag="Y"
			}
			if ((stopDate'="")&&(stopDate<$h)){
				set statusDesc="失效"
				set statusFlag="Y"
			}
			if status="Y"{
				continue:statusFlag="Y"
			}
			set dataObj.statusDesc=statusDesc
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.Data=dataArr
		set resultObj.result.TotalCount=count		
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询平台字典明细出现问题:w ##class("_$ClassName()_").GetDictionariesDetailedList("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
	quit resultObj
}

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 删除平台字典
/// Table:     	 HB_Dictionaries
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod DeleteDictionaries(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		if params.dictID="" 
		{
			set resultObj.errorCode="05100128"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")  ///请选择一条数据
			quit
		}
		set oleDictID=""
		&sql(select count(ID) into:oleDictID from HB_DictionariesDateDetail where HBDictionaries_Dr=:params.dictID)
		if SQLCODE=100{
			set oleDictID=""
		}
		if oleDictID=""{
			set resultObj.errorCode="03000005"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("03000005")  ///子表存在数据不能删除父表记录
			quit
		}
		set delObj={},data=[]
		set delObj.className="User.HBDictionaries"
		set delObj.updateUserID=userID
		set dataObj={}
		set dataObj.ID=params.dictID
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
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="删除平台字典出现问题:w ##class("_$ClassName()_").DeleteDictionaries("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
	quit resultObj
}

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 保存平台字典明细
/// Table:     	 HB_DictionariesDateDetailed
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: w ##class(src.BasicData.Dictionaries).SaveDictionariesDetailed({"params":[{"dictID":"4","code":"442432","desc":"居民身份证(户口薄)","startDate":"2022-07-06","error":false}],"code":"02020004","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"009kXpy1by","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod SaveDictionariesDetailed(postObj) As %Library.DynamicObject
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
		set id=params.id
		set dictID=params.dictID  
		set code=params.code
		set desc=params.desc
		set startDate=params.startDate
		set stopDate=params.stopDate
		if startDate=""{
			set startDate=$zd($h,3)
		}
		if (dictID=""){
			set resultObj.errorCode="01000010"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000010")   
			quit
		}
		if (code=""){
			set resultObj.errorCode="01000011"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000011")
			quit
		}
		if (desc=""){
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
		set dataObj.StartDate=startDate
		set dataObj.StopDate=stopDate
		set dataObj.CreateUserDr=userID
		set dataObj.CreateDate=$zd($h,3)
		set dataObj.CreateTime=$zt($p($h,",",2),1)
		set insObj={}
		set insObj.className="User.HBDictionariesDateDetailed"
		set insObj.updateUserID=userID	
		set rtn=""
		do data.%Push(dataObj)
		set insObj.data=data
		b ;;  insObj
		if id=""{
			set rtn=##class(src.util.operatetable).Insert(.insObj)
		}else{
			set rtn=##class(src.util.operatetable).Update(.insObj)
		}
		b ;; rtn
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
	    if errorCode'=0{
		    set resultObj.errorCode=errorCode
	    	set resultObj.errorMessage=errorMessage
	   	}
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存平台字典明细出现问题:w ##class("_$ClassName()_").SaveDictionariesDetailed("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
 	quit resultObj
}

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 查询平台字典明细
/// Table:     	 HB_DictionariesDateDetail
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: w ##class(src.BasicData.Dictionaries).GetDictionariesDetailedList({"params":[{"status":"","desc":"","dictID":"4"}],"pagination":[{"pageSize":20,"currentPage":1}],"code":"02020005","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"009kXpy1by","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJOSN()
ClassMethod GetDictionariesDetailedList(jsonObj) As %Library.DynamicObject
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
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT ID,HBDictionaries_Dr as dictID,Code,Descripts,StartDate,StopDate FROM HB_DictionariesDateDetail where HBDictionaries_Dr="_dictID
		if desc'=""{
			set sql=sql_" and Descripts like '%"_desc_"%'" 
		}	
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){
			set id=result.%Get("ID")
			set dictID=result.%Get("dictID")
			set code=result.%Get("Code")
			set desc=result.%Get("Descripts")
			set startDate=result.%Get("StartDate")
			set stopDate=result.%Get("StopDate")
			set dataObj={}
			set dataObj.id=id
			set dataObj.dictID=dictID
			set dataObj.code=code
			set dataObj.desc=desc
			set dataObj.startDate=startDate
			set dataObj.stopDate=stopDate
			if startDate'=""{
				set startDate=$zdh(startDate,3)
			}
			if stopDate'=""{
				set stopDate=$zdh(stopDate,3)
			}
			set statusDesc="有效"
			set statusFlag=""
			if ((startDate'="")&&(startDate>$h)){
				set statusDesc="失效"
				set statusFlag="Y"
			}
			if ((stopDate'="")&&(stopDate<$h)){
				set statusDesc="失效"
				set statusFlag="Y"
			}
			if status="Y"{
				continue:statusFlag="Y"
			}
			set dataObj.statusDesc=statusDesc
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.Data=dataArr
		set resultObj.result.TotalCount=count		
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询平台字典明细出现问题:w ##class("_$ClassName()_").GetDictionariesDetailedList("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID

	}
	quit resultObj
}

/// Creator:     ZXZ
/// CreatDate:   2022-06-30
/// Description: 删除平台字典明细
/// Table:     	 HB_DictionariesDateDetail
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug:
ClassMethod DeleteDictionariesDetailed(jsonObj) As %Library.DynamicObject
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
		set delObj.className="User.HBDictionariesDateDetailed"
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
	    set errorInfo="删除平台字典明细出现问题:w ##class("_$ClassName()_").DeleteDictionariesDetailed("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
	quit resultObj
}

}
