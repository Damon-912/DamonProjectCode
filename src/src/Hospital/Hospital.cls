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
	Set desc=params.descripts
	Set sqlString="select ID, Code, Descripts, HospGrade_Dr,HospGrade_Dr->Descripts gradeDesc, HospType_Dr,HospType_Dr->descripts typeDesc, HospNature_Dr, HospNature_Dr->descripts natureDesc, ProvID_Dr,ProvID_Dr->Descripts proDesc, CityID_Dr, CityID_Dr->Descripts cityDesc,AreaID_Dr, AreaID_Dr->Descripts areaDesc, Active, OrganizationCode, Businesslicense, CreateDate, CreateTime, CreateUser_Dr from CB_Hospital where 1=1"
	Set:active'="" sqlString=sqlString_" AND Active like '%"_active_"%'"
	Set:desc'="" sqlString=sqlString_" AND Descripts like '%"_desc_"%'"
	Return ##class(src.util.SQLUtil).SqlForList(sqlString,pagination)
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
