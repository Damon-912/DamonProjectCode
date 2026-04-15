Class src.User.User Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 查询用户分页
/// Table:     	 CB_User      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.User.User).FindUserDetail({"params":[{"hospID":"8","hospDesc":"成都普瑞眼科医院"}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"","sortOrder":""}],"code":"01030101","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"2qxKMKf160","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod FindUserDetail(postObj)
{
	new (postObj)
	Set params=postObj.params.%Get(0)
	Set pagination=postObj.pagination.%Get(0)
	Set code=params.code
	Set hospID=params.hospID
	Set groupID=params.groupID
	Set active=params.status
	Set desc=params.descripts
	if postObj.session'=""
	{
		Set session=postObj.session.%Get(0)
		Set:groupID="" groupID=session.groupID
	}
	if (pagination'=""){
		set pageSize=pagination.pageSize
		set currentPage=pagination.currentPage
		if ((pageSize<=0)||(pageSize="")||(currentPage<=0)||(currentPage="")){
			quit ##class(src.util.ResultSet).FailInfoByCode("03000004")
		}
		set start=((currentPage-1)*pageSize)+1
		set end=currentPage*pageSize
	}
	set hospInfo=""
	// 先从HB_UserLinkHosp获取有权限的用户ID列表
	if hospID=""
	{
		if postObj.session'=""
		{
			Set hospID=session.hospID
			
		}
		if hospID'=""
		{
			set hospStr=##class(src.CBTable.CBTableData).GetHosptialAuth(groupID,hospID,"User.CBHospital")
			
			if hospStr="" set hospStr=hospID
			if hospStr'=""{
				for i=1:1:$l(hospStr,"^"){
					set hospId=$p(hospStr,"^",i)
					continue:hospId=""
					if hospInfo=""
					{
						set hospInfo=hospId
					}else{
						set hospInfo=hospInfo_","_hospId
					}
				}
			}
		}
	}else{
		set hospInfo=hospID
	}
	if hospInfo=""
	{
		quit {"errorCode":0,"errorMessage":"成功","result":{"total":0,"rows":[]}}
	}
	
	// 构建用户ID过滤条件 - 只查询在授权医院中有关联的用户
	Set userFilterSql="SELECT DISTINCT User_Dr FROM HB_UserLinkHosp WHERE Hosp_Dr in ("_hospInfo_")"
	Set:code'="" userFilterSql=userFilterSql_" AND User_Dr->Code like '%"_code_"%'"
	Set:(active'="")&(active'="all") userFilterSql=userFilterSql_" AND User_Dr->Active = '"_active_"'"
	Set:desc'="" userFilterSql=userFilterSql_" AND User_Dr->Descripts like '%"_desc_"%'"
	
	// 主查询：从HB_User查询用户基本信息（去重）
	Set sqlString="SELECT ID as userDr, Code as userCode, Descripts as userName, Sex_Dr as sexID, Sex_Dr->Descripts as sexDesc, "_
				  "Mobile, CredType_Dr as credTypeID, CredType_Dr->Descripts as credTypeDesc, CredNo, "_
				  "Image, Introduce, CreatedBy_Dr, CreatedBy_Dr->Descripts as creatUserDesc, "_
				  "CreatedDate, CreatedTime, StartDate, StopDate, Active as statusFlag, "_
				  "Nickname, Email as mail, WorkMobile, BirthDate "_
				  "FROM HB_User WHERE ID IN ("_userFilterSql_")"
	
	set st = ##class(%SQL.Statement).%New(1)
	set status = st.%Prepare(sqlString)
	if status'=1 {
		quit ##class(src.util.ResultSet).StatusFail(status)
	}
	set rset = st.%Execute()
	set rsmeta=rset.%GetMetadata()
	set count=0,rows=[]
	//获取列名，并对字段进行修改
	set colArr=[""],index=1
	while rsmeta.columns.GetAt(index) {
		set colName=rsmeta.columns.GetAt(index).colName
		//ID 字段处理为表名加ID
		if (colName'="ID"){
			if ($find(colName,"_")'=0){
				set colName=$p(colName,"_",1)_"ID"
			}
			set colName=$zcvt($e(colName,1),"L")_$e(colName,2,*)
		}else{
			set tabNameID=rsmeta.columns.GetAt(index).tableName
			set colName=$p(tabNameID,"_",2)_"ID"
			set colName=$zcvt($e(colName,1),"L")_$e(colName,2,*)
		}
		set index=index+1 
		do colArr.%Push(colName)
	}
	while rset.%Next(){
		set dataObj={}
		for i=1:1:colArr.%Size()-1{
			set colName=colArr.%Get(i)
			set colData=rset.%GetData(i)
			do dataObj.%Set(colName,colData)
		}
		set count=count+1
		if (pagination'=""){
			continue:count<start
			continue:count>end
		}
		set userDr=dataObj.userDr
		set userExtDr=""
		for
		{
			set userExtDr=$o(^HBUserExtI("User",userDr,userExtDr))
			quit:userExtDr=""
			set userExtobj=##class(User.HBUserExt).%OpenId(userExtDr)
			set ExtCode=userExtobj.Code
			set ExtCode=$zcvt($e(ExtCode,1),"L")_$e(ExtCode,2,*)
			set ExtValue=userExtobj.ExtValue
			do dataObj.%Set(ExtCode,ExtValue)
		}
		do rows.%Push(dataObj)
	}
	Return {"errorCode":0,"errorMessage":"成功","result":{"total":(count),"rows":(rows)}}
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 新增用户
/// Table:     	 CB_User     
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug: w ##Class(src.User.User).AddUserConf({"params":[{"UpdateUserDr":"158","userID":"158","hospID":"11","credTypeID":"1","credNo":"440982198805214076","sexID":"2","birthDate":"1988-05-21","mobile":15975547794,"workMobile":15975547794,"userName":"黄亚广","startDate":"2025-12-24","statusFlag":"Y","hospDesc":"昆明普瑞眼科医院","credTypeDesc":"身份证","sexDesc":"男"}],"code":"01030102","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"zg1spNoB1u","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod AddUserConf(postObj)
{
	//set ^TMP("AddUserConf",0)=postObj.%ToJSON()
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	set userDr=jsonObj.userDr
	Set userID=session.userID
	set mobile=+jsonObj.mobile
	if $l(mobile)'=11
	{
		set resultJson={}
		set resultJson.errorCode="-1"
		set resultJson.errorMessage="私人电话不正确"
		quit resultJson
	}
	set Code=""
	if userDr=""
	{
		set tmpuserID=$o(^HBUserI("Mobile",mobile,""))
		if tmpuserID'=""
		{
			set resultJson={}
			set resultJson.errorCode="-1"
			set resultJson.errorMessage="此电话"_mobile_"已注册用户"
			quit resultJson
		}
		// 检查证件号是否已存在
		set credNo=jsonObj.credNo
		if credNo'=""
		{
			set tmpuserIDByCred=$o(^HBUserI("CredNo",credNo,""))
			if tmpuserIDByCred'=""
			{
				set resultJson={}
				set resultJson.errorCode="-1"
				set resultJson.errorMessage="此证件号"_credNo_"已注册用户"
				quit resultJson
			}
		}
		// 生成6位数字用户编码
		set Code=##class(src.User.User).GenUserCode()
		set tmpUserDr=$o(^HBUserI("Code",Code,""))
		while tmpUserDr'=""
		{
			set Code=##class(src.User.User).GenUserCode()
			set tmpUserDr=$o(^HBUserI("Code",Code,""))
		}
	}
	set password=""
	if userDr=""
	{
		;//新添加用户默认密码
		set passwordname="123456"
		set passwordinfo=##class(src.Encryption.HBUser).FromatPassword(passwordname)
		if (+passwordinfo'="0")
		{
			set resultJson={}
			set resultJson.errorCode=+passwordinfo
			set resultJson.errorMessage=$p(passwordinfo,"^",2)
			quit resultJson
		}
		else
		{
			set password=$p(passwordinfo,"^",2)
		}		
	}
	
	Try
	{		
		TSTART
		set userID=jsonObj.userID
		Set json={}
		Set json.className="User.HBUser"
		set json.updateUserID=session.userID //userID
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj.ID=userDr
		Set newJsonObj.CreatedDate=$zd($h,3)
		Set newJsonObj.CreatedTime=$zt($p($h,",",2))
		Set:userDr="" newJsonObj.Code=Code
		Set newJsonObj.Nickname=jsonObj.nickname      ;昵称
		Set newJsonObj.Email=jsonObj.mail         ;电子邮箱
		Set newJsonObj.WorkMobile=jsonObj.workMobile    ;工作手机

		Set newJsonObj.Introduce=jsonObj.introduce
		Set newJsonObj.Image=jsonObj.image
		Set newJsonObj.Descripts=jsonObj.userName
		Set:userDr="" newJsonObj.Password=password
		
		Set newJsonObj.SexDr=jsonObj.sexID
		Set newJsonObj.Mobile=jsonObj.mobile
		Set newJsonObj.CredNo=jsonObj.credNo
		Set newJsonObj.CredTypeDr=jsonObj.credTypeID
		Set newJsonObj.Active=jsonObj.statusFlag
		Set newJsonObj.CreatedByDr=session.userID
		Set:jsonObj.birthDate newJsonObj.BirthDate=$zdh(jsonObj.birthDate,3)
		Set newJsonObj.StartDate=$zdh(jsonObj.startDate,3)
		Set:jsonObj.stopDate newJsonObj.StopDate=$zdh(jsonObj.stopDate,3)
		
		Set:jsonObj.createdDate'="" newJsonObj.CreatedDate=jsonObj.createdDate
		Set:jsonObj.createdTime'="" newJsonObj.CreatedTime=jsonObj.createdTime

		do data.%Push(newJsonObj)
		Set json.data=data

		if userDr=""
		{
			Set rtn=##class(src.util.operatetable).Insert(json)
		}
		else
		{
			Set rtn=##class(src.util.operatetable).Update(json)
		}
		
		if rtn.errorCode'=0
		{
			TROLLBACK
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage
			Return resultJson
		}
		Set saveUserID=rtn.rowIDArr.%Get(0)
		
		set extData=[]
		if jsonObj.hospID '=""
		{
			//所属医院
			set hospitalID=jsonObj.hospID
			set LinkHospDr=$o(^HBUserLinkHospI("HospUser",hospitalID,saveUserID,""))
			if LinkHospDr=""
			{
				Set json={}
				Set json.className="User.HBUserLinkHosp"
				set json.updateUserID=session.userID //userID
				Set data=[]
				Set newJsonObj={}
				Set newJsonObj.UserDr=saveUserID
				Set newJsonObj.HospDr=hospitalID
				Set newJsonObj.StartDate=+$h
				Set newJsonObj.CreatedByDr=session.userID
				Set newJsonObj.CreatedDate=+$h
				Set newJsonObj.CreatedTime=$p($h,",",2)
				do data.%Push(newJsonObj)
				Set json.data=data
				Set rtn=##class(src.util.operatetable).Insert(json)
				if rtn.errorCode'=0
				{
					TROLLBACK
					Set resultJson.errorCode=rtn.errorCode
					Set resultJson.errorMessage=rtn.errorMessage
					Return resultJson
				}
			}
		}
		if jsonObj.wxOPENID'=""
		{
			set item={}
			set item.fieldCode="wxOPENID"  //微信openid
			set item.fieldValue=jsonObj.wxOPENID
			do extData.%Push(item)
		}
		if jsonObj.hrUSERID'=""
		{
			set item={}
			set item.fieldCode="hrUSERID"  //hr系统中的用户ID
			set item.fieldValue=jsonObj.hrUSERID
			do extData.%Push(item)
		}
		if jsonObj.approveID'=""
		{
			set item={}
			set item.fieldCode="approveID" //审批流程表ID
			set item.fieldValue=jsonObj.approveID
			do extData.%Push(item)
		}
		b 
		if extData.%Size()>0
		{
			set paraObj={}
			set paraObj.userID=saveUserID
			set paraObj.updateUserID=session.userID
			set paraObj.extData=extData
			set retObj=..SaveUserExtData(paraObj)
			set resultJson={}
			set resultJson.errorCode=retObj.errorCode
			set resultJson.errorMessage=retObj.errorMessage
			if resultJson.errorCode'=0
			{
				TROLLBACK
				quit
			}
		}
		TCOMMIT
		Return rtn
	}Catch(e){
		TROLLBACK
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    b
	    set errorInfo="新增用户出现异常:w ##class("_$ClassName()_").AddUserConf("")"
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
/// Debug:   w ##Class(src.User.User).GetUserDetail({"params":[{"userID":"2"}]}).%ToJSON()
ClassMethod GetUserDetail(postObj) As %Library.DynamicAbstractObject
{
	new (postObj)
	Set outputobj={}
	set outputobj.errorCode="0"
	set outputobj.errorMessage="成功"
	
	Set params=postObj.params.%Get(0)
	Set userID=params.userID
	Set sqlString="select ID, Code, Descripts, Password, Sex_Dr,Sex_Dr->Descripts sexDesc, Active, Hospital_Dr,Hospital_Dr->Descripts hospDesc, "_
				  " Mobile, CredType_Dr,CredType_Dr->Descripts credTypeDesc, CredNo, Image, Introduce, CreatedBy_Dr,CreatedBy_Dr->descripts creatUserDesc, CreatedDate, CreatedTime "_
				  " from HB_User where ID="_userID
				  //w sqlString,!
	Set st = ##class(%SQL.Statement).%New(1)
	Set sc = st.%Prepare(sqlString)
	Set rs = st.%Execute()
	Set obj={}
	While rs.%Next(){
		Set obj.userLogonLocID=rs.%Get("ID")
		Set obj.code=rs.%Get("Code")
		Set obj.password=rs.%Get("Password")
		Set obj.descripts=rs.%Get("Descripts")
		Set obj.sexID=rs.%Get("Sex_Dr")
		Set obj.sexDesc=rs.%Get("sexDesc")
		Set obj.active=rs.%Get("Active")
		Set obj.hospitalID=rs.%Get("Hospital_Dr")
		Set obj.hospDesc=rs.%Get("hospDesc")
		Set obj.mobile=rs.%Get("Mobile")
		
		Set obj.credTypeID=rs.%Get("CredType_Dr")
		Set obj.credTypeDesc=rs.%Get("credTypeDesc")
		Set obj.credNo=rs.%Get("CredNo")
		Set obj.image=rs.%Get("Image")
		Set obj.introduce=rs.%Get("Introduce")
		Set obj.createdByID=rs.%Get("CreatedBy_Dr")
		Set obj.creatUserDesc=rs.%Get("creatUserDesc")
		Set obj.createdDate=rs.%Get("CreatedDate")
		Set obj.createdTime=rs.%Get("CreatedTime")
		
		Set obj.userLogonLoc=[]
		Set logonObj=##Class(src.User.UserLogonLoc).GetLogonGroupByUserId(postObj).result.rows
		Set obj.userLogonLoc=logonObj
	}
	Set outputobj.result={}
	Set outputobj.result=obj
	Return outputobj
}

/// 保存人员扩展数据
/// 
ClassMethod SaveUserExtData(paraObj)
{
	new (paraObj)
	set ^TMP("SaveUserExtData")=paraObj.%ToJSON()
	set tranLevel=0
	try{
		set userID=paraObj.userID
		if userID=""{
			set resultObj={}
			set resultObj.errorCode="-1"	
			set resultObj.errorMessage="请选择记录"
			Quit 
		}
		set updateUserID=paraObj.updateUserID
		set extData=paraObj.extData
		if extData.%Size()=0{
			set resultObj={}
			set resultObj.errorCode="0"	
			set resultObj.errorMessage=""
			Quit 	
		}
		TStart
		set tranLevel=1
		set errorCode="0"
		set errorMessage=""
		for i=0:1:extData.%Size()-1{
			set itemObj=extData.%Get(i)
			set fieldCode=itemObj.fieldCode
			set fieldValue=itemObj.fieldValue
			set fieldID=""
			&sql(select top 1 ID,Descripts into :fieldID,:fieldDesc from SQLUSER.CB_UserFieldConfig where Code=:fieldCode )
			if SQLCODE'=0 set fieldID=""
			if fieldID=""{
				set errorCode="-1"
				set errorMessage=fieldCode_"不是 CB_UserFieldConfig 字段"
				Quit 
			}
			set userExtID="",extCreateDate="",extCreateTime="",extCreateUserDr=""
			&sql(select ID,CreateDate,CreateTime,CreateUser_Dr into :userExtID,:extCreateDate,:extCreateTime,:extCreateUserDr from SQLUSER.HB_UserExt where User_Dr=:userID and UserField_Dr=:fieldID)
			if SQLCODE'=0 set userExtID=""
			set extObj={}
			set extObj.ID=userExtID
			set extObj.UserDr=userID
			set extObj.UserFieldDr=fieldID
			set extObj.Code=fieldCode
			set extObj.Descripts=fieldDesc
			set extObj.ExtValue=fieldValue
			if userExtID=""{
				set extObj.CreateDate=$zd(+$h,3)
				set extObj.CreateTime=$zt($p($h,",",2))
				set extObj.CreateUserDr=updateUserID
			}Else{ //补充之前未赋值数据
				Set extObj.CreateDate = extCreateDate
				Set extObj.CreateTime = extCreateTime
				Set extObj.CreateUserDr = updateUserID
				Set:(extCreateDate=$C(0))||(extCreateDate="") extObj.CreateDate = $zd(+$h,3)
				Set:(extCreateTime=$C(0))||(extCreateTime="") extObj.CreateTime = $zt($p($h,",",2))
				Set:(extCreateUserDr=$C(0))||(extCreateUserDr="") extObj.CreateUserDr = 1
			}
			set data=[]
			do data.%Push(extObj)
			set dataObj={}
			set dataObj.className="User.HBUserExt"
			set dataObj.updateUserID=updateUserID
			set dataObj.data=data
			set dataObj.logFlag=1
			if userExtID=""{
				set ret=##class(src.util.operatetable).Insert(.dataObj)
			}else{
				set ret=##class(src.util.operatetable).Update(.dataObj)	
			}
			set errorCode=ret.errorCode
			set errorMessage=ret.errorMessage
			if errorCode'=0
			{
				set resultObj={}
				set resultObj.errorCode=errorCode
				set resultObj.errorMessage=errorMessage
				quit 
			}
			
		}
		if errorCode'="0"{
			set resultObj={}
			set resultObj.errorCode=errorCode
			set resultObj.errorMessage=errorMessage
			Quit	
		}
		TCommit 
		set tranLevel=0
		set resultObj={}
		set resultObj.errorCode="0"
		set resultObj.errorMessage=""
	}catch(e){
		if tranLevel=1 TRollBack 1
		set status=e.AsStatus()
		set resultObj={}
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
    	B ;BBB
	    set errorInfo="保存就诊扩展数据:w ##class("_$ClassName()_").SaveAdmExtData("_paraObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")
	}
	if resultObj.errorCode'=0{
		if tranLevel=1
		{
			TRollBack 1
		}	
	}
	Quit resultObj
}

/// Creator:     CodeBuddy
/// CreatDate:   2026-04-14
/// Description: 生成6位数字用户编码
/// Return:      6位数字字符串
/// Debug:       w ##class(src.User.User).GenUserCode()
ClassMethod GenUserCode() As %String
{
	new
	// 生成100000-999999之间的随机数
	set random=$Random(900000)+100000
	quit random
}

}
