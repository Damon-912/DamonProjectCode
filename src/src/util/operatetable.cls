Import SQLUSER

///      Author: HYG<br> 
///   CreatDate: 2022-06-27 <br>
/// Description: 表操作通用类 <br>
Class src.util.operatetable Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

///      Author: HYG<br>
///   CreatDate: 2022-06-27<br>
/// Description: 插入表数据通用方法<br>
///       Input: jsonobj<br>
///      Output: 0^成功!rowIDArr[成功数据ID,成功数据ID,成功数据ID]
ClassMethod Insert(insObj As %Library.DynamicAbstractObject, sessionObj = {{}})
{
	new (insObj,sessionObj)
	set errorCode="0"
	set errorMessage="成功"
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	set className=insObj.className
	set updateUserID=insObj.updateUserID
	set existFlag=##class(%Library.ClassDefinition).%ExistsId(className)
	if existFlag=0 {
		; 实体类不存在
		set errorCode="01040001"
		set errorMessage=##class(src.Interface.Message).GetErrorMessage(errorCode)
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage
	}
	quit:existFlag=0 resultObj
	set data=insObj.data
	set iter = data.%GetIterator()
	set rowIDInfo=[]
	while iter.%GetNext(.key , .value ) {
		quit:errorCode'="0"
		try{
			set tbObj=$CLASSMETHOD(className,"%New")	; 插表实例化
			set sc1=tbObj.FromDynamicObj(value)
			If ($System.Status.IsError(sc1)) {
				set errorCode="01040029"
				set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(sc1,"cn"),"^"," ")
			}
			if errorCode'="0" do tbObj.%Close()
			quit:errorCode'="0"
			set sc=tbObj.%Save(0)
			If ($System.Status.IsError(sc)) {
				set errorCode="01040031"
				set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(sc,"cn"),"^"," ")
			}
			if errorCode'="0" do tbObj.%Close()
			quit:errorCode'="0"
			set rowID=tbObj.%Id()
			do tbObj.%Close()
			do rowIDInfo.%Push(rowID)
		}catch (e) {
	 		set status=e.AsStatus()
	    	set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
    		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
    		
    	}  
		if errorCode="0" {
			set:sessionObj.userID="" sessionObj.userID=updateUserID
			set logObj={"type":"Insert","oldDataObj":{},"className":(className),"rowID":(rowID),"sessionObj":(sessionObj),"remark":""}
			do ..SaveLogNew(logObj)
		}
	}
	set resultObj.errorCode=errorCode
	set resultObj.errorMessage=errorMessage
	if errorCode=0{
		set resultObj.rowIDArr=rowIDInfo
	}
	quit resultObj
}

/// w ##class(src.util.operatetable).InsertTXT()
ClassMethod InsertTXT() As %String
{
	set insObj={},data=[]
	set insObj.className="User.CBModifyLogConfig"
	set insObj.updateUserID=1
	set PayMentRecordObj={}
	set PayMentRecordObj.TableName=""
	set PayMentRecordObj.CreateDate="2202-10-21"
	set PayMentRecordObj.CreateTime="12:12:1"
	set PayMentRecordObj.CreateUserDr="1"
	do data.%Push(PayMentRecordObj)
	set insObj.data=data
	set insrtn=##class(src.util.operatetable).Insert(.insObj)
	b ;????
	set rtn=$p($p(insrtn,"!",1),"^",1)
	set errorMessage=$p($p(insrtn,"!",1),"^",2)
	set id=$p($p(insrtn,"!",2),"^",1)		
	quit rtn_$c(2)_id_$c(2)_insrtn
}

