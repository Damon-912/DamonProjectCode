Class src.Group.MenuDetail Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     HYG
/// CreatDate:   2024-05-15
/// Description: 初始化	 
/// Debug:   w ##Class(src.Group.MenuDetail).GetInitialize({"params":[{"code":"","descripts":"","fieldClassID":""}],"code":"01010042","pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"Code","sortOrder":"asc"}]}).%ToJSON()
ClassMethod GetInitialize(postObj)
{
	new (postObj)
	
	set productModule=[]
	set sql="select * from SQLUSER.CB_ProductModule"
	set sqlObj=##class(%SQL.Statement).%New()
	set sc=sqlObj.%Prepare(sql)
	set list=sqlObj.%Execute()
	while list.%Next(){
		set obj={}
		set obj.id=list.%Get("ID")
		set obj.code=list.%Get("Code")
		set obj.descripts=list.%Get("Descripts")
		do productModule.%Push(obj)

	}
	
	set resultJson={}
	set resultJson.errorCode="0"
	set resultJson.errorMessage="成功"
	set result={}
	set result.productModule=productModule
	set resultJson.result=result
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 查询菜单分页
/// Table:     	 CB_MenuDetail      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Group.MenuDetail).FindMenuDetail({"params":[{"code":"","descripts":""}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"Code","sortOrder":"asc"}]}).%ToJSON()
ClassMethod FindMenuDetail(postObj)
{
	new (postObj)
	Set params=postObj.params.%Get(0)
	Set pagination=postObj.pagination.%Get(0)
	Set code=params.code
	Set desc=params.descripts
	set linkAddress=params.linkAddress
	set paras=params.paras
	Set sqlString="select ProductCat_Dr->Descripts as productCatDesc,ProductModule_Dr->Descripts as productModuleDesc,* from CB_MenuDetail where 1=1"
	Set:code'="" sqlString=sqlString_" AND Code like '%"_code_"%'"
	Set:desc'="" sqlString=sqlString_" AND Descripts like '%"_desc_"%'"
	set:linkAddress'="" sqlString=sqlString_" AND LinkAddress = '"_linkAddress_"'"
	set:paras'="" sqlString=sqlString_" AND Paras like '%"_paras_"%'"
	set Sqlrtn=##class(src.util.SQLUtil).SqlForList(sqlString,pagination)
	set rowsArr=[]
	set rows=Sqlrtn.result.rows
	set iter = rows.%GetIterator()
	while iter.%GetNext(.key , .value ) {
		set obj=rows.%Get(key)
		set menuDetailID=obj.menuDetailID
		set componentArr=[]
		set menuComponentID=""
		for{
			set menuComponentID=$o(^CBMenuDetailComponentI("MenuDetail",menuDetailID,menuComponentID))
			quit:menuComponentID=""
			set Componentobj={}
			set menuComponentobj=##class(User.CBMenuDetailComponent).%OpenId(menuComponentID)
			set Componentobj.componentID=menuComponentobj.ReactComponentDr.%Id()
			set Componentobj.componentCode=menuComponentobj.ReactComponentDr.Code
			set Componentobj.componentDesc=menuComponentobj.ReactComponentDr.Descripts
			set Componentobj.dataIndex=menuComponentobj.FieldCode
			do componentArr.%Push(Componentobj)
		}
		set obj.componentArr=componentArr
		do rowsArr.%Push(obj)
	}
	set Sqlrtn.result.rows=rowsArr
	Return Sqlrtn
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 保存菜单配置
/// Table:     	 CB_MenuDetail      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug: w ##Class(src.Group.MenuDetail).AddMenuConf({"params":[{"menuDetailID":"12","code":"010101","descripts":"基础数据","eNDesc":"Basic Settings","linkAddress":"","linkPath":"","seqNo":"","menuGroup":"Y","image":"FolderOpenOutlined","mainMenuID":"","shortcutKey":"","winPosition":"","backMethod":"","paras":"","condExpress":"","jSMethod":"","tooltip":"","productCatID":"1","productModuleID":"1","updateDate":"2024-06-06","updateTime":"13:41:34","updateUserID":"158","endDate":"","componentArr":[],"key":"1","UpdateUserDr":"161","userID":"161","productCatDesc":"(01)系统","productModuleDesc":"(0101)系统维护"}],"code":"01040101","session":[{"userID":"161","locID":1,"groupID":"1","hospID":"12","sessionID":"pdG3V6KkwE","hospCode":"RDR","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod AddMenuConf(postObj)
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	Set menuDetailID=jsonObj.menuDetailID
	Set Code=jsonObj.code
	Set Descripts=jsonObj.descripts
	Set MenuGroup=jsonObj.menuGroup
	Set userID=session.userID
	Set ProductCatDr=jsonObj.productCatID
	Set ProductModuleDr=jsonObj.productModuleID
	Set componentArr=jsonObj.componentArr
	Set verify=..Verify(postObj)
	Return:verify.errorCode'=0 verify
	
	
	Try{
		
		set menuCode=jsonObj.code
		
		if (menuCode="")&(menuDetailID="")
		{
			set menuGroup=jsonObj.menuGroup
			if menuGroup=""
			{
				set menuGroup="N"
			}
			if ProductModuleDr'=""
			{
				set menuCode=##class(User.CBProductModule).%OpenId(ProductModuleDr).Code
			}
			if (ProductCatDr'="")&(ProductModuleDr'="")
			{
				set menuListnum=$i(^MenuConfCode(ProductCatDr,ProductModuleDr,menuGroup))
			}
			else{
				set menuListnum=$i(^MenuConfCode("ProductCatDr","ProductModuleDr",menuGroup))
			}
			set num=$l(menuCode)+$l(menuListnum)
			set menuCodeL=8   ;默认8位
			if menuGroup="Y"
			{
				;//菜单组6位
				set menuCodeL=6
			}
			for l=1:1:(menuCodeL-num)
			{
				set menuCode=menuCode_"0"
			}
			set menuCode=menuCode_menuListnum
		}
		b ;112322322
		Set json={}
		Set json.className="User.CBMenuDetail"
		set json.updateUserID=userID
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj.ID=menuDetailID
		Set:menuDetailID="" newJsonObj.Code=menuCode
		Set newJsonObj.Descripts=jsonObj.descripts
		Set newJsonObj.ENDesc=jsonObj.eNDesc
		Set newJsonObj.LinkAddress=jsonObj.linkAddress
		Set newJsonObj.LinkPath=jsonObj.linkPath
		Set newJsonObj.SeqNo=jsonObj.seqNo
		Set newJsonObj.MenuGroup="N"
		Set:jsonObj.menuGroup'="" newJsonObj.MenuGroup=jsonObj.menuGroup
		Set newJsonObj.Image=jsonObj.image
		Set newJsonObj.MainMenuDr=jsonObj.mainMenuID
		Set newJsonObj.ShortcutKey=jsonObj.shortcutKey
		Set newJsonObj.WinPosition=jsonObj.winPosition
		Set newJsonObj.BackMethod=jsonObj.backMethod
		Set newJsonObj.Paras=jsonObj.paras
		Set newJsonObj.CondExpress=jsonObj.condExpress
		Set newJsonObj.JSMethod=jsonObj.jSMethod
		Set newJsonObj.Tooltip=jsonObj.tooltip
	 	Set newJsonObj.UpdateDate=$zd(+$h,3)
		Set newJsonObj.UpdateTime=$zt($p($h,",",2))
		Set newJsonObj.UpdateUserDr=userID
		Set newJsonObj.ProductCatDr=jsonObj.productCatID
		Set newJsonObj.ProductModuleDr=jsonObj.productModuleID
		do data.%Push(newJsonObj)
		Set json.data=data
		if menuDetailID=""
		{
			Set rtn=##class(src.util.operatetable).Insert(json)
		}else{
			Set rtn=##class(src.util.operatetable).Update(json)
		}
		b ;123234234234
		if rtn.errorCode'=0{
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage
			Return resultJson
		}
		set menuDetailID=rtn.rowIDArr.%Get(0)
		b ;12323
		do ..CBMenuDetailComponent(userID,menuDetailID,componentArr)
		Return rtn
	}Catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="新增菜单出现问题:w ##class("_$ClassName()_").AddMenuConf("")"
	    b
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	    
	}
	
	Return resultJson
}

