Class src.Rest.Internal.Interface Extends (%RegisteredObject, %XML.Adaptor)
{

/// 明文入参
/// w ##class(src.Rest.Internal.Interface).postMutipleParams({"params":[{"fileName":"logo.png"}],"code":"01040214","session":[{"userID":"","locID":"","groupID":"","groupDesc":"","hospID":"","sessionID":"","hospCode":"","language":"","deviceID":"","hostName":"","ipv4":"","ipv6":"","mac":""}]})
ClassMethod postMutipleParams(postObj)
{
	set postCode=postObj.code
	set srcRestMapLogID=##class(User.BSSrcRestMapLog).InsetSrcRestMapLog(postCode,postObj)    ;接口日志
	// 判断接口号是否存在
	if (postCode=""){
		set tobj=##class(src.util.ResultSet).FailInfoByCode("04000001")
		write tobj.%ToJSON()
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
	}
	//获取接口号信息并判断是否存在
	set classObj=##class(src.Rest.FetchClass).GetClass(postCode)
	if (classObj.errorCode'=0){
		set tobj=##class(src.util.ResultSet).Fail(classObj.errorMessage,classObj.errorCode)
		write tobj.%ToJSON()
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
	}
	set mapInterfaceObj=classObj.result
	//验证session
	set sessionFlag=mapInterfaceObj.sessionFlag
	if (sessionFlag="Y"){
		set session=postObj.session.%Get(0)
		set tobj=##class(src.Rest.Session).CheckSession(session)
		if (tobj.errorCode'=0){
			write tobj.%ToJSON()
			set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
			quit $$$OK
		}
	}
	//验证类和方法
	set className=mapInterfaceObj.className
	set methodName=mapInterfaceObj.methodName
	// 类是否存在
	set existFlag=##class(%Library.ClassDefinition).%ExistsId(className)		; 类是否存在
	if existFlag=0 {
		set tobj=##class(src.util.ResultSet).FailInfoByCode("04000002","",className)
		write tobj.%ToJSON()
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
	}
	// 方法是否存在		
	set existFlag=##class(%Dictionary.MethodDefinition).%ExistsId((className_"||"_methodName))		; 方法是否存在
    if (existFlag=0){
		set tobj=##class(src.util.ResultSet).FailInfoByCode("04000003","",methodName)
		write tobj.%ToJSON()
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
    }
    //调用方法
	try{
		set tobj=$CLASSMETHOD(className,methodName,.postObj)
		write tobj.%ToJSON()
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"C",tobj.%ToJSON(),"",$l(tobj.%ToJSON()))
    }catch (e) {
		set tobj=##class(src.util.ResultSet).CatchFail(e)
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		write tobj.%ToJSON()
    }
	Quit $$$OK
}