///      Author: HYG<br>
///   CreatDate: 2022-06-27<br>
/// Description: 更新表数据通用方法<br>
///       Input: jsonobj<br>
///      Output: 0^成功!rowIDArr[成功数据ID,成功数据ID,成功数据ID]
ClassMethod Update(updObj As %Library.DynamicAbstractObject, sessionObj = {{}})
{
	new (updObj,sessionObj)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	set errorCode="0"
	set errorMessage="成功"
	set className=updObj.className
	set updateUserID=updObj.updateUserID
	set existFlag=##class(%Library.ClassDefinition).%ExistsId(className)
	if existFlag=0 {
		; 实体类不存在
		set errorCode="01040001"
		set errorMessage=##class(src.Interface.Message).GetErrorMessage(errorCode)
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage
	}
	quit:existFlag=0 resultObj
	set logFlag=updObj.logFlag
	set data=updObj.data
	set iter = data.%GetIterator()
	set rowIDStr=""
	set rowIDInfo=[]
	while iter.%GetNext(.key , .value ) {
		quit:errorCode'="0"
		set rowID=data.%Get(key).ID
		set oldObj={},oldData=[],oldjson={}
		set Stream=##class(%GlobalCharacterStream).%New()
		set oldObj.className=className
		try{
			set tbObj=$CLASSMETHOD(className,"%OpenId",rowID)	; 插表实例化
			if tbObj'="" {
				; 修改前信息
				set sc2=tbObj.ToDynamicObj(.oldjson)
				If ($System.Status.IsError(sc2)) {
					set errorCode="01040030"
					set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(sc2,"cn"),"^"," ")
				}
				
				if errorCode'="0" do tbObj.%Close()
				quit:errorCode'="0"
				set oldjson=..Remove(oldjson)
				do oldData.%Push(oldjson)
				set oldObj.data=oldData

				set sc1=tbObj.FromDynamicObj(.value)
				If ($System.Status.IsError(sc1)) {
					set errorCode="01040029"
					set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(sc1,"cn"),"^"," ")
				}
				if errorCode'="0" do tbObj.%Close()
				quit:errorCode'="0"
				set sc=tbObj.%Save(0)
				If ($System.Status.IsError(sc)) {
					set errorCode="01040031"
					set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(sc,"cn"),"^"," ")
				}else{
					set rowID=tbObj.%Id()
					do rowIDInfo.%Push(rowID)
				}	
				do tbObj.%Close()
			}else{
				set errorCode="01040003"
				set errorMessage=##class(src.Interface.Message).GetErrorMessage(errorCode)
				set errorMessage=className_" ID="_$g(rowID)_errorMessage
			}
		}catch (e) {
			Set status=e.AsStatus()
		    set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
    	}
    	if errorCode="0" {
	    	set:sessionObj.userID="" sessionObj.userID=updateUserID
			set logObj={"type":"Update","oldDataObj":(oldjson),"className":(className),"rowID":(rowID),"sessionObj":(sessionObj),"remark":""}
			do ..SaveLogNew(logObj)
		}
	}
	
	set resultObj.errorCode=errorCode
	set resultObj.errorMessage=errorMessage
	if errorCode=0{
		set resultObj.rowIDArr=rowIDInfo
	}
	quit resultObj
}

