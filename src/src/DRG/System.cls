Import SQLUSER

/// 系统管理服务类
/// 提供用户管理、角色管理、菜单管理、接口配置等功能
/// 
/// 接口Code规范: 020104xx
Class src.DRG.System Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 查询系统用户列表
/// Code: 02010401
ClassMethod QuerySystemUsers(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params.%Get(0)
    set session = postObj.session.%Get(0)
    
    // 获取参数
    set userCode = $lg(params,1)
    set userName = $lg(params,2)
    set userType = $lg(params,3)
    set deptCode = $lg(params,4)
    set isActive = $lg(params,5)
    set page = $lg(params,6)
    set limit = $lg(params,7)
    
    if (page = "") set page = 1
    if (limit = "") set limit = 20
    
    set dataList = ##class(%Library.DynamicArray).%New()
    
    set sql = "SELECT ID, UserCode, UserName, UserType, DeptDr, DeptName, "_ 
              "Mobile, Email, IsActive, LastLoginDate, LastLoginTime "_ 
              "FROM BS_DRGSystemUser WHERE 1=1"
    
    if (userCode '= "") {
        set sql = sql _ " AND UserCode LIKE '%" _ userCode _ "%'"
    }
    if (userName '= "") {
        set sql = sql _ " AND UserName LIKE '%" _ userName _ "%'"
    }
    if (userType '= "") {
        set sql = sql _ " AND UserType = '" _ userType _ "'"
    }
    if (deptCode '= "") {
        set sql = sql _ " AND DeptDr = '" _ deptCode _ "'"
    }
    if (isActive '= "") {
        set sql = sql _ " AND IsActive = '" _ isActive _ "'"
    }
    
    set sql = sql _ " ORDER BY SeqNo, ID"
    
    set rs = ##class(%ResultSet).%New()
    set rs.Query = sql
    do rs.Execute()
    
    set count = 0
    while (rs.Next()) {
        set count = count + 1
        if ((count > ((page - 1) * limit)) && (count <= (page * limit))) {
            set item = ##class(%Library.DynamicObject).%New()
            set item.id = rs.Data("ID")
            set item.userCode = rs.Data("UserCode")
            set item.userName = rs.Data("UserName")
            set item.userType = rs.Data("UserType")
            set item.deptDr = rs.Data("DeptDr")
            set item.deptName = rs.Data("DeptName")
            set item.mobile = rs.Data("Mobile")
            set item.email = rs.Data("Email")
            set item.isActive = rs.Data("IsActive")
            set item.lastLoginDate = $zd(rs.Data("LastLoginDate"), 3)
            do dataList.%Push(item)
        }
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = dataList
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 保存系统用户
/// Code: 02010402
ClassMethod SaveSystemUser(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params.%Get(0)
    set session = postObj.session.%Get(0)
    
    // 获取参数
    set userId = $lg(params,1)
    set userCode = $lg(params,2)
    set userName = $lg(params,3)
    set password = $lg(params,4)
    set userType = $lg(params,5)
    set deptDr = $lg(params,6)
    set deptName = $lg(params,7)
    set mobile = $lg(params,8)
    set email = $lg(params,9)
    set isActive = $lg(params,10)
    set seqNo = $lg(params,11)
    set userIdSession = $lg(session,1)
    
    // 验证必填参数
    if (userCode = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "用户账号不能为空"
        quit result
    }
    if (userName = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "用户姓名不能为空"
        quit result
    }
    
    // 检查账号是否已存在
    if (userId = "") {
        set existSql = "SELECT ID FROM BS_DRGSystemUser WHERE UserCode = '" _ userCode _ "'"
        set existRs = ##class(%ResultSet).%New()
        set existRs.Query = existSql
        do existRs.Execute()
        if (existRs.Next()) {
            set result.errorCode = "2002"
            set result.errorMessage = "用户账号已存在"
            quit result
        }
    }
    
    // 保存数据
    if (userId = "") {
        // 新增
        set obj = ##class(User.BSDRGSystemUser).%New()
        set obj.CreateDate = +$h
        set obj.CreateTime = $p($h,",",2)
        set obj.CreateUserDr = userIdSession
    } else {
        // 修改
        set obj = ##class(User.BSDRGSystemUser).%OpenId(userId)
    }
    
    set obj.UserCode = userCode
    set obj.UserName = userName
    if (password '= "") {
        set obj.Password = password  // 实际应加密存储
    }
    set obj.UserType = userType
    set obj.DeptDr = deptDr
    set obj.DeptName = deptName
    set obj.Mobile = mobile
    set obj.Email = email
    set obj.IsActive = isActive
    set obj.SeqNo = seqNo
    
    set sc = obj.%Save()
    if ($$$ISOK(sc)) {
        set result.errorCode = "0"
        set result.errorMessage = ""
        set result.result = {"id": (obj.%Id())}
    } else {
        set result.errorCode = "3001"
        set result.errorMessage = "保存失败"
    }
    
    quit result
}

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
/// Description: 获取用户菜单权限
/// Code: 02010408
ClassMethod GetUserMenus(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params.%Get(0)
    set session = postObj.session.%Get(0)
    
    set userId = $lg(session,1)
    
    if (userId = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "用户未登录"
        quit result
    }
    
    // 获取用户角色
    set roleSql = "SELECT RoleDr FROM BS_DRGUserRole WHERE UserDr = " _ userId
    set roleRs = ##class(%ResultSet).%New()
    set roleRs.Query = roleSql
    do roleRs.Execute()
    
    set roleList = ##class(%ListOfDataTypes).%New()
    while (roleRs.Next()) {
        do roleList.Insert(roleRs.Data("RoleDr"))
    }
    
    // 获取角色关联的菜单
    set menuList = ##class(%Library.DynamicArray).%New()
    
    set menuSql = "SELECT DISTINCT m.ID, m.MenuCode, m.MenuName, m.ParentID, m.MenuPath, "_ 
                  "m.MenuIcon, m.Component, m.SeqNo, m.MenuLevel, m.IsLeaf "_ 
                  "FROM BS_DRGRoleMenu rm "_ 
                  "JOIN BS_DRGSystemMenu m ON rm.Menu_Dr = m.ID "_ 
                  "WHERE rm.Role_Dr IN ("_roleList.ToString()_") "_ 
                  "AND rm.CanView = 'Y' AND m.IsActive = 'Y' "_ 
                  "ORDER BY m.SeqNo"
    
    set menuRs = ##class(%ResultSet).%New()
    set menuRs.Query = menuSql
    do menuRs.Execute()
    
    while (menuRs.Next()) {
        set item = ##class(%Library.DynamicObject).%New()
        set item.id = menuRs.Data("ID")
        set item.menuCode = menuRs.Data("MenuCode")
        set item.menuName = menuRs.Data("MenuName")
        set item.parentID = menuRs.Data("ParentID")
        set item.menuPath = menuRs.Data("MenuPath")
        set item.menuIcon = menuRs.Data("MenuIcon")
        set item.component = menuRs.Data("Component")
        set item.menuLevel = menuRs.Data("MenuLevel")
        set item.isLeaf = menuRs.Data("IsLeaf")
        do menuList.%Push(item)
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = menuList
    
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
/// Description: 查询系统角色
/// Code: 02010406
ClassMethod QuerySystemRoles(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params.%Get(0)
    set session = postObj.session.%Get(0)
    
    set roleCode = $lg(params,1)
    set roleName = $lg(params,2)
    set roleType = $lg(params,3)
    set isActive = $lg(params,4)
    
    set dataList = ##class(%Library.DynamicArray).%New()
    
    set sql = "SELECT ID, RoleCode, RoleName, RoleDesc, RoleType, IsActive, SeqNo "_ 
              "FROM BS_DRGSystemRole WHERE 1=1"
    
    if (roleCode '= "") {
        set sql = sql _ " AND RoleCode LIKE '%" _ roleCode _ "%'"
    }
    if (roleName '= "") {
        set sql = sql _ " AND RoleName LIKE '%" _ roleName _ "%'"
    }
    if (roleType '= "") {
        set sql = sql _ " AND RoleType = '" _ roleType _ "'"
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
        set item.roleCode = rs.Data("RoleCode")
        set item.roleName = rs.Data("RoleName")
        set item.roleDesc = rs.Data("RoleDesc")
        set item.roleType = rs.Data("RoleType")
        set item.isActive = rs.Data("IsActive")
        set item.seqNo = rs.Data("SeqNo")
        do dataList.%Push(item)
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = dataList
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 保存系统角色
/// Code: 02010407
ClassMethod SaveSystemRole(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params.%Get(0)
    set session = postObj.session.%Get(0)
    
    set roleId = $lg(params,1)
    set roleCode = $lg(params,2)
    set roleName = $lg(params,3)
    set roleDesc = $lg(params,4)
    set roleType = $lg(params,5)
    set isActive = $lg(params,6)
    set seqNo = $lg(params,7)
    set userId = $lg(session,1)
    
    // 验证必填参数
    if (roleCode = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "角色编码不能为空"
        quit result
    }
    if (roleName = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "角色名称不能为空"
        quit result
    }
    
    // 保存数据
    if (roleId = "") {
        set obj = ##class(User.BSDRGSystemRole).%New()
        set obj.CreateDate = +$h
        set obj.CreateTime = $p($h,",",2)
        set obj.CreateUserDr = userId
    } else {
        set obj = ##class(User.BSDRGSystemRole).%OpenId(roleId)
    }
    
    set obj.RoleCode = roleCode
    set obj.RoleName = roleName
    set obj.RoleDesc = roleDesc
    set obj.RoleType = roleType
    set obj.IsActive = isActive
    set obj.SeqNo = seqNo
    
    set sc = obj.%Save()
    if ($$$ISOK(sc)) {
        set result.errorCode = "0"
        set result.errorMessage = ""
        set result.result = {"id": (obj.%Id())}
    } else {
        set result.errorCode = "3001"
        set result.errorMessage = "保存失败"
    }
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 保存角色菜单权限
/// Code: 02010409
ClassMethod SaveRoleMenu(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params.%Get(0)
    set session = postObj.session.%Get(0)
    
    set roleId = $lg(params,1)
    set menuList = $lg(params,2)  // JSON数组
    set userId = $lg(session,1)
    
    if (roleId = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "角色ID不能为空"
        quit result
    }
    
    // 先删除该角色的所有菜单权限
    &sql(DELETE FROM SQLUser.BS_DRGRoleMenu WHERE Role_Dr = :roleId)
    
    // 重新插入菜单权限
    set count = 0
    if ($isobject(menuList)) {
        for i = 0:1:(menuList.%Size() - 1) {
            set menuItem = menuList.%Get(i)
            set menuId = menuItem.menuId
            set canView = $s(menuItem.canView="Y":"Y", 1:"N")
            set canAdd = $s(menuItem.canAdd="Y":"Y", 1:"N")
            set canEdit = $s(menuItem.canEdit="Y":"Y", 1:"N")
            set canDelete = $s(menuItem.canDelete="Y":"Y", 1:"N")
            set canExport = $s(menuItem.canExport="Y":"Y", 1:"N")
            
            set rm = ##class(User.BSDRGRoleMenu).%New()
            set rm.RoleDr = roleId
            set rm.MenuDr = menuId
            set rm.CanView = canView
            set rm.CanAdd = canAdd
            set rm.CanEdit = canEdit
            set rm.CanDelete = canDelete
            set rm.CanExport = canExport
            set rm.CreateDate = +$h
            set rm.CreateTime = $p($h,",",2)
            set rm.CreateUserDr = userId
            
            do rm.%Save()
            set count = count + 1
        }
    }
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set jo={}
    set jo.savedCount=count
    set result.result = jo
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 用户登录
/// Code: 02010410
ClassMethod UserLogin(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params.%Get(0)
    
    set userCode = $lg(params,1)
    set password = $lg(params,2)
    
    if (userCode = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "用户名不能为空"
        quit result
    }
    if (password = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "密码不能为空"
        quit result
    }
    
    // 查询用户
    set sql = "SELECT ID, UserCode, UserName, Password, UserType, DeptDr, DeptName, IsActive "_ 
              "FROM BS_DRGSystemUser WHERE UserCode = '" _ userCode _ "'"
    
    set rs = ##class(%ResultSet).%New()
    set rs.Query = sql
    do rs.Execute()
    
    if ('rs.Next()) {
        set result.errorCode = "2001"
        set result.errorMessage = "用户不存在"
        quit result
    }
    
    set userId = rs.Data("ID")
    set storedPassword = rs.Data("Password")
    set isActive = rs.Data("IsActive")
    
    if (isActive '= "Y") {
        set result.errorCode = "1003"
        set result.errorMessage = "用户已被禁用"
        quit result
    }
    
    // 验证密码（实际应该加密比较）
    if (password '= storedPassword) {
        set result.errorCode = "1001"
        set result.errorMessage = "密码错误"
        quit result
    }
    
    // 生成会话ID
    set sessionId = $r(16)
    
    // 更新登录信息
    set user = ##class(User.BSDRGSystemUser).%OpenId(userId)
    set user.LastLoginDate = +$h
    set user.LastLoginTime = $p($h,",",2)
    // set user.LastLoginIP = clientIP
    do user.%Save()
    
    // 返回用户信息和菜单
    set userInfo = ##class(%Library.DynamicObject).%New()
    set userInfo.userId = userId
    set userInfo.userCode = rs.Data("UserCode")
    set userInfo.userName = rs.Data("UserName")
    set userInfo.userType = rs.Data("UserType")
    set userInfo.deptDr = rs.Data("DeptDr")
    set userInfo.deptName = rs.Data("DeptName")
    set userInfo.sessionId = sessionId
    
    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = userInfo
    
    quit result
}

/// Creator:     系统
/// CreatDate:   2026-03-19
/// Description: 用户登出
/// Code: 02010411
ClassMethod UserLogout(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)

    set result = ##class(%Library.DynamicObject).%New()

    set result.errorCode = "0"
    set result.errorMessage = ""
    set result.result = {}

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
