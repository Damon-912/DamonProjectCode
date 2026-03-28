/// 用户申请
Class src.User.UserAuditLog Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 查询用户申请记录分页
/// Table:     	 HB_UserAuditLog     
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.User.UserAuditLog).FindApplyLog({"params":[{"auditStatus":"No","hospitalID":"","beginDate":"","endDate":""}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"Code","sortOrder":"asc"}]}).%ToJSON()
ClassMethod FindApplyLog(postObj)
{
	new (postObj)
	
	Set params=postObj.params.%Get(0)
	Set pagination=postObj.pagination.%Get(0)
	
	Set hospID=params.hospitalID
	Set auditStatus=params.auditStatus
	Set beginDate=params.beginDate
	Set endDate=params.endDate
	
	Set sqlString="SELECT ID, Code, Descripts, Password, Sex_Dr,Sex_Dr->Descripts sexDesc, Active, Hospital_Dr, Mobile, CredType_Dr, CredNo, "_
				  "Image, Introduce, AuditUser_Dr, AuditGroup_Dr, AuditStatus, AuditRemarks, "_
				  "ApplyDate, ApplyTime,to_char(to_char(ApplyDate)||','||to_char(ApplyTime),'YYYY-MM-DD hh:mm:ss') applyDateTime, "_
				  "CreatedBy_Dr, CreatedDate, CreatedTime,to_char(to_char(CreatedDate)||','||to_char(CreatedTime),'YYYY-MM-DD hh:mm:ss') createDateTime "_
			      "FROM SQLUser.HB_UserAuditLog where 1=1"
	Set:hospID'="" sqlString=sqlString_" AND Hospital_Dr ="_hospID
	Set:auditStatus'="" sqlString=sqlString_" AND AuditStatus ='"_auditStatus_"'"
	if ((beginDate'="") && (endDate'="")){
		Set sqlString=sqlString_" AND ApplyDate Between "_beginDate_" And "_endDate
	}
	Set result=##class(src.util.SQLUtil).SqlForList(sqlString,pagination)
	
	Return result
}

