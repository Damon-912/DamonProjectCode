/// 接口日志
Class User.BSSrcRestMapLog Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_SrcRestMapLog ]
{

Parameter %JSONREFERENCE = "ID";

/// 医院
Property HospitalDr As CBHospital [ SqlColumnNumber = 2, SqlFieldName = Hospital_Dr ];

/// 输入IP地址
Property InputIP As %String [ SqlColumnNumber = 3, SqlFieldName = InputIP ];

/// 输入MAC地址
Property InputMAC As %String [ SqlColumnNumber = 4, SqlFieldName = InputMAC ];

/// 接口代码
Property Code As %String(COLLATION = "UPPER", MAXLEN = 10, TRUNCATE = 1) [ SqlColumnNumber = 5, SqlFieldName = Code ];

Index IndexCode On Code;

/// 连接日期时间
Property LinkDateTime As %String [ SqlColumnNumber = 6, SqlFieldName = LinkDateTime ];

/// 入参
Property Inputstr As %String(MAXLEN = 5000, TRUNCATE = 1) [ SqlColumnNumber = 7, SqlFieldName = Inputstr ];

/// 连接地址
Property LinkURL As %String(MAXLEN = 500, TRUNCATE = 1) [ SqlColumnNumber = 8, SqlFieldName = LinkURL ];

/// 返回日期时间
Property OutDateTime As %String [ SqlColumnNumber = 9, SqlFieldName = OutDateTime ];

/// 出参
Property Outstr As %String(MAXLEN = 5000, TRUNCATE = 1) [ SqlColumnNumber = 10, SqlFieldName = Outstr ];

/// 连接日期 
Property LinkDate As %Date [ SqlColumnNumber = 11, SqlFieldName = LinkDate ];

Index LinkDate On LinkDate;

/// 连接时间
Property LinkTime As %Time [ SqlColumnNumber = 12, SqlFieldName = LinkTime ];

/// 返回日期 
Property OutDate As %Date [ SqlColumnNumber = 13, SqlFieldName = OutDate ];

/// 返回时间
Property OutTime As %Time [ SqlColumnNumber = 14, SqlFieldName = OutTime ];

/// 状态
Property Status As %String(DISPLAYLIST = ",WAIT,COMPLETE,ERR", TRUNCATE = 1, VALUELIST = ",W,C,E") [ SqlColumnNumber = 15, SqlFieldName = Status ];

/// 等待时间
Property WaitTime As %Integer [ SqlColumnNumber = 16, SqlFieldName = WaitTime ];

Index IndexWaitTime On WaitTime;

/// 创建人
Property CreateUserDr As HBUser [ SqlColumnNumber = 17, SqlFieldName = CreateUser_Dr ];

/// 输出大小
Property OutSize As %Integer [ SqlColumnNumber = 18, SqlFieldName = OutSize ];

Storage Default
{
<Data name="BSSrcRestMapLogDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>HospitalDr</Value>
</Value>
<Value name="3">
<Value>InputIP</Value>
</Value>
<Value name="4">
<Value>InputMAC</Value>
</Value>
<Value name="5">
<Value>Code</Value>
</Value>
<Value name="6">
<Value>LinkDateTime</Value>
</Value>
<Value name="7">
<Value>Inputstr</Value>
</Value>
<Value name="8">
<Value>LinkURL</Value>
</Value>
<Value name="9">
<Value>OutDateTime</Value>
</Value>
<Value name="10">
<Value>Outstr</Value>
</Value>
<Value name="11">
<Value>LinkDate</Value>
</Value>
<Value name="12">
<Value>LinkTime</Value>
</Value>
<Value name="13">
<Value>OutDate</Value>
</Value>
<Value name="14">
<Value>OutTime</Value>
</Value>
<Value name="15">
<Value>Status</Value>
</Value>
<Value name="16">
<Value>WaitTime</Value>
</Value>
<Value name="17">
<Value>CreateUserDr</Value>
</Value>
<Value name="18">
<Value>OutSize</Value>
</Value>
</Data>
<DataLocation>^BSSrcRestMapLogD</DataLocation>
<DefaultData>BSSrcRestMapLogDefaultData</DefaultData>
<IdLocation>^BSSrcRestMapLogD</IdLocation>
<IndexLocation>^BSSrcRestMapLogI</IndexLocation>
<StreamLocation>^BSSrcRestMapLogS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

/// 插入log
/// w ##class(User.BSSrcRestMapLog).InsetSrcRestMapLog("",{"params":[{"Descripts":"","Code":"","Group":"3","Hospital":"6","User":"2860"}],"pagination":[{"pageSize":10,"currentPage":1,"sortColumn":"","sortOrder":""}],"code":"4010","session":[{"userID":"2860","locID":"828","groupID":"3","hospID":"6","sessionID":"5WiFsaC1VM","hospCode":"SZXYSMZB","language":"CN","hostName":"SC-201907220930\\Administrator","ipv4":"172.18.13.75","ipv6":"fe80::24bc:d024:7a34:ca42%13","mac":"9C-5C-8E-93-0B-78"}]})
ClassMethod InsetSrcRestMapLog(code, postObj)
{
	new (code,postObj)
	set session=$case(postObj.session'="","1":postObj.session.%Get(0),:"")
	set (srcRestMapLogID,IP,MAC,userID,hospID)=""
	if ((session'="")){
		set userID=session.userID
		set hospID=session.hospID
		set IP=session.ipv4
		set MAC=session.mac
	}
	try{
		set data=+$h
		set time=$p($h,",",2)
		set timeStamp=$zdt($zdth($zts,-3),3,1,3)
		set dataObj=##class(User.BSSrcRestMapLog).%New()
		do dataObj.HospitalDrSetObjectId(hospID)
		set dataObj.Code=code
		set dataObj.LinkDate=data
		set dataObj.LinkTime=time
		set dataObj.LinkDateTime=timeStamp
		set dataObj.Inputstr=postObj.%ToJSON()
		set dataObj.Status="W"
		set dataObj.InputIP=IP
		set dataObj.InputMAC=MAC
		do dataObj.CreateUserDrSetObjectId(userID)
		Set tSC = dataObj.%Save() 
		set srcRestMapLogID=dataObj.%Id()
		$$$ThrowOnError(tSC) 
	}catch(e){
		set status=e.AsStatus()
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit srcRestMapLogID
}

/// 更新
/// w ##class(User.BSSrcRestMapLog).UpdateSrcRestMapLog(2,"E","ceshi")
ClassMethod UpdateSrcRestMapLog(srcRestMapLogID, status, outstr, linkURL = "", outsize = "0")
{
	new (srcRestMapLogID, status,outstr,linkURL,outsize)
	quit:+srcRestMapLogID=0
	try{
		set dataObj=##class(User.BSSrcRestMapLog).%OpenId(srcRestMapLogID)
		if linkURL'=""{
			set dataObj.LinkURL=linkURL
			Set tSC = dataObj.%Save() 
			set srcRestMapLogID=dataObj.%Id()
			$$$ThrowOnError(tSC)
		}else{
			set data=+$h
			set time=$p($h,",",2)
			set timeStamp=$zdt($zdth($zts,-3),3,1,3)
			set linkDateTime=dataObj.LinkDateTime
			set outDateTime=dataObj.OutDateTime
			set linkTimenumble=0,outkTimenumble=0
			if linkDateTime'="" {
				set linkDateTime=$zdth(linkDateTime,3,1,3)
				set linkTimenumble=$p(linkDateTime,",",1)*24*3600+$p(linkDateTime,",",2)
			}
			set outDateTime=$zdth(timeStamp,3,1,3)
			set outkTimenumble=$p(outDateTime,",",1)*24*3600+$p(outDateTime,",",2)
			set waitTime=(outkTimenumble-linkTimenumble)*1000
			set dataObj.OutDate=data
			set dataObj.OutTime=time
			set dataObj.OutDateTime=timeStamp
			set dataObj.Status=status
			set dataObj.Outstr=outstr
			set dataObj.WaitTime=+waitTime
			set dataObj.OutSize=+outsize
			Set tSC = dataObj.%Save() 
			set srcRestMapLogID=dataObj.%Id()
			$$$ThrowOnError(tSC) 
		}
	}catch(e){
		set status=e.AsStatus()
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit srcRestMapLogID
}

}