///      Author: HYG<br>
///   CreatDate: 2022-06-28<br>
/// Description: 删除表数据通用方法<br>
///       Input: jsonobj<br>
///      Output: 0^成功!rowIDArr[成功数据ID,成功数据ID,成功数据ID]
ClassMethod Delete(delObj As %Library.DynamicAbstractObject, sessionObj = {{}})
{
	new (delObj,sessionObj)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	set errorCode="0"
	set errorMessage="成功"
	set className=delObj.className
	set updateUserID=delObj.updateUserID
	if updateUserID=""
	{
		set resultObj.errorCode="-1"
		set resultObj.errorMessage="删除人不能为空"
		quit 
	}
	set existFlag=##class(%Library.ClassDefinition).%ExistsId(className)
	if existFlag=0 {
		; 实体类不存在
		set errorCode="01040001"
		set errorMessage=##class(src.Interface.Message).GetErrorMessage(errorCode)
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage
	}
	quit:existFlag=0 resultObj
	set rowIDInfo=[]
	set data=delObj.data
	set iter = data.%GetIterator()
	while iter.%GetNext(.key , .value ) {
		quit:errorCode'="0"
		set rowID=data.%Get(key).ID
		set oldObj={},oldData=[],oldjson={}
		set oldObj.className=className
		try{
			set tbObj=$CLASSMETHOD(className,"%OpenId",rowID)
			if (tbObj'=""){
				; 修改前信息
				; 修改前信息
				set sc2=tbObj.ToDynamicObj(.oldjson)
				If ($System.Status.IsError(sc2)) {
					set errorCode="01040030"
					set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(sc2,"cn"),"^"," ")
				}
				if errorCode'="0" do tbObj.%Close()
				quit:errorCode'="0"
				b ;23232323
				set oldjson=..Remove(oldjson)
				do oldData.%Push(oldjson)
				set oldObj.data=oldData
				b ;oldObj2
				; 修改前信息

				set sc=tbObj.%DeleteId(rowID)	;  删除
				If ($System.Status.IsError(sc)) {
					set errorCode="01040031"
					set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(sc,"cn"),"^"," ")
				}else{
					do rowIDInfo.%Push(rowID)
				}
			}else{
				set errorCode="01040003"
				set errorMessage=##class(src.Interface.Message).GetErrorMessage(errorCode)
				set errorMessage=className_" ID="_$g(rowID)_errorMessage
			}
		}catch (e) {
			Set status=e.AsStatus()
		    set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
    	}  
		if errorCode="0" {
			set:sessionObj.userID="" sessionObj.userID=updateUserID
			set logObj={"type":"Delete","oldDataObj":(oldjson),"className":(className),"rowID":(rowID),"sessionObj":(sessionObj),"remark":""}
			do ..SaveLogNew(logObj)
		}
	}

	set resultObj.errorCode=errorCode
	set resultObj.errorMessage=errorMessage
	if errorCode=0{
		set resultObj.rowIDArr=rowIDInfo
	}
	quit resultObj
}

///   CreatDate: 2022-06-28<br>
/// Description: 清除返回的子表数组数据<br>
///       Input: jsonobj<br>
///      Output: jsonobj
ClassMethod Remove(reJson As %Library.DynamicObject)
{
	new (reJson)
	set iter = reJson.%GetIterator()
	while iter.%GetNext(.key , .value ) {
		if (($zcvt(key,"U")["CHILD")&(value["%Library.DynamicArray")) d reJson.%Remove(key)
	}
	quit reJson
}

/// w ##class(src.util.operatetable).SaveLog({"ID":"727","BarCode":"556","BaseUnitDr":"427","BillFac":1,"ChargeItemDr":"4776","Code":"ZY0005379","Descripts":"吴茱萸","DrugUseInfo":"","ENDescripts":"","Factor":1,"ISCDr":"","ImpTypeDr":"","MaxSprice":"","MedItemDr":"5684","PreparationFlag":"","PriceFileNo":"","PriceTypeDr":"","PurchUnitDr":"337","QuaLevelDr":"","QualityNo":"","Spec":"1*12","StkSubCatDr":"1000"},"User.CBStockItem",727,{"userID":"555","locID":"292","groupID":"315","hospID":"63","sessionID":"R56Xe99mlz","hospCode":"H20","language":"CN","hostName":"","ipv4":"182.254.131.121","ipv6":"","mac":""})
ClassMethod SaveLog(oldDataObj, className, rowID, sessionObj)
{
	new (oldDataObj,className,rowID,sessionObj)
	try {
		set errorCode=0,errorMessage="保存日志成功"
		&sql(select ID into :configID from CB_ModifyLogConfig where TableName=:className)
		if SQLCODE'=0 {
			set errorCode=-1
			set errorMessage="未配置修改日志表,不需保存日志"
			quit
		}
		set newTbObj=$CLASSMETHOD(className,"%OpenId",rowID)
		if newTbObj'="" {
			set sc=newTbObj.ToDynamicObj(.newDataObj)
			if ($System.Status.IsError(sc)) {
				set errorCode=-1
				set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(sc,"cn"),"^"," ")
				quit
			}
			set i=0
			set insOldDataObj={},insNewDataObj={}
			set iter = newDataObj.%GetIterator()
			while iter.%GetNext(.key , .value ) {
				set oldValue=oldDataObj.%Get(key)
				continue:value=oldValue
				do insOldDataObj.%Set(key,oldValue)
				do insNewDataObj.%Set(key,value)
				set i=i+1
			}
			if i=0 {
				set errorCode=-1
				set errorMessage="数据未发生改变,不需保存日志"
				quit
			}
			set userID=sessionObj.userID
			set locID=sessionObj.locID
			set groupID=sessionObj.groupID
			set hospID=sessionObj.hospID
			set ipAddress=sessionObj.ipv4
			set macAddress=sessionObj.mac
			kill PLIST
			set PLIST(2)=+$h
			set PLIST(3)=$p($h,",",2)
			set PLIST(4)=userID
			set PLIST(5)=ipAddress
			set PLIST(6)=macAddress
			set PLIST(7)=hospID
			set PLIST(8)=groupID
			set PLIST(9)=locID
			set PLIST(10)=className
			set PLIST(11)=rowID
			if insOldDataObj'=""{
				set PLIST(12)=insOldDataObj.%ToJSON()	
			}
			if insNewDataObj'=""{
				set PLIST(13)=insNewDataObj.%ToJSON()	
			}
			&sql(INSERT INTO SQLUser.BS_BaseDataModifyLog Values PLIST())
			if SQLCODE'=0 {
				set errorCode=SQLCODE
				set errorMessage=$g(%msg)
				quit
			}
		}else {
			set errorCode=-1
			set errorMessage="表实例化失败"
			quit
		}
	}catch(e){
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(e.AsStatus()),",")
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(e.AsStatus(),"cn"),"^"," ")
	}
	set retObj={
		"errorCode":(errorCode),
		"errorMessage":(errorMessage)
	}
	quit retObj
}

