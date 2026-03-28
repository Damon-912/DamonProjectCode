///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 内部加密类<br>
Class src.Encryption.Encryption Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

Parameter ENCKEY = 1234567891234567;

Parameter ENCIV = 1234567891234567;

ClassMethod ENCKEY()
{
	set ENCKEY = "1234567812345678"
	quit ENCKEY
}

ClassMethod ENCIV()
{
	set ENCIV = "1234567812345678"
	quit ENCIV
}

///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 密码加密(长度不超过12位)<br>
///       Input: 密码(长度不超过12位)<br>
///      Output: 加密串(长度不超过12位)<br>
ClassMethod Encrypt(EncStr As %Library.String) As %Library.String
{
	new (EncStr)
	set constant=23,output=""
	for step=1:1:$l(EncStr) set char=$e(EncStr,step) do
	.if char="T" set char=$c(2)
	.if char="a" set char=$c(3)
	.if char="N" set char=$c(4)
	.if char="g" set char=$c(5)
	.set num=$a(char)
	.set num=(num-step+constant)#255
	.if num>127 set num=(num+128)#255
	.if num<32 set num=(num+40)#255
	.if $c(num)="^" set num=num+1
	.set $e(output,step)=$c(num#255)

	set len=$l(output)
	for step=(len+1):1:12 do
	.set char=$e(output,(step-len))
	.set num=$a(char)
	.set num=(num*3*constant*(constant-4))#255
	.if num>127 set num=(num+128)#255
	.if num<32 set num=(num+40)#255
	.if $c(num)="^" set num=num+1
	.set $e(output,step)=$c(num#255)

	q output
}

///    Author: TT<br>
/// CreatDate: 2018-12-28<br>
///     Input: 加密串(长度不超过12位),授权码<br>
///    Output: 密码明文(长度不超过12位)<br>
ClassMethod Decrypt(DecStr As %Library.String, AuthCode As %Library.String) As %Library.String
{
	new (DecStr,AuthCode)
	quit:AuthCode'="XYSxys" "授权码不正确"
	set ok="",pwd="",isok=""
	set usrpwd=DecStr
	set leng=$l(usrpwd)
	quit:(leng>12) "加密串超长"
	for start=1:1:leng quit:isok="1"  do
	.set tDecStr=..DecryptOne(pwd,start,usrpwd)
	.set pwd=$p(tDecStr,"@#!@#!",1)
	.set start=$p(tDecStr,"@#!@#!",2)
	.set isok=$p(tDecStr,"@#!@#!",3)
	quit pwd
}

///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 不可描述<br>
ClassMethod DecryptOne(pwd As %String, start As %String, usrpwd As %String) As %Library.String
{
	set ok="",isok=""
	for num=32:1:126 quit:ok="1"  do
	.set char=$c(num)
	.if pwd="" set tDecStr=char
	.else  set tDecStr=pwd_""_char 
	.set len=$l(tDecStr)
	.set pass=..Encrypt(tDecStr)
	.if pass=usrpwd set ok="1",isok="1" 
	.if $e(pass,1,len)=$e(usrpwd,1,len) s ok="1"
	.if ok'="1" set tDecStr=pwd quit
	.if pwd="" set pwd=char
	.else  set pwd=pwd_""_char
	quit pwd_"@#!@#!"_start_"@#!@#!"_isok
}

///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 字符转16进制数<br>
ClassMethod ByteToHex(string As %String) As %Library.String
{
	new (string)
	set ret = ""
	for j=1:1:$l(string) do
	.set ascii = $a($e(string,j)) 
	.if ascii<16 set ret = ret_"0"_$zh(ascii)
	.else  set ret = ret_$zh(ascii)
	quit ret
}

///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 16进制数转字符<br>
ClassMethod HexToByte(Hex)
{
	set ret=""
	set len = $l(Hex)
	for i=1:2:len d
	.set h = $e(Hex,i,i+1)
	.set asc = $zh(h)
	.set ret = ret_$c(asc)
	quit ret
}

///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 进行md5加密<br>
///       Other: w ##class(src.Encryption.Encryption).MD5Hex(1)
ClassMethod MD5Hex(string As %String)
{
	new (string)
	Quit:string="" ""
	set EncStr=##class(%SYSTEM.Encryption).MD5Encode(string)
	set EncStr=..ByteToHex(EncStr)
	quit EncStr
}

///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 进行SHA加密<br>
///       Input: string待加密串<br>
///              length SHA加密长度  
///              160 (SHA-1)<br>
///              224 (SHA-224)<br>
///              256 (SHA-256)<br>
///              384 (SHA-384)<br>
///              512 (SHA-512)<br><br>
///       Other: w ##class(src.Encryption.Encryption).SHAHash(1)
ClassMethod SHAHash(length As %Integer, string As %String)
{
	new (length,string)
	Quit:string="" ""
	Quit:length="" ""
	set EncStr=##class(%SYSTEM.Encryption).SHAHash(length,string)
	set EncStr=..ByteToHex(EncStr)
	quit EncStr
}

///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 密码加密(长度不超过12位)<br>
///       Input: AES加密+base加密双重加密串<br>
///      Output: 加密串(长度不超过12位)<br>
ClassMethod DeCodeEnc(passWord)
{
	quit:passWord="" ""
	set ENCKEY=##class(src.Encryption.Encryption).ENCKEY()	; 获取AES密钥，不用常量，常量是迷惑
	set ENCIV=##class(src.Encryption.Encryption).ENCIV()	; 获取AES偏移量，不用常量，常量是迷惑
	set passWord=##class(%SYSTEM.Encryption).Base64Decode(passWord)	; base64 解密
	set passWord=##class(%SYSTEM.Encryption).AESCBCDecrypt(passWord,ENCKEY,ENCIV)	; AES解密
	set passWord=##class(src.Encryption.Encryption).Encrypt(passWord)	; 内部加密
	quit passWord
}

///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 密码加密(长度不超过12位)<br>
///       Input: 明文密码<br>
///      Output: AES加密+base加密双重加密串<br>
ClassMethod EnCodeEnc(passWord)
{
	quit:passWord="" ""
	set ENCKEY=##class(src.Encryption.Encryption).ENCKEY()	; 获取AES密钥，不用常量，常量是迷惑
	set ENCIV=##class(src.Encryption.Encryption).ENCIV()	; 获取AES偏移量，不用常量，常量是迷惑
	set passWord=##class(%SYSTEM.Encryption).AESCBCEncrypt(passWord,ENCKEY,ENCIV)	; AES加密
	set passWord=##class(%SYSTEM.Encryption).Base64Encode(passWord)	; base64 加密
	quit passWord
}

///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 密码加密(长度不超过12位)<br>
///       Input: AES加密+base加密双重加密串<br>
///      Output: 加密串(长度不超过12位)<br>
ClassMethod DeCodeEnc2Obj(passWord) As %DynamicObject
{
	set deCodeEncObj={}
	set errorCode="0"
	if passWord="" {
		set deCodeEncObj.errorCode="01040142"
		set deCodeEncObj.errorMessage="密码不合法,Illegal password"
	}
	quit:passWord="" deCodeEncObj
	try{
		set passWord=..DeCodeEnc(passWord)
		set deCodeEncObj.errorCode=errorCode
		set deCodeEncObj.errorMessage="加密成功"
		set deCodeEncObj.passWord=passWord
	}catch{
		set deCodeEncObj.errorCode="01040142"
		set deCodeEncObj.errorMessage="密码不合法,Illegal password"
	}
	quit deCodeEncObj
}

///      Author: TT<br>
///   CreatDate: 2018-12-28<br>
/// Description: 密码加密(长度不超过12位)<br>
///       Input: 明文密码<br>
///      Output: AES加密+base加密双重加密串<br>
ClassMethod EnCodeEnc2Obj(passWord) As %DynamicObject
{
	set deCodeEncObj={}
	set errorCode="0"
	if passWord="" {
		set deCodeEncObj.errorCode="01040142"
		set deCodeEncObj.errorMessage="密码不合法,Illegal password"
	}
	quit:passWord="" deCodeEncObj
	try{
		set passWord=..EnCodeEnc(passWord)
		set deCodeEncObj.errorCode=errorCode
		set deCodeEncObj.errorMessage="加密成功"
		set deCodeEncObj.passWord=passWord
	}catch{
		set deCodeEncObj.errorCode="01040142"
		set deCodeEncObj.errorMessage="密码不合法,Illegal password"
	}
	quit deCodeEncObj
}

}
