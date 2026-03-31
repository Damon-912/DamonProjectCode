Class src.BasicData.SelectDate Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     zxz
/// CreatDate:   2022-7-4
/// Description: 获取国家下拉数据
/// code:	 01010006	 
/// Input:		
/// Debug：		 w ##class(src.BasicData.SelectDate).GetCountryData().%ToJSON()  
ClassMethod GetCountryData() As %Library.DynamicObject
{
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	set resultObj.result={}
	set dataArr=[]
	try{
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_Country"
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.descriptsSPCode=result.%Get("ENDesc")
			set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(result.%Get("Descripts"))
			do dataArr.%Push(dataObj)
		}	
		set resultObj.result=dataArr
	}catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="查询国家下拉出现问题:w ##class("_$ClassName()_").GetCountryData("")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
	
	quit resultObj
}

/// Creator:     zxz
/// CreatDate:   2022-7-4
/// Description: 获取省下拉数据
/// code:		 01010007
/// Input:		
/// Debug：		 w ##class(src.BasicData.SelectDate).GetProvinceData({"params":[{"countryID":44}],"code":"02020008","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"TRibr7TkvG","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()  
ClassMethod GetProvinceData(postJson) As %Library.DynamicObject
{
	new (postJson)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	set resultObj.result={}
	set dataArr=[]
	set params=postJson.params.%Get(0)
	set countryID=params.countryID
	try{
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_Province where 1=1"
		if countryID'=""{
			set sql=sql_" and Country_Dr="_countryID
		}
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.descriptsSPCode=result.%Get("ENDesc")
			set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(result.%Get("Descripts"))
			do dataArr.%Push(dataObj)
		}
	set resultObj.result=dataArr	
	}catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="查询省下拉出现问题:w ##class("_$ClassName()_").GetDictionariesDetailedList("_postJson.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
	
	quit resultObj
}

/// Creator:     zxz
/// CreatDate:   2022-7-4
/// Description: 获取市下拉数据
/// code:		 01010008
/// Input:		
/// Debug：		 w ##class(src.BasicData.SelectDate).GetCityData({"params":[{"provinceID":"2"}],"code":"02020009","session":[{"userID":"2","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"2","sessionID":"TRibr7TkvG","hospCode":"H02","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()  
ClassMethod GetCityData(postJson) As %Library.DynamicObject
{
	new (postJson)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	set resultObj.result={}
	set dataArr=[]
	set params=postJson.params.%Get(0)
	set provinceID=params.provinceID
	try{
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_City where 1=1"
		if provinceID'=""{
			set sql=sql_" and Province_Dr="_provinceID
		}
		b ;; sql
		do ##class(User.CBCity).%BuildIndices()
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.descriptsSPCode=result.%Get("ENDesc")
			set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(result.%Get("Descripts"))
			do dataArr.%Push(dataObj)
		}
	set resultObj.result=dataArr	
	}catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="查询市下拉出现问题:w ##class("_$ClassName()_").GetDictionariesDetailedList("_postJson.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
	
	quit resultObj
}

/// Creator:     zxz
/// CreatDate:   2022-7-4
/// Description: 获取区下拉数据
/// code:		 01010009
/// Input:		
/// Debug：		 w ##class(src.BasicData.SelectDate).GetAreaData().%ToJSON()  
ClassMethod GetAreaData(postJson) As %Library.DynamicObject
{
	new (postJson)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	set resultObj.result={}
	set dataArr=[]
	set params=postJson.params.%Get(0)
	set cityID=params.cityID
	try{
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_Area where 1=1"
		if cityID'=""{
			set sql=sql_" and City_Dr="_cityID
		}
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.descriptsSPCode=result.%Get("ENDesc")
			set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(result.%Get("Descripts"))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result=dataArr
	}catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="查询区下拉出现问题:w ##class("_$ClassName()_").GetDictionariesDetailedList("_postJson.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
	
	quit resultObj
}

/// Creator:     zxz
/// CreatDate:   2022-7-4
/// Description: 获取性别下拉数据
/// code:		 01010009
/// Input:		
/// Debug：		 w ##class(src.BasicData.SelectDate).GetSexData().%ToJSON()  
ClassMethod GetSexData(postJson) As %Library.DynamicObject
{
	new (postJson)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	set resultObj.result={}
	set dataArr=[]
	try{
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_Sex where 1=1"
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.descriptsSPCode=result.%Get("ENDesc")
			set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(result.%Get("Descripts"))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result=dataArr
	}catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set resultObj={}
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage
	}
	
	quit resultObj
}

/// Creator:     zxz
/// CreatDate:   2022-7-4
/// Description: 获取证件下拉数据
/// code:		 01010009
/// Input:		
/// Debug：		 w ##class(src.BasicData.SelectDate).GetCredTypeData().%ToJSON()  
ClassMethod GetCredTypeData(postJson) As %Library.DynamicObject
{
	new (postJson)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	set resultObj.result={}
	set dataArr=[]
	try{
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_CredType where 1=1"
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.descriptsSPCode=result.%Get("ENDesc")
			set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(result.%Get("Descripts"))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result=dataArr
	}catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set resultObj={}
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage
	}
	
	quit resultObj
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 获取医院下拉数据
/// code:		 01010064
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Hospital.Hospital).FindHospDetail({"params":[{"active":"","descripts":""}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"Code","sortOrder":"asc"}]}).%ToJSON()
ClassMethod FindHospDetail(postObj)
{
		
    new (postJson)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	set resultObj.result={}
	set dataArr=[]
	try{
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT ID, OrganizationCode as Code, Descripts, HospGrade_Dr AS MedinsLv,HospGrade_Dr->Descripts gradeDesc, HospType_Dr,HospType_Dr->descripts typeDesc, HospNature_Dr, HospNature_Dr->descripts natureDesc, ProvID_Dr,ProvID_Dr->Descripts proDesc, CityID_Dr, CityID_Dr->Descripts cityDesc,AreaID_Dr, AreaID_Dr->Descripts areaDesc, Active, Businesslicense, CreateDate, CreateTime, CreateUser_Dr FROM CB_Hospital where 1=1"
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.medinsLv=result.%Get("MedinsLv")
			set dataObj.descriptsSPCode=result.%Get("gradeDesc")
			set dataObj.descriptsSPCode=##class(src.Interface.ChineseCharacter).GetSPCodeByDescNew(result.%Get("Descripts"))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result=dataArr
	}catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set resultObj={}
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage
	}
	
	quit resultObj
}

}
