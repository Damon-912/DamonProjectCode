/// 医院角色菜单表
Class src.Group.HospGroupMenuAuth Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     HYG
/// CreatDate:   2022-06-30
/// Description: 查询医院角色菜单
/// Table:     	 HB_GroupMenuAuth      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug:   w ##Class(src.Group.HospGroupMenuAuth).FindGroupMenuAuthDetail({"params":[{"hospID":"8","hospDesc":"成都普瑞眼科医院"}],"pagination":[{"pageSize":20,"currentPage":1,"sortColumn":"","sortOrder":""}],"code":"01030101","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"2qxKMKf160","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod FindGroupMenuAuthDetail(postObj)
{
	new (postObj)
	Set params=postObj.params.%Get(0)
	set groupMenuID=params.groupMenuID
	Set sqlString="select Hosp_Dr hospID , Hosp_Dr->Code hospCode,Hosp_Dr->Descripts hospDesc,* from HB_GroupMenuAuth where GroupMenu_Dr='"_groupMenuID_"'"
				  
	set st = ##class(%SQL.Statement).%New(1)
	set status = st.%Prepare(sqlString)
	if status'=1 {
		quit ##class(src.util.ResultSet).StatusFail(status)
	}
	set rset = st.%Execute()
	set rsmeta=rset.%GetMetadata()
	set count=0
	while rset.%Next(){
		set dataObj={}
		
		Set dataObj.hospID=rs.%Get("hospID")
		Set dataObj.hospDesc=rs.%Get("hospDesc")
		Set dataObj.hospCode=rs.%Get("hospCode")
		Set dataObj.groupMenuAuthID=rs.%Get("ID")
		do rows.%Push(dataObj)
		set count=count+1
	}
	Return {"errorCode":0,"errorMessage":"成功","result":{"total":(count),"rows":(rows)}}
}

/// 通过菜单获取组件的信息,table列或者按钮(角色菜单权限配置)
/// Output:      组件的信息,table列或者按钮
/// w ##class(src.Group.HospGroupMenuAuth).GetGroupMenuComponetTableData({"params":[{"groupID":"1","menuDetailCode":"01010001"}],"code":"01010062","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"aCE8bSumei","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod GetGroupMenuComponetTableData(jsonObj)
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{"language":{}}}
	set resultList=[],columnArr=[],totalWidth=0
	set errorCode="0",errorMessage=""
	kill sortData
	try{
		set hospID="",groupID="",locID="",userID=""
		
		set params=jsonObj.params.%Get(0)
		set groupID=params.groupID
		set menuDetailCode=params.menuDetailCode
		if menuDetailCode=""{
			set resultObj.errorCode="-1"
	    	set resultObj.errorMessage="菜单代码不能为空"
	    	quit
		}
		set menuDetailId=$o(^CBMenuDetailI("Code",$ZCVT(menuDetailCode,"U"),0)) 
		if menuDetailId=""{
			set resultObj.errorCode="01040102"
			set resultObj.errorMessage="无"_menuDetailCode_"此菜单信息"
			quit 
		}  
		if groupID=""{
			set resultObj.errorCode="-1"
	    	set resultObj.errorMessage="groupID角色不能为空"
	    	quit
		}
		if jsonObj.%IsDefined("session"){
			set session=jsonObj.session.%Get(0)
			if session.hospID'=""{
			    set hospID=session.hospID
				set userID=session.userID
			}
			set jsonObj.session.%Get(0).groupID=groupID
		}
		set menuDetailComponentDr=""
		for
		{
			set menuDetailComponentDr=$o(^CBMenuDetailComponentI("MenuDetail",menuDetailId,menuDetailComponentDr))
			quit:menuDetailComponentDr=""
			set menuDetailComponentobj=##class(User.CBMenuDetailComponent).%OpenId(menuDetailComponentDr)
			
			set paramsobj={
				"params":[{
					"componentName":(menuDetailComponentobj.ReactComponentDr.Code),
					"groupID":(groupID)
					}],
					"session":(jsonObj.session)
				}
			set componetTableobj=##class(src.Group.HospGroupMenuAuth).GetComponetTableData(paramsobj)
			b ;111123
			set errorCode=componetTableobj.errorCode
			set errorMessage=componetTableobj.errorMessage
			if errorCode'=0
			{
				set resultObj.errorCode=errorCode
				set resultObj.errorMessage=errorMessage
				quit
			}
			set componetobj=componetTableobj.result
			do componetobj.%Set("componentCode",menuDetailComponentobj.ReactComponentDr.Code)
			do componetobj.%Set("componentDesc",menuDetailComponentobj.ReactComponentDr.Descripts)
			do componetobj.%Set("dataIndex",menuDetailComponentobj.FieldCode)
			do componetobj.%Set("totalWidth",componetTableobj.totalWidth)
			do resultList.%Push(componetobj)
		}		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	set resultObj.result=resultList
	quit resultObj
}

