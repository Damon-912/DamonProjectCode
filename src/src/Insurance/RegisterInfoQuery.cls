Import sqluser

/// 登记信息查询
Class src.Insurance.RegisterInfoQuery Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:      gjg
/// CreatDate:    2022-07-20
/// Description:  获取医保登记信息
/// Table:        BS_MedInsuRegisterInfo
/// Debug：		 w ##class(src.Insurance.RegisterInfoQuery).GetRegisterInfo({"params":[{}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"code","sortOrder":"asc"}],"code":"02020001","session":[{"userID":"135","locID":1,"groupID":"1","groupDesc":"管理员","hospID":"6","sessionID":"dSRcLsQkf4","hospCode":"H04","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod GetRegisterInfo(postObj) As %Library.DynamicObject
{
	new (postObj)
	set params=postObj.params.%Get(0)
	set session=postObj.session.%Get(0)
	set pagination=postObj.pagination.%Get(0)
	set hospID=session.hospID
	set startDate=params.startDate
	set endDate=params.endDate
	set:startDate="" startDate=$zd(+$h-7,3)
	set:endDate="" endDate=$zd(+$h,3)
	set result=##class(src.util.ResultSet).Success()
	try{
		set sql="select Hospital_Dr->Code as hospCode,Interface_Dr->InterfaceNO as interfaceNO,* from BS_MedInsuRegisterInfo where Hospital_Dr="_hospID_" and  RegDate between '"_startDate_"' and '"_endDate_"'"
		set sql=sql_" order by ID desc"
		set result=##class(src.util.SQLUtil).SqlForList(sql,pagination)
	}catch(e){
		set errorInfo="获取医保登记信息出错:w ##class("_$ClassName()_").GetRegisterInfo("_postObj.%ToJSON()_")"
		set result=##class(src.util.ResultSet).CatchFailToLog(e,errorInfo)
	}
	quit result
}

/// Creator:      gjg
/// CreatDate:    2022-07-21
/// Description:  获取医保结算信息
/// Table:        BS_MedInsuSettlement
/// Debug：		 w ##class(src.Insurance.RegisterInfoQuery).GetMedInsuSettlement({"params":[{}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"code","sortOrder":"asc"}],"code":"02020001","session":[{"userID":"135","locID":1,"groupID":"1","groupDesc":"管理员","hospID":"6","sessionID":"dSRcLsQkf4","hospCode":"H04","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod GetMedInsuSettlement(postObj) As %Library.DynamicObject
{
	new (postObj)
	set params=postObj.params.%Get(0)
	set session=postObj.session.%Get(0)
	set pagination=postObj.pagination.%Get(0)
	set hospID=session.hospID
	set startDate=params.startDate
	set endDate=params.endDate
	set:startDate="" startDate=$zd(+$h-7,3)
	set:endDate="" endDate=$zd(+$h,3)
	set result=##class(src.util.ResultSet).Success()
	try{
		set sql="select Hosp_Dr->Code as hospCode,Interface_Dr->InterfaceNO as interfaceNO,* from BS_MedInsuSettlement where Hosp_Dr="_hospID_" and  OccurTime between '"_startDate_"' and '"_endDate_"'"
		set sql=sql_" order by ID desc"
		set result=##class(src.util.SQLUtil).SqlForList(sql,pagination)
	}catch(e){
		set errorInfo="获取医保结算信息出错:w ##class("_$ClassName()_").GetMedInsuSettlement("_postObj.%ToJSON()_")"
		set result=##class(src.util.ResultSet).CatchFailToLog(e,errorInfo)
	}
	quit result
}

/// Creator:      gjg
/// CreatDate:    2022-07-21
/// Description:  根据医保就诊号获取医保上传费用明细
/// Table:        BS_MedInsuFeeUploadRecord
/// Debug：		 w ##class(src.Insurance.RegisterInfoQuery).GetMedInsuFeeUploadRecordByMdtrtID({"params":[{"mdtrtID":"ceshi"}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"code","sortOrder":"asc"}],"code":"02020001","session":[{"userID":"135","locID":1,"groupID":"1","groupDesc":"管理员","hospID":"6","sessionID":"dSRcLsQkf4","hospCode":"H04","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod GetMedInsuFeeUploadRecordByMdtrtID(postObj) As %Library.DynamicObject
{
	new (postObj)
	set params=postObj.params.%Get(0)
	set session=postObj.session.%Get(0)
	set pagination=postObj.pagination.%Get(0)
	set hospID=session.hospID
	set mdtrtID=params.mdtrtID
	set startDate=params.startDate
	set endDate=params.endDate
	set:startDate="" startDate=$zd(+$h-7,3)
	set:endDate="" endDate=$zd(+$h,3)
	set result=##class(src.util.ResultSet).Success()
	if (mdtrtID=""){
		quit ##class(src.util.ResultSet).FailInfoByCode("01000014")
	}
	try{
		set sql="select Hospital_Dr->Code hospCode,* from BS_MedInsuFeeUploadRecord where MdtrtID='"_mdtrtID_"' and FeeOccurTime between '"_startDate_"' and '"_endDate_"'"
		set sql=sql_" order by ID desc"
		set result=##class(src.util.SQLUtil).SqlForList(sql,pagination)
	}catch(e){
		set errorInfo="获取医保上传费用明细出错:w ##class("_$ClassName()_").GetMedInsuFeeUploadRecord("_postObj.%ToJSON()_")"
		set result=##class(src.util.ResultSet).CatchFailToLog(e,errorInfo)
	}
	quit result
}

