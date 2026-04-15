Import SQLUSER

/// 系统管理服务类
/// 提供用户管理、角色管理、菜单管理、接口配置等功能
/// 
/// 接口Code规范: 020104xx
Class src.DRG.System Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询系统菜单
/// Code: 02010403
ClassMethod QuerySystemMenus(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params.%Get(0)
    set session = postObj.session.%Get(0)
    
    // 获取参数
    set menuCode = $lg(params,1)
    set menuName = $lg(params,2)
    set parentID = $lg(params,3)
    set menuType = $lg(params,4)
    set isActive = $lg(params,5)
    
    set dataList = ##class(%Library.DynamicArray).%New()
    
    set sql = "SELECT ID, MenuCode, MenuName, ParentID, MenuPath, MenuIcon, "_ 
              "Component, SeqNo, MenuLevel, IsLeaf, IsActive, IsVisible, MenuType "_ 
              "FROM BS_DRGSystemMenu WHERE 1=1"
    
    if (menuCode '= "") {
        set sql = sql _ " AND MenuCode LIKE '%" _ menuCode _ "%'"
    }
    if (menuName '= "") {
        set sql = sql _ " AND MenuName LIKE '%" _ menuName _ "%'"
    }
    if (parentID '= "") {
        set sql = sql _ " AND ParentID = '" _ parentID _ "'"
    }
    if (menuType '= "") {
        set sql = sql _ " AND MenuType = '" _ menuType _ "'"
    }
    if (isActive '= "") {
        set sql = sql _ " AND IsActive = '" _ isActive _ "'"
    }
    
    set sql = sql _ " ORDER BY SeqNo, ID"
    
    set rs = ##class(%ResultSet).%New()
    set rs.Query = sql
    do rs.Execute()
    
    while (rs.Next()) {
        set item = ##class(%Library.DynamicObject).%New()
        set item.id = rs.Data("ID")
        set item.menuCode = rs.Data("MenuCode")
        set item.menuName = rs.Data("MenuName")
        set item.parentID = rs.Data("ParentID")
        set item.menuPath = rs.Data("MenuPath")
        set item.menuIcon = rs.Data("MenuIcon")
        set item.component = rs.Data("Component")
        set item.seqNo = rs.Data("SeqNo")
        set item.menuLevel = rs.Data("MenuLevel")
        set item.isLeaf = rs.Data("IsLeaf")
        set item.isActive = rs.Data("IsActive")
        set item.isVisible = rs.Data("IsVisible")
        set item.menuType = rs.Data("MenuType")
        do dataList.%Push(item)
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = dataList
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询接口服务列表
/// Code: 02010404
ClassMethod QueryInterfaceServices(jsonObj As %Library.DynamicObject) As %Library.DynamicObject
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
		set compareClassName=params.className
		set compareMethodName=params.methodName
		set status=params.status
		set tStatement = ##class(%SQL.Statement).%New(1)  
		set sql="SELECT ProductCat_Dr->Descripts AS productCatDesc,ProductModule_Dr -> Descripts AS productModuleDesc,RWServiceType_Dr -> Descripts AS rwServiceTypeDesc,* FROM CB_MapInterface"		
		
		set sql=sql_" WHERE 1=1"
		set:(compareCode'="") sql=sql_" and Code LIKE '%"_compareCode_"%'"
		set:(compareDescripts'="") sql=sql_" AND Descripts LIKE '%"_compareDescripts_"%'"
		set:(compareClassName'="") sql=sql_" AND ClassName LIKE '%"_compareClassName_"%'"
		set:(compareMethodName'="") sql=sql_" AND MethodName LIKE '%"_compareMethodName_"%'"
		if (status'="") {
			set:status="1" sql=sql_" AND StartDate <"_(+$h+1)_" and (StopDate is NULL or StopDate >"_+$h_")"
			set:status="0" sql=sql_" AND StartDate >"_(+$h)_" and (StopDate is NULL or StopDate <"_+$h_")"
		}
		b	;111
		set sc=tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.key=result.%Get("ID")
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.className=result.%Get("ClassName")
			set dataObj.methodName=result.%Get("MethodName")
			set dataObj.startDate=result.%Get("StartDate")			
			set dataObj.stopDate=result.%Get("StopDate")
			set dataObj.serviceType=result.%Get("ServiceType")
			set dataObj.productCatID=result.%Get("ProductCat_Dr")
			set dataObj.productCatDesc=result.%Get("productCatDesc")
			set dataObj.productModuleID=result.%Get("ProductModule_Dr")
			set dataObj.productModuleDesc=result.%Get("productModuleDesc")
			set dataObj.seqNo=result.%Get("SeqNo")
			set dataObj.sessionFlag=result.%Get("SessionFlag")
			set dataObj.tokenFlag=result.%Get("TokenFlag")			
			set dataObj.tokenOverTime=result.%Get("TokenOverTime")
			set dataObj.rwServiceTypeID=result.%Get("RWServiceType_Dr")
			set dataObj.rwServiceTypeDesc=result.%Get("rwServiceTypeDesc")
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="获取接口服务配置出错:w ##class("_$ClassName()_").GetInterfaceServiceConfig("_jsonObj.%ToJSON()_")"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")	
	}
	quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 保存接口服务
/// Code: 01010016
ClassMethod SaveInterfaceService(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set dataObj={},dataArr=[]
		set dataObj.ID=params.id
		set dataObj.Key=params.key
		set dataObj.Code=params.code
		set dataObj.Descripts=params.descripts
		set dataObj.ClassName=params.className
		set dataObj.MethodName=params.methodName
		set dataObj.StartDate=params.startDate		
		set dataObj.StopDate=params.stopDate
		set dataObj.ServiceType=params.serviceType
		set dataObj.ProductCatDr=params.productCatID
		set dataObj.ProductModuleDr=params.productModuleID		
		set dataObj.SeqNo=params.seqNo
		set dataObj.ServiceIP=params.serviceIP
		set dataObj.SessionFlag=params.sessionFlag
		set dataObj.TokenFlag=params.tokenFlag		
		set dataObj.TokenOverTime=params.tokenOverTime
		set dataObj.RWServiceTypeDr=params.rwServiceTypeID
		do dataArr.%Push(dataObj)
		;b	;12121
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className="User.CBMapInterface"			
		set operateObj.data=dataArr		
		if params.id=""{
			set rtn=##class(src.util.operatetable).Insert(.operateObj) ;调用公共类方法记录修改日记
		}else{				
			set rtn=##class(src.util.operatetable).Update(.operateObj) ;调用公共类方法记录修改日记
		}
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		if errorCode'="0"{
			set resultObj.errorCode=errorCode
			set resultObj.errorMessage=errorMessage
			quit
		}
		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询接口服务配置下拉数据
/// Code: 01010018
/// 产品分类列表传空，产品模块列表传空
/// 服务类型列表：查询(S)、新增(A)、修改(U)、删除(D)
ClassMethod QueryInterfaceDropdownData(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set resultObj = ##class(%Library.DynamicObject).%New()
    
    // 产品分类列表 - 传空
    set productCats = ##class(%Library.DynamicArray).%New()
    
    // 产品模块列表 - 传空  
    set productModules = ##class(%Library.DynamicArray).%New()
    
    // 服务类型列表
    set serviceTypes = ##class(%Library.DynamicArray).%New()
    
    set item1 = ##class(%Library.DynamicObject).%New()
    set item1.code = "S"
    set item1.name = "查询(S)"
    do serviceTypes.%Push(item1)
    
    set item2 = ##class(%Library.DynamicObject).%New()
    set item2.code = "A"
    set item2.name = "新增(A)"
    do serviceTypes.%Push(item2)
    
    set item3 = ##class(%Library.DynamicObject).%New()
    set item3.code = "U"
    set item3.name = "修改(U)"
    do serviceTypes.%Push(item3)
    
    set item4 = ##class(%Library.DynamicObject).%New()
    set item4.code = "D"
    set item4.name = "删除(D)"
    do serviceTypes.%Push(item4)
    
    set resultObj.productCats = productCats
    set resultObj.productModules = productModules
    set resultObj.serviceTypes = serviceTypes
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = resultObj
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 删除接口服务
/// Code: 02010412
ClassMethod DeleteInterfaceService(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)

    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params.%Get(0)

    set interfaceId = $lg(params,1)

    if (interfaceId = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "接口ID不能为空"
        quit result
    }

    // 检查是否存在
    if '##class(User.CBMapInterface).%ExistsId(interfaceId) {
        set result.errorCode = "2001"
        set result.errorMessage = "接口不存在"
        quit result
    }

    // 删除
    set sc = ##class(User.CBMapInterface).%DeleteId(interfaceId)
    if ($$$ISOK(sc)) {
        set result.errorCode = "0"
        set result.errorMessage = ""
    } else {
        set result.errorCode = "3001"
        set result.errorMessage = "删除失败"
    }

    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 测试接口调用
/// Code: 02010413
ClassMethod TestInterfaceCall(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)

    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params.%Get(0)
    set session = postObj.session.%Get(0)

    set interfaceId = $lg(params,1)
    set testParams = $lg(params,2)  // JSON格式的测试参数

    if (interfaceId = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "接口ID不能为空"
        quit result
    }

    // 获取接口信息
    set interfaceObj = ##class(User.CBMapInterface).%OpenId(interfaceId)
    if (interfaceObj = "") {
        set result.errorCode = "2001"
        set result.errorMessage = "接口不存在"
        quit result
    }

    set className = interfaceObj.ClassName
    set methodName = interfaceObj.MethodName

    // 记录日志
    set logObj = ##class(User.CBMapInterfaceLog).%New()
    set logObj.InterfaceDr = interfaceId
    set logObj.CallDate = +$h
    set logObj.CallTime = $p($h,",",2)
    set logObj.CallUserDr = $lg(session,1)
    set logObj.CallParams = testParams
    set logObj.CallType = "TEST"

    // 调用接口
    set startTime = $p($h,",",2)
    try {
        // 构建调用字符串
        set callStr = "##class("_className_")."_methodName_"(postObj)"
        set responseObj = @callStr

        set endTime = $p($h,",",2)
        set duration = endTime - startTime

        // 记录成功日志
        set logObj.ResponseData = responseObj.%ToJSON()
        set logObj.CallStatus = "SUCCESS"
        set logObj.ResponseTime = duration

        set result.errorCode = "0"
        set result.errorMessage = ""
        set result.result = responseObj
    } catch (e) {
        // 记录失败日志
        set logObj.CallStatus = "FAIL"
        set logObj.ErrorMessage = e.Name

        set result.errorCode = "3001"
        set result.errorMessage = "接口调用失败: " _ e.Name
    }

    do logObj.%Save()
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询接口日志
/// Code: 02010414
ClassMethod QueryInterfaceLogs(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)

    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params.%Get(0)

    set interfaceId = $lg(params,1)
    set callType = $lg(params,2)
    set callStatus = $lg(params,3)
    set startDate = $lg(params,4)
    set endDate = $lg(params,5)
    set page = $lg(params,6)
    set limit = $lg(params,7)

    if (page = "") set page = 1
    if (limit = "") set limit = 20

    set dataList = ##class(%Library.DynamicArray).%New()

    set sql = "SELECT l.ID, l.Interface_Dr, i.Code as InterfaceCode, i.Descripts as InterfaceName, "_ 
              "l.CallDate, l.CallTime, l.CallUserDr, l.CallType, l.CallParams, "_ 
              "l.ResponseData, l.CallStatus, l.ResponseTime, l.ErrorMessage "_ 
              "FROM CB_MapInterfaceLog l "_ 
              "LEFT JOIN CB_MapInterface i ON l.Interface_Dr = i.ID WHERE 1=1"

    if (interfaceId '= "") {
        set sql = sql _ " AND l.Interface_Dr = '" _ interfaceId _ "'"
    }
    if (callType '= "") {
        set sql = sql _ " AND l.CallType = '" _ callType _ "'"
    }
    if (callStatus '= "") {
        set sql = sql _ " AND l.CallStatus = '" _ callStatus _ "'"
    }
    if (startDate '= "") {
        set sql = sql _ " AND l.CallDate >= '" _ startDate _ "'"
    }
    if (endDate '= "") {
        set sql = sql _ " AND l.CallDate <= '" _ endDate _ "'"
    }

    set sql = sql _ " ORDER BY l.CallDate DESC, l.CallTime DESC"

    set rs = ##class(%ResultSet).%New()
    set rs.Query = sql
    do rs.Execute()

    set count = 0
    while (rs.Next()) {
        set count = count + 1
        if ((count > ((page - 1) * limit)) && (count <= (page * limit))) {
            set item = ##class(%Library.DynamicObject).%New()
            set item.id = rs.Data("ID")
            set item.interfaceDr = rs.Data("Interface_Dr")
            set item.interfaceCode = rs.Data("InterfaceCode")
            set item.interfaceName = rs.Data("InterfaceName")
            set item.callDate = $zd(rs.Data("CallDate"), 3)
            set item.callTime = $zt(rs.Data("CallTime"))
            set item.callUserDr = rs.Data("CallUserDr")
            set item.callType = rs.Data("CallType")
            set item.callParams = rs.Data("CallParams")
            set item.responseData = rs.Data("ResponseData")
            set item.callStatus = rs.Data("CallStatus")
            set item.responseTime = rs.Data("ResponseTime")
            set item.errorMessage = rs.Data("ErrorMessage")
            do dataList.%Push(item)
        }
    }

    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = dataList

    quit result
}

}
