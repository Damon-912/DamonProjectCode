/// 公共元素集
Class src.ElementField.CBElementField Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     HYG
/// CreatDate:   2024-05-15
/// Description: 初始化公共元素集	 
/// Debug:   w ##Class(src.ElementField.CBElementField).GetInitialize({"params":[{"code":"","descripts":"","fieldClassID":""}],"code":"01010042","pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"Code","sortOrder":"asc"}]}).%ToJSON()
ClassMethod GetInitialize(postObj)
{
	new (postObj)
	
	set configFieldType=[]
	set sql="select * from SQLUSER.CB_ConfigFieldType"
	set sqlObj=##class(%SQL.Statement).%New()
	set sc=sqlObj.%Prepare(sql)
	set list=sqlObj.%Execute()
	while list.%Next(){
		set obj={}
		set obj.id=list.%Get("ID")
		set obj.code=list.%Get("Code")
		set obj.descripts=list.%Get("Descripts")
		do configFieldType.%Push(obj)

	}
	set customDataSet=[]
	set sql="select * from SQLUSER.CB_CustomDataSet"
	set sqlObj=##class(%SQL.Statement).%New()
	set sc=sqlObj.%Prepare(sql)
	set list=sqlObj.%Execute()
	while list.%Next(){
		set obj={}
		set obj.id=list.%Get("ID")
		set obj.code=list.%Get("Code")
		set obj.descripts=list.%Get("Descripts")
		do customDataSet.%Push(obj)
	}
	set fieldClass=[]
	set sql="select * from SQLUSER.CB_FieldClass"
	set sqlObj=##class(%SQL.Statement).%New()
	set sc=sqlObj.%Prepare(sql)
	set list=sqlObj.%Execute()
	while list.%Next(){
		set obj={}
		set obj.id=list.%Get("ID")
		set obj.code=list.%Get("Code")
		set obj.descripts=list.%Get("Descripts")
		do fieldClass.%Push(obj)
	}
	set resultJson={}
	set resultJson.errorCode="0"
	set resultJson.errorMessage="成功"
	set result={}
	set result.configFieldType=configFieldType
	set result.customDataSet=customDataSet
	set result.fieldClass=fieldClass
	set resultJson.result=result
	Return resultJson
}

/// Creator:     HYG
/// CreatDate:   2024-05-15
/// Description: 查询公共元素集分页
/// Table:     	 CB_ElementField      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.ElementField.CBElementField).FindCBElementField({"params":[{"descripts":"文本"}],"pagination":[{"pageSize":20,"currentPage":1}],"code":"01010042","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"IaQrIr2kTt","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod FindCBElementField(postObj)
{
	new (postObj)
	Set params=postObj.params.%Get(0)
	Set pagination=postObj.pagination.%Get(0)
	Set code=params.code
	Set desc=params.descripts
	set fieldClassID=params.fieldClassID
	Set sqlString="SELECT FieldType_Dr->Code AS fieldTypeCode,FieldType_Dr->Descripts AS fieldTypeDesc,CustomData_Dr->Code AS customDataCode,CustomData_Dr->Descripts as customDataDesc,FieldClass_Dr->Code AS fieldClassCode,FieldClass_Dr->Descripts  AS fieldClassDesc,* FROM CB_ElementField where 1=1"
	set:fieldClassID'="" sqlString=sqlString_" AND FieldClass_Dr = '"_fieldClassID_"'"
	Set:code'="" sqlString=sqlString_" AND Code like '%"_code_"%'"
	Set:desc'="" sqlString=sqlString_" AND Descripts like '%"_desc_"%'"
	Return ##class(src.util.SQLUtil).SqlForList(sqlString,pagination)
}

/// Creator:     HYG
/// CreatDate:   2024-05-15
/// Description: 保存公共元素集
/// Table:     	 CB_ElementField      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug: w ##Class(src.ElementField.CBElementField).AddCBElementField({"params":[{"code":"patNo","descripts":"患者标识","fieldTypeID":"1","customDataID":"","fieldClassID":"1"}],"code":"","session":[{"userID":"158","locID":"","groupID":"","groupDesc":"","hospID":"","sessionID":"","hospCode":"","language":"","deviceID":"DESKTOP-AC3CP6U\\huang","hostName":"DESKTOP-AC3CP6U\\huang","ipv4":"192.168.100.92","ipv6":"fe80::7658:83b6:177a:fc3f%20","mac":"00-FF-D7-3E-BC-5E"}]}).%ToJSON()
ClassMethod AddCBElementField(postObj)
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	Set elementFieldID=jsonObj.elementFieldID
	Set code=jsonObj.code
	Set descripts=jsonObj.descripts
	Set fieldTypeID=jsonObj.fieldTypeID
	Set userID=session.userID
	Set customDataID=jsonObj.customDataID
	Set fieldClassID=jsonObj.fieldClassID

	Try{
		Set json={}
		Set json.className="User.CBElementField"
		set json.updateUserID=userID
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj.ID=elementFieldID
		Set newJsonObj.Code=jsonObj.code
		Set newJsonObj.Descripts=jsonObj.descripts
		Set newJsonObj.FieldTypeDr=jsonObj.fieldTypeID
		Set newJsonObj.CustomDataDr=jsonObj.customDataID
		Set newJsonObj.FieldClassDr=jsonObj.fieldClassID
		Set newJsonObj.Doubt=jsonObj.doubt
		Set newJsonObj.CreateDate=$zd(+$h,3)
		Set newJsonObj.CreateUserDr=userID
		set newJsonObj.CustomDataStr=jsonObj.customDataStr
		do data.%Push(newJsonObj)
		Set json.data=data
		if (elementFieldID'="")
		{
		Set rtn=##class(src.util.operatetable).Update(json)
		}else{
			Set rtn=##class(src.util.operatetable).Insert(json)
		}
		if rtn.errorCode'=0{
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage
			Return resultJson
		}
		Return rtn
	}Catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="保存公共元素集出现问题:w ##class("_$ClassName()_").AddCBElementField("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	    
	}
	
	Return resultJson
}

}
