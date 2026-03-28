/// gjg
/// session处理
Class src.Rest.Session Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 登录时保存session
/// w ##class(src.Rest.Session).SaveSessionByLogon({"deviceID":"WEB:PC-D1","userID":"1","groupID":"1","hospID":"2","mac":"csmac","IP":"ceshiip"}).%ToJSON()
ClassMethod SaveSessionByLogon(sessionObj)
{
	new (sessionObj)
	//传入参数
	set deviceID=sessionObj.deviceID
	set IP=sessionObj.IP
	set mac=sessionObj.mac
	set groupID=sessionObj.groupID     ;必填
	set hospID=sessionObj.hospID       ;必填
	set userID=sessionObj.userID       ;必填
	set timeOut=sessionObj.timeOut
	set sessionStr=sessionObj.sessionStr  ;必填
	//验证参数
	quit:(groupID="") ##class(src.util.ResultSet).FailInfoByCode("01000001")
	quit:(hospID="") ##class(src.util.ResultSet).FailInfoByCode("01000002")
	quit:(userID="") ##class(src.util.ResultSet).FailInfoByCode("01000003")
	//保存
	set dataObj=##class(User.BSSession).%New()
	set dataObj.SessionStr=sessionStr
	set dataObj.DeviceID=deviceID
	set dataObj.IP=IP
	set dataObj.Mac=mac
	do dataObj.GroupDrSetObjectId(groupID)
	do dataObj.HospitalDrSetObjectId(hospID)
	set dataObj.LoginDate=+$h
	set dataObj.LoginTime=$p($h,",",2)
	do dataObj.LoginUserDrSetObjectId(userID)
	set dataObj.TimeOut=$case(timeOut'="","1":timeOut,:"30")           ;默认三十分钟，后期取配置
	set dataObj.CreatedDate=+$h
	set dataObj.CreatedTime=$p($h,",",2)
	do dataObj.CreateUserDrSetObjectId(userID)
	set dataObj.UpdateDate=+$h
	set dataObj.UpdateTime=$p($h,",",2)
	do dataObj.UpdateUserDrSetObjectId(userID)
	set dataObj.IsActive="Y"
	set tSC = dataObj.%Save() 
	if ($System.Status.IsError(tSC)) {
	   quit ##class(src.util.ResultSet).StatusFail(tSC)
	}
	set id=dataObj.%Id()
	do dataObj.%Close()
	quit ##class(src.util.ResultSet).Success(id)
}

/// sessionStr ,userID 用户
ClassMethod DestroySession(sessionStr, userID) As %Library.DynamicAbstractObject
{
	new (sessionStr,userID)
	//验证	
	quit:(userID="") ##class(src.util.ResultSet).FailInfoByCode("01000003")
	quit:(sessionStr="") ##class(src.util.ResultSet).FailInfoByCode("01000004")
	set sessionStr=$ZCVT(sessionStr,"U")
	set sessionID=$o(^BSSessionI("SessionStr",sessionStr,0))
	quit:(sessionID="") ##class(src.util.ResultSet).FailInfoByCode("01000004")
	set dataObj=##class(User.BSSession).%OpenId(sessionID)
	set dataObj.UpdateDate=+$h
	set dataObj.UpdateTime=$p($h,",",2)
	do dataObj.UpdateUserDrSetObjectId(userID)
	set dataObj.IsActive="N"
	set tSC = dataObj.%Save() 
	if ($System.Status.IsError(tSC)) {
	   quit ##class(src.util.ResultSet).StatusFail(tSC)
	}
	set id=dataObj.%Id()
	do dataObj.%Close()
	quit ##class(src.util.ResultSet).Success(id)
}

/// w ##class(src.Rest.Session).CheckOverTime()
ClassMethod CheckSession(sessionObj)
{
	new (sessionObj)
	//session传入参数
	set sessionStr=sessionObj.sessionStr
	set groupID=sessionObj.groupID     
	set hospID=sessionObj.hospID       
	set userID=sessionObj.userID       
	//验证参数
	quit:(userID="") ##class(src.util.ResultSet).FailInfoByCode("01000003")
	quit:(sessionStr="") ##class(src.util.ResultSet).FailInfoByCode("01000004")
	set sessionStr=$ZCVT(sessionStr,"U")
	set sessionID=$o(^BSSessionI("SessionStr",SessionStr,0))
	quit:(sessionID="") ##class(src.util.ResultSet).FailInfoByCode("01000004")
	//检查在线人数
	set checkObj=..CheckUserOnlineSession({"sessionStr":(sessionStr),"deviceID":(deviceID),"userID":(userID)})
	if (checkObj.errorCode'=0){
		quit checkObj
	}
	//获取存储的数据	
	set sessionObj=##class(User.BSSession).%OpenId(sessionID)
	set oldUserID=sessionObj.LoginUserDr.%Id()
	//和当前数据进行对比
	if (oldUserID'=userID){
		quit ##class(src.util.ResultSet).FailInfoByCode("03000001")
	}
	set timeout=sessionObj.TimeOut
	set lastUpdateDate=sessionObj.UpdateDate
	set lastUpdateTime=sessionObj.UpdateTime
	set isActive=sessionObj.IsActive
	set nowDate=+$h
	set nowTime=$p($h,",",2)
	//判断是否超时
	if (((nowDate-lastUpdateDate)*86400+nowTime)-lastUpdateTime)>(timeout*60) {
		set rtn=..DestroySession(sessionStr,userID)
		quit ##class(src.util.ResultSet).FailInfoByCode("03000002")
	}
	//判断是否激活(未超时，未激活就是被其他设备挤下线了)
	if (isActive="N"){
		quit ##class(src.util.ResultSet).FailInfoByCode("03000003")
	}
	quit ##class(src.util.ResultSet).Success()
}

ClassMethod CheckUserOnlineSession(sessionObj)
{
	new (sessionObj)
	//session传入参数
	set sessionStr=sessionObj.sessionStr
	set deviceID=sessionObj.deviceID
	set userID=sessionObj.userID       
	
	// 同一用户有效在线session数,超过的按照最晚更新时间置为失效
	// 走配置,是否根据类型类型，根据类型的最大在线数
	set singleOnline=30             ;同时在线总数
	set deviceTypeConfigFlag="Y"    ;是否走根据设备类型在线总数
	set deviceType=$ZCVT($p(deviceID,":",1),"U")
	if ("WEB^IPHONE^PAD"'[deviceType){
		//如果类型传入的有问题，默认为WEB类型
		set deviceType="WEB"
	}
	quit:(userID="") ##class(src.util.ResultSet).FailInfoByCode("01000003")
	set sql="select SessionStr,DeviceID from BS_Session where LoginUser_Dr = '"_userID_"' and IsActive ='Y' "
	if (deviceTypeConfigFlag="Y"){
		set sql=sql_" and DeviceID like '"_deviceType_"%'"
	}
	set sql=" order by UpdateDate,UpdateTime"
	set result=##class(src.util.SQLUtil).SqlForList(sql)
	if (result.errorCode'=0){
		quit result
	}
	set count=result.result.total
	set arr=result.result.rows
	//超过的
	if (count>=singleOnline){
		for i=0:1:(arr.%Size()-1-singleOnline){
			set obj=arr.%Get(i)
			set sessionStr=obj.sessionStr
			set rtn=..DestroySession(sessionStr,userID)
		}
	}	
	quit ##class(src.util.ResultSet).Success()
}

}