ClassMethod GetComponetTableData(jsonObj)
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{"language":{}}}
	set buttonArr=[],columnArr=[],totalWidth=0
	set errorCode="0",errorMessage=""
	kill sortData
	try{
		set hospID="",groupID="",locID="",userID=""
		
		set params=jsonObj.params.%Get(0)
		set componentName=params.componentName
		set groupID=params.groupID
		set reactCode=params.reactCode
		if reactCode'=""{
			set reactCode=reactCode.%Get(0)
		}
		
		if jsonObj.%IsDefined("session"){
			set session=jsonObj.session.%Get(0)
			if session.hospID'=""{
			    set hospID=session.hospID
				set userID=session.userID
			}
		}
		set type=params.type	
		if componentName'=""{
			
			set searchType="G"	;//固定角色权限
			set compontId=$o(^CBReactComponentI("Code",$ZCVT(componentName,"U"),0)) 
			if compontId=""{
				set resultObj.errorCode="01040102"
				set resultObj.errorMessage="未维护组件信息"
				quit 
			} 
			set typeStr="U^G^H" //用户,角色,医院
			set saveType="G",saveTypeId=groupID    //固定角色权限
	
			set sub="" 
			set result=[]
			set sequence=0
			set nullSeqNo=99999 //未维护列顺序,从99999开始
			set colId=""
			set type="B"
			b //维护配置
			set tStatement = ##class(%SQL.Statement).%New(1)   
			set sql="SELECT * FROM CB_ReactComTable where CBReactCom_Dr->Code ='"_componentName_"'"
			set sql=sql_" order by Type,SeqNo"
			set sc=tStatement.%Prepare(sql)
			set result=tStatement.%Execute()		
			while result.%Next(.sc){
				set id=result.%Get("ID")
				set compontId=result.%Get("CBReactCom_Dr")
				set seqNo=result.%Get("SeqNo")
				set type=result.%Get("Type")
				set authId=$o(^HBTableAuthI("HospType",$ZCVT(saveType,"U"),saveTypeId,hospID,compontId,id,0)) //医院权限 
				if authId=""
				{
					set authId=$o(^HBTableAuthI("Type",$ZCVT(saveType,"U"),saveTypeId,compontId,id,0))
				}
				if authId=""{
					//维护配置后新添加的列
					set seqNo=id
					set sortData("reactData",type,seqNo,compontId_"||"_id)=compontId_"||"_id
				}
				else{
					//维护配置的数据
					set data=$g(^HBTableAuthD(authId))
					set diaplayFlag=$lg(data,7)
					continue:diaplayFlag="N"
					set seqNo=$lg(data,6)
					set colDr=$lg(data,5)
					set sortData("reactData",type,seqNo,authId)=authId
				}
			}
			set HBTableAuthFlag=0
			if $d(^HBTableAuthI("HospType",$ZCVT(saveType,"U"),saveTypeId,hospID,compontId))
			{
				set HBTableAuthFlag=1
			}
			set typeStr="C^B"
			set typeData=[]
			set seqNo=""
			for{
				set seqNo=$O(sortData("reactData",type,seqNo))
				quit:seqNo=""
				set dataID=""
				for {
					set dataID=$o(sortData("reactData",type,seqNo,dataID))
					quit:dataID=""
					if HBTableAuthFlag=1
					{
						set displayFlag="N"
					}
					if dataID["||"{
						//未维护权限
						set data=$g(^CBReactComTableD($P(dataID,"||",2)))
						set id=$P(dataID,"||",2)
						set descripts=$lg(data,4)
						set width=$lg(data,6)
						set align=$lg(data,13)
						set enDescripts=""
						set exportFlag=$lg(data,10)
						set:HBTableAuthFlag=0 displayFlag=$lg(data,8)
					}else{
						set authData=$g(^HBTableAuthD(dataID))
						set id=$lg(authData,5)	
						set data=$g(^CBReactComTableD(id))
						set descripts=$lg(authData,11)
						if descripts="" set descripts=$lg(data,4)
						set width=$lg(authData,12)
						if width="" set width=$lg(data,6)
						set align=$lg(authData,13) 
						set enDescripts=$lg(authData,14)
						if enDescripts="" 
						set exportFlag=$lg(data,9)
						set displayFlag=$lg(authData,7)
						set encryptFlag=$lg(authData,17)
					}
					set sequence=sequence+1
					set dataObj={}
					set dataObj.id=id
					set dataObj.code=$lg(data,3)
					set dataObj.descripts=descripts
					set dataObj.dataIndex=$lg(data,3)
					set dataObj.display=displayFlag
					set dataObj.encryptFlag=$g(encryptFlag)
					set dataObj.enDescripts=""	
					set dataObj.exportFlag=exportFlag
					set dataObj.fixed=$case($lg(data,14)'="","1":$lg(data,14),:"") 
					set dataObj.label=descripts
					set dataObj.seqNo=sequence
					set dataObj.title=descripts
					set dataObj.value=id
					set dataObj.visible=$lg(data,15)
					set dataObj.width=width_"px"
					set dataObj.align=align
					set dataObj.fieldTypeID=$lg(data,17)
					set dataObj.typeCode=$case(dataObj.fieldTypeID'="",1:(##class(User.CBConfigFieldType).%OpenId(dataObj.fieldTypeID).Code),:"")
					set dataObj.params=$lg(data,18)
					set dataObj.doubt=$lg(data,19)
					set dataObj.linkMethod=$lg(data,11)
					set dataObj.linkService=$lg(data,12)
					set totalWidth=totalWidth+width
					if (type="C"){
						do columnArr.%Push(dataObj)
					}
					if (type="B"){
						do buttonArr.%Push(dataObj)
					}
				}
			}  
			// Field部分
			set CN={}
			set tStatement = ##class(%SQL.Statement).%New(1)   
			set sql="SELECT * FROM CB_ReactFormField where CBReactCom_Dr->Code ='"_componentName_"'"
			set sc=tStatement.%Prepare(sql)
			set result=tStatement.%Execute()		
			while result.%Next(.sc){
				set obj={}
				set obj.descripts=result.%Get("Descripts")
				set obj.required=result.%Get("Required")
				set obj.message=result.%Get("Message")
				set obj.focusIndex=result.%Get("FocusIndex")
				set obj.suffix=result.%Get("Suffix")
				set obj.length=result.%Get("Length")
				set obj.enDesc=result.%Get("ENDesc")
				do CN.%Set(reactCode_result.%Get("Code"),obj)
			}
			// Form
			set compontData={}
			kill sortData
			set sub="" 
			set formData=[]
			set sequence=0
			set nullSeqNo=99999 //未维护列顺序,从99999开始
			set HBFormAuthFlag=0
			if $d(^HBFormAuthI("HospType",$ZCVT(saveType,"U"),saveTypeId,hospID,compontId))
			{
				set HBFormAuthFlag=1
			}
			//维护配置
			set tStatement = ##class(%SQL.Statement).%New(1)   
			set sql="SELECT * FROM CB_ReactForm where CBReactCom_Dr->Code ='"_componentName_"'"
			set sql=sql_" order by SeqNo"
			b ;111111111111111
			set sc=tStatement.%Prepare(sql)
			set result=tStatement.%Execute()		
			while result.%Next(.sc){
				set id=result.%Get("ID")
				set compontId=result.%Get("CBReactCom_Dr")
				set seqNo=result.%Get("SeqNo")
				set:seqNo="" seqNo=nullSeqNo,nullSeqNo=+nullSeqNo+1
				set authId=$o(^HBFormAuthI("HospType",$ZCVT(saveType,"U"),saveTypeId,hospID,compontId,id,0)) //区分医院
				set:authId="" authId=$o(^HBFormAuthI("Type",$ZCVT(saveType,"U"),saveTypeId,compontId,id,0))	
				if authId=""
				{
					//维护配置后新添加的列
					//
					set sortData("FormData",seqNo,compontId_"||"_id)=""
				}
				else
				{
					//维护配置的数据
					set data=$g(^HBFormAuthD(authId))
					//set seqNo=$lg(data,6)
					set sortData("FormData",seqNo,authId)=""
				}
				
			}
			set seqNo=""
			for{
				set seqNo=$O(sortData("FormData",seqNo))
				quit:seqNo=""
				set id=""
				for{
					set id=$O(sortData("FormData",seqNo,id))
					quit:id=""
					set itemData={}
					set formID=id
					
					if HBFormAuthFlag=1
					{
						set displayFlag="N"
					}
					if id["||"{
						//未维护权限
						set data=$g(^CBReactFormD($P(id,"||",2)))
						set col=$lg(data,14)
						set jumpID=$lg(data,15) 					
						set labelCol=$lg(data,16)
						set wrapperCol=$lg(data,17)
						set:HBFormAuthFlag=0 displayFlag=$lg(data,20)
					}else{
						set authData=$g(^HBFormAuthD(id))
						set formID=$lg(authData,5)
						set data=$g(^CBReactFormD(formID))
						set col=$lg(authData,7)
						set jumpID=$lg(authData,8) 					
						set labelCol=$lg(authData,9)
						set wrapperCol=$lg(authData,10)
						set itemData.display=$lg(data,20)
						
					}
					b ;;;;;sssd
					set itemData.id=formID
					set itemData.value=formID
					set itemData.code=$lg(data,3)
					set itemData.dataIndex=$lg(data,3)
					set itemData.descripts=$lg(data,4)
					set itemData.title=$lg(data,4)
					set itemData.placeholder=$lg(data,7)
					if (session.language="EN")&&(enDescripts'=""){
						set itemData.descripts=$lg(data,6)
					}
					set sequence=sequence+1
					set itemData.seqNo=sequence
					set fieldTypeID=$lg(data,8)
					set itemData.typeCode=""
					set:fieldTypeID'="" itemData.typeCode=##class(User.CBConfigFieldType).%OpenId(fieldTypeID).Code
					set itemData.callback=$lg(data,9)
					set itemData.doubt=$lg(data,10)
					set itemData.className=$lg(data,11)
					set itemData.methodName=$lg(data,12)
					set linkValueIDStr=$lg(data,13)				
					set linkValueCodeArr=[],linkValueIDArr=[]
					for i=1:1:$l(linkValueIDStr,"^")
					{
						set linkValueID=$p(linkValueIDStr,"^",i)
						continue:linkValueID=""
						set linkValueCode=##class(User.CBReactForm).%OpenId(linkValueID).Code
						do linkValueCodeArr.%Push(linkValueCode)
						do linkValueIDArr.%Push(linkValueID)
					}
					set itemData.linkValueCode=linkValueCodeArr
					set itemData.linkValueID=linkValueIDArr
					set itemData.enDescripts=$lg(data,6)
					set itemData.linkCode=$lg(data,24)
					set itemData.col=col
					set jumpCode=""
					set:jumpID'="" jumpCode=##class(User.CBReactForm).%OpenId(jumpID).Code
					set itemData.jumpID=jumpID 
					set itemData.jumpCode=jumpCode
					set itemData.labelCol=labelCol	
					set itemData.wrapperCol=wrapperCol
					set itemData.required=$lg(data,18)	
					set itemData.disabled=$lg(data,19)
					
					set itemData.default=$lg(data,25)	
					set itemData.params=$lg(data,26)
					set detailItem=[]
					set elementFieldDr=$lg(data,27)
					if elementFieldDr'=""
					{
						set elementFieldobj=##class(User.CBElementField).%OpenId(elementFieldDr)
						if elementFieldobj'=""
						{
							if (elementFieldobj.CustomDataDr)'=""
							{
								if (elementFieldobj.CustomDataDr.ServiceInterfaceDr'="")
								{
									set className=elementFieldobj.CustomDataDr.ServiceInterfaceDr.ClassName
									set methodName=elementFieldobj.CustomDataDr.ServiceInterfaceDr.MethodName
									set tobj=$CLASSMETHOD(className,methodName,.jsonObj)
									if ($ISOBJECT(tobj)&&(tobj.errorCode'="0")){
										
									}else
									{
										set detailItem=tobj.result
									}
								}
							}else{
								set customDataStr=elementFieldobj.CustomDataStr
								if customDataStr'=""
								{
									for l=1:1:$l(customDataStr,"&")
									{
										set info=$p(customDataStr,"&",l)
										set customDataobj={}
										set customDataobj.id=$p(info,":",1)
										set customDataobj.code=$p(info,":",1)
										set customDataobj.descripts=$p(info,":",2)
										do detailItem.%Push(customDataobj)
									}
								}
							}
						}
					}
					set itemData.detailItem=detailItem
					do formData.%Push(itemData)
					;b ;itemData
				} 
			}
			//set compontData.formData=formData
			b // 新button
			set HBButtonAuthFlag=0
			if $d(^HBButtonAuthI("HospType",$ZCVT(saveType,"U"),saveTypeId,hospID,compontId))
			{
				set HBButtonAuthFlag=1
			}
			set buttonData=[]
			set tStatement = ##class(%SQL.Statement).%New(1)
			set sql="SELECT Type_Dr->Descripts typeDesc,Size_Dr->Descripts sizeDesc,Shape_Dr->Descripts shapeDesc,* FROM CB_ReactButton WHERE CBReactCom_Dr=?"
			b	;111
			do tStatement.%Prepare(sql)
			set result=tStatement.%Execute(compontId)		
			while result.%Next(.sc){
				set id=result.%Get("ID")
				set dataObj={}
				set dataObj.id=result.%Get("ID")
				set dataObj.value=result.%Get("ID")
				if HBButtonAuthFlag=1
				{
					set displayFlag="N"
				}
				set authId=$o(^HBButtonAuthI("HospType",$ZCVT(saveType,"U"),saveTypeId,hospID,compontId,id,0)) //区分医院
				set:authId="" authId=$o(^HBButtonAuthI("Type",$ZCVT(saveType,"U"),saveTypeId,compontId,id,0))					
				if authId'=""
				{
					set dataObj.id=authId
					set dataObj.value=authId
					set displayFlag="Y"
				}
				else{
					set dataObj.id=compontId_"||"_result.%Get("ID")
				}
				set dataObj.code=result.%Get("Code")
				set dataObj.title=result.%Get("Title")
				set dataObj.icon=result.%Get("Icon")
				set dataObj.onClick=result.%Get("OnClick")
				set dataObj.typeID=result.%Get("Type_Dr")
				set dataObj.typeDesc=result.%Get("typeDesc")
				set dataObj.sizeID=result.%Get("Size_Dr")
				set dataObj.sizeDesc=result.%Get("sizeDesc")
				set dataObj.shapeID=result.%Get("Shape_Dr")
				set dataObj.shapeDesc=result.%Get("shapeDesc")	
				set dataObj.href=result.%Get("Href")
				set dataObj.target=result.%Get("Target")
				set dataObj.ghost=result.%Get("Ghost")
				set dataObj.block=result.%Get("Block")
				set dataObj.valid=result.%Get("Valid")
				set dataObj.display=displayFlag		
				do buttonData.%Push(dataObj)
			}
			set compontData.buttonData=buttonData
		}		
		set resultObj.result.language.CN=$g(CN)	
		set resultObj.result.B=buttonArr
		set resultObj.result.C=columnArr
		set resultObj.result.formData=formData
		set resultObj.result.buttonData=buttonData
		set resultObj.totalWidth=totalWidth_"px"		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Creator:     LYP
/// CreatDate:   2022-06-30
/// Description: 保存医院角色菜单表
/// Table:     	 HB_GroupMenuAuth      
/// Input:		{"params":[{"":""}]} 
/// Return:  	 	 
/// Debug: w ##Class(src.User.UserLogonLoc).SaveUserLogonLoc({"params":[{"userID":"35","hospID":1,"groupID":"1","isDefault":"N","updateUserID":1,"updateDate":66294,"updateTime":"51706"}]}).%ToJSON()
ClassMethod SaveGroupMenuAuth(postObj)
{
	new (postObj,userSaveID)
	Set jsonObj=postObj.params.%Get(0)
	Set session=postObj.session.%Get(0)
	set groupMenuID=jsonObj.groupMenuID
	set groupMenuAuthArr=jsonObj.groupMenuAuthArr
	Set resultJson={}
	Set resultJson.errorCode=0
	Set resultJson.errorMessage=""
	if groupMenuID=""
	{
		set resultJson={}
		set resultJson.errorCode="-1"
		set resultJson.errorMessage="groupMenuID:不能为空"
		quit resultJson
	}
	Try{
		 
		for i=0:1:groupMenuAuthArr.%Size()-1{
			set hospID=groupMenuAuthArr.%Get(i)
			continue:+hospID=0
			quit:resultJson.errorCode'=0
			set groupMenuAuthID=$o(^HBGroupMenuAuthI("HospMenu",hospID,groupMenuID,""))
			if groupMenuAuthID=""
			{
				Set json={}
				Set json.className="User.HBGroupMenuAuth"
				Set json.updateUserID=session.userID    //userID
				Set data=[]
				Set obj={}
				Set obj.GroupMenuDr=groupMenuID
				Set obj.HospDr=hospID
				Set obj.CreatedByDr=session.userID
				Set obj.CreatedDate=$zd(+$h,3)
				Set obj.CreatedTime=$zt($p($h,",",2))
				do data.%Push(obj)
				Set json.data=data
				Set rtn=##class(src.util.operatetable).Insert(json)
				if rtn.errorCode'=0{
					Set resultJson.errorCode=rtn.errorCode
					Set resultJson.errorMessage=rtn.errorMessage
					quit
				}
				set groupMenuAuthID=rtn.rowIDArr.%Get(0)
			}
			set groupMenuAuthIDArr(groupMenuAuthID)=groupMenuAuthID
		}
		set groupMenuAuthID=""
		for
		{
			set groupMenuAuthID=$o(^HBGroupMenuAuthI("GroupMenu",groupMenuID,groupMenuAuthID))
			quit:groupMenuAuthID=""
			continue:$g(groupMenuAuthIDArr(groupMenuAuthID))'=""
			Set json={}
			Set json.className="User.HBGroupMenuAuth"
			set json.updateUserID=session.userID
			Set data=[]
			Set newJsonObj={}
			Set newJsonObj.ID=groupMenuAuthID
			do data.%Push(newJsonObj)
			Set json.data=data
			Set rtn=##class(src.util.operatetable).Delete(json)
			if rtn.errorCode'=0{
				Set resultJson.errorCode=rtn.errorCode
				Set resultJson.errorMessage=rtn.errorMessage	
				Return resultJson
			}
		}
		Return rtn
	}Catch(e){
		set status=e.AsStatus()
		set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set resultJson={}
		set resultJson.errorCode=errorCode
		set resultJson.errorMessage=errorMessage
	}
	
	Return resultJson
}

/// Creator:     HYG
/// CreatDate:   2024-06-12
/// Description: 保存角色菜单动态表头
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Group.HospGroupMenuAuth).SaveGroupMenuComponetTableData({"params":[{"groupID":"1","menuDetailCode":"01010001","componentCode":"MenuDetailMaintenance","C":[{"id":"1","code":"seqNo","descripts":"序号","dataIndex":"seqNo","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"序号","seqNo":1,"title":"序号","value":"1","visible":"N","width":"80pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"35","code":"code","descripts":"代码","dataIndex":"code","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"left","label":"代码","seqNo":2,"title":"代码","value":"35","visible":"N","width":"120pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"36","code":"descripts","descripts":"描述","dataIndex":"descripts","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"left","label":"描述","seqNo":3,"title":"描述","value":"36","visible":"N","width":"150pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"37","code":"eNDesc","descripts":"英文描述","dataIndex":"eNDesc","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"英文描述","seqNo":4,"title":"英文描述","value":"37","visible":"N","width":"200pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"38","code":"linkAddress","descripts":"链接地址","dataIndex":"linkAddress","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"链接地址","seqNo":5,"title":"链接地址","value":"38","visible":"N","width":"500pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"39","code":"paras","descripts":"参数","dataIndex":"paras","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"参数","seqNo":6,"title":"参数","value":"39","visible":"N","width":"600pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"40","code":"menuGroup","descripts":"菜单组标志","dataIndex":"menuGroup","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"菜单组标志","seqNo":7,"title":"菜单组标志","value":"40","visible":"N","width":"150pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"41","code":"productCatDesc","descripts":"产品分类","dataIndex":"productCatDesc","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"产品分类","seqNo":8,"title":"产品分类","value":"41","visible":"N","width":"100pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"42","code":"productModuleDesc","descripts":"产品模块","dataIndex":"productModuleDesc","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"产品模块","seqNo":9,"title":"产品模块","value":"42","visible":"N","width":"100pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"43","code":"image","descripts":"菜单图标","dataIndex":"image","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"菜单图标","seqNo":10,"title":"菜单图标","value":"43","visible":"N","width":"100pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"44","code":"mainMenuID","descripts":"图标颜色","dataIndex":"mainMenuID","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"图标颜色","seqNo":11,"title":"图标颜色","value":"44","visible":"N","width":"100pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"45","code":"shortcutKey","descripts":"快捷键","dataIndex":"shortcutKey","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"快捷键","seqNo":12,"title":"快捷键","value":"45","visible":"N","width":"100pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"46","code":"winPosition","descripts":"弹窗位置","dataIndex":"winPosition","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"弹窗位置","seqNo":13,"title":"弹窗位置","value":"46","visible":"N","width":"100pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"47","code":"backMethod","descripts":"执行后台方法","dataIndex":"backMethod","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"执行后台方法","seqNo":14,"title":"执行后台方法","value":"47","visible":"N","width":"120pxpxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"48","code":"condExpress","descripts":"条件表达式","dataIndex":"condExpress","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"条件表达式","seqNo":15,"title":"条件表达式","value":"48","visible":"N","width":"200pxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"49","code":"jSMethod","descripts":"JS方法","dataIndex":"jSMethod","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"JS方法","seqNo":16,"title":"JS方法","value":"49","visible":"N","width":"200pxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""},{"id":"50","code":"tooltip","descripts":"菜单描述","dataIndex":"tooltip","display":"Y","encryptFlag":"","enDescripts":"","exportFlag":"N","fixed":"","label":"菜单描述","seqNo":17,"title":"菜单描述","value":"50","visible":"N","width":"200pxpxpxpx","align":"center","fieldTypeID":"","typeCode":"","params":"","doubt":"","linkMethod":"","linkService":""}],"formData":[{"display":"Y","id":"22","value":"22","code":"code","dataIndex":"code","descripts":"代码","title":"代码","placeholder":"","seqNo":1,"typeCode":"Input","callback":"","doubt":"","className":"","methodName":"","linkValueCode":[],"linkValueID":[],"enDescripts":"","linkCode":"","col":"","jumpID":"","jumpCode":"","labelCol":"","wrapperCol":"","required":"N","disabled":"N","default":"","params":"","detailItem":[]},{"display":"Y","id":"23","value":"23","code":"descripts","dataIndex":"descripts","descripts":"描述","title":"描述","placeholder":"","seqNo":2,"typeCode":"Input","callback":"","doubt":"","className":"","methodName":"","linkValueCode":[],"linkValueID":[],"enDescripts":"","linkCode":"","col":"","jumpID":"","jumpCode":"","labelCol":"","wrapperCol":"","required":"N","disabled":"N","default":"","params":"","detailItem":[]},{"display":"Y","id":"84","value":"84","code":"linkAddress","dataIndex":"linkAddress","descripts":"链接地址","title":"链接地址","placeholder":"","seqNo":3,"typeCode":"Input","callback":"","doubt":"","className":"","methodName":"","linkValueCode":[],"linkValueID":[],"enDescripts":"","linkCode":"","col":"","jumpID":"","jumpCode":"","labelCol":"","wrapperCol":"","required":"N","disabled":"N","default":"","params":"","detailItem":[]},{"display":"Y","id":"85","value":"85","code":"paras","dataIndex":"paras","descripts":"参数","title":"参数","placeholder":"","seqNo":4,"typeCode":"Input","callback":"","doubt":"","className":"","methodName":"","linkValueCode":[],"linkValueID":[],"enDescripts":"","linkCode":"","col":"","jumpID":"","jumpCode":"","labelCol":"","wrapperCol":"","required":"N","disabled":"N","default":"","params":"","detailItem":[]},{"display":"Y","id":"62","value":"62","code":"queryBtn","dataIndex":"queryBtn","descripts":"查询","title":"查询","placeholder":"","seqNo":5,"typeCode":"Button","callback":"","doubt":"","className":"","methodName":"","linkValueCode":[],"linkValueID":[],"enDescripts":"","linkCode":"","col":"","jumpID":"","jumpCode":"","labelCol":"","wrapperCol":"","required":"N","disabled":"N","default":"","params":"type:primary","detailItem":[]}],"buttonData":[{"id":"8","value":"8","code":"queryBtn","title":"查询","icon":"","onClick":"","typeID":"","typeDesc":"","sizeID":"","sizeDesc":"","shapeID":"","shapeDesc":"","href":"","target":"","ghost":"N","block":"N","valid":"N","display":"Y"},{"id":"2","value":"2","code":"addBtn","title":"新增","icon":"","onClick":"","typeID":"","typeDesc":"","sizeID":"","sizeDesc":"","shapeID":"","shapeDesc":"","href":"","target":"","ghost":"N","block":"N","valid":"N","display":"Y"}]}],"code":"01010063","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"a818fm8mEj","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]})
ClassMethod SaveGroupMenuComponetTableData(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set errorCode=0,errorMessage=""
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set groupID=params.groupID
		set hospID=session.hospID
		set userID=session.userID
		set menuDetailCode=params.menuDetailCode
		set componentCode=params.componentCode
		set compontId=$o(^CBReactComponentI("Code",$ZCVT(componentCode,"U"),0)) 

		if compontId=""{
			set resultObj.errorCode=-1
			set resultObj.errorMessage="不存在该组件"
			Quit
		}	
	
		set tableData=params."C"
		set formData=params.formData
		set buttonData=params.buttonData
		TStart
		
		set postObj={}
		set postObj.tableData=tableData
		set postObj.updateUser=userID
		set postObj.type="G"
		set postObj.hospID=hospID
		set postObj.groupID=groupID
		set postObj.userID=userID
		set postObj.componentName=componentCode
		set tableDatartnobj=..SaveComponettableAuthConfig(postObj)   ;//table
		if tableDatartnobj.errorCode'=0
		{
			Trollback
			set resultObj=tableDatartnobj
			quit
		}
		
		set postObj={}
		set postObj.formData=formData
		set postObj.updateUser=userID
		set postObj.type="G"
		set postObj.hospID=hospID
		set postObj.groupID=groupID
		set postObj.userID=userID
		set postObj.componentName=componentCode
		set tableDatartnobj=..SaveComponetFormAuthConfig(postObj)   ;//form
		if tableDatartnobj.errorCode'=0
		{
			Trollback
			set resultObj=tableDatartnobj
			quit
		}
		
		set postObj={}
		set postObj.buttonData=buttonData
		set postObj.updateUser=userID
		set postObj.type="G"
		set postObj.hospID=hospID
		set postObj.groupID=groupID
		set postObj.userID=userID
		set postObj.componentName=componentCode
		set tableDatartnobj=..SaveComponetButtonAuthConfig(postObj)   ;//button
		if tableDatartnobj.errorCode'=0
		{
			Trollback
			set resultObj=tableDatartnobj
			quit
		}
		Tcommit
		
	}catch(e){
		Trollback 1
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Description: 保存角色菜单组建列权限配置信息
/// Output:      组件的信息,table列  	
ClassMethod SaveComponettableAuthConfig(postObj)
{
	new (postObj)
	kill ^TMP("SaveComponetAuthConfig",$j)
	try{
		set resultJson={"errorCode":"0","errorMessage":"成功","result":{}}
		set errorCode=0
		set errorMessage=""
		set tableData=postObj.tableData	 
	    set updateUser=postObj.updateUser	      
	    set typeId=""  	 
	    set type=postObj.type 	
	    set hospID=postObj.hospID
		set groupID=postObj.groupID
		set userID=postObj.userID
		set:updateUser="" updateUser=userID
		set typeId=$case(type,"U":userID,"G":groupID,"H":hospID,:"")
		;用于列配置页面使用
	    set componentName=postObj.componentName	 
		set compontId=$o(^CBReactComponentI("Code",$ZCVT(componentName,"U"),0)) 
		if compontId=""{
			set resultJson.errorCode=-1
			set resultJson.errorMessage="组件id不可为空"
			quit
		}
		TStart
		b ;//更新插入
		set tableiter=tableData.%GetIterator()
		while tableiter.%GetNext(.key1 , .value1 ) {
		    set rowData=tableData.%Get(key1)
			set subIter=rowData.%GetIterator() //列数据
			set insObj={},data=[]
			set insObj.className="User.HBTableAuth"
			set insObj.updateUserID=updateUser
			set dataobj={}
			set dataobj.Type=type
			set dataobj.DataID=typeId
			set dataobj.ComponentDr=compontId
			set dataobj.UserDr=updateUser
			set:type="G" dataobj.HospitalDr=hospID	;//角色 按医院区分
			
			set comTableDr=rowData.id
			set comTableobj=##class(User.CBReactComTable).%OpenId(comTableDr)
			set dataobj.Export=comTableobj.Export
			set authId=""
			while subIter.%GetNext(.code,.colData) {
			  set cellValue=rowData.%Get(code)
			  continue:code="TotalCount" 
			  if (code="id")
			  {
				set authId=$o(^HBTableAuthI("HospType",$ZCVT(type,"U"),typeId,hospID,compontId,cellValue,0)) 
				if (authId'=""){set dataobj.ID=authId}
				set dataobj.ComTableDr=cellValue
		      }
		      if (code="display") set dataobj.Display=colData
			  if (code="encryptFlag") set dataobj.Encrypt=colData
			  if (code="columnName"){
				  if language="EN"{
					  set dataobj.ENDesc=colData
			  	  }else{
				  	  set dataobj.Title=colData
				  }
			  } 
			  if (code="width") set dataobj.Width=colData
			  if (code="align") set dataobj.Align=colData
			}
			continue:dataobj.Display'="Y"   ;//不显示不保存
			set dataobj.SeqNo=key1+1
			do data.%Push(dataobj)
			set insObj.data=data
			if authId=""
			{ 
				set rtn=##class(src.util.operatetable).Insert(.insObj)
			}
			else
			{
				set rtn=##class(src.util.operatetable).Update(.insObj)
			}
			set errorCode=rtn.errorCode
			set errorMessage=rtn.errorMessage	
			if errorCode=0 {
				
			}else{
				set resultJson.errorMessage=errorMessage
				set resultJson.errorCode=errorCode
				quit 
			}
			set rowID=rtn.rowIDArr.%Get(0)
			set ^TMP("SaveComponetAuthConfig",$j,rowID)=rowID
		}
		quit:errorCode'=0
		set cellValue=""
		for
		{
			set cellValue=$o(^HBTableAuthI("HospType",$ZCVT(type,"U"),typeId,hospID,compontId,cellValue))
			quit:cellValue=""
			quit:errorCode'=0
			set authId=""
			for
			{
				set authId=$o(^HBTableAuthI("HospType",$ZCVT(type,"U"),typeId,hospID,compontId,cellValue,authId))
				quit:authId=""
				continue:$g(^TMP("SaveComponetAuthConfig",$j,authId))'=""
				set delObj={},data=[]
				set delObj.className="User.HBTableAuth"
				set delObj.updateUserID=userID
				set dataObj={}
				set dataObj.ID=authId
				do data.%Push(dataObj)
				set delObj.data=data
				set rtn=##class(src.util.operatetable).Delete(.delObj) ;调用公共类方法记录修改日记
				set errorCode=rtn.errorCode
				set errorMessage=rtn.errorMessage
				if errorCode'=0
				{
					set resultJson.errorMessage=errorMessage
					set resultJson.errorCode=errorCode
				}
				quit:errorCode'=0
			}
		}
		quit:errorCode'=0
		
	}catch(e){
		set status=e.AsStatus()
	    set resultJson.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultJson.errorMessage=##class(%SYSTEM.Status).GetErrorText(status,"cn")	
	}
	kill ^TMP("SaveComponetAuthConfig",$j)
	if resultJson.errorCode'=0
	{
		Trollback 1
	}else
	{
		Tcommit
	}
	quit resultJson
}

/// Description: 保存角色菜单组建列权限配置信息
/// Output:      组件的信息,Form表单  	
ClassMethod SaveComponetFormAuthConfig(postObj)
{
	new (postObj)
	kill ^TMP("SaveComponetFormAuthConfig",$j)
	try{
		set resultJson={"errorCode":"0","errorMessage":"成功","result":{}}
		set errorCode=0
		set errorMessage=""
		set formData=postObj.formData	 
	    set updateUser=postObj.updateUser	      
	    set typeId=""  	 
	    set type=postObj.type 	
	    set hospID=postObj.hospID
		set groupID=postObj.groupID
		set userID=postObj.userID
		set:updateUser="" updateUser=userID
		set typeId=$case(type,"U":userID,"G":groupID,"H":hospID,:"")
		;用于列配置页面使用
	    set componentName=postObj.componentName	 
		set compontId=$o(^CBReactComponentI("Code",$ZCVT(componentName,"U"),0)) 
		if compontId=""{
			set resultJson.errorCode=-1
			set resultJson.errorMessage="组件id不可为空"
			quit
		}
		TStart
		;//更新插入
		set formiter=formData.%GetIterator()
		while formiter.%GetNext(.key1 , .value1 ) {
		    set rowData=formData.%Get(key1)
		    continue:rowData.display'="Y"   ;//不显示不保存
			set insObj={},data=[]
			set insObj.className="User.HBFormAuth"
			set insObj.updateUserID=updateUser
			set dataobj={}
			set dataobj.Type=type
			set dataobj.DataID=typeId
			set dataobj.ComponentDr=compontId
			set dataobj.UserDr=updateUser
			set:type="G" dataobj.HospitalDr=hospID	;//角色 按医院区分
			set authId=""
			set cellValue=rowData.id
			set authId=$o(^HBFormAuthI("HospType",$ZCVT(type,"U"),typeId,hospID,compontId,cellValue,0)) 
			if (authId'=""){set dataobj.ID=authId}
			set dataobj.ComFormDr=cellValue
			set:cellValue["||" dataobj.ComFormDr=$p(cellValue,"||",2)
			set dataobj.SeqNo=key1+1
			do data.%Push(dataobj)
			set insObj.data=data
			if authId=""
			{ 
				set rtn=##class(src.util.operatetable).Insert(.insObj)
			}
			else
			{
				set rtn=##class(src.util.operatetable).Update(.insObj)
			}
			set errorCode=rtn.errorCode
			set errorMessage=rtn.errorMessage	
			if errorCode=0 {
				
			}else{
				set resultJson.errorMessage=errorMessage
				set resultJson.errorCode=errorCode
				quit 
			}
			set rowID=rtn.rowIDArr.%Get(0)
			set ^TMP("SaveComponetFormAuthConfig",$j,rowID)=rowID
		}
		quit:errorCode'=0
		set cellValue=""
		for
		{
			set cellValue=$o(^HBFormAuthI("HospType",$ZCVT(type,"U"),typeId,hospID,compontId,cellValue))
			quit:cellValue=""
			quit:errorCode'=0
			set authId=""
			for
			{
				set authId=$o(^HBFormAuthI("HospType",$ZCVT(type,"U"),typeId,hospID,compontId,cellValue,authId))
				quit:authId=""
				continue:$g(^TMP("SaveComponetFormAuthConfig",$j,authId))'=""
				set delObj={},data=[]
				set delObj.className="User.HBFormAuth"
				set delObj.updateUserID=userID
				set dataObj={}
				set dataObj.ID=authId
				do data.%Push(dataObj)
				set delObj.data=data
				set rtn=##class(src.util.operatetable).Delete(.delObj) ;调用公共类方法记录修改日记
				set errorCode=rtn.errorCode
				set errorMessage=rtn.errorMessage
				if errorCode'=0
				{
					set resultJson.errorMessage=errorMessage
					set resultJson.errorCode=errorCode
				}
				quit:errorCode'=0
			}
		}
		quit:errorCode'=0
		
	}catch(e){
		set status=e.AsStatus()
	    set resultJson.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultJson.errorMessage=##class(%SYSTEM.Status).GetErrorText(status,"cn")	
	}
	kill ^TMP("SaveComponetFormAuthConfig",$j)
	if resultJson.errorCode'=0
	{
		Trollback 1
	}else
	{
		Tcommit
	}
	quit resultJson
}

/// Description: 保存角色菜单组建列权限配置信息
/// Output:      组件的信息,Button表单  	
ClassMethod SaveComponetButtonAuthConfig(postObj)
{
	new (postObj)
	kill ^TMP("SaveComponetButtonAuthConfig",$j)
	try{
		set resultJson={"errorCode":"0","errorMessage":"成功","result":{}}
		set errorCode=0
		set errorMessage=""
		set buttonData=postObj.buttonData	 
	    set updateUser=postObj.updateUser	      
	    set typeId=""  	 
	    set type=postObj.type 	
	    set hospID=postObj.hospID
		set groupID=postObj.groupID
		set userID=postObj.userID
		set:updateUser="" updateUser=userID
		set typeId=$case(type,"U":userID,"G":groupID,"H":hospID,:"")
		;用于列配置页面使用
	    set componentName=postObj.componentName	 
		set compontId=$o(^CBReactComponentI("Code",$ZCVT(componentName,"U"),0)) 
		if compontId=""{
			set resultJson.errorCode=-1
			set resultJson.errorMessage="组件id不可为空"
			quit
		}
		TStart
		;//更新插入
		set buttoniter=buttonData.%GetIterator()
		while buttoniter.%GetNext(.key1 , .value1 ) {
		    set rowData=buttonData.%Get(key1)
		    continue:rowData.display'="Y"   ;//不显示不保存
			set insObj={},data=[]
			set insObj.className="User.HBButtonAuth"
			set insObj.updateUserID=updateUser
			set dataobj={}
			set dataobj.DataID=typeId
			set dataobj.ComponentDr=compontId
			set dataobj.UserDr=updateUser
			set dataobj.Type=type
			set:type="G" dataobj.HospitalDr=hospID	;//角色 按医院区分
			set authId=""
			set cellValue=rowData.id
			//set authId=$o(^HBButtonAuthI("HospType",$ZCVT(type,"U"),typeId,hospID,compontId,cellValue,0)) 
			if (cellValue'["||"){set dataobj.ID=cellValue,authId=cellValue}
			set:cellValue["||" dataobj.ButtonDr=$p(cellValue,"||",2)
			set dataobj.SeqNo=key1+1
			do data.%Push(dataobj)
			set insObj.data=data
			b 
			if authId=""
			{ 
				set rtn=##class(src.util.operatetable).Insert(.insObj)
			}
			else
			{
				set rtn=##class(src.util.operatetable).Update(.insObj)
			}
			b ;2
			set errorCode=rtn.errorCode
			set errorMessage=rtn.errorMessage	
			if errorCode=0 {
				
			}else{
				set resultJson.errorMessage=errorMessage
				set resultJson.errorCode=errorCode
				quit 
			}
			set rowID=rtn.rowIDArr.%Get(0)
			set ^TMP("SaveComponetButtonAuthConfig",$j,rowID)=rowID
		}
		quit:errorCode'=0
		set cellValue=""
		for
		{
			set cellValue=$o(^HBButtonAuthI("HospType",$ZCVT(type,"U"),typeId,hospID,compontId,cellValue))
			quit:cellValue=""
			quit:errorCode'=0
			set authId=""
			for
			{
				set authId=$o(^HBButtonAuthI("HospType",$ZCVT(type,"U"),typeId,hospID,compontId,cellValue,authId))
				quit:authId=""
				continue:$g(^TMP("SaveComponetButtonAuthConfig",$j,authId))'=""
				set delObj={},data=[]
				set delObj.className="User.HBButtonAuth"
				set delObj.updateUserID=userID
				set dataObj={}
				set dataObj.ID=authId
				do data.%Push(dataObj)
				set delObj.data=data
				set rtn=##class(src.util.operatetable).Delete(.delObj) ;调用公共类方法记录修改日记
				set errorCode=rtn.errorCode
				set errorMessage=rtn.errorMessage
				if errorCode'=0
				{
					set resultJson.errorMessage=errorMessage
					set resultJson.errorCode=errorCode
				}
				quit:errorCode'=0
			}
		}
		quit:errorCode'=0
		
	}catch(e){
		set status=e.AsStatus()
	    set resultJson.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultJson.errorMessage=##class(%SYSTEM.Status).GetErrorText(status,"cn")	
	}
	kill ^TMP("SaveComponetButtonAuthConfig",$j)
	if resultJson.errorCode'=0
	{
		Trollback 1
	}else
	{
		Tcommit
	}
	quit resultJson
}

}
