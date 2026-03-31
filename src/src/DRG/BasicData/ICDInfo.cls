Import SQLUSER

Class src.DRG.BasicData.ICDInfo Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询医保ICD编码信息
/// Table:     	 HB_DRGBasicDataSub
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: w ##class(src.BasicData.Dictionaries).GetDictionariesDetailedList({"params":[{"status":"","desc":"","dictID":"4"}],"pagination":[{"pageSize":20,"currentPage":1}],"code":"02020005","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"009kXpy1by","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJOSN()
ClassMethod GetMedInsuICDInfo(jsonObj) As %Library.DynamicObject
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
		set dictID=params.dictID
		set versionNo=params.versionNo //ICD-9;ICD-10
		set code=params.code
		set desc=params.desc
		set status=params.status
		set provinceID=params.provinceID
		set cityID=params.cityID
		
		if (provinceID="")||(cityID="")
		{
			set provinceID="36"
			set cityID="371"
		}
		
		//查询ICD编码类型不能为空
		if versionNo=""
		{
			set resultObj.errorCode="01040015"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040015")   
			quit			
		}
		//省级代码不能为空
		if provinceID=""
		{
			set resultObj.errorCode="01000007"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000007")   
			quit			
		}
		//市级代码不能为空
		if cityID=""
		{
			set resultObj.errorCode="01000008"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000008")   
			quit			
		}				
		
		set sql=" SELECT Top 200 b.ID,b.HBDictionaries_Dr as dictID,"
		       _" b.Code,b.Descripts,b.identification,b.StopDate as stopDate, "	
		       _" Province_Dr as provinceID,a.StartDate as startDate,"
		       _" Province_Dr->Descripts as provinceDesc,"
		       _" City_Dr as cityID,City_Dr->Descripts as cityDesc "	
               _" FROM HB_DRGBasicData a, HB_DRGBasicDataSub b "
               _" Where a.ID=b.HBDictionaries_Dr "
               _" and a.Province_Dr= '"_provinceID_"'"
               _" and a.City_Dr= '"_cityID_"'"
               _" and a.InsuCode= '"_versionNo_"'"
			
		if dictID='""
		{
			set sql=sql_" and b.HBDictionaries_Dr= "_dictID
		}
		if code'=""
		{
			set sql=sql_" and b.Code like '%"_code_"%'" 
		}				
		if desc'=""
		{
			set sql=sql_" and b.Descripts like '%"_desc_"%'" 
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
			set startDate=result.%Get("startDate")
			set stopDate=result.%Get("stopDate")
			
			set provinceID=result.%Get("provinceID")
			set provinceDesc=result.%Get("provinceDesc")
			set cityID=result.%Get("cityID")
			set cityDesc=result.%Get("cityDesc")
						
			set dataObj={}
			set dataObj.id=id
			set dataObj.dictID=dictID
			set dataObj.code=code
			set dataObj.desc=desc
			set dataObj.startDate=startDate
			set dataObj.stopDate=stopDate			
			set dataObj.provinceID=provinceID
			set dataObj.provinceDesc=provinceDesc
			set dataObj.cityID=cityID
			set dataObj.cityDesc=cityDesc			
			set dataObj.identification=identification
			
			if startDate'=""{
				set startDate=$zdh(startDate,3)
			}
			if stopDate'=""{
				set stopDate=$zdh(stopDate,3)
			}			
			
			set iStatus=##class(src.DRG.Interface).IsRecordActive(startDate,stopDate)
							
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
		set errorInfo="查询医保ICD编码信息出现问题:w ##class("_$ClassName()_")GetMedInsuICDInfo("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage

	}
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 新增/修改 ICD编码映射表
/// Table:     	 HB_DRGICDVersionMapping  
/// Input:       
/// Output:      
/// Return:      
/// Others: 
/// Debug：w ##class(MedInsu.services.MapRelation).Update([{"ID":"","HospitalID":"66","InterfaceID":"CD02","Code":"32c47d39-da6e-11eb-b658-0050568f9c84","Chapter":"20","ChapterRange":"V01-Y98","ChapterName":"疾病和死亡的外因","SectionRange":"Y40-Y84","SectionName":"医疗和手术的并发症","CategoryCode":"","CategoryName":"","SuborderCode":"","SuborderName":"","Diagnosticcode":"","Name":"","UseTag":"null","NationalStandardCode":"null","NationalStandardName":"null","ClinicalCode":"null","ClinicalName":"null","Note":"1","ValiadFlag":"100000000000202112301749353440637874","OnlyRecordNO":"2021-12-30 17:49:35","DataCreatTime":"2021-12-30 17:49:35","DataUpdateTime":"20211230","VersionNO":"J001_20211231000001_A","VersionName":"0","Type":"Diagnose","UseFlag":"1","XH":"10"},{"ID":"","HospitalID":"66","InterfaceID":"CD02","Code":"349c37da-da6e-11eb-b658-0050568f9c84","Chapter":"3","ChapterRange":"D50-D89","ChapterName":"血液及造血器官疾病和涉及免疫机制的某些疾患","SectionRange":"D70-D77","SectionName":"其他血液和造血器官疾病","CategoryCode":"D77*","CategoryName":"分类于他处的疾病引起的血液和造血器官的其他疾患","SuborderCode":"","SuborderName":"","Diagnosticcode":"","Name":"","UseTag":"null","NationalStandardCode":"null","NationalStandardName":"null","ClinicalCode":"null","ClinicalName":"null","Note":"1","ValiadFlag":"100000000000202112301749353440639457","OnlyRecordNO":"2021-12-30 17:49:35","DataCreatTime":"2021-12-30 17:49:35","DataUpdateTime":"20211230","VersionNO":"J001_20211231000001_A","VersionName":"0","Type":"Diagnose","UseFlag":"1","XH":"11"},{"ID":"","HospitalID":"66","InterfaceID":"CD02","Code":"349c3cde-da6e-11eb-b658-0050568f9c84","Chapter":"4","ChapterRange":"E00-E90","ChapterName":"内分泌、营养和代谢疾病","SectionRange":"E70-E90","SectionName":"代谢紊乱","CategoryCode":"E90*","CategoryName":"分类于他处的疾病引起的营养和代谢疾患","SuborderCode":"","SuborderName":"","Diagnosticcode":"","Name":"","UseTag":"null","NationalStandardCode":"null","NationalStandardName":"null","ClinicalCode":"null","ClinicalName":"null","Note":"1","ValiadFlag":"100000000000202112301749353440638545","OnlyRecordNO":"2021-12-30 17:49:35","DataCreatTime":"2021-12-30 17:49:35","DataUpdateTime":"20211230","VersionNO":"J001_20211231000001_A","VersionName":"0","Type":"Diagnose","UseFlag":"1","XH":"12"},{"ID":"","HospitalID":"66","InterfaceID":"CD02","Code":"349c4253-da6e-11eb-b658-0050568f9c84","Chapter":"6","ChapterRange":"G00-G99","ChapterName":"神经系统疾病","SectionRange":"G00-G09","SectionName":"中枢神经系统炎性疾病","CategoryCode":"G01*","CategoryName":"分类于他处的细菌性疾病引起的脑膜炎","SuborderCode":"","SuborderName":"","Diagnosticcode":"","Name":"","UseTag":"null","NationalStandardCode":"null","NationalStandardName":"null","ClinicalCode":"null","ClinicalName":"null","Note":"1","ValiadFlag":"100000000000202112301749353440640057","OnlyRecordNO":"2021-12-30 17:49:35","DataCreatTime":"2021-12-30 17:49:35","DataUpdateTime":"20211230","VersionNO":"J001_20211231000001_A","VersionName":"0","Type":"Diagnose","UseFlag":"1","XH":"13"},{"ID":"","HospitalID":"66","InterfaceID":"CD02","Code":"349c425c-da6e-11eb-b658-0050568f9c84","Chapter":"6","ChapterRange":"G00-G99","ChapterName":"神经系统疾病","SectionRange":"G00-G09","SectionName":"中枢神经系统炎性疾病","CategoryCode":"G07*","CategoryName":"分类于他处的疾病引起的颅内、椎管内脓肿和肉芽肿","SuborderCode":"","SuborderName":"","Diagnosticcode":"","Name":"","UseTag":"null","NationalStandardCode":"null","NationalStandardName":"null","ClinicalCode":"null","ClinicalName":"null","Note":"1","ValiadFlag":"100000000000202112301749353440639458","OnlyRecordNO":"2021-12-30 17:49:35","DataCreatTime":"2021-12-30 17:49:35","DataUpdateTime":"20211230","VersionNO":"J001_20211231000001_A","VersionName":"0","Type":"Diagnose","UseFlag":"1","XH":"14"}]).%ToJSON()
ClassMethod UpdateMappingInfo(postObj) As %Library.DynamicAbstractObject
{
	set paramsObj={}
	set paramsObj=postObj.params.%Get(0)
	//set session=postObj.session.%Get(0)
	set booleanSuccess = 0
	set resultObj={}
	set resultObj.errorCode=0
	set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage(resultObj.errorCode)
        
    set PreMsg = ""        
	set errorMsgList=""

		set (UpdateUserDr,ID,ProvinceDr,CityDr,VersionNO,Code,Descripts,ICD,ICDDesc,errorMessage)=""
		try
		{					
			set UpdateUserDr=paramsObj.updateUserID
			set VersionNo=paramsObj.versionNo			
			set Code=paramsObj.code
			set Descripts=paramsObj.descripts				
			set ProvinceDr=paramsObj.provinceID
			set CityDr=paramsObj.cityID  									
			set ICD=paramsObj.icd
   		    set ICDDesc=paramsObj.icdDesc	
																							
			set ID=paramsObj.id					
			if ID=0 set ID=""				
					    								        	
        	
	    	if ProvinceDr=""
	    	{
				set errorMessage = PreMsg_"省代码不能为空;"
				set errorMsgList = errorMsgList_errorMessage
				set booleanSuccess = booleanSuccess + 1			
			}
	    	if CityDr=""
	    	{
				set errorMessage= PreMsg_"市代码不能为空;"
				set errorMsgList = errorMsgList_errorMessage
				set booleanSuccess = booleanSuccess + 1				
			}				
	    	if VersionNo=""
	    	{
				set errorMessage= PreMsg_"ICD版本不能为空;"
				set errorMsgList = errorMsgList_errorMessage
				set booleanSuccess = booleanSuccess + 1				
			}				
			if (Code="")||(Descripts="")
			{
				set errorMessage= PreMsg_"代码["_Code_"]或描述["_Descripts_"]不能为空;"
				set errorMsgList = errorMsgList_errorMessage
				set booleanSuccess = booleanSuccess + 1					
			}			
			if (ICD="")||(ICDDesc="")
			{
				set errorMessage= PreMsg_"ICD["_ICD_"]或ICD描述["_ICDDesc_"]不能为空;"
				set errorMsgList = errorMsgList_errorMessage
				set booleanSuccess = booleanSuccess + 1					
			}		
			
			set dataObj={}			
			set dataObj.Code=Code
			set dataObj.Descripts=Descripts				
			set dataObj.ICD=ICD
			set dataObj.ICDDesc=ICDDesc									
			set dataObj.CityDr=CityDr
			set dataObj.ProvinceDr=ProvinceDr			
			set dataObj.VersionNo=VersionNo	
			set dataObj.UpdateUserDr =UpdateUserDr 		
		    set dataObj.UpdateDate=$zd($h,3)
	    	set dataObj.UpdateTime=$zt($p($h,",",2),1)																																						     		   

			set insObj={},data=[]
			set insObj.className="User.HBDRGICDVersionMapping"					
			do data.%Push(dataObj)
			set insObj.data= data			

			if ID=""
			{
				set rtn=##class(src.util.operatetable).Insert(.insObj) 
				set errorCode=rtn.errorCode
				set errorMessage= PreMsg_"插入结果为"_rtn.errorMessage_";" 
				set errorMsgList = errorMsgList_errorMessage 
				if errorCode '= 0
				{
					set booleanSuccess = booleanSuccess + 1
					set errorMsgList = errorMsgList_errorMessage  
				}
			}
			else
			{
				set rtn=##class(src.util.operatetable).Update(.insObj) 
				set errorCode=errorCode
				set errorMessage=PreMsg_"更新结果为"_rtn.errorMessage_";" 
				set errorMsgList = errorMsgList_errorMessage 
				if errorCode '= 0
				{
					set booleanSuccess = booleanSuccess + 1
					set errorMsgList = errorMsgList_errorMessage  
				}
		    }		    
		}
		catch(e)
		{
			set status=e.AsStatus()
	    	set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    	set errorMessage=##class(%SYSTEM.Status).GetErrorText(status,"cn")					
		}

	if booleanSuccess > 0
	{
		set resultObj.errorCode = "04000007"	
		set resultObj.errorMessage = errorMsgList		
	}
	else
	{
		set resultObj.errorCode = "0"	
		set resultObj.errorMessage = errorMsgList
	}
	
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除ICD编码映射关系信息
/// Table:     	 HB_DRGICDVersionMapping  
/// Input:       
/// Output:      
/// Return:      
/// Others: 
/// Debug：w ##class(MedInsu.services.MapRelation).Delete([{"ID":"","HospitalID":"","InterfaceID":"Y","Type":"Z","NO":"E","Name":"","Description":"","PinyinSearchCode":"","UseFlag":"0","updateUserID":"xys"},{"ID":"1","HospitalID":"68","InterfaceID":"Y","Type":"Y1","NO":"E1","Name":"11","Description":"11","PinyinSearchCode":"11","UseFlag":"0","updateUserID":"xys"}]).%ToJSON()
ClassMethod DeleteMappingInfo(postObj) As %Library.DynamicAbstractObject
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
		set delObj.className="User.HBDRGICDVersionMapping"
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
	    set errorInfo="删除ICD映射关系数据出现问题:w ##class("_$ClassName()_").DeleteDRGICDVersionMapping("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询ICD编码映射关系信息
/// Table:     	 HB_DRGICDVersionMapping
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: w ##class(src.BasicData.Dictionaries).GetDictionariesList({"params":[{"status":"","insuDesc":""}],"pagination":[{"pageSize":20,"currentPage":1}],"code":"02020002","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"009kXpy1by","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod QueryMappingInfo(jsonObj) As %Library.DynamicObject
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
		
		set (id,code,descripts,icd,icdDesc,provinceID,cityID,versionNo)=""
		set params=jsonObj.params.%Get(0)
		set id=params.id
		set code=params.code				
		set descripts=params.descripts
		set icd=params.icd				
		set icdDesc=params.icdDesc	
		set provinceID=params.provinceID		
		set cityID=params.cityID
		set versionNo=params.versionNo
		
		//如果查询传参都为空则给出默认返回国家医保中心的映射关系数据
		set str=id_code_descripts_icd_icdDesc_provinceID_cityID_versionNo
		if (str="")||($ZSTRIP(str, "*W")="")
		{
		    set provinceID="000000",cityID="000000"	
		}
				
		set sql =" SELECT ID,Code,Descripts,Province_Dr as ProvinceID,"
		        _" Province_Dr->Descripts as ProvinceDesc,City_Dr as CityID,"
		        _" City_Dr->Descripts as CityDesc,ICD,ICDDesc,VersionNo, "
		        _" UpdateDate,UpdateTime,UpdateUser_Dr as UpdateUserID, "
		        _" UpdateUser_Dr->Descripts as UpdateUserDesc,Identification,Remark"
			    _" FROM HB_DRGICDVersionMapping where 1=1"
			    
		if id'=""
		{
			set sql=sql_" and ID = "_id 
		} 
		if code'=""
		{
			set sql=sql_" and Code = '"_code_"'" 
		}											 			    
		if descripts'=""
		{
			set sql=sql_" and Descripts like '%"_descripts_"%'" 
		} 
		if icd'=""
		{
			set sql=sql_" and ICD like '%"_icd_"%'" 
		} 
		if icdDesc'=""
		{
			set sql=sql_" and ICDDesc like '%"_icdDesc_"%'" 
		} 		
		if provinceID'=""
		{
			set sql=sql_" and Province_Dr = '"_provinceID_"'" 
		} 		
		if cityID'=""
		{
			set sql=sql_" and City_Dr = '"_cityID_"'" 
		} 	
		if versionNo'=""
		{
			set sql=sql_" and VersionNo = '"_versionNo_"'" 
		} 									
		  	
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)	
		{	
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")	
		    set dataObj.icd=result.%Get("ICD")		
		    set dataObj.icdDesc=result.%Get("ICDDesc")					
            set dataObj.provinceID=result.%Get("ProvinceID")
		    set dataObj.provinceDesc=result.%Get("ProvinceDesc")
		    set dataObj.cityID=result.%Get("CityID")
		    set dataObj.cityDesc=result.%Get("CityDesc")
		    set dataObj.versionNo=result.%Get("VersionNo")		
		    set dataObj.updateDate=result.%Get("UpdateDate")
		    set dataObj.updateTime=result.%Get("UpdateTime")														
			set dataObj.updateUserDr=result.%Get("UpdateUserID")
			set dataObj.updateUserDesc=result.%Get("UpdateUserDesc")
			set dataObj.identification=result.%Get("Identification")
			set dataObj.remark=result.%Get("Remark")	
		
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
		set errorInfo="查询ICD编码映射关系数据出现问题:w ##class("_$ClassName()_").BS_DRGICDVersionMapping("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询各地方版本ICD编码信息
/// Table:     	 BS_DRGICDInfo
/// Input:        
/// Output:      
/// Return:  	 	 
/// Debug: w ##class(src.BasicData.Dictionaries).GetDictionariesDetailedList({"params":[{"status":"","desc":"","dictID":"4"}],"pagination":[{"pageSize":20,"currentPage":1}],"code":"02020005","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"009kXpy1by","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJOSN()
ClassMethod GetICDInfo(jsonObj) As %Library.DynamicObject
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
		set version=params.version //ICD-9;ICD-10
		set code=params.code
		set descripts=params.descripts
		set status=params.status
		set provinceID=params.provinceID
		set cityID=params.cityID
		
		//查询ICD编码类型不能为空
		if version=""
		{
			set resultObj.errorCode="01040015"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040015")   
			quit			
		}
		//省级代码不能为空
		if provinceID=""
		{
			set resultObj.errorCode="01000007"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000007")   
			quit			
		}
		//市级代码不能为空
		if cityID=""
		{
			set resultObj.errorCode="01000008"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000008")   
			quit			
		}				
		
		set sql=" SELECT ID,Code,Descripts,StopDate,Province_Dr as ProvinceID,StartDate,Version, "				       
		       _" Province_Dr->Descripts as ProvinceDesc,City_Dr as CityID,City_Dr->Descripts as CityDesc "		       
               _" FROM BS_DRGICDInfo Where Province_Dr= '"_provinceID_"'"     
               _" and City_Dr= '"_cityID_"' and Version= '"_version_"'"
			
		if code'=""
		{
			set sql=sql_" and Code like '%"_code_"%'" 
		}				
		if descripts'=""
		{
			set sql=sql_" and Descripts like '%"_descripts_"%'" 
		}	
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)	
		{
			set id=result.%Get("ID")		
			set code=result.%Get("Code")
			set descripts=result.%Get("Descripts")
			set version=result.%Get("Version")
			set startDate=result.%Get("startDate")
			set stopDate=result.%Get("stopDate")			
			set provinceID=result.%Get("provinceID")
			set provinceDesc=result.%Get("provinceDesc")
			set cityID=result.%Get("cityID")
			set cityDesc=result.%Get("cityDesc")
						
			set dataObj={}
			set dataObj.id=id	
			set dataObj.code=code
			set dataObj.descripts=descripts
			set dataObj.startDate=startDate
			set dataObj.stopDate=stopDate			
			set dataObj.provinceID=provinceID
			set dataObj.provinceDesc=provinceDesc
			set dataObj.cityID=cityID
			set dataObj.cityDesc=cityDesc			
			set dataObj.version=version
			
			if startDate'=""{
				set startDate=$zdh(startDate,3)
			}
			if stopDate'=""{
				set stopDate=$zdh(stopDate,3)
			}			
			
			set iStatus=##class(src.DRG.Interface).IsRecordActive(startDate,stopDate)
							
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
		set errorInfo="查询ICD编码信息出现问题:w ##class("_$ClassName()_")GetMedInsuICDInfo("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage

	}
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-03-27
/// Description: 下载ICD编码导入模板
/// Output:      CSV格式模板内容（Base64编码）
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.ICDInfo).DownloadImportTemplate({}).%ToJSON()
ClassMethod DownloadImportTemplate(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (jsonObj)
    set resultObj={"errorCode":"0","errorMessage":"","result":{}}
    
    try {
        // 生成CSV内容 - 先使用纯ASCII字符测试
        set csvContent = "ICDCode,ICDDesc,Version,Remark"_$c(13,10)
        set csvContent = csvContent_"A01.001,Typhoid,ICD-10,National"_$c(13,10)
        set csvContent = csvContent_"A01.002,Paratyphoid,ICD-10,Standard"_$c(13,10)
        
        // Base64编码 - 使用%SYSTEM.Encryption.Base64Encode
        set base64Data = ##class(%SYSTEM.Encryption).Base64Encode(csvContent)
        
        set resultObj.result.fileName = "ICD编码导入模板.csv"
        set resultObj.result.fileData = base64Data
        set resultObj.result.contentType = "text/csv"
        
    } catch e {
        set status = e.AsStatus()
        set resultObj.errorCode = "04000007"
        set resultObj.errorMessage = "下载模板失败: "_$system.Status.GetErrorText(status)
    }
    
    quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-03-27
/// Description: ICD编码导入预览（校验数据并返回预览结果）
/// Table:       BS_DRGICDInfo (User.BSDRGICDInfo)
/// Input:       provinceID, cityID, fileData(Base64)
/// Output:      预览结果（含重复数据标记）
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.ICDInfo).PreviewImportICD({}).%ToJSON()
ClassMethod PreviewImportICD(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{"totalCount":0,"validCount":0,"invalidCount":0,"duplicateCount":0,"previewList":[]}}
	
	set totalCount=0,validCount=0,invalidCount=0,duplicateCount=0
	set previewList=[]
	
	try 
	{
		set params=jsonObj.params.%Get(0)
		set provinceID=params.provinceID
		set cityID=params.cityID
		set fileData=params.fileData
		
		// 参数校验
		if provinceID="" {
			set resultObj.errorCode="01000007"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000007")
			quit
		}
		if cityID="" {
			set resultObj.errorCode="01000008"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000008")
			quit
		}
		if fileData="" {
			set resultObj.errorCode="02010001"
			set resultObj.errorMessage="导入文件不能为空"
			quit
		}
		
		// Base64解码 - 尝试多种方法
		set csvContent = ""
		
		// 方法1: 使用$zcvt函数
		try {
			set csvContent = $zcvt(fileData, "I", "BASE64")
		} catch e1 {
			// 不输出调试信息，避免Web响应冲突
		}
		
		// 如果方法1失败，尝试方法2: 使用%SYSTEM.Encryption.Base64Decode并尝试多种编码
		if csvContent="" {
			try {
				set binaryData = ##class(%SYSTEM.Encryption).Base64Decode(fileData)
				
				// 尝试不同的编码方式
				// 1. 先尝试UTF-8
				set csvContent = $zcvt(binaryData, "I", "UTF8")
				
				// 2. 如果包含问号，尝试GB18030（中文标准编码）
				if csvContent["?" {
					set csvContent = $zcvt(binaryData, "I", "GB18030")
				}
				
				// 3. 如果仍然有问题，直接使用二进制数据
				if csvContent["?" {
					set csvContent = binaryData
				}
			} catch e2 {
				// 不输出调试信息，避免Web响应冲突
			}
		}
		
		// 如果仍然失败，尝试方法3: 使用%SYSTEM.Encryption.Base64Decode但不转换
		if csvContent="" {
			try {
				set binaryData = ##class(%SYSTEM.Encryption).Base64Decode(fileData)
				set csvContent = binaryData
			} catch e3 {
				// 不输出调试信息，避免Web响应冲突
			}
		}
		
		if csvContent="" 
		{
			set resultObj.errorCode="02010003"
			set resultObj.errorMessage="文件解码失败，请提供有效的CSV文件"
			quit
		}
		
		// 检查解码后的内容
		if csvContent="" 
		{
			set resultObj.errorCode="02010004"
			set resultObj.errorMessage="文件内容为空或解码失败"
			quit
		}
		
		// 解析CSV内容（增强版，支持中文字符和换行符处理）
		set lineNum=0
		set ptr=1
		set csvContent=$replace(csvContent,$c(13,10),$c(10))  // 统一换行符
		set csvContent=$replace(csvContent,$c(13),$c(10))    // 处理MAC格式换行符
		
		for 
		{
			set line=$piece(csvContent,$c(10),ptr)
			quit:line=""
			set ptr=ptr+1
			set lineNum=lineNum+1
			continue:lineNum=1  // 跳过表头
			continue:line=""
			
			set totalCount=totalCount+1
			set rowNum=lineNum-1  // 数据行号（不含表头）
			
			// 解析CSV列 - 使用安全的解析方法
			set errorMsg=""
			try 
			{
				set code=$piece(line,",",1)
			} 
			catch codeError 
			{
				set code=""
				set errorMsg="字段解析错误: " _ codeError.Name
			}
			
			try 
			{
				set desc=$piece(line,",",2)
			} 
			catch descError 
			{
				set desc=""
				set:'$data(errorMsg) errorMsg="字段解析错误: " _ descError.Name
			}
			
			try 
			{
				set version=$piece(line,",",3)
			} 
			catch versionError 
			{
				set version=""
				set:'$data(errorMsg) errorMsg="字段解析错误: " _ versionError.Name
			}										
			
			set previewObj={}
			set previewObj.rowNum=rowNum
			set previewObj.code=code
			set previewObj.desc=desc
			set previewObj.version=version
			set previewObj.provinceID=provinceID
			set previewObj.cityID=cityID
			set previewObj.remark=""
			set previewObj.errorMsg=errorMsg
			
			// 数据校验
			if (errorMsg '="")
			{
				// 字段解析错误
				set invalidCount=invalidCount+1
				set previewObj.errorMsg=errorMsg
				set previewObj.status="invalid"
				set previewObj.statusDesc="解析错误"
			} 		
			elseif code="" 
			{
				set previewObj.status="invalid"
				set previewObj.statusDesc="错误"
				set previewObj.errorMsg="ICD代码不能为空"
				set invalidCount=invalidCount+1
				do previewList.%Push(previewObj)
				continue
			}

			if desc="" 
			{
				set previewObj.status="invalid"
				set previewObj.statusDesc="错误"
				set previewObj.errorMsg="ICD描述不能为空"
				set invalidCount=invalidCount+1
				do previewList.%Push(previewObj)
				continue
			}
			
			if version="" 
			{
				set previewObj.status="invalid"
				set previewObj.statusDesc="错误"
				set previewObj.errorMsg="版本不能为空"
				set invalidCount=invalidCount+1
				do previewList.%Push(previewObj)
				continue
			}
			
			// 检查是否已存在
			set existingID=""
			&sql(SELECT ID INTO :existingID FROM SQLUser.BS_DRGICDInfo 
			     WHERE Code=:code AND Province_Dr=:provinceID AND City_Dr=:cityID and Version=:version)
			
			if existingID'="" 
			{
				set previewObj.status="duplicate"
				set previewObj.statusDesc="重复"
				set previewObj.errorMsg="该ICD代码已存在，导入将执行更新操作"
				set duplicateCount=duplicateCount+1
			} 
			else 
			{
				set previewObj.status="valid"
				set previewObj.statusDesc="正常"
				set validCount=validCount+1
			}
			
			do previewList.%Push(previewObj)
				
		    set resultObj.result.totalCount=totalCount
		    set resultObj.result.validCount=validCount
		    set resultObj.result.invalidCount=invalidCount
		    set resultObj.result.duplicateCount=duplicateCount
	    	set resultObj.result.previewList=previewList
		}
	} 
	catch(e) 
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage="预览失败："_errorMessage
	}
	
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-03-27
/// Description: 确认导入ICD编码信息
/// Table:       BS_DRGICDInfo (User.BSDRGICDInfo)
/// Input:       provinceID, cityID, fileData(Base64)
/// Output:      详细导入结果报告
/// Return:      接口响应对象
/// Debug:       w ##class(src.DRG.BasicData.ICDInfo).ConfirmImportICD({}).%ToJSON()
ClassMethod ConfirmImportICD(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{"totalCount":0,"successCount":0,"failCount":0,"duplicateCount":0,"newCount":0,"failList":[]}}
	
	set (totalCount,successCount,failCount,duplicateCount,newCount)=0
	set failList=[]
	
	try {
		set params=jsonObj.params.%Get(0)
		
		// 检查必需参数
		if '$isobject(params) {
			set resultObj.errorCode="02010001"
			set resultObj.errorMessage="参数错误：缺少params参数"
			quit
		}
		
		set fileData=params.fileData
		set fileName=params.fileName
		
		// 设置默认值或从params获取
		set provinceID=params.provinceID
		set cityID=params.cityID
		
		if (provinceID="")||(cityID="")
		{
			set resultObj.errorCode="-1"
			set resultObj.errorMessage="接口入参省、市代码不能为空！"
			quit	
		}
		
		// 创建用户ID（如果没有session参数，使用默认值）
		set createUserDr=""
		if $isobject(jsonObj.session) 
		{
			set session=jsonObj.session.%Get(0)
			set:session'="" createUserDr=session.userID
		}
		set:createUserDr="" createUserDr="158"  // 默认值
		
		// Base64解码 - 尝试多种方法（与PreviewImportICD保持一致）
		set csvContent = ""
		
		// 方法1: 使用$zcvt函数
		try {
			set csvContent = $zcvt(fileData, "I", "BASE64")
		} catch e1 {
			// 不输出调试信息，避免Web响应冲突
		}
		
		// 如果方法1失败，尝试方法2: 使用%SYSTEM.Encryption.Base64Decode并尝试多种编码
		if csvContent="" {
			try {
				set binaryData = ##class(%SYSTEM.Encryption).Base64Decode(fileData)
				
				// 尝试不同的编码方式
				// 1. 先尝试UTF-8
				set csvContent = $zcvt(binaryData, "I", "UTF8")
				
				// 2. 如果包含问号，尝试GB18030（中文标准编码）
				if csvContent["?" {
					try {
						set csvContent = $zcvt(binaryData, "I", "GB18030")
					} catch gbError {
						// 如果GB18030失败，尝试其他编码或直接使用二进制数据
						set csvContent = binaryData
					}
				}
				
				// 3. 如果仍然有问题，直接使用二进制数据
				if csvContent["?" {
					set csvContent = binaryData
				}
			} catch e2 {
				// 不输出调试信息，避免Web响应冲突
			}
		}
		
		if csvContent="" {
			set resultObj.errorCode="02010003"
			set resultObj.errorMessage="文件解码失败，请提供有效的CSV文件"
			quit
		}
		
		// 解析CSV并执行导入
		set lineNum=0
		set ptr=1
		for 
		{
			set line=$piece(csvContent,$c(10),ptr)
			quit:line=""
			set ptr=ptr+1
			set lineNum=lineNum+1
			continue:lineNum=1  // 跳过表头
			
			set line=$replace(line,$c(13),"")
			continue:line=""
			
			set totalCount=totalCount+1
			set rowNum=lineNum-1
			
			// 解析CSV列 - 使用安全的解析方法
			set errorMsg=""
			try 
			{
				set code=$piece(line,",",1)
			} 
			catch codeError 
			{
				set code=""
				set errorMsg="字段解析错误: " _ codeError.Name
			}
			
			try 
			{
				set desc=$piece(line,",",2)
			} 
			catch descError 
			{
				set desc=""
				set:'$data(errorMsg) errorMsg="字段解析错误: " _ descError.Name
			}
			
			try 
			{
				set version=$piece(line,",",3)
			} 
			catch versionError 
			{
				set version=""
				set:'$data(errorMsg) errorMsg="字段解析错误: " _ versionError.Name
			}
			
			try 
			{
				set remark=$piece(line,",",4)
			} 
			catch remarkError 
			{
				set remark=""
				set:'$data(errorMsg) errorMsg="字段解析错误: " _ remarkError.Name
			}
			
			// 跳过校验失败的行
	
			if (errorMsg '="")
			{
				// 字段解析错误
				set failCount=failCount+1
				set failObj={}
				set failObj.rowNum=rowNum
				set failObj.code=code
				set failObj.desc=desc
				set failObj.version=version
				set failObj.errorMsg=errorMsg
				do failList.%Push(failObj)
				continue
			} 			
			elseif (code="")||(desc="")||(version="")
		    {
				set failCount=failCount+1
				set failObj={}
				set failObj.rowNum=rowNum
				set failObj.code=code
				set failObj.desc=desc
				set failObj.version=version
				
				// 更详细的错误信息
				set errorDetail="必填字段为空: "
				if code="" set errorDetail=errorDetail_"code "
				if desc="" set errorDetail=errorDetail_"desc "
				if version="" set errorDetail=errorDetail_"version "
				set failObj.errorMsg=errorDetail
				
				do failList.%Push(failObj)
				continue
			}
												
			// 检查是否已存在
			set existingID=""
			&sql(SELECT ID INTO :existingID FROM BS_DRGICDInfo 
			     WHERE Code=:code AND Province_Dr=:provinceID AND City_Dr=:cityID And Version=:version)
			
			// 构建数据对象
			set dataObj={}
			set dataObj.Code=code
			set dataObj.Descripts=desc
			set dataObj.Version=version
			set dataObj.ProvinceDr=provinceID
			set dataObj.CityDr=cityID
			set dataObj.StartDate=$zd($h,3)
			set dataObj.StopDate=""
			set dataObj.CreateDate=$zd($h,3)
			set dataObj.CreateTime=$zt($p($h,",",2),1)
			set dataObj.CreateUserDr=createUserDr
			set dataObj.Remark=remark
			
			set insObj={},data=[]
			set insObj.className="User.BSDRGICDInfo"
			do data.%Push(dataObj)
			set insObj.data=data
			
			set operationType=""
			if existingID'="" 
			{
				// 更新
				set dataObj.ID=existingID
				set rtn=##class(src.util.operatetable).Update(.insObj)
				set operationType="更新"
				set duplicateCount=duplicateCount+1
			} 
			else 
			{
				// 新增
				set rtn=##class(src.util.operatetable).Insert(.insObj)
				set operationType="新增"
				set newCount=newCount+1
			}
			
			if rtn.errorCode'=0 
			{
				set failCount=failCount+1
				set failObj={}
				set failObj.rowNum=rowNum
				set failObj.code=code
				set failObj.errorMsg=rtn.errorMessage
				do failList.%Push(failObj)
			} 
			else 
			{
				set successCount=successCount+1
			}
		}
		
		set resultObj.result.totalCount=totalCount
		set resultObj.result.successCount=successCount
		set resultObj.result.failCount=failCount
		set resultObj.result.duplicateCount=duplicateCount
		set resultObj.result.newCount=newCount
		set resultObj.result.failList=failList
		
		if failCount>0 
		{
			set resultObj.errorCode="02010002"
			set resultObj.errorMessage="导入完成，部分数据导入失败，请查看失败列表"
		}
		
	} catch(e) {
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="导入ICD编码信息出现问题:w ##class("_$ClassName()_").ConfirmImportICD("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	
	quit resultObj
}

}