/// 加密入参
/// w ##class(src.Rest.Internal.Interface).postMutipleParamsEncrypt("eYDjGDOX1QnXiEOu2gvN1tkBj9V6TJxuohHB2tAN9x4gTK6832daTh5pYCdY1FEvrGyRl7ExMQZtH1EMDxD+KPoWDoP0kT8cuPwm3/7CCKqWDU3/vroDO9Qa3CLBn5f0sn6KimWKZxr8kcKWPdolsrnpa/Z4ZUtzRNiDKtA2cygzIyq2vYw1c9tihcgRCml25hdg9Ze7HN9D77BjGhdd4XvyF2mQ28vMX0a7NbNavWpk5kiFWgvxnZW4Gl+j2nVMFHGLwBh52WoSSsOUuduoSpDSv/MKTAz3XspLa1PA7GqeGkELZKYDgr6an9BScc7pigrOoydvMoE/ZCDv8utZYC0sIoHgPH7LQn/XRekWXvTU2uLJAtKas9LTItkX/sGvLeNWT5tfSrJzJnJo594MssE+rgrsA/kKF4aJYN2C8oeUbeeX2CrK20LFINPY02Wt")
ClassMethod postMutipleParamsEncrypt(postObj)
{
	//解密入参
	set decryptStr=##class(src.util.Encryption).DecryptByAESBASE64(postObj)
	set postObj={}.%FromJSON(decryptStr)
	set postCode=postObj.code
	set srcRestMapLogID=##class(User.BSSrcRestMapLog).InsetSrcRestMapLog(postCode,postObj)    ;接口日志
	// 判断接口号是否存在
	if (postCode=""){
		set tobj=##class(src.util.ResultSet).FailInfoByCode("04000001")
		write ##class(src.util.Encryption).EncrypByAESBASE64(tobj.%ToJSON(),"Y")
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
	}
	//获取接口号信息并判断是否存在
	set classObj=##class(src.Rest.FetchClass).GetClass(postCode)
	if (classObj.errorCode'=0){
		set tobj=##class(src.util.ResultSet).Fail(classObj.errorMessage,classObj.errorCode)
		write ##class(src.util.Encryption).EncrypByAESBASE64(tobj.%ToJSON(),"Y")
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
	}
	set mapInterfaceObj=classObj.result
	//验证session
	set sessionFlag=mapInterfaceObj.sessionFlag
	if (sessionFlag="Y"){
		set session=postObj.session.%Get(0)
		set tobj=##class(src.Rest.Session).CheckSession(session)
		if (tobj.errorCode'=0){
			write ##class(src.util.Encryption).EncrypByAESBASE64(tobj.%ToJSON(),"Y")
			set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
			quit $$$OK
		}
	}
	//验证类和方法
	set className=mapInterfaceObj.className
	set methodName=mapInterfaceObj.methodName
	// 类是否存在
	set existFlag=##class(%Library.ClassDefinition).%ExistsId(className)		; 类是否存在
	if existFlag=0 {
		set tobj=##class(src.util.ResultSet).FailInfoByCode("04000002","",className)
		write ##class(src.util.Encryption).EncrypByAESBASE64(tobj.%ToJSON(),"Y")
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
	}
	// 方法是否存在		
	set existFlag=##class(%Dictionary.MethodDefinition).%ExistsId((className_"||"_methodName))		; 方法是否存在
    if (existFlag=0){
		set tobj=##class(src.util.ResultSet).FailInfoByCode("04000003","",methodName)
		write ##class(src.util.Encryption).EncrypByAESBASE64(tobj.%ToJSON(),"Y")
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
    }
    //调用方法
	try{
		set tobj=$CLASSMETHOD(className,methodName,.postObj)
		b ;tobj
		write ##class(src.util.Encryption).EncrypByAESBASE64(tobj.%ToJSON(),"Y")
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"C",tobj.%ToJSON(),"",$l(tobj.%ToJSON()))
    }catch (e) {
		set tobj=##class(src.util.ResultSet).CatchFail(e)
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		write ##class(src.util.Encryption).EncrypByAESBASE64(tobj.%ToJSON(),"Y")
    }
	Quit $$$OK
}

/// 签名验证
/// w ##class(src.Rest.Internal.Interface).postMutipleParamsEncryp({"code":"1000"})
ClassMethod postMutipleParamsSign(postObj)
{
	set postCode=postObj.code
	set srcRestMapLogID=##class(User.BSSrcRestMapLog).InsetSrcRestMapLog(postCode,postObj)    ;接口日志
	// 判断接口号是否存在
	if (postCode=""){
		set tobj=##class(src.util.ResultSet).FailInfoByCode("04000001")
		write tobj.%ToJSON()
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
	}
	//获取接口号信息并判断是否存在
	set classObj=##class(src.Rest.FetchClass).GetClass(postCode)
	if (classObj.errorCode'=0){
		set tobj=##class(src.util.ResultSet).Fail(classObj.errorMessage,classObj.errorCode)
		write tobj.%ToJSON()
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
	}
	set mapInterfaceObj=classObj.result
	//验证签名
	set signFlag="Y"    ;之后可能走配置
	if (signFlag="Y"){
		set outSign=postObj.sign
		do postObj.%Remove("sign")
		set inSign=##class(src.util.Encryption).CheckSign(postObj)
		if ((outSign="")||(inSign'=outSign)){
			set tobj=##class(src.util.ResultSet).FailInfoByCode("04000006")
			write tobj.%ToJSON()
			set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
			quit $$$OK
		}
	}
	//验证类和方法
	set className=mapInterfaceObj.className
	set methodName=mapInterfaceObj.methodName
	// 类是否存在
	set existFlag=##class(%Library.ClassDefinition).%ExistsId(className)		; 类是否存在
	if existFlag=0 {
		set tobj=##class(src.util.ResultSet).FailInfoByCode("04000002","",className)
		write tobj.%ToJSON()
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
	}
	// 方法是否存在		
	set existFlag=##class(%Dictionary.MethodDefinition).%ExistsId((className_"||"_methodName))		; 方法是否存在
    if (existFlag=0){
		set tobj=##class(src.util.ResultSet).FailInfoByCode("04000003","",methodName)
		write tobj.%ToJSON()
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		quit $$$OK
    }
    //调用方法
	try{
		set tobj=$CLASSMETHOD(className,methodName,.postObj)
		write tobj.%ToJSON()
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"C",tobj.%ToJSON(),"",$l(tobj.%ToJSON()))
    }catch (e) {
		set tobj=##class(src.util.ResultSet).CatchFail(e)
		set srcRestMapLogID=##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(srcRestMapLogID,"E",tobj.%ToJSON())
		write tobj.%ToJSON()
    }
	Quit $$$OK
}

}