/// Creator:     LYP
/// CreatDate:   2022-06-30 
/// Description: 注册
/// Table:     	 HB_UserAuditLog     
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug: w ##Class(src.User.UserAuditLog).UserApply({"params": [{"Code": "LYP","Introduce": "介绍","Image": "","Descripts": "111","Password": "acb","SexDr": "1","Mobile": "18008093593","HospitalDr": "2","CredNo": "2","CertTypeDr": "1","Active": "Y","CreatedByDr": "1","AuditUserDr":"1","AuditGroupDr":"1","AuditStatus":"","AuditRemarks":"123"}]}).%ToJSON()
ClassMethod UserApply(postObj)
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	
	Try{
		Set json={}
		Set json.className="User.HBUserAuditLog"
		Set json.updateUserID=session.userID
		Set jsonObj.auditStatus="R" //待审核状态
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj.Code=jsonObj.code
		Set newJsonObj.Introduce=jsonObj.introduce
		Set newJsonObj.Image=jsonObj.image
		Set newJsonObj.Descripts=jsonObj.descripts
		Set newJsonObj.Password=jsonObj.password
		Set newJsonObj.SexDr=jsonObj.sexID
		Set newJsonObj.Mobile=jsonObj.mobile
		Set newJsonObj.HospitalDr=jsonObj.hospitalID
		Set newJsonObj.CredNo=jsonObj.credNo
		Set newJsonObj.CredTypeDr=jsonObj.credTypeID
		Set newJsonObj.Active="N" 
		Set newJsonObj.CreatedDate=$zd(+$h,3)
		Set newJsonObj.CreatedTime=$zt($p($h,",",2))
		Set newJsonObj.CreatedByDr=session.userID
		///Set newJsonObj."AuditUserDr"=jsonObj.auditUserID
		Set newJsonObj.AuditGroupDr=jsonObj.auditGroupID
		Set newJsonObj.AuditStatus=jsonObj.auditStatus
		Set newJsonObj.AuditRemarks=jsonObj.auditRemarks
		Set newJsonObj.ApplyDate=$zd(+$h,3)
		Set newJsonObj.ApplyTime=$zt($p($h,",",2))
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
	    set errorInfo="注册出现异常:w ##class("_$ClassName()_").UserApply("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 审核用户申请
/// Table:     	 HB_UserAuditLog     
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug: w ##Class(src.User.UserAuditLog).Aduit({"params":[{"auditStatus":"Y","userAuditLogID":"5","auditRemarks":""}],"code":"01030106","session":[{"userID":"81","locID":1,"groupID":"1","groupDesc":"测试角色","hospID":"7","sessionID":"DhTRMQ8dEB","hospCode":"12324","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod Aduit(postObj)
{
	new (postObj)
	Set ^TMP("Aduit")=postObj.%ToJSON()
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage="操作成功！"
	Set ^TMP("Aduit1")=1
	
	Try{
		Set auditStatus=jsonObj.auditStatus
		Set userAuditLogID=jsonObj.userAuditLogID
		Set auditRemarks=jsonObj.auditRemarks
		Return:auditStatus="" {}
		
		TSTART
		if auditStatus="Y"{
			//用户申请记录详情
			Set param={}
			Set param.params=[]
			Set param.session=[]
			Set queryObj={}
			Set ^TMP("Aduit2")=2
			Set queryObj.userAuditLogID=userAuditLogID
			Do param.session.%Push(session)
			Do param.params.%Push(queryObj)
			Set ^TMP("Aduit3")=param.%ToJSON()
			Set auditObj=..UserAuditLogDetail(param).result
			Set ^TMP("Aduit4")=auditObj.%ToJSON()
			//用户插入到HB_User表
			Set param={}
			Set obj={}
			Set param.params=[]
			Set param.session=[]
			Do param.session.%Push(session)
			Do param.params.%Push(auditObj)
			Set ^TMP("Aduit5")=param.%ToJSON()
			Set saveResult = ##class(src.User.User).AddUserConf(param)
			Set ^TMP("Aduit6")=saveResult.%ToJSON()
			Throw:saveResult.errorCode'=0 ##class(%Exception.SQL).CreateFromSQLCODE(saveResult.errorCode,saveResult.errorMessage)
			//HBUser主键
			Set rowUserID=saveResult.rowIDArr.%Get(0)
			//Set ^TMP("Aduit7")=rowUserID
			Throw:rowUserID="" ##class(%Exception.SQL).CreateFromSQLCODE("1","HBUser主键为空！")
		
			//权限记录到HB_UserLogo表
			Set paramLogon={}
			Set paramLogon.params=[]
			Set paramLogon.session=[]
			Set obj={}
			Set ^TMP("Aduit7")=rowUserID
			Set obj.userID=rowUserID
			Set obj.hospID=auditObj.hospitalID
			Set obj.groupID=auditObj.auditGroupID
			Set obj.isDefault="N"
			Set obj.updateUserID=1
			Set obj.updateDate=$zd(+$h,3)
			Set obj.updateTime=$zt($p($h,",",2),3)
			Do paramLogon.params.%Push(obj)
			Do paramLogon.session.%Push(session)
			Set resul = ##Class(src.User.UserLogonLoc).SaveUserLogonLoc(paramLogon,rowUserID)
			Throw:resul.errorCode'=0 ##class(%Exception.SQL).CreateFromSQLCODE(resul.errorCode,resul.errorMessage)
		}
		//更新UserAuditLog的审核状态
		Set param={}
		Set param.params=[]
		Set param.session=[]
		Set obj={}
		Set obj.userAuditLogID=userAuditLogID
		Set obj.auditStatus=auditStatus
		Set obj.auditRemarks=auditRemarks
		Set obj.AuditUserDr=session.userID
		Do param.params.%Push(obj)
		Do param.session.%Push(session)
		//w param.%ToJSON(),!
		Set updateResult=..UpdateUserLog(param)
		Throw:updateResult.errorCode'=0 ##class(%Exception.SQL).CreateFromSQLCODE(updateResult.errorCode,updateResult.errorMessage)
		TCOMMIT
	}Catch(e){
		TROLLBACK
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="审核用户出现异常:w ##class("_$ClassName()_").Aduit("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 更新用户申请
/// Table:     	 HB_UserAuditLog     
/// Input:		{"params":[{"":""}]}
/// Return:  	 	 
/// Debug: w ##Class(src.User.UserAuditLog).UpdateUserLog({"params": [{"userAuditLogID":"1","auditStatus":"N"}]}).%ToJSON()
ClassMethod UpdateUserLog(postObj)
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	Try{
		Set json={}
		Set json.className="User.HBUserAuditLog"
		set json.updateUserID=session.uesrID
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj.ID=jsonObj.userAuditLogID
		//Set newJsonObj."Code"=jsonObj.code
		//Set newJsonObj."Introduce"=jsonObj.introduce
		//Set newJsonObj."Image"=jsonObj.image
		//Set newJsonObj."Descripts"=jsonObj.descripts
		//Set newJsonObj."Password"=jsonObj.password
		//Set newJsonObj."SexDr"=jsonObj.sexID
		//Set newJsonObj."Mobile"=jsonObj.mobile
		//Set newJsonObj."HospitalDr"=jsonObj.hospitalID
		//Set newJsonObj."CredNo"=jsonObj.credNo
		//Set newJsonObj."CertTypeDr"=jsonObj.certTypeID
		//Set newJsonObj."Active"=jsonObj.active
		//Set newJsonObj."CreateDate"=jsonObj.createDate
		//Set newJsonObj."CreateTime"=jsonObj.createTime
		//Set newJsonObj."CreatedByDr"=jsonObj.createdByID
		//Set newJsonObj."AuditUserDr"=jsonObj.auditUserID
		//Set newJsonObj."AuditGroupDr"=jsonObj.auditGroupID
		Set newJsonObj.AuditStatus=jsonObj.auditStatus
		Set newJsonObj.AuditRemarks=jsonObj.auditRemarks
		do data.%Push(newJsonObj)
		Set json.data=data
		Set rtn=##class(src.util.operatetable).Update(json)
		if rtn.errorCode'=0{
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage
			Return resultJson
		}
	}Catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="更新用户申请出现异常:w ##class("_$ClassName()_").UpdateUserLog("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 查询用户申请详情信息
/// Table:     	 HB_UserAuditLog     
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug: w ##Class(src.User.UserAuditLog).UserAuditLogDetail({"params":[{"userAuditLogID":"16"}]}).%ToJSON()
ClassMethod UserAuditLogDetail(postObj)
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	Set userAuditLogID=jsonObj.userAuditLogID
	
	Set sqlString="select ID, Code, Descripts, Password,Sex_Dr, Sex_Dr->Descripts sexDesc, Active, Hospital_Dr, Hospital_Dr->Descripts hospDesc, Mobile, CredType_Dr, CredType_Dr->Descripts credTypeDesc, CredNo, Image, Introduce, AuditUser_Dr,AuditUser_Dr->Descripts auditUserDesc, AuditGroup_Dr, AuditGroup_Dr->Descripts auditGroupDesc, AuditStatus, AuditRemarks, ApplyDate, ApplyTime, CreatedBy_Dr, CreatedDate, CreatedTime from HB_UserAuditLog where ID="_userAuditLogID
	//w sqlString,!
	Return ##class(src.util.SQLUtil).SqlForObject(sqlString)
}

}
