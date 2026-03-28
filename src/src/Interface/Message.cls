Import sqluser

/// 信息提示公共类
Class src.Interface.Message Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

///      Author: TC<br>
///   CreatDate: 2022-06-30<br>
/// Description: 根据代码返回自定义提示信息<br>
///       Input：代码status,语言languageID  CB_Language表ID
///      Output：提示信息message
ClassMethod GetErrorMessage(status As %Library.String, languageID As %Library.String = "") As %Library.String
{
	new (status,languageID)
	quit:status="" ""
	
	set message="",langCode=""
	if languageID="" {
		set langCode="CN"
	}else{
		set langObj=##class(User.CBLanguage).%OpenId(languageID)
		if $IsObject(langObj) {set langCode=langObj.Code}
	}
	quit:langCode="" ""
	
	set queryStr = "select Descripts,ENDesc from CB_Message where Code = '"_status_"'"
	set tStatement = ##class(%SQL.Statement).%New()
	set qStatus = tStatement.%Prepare(queryStr)
	quit:qStatus'=1 $System.Status.GetErrorText(qStatus)
	; SQL执行
	set rSet= tStatement.%Execute()
	quit:rSet.SQLCODE'=0 ##class(src.Interface.Message).GetErrorMessage(rSet.SQLCODE)
	
	while rSet.%Next() {
		set descripts=rSet.%Get("Descripts")
		set endescripts=rSet.%Get("ENDesc")
		if ($ZCVT(langCode,"U")="EN"){
			set message=endescripts
		}else{
			set message=descripts
		}
	}
	quit message
}

/// Creator:	TC
/// CreatDate:	2022-06-30
/// Descript:	消息提示
/// Input:
/// ##class(src.Interface.Message).GetErrorMessageByCode()
ClassMethod GetErrorMessageByCode(Code, resultObj)
{
	set resultObj.errorCode=Code
	set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage(Code)
	quit resultObj
}

/// Creator:	TC
/// CreatDate:	2022-06-30
/// Descript:	插入错误日志
/// Input:
/// 	appCode:		"02010001"
/// 	errorMessage: 	$System.Status.GetErrorText(e.AsStatus(),"cn")
/// 	errorInfo: 		"查询单号规则程序异常:w ##class("_$ClassName()_").GetAppCounter("_inputData_","_pageStr_")"
ClassMethod InsErrRecord(AppCode, ErrInfo, ErrValue)
{
	new (AppCode, ErrInfo, ErrValue)
	set rowId=""
	try{
		set curDate=+$h
		set curTime=$p($h,",",2)
		&sql(Insert into BS_ErrorRecord(ErrDate,ErrTime,AppCode,ErrInfo,ErrValue) values(:curDate,:curTime,:AppCode,:ErrInfo,:ErrValue))
		if SQLCODE'=0  {
			set rowId=""
		}else  {
			set rowId=$p($g(%ROWID),$c(1))
		}	
	}catch(e)
	{
	}
	quit rowId
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 获取信息提示配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Interface.Message).GetMessageConfig({"params":[{"code":"04000002","descripts":""}]}).%ToJSON()
ClassMethod GetMessageConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try{
		if (jsonObj.%IsDefined("pagination")'=0) {
			set pagationObj=jsonObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
			set currentPage=pagationObj.currentPage
		}
		set params=jsonObj.params.%Get(0)
		set compareCode=params.code
		set compareDescripts=params.descripts
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_Message"		
		if (compareCode'="")||(compareDescripts'="") 
		{
			set sql=sql_" WHERE 1=1"
			set:(compareCode'="") sql=sql_" AND Code LIKE '%"_compareCode_"%'"
			set:(compareDescripts'="") sql=sql_" AND Descripts LIKE '%"_compareDescripts_"%'"
		}
		b	;111
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.enDesc=result.%Get("ENDesc")
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="获取信息提示配置出错:w ##class("_$ClassName()_").GetMessageConfig("_jsonObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 删除信息提示配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Interface.Message).DeleteMessageConfig()
ClassMethod DeleteMessageConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		if params.id="" 
		{
			set resultObj.errorCode="05100128"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")
			quit
		}
		
		set delObj={},data=[]
		set delObj.className="User.CBMessage"
		set delObj.updateUserID=userID
		set dataObj={}
		set dataObj.ID=params.id
		do data.%Push(dataObj)
		set delObj.data=data
		;b ;0
		set rtn=##class(src.util.operatetable).Delete(.delObj) ;调用公共类方法记录修改日记
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage		
		
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="删除信息提示配置出错:w ##class("_$ClassName()_").DeleteMessageConfig("_jsonObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 保存信息提示配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Interface.Message).SaveMessageConfig({"params":[{"id":"6","code":"05100128","descripts":"请选择一条数据","enDesc":"you should select data"}],"session":[{"userID":"1"}]}).%ToJSON()
ClassMethod SaveMessageConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set dataObj={},dataArr=[]
		set dataObj.ID=params.id
		set dataObj.Code=params.code
		set dataObj.Descripts=params.descripts
		set dataObj.ENDesc=params.enDesc
		if $d(^CBMessageI("Code",$zcvt(params.code,"U"))){
			set existID=$o(^CBMessageI("Code",$zcvt(params.code,"U"),0))
			if existID'=params.id{
				set resultObj.errorCode=-1
				set resultObj.errorMessage="该提示代码已存在"
				quit
			}
		}
		if $d(^CBMessageI("Desc",$zcvt(params.descripts,"U"))){
			set existID=$o(^CBMessageI("Desc",$zcvt(params.code,"U"),0))
			if existID'=params.id{
				set resultObj.errorCode=-1
				set resultObj.errorMessage="该提示信息已存在"
				quit
			}
		}
		if params.id=""{			
			set dataObj.CreateDate=+$h
			set dataObj.CreateUserDr=session.userID
		}		
		do dataArr.%Push(dataObj)
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className="User.CBMessage"			
		set operateObj.data=dataArr		
		if params.id=""{
			set rtn=##class(src.util.operatetable).Insert(.operateObj) ;调用公共类方法记录修改日记
		}else{				
			set rtn=##class(src.util.operatetable).Update(.operateObj) ;调用公共类方法记录修改日记
		}
		b	;
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		if errorCode'="0"{
			set resultObj.errorCode=errorCode
			set resultObj.errorMessage=errorMessage
			quit
		}
		
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="保存信息提示配置出错:w ##class("_$ClassName()_").SaveMessageConfig("_jsonObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")
	    b	;err
	}
	quit resultObj
}

}