/// :65:^
/// w ##class(src.util.operatetable).DeleteLog({"className":"User.CBReactForm","data":[{"ID":"65","CBReactComDr":"4","Callback":"","ClassName":"","Code":"descripts","Col":"4","CreateDate":"2024-05-18","CreateUserDr":"158","Default":"","Descripts":"描述","Disabled":"N","Display":"Y","Doubt":"","ENDesc":"","ElementFieldDr":"4","FieldTypeDr":"5","JumpDr":"","LabelCol":"8","LinkCode":"","LinkValueDr":"","MethodName":"","Params":"","Placeholder":"","Required":"N","SeqNo":"","Valid":"","WrapperCol":"15"}]},"User.CBReactForm","65",{"userID":"158"})
ClassMethod DeleteLog(oldDataObj, className, rowID, sessionObj)
{
	new (oldDataObj,className,rowID,sessionObj)
	b ;2q3
	set ^TMP("DeleteLog")=className_":"_rowID_":"_oldDataObj.%ToJSON()_"^"_sessionObj.%ToJSON()

	try {
		set errorCode=0,errorMessage="保存日志成功"
#;		&sql(select ID into :configID from CB_ModifyLogConfig where TableName=:className)
#;		if SQLCODE'=0 {
#;			set errorCode=-1
#;			set errorMessage="未配置修改日志表,不需保存日志"
#;			quit
#;		}
		set userID=sessionObj.userID
		set locID=sessionObj.locID
		set groupID=sessionObj.groupID
		set hospID=sessionObj.hospID
		set ipAddress=sessionObj.ipv4
		set macAddress=sessionObj.mac
		kill PLIST
		set PLIST(2)=+$h
		set PLIST(3)=$p($h,",",2)
		set PLIST(4)=userID
		set PLIST(5)=ipAddress
		set PLIST(6)=macAddress
		set PLIST(7)=hospID
		set PLIST(8)=groupID
		set PLIST(9)=locID
		set PLIST(10)=className
		set PLIST(11)=rowID
		if oldDataObj'=""{
			set PLIST(12)=oldDataObj.%ToJSON()	
		}
		&sql(INSERT INTO SQLUser.BS_BaseDataModifyLog Values PLIST())
		if SQLCODE'=0 {
			set errorCode=SQLCODE
			set errorMessage=$g(%msg)
			quit
		}
	}catch(e){
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(e.AsStatus()),",")
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(e.AsStatus(),"cn"),"^"," ")
	}
	set retObj={
		"errorCode":(errorCode),
		"errorMessage":(errorMessage)
	}
	quit retObj
}

