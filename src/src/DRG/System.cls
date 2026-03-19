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
    set params = postObj.params
    set session = postObj.session
    
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
    set params = postObj.params
    set session = postObj.session
    
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
    set params = postObj.params
    set session = postObj.session
    
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
    set params = postObj.params
    set session = postObj.session
    
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
ClassMethod QueryInterfaceServices(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    // 获取参数
    set code = $lg(params,1)
    set descriptions = $lg(params,2)
    set className = $lg(params,3)
    set serviceType = $lg(params,4)
    set page = $lg(params,5)
    set limit = $lg(params,6)
    
    if (page = "") set page = 1
    if (limit = "") set limit = 20
    
    set dataList = ##class(%Library.DynamicArray).%New()
    
    set sql = "SELECT ID, Code, Descripts, ClassName, MethodName, "_ 
              "ServiceType, StartDate, StopDate, IsActive "_ 
              "FROM CB_MapInterface WHERE 1=1"
    
    if (code '= "") {
        set sql = sql _ " AND Code LIKE '%" _ code _ "%'"
    }
    if (descriptions '= "") {
        set sql = sql _ " AND Descripts LIKE '%" _ descriptions _ "%'"
    }
    if (className '= "") {
        set sql = sql _ " AND ClassName LIKE '%" _ className _ "%'"
    }
    if (serviceType '= "") {
        set sql = sql _ " AND ServiceType = '" _ serviceType _ "'"
    }
    
    set sql = sql _ " ORDER BY Code"
    
    set rs = ##class(%ResultSet).%New()
    set rs.Query = sql
    do rs.Execute()
    
    set count = 0
    while (rs.Next()) {
        set count = count + 1
        if ((count > ((page - 1) * limit)) && (count <= (page * limit))) {
            set item = ##class(%Library.DynamicObject).%New()
            set item.id = rs.Data("ID")
            set item.code = rs.Data("Code")
            set item.descripts = rs.Data("Descripts")
            set item.className = rs.Data("ClassName")
            set item.methodName = rs.Data("MethodName")
            set item.serviceType = rs.Data("ServiceType")
            set item.startDate = $zd(rs.Data("StartDate"), 3)
            set item.isActive = rs.Data("IsActive")
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
/// Description: 保存接口服务
/// Code: 02010405
ClassMethod SaveInterfaceService(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
    // 获取参数
    set interfaceId = $lg(params,1)
    set code = $lg(params,2)
    set descriptions = $lg(params,3)
    set className = $lg(params,4)
    set methodName = $lg(params,5)
    set serviceType = $lg(params,6)
    set seqNo = $lg(params,7)
    set isActive = $lg(params,8)
    set sessionFlag = $lg(params,9)
    set tokenFlag = $lg(params,10)
    
    // 验证必填参数
    if (code = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "接口代码不能为空"
        quit result
    }
    if (className = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "类名不能为空"
        quit result
    }
    if (methodName = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "方法名不能为空"
        quit result
    }
    
    // 保存数据
    if (interfaceId = "") {
        // 新增
        set obj = ##class(User.CBMapInterface).%New()
    } else {
        // 修改
        set obj = ##class(User.CBMapInterface).%OpenId(interfaceId)
    }
    
    set obj.Code = code
    set obj.Descripts = descriptions
    set obj.ClassName = className
    set obj.MethodName = methodName
    set obj.ServiceType = serviceType
    set obj.SeqNo = seqNo
    set obj.SessionFlag = sessionFlag
    set obj.TokenFlag = tokenFlag
    set obj.IsActive = isActive
    
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
/// Description: 查询系统角色
/// Code: 02010406
ClassMethod QuerySystemRoles(postObj As %Library.DynamicObject) As %Library.DynamicObject
{
    new (postObj)
    
    set result = ##class(%Library.DynamicObject).%New()
    set params = postObj.params
    set session = postObj.session
    
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
    set params = postObj.params
    set session = postObj.session
    
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
    set params = postObj.params
    set session = postObj.session
    
    set roleId = $lg(params,1)
    set menuList = $lg(params,2)  // JSON数组
    set userId = $lg(session,1)
    
    if (roleId = "") {
        set result.errorCode = "1001"
        set result.errorMessage = "角色ID不能为空"
        quit result
    }
    
    // 先删除该角色的所有菜单权限
    &sql(DELETE FROM BS_DRGRoleMenu WHERE Role_Dr = :roleId)
    
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
    set result.result = {"savedCount": count}
    
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
    set params = postObj.params
    
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

}
