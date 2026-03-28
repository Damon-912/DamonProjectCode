/// 用户校验类
Class src.Encryption.HBUser Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 用户校验
/// Table:     	 HB_User      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Encryption.HBUser).IsValidUser("hcrm","PrMEBnVDvJSVFb7ruHLv3w==","^")
ClassMethod IsValidUser(userCode As %String, password As %String, expstr As %String) As %String
{
	new (userCode,password,expstr)

	Return:userCode="" "XYS1001^用户或密码错误"
	
	//TODO Encryption 未导入
	set encryptObj=##class(src.Encryption.Encryption).DeCodeEnc2Obj(password)
	Return:(encryptObj.errorCode'="0") encryptObj.errorCode_"^"_encryptObj.errorMessage
	set encrypt=encryptObj.passWord
	
	set userCode=$ZCVT(userCode,"U")
	set userID=$o(^HBUserI("Code",userCode,""))	; 工号
	set userLogonType="03"
	if userID="" {
		set userID=$o(^HBUserI("UserName",userCode,"")) ; 用户名
		set userLogonType="02"
	}
	if userID="" {
		set userID=$o(^HBUserI("Mobile",userCode,""))	; 手机号
		set userLogonType="01"
	}
	Return:userID="" "XYS1001^用户或密码错误"
	set currentPwd=$lg($g(^HBUserD(userID)),4)
	b ;23234234
	quit:currentPwd'=encrypt "XYS1001^用户或密码错误"
	set activeFlag=$lg($g(^HBUserD(userID)),6)
	set directorAuth=$lg($g(^HBUserD(userID)),16) ;直属领导审核状态
	
	
	set activestr=0
	if ((activeFlag="N") || (activeFlag="")){
		set activestr="XYS1003^用户未激活"
	}
	//set activestr=0
	; 直属领导审核通过了的，认为用户曾经已完成人事激活，需判断用户是否激活决定能否登录系统
	; 直属领导未审核的，认为用户还未完成人事激活，则无需判断激活，可登录修改注册页面进行修改
	/*if (directorAuth="Y"){	
		if (activeFlag'="Y"){
			set activestr="XYS1003^用户未激活"
		}
	}*/
	Return:$p(activestr,"^",1)'=0 activestr
	
	set dateFrom=$lg($g(^HBUserD(userID)),15)
	set dateTo=$lg($g(^HBUserD(userID)),16)
	quit:(dateFrom'="")&&(dateFrom>+$H) "XYS1004^未到用户生效日"
	quit:(dateTo'="")&&(dateTo<+$H) "XYS1005^用户有效期已过"

	quit "0^"_userID_"^"_userLogonType
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 获取用户信息
/// Table:     	 HB_User      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Encryption.HBUser).getUserInfo(1)
ClassMethod getUserInfo(userID As %String) As %String
{
	new (userID)
	set (userCode,userName,locID,locDesc,groupID,groupDesc)=""
	set (hospID,hospDesc,langID,langDesc,changeFlag)=""
	set (changeDesc,lastLoginDate,lastLoginTime,directorAuth,titleDesc,userYBCode,hospYBCode)=""
	
	
	quit:userID="" "XYS1001^用户或密码错误"
	quit:$d(^HBUserD(userID))=0 "XYS1001^用户或密码错误"
	
	
	set userCode=$lg($g(^HBUserD(userID)),2)	; 工号
	set userName=$lg($g(^HBUserD(userID)),3)	; 姓名
	set locID=""	; 默认科室
	set groupID=""	; 默认角色
	set hospID=""	; 默认医院
	set titleID=""	; 职称
	set titleDesc="" ;职称
	set firstLocID=""	; 
	set firstGroupID=""	; 
	set firstHospID=""	; 
	;用户有无效
	set active=$lg($g(^HBUserD(userID)),6)

	quit:(active="N") "XYS1001^该用户已无效"

	//默认登录医院角色(默认)
	Set resultArray=##Class(src.Logon.Logon).GetLogonGroupByUserId({"params":[{"userID":(userID)}]}).result.rows
	quit:resultArray.%Size()=0 "XYS1001^无登录医院"
	set hospID=resultArray.%Get(0).logonHospID
	set groupID=resultArray.%Get(0).logonGroupID
	set locID=resultArray.%Get(0).userLogonLocID
	
	for i=0:1:(resultArray.%Size()-1) {
		Set groupObj=resultArray.%Get(i)
		if groupObj.isDefault="Y"{
			set hospID=groupObj.logonHospID
			set groupID=groupObj.logonGroupID
			set locID=groupObj.userLogonLocID
		}
	}
	b 
	quit:hospID="" "XYS1001^无登录医院"
	quit:groupID="" "XYS1001^无登录角色"
	quit:locID="" "XYS1001^无登录科室"
	
	set (locDesc,groupDesc,hospDesc,langDesc,lastPwdUserName)=""
	set:locID'="" locDesc="HCRM" //$lg($g(^HBLocD(locID)),6)
	set:groupID'="" groupDesc=$lg($g(^CBGroupD(groupID)),3)
	set:hospID'="" hospDesc=$lg($g(^CBHospitalD(hospID)),3)

	set changeFlag="N",changeDesc=""
	//如果存在多个登录角色的话changeFlag这个标识为Y
	Set sqlString="SELECT count(1) total FROM SQLUser.HB_UserLogonLoc Where User_Dr=?"
	Set st = ##class(%SQL.Statement).%New(1)
	Set sc = st.%Prepare(sqlString)
	Set rs = st.%Execute(userID)
	Set total=0
	While rs.%Next(){
		Set total=rs.%Get("total")
	}
	Set:(total>1) changeFlag="Y",changeDesc="存在多个登录角色"
	
	set output="0^"_userID_"^"_userCode_"^"_userName_"^"_locID_"^"_locDesc_"^"_groupID_"^"_groupDesc
	set output=output_"^"_hospID_"^"_hospDesc_"^"_langID_"^"_langDesc_"^"_changeFlag
	set output=output_"^"_changeDesc_"^"_lastLoginDate_"^"_lastLoginTime_"^"_directorAuth_"^"_titleDesc_"^"_userYBCode_"^"_hospYBCode
	
	quit output
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 判断是否有其他登录科室
/// Table:     	 HB_User      
/// Input:		{"params":[{"":""}]} 
/// Return:  	Y 有，N 没有	 	 
/// Debug:   	w ##Class(src.Encryption.HBUser).HaveOtherLoc(134)
ClassMethod HaveOtherLoc(userID)
{
	new (userID)
	set rtn="N"
	quit:userID="" rtn
	Set number=0
	&sql(SELECT count(1) into :number FROM SQLUser.HB_UserLogonLoc Where User_Dr=:userID)
	if (number>1) set rtn="Y"
	quit rtn
}

/// Description：	查询用户登录科室信息
/// Creator:		LYP
/// CreatDate:		2022-06-30
/// Input:			userID:用户主键;locID:登录科室主键;currentLocFlag:;groupID:;hospID:;startDate:;stopDate:;
/// Output:			userLogonLocID:用户登录科室记录主键;logonHospID:登录医院主键;logonHospDesc:登录医院描述;logLocIsDefault:是否默认
/// 			logLocStDate:开始日期;logLocEndDate:截止日期;logonLocID:登录科室主键;logonLocDesc:登录科室描述;
/// 			logonGroupID:登录角色主键;logonGroupDesc:登录角色描述
///  w ##class(src.Encryption.HBUser).GetUserLogonLoc({"userID":"1","hospID":"1","groupID":"1"}).%ToJSON()
ClassMethod GetUserLogonLoc(logonLocParams, language = "")
{
	new (logonLocParams,language)
	set:language="" language="CN"
	;set userId=logonLocParams.userId
	set userId=logonLocParams.userID
	;set locIdTerm=logonLocParams.locIdTerm
	set locIdTerm=logonLocParams.locID
	set currentLocFlag=logonLocParams.currentLocFlag
	set groupIdTerm=logonLocParams.groupID
	set hospIdTerm=logonLocParams.hospID
	set startDateTerm=logonLocParams.startDate
	set stopDateTerm=logonLocParams.stopDate
	set power=logonLocParams.power
	set logonLocObj={}
	set logonLocAry=[]
	set logonLocSub=0
	set deptActive=""
	try{
		Set sqlString="select User_Dr,Hosp_Dr,Group_Dr,IsDefault,User_Dr->Descripts userDesc,Hosp_Dr->Descripts hospDesc,Group_Dr->Descripts groupDesc,Hosp_Dr->Code hospCode,Group_Dr->Code groupCode from HB_UserLogon where 1=1"
		Set:userId'="" sqlString=sqlString_" AND User_Dr ="_userId
		//w sqlString,!
		//Set:hospIdTerm'="" sqlString=sqlString_" AND Hosp_Dr ="_hospIdTerm
		//Set:groupIdTerm'="" sqlString=sqlString_" AND Descripts ="_groupIdTerm
		Set st = ##class(%SQL.Statement).%New(1)
		Set sc = st.%Prepare(sqlString)
	    Set rs = st.%Execute()
		While rs.%Next(){
			Set obj={}
			Set obj.logonUserID=rs.%Get("User_Dr")
			Set obj.logonUserDesc=rs.%Get("userDesc")
			//Set logonLocLogID=rs.%Get("User_Dr")
			Set obj.logonHospID=rs.%Get("Hosp_Dr")
			Set obj.logonHospDesc=rs.%Get("hospDesc")
			Set obj.logonHospCode=rs.%Get("hospCode")
			Set obj.logIsDefault=rs.%Get("IsDefault")
			//Set logLocStartDate: "2021-01-05"
			//Set logLocEndDate: ""
			//Set logonLocID: "101"
			//Set logonLocDesc: "信息中心"
			Set obj.logonGroupID=rs.%Get("Group_Dr")
			Set obj.logonGroupDesc=rs.%Get("groupDesc")
			//Set safeRank=rs.%Get("IsDefault")
			//Set path=rs.%Get("IsDefault")
			//Set defaultMenuType=rs.%Get("IsDefault")
			Do logonLocAry.%Push(obj)
		}
	}catch(e){
		set status=e.AsStatus()
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="查询用户登录科室信息程序异常:w ##class("_$ClassName()_").GetUserLogonLoc("_logonLocParams.%ToJSON()_")"
		//do ##class(src.Interface.Message).InsErrRecord("01040040",errorInfo,errorMessage)
		set logonLocAry=[]
		set deptActive=""
	}
	set logonLocObj.logonLocAry=logonLocAry
	set logonLocObj.deptActive=deptActive
	quit logonLocObj
}

/// w ##class(src.Encryption.HBUser).GetLoginAuth("1^1^2^7")
ClassMethod GetLoginAuth(expStr)
{
	new (expStr)
	set userRowid=$p(expStr,"^",1)
	set locDr=$p(expStr,"^",2)
	set groupDr=$p(expStr,"^",3)
	set hospDr=$p(expStr,"^",4)
	quit:userRowid="" "01040075@"
	quit:hospDr="" "01040079@"
	quit:locDr="" "01040046@"
	quit:groupDr="" "03020043@"
	
	set (locDesc,groupDesc,hospDesc,DefaultMenuType)=""
	set locDesc="HCRM平台" //$lg($g(^HBLocD(locDr)),6)
	set groupDesc=$lg($g(^CBGroupD(groupDr)),3)
	set defaultMenuType=$lg($g(^CBGroupD(groupDr)),10)
	set mainInterface=$lg($g(^CBGroupD(groupDr)),4)
	set hospCode=$lg($g(^CBHospitalD(hospDr)),2)
	set hospDesc=$lg($g(^CBHospitalD(hospDr)),3)
	if defaultMenuType="" set defaultMenuType=1
	
	quit 0_"^"_locDesc_"^"_groupDesc_"^"_hospDesc_"^"_defaultMenuType_"^"_hospCode_"^"_mainInterface
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 获取用户登录权限列表
/// Table:     	 HB_User      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:	w ##class(src.Encryption.HBUser).GetUserLogonLocByUserId({"params":[{"userID":"1","userCode":"xys","currentLocFlag":"Y","language":"CN"}],"session":[{"hospID":"1"}],"code":"01040043"}).%ToJSON()
ClassMethod GetUserLogonLocByUserId(postData)
{
	new (postData)
	set paramsObj=postData.params.%Get(0)
	set session={}
	set:postData.%IsDefined("session") session=postData.session.%Get(0)
	set hospID=session.hospID
	set power=paramsObj.power
	set resultObj={"errorCode":"0","errorMessage":"成功"}
	set errorCode=0
	set userID=paramsObj.userID
	b ;0
	;20200619 NZS 审核通过用户无userCode问题
	set:(userID="")&((paramsObj.%IsDefined("userCode")=1)&&(paramsObj.userCode="")) errorCode="01040004"
	if (paramsObj.userCode'=""){
		set userCode=paramsObj.userCode
		set userCode=$ZCVT(userCode,"U")
		set:userCode'="" userID=$o(^HBUserI("Code",userCode,0))	
	}
	b ;1
	;set:(paramsObj.userId="") errorCode="01040047"
	if (errorCode'=0) quit ##class(src.Interface.Message).SetMessage(errorCode,.resultObj)
	set logonLoc={}
	set:(paramsObj.groupID'="") resultObj.userSafeRank=$lg($g(^CBGroupD(paramsObj.groupID)),8)_""
	;set paramsObj.currentLocFlag="Y"
	set logonLoc.userID=userID
	set logonLoc.currentLocFlag=paramsObj.currentLocFlag
	set logonLoc.hospID=hospID
	set logonLoc.power=power
	b ;2
	set userLogonLoc=##class(src.Encryption.HBUser).GetUserLogonLoc(logonLoc,paramsObj.language)
	b ;3
	set resultObj.result=userLogonLoc
	quit resultObj
}

/// Description: 明文密码二级加密
/// CreateDate:	 2019-09-30
/// Creator:	Nzs
/// Debug：w ##class(src.Encryption.HBUser).FromatPassword("csk123")
ClassMethod FromatPassword(password)
{
	new (password)
	;明文加密
	set encryptObj=##class(src.Encryption.Encryption).EnCodeEnc2Obj(password)
	quit:(encryptObj.errorCode'="0") encryptObj.errorCode_"^"_ encryptObj.errorMessage
	set password=encryptObj.passWord
	;密码加密
	set encryptObj=##class(src.Encryption.Encryption).DeCodeEnc2Obj(password)
	quit:(encryptObj.errorCode'="0") encryptObj.errorCode_"^"_ encryptObj.errorMessage
	quit encryptObj.errorCode_"^"_ encryptObj.passWord
}

/// w ##class(src.Encryption.HBUser).UpdateUserPassword(a)
ClassMethod UpdateUserPassword(jsonObj)
{
	new (jsonObj)
	set resultObj={"errorCode":"-1","errorMessage":"密码更新失败"}
	set params=jsonObj.params.%Get(0)
	set session=jsonObj.session.%Get(0)
	set userOriginPassword=params.originPassword
	set userPassword=params.password
	set userConfirmPassword=params.confirmPassword
	set userID=params.userID
	set userCurPassword=$lg($g(^HBUserD(userID)),4)	
	b ;密码加密
	set encryptObj=##class(src.Encryption.Encryption).DeCodeEnc2Obj(userOriginPassword)
	b ;encryptObj1
	if (encryptObj.errorCode'="0"){		
		quit encryptObj
	}else{
		set userOriginPassword=encryptObj.passWord
	}
	b ;12
	if (userOriginPassword'=userCurPassword) {		
		quit {"errorCode":"-1","errorMessage":"原密码错误"}
	}
	if (userPassword'=userConfirmPassword) {
		quit {"errorCode":"-2","errorMessage":"新密码不一致"}
	}	
	set encryptObj=##class(src.Encryption.Encryption).DeCodeEnc2Obj(userPassword)
	b ;encryptObj
	set passWord=""
	if (encryptObj.errorCode'="0"){		
		quit encryptObj
	}else{
		set passWord=encryptObj.passWord
	}
	if passWord'=""{
		// 更新密码
		set dataObj={},dataArr=[]
		set dataObj.ID=userID
		set dataObj.Password=passWord
		do dataArr.%Push(dataObj)
		;b	;12121
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className="User.HBUser"			
		set operateObj.data=dataArr		
		set rtn=##class(src.util.operatetable).Update(.operateObj)
		set resultObj.errorCode=rtn.errorCode
		set resultObj.errorMessage=rtn.errorMessage
	}
	quit resultObj
}

}
