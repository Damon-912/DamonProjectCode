Import SQLUSER

/// Menu接口服务实现类
/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 提供菜单管理的业务逻辑实现
Class src.Menu.Service Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock, Not SqlRowIdPrivate ]
{

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 获取菜单树形结构
ClassMethod GetMenuTree(postObj) As %Library.DynamicObject
{
	new (postObj)
	set retObj={}
	try {
		set errorCode=0,errorMessage="成功",data=[]
		
		// 查询所有未删除的一级菜单，包含ID字段
		&sql(DECLARE MenuCursor CURSOR FOR
			SELECT ID, Code, Descripts, ParentCode, MenuLevel, SortNo, Icon, RoutePath, IsVisible, IsActive
			INTO :id, :code, :descripts, :parentCode, :menuLevel, :sortNo, :icon, :routePath, :isVisible, :isActive
			FROM CB_Menu 
			WHERE Deleted = 0 AND (ParentCode = '' OR ParentCode IS NULL)
			ORDER BY SortNo)
		
		&sql(OPEN MenuCursor)
		while (1) {
			&sql(FETCH MenuCursor)
			quit:SQLCODE
			
			set menuItem={}
			set menuItem.id=id                           // 添加ID字段
			set menuItem.key=code                         // 使用code作为key（兼容前端）
			set menuItem.code=code
			set menuItem.label=descripts
			set menuItem.parentCode=parentCode
			set menuItem.menuLevel=menuLevel
			set menuItem.sortNo=sortNo
			set menuItem.icon=icon
			set menuItem.routePath=routePath
			set menuItem.isVisible=isVisible
			set menuItem.isActive=isActive
			
			// 获取子菜单
			set menuItem.children=..GetChildMenus(code)
			
			do data.%Push(menuItem)
		}
		&sql(CLOSE MenuCursor)
		
		set retObj.errorCode=errorCode
		set retObj.errorMessage=errorMessage
		set retObj.result=data  // 改为result格式，兼容前端
	}catch(e){
		set errorCode=-1
		set errorMessage=$System.Status.GetErrorText(e.AsStatus(),"cn")
		set retObj.errorCode=errorCode
		set retObj.errorMessage=errorMessage
	}
	quit retObj
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 获取子菜单
ClassMethod GetChildMenus(parentCode) As %Library.DynamicArray [ Private ]
{
	new (parentCode)
	set children=[]
	
	&sql(DECLARE ChildCursor CURSOR FOR
		SELECT ID, Code, Descripts, ParentCode, MenuLevel, SortNo, Icon, RoutePath, IsVisible, IsActive
		INTO :id, :code, :descripts, :parentCode, :menuLevel, :sortNo, :icon, :routePath, :isVisible, :isActive
		FROM CB_Menu 
		WHERE Deleted = 0 AND ParentCode = :parentCode
		ORDER BY SortNo)
	
	&sql(OPEN ChildCursor)
	while (1) {
		&sql(FETCH ChildCursor)
		quit:SQLCODE
		
		set menuItem={}
		set menuItem.id=id                           // 添加ID字段
		set menuItem.key=code                         // 使用code作为key
		set menuItem.code=code
		set menuItem.label=descripts
		set menuItem.parentCode=parentCode
		set menuItem.menuLevel=menuLevel
		set menuItem.sortNo=sortNo
		set menuItem.icon=icon
		set menuItem.routePath=routePath
		set menuItem.isVisible=isVisible
		set menuItem.isActive=isActive
		
		// 递归获取子菜单
		set menuItem.children=..GetChildMenus(code)
		
		do children.%Push(menuItem)
	}
	&sql(CLOSE ChildCursor)
	
	quit children
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 保存菜单(新增/修改) - 使用operatetable模式
ClassMethod SaveMenu(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultJson={}
	set resultJson.errorCode=0
	set resultJson.errorMessage=""
	
	try {
		// 解析参数
		Set params=postObj.params.%Get(0)
		Set session=postObj.session.%Get(0)
		Set userID=session.userID
		
		Set menuCode=params.code
		Set menuID=params.menuID
		Set descriptions=params.label
		Set parentCode=params.parentCode
		Set menuLevel=params.menuLevel
		Set sortNo=params.sortNo
		Set icon=params.icon
		Set routePath=params.routePath
		Set isVisible=params.isVisible
		Set isActive=params.isActive
		
		// 如果menuID为空，则检查code是否已存在
		if menuID="" {
			&sql(SELECT ID INTO :menuID FROM CB_Menu WHERE Code = :menuCode)
		}
		
		// 构建operatetable格式的json
		Set json={}
		Set json.className="User.CBMenu"
		Set json.updateUserID=userID
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj.ID=menuID
		Set:menuID="" newJsonObj.Code=menuCode
		Set newJsonObj.Descripts=descriptions
		Set newJsonObj.ENDescripts=descriptions  // 英文描述
		Set newJsonObj.ParentCode=parentCode
		Set newJsonObj.MenuLevel=menuLevel
		Set newJsonObj.SortNo=sortNo
		Set newJsonObj.Icon=icon
		Set newJsonObj.RoutePath=routePath
		Set newJsonObj.IsVisible=isVisible
		Set newJsonObj.IsActive=isActive
		Set:menuID="" newJsonObj.StartDate=+$h     // %Date类型
		Set:menuID="" newJsonObj.CreateDate=+$h    // %Date类型
		Set:menuID="" newJsonObj.Deleted=0
		do data.%Push(newJsonObj)
		Set json.data=data
		
		// 执行插入或更新
		if menuID="" {
			Set rtn=##class(src.util.operatetable).Insert(json)
		} else {
			Set rtn=##class(src.util.operatetable).Update(json)
		}
		
		if rtn.errorCode'=0 {
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage
		} else {
			Set resultJson.errorCode=0
			Set resultJson.errorMessage="保存菜单成功"
		}
		
	} catch(e) {
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set resultJson.errorCode=errorCode
		set resultJson.errorMessage=errorMessage
	}
	
	quit resultJson
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 删除菜单(逻辑删除) - 使用operatetable模式
ClassMethod DeleteMenu(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultJson={}
	set resultJson.errorCode=0
	set resultJson.errorMessage=""
	
	try {
		// 解析参数
		Set params=postObj.params.%Get(0)
		Set session=postObj.session.%Get(0)
		Set userID=session.userID
		
		Set menuCode=params.code
		
		// 查找菜单ID
		&sql(SELECT ID INTO :menuID FROM CB_Menu WHERE Code = :menuCode)
		
		if menuID="" {
			set resultJson.errorCode=-1
			set resultJson.errorMessage="菜单不存在"
			quit
		}
		
		// 构建operatetable格式的json
		Set json={}
		Set json.className="User.CBMenu"
		Set json.updateUserID=userID
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj.ID=menuID
		do data.%Push(newJsonObj)
		Set json.data=data
		
		// 执行删除
		Set rtn=##class(src.util.operatetable).Delete(json)
		
		if rtn.errorCode'=0 {
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage
		} else {
			Set resultJson.errorCode=0
			Set resultJson.errorMessage="删除菜单成功"
		}
		
	} catch(e) {
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set resultJson.errorCode=errorCode
		set resultJson.errorMessage=errorMessage
	}
	
	quit resultJson
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 初始化默认菜单(从App.tsx导入) - 使用operatetable模式
ClassMethod InitDefaultMenus(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultJson={}
	set resultJson.errorCode=0
	set resultJson.errorMessage=""
	
	try {
		// 解析session
		Set session=postObj.session.%Get(0)
		Set userID=session.userID
		
		// 默认菜单数据(从App.tsx的menuItems导入)
		set menus=[
			{"code":"dashboard","label":"监控仪表盘","parentCode":"","menuLevel":1,"sortNo":1,"icon":"DashboardOutlined","routePath":"/dashboard","isVisible":"Y","isActive":"Y"},
			{"code":"drg","label":"DRG业务","parentCode":"","menuLevel":1,"sortNo":2,"icon":"PartitionOutlined","routePath":"","isVisible":"Y","isActive":"Y"},
			{"code":"drg-workbench","label":"分组工作台","parentCode":"drg","menuLevel":2,"sortNo":1,"icon":"","routePath":"/drg/workbench","isVisible":"Y","isActive":"Y"},
			{"code":"drg-custom-query","label":"DRG分组器","parentCode":"drg","menuLevel":2,"sortNo":2,"icon":"","routePath":"/drg/custom-query","isVisible":"Y","isActive":"Y"},
			{"code":"drg-results","label":"分组结果查询","parentCode":"drg","menuLevel":2,"sortNo":3,"icon":"","routePath":"/drg/results","isVisible":"Y","isActive":"Y"},
			{"code":"drg-batch","label":"批量分组任务","parentCode":"drg","menuLevel":2,"sortNo":4,"icon":"","routePath":"/drg/batch","isVisible":"Y","isActive":"Y"},
			{"code":"dip","label":"DIP业务","parentCode":"","menuLevel":1,"sortNo":3,"icon":"MedicineBoxOutlined","routePath":"","isVisible":"Y","isActive":"Y"},
			{"code":"dip-workbench","label":"DIP分组工作台","parentCode":"dip","menuLevel":2,"sortNo":1,"icon":"","routePath":"/dip/workbench","isVisible":"Y","isActive":"Y"},
			{"code":"dip-values","label":"病种分值查询","parentCode":"dip","menuLevel":2,"sortNo":2,"icon":"","routePath":"/dip/values","isVisible":"Y","isActive":"Y"},
			{"code":"dip-analysis","label":"分值偏差分析","parentCode":"dip","menuLevel":2,"sortNo":3,"icon":"","routePath":"/dip/analysis","isVisible":"Y","isActive":"Y"},
			{"code":"warning","label":"费用预警","parentCode":"","menuLevel":1,"sortNo":4,"icon":"AlertOutlined","routePath":"","isVisible":"Y","isActive":"Y"},
			{"code":"warning-monitor","label":"预警监控中心","parentCode":"warning","menuLevel":2,"sortNo":1,"icon":"","routePath":"/warning/monitor","isVisible":"Y","isActive":"Y"},
			{"code":"warning-rules","label":"预警规则配置","parentCode":"warning","menuLevel":2,"sortNo":2,"icon":"","routePath":"/warning/rules","isVisible":"Y","isActive":"Y"},
			{"code":"warning-records","label":"预警处理记录","parentCode":"warning","menuLevel":2,"sortNo":3,"icon":"","routePath":"/warning/records","isVisible":"Y","isActive":"Y"},
			{"code":"profit","label":"盈亏分析","parentCode":"","menuLevel":1,"sortNo":5,"icon":"DollarOutlined","routePath":"","isVisible":"Y","isActive":"Y"},
			{"code":"profit-dept","label":"科室盈亏报表","parentCode":"profit","menuLevel":2,"sortNo":1,"icon":"","routePath":"/profit/dept","isVisible":"Y","isActive":"Y"},
			{"code":"profit-doctor","label":"医生盈亏分析","parentCode":"profit","menuLevel":2,"sortNo":2,"icon":"","routePath":"/profit/doctor","isVisible":"Y","isActive":"Y"},
			{"code":"profit-disease","label":"病种盈亏统计","parentCode":"profit","menuLevel":2,"sortNo":3,"icon":"","routePath":"/profit/disease","isVisible":"Y","isActive":"Y"},
			{"code":"profit-structure","label":"费用结构分析","parentCode":"profit","menuLevel":2,"sortNo":4,"icon":"","routePath":"/profit/structure","isVisible":"Y","isActive":"Y"},
			{"code":"qc","label":"病案质控","parentCode":"","menuLevel":1,"sortNo":6,"icon":"FileTextOutlined","routePath":"","isVisible":"Y","isActive":"Y"},
			{"code":"qc-center","label":"质控检查中心","parentCode":"qc","menuLevel":2,"sortNo":1,"icon":"","routePath":"/qc/center","isVisible":"Y","isActive":"Y"},
			{"code":"qc-issues","label":"质控问题列表","parentCode":"qc","menuLevel":2,"sortNo":2,"icon":"","routePath":"/qc/issues","isVisible":"Y","isActive":"Y"},
			{"code":"qc-stats","label":"质控统计报表","parentCode":"qc","menuLevel":2,"sortNo":3,"icon":"","routePath":"/qc/stats","isVisible":"Y","isActive":"Y"},
			{"code":"data","label":"HIS数据","parentCode":"","menuLevel":1,"sortNo":7,"icon":"DatabaseOutlined","routePath":"","isVisible":"Y","isActive":"Y"},
			{"code":"data-records","label":"病案数据查询","parentCode":"data","menuLevel":2,"sortNo":1,"icon":"","routePath":"/data/records","isVisible":"Y","isActive":"Y"},
			{"code":"data-settlement","label":"结算清单管理","parentCode":"data","menuLevel":2,"sortNo":2,"icon":"","routePath":"/data/settlement","isVisible":"Y","isActive":"Y"},
			{"code":"data-sync","label":"数据同步监控","parentCode":"data","menuLevel":2,"sortNo":3,"icon":"","routePath":"/data/sync","isVisible":"Y","isActive":"Y"},
			{"code":"basic-data","label":"数据管理","parentCode":"","menuLevel":1,"sortNo":8,"icon":"TableOutlined","routePath":"","isVisible":"Y","isActive":"Y"},
			{"code":"basic-data-dict","label":"DRG基础数据","parentCode":"basic-data","menuLevel":2,"sortNo":1,"icon":"","routePath":"/basic-data/dict","isVisible":"Y","isActive":"Y"},
			{"code":"basic-data-icd-mapping","label":"ICD编码映射","parentCode":"basic-data","menuLevel":2,"sortNo":2,"icon":"","routePath":"/basic-data/icd-mapping","isVisible":"Y","isActive":"Y"},
			{"code":"basic-data-icd-query","label":"ICD编码查询","parentCode":"basic-data","menuLevel":2,"sortNo":3,"icon":"","routePath":"/basic-data/icd-query","isVisible":"Y","isActive":"Y"},
			{"code":"basic-data-adrg-rules","label":"ADRG分组规则","parentCode":"basic-data","menuLevel":2,"sortNo":4,"icon":"","routePath":"/basic-data/adrg-rules","isVisible":"Y","isActive":"Y"},
			{"code":"basic-data-core-algorithm","label":"DRG算法配置","parentCode":"basic-data","menuLevel":2,"sortNo":5,"icon":"","routePath":"/basic-data/core-algorithm","isVisible":"Y","isActive":"Y"},
			{"code":"basic-data-dip","label":"DIP付费病种库","parentCode":"basic-data","menuLevel":2,"sortNo":6,"icon":"","routePath":"/basic-data/dip","isVisible":"Y","isActive":"Y"},
			{"code":"basic-data-drg-catalog","label":"DRGs目录信息表","parentCode":"basic-data","menuLevel":2,"sortNo":7,"icon":"","routePath":"/basic-data/drg-catalog","isVisible":"Y","isActive":"Y"},
			{"code":"basic-data-segmentation-rules","label":"ADRG细分规则表","parentCode":"basic-data","menuLevel":2,"sortNo":8,"icon":"","routePath":"/basic-data/segmentation-rules","isVisible":"Y","isActive":"Y"},
			{"code":"user","label":"用户管理","parentCode":"","menuLevel":1,"sortNo":9,"icon":"UserOutlined","routePath":"","isVisible":"Y","isActive":"Y"},
			{"code":"system-user","label":"用户管理","parentCode":"user","menuLevel":2,"sortNo":1,"icon":"","routePath":"/system/user","isVisible":"Y","isActive":"Y"},
			{"code":"system-role-manage","label":"角色管理","parentCode":"user","menuLevel":2,"sortNo":2,"icon":"","routePath":"/system/role-manage","isVisible":"Y","isActive":"Y"},
			{"code":"system-role","label":"角色权限","parentCode":"user","menuLevel":2,"sortNo":3,"icon":"","routePath":"/system/role","isVisible":"Y","isActive":"Y"},
			{"code":"system-menu","label":"菜单配置","parentCode":"user","menuLevel":2,"sortNo":4,"icon":"","routePath":"/system/menu","isVisible":"Y","isActive":"Y"},
			{"code":"system","label":"系统管理","parentCode":"","menuLevel":1,"sortNo":10,"icon":"SafetyOutlined","routePath":"","isVisible":"Y","isActive":"Y"},
			{"code":"system-hospital","label":"医疗机构管理","parentCode":"system","menuLevel":2,"sortNo":1,"icon":"","routePath":"/system/hospital","isVisible":"Y","isActive":"Y"},
			{"code":"system-api","label":"接口服务配置","parentCode":"system","menuLevel":2,"sortNo":2,"icon":"","routePath":"/system/api","isVisible":"Y","isActive":"Y"},
			{"code":"system-logs","label":"接口日志","parentCode":"system","menuLevel":2,"sortNo":3,"icon":"","routePath":"/system/logs","isVisible":"Y","isActive":"Y"}
		]
		
		set errorCount=0
		set successCount=0
		
		// 批量插入菜单
		for i=0:1:menus.%Size()-1 {
			set menu=menus.%Get(i)
			set menuCode=menu.code
			
			// 检查是否已存在
			&sql(SELECT ID INTO :menuID FROM CB_Menu WHERE Code = :menuCode)
			
			continue:menuID'=""
			
			// 安全获取属性
			set mLabel=menu.label
			set mParent=""
			if menu.%IsDefined("parentCode") {
				set mParent=menu.parentCode
			}
			set mLevel=1
			if menu.%IsDefined("menuLevel") {
				set mLevel=menu.menuLevel
			}
			set mSort=1
			if menu.%IsDefined("sortNo") {
				set mSort=menu.sortNo
			}
			set mIcon=""
			if menu.%IsDefined("icon") {
				set mIcon=menu.icon
			}
			set mPath=""
			if menu.%IsDefined("routePath") {
				set mPath=menu.routePath
			}
			set mVisible="Y"
			if menu.%IsDefined("isVisible") {
				set mVisible=menu.isVisible
			}
			set mActive="Y"
			if menu.%IsDefined("isActive") {
				set mActive=menu.isActive
			}
			
			// 构建operatetable格式的json
			Set json={}
			Set json.className="User.CBMenu"
			Set json.updateUserID=userID
			
			Set data=[]
			Set newJsonObj={}
			Set newJsonObj.Code=menuCode
			Set newJsonObj.Descripts=mLabel
			Set newJsonObj.ENDescripts=mLabel  // 英文描述与中文相同
			Set newJsonObj.ParentCode=mParent
			Set newJsonObj.MenuLevel=mLevel
			Set newJsonObj.SortNo=mSort
			Set newJsonObj.Icon=mIcon
			Set newJsonObj.RoutePath=mPath
			Set newJsonObj.IsVisible=mVisible
			Set newJsonObj.IsActive=mActive
			Set newJsonObj.Deleted=0
			Set newJsonObj.StartDate=+$h     // %Date类型需要horolog整数值
			Set newJsonObj.CreateDate=+$h     // %Date类型需要horolog整数值
			// 注意: CreateUserDr 是外键引用，暂时不设置，使用表默认值
			do data.%Push(newJsonObj)
			Set json.data=data
			
			// 执行插入
			Set rtn=##class(src.util.operatetable).Insert(json)
			
			
			if rtn.errorCode=0 {
				set successCount=successCount+1
			} else {
				set errorCount=errorCount+1
			}
		}
		
		if errorCount>0 {
			set resultJson.errorCode=-1
			set resultJson.errorMessage="初始化菜单失败,成功"_successCount_"条,失败"_errorCount_"条"
		} else {
			set resultJson.errorCode=0
			set resultJson.errorMessage="初始化菜单成功,共"_successCount_"条"
		}
		
	} catch(e) {
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set resultJson.errorCode=errorCode
		set resultJson.errorMessage=errorMessage
	}
	
	quit resultJson
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 获取角色菜单权限(从CB_GroupMenu)
ClassMethod GetRoleMenus(postObj) As %Library.DynamicObject
{
	new (postObj)
	set retObj={}
	try {
		set errorCode=0,errorMessage="成功",data=[]
		
		set roleCode=postObj.roleCode
		
		&sql(DECLARE RoleMenuCursor CURSOR FOR
			SELECT MD.Code INTO :menuCode
			FROM CB_GroupMenu GM
			JOIN CB_Menu MD ON GM.Menu_Dr = MD.ID
			WHERE GM.Group_Dr = :roleCode)
		
		&sql(OPEN RoleMenuCursor)
		while (1) {
			&sql(FETCH RoleMenuCursor)
			quit:SQLCODE
			
			do data.%Push(menuCode)
		}
		&sql(CLOSE RoleMenuCursor)
		
		set retObj.errorCode=errorCode
		set retObj.errorMessage=errorMessage
		set retObj.data=data
	}catch(e){
		set errorCode=-1
		set errorMessage=$System.Status.GetErrorText(e.AsStatus(),"cn")
		set retObj.errorCode=errorCode
		set retObj.errorMessage=errorMessage
	}
	quit retObj
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 保存角色菜单权限(到CB_GroupMenu) - 使用operatetable模式
ClassMethod SaveRoleMenus(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultJson={}
	set resultJson.errorCode=0
	set resultJson.errorMessage=""
	
	try {
		// 解析参数
		Set params=postObj.params.%Get(0)
		Set session=postObj.session.%Get(0)
		Set userID=session.userID
		
		Set roleCode=params.roleCode
		Set menuCodes=params.menuCodes
		
		// 先删除该角色现有的菜单权限
		&sql(DELETE FROM CB_GroupMenu WHERE Group_Dr = :roleCode)
		
		// 批量插入新的菜单权限
		for i=0:1:menuCodes.%Size()-1 {
			set menuCode=menuCodes.%Get(i)
			
			// 先通过menuCode获取MenuDetail_Dr
			&sql(SELECT ID INTO :menuDetailDr FROM CB_MenuDetail WHERE Code = :menuCode)
			continue:menuDetailDr=""
			
			// 构建operatetable格式的json
			Set json={}
			Set json.className="User.CBGroupMenu"
			Set json.updateUserID=userID
			Set data=[]
			Set newJsonObj={}
			Set newJsonObj.GroupDr=roleCode
			Set newJsonObj.MenuDetailDr=menuDetailDr
			Set newJsonObj.Type="1"
			Set newJsonObj.CreateDate=+$h      // %Date类型
			Set:userID'="" newJsonObj.CreateUserDr=userID  // 创建用户必填
			do data.%Push(newJsonObj)
			Set json.data=data
			
			// 执行插入
			Set rtn=##class(src.util.operatetable).Insert(json)
			if rtn.errorCode'=0 {
				set resultJson.errorCode=rtn.errorCode
				set resultJson.errorMessage=rtn.errorMessage
				quit
			}
		}
		
		if resultJson.errorCode=0 {
			set resultJson.errorMessage="保存角色菜单权限成功"
		}
		
	} catch(e) {
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set resultJson.errorCode=errorCode
		set resultJson.errorMessage=errorMessage
	}
	
	quit resultJson
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 获取用户菜单(根据用户角色获取)
ClassMethod GetUserMenus(postObj) As %Library.DynamicObject
{
	new (postObj)
	set retObj={}
	try {
		set errorCode=0,errorMessage="成功",data=[]
		
		set userCode=postObj.userCode
		
		// 获取用户角色(从HBUserLogonLoc获取默认角色)
		set roleCode=""
		&sql(SELECT TOP 1 Group_Dr INTO :roleCode FROM HB_UserLogonLoc WHERE User_Dr->Code = :userCode AND IsDefault = 'Y')
		
		if roleCode'="" {
			// 获取该角色的菜单权限
			set roleMenuObj={}
			set roleMenuObj.roleCode=roleCode
			set roleMenuList=..GetRoleMenus(roleMenuObj)
			
			set menuCodes=roleMenuList.data
			
			// 获取菜单详情
			for i=0:1:menuCodes.%Size()-1 {
				set menuCode=menuCodes.%Get(i)
				
				&sql(SELECT Code, Descripts, ParentCode, MenuLevel, SortNo, Icon, RoutePath, IsVisible, IsActive
					INTO :code, :descripts, :parentCode, :menuLevel, :sortNo, :icon, :routePath, :isVisible, :isActive
					FROM CB_Menu WHERE Code = :menuCode AND Deleted = 0)
				
				if SQLCODE=0 {
					set menuItem={}
					set menuItem.code=code
					set menuItem.label=descripts
					set menuItem.parentCode=parentCode
					set menuItem.menuLevel=menuLevel
					set menuItem.sortNo=sortNo
					set menuItem.icon=icon
					set menuItem.routePath=routePath
					set menuItem.isVisible=isVisible
					set menuItem.isActive=isActive
					
					// 获取子菜单
					set menuItem.children=..GetUserChildMenus(code,menuCodes)
					
					do data.%Push(menuItem)
				}
			}
		}
		
		set retObj.errorCode=errorCode
		set retObj.errorMessage=errorMessage
		set retObj.data=data
	}catch(e){
		set errorCode=-1
		set errorMessage=$System.Status.GetErrorText(e.AsStatus(),"cn")
		set retObj.errorCode=errorCode
		set retObj.errorMessage=errorMessage
	}
	quit retObj
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 获取用户子菜单
ClassMethod GetUserChildMenus(parentCode, ByRef menuCodes) As %Library.DynamicArray [ Private ]
{
	new (parentCode)
	set children=[]
	
	for i=0:1:menuCodes.%Size()-1 {
		set menuCode=menuCodes.%Get(i)
		
		&sql(SELECT Code, Descripts, ParentCode, MenuLevel, SortNo, Icon, RoutePath, IsVisible, IsActive
			INTO :code, :descripts, :parentCode, :menuLevel, :sortNo, :icon, :routePath, :isVisible, :isActive
			FROM CB_Menu WHERE Code = :menuCode AND ParentCode = :parentCode AND Deleted = 0)
		
		if SQLCODE=0 {
			set menuItem={}
			set menuItem.code=code
			set menuItem.label=descripts
			set menuItem.parentCode=parentCode
			set menuItem.menuLevel=menuLevel
			set menuItem.sortNo=sortNo
			set menuItem.icon=icon
			set menuItem.routePath=routePath
			set menuItem.isVisible=isVisible
			set menuItem.isActive=isActive
			
			set menuItem.children=..GetUserChildMenus(code,.menuCodes)
			
			do children.%Push(menuItem)
		}
	}
	
	quit children
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 获取用户菜单(根据角色GroupID获取，整合现有CBGroupMenu和CBMenuDetail表)
ClassMethod GetUserMenusByGroup(postObj) As %Library.DynamicArray
{
	new (postObj)
	set data=[]
	try {
		set groupID=postObj.groupID
		set userCode=postObj.userCode
		
		// 如果没有groupID，尝试从HBUserLogonLoc获取默认角色
		if groupID="" {
			&sql(SELECT Group_Dr INTO :groupID 
				 FROM HB_UserLogonLoc 
				 WHERE User_Dr->Code = :userCode AND IsDefault = 'Y')
		}
		
		if groupID="" {
			quit 
		}
		
		// 从CBGroupMenu获取该角色的菜单列表(关联CBMenu获取菜单详情)
		&sql(DECLARE UserMenuCursor CURSOR FOR
			SELECT MD.Code, MD.Descripts, GM.Group_Dr, MD.Icon, MD.SortNo, MD.RoutePath, MD.MenuLevel, MD.ParentCode
			INTO :code, :descripts, :menuGroup, :image, :seqNo, :linkAddress, :mainMenuDr, :parentCode
			FROM CB_GroupMenu GM
			JOIN CB_Menu MD ON GM.Menu_Dr = MD.ID
			WHERE MD.IsActive='Y' AND GM.Group_Dr = :groupID
			ORDER BY MD.SortNo)
		
		&sql(OPEN UserMenuCursor)
		while (1) {
			&sql(FETCH UserMenuCursor)
			quit:SQLCODE
			
			set menuItem={}
			set menuItem.key=code
			set menuItem.code=code
			set menuItem.label=descripts
			set menuItem.icon=image
			set menuItem.seqNo=seqNo
			set menuItem.linkAddress=linkAddress
			set menuItem.menuGroup=menuGroup
			set menuItem.mainMenuDr=mainMenuDr
			set menuItem.parentCode=parentCode  // 添加 parentCode 字段，用于前端关联父子菜单
			
			do data.%Push(menuItem)
		}
		&sql(CLOSE UserMenuCursor)
		
	}catch(e){
		// 出错时返回空数组
	}
	quit data
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 获取菜单树形结构(从现有CBMenuDetail表)
ClassMethod GetMenuTreeFromDetail(postObj) As %Library.DynamicObject
{
	new (postObj)
	set retObj={}
	try {
		set errorCode=0,errorMessage="成功",data=[]
		
		// 查询所有一级菜单(MenuGroup='Y'且没有父级)
		&sql(DECLARE MenuDetailCursor CURSOR FOR
			SELECT ID, Code, Descripts, MenuGroup, Image, SeqNo, LinkAddress, LinkPath, MainMenu_Dr
			INTO :id, :code, :descripts, :menuGroup, :image, :seqNo, :linkAddress, :linkPath, :mainMenuDr
			FROM CB_MenuDetail 
			WHERE MenuGroup = 'Y'
			ORDER BY SeqNo)
		
		&sql(OPEN MenuDetailCursor)
		while (1) {
			&sql(FETCH MenuDetailCursor)
			quit:SQLCODE
			
			set menuItem={}
			set menuItem.id=id
			set menuItem.key=code
			set menuItem.code=code
			set menuItem.label=descripts
			set menuItem.icon=image
			set menuItem.seqNo=seqNo
			set menuItem.linkAddress=linkAddress
			set menuItem.linkPath=linkPath
			set menuItem.menuGroup=menuGroup
			
			// 获取子菜单
			set menuItem.children=..GetChildMenusFromDetail(code)
			
			do data.%Push(menuItem)
		}
		&sql(CLOSE MenuDetailCursor)
		
		set retObj.errorCode=errorCode
		set retObj.errorMessage=errorMessage
		set retObj.data=data
	}catch(e){
		set errorCode=-1
		set errorMessage=$System.Status.GetErrorText(e.AsStatus(),"cn")
		set retObj.errorCode=errorCode
		set retObj.errorMessage=errorMessage
	}
	quit retObj
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 获取子菜单(从CBMenuDetail)
ClassMethod GetChildMenusFromDetail(parentCode) As %Library.DynamicArray [ Private ]
{
	new (parentCode)
	set children=[]
	
	// 先获取父菜单的ID
	&sql(SELECT ID INTO :parentID FROM CB_MenuDetail WHERE Code = :parentCode)
	
	if parentID="" {
		quit children
	}
	
	&sql(DECLARE ChildDetailCursor CURSOR FOR
		SELECT ID, Code, Descripts, MenuGroup, Image, SeqNo, LinkAddress, LinkPath
		INTO :id, :code, :descripts, :menuGroup, :image, :seqNo, :linkAddress, :linkPath
		FROM CB_MenuDetail 
		WHERE MainMenu_Dr = :parentID AND MenuGroup = 'N'
		ORDER BY SeqNo)
	
	&sql(OPEN ChildDetailCursor)
	while (1) {
		&sql(FETCH ChildDetailCursor)
		quit:SQLCODE
		
		set menuItem={}
		set menuItem.id=id
		set menuItem.key=code
		set menuItem.code=code
		set menuItem.label=descripts
		set menuItem.icon=image
		set menuItem.seqNo=seqNo
		set menuItem.linkAddress=linkAddress
		set menuItem.linkPath=linkPath
		set menuItem.menuGroup=menuGroup
		
		do children.%Push(menuItem)
	}
	&sql(CLOSE ChildDetailCursor)
	
	quit children
}

/// Creator: AI CodeBuddy
/// CreatDate: 2026-04-14
/// Description: 保存角色菜单权限(到CBGroupMenu) - 使用operatetable模式
ClassMethod SaveRoleMenusToGroup(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultJson={}
	set resultJson.errorCode=0
	set resultJson.errorMessage=""
	
	try {
		// 解析参数
		Set params=postObj.params.%Get(0)
		Set session=postObj.session.%Get(0)
		Set userID=session.userID
		
		Set groupID=params.groupID
		Set menuDetailIds=params.menuDetailIds
		
		// 先删除该角色现有的菜单权限
		&sql(DELETE FROM CB_GroupMenu WHERE Group_Dr = :groupID)
		
		// 批量插入新的菜单权限
		for i=0:1:menuDetailIds.%Size()-1 {
			set menuDetailId=menuDetailIds.%Get(i)
			continue:menuDetailId=""
			
			// 构建operatetable格式的json
			Set json={}
			Set json.className="User.CBGroupMenu"
			Set json.updateUserID=userID
			Set data=[]
			Set newJsonObj={}
			Set newJsonObj.GroupDr=groupID
			Set newJsonObj.MenuDetailDr=menuDetailId
			Set newJsonObj.Type="1"
			Set newJsonObj.CreateDate=+$h      // %Date类型
			Set:userID'="" newJsonObj.CreateUserDr=userID  // 创建用户必填
			do data.%Push(newJsonObj)
			Set json.data=data
			
			// 执行插入
			Set rtn=##class(src.util.operatetable).Insert(json)
			if rtn.errorCode'=0 {
				set resultJson.errorCode=rtn.errorCode
				set resultJson.errorMessage=rtn.errorMessage
				quit
			}
		}
		
		if resultJson.errorCode=0 {
			set resultJson.errorMessage="保存角色菜单权限成功"
		}
		
	} catch(e) {
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set resultJson.errorCode=errorCode
		set resultJson.errorMessage=errorMessage
	}
	
	quit resultJson
}

}