/// w ##class(src.util.operatetable).SaveLog({"ID":"727","BarCode":"556","BaseUnitDr":"427","BillFac":1,"ChargeItemDr":"4776","Code":"ZY0005379","Descripts":"吴茱萸","DrugUseInfo":"","ENDescripts":"","Factor":1,"ISCDr":"","ImpTypeDr":"","MaxSprice":"","MedItemDr":"5684","PreparationFlag":"","PriceFileNo":"","PriceTypeDr":"","PurchUnitDr":"337","QuaLevelDr":"","QualityNo":"","Spec":"1*12","StkSubCatDr":"1000"},"User.CBStockItem",727,{"userID":"555","locID":"292","groupID":"315","hospID":"63","sessionID":"R56Xe99mlz","hospCode":"H20","language":"CN","hostName":"","ipv4":"182.254.131.121","ipv6":"","mac":""})
ClassMethod SaveLogNew(logObj)
{
	new (logObj)
	try {
		set errorCode=0,errorMessage="保存日志成功"
		set type=logObj.type
		set oldDataObj=logObj.oldDataObj
		set className=logObj.className
		set rowID=logObj.rowID
		set sessionObj=logObj.sessionObj
		set remark=logObj.remark
		if type="delete" {
			set newDataObj={}
		}else {
			set newTbObj=$CLASSMETHOD(className,"%OpenId",rowID)
			if newTbObj'="" {
				set sc=newTbObj.ToDynamicObj(.newDataObj)
				if ($System.Status.IsError(sc)) {
					set errorCode=-1
					set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(sc,"cn"),"^"," ")
					quit
				}
				set newDataObj=..Remove(newDataObj)
				set i=0
				set insOldDataObj={},insNewDataObj={}
				set iter = newDataObj.%GetIterator()
				while iter.%GetNext(.key , .value ) {
					set oldValue=oldDataObj.%Get(key)
					continue:value=oldValue
					do insOldDataObj.%Set(key,oldValue)
					do insNewDataObj.%Set(key,value)
					set i=i+1
				}
				if i=0 {
					set errorCode=-1
					set errorMessage="数据未发生改变,不需保存日志"
					quit
				}
			}else {
				set errorCode=-1
				set errorMessage="表实例化失败"
				quit
			}
		}
		set userID=sessionObj.userID
		set ipAddress=sessionObj.ipv4
		set macAddress=sessionObj.mac
		kill PLIST
		set PLIST(2)=type
		set PLIST(3)=className
		set PLIST(4)=rowID
		set PLIST(5)=oldDataObj.%ToJSON()		//insOldDataObj.%ToJSON()
		set PLIST(6)=newDataObj.%ToJSON()		//insNewDataObj.%ToJSON()
		set PLIST(7)=+$h
		set PLIST(8)=$p($h,",",2)
		set PLIST(9)=userID
		set PLIST(10)=ipAddress
		set PLIST(11)=macAddress
		set PLIST(12)=remark
		&sql(INSERT INTO SQLUser.BS_DataModifyRecord Values PLIST())
		if SQLCODE'=0 {
			set errorCode=SQLCODE
			set errorMessage=$g(%msg)
			quit
		}
	}catch(e){
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(e.AsStatus()),",")
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(e.AsStatus(),"cn"),"^"," ")
	}
	set retObj={
		"errorCode":(errorCode),
		"errorMessage":(errorMessage)
	}
	quit retObj
}

}
