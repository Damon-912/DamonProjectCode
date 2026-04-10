/// 登录
Class src.Logon.Logon Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 登录用户校验
/// Table:     	 HB_User      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Logon.Logon).IsValidUser({"params":[{"userName":"hcrm","passWord":"qlT17kO0ZH35/JJ0jUODLw=="}],"code":"01010001","session":[{"userID":"","locID":"","groupID":"","groupDesc":"","hospID":"","sessionID":"","hospCode":"","language":"","deviceID":"","hostName":"","ipv4":"171.223.210.38","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod IsValidUser(postObj) As %Library.DynamicAbstractObject
{
	new (postObj)
	try{
		set longonObj=postObj.params
		set iter = longonObj.%GetIterator()
		set (userCode,passWord,phoneCheck,mobileFlag)=""
		while iter.%GetNext(.key , .value ) {
			set userCode=longonObj.%Get(key).userName	; 工号
			set passWord=longonObj.%Get(key).passWord
			set phoneCheck=longonObj.%Get(key).phoneCheck
			set mobileFlag=longonObj.%Get(key).mobileFlag
		}
		set expStr="^"
		set outputobj={}
		
		; 验证登录错误日志
		/*set remoteAddress=%request.GetCgiEnv("REMOTE_ADDR")
		set failureObj={}
		set failureObj.remoteAddress=remoteAddress
		set failureObj.loginName=userCode
		set failureObj.mobileFlag=mobileFlag
		set checkFlagObj=##class(src.Logon.SessionLogon).CheckLoginFailureFlag(failureObj)
		if (checkFlagObj.errorCode'=0)&(phoneCheck'="Y") {
			set outputobj.errorCode=checkFlagObj.errorCode
			set outputobj.errorMessage=checkFlagObj.errorMessage
			quit
		}*/

		; 验证用户名密码是否正确
		set isValid=##class(src.Encryption.HBUser).IsValidUser(userCode,passWord,expStr)
		set result=[],resultobj={}
		if $p($g(isValid),"^",1)'=0 {
			set outputobj.errorCode=$p(isValid,"^",1)
			set outputobj.errorMessage=$p(isValid,"^",2)
			; 插入错误次数日志
			//do ##class(src.Logon.SessionLogon).InsertFailureInfo(failureObj)
			quit
		}
		//w isValid,!
		set userID=$p(isValid,"^",2)
		set userLogonType=$p(isValid,"^",3)
		b ;2
		set userInfo=##class(src.Encryption.HBUser).getUserInfo(userID)	
		if $p($g(userInfo),"^",1)'=0 {
			set outputobj.errorCode=$p(userInfo,"^",1)
			set outputobj.errorMessage=$p(userInfo,"^",2)
			quit
		}
		b
		set othLocInfo=##class(src.Encryption.HBUser).HaveOtherLoc(userID)	
		set outputobj={},result=[],resultobj={}
		if $p(userInfo,"^",1)=0 {
			set outputobj.errorCode="0"
			set outputobj.errorMessage="成功"
			set resultobj.userID=$p(userInfo,"^",2)
			set resultobj.userCode=$p(userInfo,"^",3)
			set resultobj.userName=$p(userInfo,"^",4)
			//set resultobj.locID=$p(userInfo,"^",5)
			//set resultobj.locDesc=$p(userInfo,"^",6)
			set resultobj.groupID=$p(userInfo,"^",7)
			set resultobj.groupDesc=$p(userInfo,"^",8)
			set resultobj.hospID=$p(userInfo,"^",9)
			set resultobj.hospDesc=$p(userInfo,"^",10)
			set resultobj.langID=1 //$p(userInfo,"^",11)
			set resultobj.langDesc="简体中文" //$p(userInfo,"^",12)
			//set resultobj.changeFlag=$p(userInfo,"^",13)
			//set resultobj.changeDesc=$p(userInfo,"^",14)
			//set resultobj.lastLoginDate=$p(userInfo,"^",15)
			//set resultobj.lastLoginTime=$p(userInfo,"^",16)
			//set resultobj.directorAuth=$p(userInfo,"^",17)
			
			set resultobj.othLocFlag=othLocInfo
			//set resultobj.userLogonType=userLogonType
			do result.%Push(resultobj)
			set outputobj.result=result
		}else{
			set outputobj.errorCode=$p(userInfo,"^",1)
			set outputobj.errorMessage=$p(userInfo,"^",2)
		}
		;DO outputobj.%FromJSON(111)
	}catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="验证用户信息出现问题:w ##class("_$ClassName()_").IsValidUser("")"
	    b
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set outputobj={}
		set outputobj.errorCode="05000001"
		set outputobj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	quit outputobj
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 用户登录
/// Table:     	 HB_User      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Logon.Logon).Logon({"params":[{"userID":"1","userCode":"xys","passWord":"qlT17kO0ZH35/JJ0jUODLw==","loginLocID":"1","loginGroupID":"1","loginHospID":"1","deviceID":"DESKTOP-SV3D2S3\\Nagisa","IP":"10.204.63.192","userLogonType":"03","mac":"00-FF-FA-E1-C9-D5"}],"code":"1011"}).%ToJSON()
ClassMethod Logon(postObj) As %Library.DynamicAbstractObject
{
	//new (postObj,%session,%request)
	new (postObj,%session)
	try{
		set longonObj=postObj.params
		set iter = longonObj.%GetIterator()
		set (userID,userCode,passWord,loginLocID,loginGroupID,loginHospID,deviceID,IP,userLogonType,mac,phoneCheck)=""
		while iter.%GetNext(.key , .value ) {
			set userID=longonObj.%Get(key).userID
			set userCode=longonObj.%Get(key).userName	; 工号
			set passWord=longonObj.%Get(key).passWord
			set loginLocID=1 //longonObj.%Get(key).loginLocID
			set loginGroupID=longonObj.%Get(key).loginGroupID
			set loginHospID=longonObj.%Get(key).loginHospID
			set deviceID="WEB:test20220705" //longonObj.%Get(key).deviceID
			set:longonObj.%Get(key).deviceID'="" deviceID=longonObj.%Get(key).deviceID
			
			set IP=longonObj.%Get(key).IP
			set userLogonType=longonObj.%Get(key).userLogonType
			set mac=longonObj.%Get(key).mac
			set phoneCheck=longonObj.%Get(key).phoneCheck
		}
		
		set outputobj={}
		; 验证登录错误日志
		/*set remoteAddress=%request.GetCgiEnv("REMOTE_ADDR")
		set failureObj={}
		set failureObj.remoteAddress=remoteAddress
		set failureObj.loginName=userCode
		set failureObj.loginHospID=loginHospID
		set checkFlagObj=##class(src.Logon.SessionLogon).CheckLoginFailureFlag(failureObj)
		if (checkFlagObj.errorCode'=0)&(phoneCheck'="Y") {
			set outputobj.errorCode=checkFlagObj.errorCode
			set outputobj.errorMessage=checkFlagObj.errorMessage
			quit
		}*/

	set expStr="^"
	; 验证用户名密码是否正确（密码为空则跳过验证，第一步已验证）
	if passWord'="" {
		set isValid=##class(src.Encryption.HBUser).IsValidUser(userCode,passWord,expStr)
		if $p($g(isValid),"^",1)'=0 {
			set outputobj.errorCode=$p(isValid,"^",1)
			set outputobj.errorMessage=$p(isValid,"^",2)
			quit
		}
		set userID=$p(isValid,"^",2)
	}

	set result=[],resultobj={}		; {} Library.DynamicObject,  [] Library.DynamicArray
		
		;登录方式验证
		if (userLogonType'="")&&("^01^02^03^04^05^06^"'[("^"_userLogonType_"^")) {
			set outputobj.errorCode=01040141
			set outputobj.errorMessage="不支持该登录方式！"
			//do ##class(src.Interface.Message).GetErrorMessageByCode("01040141",.outputobj)
			quit
		}
		;quit:$p($g(isValid),"^",1)'=0 outputobj
		; userID 已从前端参数获取（密码为空时）或从验证结果获取（密码不为空时）
		//b ;2
		set userInfo=##class(src.Encryption.HBUser).getUserInfo(userID)	
		if +$g(userInfo)'=0 {
			set outputobj.errorCode=$p(userInfo,"^",1)
			set outputobj.errorMessage=$p(userInfo,"^",2)
			quit
		}

		set expStr=userID_"^"_loginLocID_"^"_loginGroupID_"^"_loginHospID
		//w loginGroupID,!
		set authInfo=##class(src.Encryption.HBUser).GetLoginAuth(expStr)
		if (authInfo["@") {
			//do ##class(src.Interface.Message).GetErrorMessageByCode(+authInfo,.outputobj)
			quit
		}
		set outputobj={},result=[],resultobj={}
		if $p(userInfo,"^",1)=0 {
			set outputobj.errorCode="0"
			set outputobj.errorMessage="成功"
			set resultobj.userID=$p(userInfo,"^",2)
			set resultobj.userCode=$p(userInfo,"^",3)
			set resultobj.userName=$p(userInfo,"^",4)
			set resultobj.locID=loginLocID
			set resultobj.locDesc=$p(authInfo,"^",2)
			set resultobj.groupID=loginGroupID
			set resultobj.groupDesc=$p(authInfo,"^",3)
			set resultobj.hospID=loginHospID
			set resultobj.hospCode=$p(authInfo,"^",6)
			set resultobj.hospDesc=$p(authInfo,"^",4)
			set resultobj.langID=1 //$p(userInfo,"^",11)
			set resultobj.langDesc="简体中文" //$p(userInfo,"^",12)
			set resultobj.changeFlag=$p(userInfo,"^",13)
			set resultobj.changeDesc=$p(userInfo,"^",14)

			set resultobj.defaultMenuType=$p(authInfo,"^",5)
			set resultobj.mainInterface=$p(authInfo,"^",7)
			if resultobj.mainInterface'=""
			{
				//菜单路径查询
				Set linkPath=##Class(src.Group.MenuDetail).parentGroupMenu(resultobj.mainInterface)
				set resultobj.path=linkPath
			}else{
				set resultobj.path=""
			}
			//TODO 生成session
			set sessionStr=%session.SessionId
			Set param={"deviceID":(deviceID),"userID":(userID),"groupID":(loginGroupID),"hospID":(loginHospID),"mac":(mac),"IP":(IP),"sessionStr":(sessionStr)}
			Set sessionResult=##class(src.Rest.Session).SaveSessionByLogon(param)
			Set sessionID=sessionResult.result
			//Set ^TMP("sessionId")=sessionID
			Set sessionObj=$Get(^BSSessionD(sessionID))
			Set sessionStr=$ListGet(sessionObj,2)
			//Set ^TMP("session")=sessionStr
			set resultobj.sessionID=sessionStr //session
			do result.%Push(resultobj)
			set outputobj.result=result
			
			; 登录成功更新用户信息
			/*set updObj={},data=[]
			set updObj.className="User.HBUser"
			set updObj.updateUserID=userID
			set updObj.logFlag=1
			set dataobj={}
			set dataobj.ID=userID
			set dataobj.DateLastLogin=$zd(+$h,3)
			set dataobj.TimeLastLogin=$zt($p($h,",",2))
			do data.%Push(dataobj)
			set updObj.data=data
			set rtn=##class(src.util.operatetable).Update(.updObj)*/
			//b ;1
			//do ..SetLogonLog(userID, postObj, %session.SessionId)
		}else{
			set outputobj.errorCode=$p(userInfo,"^",1)
			set outputobj.errorMessage=$p(userInfo,"^",2)
		}
	}catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="登录程序出现异常:w ##class("_$ClassName()_").Logon("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set outputobj={}
		set outputobj.errorCode="05000001"
		set outputobj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	;DO outputobj.%FromJSON(111)
	
	quit outputobj
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 用户注销
/// Table:     	 HB_User      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Logon.Logon).Logout({"params": [{"sessionID":"8yG6pSf1MB","userID": "135"}],"code":"01010003"}).%ToJSON()
ClassMethod Logout(postObj) As %Library.DynamicAbstractObject
{
	new (postObj)
	Set outputobj={}
	set outputobj.errorCode="0"
	set outputobj.errorMessage="成功"
	set longoutObj=postObj.params.%Get(0)
	try{
		Set sessionStr=longoutObj.sessionID
		Set userID=longoutObj.userID
		/// w ##class(src.Rest.Session).DestroySession("SPidwDodna",2).%ToJSON()
		Return ##class(src.Rest.Session).DestroySession(sessionStr,userID)
	}catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    /*set errorInfo="用户注销出现异常:w ##class("_$ClassName()_").Logon("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set outputobj={}
		set outputobj.errorCode="05000001"
		set outputobj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")*/
	}
	Return outputobj
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 查询登录用户科室列表
/// Table:     	 HB_UserLogonLoc   
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Logon.Logon).GetLogonGroupByUserId({"params":[{"userID":"158"}]}).%ToJSON()
ClassMethod GetLogonGroupByUserId(postObj) As %Library.DynamicAbstractObject
{
	
	new (postObj)
	set ^TMP("GetLogonGroupByUserId")=postObj.%ToJSON()
	Set outputobj={}
	set outputobj.errorCode="0"
	set outputobj.errorMessage="成功"
	
	Set params=postObj.params.%Get(0)
	//Set session=postObj.session.%Get(0)
	
	Set sqlString="SELECT ID, User_Dr,User_Dr->Descripts userDesc, Hosp_Dr,Hosp_Dr->Descripts hospDesc,Hosp_Dr->Code hospCode, "_
				  " Group_Dr, Group_Dr->Descripts groupDesc, IsDefault, UpdateDate, UpdateTime, UpdateUser_Dr "_
				  " FROM SQLUser.HB_UserLogonLoc Where User_Dr="_params.userID
	Set st = ##class(%SQL.Statement).%New(1)
	Set sc = st.%Prepare(sqlString)
	Set rs = st.%Execute()
	Set list=[]
	b ;234
	While rs.%Next(){
		Set obj={}
		Set obj.userLogonLocID=rs.%Get("ID")
		Set obj.hospID=rs.%Get("Hosp_Dr")
		Set obj.hospDesc=rs.%Get("hospDesc")
		Set obj.hospCode=rs.%Get("hospCode")
		Set obj.groupID=rs.%Get("Group_Dr")
		Set obj.groupDesc=rs.%Get("groupDesc")
		
		Set obj.userID=rs.%Get("User_Dr")
		Set obj.userDesc=rs.%Get("userDesc")
		Set obj.isDefault=rs.%Get("IsDefault")
		;//所属医院
		set hospFlag=0
		set UserDr=rs.%Get("User_Dr")
		set linkHospID=""
		for{
			set linkHospID=$o(^HBUserLinkHospI("HospUser",rs.%Get("Hosp_Dr"),UserDr,linkHospID))
			quit:linkHospID=""
			set userExtobj=##class(User.HBUserLinkHosp).%OpenId(linkHospID)
			set dateFrom=userExtobj.StartDate
			set dateTo=userExtobj.StopDate
			continue:(dateFrom'="")&&(dateFrom>+$H)
			continue:(dateTo'="")&&(dateTo<+$H) 
			;//存在所属医院
			set hospFlag=1
		}
		continue:hospFlag=0
		//菜单路径
		set expStr=params.userID_"^"_1_"^"_rs.%Get("Group_Dr")_"^"_rs.%Get("Hosp_Dr")
		set authInfo=##class(src.Encryption.HBUser).GetLoginAuth(expStr)
		set obj.mainInterface=$p(authInfo,"^",7)
		set obj.defaultMenuType=$p(authInfo,"^",5)
		if obj.mainInterface'=""
		{
			Set groupMenuObj=$Get(^CBGroupMenuD(obj.mainInterface))
			Set preMenuDr=$ListGet(groupMenuObj,5)
			if preMenuDr'=""
			{
				Set menuObj=$Get(^CBMenuDetailD(preMenuDr))
				Set obj.pathDesc=$ListGet(menuObj,3)
				
				Set linkPath=##Class(src.Group.MenuDetail).parentGroupMenu(obj.mainInterface)
				
				Set obj.path=linkPath
			}
			else{
				Set obj.pathDesc=""
				Set obj.path=""
			}
		}else{
				Set obj.pathDesc=""
				Set obj.path=""
			}
		Do list.%Push(obj)
	}
	Set outputobj.result={}
	Set outputobj.result.rows=list
	Return outputobj
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 下拉列表通用查询    
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Logon.Logon).GetSelectList({"params": [{"sex":"Y","hospNature":"Y","hospType":"Y","hospGrade":"","productCat":"Y","productModule":"","credType":"","hospital":""}],"code":"01010005"}).%ToJSON()
ClassMethod GetSelectList(postObj) As %Library.DynamicAbstractObject
{
	new (postObj)
	Set outputobj={}
	set outputobj.errorCode="0"
	set outputobj.errorMessage="成功"
	
	Set params=postObj.params.%Get(0)
	//Set tableName=params.tableName
	//Return:tableName="" {"errorCode":1,"errorMessage":"tableName为空！"}
	
	Set outputobj.result={}
	if params.sex="Y"{
		Set tableName="CB_Sex"
		Set outputobj.result.sex=..ExcuteQuery(tableName)
	}
	if params.hospNature="Y"{
		Set tableName="CB_HospNature"
		Set outputobj.result.hospNature=..ExcuteQuery(tableName)
	}
	if params.hospType="Y"{
		Set tableName="CB_HospType"
		Set outputobj.result.hospType=..ExcuteQuery(tableName)
	}
	if params.hospGrade="Y"{
		Set tableName="CB_HospGrade"
		Set outputobj.result.hospGrade=..ExcuteQuery(tableName)
	}
	if params.productModule="Y"{
		Set tableName="CB_ProductModule"
		Set outputobj.result.productModule=..ExcuteQuery(tableName)
	}
	if params.productCat="Y"{
		Set tableName="CB_ProductCat"
		Set outputobj.result.productCat=..ExcuteQuery(tableName)
	}
	if params.credType="Y"{
		Set tableName="CB_CredType"
		Set outputobj.result.credType=..ExcuteQuery(tableName)
	}
	if params.hospital="Y"{
		Set tableName="CB_Hospital"
		Set outputobj.result.hospital=..ExcuteQuery(tableName)
	}
	if params.group="Y"{
		Set tableName="CB_Group"
		Set outputobj.result.group=..ExcuteQuery(tableName)
	}
	Return outputobj
}

/// w ##Class(src.Logon.Logon).ExcuteQuery("CB_CredType").%ToJSON()
ClassMethod ExcuteQuery(tableName) [ Internal ]
{
	
	Set sqlString="SELECT ID, Code, Descripts FROM SQLUser."_tableName
	//w sqlString,!
	Set st = ##class(%SQL.Statement).%New(1)
	Set sc = st.%Prepare(sqlString)
	Set rs = st.%Execute()
	Set list=[]
	While rs.%Next(){
		Set obj={}
		Set obj.id=rs.%Get("ID")
		Set obj.code=rs.%Get("Code")
		Set obj.descripts=rs.%Get("Descripts")
		Do list.%Push(obj)
	}
	Return list
}

/// w ##Class(src.Logon.Logon).UpdateLogonGroup({"params": [{"userLogonLocID":"1","isDefault":"N"},{"userLogonLocID":"2","isDefault":"N"}]}).%ToJSON()
ClassMethod UpdateLogonGroup(postObj)
{
	new (postObj)
	Set outputobj={}
	set outputobj.errorCode="0"
	set outputobj.errorMessage="成功"
	Set session="" //postObj.session.%Get(0)
	Set userId=1 //session.userID
	
	Try{
		TSTART
		for i=0:1:(postObj.params.%Size()-1){
			//w i,!
			Set jsonObj=postObj.params.%Get(i)
			//w jsonObj.%ToJSON(),!
			Set userLogonLocID=jsonObj.userLogonLocID
			Set isDefault=jsonObj.isDefault
			
			Set json={}
			Set json.className="User.HBUserLogonLoc"
			set json.updateUserID=userId
			Set data=[]
			Set newJsonObj={}
			Set newJsonObj.ID=userLogonLocID
			Set newJsonObj.IsDefault=isDefault
			Set newJsonObj.UpdateDate=$zd(+$h,3)
			Set newJsonObj.UpdateTime=$zt($p($h,",",2))
			do data.%Push(newJsonObj)
			Set json.data=data
			//w json.%ToJSON()
			Set rtn=##class(src.util.operatetable).Update(json)
			if rtn.errorCode'=0{
				Set resultJson.errorCode=rtn.errorCode
				Set resultJson.errorMessage=rtn.errorMessage
				Return resultJson
			}
			//Return rtn
		}
		TCOMMIT
	}Catch(e){
		TROLLBACK
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="修改默认登录权限出现问题:w ##class("_$ClassName()_").UpdateLogonGroup("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	Return outputobj
}

/// w ##Class(src.Logon.Logon).UpdateLogonGroupById({"params": [{"userLogonLocID":"3","isDefault":"Y"}]}).%ToJSON()
ClassMethod UpdateLogonGroupById(postObj)
{
	new (postObj)
	Set outputobj={}
	set outputobj.errorCode="0"
	set outputobj.errorMessage="成功"
	Set jsonObj=postObj.params.%Get(0)
	Set userLogonLocID=jsonObj.userLogonLocID
	Set isDefault=jsonObj.isDefault
	if userLogonLocID=""{
		set outputobj.errorCode="1"
		set outputobj.errorMessage="userLogonLocID为空！"
	}
	if isDefault=""{
		set outputobj.errorCode="1"
		set outputobj.errorMessage="isDefault为空！"
	}
	
	Set sqlString="SELECT ID FROM SQLUser.HB_UserLogonLoc Where User_Dr in (SELECT User_Dr FROM SQLUser.HB_UserLogonLoc Where id=?)"
	Set st = ##class(%SQL.Statement).%New(1)
	Set sc = st.%Prepare(sqlString)
	Set rs = st.%Execute(userLogonLocID)
	
	Set param={}
	Set param.session=postObj.session
	Set param.params=[]
	Do param.params.%Push(jsonObj)
	While rs.%Next(){
		Set obj={}
		Set obj.userLogonLocID=rs.%Get("ID")
		if userLogonLocID'=rs.%Get("ID"){
			if isDefault="Y"{
				Set obj.isDefault="N"
				Do param.params.%Push(obj)
			}elseif isDefault="N"{
				Set obj.isDefault="N"
				Do param.params.%Push(obj)
			}
		}
	}	
	Return ..UpdateLogonGroup(param)
}

}
