Class src.CBTable.TableMain Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

ClassMethod GetFindField(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	set session=jsonObj.session.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetFindField(postParams.%ToJSON(),session.%ToJSON())
}

ClassMethod GetColumnField(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetColumnField(postParams.%ToJSON())
}

/// w ##class(src.CBTable.TableMain).GetTableData({"params":[{"ClassName":"User.CBHospital","FindFieldVal":{},"groupId":"1","hospitalId":"8"}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"","sortOrder":""}],"code":"4003","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"A9xwLV51yU","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]})
ClassMethod GetTableData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	set postPagination=jsonObj.pagination.%Get(0)
	set session=jsonObj.session.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetTableData(postPagination.%ToJSON(),postParams.%ToJSON(),session.%ToJSON())
}

ClassMethod GetEditField(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetEditField(postParams.%ToJSON())
}

/// w ##class(src.CBTable.TableMain).SaveTableData({"params":[{"ClassName":"User.CBFieldClass","userID":"158","Item":{"Code":"BaseInfo","Descripts":"基本信息"}}],"code":"4005","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"iBVe33n1Do","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]})
ClassMethod SaveTableData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).SaveData(postParams.%ToJSON())
}

ClassMethod DeleteTableData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).DeleteData(postParams.%ToJSON())
}

ClassMethod GetItemData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetItemData(postParams.%ToJSON())
}

/// w ##class(src.CBTable.TableMain).TableAdd({"params":[{"Code":"User.HBUndertakingLoc","Descripts":"承接部门","ProductModuleDr":"1","Notes":"","SafeClassificat":"","ColNum":"11","ShortDesc":"","FrequeUse":"N","ID":"","CreateUserDr":"292"}],"code":4011,"session":[{"userID":"292","locID":"338","groupID":"1","hospID":"67","sessionID":"Y0bIM1ySdb","hospCode":"H23","language":"CN","hostName":"DESKTOP-AC3CP6U\\huang","ipv4":"192.168.100.98","ipv6":"fe80::7658:83b6:177a:fc3f%20","mac":"00-FF-D7-3E-BC-5E"}]})
ClassMethod TableAdd(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).Add(postParams.%ToJSON())
}

/// w ##class(src.CBTable.TableMain).GetSelectData({"params":[{"ClassName":"User.HBUndertakingLoc","groupId":"1","hospitalId":"8"}],"code":"4007","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"Tcgycavk1O","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]})
ClassMethod GetSelectData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	set session=jsonObj.session.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetSelectData(postParams.%ToJSON(),session.%ToJSON())
}

ClassMethod GetTableFieldData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetTableFieldData(postParams.%ToJSON())
}

ClassMethod SaveFieldSort(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).SaveFieldSort(postParams.%ToJSON())
}

ClassMethod GetClassData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	set postPagination=jsonObj.pagination.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetClassData(postPagination.%ToJSON(),postParams.%ToJSON())
}

ClassMethod GetTableItem(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetTableItem(postParams.%ToJSON())
}

ClassMethod GetBasicClassData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetBasicClassData(postParams.%ToJSON())
}

/// w ##class(src.CBTable.TableMain).GetLinkTableData({"params":[{"ClassName":"User.CBBasicDictionary"}],"code":"4014","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"IaQrIr2kTt","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]})
ClassMethod GetLinkTableData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetLinkTableData(postParams.%ToJSON())
}

ClassMethod SaveDataLink(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableFieldExt).SaveDataLink(postParams.%ToJSON())
}

ClassMethod GetDataByRefId(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	set postPagination=jsonObj.pagination.%Get(0)
	Quit ##class(src.CBTable.CBTableFieldExt).GetDataByRefId(postPagination.%ToJSON(),postParams.%ToJSON())
}

ClassMethod GetItemDataRef(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableFieldExt).GetItemData(postParams.%ToJSON())
}

ClassMethod DeleteItemDataRef(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableFieldExt).DeleteItemData(postParams.%ToJSON())
}

/// w ##class().CheckTableEditFlag()
ClassMethod CheckTableEditFlag(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	s resStr=##class(src.CBTable.CBTableData).CheckTableEditFlag(postParams.ClassName)
	s resultJson={}
	s resultJson.errorCode=$p(resStr,"^",1)
	s resultJson.errorMessage=$p(resStr,"^",2)
	Quit resultJson
}

ClassMethod GetOperateAuth(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableFieldExt).GetOperateAuth(postParams.%ToJSON())
}

ClassMethod GetAuthCBData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetAuthCBData(postParams.%ToJSON())
}

ClassMethod GetFormData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetFormData()
}

ClassMethod GetClassConfigData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.Public).GetClassData(postParams.%ToJSON())
}

ClassMethod GetConfigColumnField(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.Public).GetColumnField(postParams.%ToJSON())
}

ClassMethod GetConfigTableData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.Public).GetTableData(postParams.%ToJSON())
}

ClassMethod ImportTableData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.TableDataImport).ImportData(postParams.%ToJSON())
}

ClassMethod UpdateTableField(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableFieldExt).UpdateTableField(postParams.%ToJSON())
}

ClassMethod CreateSelectMethod(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableFieldExt).CreateSelectMethod(postParams.className)
}

ClassMethod GetFrequeUseClass(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetFrequeUseClass()
}

ClassMethod SendMessage(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.OrderMessage).SendMessage(postParams.%ToJSON())
}

ClassMethod GetFriend(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.OrderMessage).GetFriend(postParams.%ToJSON())
}

ClassMethod CreateGetDataMethod(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableFieldExt).CreateGetDataMethod(postParams.className)
}

ClassMethod GetExportTableData(ByRef jsonObj As %String)
{
	set postParams=jsonObj.params.%Get(0)
	Quit ##class(src.CBTable.CBTableData).GetExportTableData(postParams)
}

/// w ##class(src.CBTable.TableMain).Test()
ClassMethod Test(Arg1 As %String)
{
	 s str=	^XYSRESTMAP(20190301,4470,142923,"INPUT")
	/*s params={}
	s params.ClassName="User.CBMenuDetail"
	s a={"code":4004}
	s a.params=[]
	do a.params.%Push(params)*/
	s a=##class(%Library.DynamicObject).%FromJSON(str)
	s ret=##class(src.Rest.Interface).postMutipleParams(.a,"TableMain")
	quit ret
}

ClassMethod GetALLTable(ByRef jsonObj As %String)
{
	Quit ##class(src.CBTable.CBTableData).GetALLTable()
}

}
