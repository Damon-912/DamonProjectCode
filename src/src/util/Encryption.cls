/// gjg
/// 2022-7-4
/// 加密工具类
Class src.util.Encryption Extends (%RegisteredObject, %XML.Adaptor, %JSON.Adaptor) [ Not ProcedureBlock ]
{

Parameter ENCKEY = 1234567812345678;

Parameter ENCIV = 1234567812345678;

/// 根据配置获取key值
ClassMethod GetKeyByConfig()
{
	set ENCKEY="1234567812345678"        ;后面走配置
	quit ENCKEY
}

/// 根据配置获取iv值
ClassMethod GetIvByConfig()
{
	set ENCIV="1234567812345678"         ;后面走配置
	quit ENCIV
}

/// 字符串加密 AES加密+base加密双重加密串
/// (入参必须是字符串类型)    异常返回空    flag :  如果字符串有汉字或者大于等于两个字节的字符，就必须使用flag="Y"
/// w ##class(src.util.Encryption).EncrypByAESBASE64("发动机fdsafdsadsffdsafdsafdsafdsefesdafdsafdsafeaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","Y")
ClassMethod EncrypByAESBASE64(str As %String, flag = "")
{
	new (str,flag)
	quit:str="" ""
	try{
		set ENCKEY=..GetKeyByConfig()
		set ENCIV=..GetIvByConfig()
		if (flag="Y"){
			set str=$zconvert($zconvert(str,"O","UTF8"),"O","URL")
		}
		set aesStr=##class(%SYSTEM.Encryption).AESCBCEncrypt(str,ENCKEY,ENCIV)	; AES加密
		set baseStr=##class(%SYSTEM.Encryption).Base64Encode(aesStr,1)	; base64 加密
	}catch(e){
		set baseStr=""
	}
	quit baseStr
}

/// 字符串解密 AES加密+base加密双重加密串
/// (入参必须是字符串类型) 异常返回空      flag  配合加密时有汉子转为url编码时使用,如果加密没使用url编码则不处理
/// w ##class(src.util.Encryption).DecryptByAESBASE64("eYDjGDOX1QnXiEOu2gvN1tkBj9V6TJxuohHB2tAN9x4gTK6832daTh5pYCdY1FEvrGyRl7ExMQZtH1EMDxD+KPoWDoP0kT8cuPwm3/7CCKqWDU3/vroDO9Qa3CLBn5f0sn6KimWKZxr8kcKWPdolsrnpa/Z4ZUtzRNiDKtA2cygzIyq2vYw1c9tihcgRCml25hdg9Ze7HN9D77BjGhdd4XvyF2mQ28vMX0a7NbNavWpk5kiFWgvxnZW4Gl+j2nVMFHGLwBh52WoSSsOUuduoSpDSv/MKTAz3XspLa1PA7GqeGkELZKYDgr6an9BScc7pigrOoydvMoE/ZCDv8utZYC0sIoHgPH7LQn/XRekWXvTU2uLJAtKas9LTItkX/sGvLeNWT5tfSrJzJnJo594MssE+rgrsA/kKF4aJYN2C8oeUbeeX2CrK20LFINPY02Wt")
ClassMethod DecryptByAESBASE64(baseStr As %String, flag = "")
{
	new (baseStr,flag)
	quit:baseStr="" ""
	try{
		set ENCKEY=..GetKeyByConfig()
		set ENCIV=..GetIvByConfig()
		set aesStr=##class(%SYSTEM.Encryption).Base64Decode(baseStr)	; base64 解密
		set str=##class(%SYSTEM.Encryption).AESCBCDecrypt(aesStr,ENCKEY,ENCIV)	; AES解密
		if (flag="Y"){
			set str=$zconvert($zconvert(str,"I","URL"),"I","UTF8")
		}else{
			set str=$zconvert(str,"I","UTF8")
		}
	}catch(e){
		set str=""
	}
	quit str
}

/// md5hash加密     
/// (入参必须是字符串类型)    异常返回空
/// w ##class(src.util.Encryption).EncrypByMD5hash({"params":[],"code":"01040013","session":[{"userID":"1","locID":"1","groupID":"3","hospID":"25","sessionID":"aHsXSFPmMl","hospCode":"H03","language":"CN","hostName":"","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]})
ClassMethod EncrypByMD5hash(str As %String)
{
	new (str)
	quit:str="" ""
	try{
		set md5Str=##class(%SYSTEM.Encryption).MD5Hash(str)
	}catch(e){
		set md5Str=""
	}
	quit md5Str
}

/// 签名效验（防止入参被恶意篡改）       
/// (入参必须是字符串类型)    异常返回空
/// w ##class(src.util.Encryption).CheckSign({"params":[],"code":"01040013","session":[{"userID":"1","locID":"1","groupID":"3","hospID":"25","sessionID":"aHsXSFPmMl","hospCode":"H03","language":"CN","hostName":"","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]})
ClassMethod CheckSign(str As %String, appID = "")
{
	new (str,app)
	quit:str="" ""
	quit:appID="" ""
	set secretKey="1234567812345678"      ;后面取第三方表维护的秘钥，根据唯一的第三方码
	set str=str_secretKey
	set md5Str=..EncrypByMD5hash(str)
	quit md5Str
}

/// w ##class(src.util.Encryption).test({"params":[],"code":"01040013","session":[{"userID":"1","locID":"1","groupID":"3","hospID":"25","sessionID":"aHsXSFPmMl","hospCode":"H03","language":"CN","hostName":"","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]})
ClassMethod test(str As %String)
{
	new (str)
	set str=1234567812345678
	set baseStr=##class(%SYSTEM.Encryption).EncrypByMD5hash(str)	; base64 加密
	quit baseStr
}

}
