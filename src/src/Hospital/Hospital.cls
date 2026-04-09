Class src.Hospital.Hospital Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 查询医院分页
/// Table:     	 CB_Hospital      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Hospital.Hospital).FindHospDetail({"params":[{"active":"","descripts":""}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"Code","sortOrder":"asc"}]}).%ToJSON()
ClassMethod FindHospDetail(postObj)
{
	new (postObj)
	Set params=postObj.params.%Get(0)
	Set pagination=postObj.pagination.%Get(0)
	Set active=params.active
	set code =params.code 
	Set desc=params.desc
	set policyTypeDesc=params.policyTypeDesc
	set organizationCode=params.organizationCode
	Set sql=" select ID,Code,OrganizationCode, Descripts, HospGrade_Dr,HospGrade_Dr->Descripts gradeDesc, "
	       _" HospType_Dr,HospType_Dr->descripts typeDesc, HospNature_Dr, HospNature_Dr->descripts natureDesc, "
	       _" ProvID_Dr,ProvID_Dr->Descripts proDesc, CityID_Dr, CityID_Dr->Descripts cityDesc,AreaID_Dr, "
	       _" AreaID_Dr->Descripts areaDesc,PolicyType_Dr, PolicyType_Dr->Descripts policyTypeDesc, Active, Businesslicense, "
	       _" CreateDate, CreateTime, CreateUser_Dr from CB_Hospital where 1=1"	                        
	             
	//Set:active'="" sqlString=sqlString_" AND Active like '%"_active_"%'"
	//Set:desc'="" sqlString=sqlString_" AND Descripts like '%"_desc_"%'"
	//Set:code'="" sqlString=sqlString_" AND OrganizationCode like '%"_code_"%'"
	
		if (code'="")
		{
			set sql=sql_" and Code like '%"_code_"%'" 
		}
		
		if (organizationCode'="")
		{
			set sql=sql_" and OrganizationCode like '%"_organizationCode_"%'" 
		}				
				
		if (desc'="")
		{
			set sql=sql_" and Descripts like '%"_desc_"%'" 
		}
		
        if (policyTypeDesc'="")
		{
			set sql=sql_" and PolicyType_Dr->Descripts like '%"_policyTypeDesc_"%'" 
		}
		
		if (active'="")
		{
			set sql=sql_" and Active like '%"_active_"%'" 
		}		
	
	Return ##class(src.util.SQLUtil).SqlForList(sql,pagination)
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 查询医院分页
/// Table:     	 CB_Hospital      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Hospital.Hospital).FindHospDetail({"params":[{"active":"","descripts":""}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"Code","sortOrder":"asc"}]}).%ToJSON()
ClassMethod FindHospDetailooo(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try
	{
		if (postObj.%IsDefined("pagination")'=0) 
		{
			set pagationObj=postObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
			set currentPage=pagationObj.currentPage
		}
		set params=postObj.params.%Get(0)
		set code =postObj.code
		set desc=params.desc
		set active=params.active
		set tStatement = ##class(%SQL.Statement).%New(1)
	    Set sql =" select ID,ID as hospitalID, Code, Descripts, HospGrade_Dr, HospGrade_Dr->Descripts gradeDesc, "
	            _" HospType_Dr,HospType_Dr->descripts typeDesc, HospNature_Dr, HospNature_Dr->descripts natureDesc, "
	            _" ProvID_Dr,ProvID_Dr->Descripts proDesc, CityID_Dr, CityID_Dr->Descripts cityDesc,AreaID_Dr, "
	            _" AreaID_Dr->Descripts areaDesc, Active, OrganizationCode, Businesslicense, "
	            _" CreateDate, CreateTime, CreateUser_Dr from CB_Hospital where 1=1"		
		
		if code'=""
		{
			set sql=sql_" and OrganizationCode like '%"_code_"%'" 
		}		
				
		if desc'=""
		{
			set sql=sql_" and Descripts like '%"_desc_"%'" 
		}
			
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc)
		{
			set id=result.%Get("ID")
			set code=result.%Get("Code")
			set descripts=result.%Get("Descripts")
			set organizationCode=result.%Get("OrganizationCode")			
			set hospGradeID=result.%Get("HospGrade_Dr")
			set gradeDesc=result.%Get("gradeDesc")
			set hospTypeID=result.%Get("HospType_Dr")
			set typeDesc=result.%Get("typeDesc")
			set hospNatureID=result.%Get("HospNature_Dr")
			set natureDesc=result.%Get("natureDesc")
			set provID=result.%Get("ProvID_Dr")
			set proDesc=result.%Get("proDesc")
			set cityID=result.%Get("CityID_Dr")
			set cityDesc=result.%Get("cityDesc")
			set areaID=result.%Get("AreaID_Dr")
			set areaDesc=result.%Get("areaDesc")
			set active=result.%Get("Active")			
			set businesslicense=result.%Get("Businesslicense")
			set createDate=result.%Get("CreateDate")
			set createTime=result.%Get("CreateTime")
			set createUserID=result.%Get("CreateUser_Dr")
			set startDate=result.%Get("StartDate")
			set stopDate=result.%Get("StopDate")
			
			set dataObj={}
			set dataObj.id=id
			set dataObj.code=code
			set dataObj.descripts=descripts
			set dataObj.organizationCode=organizationCode									
			set dataObj.hospGradeID=hospGradeID
			set dataObj.gradeDesc=gradeDesc
			set dataObj.hospTypeID=hospTypeID
			set dataObj.typeDesc=typeDesc
			set dataObj.hospNatureID=hospNatureID
			set dataObj.natureDesc=natureDesc
			set dataObj.provID=provID
			set dataObj.proDesc=proDesc
			set dataObj.cityID=cityID
			set dataObj.cityDesc=cityDesc
			set dataObj.areaID=areaID
			set dataObj.areaDesc=areaDesc
			set dataObj.active=active
			set dataObj.businesslicense=businesslicense
			set dataObj.createDate=createDate		
			set dataObj.createTime=createTime
			set dataObj.createUserID=createUserID
			set dataObj.startDate=startDate
			set dataObj.stopDate=stopDate
			
			/*
			if startDate'=""
			{
				set startDate=$zdh(startDate,3)
			}
			if stopDate'=""
			{
				set stopDate=$zdh(stopDate,3)
			}
			set statusDesc="有效"
			set statusFlag=""
			if ((startDate'="")&&(startDate>$h))
			{
				set statusDesc="失效"
				set statusFlag="Y"
			}
			if ((stopDate'="")&&(stopDate<$h))
			{
				set statusDesc="失效"
				set statusFlag="Y"
			}
			if active="Y"
			{
				continue:statusFlag="Y"
			}
			set dataObj.statusDesc=statusDesc
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			
			*/
			do dataArr.%Push(dataObj)
		}
		
		set resultObj.result.Data=dataArr
		set resultObj.result.TotalCount=count		
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询医疗机构信息出现问题:w ##class("_$ClassName()_").FindHospDetail("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID

	}
	
	quit resultObj
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 新增医院
/// Table:     	 CB_Hospital      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug: w ##Class(src.Hospital.Hospital).AddHospConf({"params": [{"Code": "H02","OrganizationCode": "xx","Descripts": "123","HospTypeDr": "1","HospGradeDr": "1","HospNatureDr": "1","Businesslicense": "22","Active": "Y","CreateDate": "2022-02-03","CreateTime": "09:00:00","ProvIDDr": "1","CityIDDr": "1","AreaIDDr": "1","CreateUserDr":"1"}]}).%ToJSON()
ClassMethod AddHospConf(postObj)
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set resultJson={} 
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	
	Set userID=session.userID
	Return:userID="" {"errorCode":1,"errorMessage":"userID为空！"}
	Try{
		Set json={}
		Set json.className="User.CBHospital"
		set json.updateUserID=userID //userID
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj."Code"=jsonObj.code
		Set newJsonObj."OrganizationCode"=jsonObj.organizationCode
		Set newJsonObj."Descripts"=jsonObj.descripts
		Set newJsonObj."HospTypeDr"=jsonObj.hospTypeID
		Set newJsonObj."HospGradeDr"=jsonObj.hospGradeID
		Set newJsonObj."HospNatureDr"=jsonObj.hospNatureID
		Set newJsonObj."PolicyTypeDr"=jsonObj.policyTypeID
		Set newJsonObj."Businesslicense"=jsonObj.businesslicense
		Set newJsonObj."Active"="Y"
		Set:jsonObj.active'="" newJsonObj."Active"=jsonObj.active
		Set newJsonObj."CreateDate"=$zd(+$h,3)
		Set newJsonObj."CreateTime"=$zt($p($h,",",2))
		Set newJsonObj."ProvIDDr"=jsonObj.provIDID
		Set newJsonObj."CityIDDr"=jsonObj.cityIDID
		Set newJsonObj."AreaIDDr"=jsonObj.areaIDID
		Set newJsonObj."CreateUserDr"=userID

		do data.%Push(newJsonObj)
		Set json.data=data
		
		Set rtn=##class(src.util.operatetable).Insert(json)
		if rtn.errorCode'=0{
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage
			Return resultJson
		}
		Return rtn
	}Catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="添加医院出现问题:w ##class("_$ClassName()_").AddHospConf("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 修改医院
/// Table:     	 CB_Hospital     
/// Input:		{"params":[{"":""}]}
/// Return:  	 	 
/// Debug: w ##Class(src.Hospital.Hospital).UpdateHospConf({"params": [{"Code": "H04","OrganizationCode": "xx","Descripts": "123","HospTypeDr": "1","HospGradeDr": "1","HospNatureDr": "1","Businesslicense": "22","Active": "Y","CreateDate": "2022-02-03","CreateTime": "09:00:00","ProvIDDr": "1","CityIDDr": "1","AreaIDDr": "1","CreateUserDr":"1","ID":"1"}]}).%ToJSON()
ClassMethod UpdateHospConf(postObj)
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	Try{
		Set json={}
		Set json.className="User.CBHospital"
		set json.updateUserID=session.uesrID
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj."ID"=jsonObj.hospitalID
		Set newJsonObj."Code"=jsonObj.code
		Set newJsonObj."OrganizationCode"=jsonObj.organizationCode
		Set newJsonObj."Descripts"=jsonObj.descripts
		Set newJsonObj."HospTypeDr"=jsonObj.hospTypeID
		Set newJsonObj."HospGradeDr"=jsonObj.hospGradeID
		Set newJsonObj."HospNatureDr"=jsonObj.hospNatureID
		
		Set newJsonObj."PolicyTypeDr"=jsonObj.policyTypeID
		
		Set newJsonObj."Businesslicense"=jsonObj.businesslicense
		if jsonObj.active'="" Set newJsonObj."Active"=jsonObj.active
		Set newJsonObj."ProvIDDr"=jsonObj.provIDID
		Set newJsonObj."CityIDDr"=jsonObj.cityIDID
		Set newJsonObj."AreaIDDr"=jsonObj.areaIDID
		do data.%Push(newJsonObj)
		Set json.data=data
		Set rtn=##class(src.util.operatetable).Update(json)
		if rtn.errorCode'=0{
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage
			Return resultJson
		}
		Return rtn
	}Catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="修改医院出现问题:w ##class("_$ClassName()_").UpdateHospConf("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 删除医院
/// Table:     	 CB_Hospital
/// Input:		 {"params":[{"":""}]}      
/// Return:  	 	 
/// Debug: w ##Class(src.Hospital.Hospital).DeleteHospConf({"params":[{"hospitalID":1}]}).%ToJSON()
ClassMethod DeleteHospConf(postObj)
{
	new (postObj) 
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set ID=jsonObj.hospitalID
	set userID=jsonObj.userID
	
	if ID=""{
		Set resultJson.errorCode=1
		Set resultJson.errorMessage="记录id不能为空"
		Return resultJson
	}
	
	Try{
		Set json={}
		Set json.className="User.CBHospital"
		set json.updateUserID=session.userID
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj."ID"=ID
		do data.%Push(newJsonObj)
		Set json.data=data
		Set rtn=##class(src.util.operatetable).Delete(json)
		if rtn.errorCode'=0{
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage	
			Return resultJson
		}
		Return rtn
	}Catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="删除医院出现问题:w ##class("_$ClassName()_").DeleteHospConf("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 查询医院下拉框
/// Table:     	 CB_Hospital      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Hospital.Hospital).FindHospDetailList({"params":[{}],"code":"","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"2qxKMKf160","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod FindHospDetailList(postObj)
{
	new (postObj)
	Set params=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set hospID=session.hospID
	Set groupID=session.groupID
	set hospital=[]
	set hospStr=##class(src.CBTable.CBTableData).GetHosptialAuth(groupID,hospID,"User.CBHospital")
	if hospStr="" set hospStr=hospID
	if hospStr'=""{
		for i=1:1:$l(hospStr,"^"){
			set hospId=$p(hospStr,"^",i)
			continue:hospId=""
			set hospObj=$CLASSMETHOD("User.CBHospital","%OpenId",hospId)
			set obj={}
			set obj.id=hospId
			set obj.code=hospObj.Code
			set obj.descripts=hospObj.Descripts
			do hospital.%Push(obj)
		}
	}
	set resultJson={}
	set resultJson.errorCode="0"
	set resultJson.errorMessage="成功"
	set resultJson.result=hospital
	quit resultJson
}

}