/// Creator:      zxz
/// CreatDate:    2022-07-25
/// Description:  获取医保日志
/// Table:        User.BSMedInsuTransactionLog
/// Debug：		 w ##class(src.Insurance.RegisterInfoQuery).GetMedInsuTransactionLog({"params":[{"hospID":"55"}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"code","sortOrder":"asc"}],"code":"02020001","session":[{"userID":"135","locID":1,"groupID":"1","groupDesc":"管理员","hospID":"55","sessionID":"dSRcLsQkf4","hospCode":"H04","language":"CN","deviceID":"WEB:test","hostName":"WEB:test","ipv4":"192.168.0.100","ipv6":"192.168.0.100","mac":"fe80::48a:d9c7:ac9"}]}).%ToJSON()
ClassMethod GetMedInsuTransactionLog(postObj) As %Library.DynamicObject
{
	new (postObj)
	try{
		set result={"errorCode":"0","errorMessage":"","result":{}}
		set pageSize="",currentPage=1,count=0,dataArr=[]
		set params=postObj.params.%Get(0)
		set session=postObj.session.%Get(0)
		set pagination=postObj.pagination.%Get(0)
		set hospID=params.hospID
		if params.hospID=""{
			set hospID=session.hospID
		}
		if (postObj.%IsDefined("pagination")'=0) {
			set pagationObj=postObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
			set currentPage=pagationObj.currentPage
		}
		set sql="select ID,Hospital_Dr->Code hospCode,Hospital_Dr->Descripts as hospDesc,Interface_Dr->InterfaceName,Infno,MSGID,Mdtrtareaadmvs,InsuplcAdmdvs,PSNNO,InfDate,InfTime,RecerSyscode,DevNo,"
			_"Opter,OpterName,FixMedinsCode,FixMedinsName,Inparam,Outparam from BS_MedInsuTransactionLog"
			///_" where Hospital_Dr="_hospID
		b ;; sql
		set st=##class(%SQL.Statement).%New(1)
	 	set sc=st.%Prepare(sql)
	 	set rs=st.%Execute()
	 	while rs.%Next(){
		 	set inparam={}
		 	set outparam={}
		 	set id=rs.%Get("ID")
		 	set hospCode=rs.%Get("hospCode")
		 	set hospDesc=rs.%Get("hospDesc")
		 	set interfaceName=rs.%Get("InterfaceName")
		 	set infno=rs.%Get("Infno")
		 	set MSGID=rs.%Get("MSGID")
		 	set mdtrtareaadmvs=rs.%Get("Mdtrtareaadmvs")
		 	set insuplcAdmdvs=rs.%Get("InsuplcAdmdvs")
		 	set PSNNO=rs.%Get("PSNNO")
		 	set infDate=rs.%Get("InfDate")
		 	set infTime=rs.%Get("InfTime")
		 	set recerSyscode=rs.%Get("RecerSyscode")
		 	set devNo=rs.%Get("DevNo")
		 	set opter=rs.%Get("Opter")
		 	set opterName=rs.%Get("OpterName")
		 	set opter=rs.%Get("Opter")
		 	set fixMedinsCode=rs.%Get("fixMedinsCode")
		 	set fixMedinsName=rs.%Get("FixMedinsName")
		 	set inparam=rs.%Get("Inparam")
		 	set outparam=rs.%Get("Outparam")
		 	if inparam'=""{
			 	set inparam=##class(%Library.DynamicObject).%FromJSON(inparam)
			}
		 	if outparam'=""{
			 	set outparam=##class(%Library.DynamicObject).%FromJSON(outparam)
			}
		 	set dataObj={}
		 	set dataObj.id=id
		 	set dataObj.hospCode=hospCode
		 	set dataObj.hospDesc=hospDesc
		 	set dataObj.interfaceName=interfaceName
		 	set dataObj.infno=infno
		 	set dataObj.MSGID=MSGID
		 	set dataObj.mdtrtareaadmvs=mdtrtareaadmvs
		 	set dataObj.insuplcAdmdvs=insuplcAdmdvs
		 	set dataObj.PSNNO=PSNNO
		 	set dataObj.infDate=infDate
		 	set dataObj.infTime=infTime
		 	set dataObj.recerSyscode=recerSyscode
		 	set dataObj.devNo=devNo
		 	set dataObj.opter=opter
		 	set dataObj.opterName=opterName
		 	set dataObj.devNo=devNo
		 	set dataObj.fixMedinsCode=fixMedinsCode
		 	set dataObj.fixMedinsName=fixMedinsName
		 	set dataObj.inparam=inparam
		 	set dataObj.outparam=outparam
		 	set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		 }
		set result.result.Data=dataArr
		set result.result.TotalCount=count	
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		b ;; errorMessage
		set errorInfo="获取获取医保日志出错:w ##class("_$ClassName()_").SaveDictionaries("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set result={}
		set result.errorCode="04000007"
		set result.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID
	}
	quit result
}

}
