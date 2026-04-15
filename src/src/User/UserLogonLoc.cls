Class src.User.UserLogonLoc Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 插入用户权限记录表
/// Table:     	 HB_UserLogonLoc      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug: w ##Class(src.User.UserLogonLoc).SaveUserLogonLoc({"params":[{"userID":"160","userCode":"huangyaguang","hospID":"11","groupID":"1","isDefault":"Y","hospDesc":"昆明普瑞眼科医院","groupDesc":"管理员"}],"code":"01030109","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"zg1spNoB1u","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod SaveUserLogonLoc(postObj, userSaveID)
{
	new (postObj,userSaveID)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	
	Try{
		Set json={}
		Set json.className="User.HBUserLogonLoc"
		Set json.updateUserID=session.userID    //userID
		Set data=[]
		Set obj={}
		Set obj.UserDr=jsonObj.userID
		Set obj.HospDr=jsonObj.hospID
		Set obj.GroupDr=jsonObj.groupID
		Set obj.IsDefault=jsonObj.isDefault
		Set obj.UpdateUserDr=session.userID
		Set obj.UpdateDate=$zd(+$h,3)
		set obj.StartDate=$zd(+$h,3)
		Set:jsonObj.updateDate'="" obj.UpdateDate=jsonObj.updateDate
		Set obj.UpdateTime=$zt($p($h,",",2))
		Set:jsonObj.updateTime'="" obj.UpdateTime=jsonObj.updateTime

		do data.%Push(obj)
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
	    set errorInfo="新增用户权限出现异常:w ##class("_$ClassName()_").SaveUserLogonLoc("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
		b
	}
	
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 更新用户权限记录表
/// Table:     	 HB_UserLogonLoc     
/// Input:		{"params":[{"":""}]}
/// Return:  	 	 
/// Debug: w ##Class(src.User.UserLogonLoc).UpdateUserLogonLoc({"params":[{"userLogonLocID":2,"hospID":"6","hospDesc":"南宁普瑞2","hospCode":"H04","groupID":"10","groupDesc":"测试角色","userID":135,"userDesc":"系统管理员","isDefault":"Y","startDate":"2022-07-12","stopDate":"","key":"1"}],"code":"01030109","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"OM9jv04khE","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod UpdateUserLogonLoc(postObj)
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	set userID=jsonObj.userID
	set:userID="" userID=session.userID
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	Try{
		Set json={}
		Set json.className="User.HBUserLogonLoc"
		set json.updateUserID=session.userID //uesrID
		Set data=[]
		Set obj={}
		Set obj.ID=jsonObj.userLogonLocID
		Set obj.UserDr=userID
		Set obj.HospDr=jsonObj.hospID
		Set obj.GroupDr=jsonObj.groupID
		Set obj.IsDefault=jsonObj.isDefault
		Set obj.UpdateUserDr=session.userID
		Set obj.UpdateDate=$zd(+$h,3)
		Set obj.UpdateTime=$zt($p($h,",",2))
		do data.%Push(obj)
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
	    b
	    set errorInfo="新增用户权限出现异常:w ##class("_$ClassName()_").UpdateUserLogonLoc("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 删除用户权限
/// Table:     	 HB_UserLogonLoc     
/// Input:		{"params":[{"":""}]}
/// Return:  	 	 
/// Debug: w ##Class(src.User.UserLogonLoc).UpdateUserLogonLoc({"params": [{"userLogonLocID":"1"}]}).%ToJSON()
ClassMethod DeleteUserLogon(postObj)
{
	new (postObj) 
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set ID=jsonObj.userLogonLocID
	set userID=jsonObj.userID
	
	if ID=""{
		Set resultJson.errorCode=1
		Set resultJson.errorMessage="记录id不能为空"
		Return resultJson
	}
	
	Try{
		Set json={}
		Set json.className="User.HBUserLogonLoc"
		set json.updateUserID=session.userID
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj.ID=ID
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
	    set errorInfo="新增用户权限出现异常:w ##class("_$ClassName()_").DeleteUserLogon("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 查询登录用户科室列表
/// Table:     	 HB_UserLogonLoc   
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.User.UserLogonLoc).GetLogonGroupByUserId({"params":[{"userID":"1","userCode":"xys","currentLocFlag":"Y","language":"CN"}]}).%ToJSON()
ClassMethod GetLogonGroupByUserId(postObj) [ Internal ]
{
	new (postObj)
	Set outputobj={}
	set outputobj.errorCode="0"
	set outputobj.errorMessage="成功"
	
	Set params=postObj.params.%Get(0)
	Set sqlString="SELECT ID, User_Dr,User_Dr->Descripts userDesc, Hosp_Dr,Hosp_Dr->Descripts hospDesc,Hosp_Dr->Code hospCode, "_
				  " Group_Dr, Group_Dr->Descripts groupDesc, IsDefault, UpdateDate, UpdateTime, UpdateUser_Dr,StartDate,StopDate "_
				  " FROM SQLUser.HB_UserLogonLoc Where User_Dr="_params.userID_
				  " Order By IsDefault DESC"
	Set st = ##class(%SQL.Statement).%New(1)
	Set sc = st.%Prepare(sqlString)
	Set rs = st.%Execute()
	Set list=[]
	While rs.%Next(){
		
		Set StartDate=rs.%Get("StartDate")
		Set StopDate=rs.%Get("StopDate")
		continue:$zdh(StartDate,3)>(+$h)
		if StopDate'=""
		{
			continue:$zdh(StopDate,3)<(+$h)
		}
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
		Do list.%Push(obj)
	}
	Set outputobj.result={}
	Set outputobj.result.rows=list
	Return outputobj
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 查询用户角色列表
/// Table:     	 HB_UserLogonLoc   
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.User.UserLogonLoc).GetLogonGroupByUserId({"params":[{"userID":"1","userCode":"xys","currentLocFlag":"Y","language":"CN"}]}).%ToJSON()
ClassMethod GetGroupByUserId(postObj) [ Internal ]
{
	new (postObj)
	Set outputobj={}
	set outputobj.errorCode="0"
	set outputobj.errorMessage="成功"
	Set params=postObj.params.%Get(0)
	Set sqlString="SELECT ID, User_Dr,User_Dr->Descripts userDesc, Hosp_Dr,Hosp_Dr->Descripts hospDesc,Hosp_Dr->Code hospCode, "_
				  " Group_Dr, Group_Dr->Descripts groupDesc, IsDefault, UpdateDate, UpdateTime, UpdateUser_Dr,StartDate,StopDate "_
				  " FROM SQLUser.HB_UserLogonLoc Where User_Dr="_params.userID_
				  " Order By IsDefault DESC"
	Set st = ##class(%SQL.Statement).%New(1)
	Set sc = st.%Prepare(sqlString)
	Set rs = st.%Execute()
	Set list=[]
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
		Set obj.startDate=rs.%Get("StartDate")
		Set obj.stopDate=rs.%Get("StopDate")
		Do list.%Push(obj)
	}
	Set outputobj.result={}
	Set outputobj.result.rows=list
	Return outputobj
}

/// Creator:     Damon
/// CreatDate:   2026-04-14
/// Description: 保存用户医院关联记录
/// Table:     	 HB_UserLinkHosp   
/// Input:		{"params":[{"userID":"1","hospID":"11"}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.User.UserLogonLoc).SaveUserLinkHosp({"params":[{"userID":"1","hospID":"11"}],"session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8"}]}).%ToJSON()
ClassMethod SaveUserLinkHosp(postObj)
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage="成功"
	
	Try{
		Set userID=jsonObj.userID
		Set hospID=jsonObj.hospID
		
		if userID=""{
			Set resultJson.errorCode=1
			Set resultJson.errorMessage="用户ID不能为空"
			Return resultJson
		}
		if hospID=""{
			Set resultJson.errorCode=1
			Set resultJson.errorMessage="医院ID不能为空"
			Return resultJson
		}
		
		// 先查询是否存在记录
		Set json={}
		Set json.className="User.HBUserLinkHosp"
		Set data=[]
		Set queryObj={}
		Set queryObj.UserDr=userID
		Set queryObj.HospDr=hospID
		Set queryObj.StopDate=""
		do data.%Push(queryObj)
		Set json.data=data
		Set rtn=##class(src.util.operatetable).Select(json)
		
		if rtn.errorCode=0{
			Set existID=""
			if rtn.result'="",rtn.result.rows'=""{
				Set existID=rtn.result.rows.%Get(0)
			}
		}
		
		// 使用 operatetable 进行新增或更新
		Set json={}
		Set json.className="User.HBUserLinkHosp"
		Set json.updateUserID=session.userID
		Set data=[]
		Set obj={}
		Set obj.UserDr=userID
		Set obj.HospDr=hospID
		Set obj.StartDate=$zd(+$h,3)
		Set obj.CreatedByDr=session.userID
		Set obj.CreatedDate=$zd(+$h,3)
		Set obj.CreatedTime=$zt($p($h,",",2))
		
		if existID'=""{
			// 记录已存在，更新为有效状态
			Set obj.ID=existID
			Set obj.StopDate=""
			do data.%Push(obj)
			Set json.data=data
			Set rtn=##class(src.util.operatetable).Update(json)
		}else{
			// 新增记录
			do data.%Push(obj)
			Set json.data=data
			Set rtn=##class(src.util.operatetable).Insert(json)
		}
		
		if rtn.errorCode'=0{
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage
		}
	}Catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="保存用户医院关联异常:w ##class("_$ClassName()_").SaveUserLinkHosp("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	
	Return resultJson
}