ClassMethod CBMenuDetailComponent(userID, menuDetailID, componentArr)
{
	new (userID,menuDetailID,componentArr) 
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	Try{
		if (componentArr.%Size()>0)
		{
			set iter = componentArr.%GetIterator()
			while iter.%GetNext(.key , .value ) {
				quit:resultJson.errorCode'=0
				set dataIndex=componentArr.%Get(key).dataIndex
				set componentID=componentArr.%Get(key).componentID
				set TMPcomponentArr(componentID)=componentArr.%Get(key).%ToJSON()
				set menuComponentID=$o(^CBMenuDetailComponentI("MenuComponent",menuDetailID,componentID,""))
				Set json={}
				Set json.className="User.CBMenuDetailComponent"
				set json.updateUserID=userID
				Set data=[]
				Set newJsonObj={}
				Set newJsonObj.ID=menuComponentID
				Set newJsonObj.MenuDetailDr=menuDetailID
				Set newJsonObj.ReactComponentDr=componentID
				Set newJsonObj.FieldCode=dataIndex
			 	Set newJsonObj.CreateDate=$zd(+$h,3)
				Set newJsonObj.CreateUserDr=userID
				do data.%Push(newJsonObj)
				Set json.data=data
				if menuComponentID=""
				{
					Set rtn=##class(src.util.operatetable).Insert(json)
				}else{
					Set rtn=##class(src.util.operatetable).Update(json)
				}
				if rtn.errorCode'=0{
					Set resultJson.errorCode=rtn.errorCode
					Set resultJson.errorMessage=rtn.errorMessage
					quit 
				}
			}
		}
		
		set componentID=""
		for{
			set componentID=$o(^CBMenuDetailComponentI("MenuComponent",menuDetailID,componentID))
			quit:componentID=""
			if $g(TMPcomponentArr(componentID))=""
			{
				set menuComponentID=""
				for{
					set menuComponentID=$o(^CBMenuDetailComponentI("MenuComponent",menuDetailID,componentID,menuComponentID))
					quit:menuComponentID=""
					Set json={}
					Set json.className="User.CBMenuDetailComponent"
					set json.updateUserID=userID
					Set data=[]
					Set newJsonObj={}
					Set newJsonObj.ID=menuComponentID
					do data.%Push(newJsonObj)
					Set json.data=data
					Set rtn=##class(src.util.operatetable).Delete(json)
				}
			}
		}
	}Catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    b ;?
		set resultJson={}
		set resultJson.errorCode=errorCode
		set resultJson.errorMessage=errorMessage
	}
	
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 删除菜单配置
/// Table:     	 CB_MenuDetail
/// Input:		 {"params":[{"":""}]}      
/// Return:  	 	 
/// Debug: w ##Class(src.Group.MenuDetail).DeleteMenuConf({"params":[{"menuDetailID":2}]}).%ToJSON()
ClassMethod DeleteMenuConf(postObj)
{
	new (postObj) 
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	Set ID=jsonObj.menuDetailID
	set userID=session.userID
	
	if ID=""{
		Set resultJson.errorCode=1
		Set resultJson.errorMessage="记录id不能为空"
		Return resultJson
	}
	
	Try{
		Set json={}
		Set json.className="User.CBMenuDetail"
		set json.updateUserID=userID
		Set data=[]
		Set newJsonObj={}
		Set newJsonObj.ID=ID
		do data.%Push(newJsonObj)
		Set json.data=data
		Set rtn=##class(src.util.operatetable).Delete(json)
		if rtn.errorCode'=0{
			Set resultJson.errorCode=rtn.errorCode
			Set resultJson.errorMessage=rtn.errorMessage	
			Return resultJson
		}
		set menuComponentID=""
		for{
			set menuComponentID=$o(^CBMenuDetailComponentI("MenuDetail",ID,menuComponentID))
			quit:menuComponentID=""
			Set json={}
			Set json.className="User.CBMenuDetailComponent"
			set json.updateUserID=userID
			Set data=[]
			Set newJsonObj={}
			Set newJsonObj.ID=menuComponentID
			do data.%Push(newJsonObj)
			Set json.data=data
			Set rtn=##class(src.util.operatetable).Delete(json)
		}
		Return rtn
	}Catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    set errorInfo="删除菜单出现问题:w ##class("_$ClassName()_").DeleteMenuConf("")"
		do ##class(src.Interface.Message).InsErrRecord("05000001",errorInfo,errorMessage)
		set resultJson={}
		set resultJson.errorCode="05000001"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("05000001")
	}
	
	Return resultJson
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 菜单列表
/// Table:     	 CB_MenuDetail
/// Input:		 {"params":[{"":""}]}      
/// Return:  	 	 
/// Debug: w ##Class(src.Group.MenuDetail).MenuList().%ToJSON()
ClassMethod MenuList(postObj)
{
	new (postObj)
	Set params=postObj.params.%Get(0)
	Set sqlString=""				
    Set st = ##class(%SQL.Statement).%New(1)
	Set sc = st.%Prepare(sqlString)
	Set rs = st.%Execute()
	While rs.%Next(){
	
	}
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 校验
/// Table:     	 CB_MenuDetail
/// Input:		 {"params":[{"":""}]}      
/// Return:  	 	 
/// Debug: w ##Class(src.Group.MenuDetail).MenuList().%ToJSON()
ClassMethod Verify(postObj)
{
	new (postObj)
	Set jsonObj=postObj.params.%Get(0)
	Set Code=jsonObj.code
	Set Descripts=jsonObj.descripts
	Set MenuGroup=jsonObj.menuGroup
	Set ProductCatDr=jsonObj.productCatID
	Set ProductModuleDr=jsonObj.productModuleID
	
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	Set resultJson.rsult={}
#;	//代码不能为空
#;	if Code=""{
#;		Set resultJson.errorCode="01000101"
#;		Set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000101")
#;	}	
	//描述不能为空	
	if Descripts=""{
		Set resultJson.errorCode="01000102"
		Set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000102")
	}
	//菜单组标志不能为空
	if MenuGroup=""{
		Set resultJson.errorCode="01000103"
		Set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000103")
	}
	//产品分类不能为空
	if ProductCatDr=""{
		Set resultJson.errorCode="01000104"
		Set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000104")
	}
	//产品模块不能为空
	if ProductModuleDr=""{
		Set resultJson.errorCode="01000105"
		Set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000105")
	}
	Return resultJson
}

/// w ##Class(src.Group.MenuDetail).parentGroupMenu(7)
ClassMethod parentGroupMenu(groupMenuId, path = "", preMenuCode = "") As %Library.DynamicObject
{
	quit:groupMenuId="" ""
	Set groupMenuObj=$Get(^CBGroupMenuD(groupMenuId))
	quit:groupMenuObj="" ""
	Set preGroupMenuId=$ListGet(groupMenuObj,6)
	
	Set preMenuDr=$ListGet(groupMenuObj,5)
	Set menuObj=$Get(^CBMenuDetailD(preMenuDr))
	quit:menuObj="" ""
	Set preMenuCode=$ListGet(menuObj,2)
	
	//查询菜单Code
	if preGroupMenuId=""{
		Return path_"/"_preMenuCode
	}else{
		Return ..parentGroupMenu(preGroupMenuId,path,preMenuCode)_"/"_preMenuCode
	}
}

}