/// Creator:     Damon
/// CreatDate:   2026-04-14
/// Description: 删除用户医院关联记录
/// Table:     	 HB_UserLinkHosp   
/// Input:		{"params":[{"userID":"1","hospID":"11"}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.User.UserLogonLoc).DeleteUserLinkHosp({"params":[{"userID":"1","hospID":"11"}],"session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8"}]}).%ToJSON()
ClassMethod DeleteUserLinkHosp(postObj)
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage="成功"
	
	Try{
		Set userID=jsonObj.userID
		Set hospID=jsonObj.hospID
		
		if userID=""{
			Set resultJson.errorCode=1
			Set resultJson.errorMessage="用户ID不能为空"
			Return resultJson
		}
		if hospID=""{
			Set resultJson.errorCode=1
			Set resultJson.errorMessage="医院ID不能为空"
			Return resultJson
		}
		
		// 先查询记录ID
		Set json={}
		Set json.className="User.HBUserLinkHosp"
		Set data=[]
		Set queryObj={}
		Set queryObj.UserDr=userID
		Set queryObj.HospDr=hospID
		Set queryObj.StopDate=""
		do data.%Push(queryObj)
		Set json.data=data
		Set rtn=##class(src.util.operatetable).Select(json)
		
		if rtn.errorCode'=0{
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage="查询用户医院关联失败"
			Return resultJson
		}
		
		if rtn.result="",rtn.result.rows=""{
			// 没有找到记录，直接返回成功
			Return resultJson
		}
		
		// 获取记录ID进行删除
		Set existID=rtn.result.rows.%Get(0)
		
		// 使用 operatetable 进行软删除（更新StopDate）
		Set json={}
		Set json.className="User.HBUserLinkHosp"
		Set json.updateUserID=session.userID
		Set data=[]
		Set obj={}
		Set obj.ID=existID
		Set obj.StopDate=$zd(+$h-1,3)
		do data.%Push(obj)
		Set json.data=data
		Set rtn=##class(src.util.operatetable).Update(json)
		
		if rtn.errorCode'=0{
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage
		}
	}Catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="删除用户医院关联异常:w ##class("_$ClassName()_").DeleteUserLinkHosp("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	
	Return resultJson
}

}
