/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 组件配置相关
Class src.Component.ReactComponent Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 保存组件主表配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).SaveReactComponentConfig()
ClassMethod SaveReactComponentConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set dataObj={},dataArr=[]
		set dataObj.ID=params.id
		set dataObj.Code=params.code
		set dataObj.Descripts=params.descripts
		set dataObj.Path=params.path
		set dataObj.ComAddress=params.comAddress
		set dataObj.Note=params.note
		set dataObj.ENDesc=params.enDesc
		if params.id=""{
			set dataObj.CreateDate=+$h
			set dataObj.CreateUserDr=session.userID
		}
		do dataArr.%Push(dataObj)
		;b	;12121
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className="User.CBReactComponent"			
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

/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 获取组件主表配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).GetReactComponentConfig({"params":[{"hospID":"6","code":"hh","descripts":"xixi"}]})
ClassMethod GetReactComponentConfig(jsonObj) As %Library.DynamicObject
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
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_ReactComponent"		
		if (compareCode'="")||(compareDescripts'="") 
		{
			set sql=sql_" WHERE 1=1"
			set:(compareCode'="") sql=sql_" AND Code LIKE '%"_compareCode_"%'"
			set:(compareDescripts'="") sql=sql_" AND Descripts LIKE '%"_compareDescripts_"%'"
		}
		b	;111
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.path=result.%Get("Path")
			set dataObj.comAddress=result.%Get("ComAddress")
			set dataObj.enDesc=result.%Get("ENDesc")
			set dataObj.note=result.%Get("Note")
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 保存组件table子表配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).SaveReactComTableConfig()
ClassMethod SaveReactComTableConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set dataObj={},dataArr=[]
		set dataObj.ID=params.id
		set dataObj.CBReactComDr=params.reactComID
		set dataObj.Code=params.code
		set dataObj.Descripts=params.descripts
		set dataObj.Type=params.type
		set dataObj.Width=params.width
		set dataObj.SeqNo=params.seqNo
		set dataObj.Display=params.display
		set dataObj.Print=params.print
		set dataObj.Export=params.export
		set dataObj.LinkMethod=params.linkMethod
		set dataObj.LinkService=params.linkService
		set dataObj.Align=params.align
		set dataObj.Fixed=params.fixed
		set dataObj.Visible=params.visible		
		set dataObj.ENDesc=params.enDesc
		set dataObj.FieldTypeDr=params.fieldTypeID
		set dataObj.Params=params.params
		set dataObj.Doubt=params.doubt
		if params.id=""{
			set dataObj.CreateDate=+$h
			set dataObj.CreateUserDr=session.userID
		}
		do dataArr.%Push(dataObj)
		;b	;12121
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className="User.CBReactComTable"			
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

/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 获取组件table子表配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).GetReactComTableConfig({"params":[{"reactComID":"10"}]}).%ToJSON()
ClassMethod GetReactComTableConfig(jsonObj) As %Library.DynamicObject
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
		set reactComID=params.reactComID
		set compareCode=params.code
		set compareDescripts=params.descripts
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT * FROM CB_ReactComTable WHERE CBReactCom_Dr=?"		
		if (compareCode'="")||(compareDescripts'="") 
		{
			set:(compareCode'="") sql=sql_" AND Code LIKE '%"_compareCode_"%'"
			set:(compareDescripts'="") sql=sql_" AND Descripts LIKE '%"_compareDescripts_"%'"
		}
		set sql=sql_" order by SeqNo"
		b	;111
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute(reactComID)		
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.type=result.%Get("Type")
			set dataObj.width=result.%Get("Width")
			set dataObj.seqNo=result.%Get("SeqNo")			
			set dataObj.display=result.%Get("Display")
			set dataObj.print=result.%Get("Print")
			set dataObj.export=result.%Get("Export")
			set dataObj.linkMethod=result.%Get("LinkMethod")
			set dataObj.linkService=result.%Get("LinkService")
			set dataObj.align=result.%Get("Align")
			set dataObj.fixed=result.%Get("Fixed")			
			set dataObj.visible=result.%Get("Visible")
			set dataObj.enDesc=result.%Get("ENDesc")
			set dataObj.doubt=result.%Get("Doubt")
			set dataObj.params=result.%Get("Params")
			set dataObj.fieldTypeID=result.%Get("FieldType_Dr")
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 保存组件field子表配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).SaveReactComFieldConfig()
ClassMethod SaveReactComFieldConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set dataObj={},dataArr=[]
		set dataObj.ID=params.id
		set dataObj.CBReactComDr=params.reactComID
		set dataObj.Code=params.code
		set dataObj.Descripts=params.descripts
		set dataObj.ENDesc=params.enDesc
		set dataObj.Required=params.required
		set dataObj.Message=params.message		
		set dataObj.MessageEN=params.messageEN
		set dataObj.FieldTypeDr=params.fieldTypeID
		set dataObj.Length=params.length
		set dataObj.FocusIndex=params.focusIndex
		set dataObj.Suffix=params.suffix		
		set dataObj.Disabled=params.disabled
		if params.id=""{
			set dataObj.CreateDate=+$h
			set dataObj.CreateUserDr=session.userID
		}
		do dataArr.%Push(dataObj)
		;b	;12121
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className="User.CBReactFormField"			
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

/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 获取组件field子表配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).GetReactComFieldConfig({"params":[{"hospID":"6","code":"hh","descripts":"xixi"}]})
ClassMethod GetReactComFieldConfig(jsonObj) As %Library.DynamicObject
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
		set reactComID=params.reactComID
		set compareCode=params.code
		set compareDescripts=params.descripts
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT FieldType_Dr->Descripts fieldTypeDesc,* FROM CB_ReactFormField WHERE CBReactCom_Dr=?"		
		if (compareCode'="")||(compareDescripts'="") 
		{
			set:(compareCode'="") sql=sql_" AND Code LIKE '%"_compareCode_"%'"
			set:(compareDescripts'="") sql=sql_" AND Descripts LIKE '%"_compareDescripts_"%'"
		}
		b	;111
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute(reactComID)		
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.enDesc=result.%Get("ENDesc")
			set dataObj.required=result.%Get("Required")
			set dataObj.message=result.%Get("Message")	
			set dataObj.messageEN=result.%Get("MessageEN")
			set dataObj.fieldTypeID=result.%Get("FieldType_Dr")
			set dataObj.fieldTypeDrDesc=result.%Get("fieldTypeDesc")
			set dataObj.length=result.%Get("Length")
			set dataObj.focusIndex=result.%Get("FocusIndex")
			set dataObj.suffix=result.%Get("Suffix")
			set dataObj.disabled=result.%Get("Disabled")
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 保存组件form子表配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).SaveReactComFormConfig(a).%ToJSON()
ClassMethod SaveReactComFormConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set arr=params.linkValueID
		set linkValueIDStr=""
		if (arr'="")&&(arr.%Size()>0){
			for i=0:1:arr.%Size()-1{
				if linkValueIDStr=""{
					set linkValueIDStr=arr.%Get(i)
				}else{
					set linkValueIDStr=linkValueIDStr_"^"_arr.%Get(i)
				}
			}
		}
		set dataObj={},dataArr=[]
		set dataObj.ID=params.id
		set dataObj.CBReactComDr=params.reactComID
		set dataObj.Code=params.code
		set dataObj.Descripts=params.descripts
		set dataObj.SeqNo=params.seqNo
		set dataObj.ENDesc=params.enDesc
		set dataObj.Placeholder=params.placeholder		
		set dataObj.FieldTypeDr=params.fieldTypeID
		set dataObj.Callback=params.callback
		set dataObj.Doubt=params.doubt		
		set dataObj.ClassName=params.className
		set dataObj.MethodName=params.methodName
		set dataObj.LinkValueDr=linkValueIDStr
		set dataObj.LinkCode=params.linkCode	
		set dataObj.Col=params.col
		set dataObj.JumpDr=params.jumpID
		set dataObj.LabelCol=params.labelCol
		set dataObj.WrapperCol=params.wrapperCol
		set dataObj.Required=params.required
		set dataObj.Disabled=params.disabled
		set dataObj.Display=params.display
		set dataObj.Valid=params.valid
		set dataObj.Default=params.default
		set dataObj.Params=params.params
		set dataObj.ElementFieldDr=params.elementFieldID
		if params.id=""{
			set dataObj.CreateDate=+$h
			set dataObj.CreateUserDr=session.userID
		}
		do dataArr.%Push(dataObj)
		;b	;12121
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className="User.CBReactForm"			
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

/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 获取组件form子表配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).GetReactComFormConfig({"params":[{"reactComID":"6"}],"pagination":[{"pageSize":10000,"currentPage":1,"sortColumn":"","sortOrder":""}],"code":"01010045","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"a818fm8mEj","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]})
ClassMethod GetReactComFormConfig(jsonObj) As %Library.DynamicObject
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
		set reactComID=params.reactComID
		set compareCode=params.code
		set compareDescripts=params.descripts
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT FieldType_Dr->Descripts fieldTypeDesc,Jump_Dr->Descripts jumpDesc,ElementField_Dr->CustomData_Dr customDataID, ElementField_Dr->CustomDataStr,"_
				"ElementField_Dr->CustomData_Dr->Descripts customDataDesc,* FROM CB_ReactForm WHERE CBReactCom_Dr=?"		
		if compareDescripts'=""{
			set sql=sql_" AND (Code LIKE '%"_compareDescripts_"%' or Descripts LIKE '%"_compareDescripts_"%')"
		}
		set sql=sql_" order by +SeqNo"
		b	;111
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute(reactComID)		
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.descripts=result.%Get("Descripts")
			set dataObj.seqNo=result.%Get("SeqNo")
			set dataObj.enDesc=result.%Get("ENDesc")
			set dataObj.placeholder=result.%Get("Placeholder")
			set dataObj.callback=result.%Get("Callback")	
			set dataObj.doubt=result.%Get("Doubt")
			set dataObj.fieldTypeID=result.%Get("FieldType_Dr")
			set dataObj.fieldTypeDrDesc=result.%Get("fieldTypeDesc")
			set dataObj.className=result.%Get("ClassName")
			set dataObj.methodName=result.%Get("MethodName")			
			set dataObj.col=result.%Get("Col")
			set linkValueIDStr=result.%Get("LinkValue_Dr")
			set arr=[],descStr=""
			;b	;?
			for i=1:1:$l(linkValueIDStr,"^"){
				set linkValueID=$p(linkValueIDStr,"^",i)
				continue:linkValueID=""
				set linkObj=##class(User.CBReactForm).%OpenId(linkValueID)
				continue:'$IsObject(linkObj)
				set descStr=descStr_","_linkObj.Descripts				
				do arr.%Push(linkValueID)
			}
			set dataObj.linkValueID=arr		
			set dataObj.linkValueDesc=descStr
			set dataObj.linkCode=result.%Get("LinkCode")
			set dataObj.jumpID=result.%Get("Jump_Dr")
			set dataObj.jumpDesc=result.%Get("jumpDesc")
			set dataObj.labelCol=result.%Get("LabelCol")
			set dataObj.wrapperCol=result.%Get("WrapperCol")			
			set dataObj.required=result.%Get("Required")
			set dataObj.disabled=result.%Get("Disabled")
			set dataObj.display=result.%Get("Display")
			set dataObj.valid=result.%Get("Valid")
			set dataObj.default=result.%Get("Default")
			set dataObj.params=result.%Get("Params")
			set dataObj.elementFieldID=result.%Get("ElementField_Dr")
			set dataObj.customDataID=result.%Get("customDataID")
			set dataObj.customDataStr=result.%Get("CustomDataStr")
			set dataObj.customDataDesc=result.%Get("customDataDesc")
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 保存组件button子表配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).SaveReactComBtnConfig(a).%ToJSON()
ClassMethod SaveReactComBtnConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set dataObj={},dataArr=[]
		set dataObj.ID=params.id
		set dataObj.CBReactComDr=params.reactComID
		set dataObj.Code=params.code
		set dataObj.Title=params.title
		set dataObj.Icon=params.icon
		set dataObj.OnClick=params.onClick
		set dataObj.TypeDr=params.typeID
		set dataObj.SizeDr=params.sizeID		
		set dataObj.ShapeDr=params.shapeID
		set dataObj.Href=params.href
		set dataObj.Target=params.target
		set dataObj.Ghost=params.ghost
		set dataObj.Block=params.block		
		set dataObj.Valid=params.valid
		if params.id=""{
			set dataObj.CreateDate=+$h
			set dataObj.CreateUserDr=session.userID
		}
		do dataArr.%Push(dataObj)
		;b	;12121
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className="User.CBReactButton"			
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

/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 获取组件button子表配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).GetReactComBtnConfig({"params":[{"hospID":"6","code":"hh","descripts":"xixi"}]})
ClassMethod GetReactComBtnConfig(jsonObj) As %Library.DynamicObject
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
		set reactComID=params.reactComID
		set compareCode=params.code
		set compareDescripts=params.descripts
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT Type_Dr->Descripts typeDesc,Size_Dr->Descripts sizeDesc,Shape_Dr->Descripts shapeDesc,* FROM CB_ReactButton WHERE CBReactCom_Dr=?"		
		if compareDescripts'=""{
			set sql=sql_" AND (Code LIKE '%"_compareDescripts_"%' or Descripts LIKE '%"_compareDescripts_"%')"
		}
		b	;111
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute(reactComID)		
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
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
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 删除组件table配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).DeleteReactComTableConfig()
ClassMethod DeleteReactComTableConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		if params.id="" 
		{
			set resultObj.errorCode="05100128"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")
			quit
		}
		
		set delObj={},data=[]
		set delObj.className="User.CBReactComTable"
		set delObj.updateUserID=userID
		set dataObj={}
		set dataObj.ID=params.id
		do data.%Push(dataObj)
		set delObj.data=data
		;b ;0
		set rtn=##class(src.util.operatetable).Delete(.delObj) ;调用公共类方法记录修改日记
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage		
		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 删除组件field配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).DeleteReactComFieldConfig()
ClassMethod DeleteReactComFieldConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		if params.id="" 
		{
			set resultObj.errorCode="05100128"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")
			quit
		}
		
		set delObj={},data=[]
		set delObj.className="User.CBReactFormField"
		set delObj.updateUserID=userID
		set dataObj={}
		set dataObj.ID=params.id
		do data.%Push(dataObj)
		set delObj.data=data
		;b ;0
		set rtn=##class(src.util.operatetable).Delete(.delObj) ;调用公共类方法记录修改日记
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage		
		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 删除组件Form配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).DeleteReactFormConfig()
ClassMethod DeleteReactFormConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		if params.id="" 
		{
			set resultObj.errorCode="05100128"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")
			quit
		}
		
		set delObj={},data=[]
		set delObj.className="User.CBReactForm"
		set delObj.updateUserID=userID
		set dataObj={}
		set dataObj.ID=params.id
		do data.%Push(dataObj)
		set delObj.data=data
		;b ;0
		set rtn=##class(src.util.operatetable).Delete(.delObj) ;调用公共类方法记录修改日记
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage		
		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-6-30
/// Description: 删除组件button配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).DeleteReactComBtnConfig()
ClassMethod DeleteReactComBtnConfig(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		if params.id="" 
		{
			set resultObj.errorCode="05100128"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("05100128")
			quit
		}
		
		set delObj={},data=[]
		set delObj.className="User.CBReactButton"
		set delObj.updateUserID=userID
		set dataObj={}
		set dataObj.ID=params.id
		do data.%Push(dataObj)
		set delObj.data=data
		;b ;0
		set rtn=##class(src.util.operatetable).Delete(.delObj) ;调用公共类方法记录修改日记
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		set resultObj.errorCode=errorCode
		set resultObj.errorMessage=errorMessage		
		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-7-8
/// Description: 删除组件配置权限
/// Table:     	 HB_TableAuth
/// Input:        
/// Output:       
/// Return:      
/// Others:  w ##class(src.Component.ReactComponent).DeleteComponetAuthConfig(a).%ToJSON()   	
ClassMethod DeleteComponetAuthConfig(jsonObj)
{
	new (jsonObj)
	set postObj=jsonObj.params.%Get(0)
	set session=jsonObj.session.%Get(0)
	set type=""
	set resultObj={}
	set resultObj.errorCode=0
	set resultObj.errorMessage="删除成功!"
	try
	{
		b
		set type=postObj.type
		set hospID=session.hospID
		set groupID=session.groupID
		set userID=session.userID
		set dataID=$case(type,"U":userID,"G":groupID,"H":hospID,:"")
		set compontName=postObj.componentName	 
		set componentID=$o(^CBReactComponentI("Code",$ZCVT(compontName,"U"),0)) 
		quit:(type="")||(dataID="")||(componentID="")
		b
		&sql(delete from SQLUser.HB_TableAuth where Type=:type and DataID=:dataID and Component_Dr=:componentID)
	}catch(e){ 
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    b
	}
	quit resultObj
}

/// 组件维护下拉数据
ClassMethod GetComTableSelectData()
{
	new 
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	try{
		// 类型
		set arr=[]
	    set dataObj={}
		set dataObj.id="C"
	    set dataObj.code="C"
	    set dataObj.descripts="列"
	    do arr.%Push(dataObj)
	    set dataObj={}
		set dataObj.id="B"
	    set dataObj.code="B"
	    set dataObj.descripts="按钮"
	    do arr.%Push(dataObj)
	    set resultObj.typeList=arr
	    
	    set arr=[]
		set dataObj={}
		set dataObj.id="left"
	    set dataObj.code="left"
	    set dataObj.descripts="居左"
	    do arr.%Push(dataObj)
	    set dataObj={}
		set dataObj.id="right"
	    set dataObj.code="right"
	    set dataObj.descripts="居右"
	    do arr.%Push(dataObj)
	    set dataObj={}
		set dataObj.id="center"
	    set dataObj.code="center"
	    set dataObj.descripts="居中"
	    do arr.%Push(dataObj)
	    set resultObj.alignList=arr
	    
	    set arr=[]
		set dataObj={}
		set dataObj.id="left"
	    set dataObj.code="left"
	    set dataObj.descripts="居左"
	    do arr.%Push(dataObj)
	    set dataObj={}
		set dataObj.id="right"
	    set dataObj.code="right"
	    set dataObj.descripts="居右"
	    do arr.%Push(dataObj)
	    set resultObj.fixedList=arr
	    set resultObj.btnTypeList = ##class(src.BasicData.BasicDictionary).GetDictionaryByType({"type":"ButtonType"})
		set resultObj.btnSizeList = ##class(src.BasicData.BasicDictionary).GetDictionaryByType({"type":"ButtonSize"})
		set resultObj.btnShapeList = ##class(src.BasicData.BasicDictionary).GetDictionaryByType({"type":"ButtonShape"})
	    set resultObj.fieldTypeList=..GetFieldType().result
	    
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
		set resultObj.customDataSet=customDataSet
		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// Description: 字段类型下拉
ClassMethod GetFieldType()
{
	new 
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"
	set resultObj.result=[]
	try{
	
		set sql="select ID,Code,Descripts from CB_ConfigFieldType "
		set st=##class(%SQL.Statement).%New(1)
		set sc=st.%Prepare(sql)
		set rs=st.%Execute()
		while rs.%Next(){
			set dataObj={}
			set dataObj.id=rs.%Get("ID")
		    set dataObj.code=rs.%Get("Code")
		    set dataObj.descripts=rs.%Get("Descripts")
		    do resultObj.result.%Push(dataObj)
		}
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}

/// ----------------------------------使用公共接口
/// 通过菜单获取组件的信息,table列或者按钮
/// Output:      组件的信息,table列或者按钮
/// w ##class(src.Component.ReactComponent).GetMenuComponetTableData({"params":[{"menuDetailCode":"01010001"}],"code":"01040074","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"aCE8bSumei","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod GetMenuComponetTableData(jsonObj)
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{"language":{}}}
	set resultList=[],columnArr=[],totalWidth=0
	set errorCode="0",errorMessage=""
	kill sortData
	try{
		set hospID="",groupID="",locID="",userID=""
		if jsonObj.%IsDefined("session"){
			set session=jsonObj.session.%Get(0)
			if session.hospID'=""{
			    set hospID=session.hospID
				set groupID=session.groupID
				set userID=session.userID
			}
		}else{
		    set hospID=1
			set groupID=1
			set userID=1
		}
		set params=jsonObj.params.%Get(0)
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
		set menuDetailComponentDr=""
		for
		{
			set menuDetailComponentDr=$o(^CBMenuDetailComponentI("MenuDetail",menuDetailId,menuDetailComponentDr))
			quit:menuDetailComponentDr=""
			set menuDetailComponentobj=##class(User.CBMenuDetailComponent).%OpenId(menuDetailComponentDr)
			set paramsobj={
				"params":[{
					"componentName":(menuDetailComponentobj.ReactComponentDr.Code)
					}],
					"code":"01040073",
					"session":(jsonObj.session)
				}
			set componetTableobj=##class(src.Component.ReactComponent).GetComponetTableData(paramsobj)
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

/// Output:      组件的信息,table列或者按钮
/// w ##class(src.Component.ReactComponent).GetComponetTableData({"params":[{"businessFlag":"Y","componentName":"MenuDetailMaintenance","saveType":"U","language":""}],"code":"01040073","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"ugQPGZGnZu","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]}).%ToJSON()
ClassMethod GetComponetTableData(jsonObj)
{
	new (jsonObj)
	set ^TMP("GetComponetTableData")=jsonObj.%ToJSON()
	set resultObj={"errorCode":"0","errorMessage":""}	
	set errorCode="0",errorMessage=""
	kill sortData
	try{
		set hospID="",groupID="",locID="",userID=""
		if jsonObj.%IsDefined("session"){
			set session=jsonObj.session.%Get(0)
			if session.hospID'=""{
			    set hospID=session.hospID
				set groupID=session.groupID
				set userID=session.userID
			}
		}else{
		    set hospID=1
			set groupID=1
			set userID=1
		}
		b	;??
		set params=jsonObj.params.%Get(0)
		set componentName=params.componentName
		set componentArr=params.componentArr
		set businessFlag=params.businessFlag    ;//是否配置界面
		if $IsObject(componentArr){
			set resultArr=[]
			for i=0:1:componentArr.%Size()-1
			{
				set buttonArr=[],columnArr=[],totalWidth=0
				set componentName=componentArr.%Get(i)
				set compontId=$o(^CBReactComponentI("Code",$ZCVT(componentName,"U"),0)) 
				if compontId=""{
					set resultObj.errorCode="01040102"
					set resultObj.errorMessage="未维护组件信息"
					quit 
				}
				quit:resultObj.errorCode'=0
				do GetComponentInfo
				set result={"language":{}}
				set result.language.CN=$g(CN)	
				set result.B=buttonArr
				set result.C=columnArr
				set result.formData=formData
				set result.buttonData=buttonData
				set result.totalWidth=totalWidth_"px"
				set result.componentCode=componentName
				set result.dataIndex=componentName
				do resultArr.%Push(result)
			}
			set resultObj.result=resultArr
			quit
		}	
		if componentName'=""{
			set buttonArr=[],columnArr=[],totalWidth=0
			;set searchType=params.type
			set compontId=$o(^CBReactComponentI("Code",$ZCVT(componentName,"U"),0)) 
			if compontId=""{
				set resultObj.errorCode="01040102"
				set resultObj.errorMessage="未维护组件信息"
				quit 
			}
			do GetComponentInfo
			set result={"language":{}}
			set result.language.CN=$g(CN)	
			set result.B=buttonArr
			set result.C=columnArr
			set result.formData=formData
			set result.buttonData=buttonData
			set resultObj.result=result
			set resultObj.totalWidth=totalWidth_"px"
			quit
		}		
				
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    b	;11
	}
	quit resultObj
	
GetComponentInfo
	set typeStr="U^G^H" //用户,角色,医院

	set sub="" 
	set result=[]
	set sequence=0
	set nullSeqNo=99999 //未维护列顺序,从99999开始
	set colId=""
	set type="C"
	//判断医院角色 是否存在
	if ($d(^HBTableAuthI("HospType","G",groupID,hospID,compontId)))
	{
		set tStatement = ##class(%SQL.Statement).%New(1)   
		set sql="SELECT * FROM HB_TableAuth where Component_Dr='"_compontId_"' and Type='G' and DataID='"_groupID_"' and Hospital_Dr='"_hospID_"'"
		set sql=sql_" order by Type,SeqNo"
		set sc=tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){
			set id=result.%Get("ID")
			set seqNo=result.%Get("SeqNo")
			set type=result.%Get("Type")
			if +seqNo="0" set seqNo=id
			set sortData("reactData","C",seqNo,id)=id
		}
	}else{
		set tStatement = ##class(%SQL.Statement).%New(1)   
		set sql="SELECT * FROM CB_ReactComTable where CBReactCom_Dr='"_compontId_"'"
		set sql=sql_" order by Type,SeqNo"
		b	;qwq1
		set sc=tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){
			set id=result.%Get("ID")
			set seqNo=result.%Get("SeqNo")
			set type=result.%Get("Type")
			if +seqNo="0" set seqNo=id
			set sortData("reactData",type,seqNo,compontId_"||"_id)=compontId_"||"_id
		}
	}
	b ;
	set type="C"
	set typeData=[]
	set seqNo=""
	for{
		set seqNo=$O(sortData("reactData",type,seqNo))
		quit:seqNo=""
		set dataID=""
		for {
			set dataID=$o(sortData("reactData",type,seqNo,dataID))
			quit:dataID=""
			if dataID["||"{
				//未维护权限
				set data=$g(^CBReactComTableD($P(dataID,"||",2)))
				set id=$P(dataID,"||",2)
				set descripts=$lg(data,4)
				set width=$lg(data,6)
				set align=$lg(data,13)
				set enDescripts=""
				set export=$lg(data,10)
				set diaplay=$lg(data,8)
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
				set export=$lg(data,9)
				set diaplay=$lg(authData,7)
				set encrypt=$lg(authData,17)
			}
			///(Type, DataID, ComponentDr, ComTableDr)
			//判断个人配置
			if $d(^HBTableAuthI("Type","U",userID,compontId,id))
			{
				set userTableAuthDR=$o(^HBTableAuthI("Type","U",userID,compontId,id,""))
				if userTableAuthDR'=""
				{
					set userauthData=$g(^HBTableAuthD(userTableAuthDR))
					set export=$lg(userauthData,9)
					set diaplay=$lg(userauthData,7)
					
				}
			}
			continue:(diaplay="N")&(businessFlag'="Y")
			set sequence=sequence+1
			set dataObj={}
			set dataObj.id=id
			set dataObj.code=$lg(data,3)
			set dataObj.descripts=descripts
			set dataObj.dataIndex=$lg(data,3)
			set dataObj.display=diaplay
			set dataObj.encrypt=$g(encrypt)
			set dataObj.enDescripts=""	
			set dataObj.export=export
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
		do CN.%Set(result.%Get("Code"),obj)
	}
	// Form
	set compontData={}
	set typeStr="U^G^H" //用户,角色,医院
	set saveType="-1",saveTypeId="-1"
	i hospID'=""{
		for len=1:1:$L(typeStr,"^")
		{
			set saveType=$P(typeStr,"^",len)
			set saveTypeId=$case(saveType,"U":userID,"D":locID,"G":groupID,"H":hospID,:"")
			
			set id=$O(^HBFormAuthI("HospType",$ZCVT(saveType,"U"),saveTypeId,hospID,compontId,0))	;//区分医院
			if id=""
			{
				set id=$O(^HBFormAuthI("Type",$ZCVT(saveType,"U"),saveTypeId,compontId,0))
			}
			if id'="" quit 
		}
	}
	kill sortData
	set sub="" 
	set formData=[]
	set sequence=0
	set nullSeqNo=99999 //未维护列顺序,从99999开始
	
	//判断医院角色 是否存在
	if ($d(^HBFormAuthI("HospType","G",groupID,hospID,compontId)))
	{
		set tStatement = ##class(%SQL.Statement).%New(1)   
		set sql="SELECT * FROM HB_FormAuth where Component_Dr='"_compontId_"' and Type='G' and DataID='"_groupID_"' and Hospital_Dr='"_hospID_"'"
		set sql=sql_" order by Type,SeqNo"
		set sc=tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){
			set authId=result.%Get("ID")
			set data=$g(^HBFormAuthD(authId))
			set seqNo=result.%Get("SeqNo")
			if +seqNo="0" set seqNo=nullSeqNo,nullSeqNo=+nullSeqNo+1
			set sortData("FormData",seqNo,authId)=""
		}
	}else{
		//没有维护安全组配置
		set tStatement = ##class(%SQL.Statement).%New(1)   
		set sql="SELECT * FROM CB_ReactForm where CBReactCom_Dr->Code ='"_componentName_"'"
		set sql=sql_" order by SeqNo"
		b	;qwq1
		set sc=tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){					
			set seqNo=result.%Get("SeqNo")
			if +seqNo="0" set seqNo=nullSeqNo,nullSeqNo=+nullSeqNo+1
			set sortData("FormData",seqNo,compontId_"||"_result.%Get("ID"))=""
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
			if id["||"{
				//未维护权限
				set data=$g(^CBReactFormD($P(id,"||",2)))				
			}else{
				set authData=$g(^HBFormAuthD(id))
				set formID=$lg(authData,5)
				set data=$g(^CBReactFormD(formID))
				;set col=$lg(authData,7)
				;set jumpID=$lg(authData,8) 					
				;set labelCol=$lg(authData,9)
				;set wrapperCol=$lg(authData,10)
			}
			set col=$lg(data,14)
			set jumpID=$lg(data,15) 					
			set labelCol=$lg(data,16)
			set wrapperCol=$lg(data,17)
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
				set reactFormObj=##class(User.CBReactForm).%OpenId(linkValueID)
				if reactFormObj'=""{
					set linkValueCode=##class(User.CBReactForm).%OpenId(linkValueID).Code
					do linkValueCodeArr.%Push(linkValueCode)
					do linkValueIDArr.%Push(linkValueID)
				}
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
			set itemData.display=$lg(data,20)
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
	// 新button
	set buttonData=[]
	//判断医院角色 是否存在
	if ($d(^HBButtonAuthI("HospType","G",groupID,hospID,compontId)))
	{
		set tStatement = ##class(%SQL.Statement).%New(1)   
		set sql="SELECT * FROM HB_ButtonAuth where Component_Dr='"_compontId_"' and Type='G' and DataID='"_groupID_"' and Hospital_Dr='"_hospID_"'"
		set sc=tStatement.%Prepare(sql)
		set result=tStatement.%Execute()		
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set buttonDr=result.%Get("Button_Dr")
			set Buttonobj=##class(User.CBReactButton).%OpenId(buttonDr)
			set dataObj.title=Buttonobj.Title
			set dataObj.icon=Buttonobj.Icon
			set dataObj.onClick=Buttonobj.OnClick
			set:Buttonobj.TypeDr'="" dataObj.typeID=Buttonobj.TypeDr.%Id()
			set:Buttonobj.TypeDr'="" dataObj.typeDesc=Buttonobj.TypeDr.Descripts
			set:Buttonobj.SizeDr'="" dataObj.sizeID=Buttonobj.SizeDr.%Id()
			set:Buttonobj.SizeDr'="" dataObj.sizeDesc=Buttonobj.SizeDr.Descripts
			set:Buttonobj.ShapeDr'="" dataObj.shapeID=Buttonobj.ShapeDr.%Id()
			set:Buttonobj.ShapeDr'="" dataObj.shapeDesc=Buttonobj.ShapeDr.Descripts
			set dataObj.href=Buttonobj.Href
			set dataObj.target=Buttonobj.Target
			set dataObj.ghost=Buttonobj.Ghost
			set dataObj.block=Buttonobj.Block
			set dataObj.valid=Buttonobj.Valid			
			do buttonData.%Push(dataObj)
		}
	}else{
		//没有维护安全组配置
		set tStatement = ##class(%SQL.Statement).%New(1)
		set sql="SELECT Type_Dr->Descripts typeDesc,Size_Dr->Descripts sizeDesc,Shape_Dr->Descripts shapeDesc,* FROM CB_ReactButton WHERE CBRB_ParRef=?"
		;b	;111
		do tStatement.%Prepare(sql)
		set result=tStatement.%Execute(compontId)		
		while result.%Next(.sc){
			set dataObj={}
			set dataObj.id=compontId_"||"_result.%Get("ID")
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
			do buttonData.%Push(dataObj)
		}
	}
	
	
	
	
	set compontData.buttonData=buttonData
	quit
}

/// Output: 组件维护表Form表单子表的数据
ClassMethod GetComponetFormField(inputObj) As %Library.DynamicObject
{
	new (inputObj) 
	set postParams=inputObj.params.%Get(0)
	set session=inputObj.session.%Get(0)
	set componentName=postParams.componentName	; 组件名称 
	set hospID=session.hospID
	set resultObj={} 
	set resultObj.errorCode="0",resultObj.errorMessage="",resultObj.result={}
	set compontId=$o(^CBReactComponentI("Code",$ZCVT(componentName,"U"),0)) 
	if compontId=""{
		set resultJson.errorCode="01040102"
		set resultJson.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040102")
		quit resultJson
	}  
	try{
		//维护配置
		set FormFieldID=""
		 for{
				set FormFieldID=$o(^CBReactFormFieldI("Component",compontId,FormFieldID))
				Quit:FormFieldID=""
				set dataobj=##class(User.CBReactFormField).%OpenId(id)
				set Disabled=$lg(data,6)
				continue:type'=searchType&(searchType'="") 
		
				set code = dataobj.ComponentDr.Code_dataobj.Code
				set EndataObj={} 
				set CNdataObj={}  
				set CNdataObj.descripts=dataobj.Descripts  
				set CNdataObj.message=dataobj.Message
				set CNdataObj.required=dataobj.Required
				set CNdataObj.legth = dataobj.Length
				set CNdataObj.suffix = dataobj.Suffix  
				set CNdataObj.focusIndex = dataobj.FocusIndex 
				set $PROPERTY(CN,code)=CNdataObj
		}
		set data={}
		set data.CN=CN
		set resultObj.result=data
	}catch(e){
		b
		Set status=e.AsStatus()
	    set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=##class(%SYSTEM.Status).GetErrorText(status,"cn")	
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2022-07-08
/// Description: 保存组建列权限配置信息
/// Table:     	 CB_ReactComTable
/// Input:       {'compontId':1}
/// Output:      组件的信息,table列或者按钮
/// Return:      
/// Others:     
/// Debug：		 w ##class(src.Component.ReactComponent).SaveComponetAuthConfig(a).%ToJSON()	
ClassMethod SaveComponetAuthConfig(jsonObj)
{
	new (jsonObj)
	try{
		set resultJson={"errorCode":"0","errorMessage":"成功","result":{}}
		set postObj=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set tableData=postObj.tableData	 
	    set updateUser=postObj.updateUser	      
	    set typeId=""  	 
	    set type=postObj.type 	
	    set hospID=session.hospID
		set groupID=session.groupID
		set userID=session.userID
		set language=postObj.language
		set typeId=$case(type,"U":userID,"G":groupID,"H":hospID,:"")
		;用于列配置页面使用
		set:(postObj.typeDataID'="") typeId=postObj.typeDataID
	    set componentName=postObj.componentName	 
		set compontId=$o(^CBReactComponentI("Code",$ZCVT(componentName,"U"),0)) 
		set resultJson={}
		set resultJson.errorCode=0
		set resultJson.errorMessage=""
		if compontId=""{
			set resultJson.errorCode=-1
			set resultJson.errorMessage="组件id不可为空"
			quit
		}
		set tableiter=tableData.%GetIterator()
		while tableiter.%GetNext(.key , .value ) {
			set subIter=value.%GetIterator() //列数据
			set insObj={},data=[]
			set insObj.className="User.HBTableAuth"
			set insObj.updateUserID=updateUser
			set dataobj={}
			set dataobj.Type=type
			set dataobj.DataID=typeId
			set dataobj.ComponentDr=compontId
			set dataobj.UserDr=updateUser
			set:type="G" dataobj.HospitalDr=hospID	;//角色 按医院区分
			set authId=""
			while subIter.%GetNext(.code,.colData) {
			  continue:code="TotalCount" 
			  if (code="id")
			  {
				set authId=$o(^HBTableAuthI("Type",$ZCVT(type,"U"),typeId,compontId,colData,0)) 
				if (authId'=""){set dataobj.ID=authId}
				set dataobj.ComTableDr=colData
		      }
		      if (code="display") set dataobj.Display=colData
			  if (code="print") set dataobj.Print=colData
			  if (code="export") set dataobj.Export=colData
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
			;b ;111
			set dataobj.SeqNo=key+1
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
			;b ;9090
			set errorCode=rtn.errorCode
			set errorMessage=rtn.errorMessage	
			if errorCode=0 {
				
			}else{
				set resultJson={}
				set resultJson.errorMessage=errorMessage
				set resultJson.errorCode=errorCode
				Trollback 1
				quit 
			}
		}
	}catch(e){
		set status=e.AsStatus()
	    set resultJson.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultJson.errorMessage=##class(%SYSTEM.Status).GetErrorText(status,"cn")	
	    b	;err
	}
	quit resultJson
}

/// Creator:     TC
/// CreatDate:   2023-05-01
/// Description: 组件数据排序
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).SaveReactComSeq(a)
ClassMethod SaveReactComSeq(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	TStart
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set sortArr=params.sortArr
		set dataArr=[]
		for i=0:1:sortArr.%Size()-1{
			set sortObj=sortArr.%Get(i)
			set dataObj={}
			set dataObj.ID=sortObj.id		
			set dataObj.SeqNo=sortObj.seqNo		
			do dataArr.%Push(dataObj)
		}
		;b	;12121
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className=params.className		
		set operateObj.data=dataArr	
		;b	;??	
		set rtn=##class(src.util.operatetable).Update(.operateObj) ;调用公共类方法记录修改日记
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		if errorCode'="0"{
			Trollback 1
			set resultObj.errorCode=errorCode
			set resultObj.errorMessage=errorMessage
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

/// Creator:     TC
/// CreatDate:   2023-05-01
/// Description: 复制组件
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).CopyComponent(a)
ClassMethod CopyComponent(jsonObj)
{
	new (jsonObj)
	set params=jsonObj.params.%Get(0)
	set session=jsonObj.session.%Get(0)
	set fromComponentID=params.fromComponentID
	set toComponentID=params.toComponentID
	set data=params.data
	set type=params.type
	set resultObj={"errorCode":0,"errorMessage":"","result":{}}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"	
	try{	
		set tableName=$case(type,"table":"User.CBReactComTable","field":"User.CBReactFormField","form":"User.CBReactForm","button":"User.CBReactButton",:"")
		if tableName=""{
			set resultObj.errorCode=-1
			set resultObj.errorMessage="类型错误！"
			quit
		}
		set dataArr=[]
		// 不选复制全部
		if data.%Size()=0
		{
			set tStatement = ##class(%SQL.Statement).%New(1)
			if type="table"{				
				set sql="SELECT ID,Code FROM CB_ReactComTable WHERE CBReactCom_Dr=?"	
				do tStatement.%Prepare(sql)
				set rs=tStatement.%Execute(fromComponentID)		
				while rs.%Next(.sc){
					set dataObj=""
					set sc = ##class(User.CBReactComTable).%OpenId(rs.%Get("ID")).ToDynamicObj(.dataObj)
					do dataObj.%Remove("ID")
					set dataObj.CBReactComDr=toComponentID
					set code=rs.%Get("Code")
					continue:$d(^CBReactComTableI("Code",toComponentID,$zcvt(code,"U")))					
					do:$IsObject(dataObj) dataArr.%Push(dataObj)
				}
			}
			if type="field"{
				set sql="SELECT ID,Code FROM CB_ReactFormField WHERE CBReactCom_Dr=?"	
				do tStatement.%Prepare(sql)
				set rs=tStatement.%Execute(fromComponentID)		
				while rs.%Next(.sc){
					set dataObj=""
					set sc = ##class(User.CBReactFormField).%OpenId(rs.%Get("ID")).ToDynamicObj(.dataObj)
					do dataObj.%Remove("ID")
					set dataObj.CBReactComDr=toComponentID
					set code=rs.%Get("Code")
					continue:$d(^CBReactFormFieldI("Code",toComponentID,$zcvt(code,"U")))					
					set dataObj.CreateDate=+$h
					set dataObj.CreateUserDr=session.userID
					do dataArr.%Push(dataObj)
				}
			}
			if type="form"{
				set sql="SELECT * FROM CB_ReactForm WHERE CBReactCom_Dr=?"	
				do tStatement.%Prepare(sql)
				set rs=tStatement.%Execute(fromComponentID)		
				while rs.%Next(.sc){
					set dataObj=""
					set sc = ##class(User.CBReactForm).%OpenId(rs.%Get("ID")).ToDynamicObj(.dataObj)
					do dataObj.%Remove("ID")
					set dataObj.CBReactComDr=toComponentID
					set code=rs.%Get("Code")
					continue:$d(^CBReactFormI("Code",toComponentID,$zcvt(code,"U")))
					set dataObj.CreateDate=+$h
					set dataObj.CreateUserDr=session.userID
					do dataArr.%Push(dataObj)
				}
			}
			if type="button"{
				set sql="SELECT * FROM CB_ReactButton WHERE CBRB_ParRef=?"	
				do tStatement.%Prepare(sql)
				set rs=tStatement.%Execute(fromComponentID)		
				while rs.%Next(.sc){
					set dataObj=""
					set sc = ##class(User.CBReactButton).%OpenId(rs.%Get("ID")).ToDynamicObj(.dataObj)
					do dataObj.%Remove("ID")
					set dataObj.CBReactComDr=toComponentID
					set dataObj.CreateDate=+$h
					set dataObj.CreateUserDr=session.userID
					do dataArr.%Push(dataObj)
				}
			}
		}else{		
			b ;part	
			set iter=data.%GetIterator()
			if type="table"{				
				while iter.%GetNext(.key,.val){	
					set dataObj=""
					continue:'($d(^CBReactComTableD(val)))
					set sc = ##class(User.CBReactComTable).%OpenId(val).ToDynamicObj(.dataObj)
					do dataObj.%Remove("ID")
					set dataObj.CBReactComDr=toComponentID
					set code=dataObj.Code
					continue:$d(^CBReactComTableI("Code",toComponentID,$zcvt(val.Code,"U")))					
					do dataArr.%Push(dataObj)
				}
			}	
			if type="field"{				
				while iter.%GetNext(.key,.val){	
					set dataObj=""
					continue:'($d(^CBReactFormFieldD(val)))
					set sc = ##class(User.CBReactFormField).%OpenId(val).ToDynamicObj(.dataObj)
					do dataObj.%Remove("ID")
					set dataObj.CBReactComDr=toComponentID
					set code=dataObj.Code
					continue:$d(^CBReactFormFieldI("Code",toComponentID,$zcvt(val.Code,"U")))					
					set dataObj.CreateDate=+$h
					set dataObj.CreateUserDr=session.userID
					do dataArr.%Push(dataObj)
				}
			}
			if type="form"{				
				while iter.%GetNext(.key,.val){
					set dataObj=""
					continue:'($d(^CBReactFormD(val)))
					set sc = ##class(User.CBReactForm).%OpenId(val).ToDynamicObj(.dataObj)
					do dataObj.%Remove("ID")
					set dataObj.CBReactComDr=toComponentID
					set code=dataObj.Code
					continue:$d(^CBReactFormI("Code",toComponentID,$zcvt(code,"U")))					
					set dataObj.CreateDate=+$h
					set dataObj.CreateUserDr=session.userID					
					do dataArr.%Push(dataObj)
				}
				b ;part form ok
			}
			if type="button"{
				set sql="SELECT * FROM CB_ReactButton WHERE CBReactCom_Dr=?"	
				do tStatement.%Prepare(sql)
				set rs=tStatement.%Execute(fromComponentID)		
				while rs.%Next(.sc){
					set dataObj=""
					continue:'($d(^CBReactButtonD(val)))
					set sc = ##class(User.CBReactButton).%OpenId(val).ToDynamicObj(.dataObj)
					do dataObj.%Remove("ID")
					set dataObj.CBReactComDr=toComponentID				
					set dataObj.CreateDate=+$h
					set dataObj.CreateUserDr=session.userID
					do dataArr.%Push(dataObj)
				}
			}
			b ;part ok		
		}
		Tstart
		set operateObj={}
		set operateObj.updateUserID=session.userID
		set operateObj.className=tableName			
		set operateObj.data=dataArr			
		set rtn=##class(src.util.operatetable).Insert(.operateObj) ;调用公共类方法记录修改日记
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		if errorCode'="0"{
			Trollback 1
			set resultObj.errorCode=errorCode
			set resultObj.errorMessage=errorMessage
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

/// Creator:     TC
/// CreatDate:   2024-05-07
/// Description: 
/// Table:     	 
/// Input:       
/// Output:      获取角色级别及组件编辑权限
/// Return:      
/// Others:   
ClassMethod GetGroupAuthLevel(jsonObj)
{
	new (jsonObj)
	set session=jsonObj.session.%Get(0)
	set resultJson={}
	set resultJson.errorCode=0 
	set resultJson.errorMessage=""
	set groupID=session.groupID
	set groupData=$g(^CBGroupD(groupID))
	set data={}
	set editFlag=$lg(groupData,8)
	set groupLevel=$lg(groupData,7)
	set Common="保存公共"
	set hosAuth="按医院保存"
	set Group="按角色保存"
	set User="按用户保存"
	set authList=[]
	if (groupLevel>6){
		set obj={}
		set obj.value="C",obj.descripts=Common
		do authList.%Push(obj)
		set obj={}
		set obj.value="H",obj.descripts=hosAuth
		do authList.%Push(obj)
		set obj={}
		set obj.value="G",obj.descripts=Group
		do authList.%Push(obj)
		set obj={}
		set obj.value="U",obj.descripts=User
		do authList.%Push(obj)
	}elseif (groupLevel>5){
		set obj={}
		set obj.value="C",obj.descripts=Common
		do authList.%Push(obj)
		set obj={}
		set obj.value="H",obj.descripts=hosAuth
		do authList.%Push(obj)
		set obj={}
		set obj.value="G",obj.descripts=Group
		do authList.%Push(obj)
		set obj={}
		set obj.value="U",obj.descripts=User
		do authList.%Push(obj)
	}else{
		set obj={}
		set obj.value="U",obj.descripts=User
		do authList.%Push(obj)
		
	}
	
	
	set data.editFlag=editFlag
	set data.authList=authList
	set resultJson.result=data 
	quit resultJson
}

/// Description: 关联字段下拉
/// w ##class(src.Component.ReactComponent).GetLinkFieldList({"params":[{"componentID":"6","fieldID":""}],"code":"01040288","session":[{"userID":"158","locID":1,"groupID":"1","hospID":"8","sessionID":"L3NutIckon","hospCode":"12344","language":"","hostName":"","ipv4":"","ipv6":"","mac":""}]})
ClassMethod GetLinkFieldList(jsonObj)
{
	new (jsonObj)
	set params=jsonObj.params.%Get(0)
	set componentID=params.componentID
	set fieldID=params.fieldID
	set componentName=params.componentName
	set:componentID="" componentID=$o(^CBReactComponentI("Code",$ZCVT(componentName,"U"),0)) 
	if componentID="" quit {"errorCode":-1,"errorMessage":"未找到对应组件！"}
	set resultObj={"errorCode":0,"errorMessage":"","result":{}}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="成功"	
	try{	
		set arr=[]
		;set sql="select ID,Code,Descripts from CB_ReactForm where CBRF_ParRef=? and FieldType_Dr->Code = 'Select' "
		set sql="select ID,Code,Descripts from CB_ReactForm where CBReactCom_Dr=? "
		set:fieldID'="" sql=sql_"and ID <> '"_fieldID_"'"
		set st=##class(%SQL.Statement).%New(1)
		set sc=st.%Prepare(sql)
		set rs=st.%Execute(componentID)
		while rs.%Next(){
			set dataObj={}
			set dataObj.id=rs.%Get("ID")
		    set dataObj.code=rs.%Get("Code")
		    set dataObj.descripts=rs.%Get("Descripts")
		    do arr.%Push(dataObj)
		}
		set resultObj.result.linkValueID=arr
		set data=[]
		set sql="select ID,Code,Descripts from CB_ReactForm where CBReactCom_Dr=? "
		set:fieldID'="" sql=sql_"and ID <>'"_fieldID_"'"
		set st=##class(%SQL.Statement).%New(1)
		set sc=st.%Prepare(sql)
		set rs=st.%Execute(componentID)
		while rs.%Next(){
			set dataObj={}
			set dataObj.id=rs.%Get("ID")
		    set dataObj.code=rs.%Get("Code")
		    set dataObj.descripts=rs.%Get("Descripts")
		    do data.%Push(dataObj)
		}
		set resultObj.result.jumpID=data
	}catch(e){
		set status=e.AsStatus()
    	set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")	
	    set errorInfo="获取字段类型下拉出错:w ##class("_$ClassName()_").GetLinkFieldList()"
		do ##class(src.Interface.Message).InsErrRecord("01040044",errorInfo,errorMessage)
		set resultObj.errorCode="01040044"
	    set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01040044")	
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2024-06-01
/// Description: 保存组件整合
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).SaveReactComponentInteger(a).%ToJSON()
ClassMethod SaveReactComponentInteger(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set errorCode=0	
	try{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		Tstart
		set reactData=params.reactData
		set iter=reactData.%GetIterator()
		while iter.%GetNext(.key,.val)
		{
			// 主表信息
			set code=val.code
			set descripts=val.descripts
			set path=val.path
			set comAddress=val.comAddress
			set note=val.note
			set id=$O(^CBReactComponentI("Code",$zcvt(code,"U"),0))
			set dataObj={},dataArr=[]
			set dataObj.ID=id
			set dataObj.Code=code
			set dataObj.Descripts=descripts
			set dataObj.Path=path
			set dataObj.ComAddress=comAddress
			set dataObj.Note=note
			if id=""{
				set dataObj.CreateDate=+$h
				set dataObj.CreateUserDr=userID
			}
			do dataArr.%Push(dataObj)
			set operateObj={}
			set operateObj.updateUserID=session.userID
			set operateObj.className="User.CBReactComponent"			
			set operateObj.data=dataArr		
			if id=""{
				set rtn=##class(src.util.operatetable).Insert(.operateObj) ;调用公共类方法记录修改日记
			}else{				
				set rtn=##class(src.util.operatetable).Update(.operateObj) ;调用公共类方法记录修改日记
			}
			set errorCode=rtn.errorCode
			set errorMessage=rtn.errorMessage		
			if errorCode'="0"{
				Trollback 1
				set resultObj.errorCode=errorCode
				set resultObj.errorMessage=errorMessage
				quit
			}
			set reactID=rtn.rowIDArr.%Get(0)
			do resultObj.result.%Set(code,reactID)
			// table
			if (val.%IsDefined("tableData"))&&(val.tableData.%Size()>0){
				set tableData=val.tableData
				set insArr=[],updArr=[],delArr=[]
				for i=0:1:tableData.%Size()-1
				{
					set record=tableData.%Get(i)
					set tableID=$O(^CBReactComTableI("Code",reactID,$zcvt(record.code,"U"),0))
					set dataObj={}
					set dataObj.ID=tableID
					if (record.deleteFlag="Y")&&(tableID'=""){
						do delArr.%Push(dataObj)
						continue
					}
					set dataObj.CBReactComDr=reactID
					set dataObj.Code=record.code
					set dataObj.Descripts=record.descripts
					set dataObj.Type=record.type
					set dataObj.Width=record.width
					set dataObj.SeqNo=record.seqNo
					set dataObj.Display=record.display
					set dataObj.Print=record.print
					set dataObj.Export=record.export
					set dataObj.LinkMethod=record.linkMethod
					set dataObj.LinkService=record.linkService
					set dataObj.Align=record.align
					set dataObj.Fixed=record.fixed
					set dataObj.Visible=record.visible		
					set dataObj.ENDesc=record.enDesc
					set dataObj.FieldTypeDr=record.fieldTypeID
					set dataObj.Params=record.params
					set dataObj.Doubt=record.doubt
					if tableID=""{
						set dataObj.CreateDate=+$h
						set dataObj.CreateUserDr=userID
						do insArr.%Push(dataObj)
					}else{
						do updArr.%Push(dataObj)
					}
					;b	;12121
				}
				set operateObj={}
				set operateObj.updateUserID=userID
				set operateObj.className="User.CBReactComTable"	
				if insArr.%Size()>0{
					set operateObj.data=insArr
					set rtn=##class(src.util.operatetable).Insert(.operateObj) 
					set errorCode=rtn.errorCode
					set errorMessage=rtn.errorMessage
					if errorCode'="0"{
						Trollback 1
						set resultObj.errorCode=errorCode
						set resultObj.errorMessage=errorMessage
						quit
					}
				}		
				if updArr.%Size()>0{
					set operateObj.data=updArr
					set rtn=##class(src.util.operatetable).Update(.operateObj) 
					set errorCode=rtn.errorCode
					set errorMessage=rtn.errorMessage
					if errorCode'="0"{
						Trollback 1
						set resultObj.errorCode=errorCode
						set resultObj.errorMessage=errorMessage
						quit
					}
				}
				if delArr.%Size()>0{
					set operateObj.data=delArr
					set rtn=##class(src.util.operatetable).Delete(.operateObj) 
					set errorCode=rtn.errorCode
					set errorMessage=rtn.errorMessage
					if errorCode'="0"{
						Trollback 1
						set resultObj.errorCode=errorCode
						set resultObj.errorMessage=errorMessage
						quit
					}
				}
			}
			quit:errorCode'=0	
			// form
			if (val.%IsDefined("formData"))&&(val.formData.%Size()>0){
				set formData=val.formData
				set insArr=[],updArr=[],delArr=[]
				for i=0:1:formData.%Size()-1
				{
					set record=formData.%Get(i)
					set formID=$O(^CBReactFormI("Code",reactID,$zcvt(record.code,"U"),0))
					set dataObj={}
					set dataObj.ID=formID
					if (record.deleteFlag="Y")&&(formID'=""){
						do delArr.%Push(dataObj)
						continue
					}
					set arr=record.linkValueID
					set linkValueIDStr=""
					if (arr'="")&&(arr.%Size()>0){
						for j=0:1:arr.%Size()-1{
							if linkValueIDStr=""{
								set linkValueIDStr=arr.%Get(j)
							}else{
								set linkValueIDStr=linkValueIDStr_"^"_arr.%Get(j)
							}
						}
					}
					set dataObj.ID=formID
					set dataObj.CBReactComDr=reactID
					set dataObj.Code=record.code
					set dataObj.Descripts=record.descripts
					set dataObj.SeqNo=record.seqNo
					set dataObj.ENDesc=record.enDesc
					set dataObj.Placeholder=record.placeholder		
					set dataObj.FieldTypeDr=record.fieldTypeID
					set dataObj.Callback=record.callback
					set dataObj.Doubt=record.doubt		
					set dataObj.ClassName=record.className
					set dataObj.MethodName=record.methodName
					set dataObj.LinkValueDr=linkValueIDStr
					set dataObj.LinkCode=record.linkCode	
					set dataObj.Col=record.col
					set dataObj.JumpDr=record.jumpID
					set dataObj.LabelCol=record.labelCol
					set dataObj.WrapperCol=record.wrapperCol
					set dataObj.Required=record.required
					set dataObj.Disabled=record.disabled
					set dataObj.Display=record.display
					set dataObj.Valid=record.valid
					set dataObj.Default=record.default
					set dataObj.Params=record.params
					set dataObj.ElementFieldDr=record.elementFieldID
					if formID=""{
						set dataObj.CreateDate=+$h
						set dataObj.CreateUserDr=userID
						do insArr.%Push(dataObj)
					}else{
						do updArr.%Push(dataObj)
					}
				}
				set operateObj={}
				set operateObj.updateUserID=userID
				set operateObj.className="User.CBReactForm"	
				if insArr.%Size()>0{
					set operateObj.data=insArr
					set rtn=##class(src.util.operatetable).Insert(.operateObj) 
					set errorCode=rtn.errorCode
					set errorMessage=rtn.errorMessage
					if errorCode'="0"{
						Trollback 1
						set resultObj.errorCode=errorCode
						set resultObj.errorMessage=errorMessage
						quit
					}
				}		
				if updArr.%Size()>0{
					set operateObj.data=updArr
					set rtn=##class(src.util.operatetable).Update(.operateObj) 
					set errorCode=rtn.errorCode
					set errorMessage=rtn.errorMessage
					if errorCode'="0"{
						Trollback 1
						set resultObj.errorCode=errorCode
						set resultObj.errorMessage=errorMessage
						quit
					}
				}
				if delArr.%Size()>0{
					set operateObj.data=delArr
					set rtn=##class(src.util.operatetable).Delete(.operateObj) 
					set errorCode=rtn.errorCode
					set errorMessage=rtn.errorMessage
					if errorCode'="0"{
						Trollback 1
						set resultObj.errorCode=errorCode
						set resultObj.errorMessage=errorMessage
						quit
					}
				}
			}
			quit:errorCode'=0			
		}
		if errorCode=0{
			Tcommit
		}else{
			Trollback 1
		}	
	}catch(e){
		Trollback 1
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    b	;err
	}
	quit resultObj
}

/// Creator:     TC
/// CreatDate:   2024-06-01
/// Description: 查询组件(维护界面用)
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.Component.ReactComponent).GetReactComponentInteger({"params":[{"menuDetailCode":"01010001"}]}).%ToJSON()
ClassMethod GetReactComponentInteger(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":""}
	try{
		set params=jsonObj.params.%Get(0)
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
		set componentArr=[]
		set componentID=""
		for
		{
			set componentID=$o(^CBMenuDetailComponentI("MenuComponent",menuDetailId,componentID))
			quit:componentID=""
			set componentObj={}
			set menuDetailComID=$o(^CBMenuDetailComponentI("MenuComponent",menuDetailId,componentID,0))
			set componentObj.dataIndex=$lg(^CBMenuDetailComponentD(menuDetailComID),6)
			set componentInfo=##class(User.CBReactComponent).%OpenId(componentID)
			// 主表信息
			set code=componentInfo.Code
			set descripts=componentInfo.Descripts
			set path=componentInfo.Path
			set comAddress=componentInfo.ComAddress
			set note=componentInfo.Note
			set componentObj.componentCode=code
			// table信息
			set dataArr=[],totalWidth=0
			set tStatement = ##class(%SQL.Statement).%New(1)
			set sql="SELECT * FROM CB_ReactComTable WHERE CBReactCom_Dr=?"	
			set sql=sql_" order by SeqNo"
			do tStatement.%Prepare(sql)
			set result=tStatement.%Execute(componentID)		
			while result.%Next(.sc){
				set dataObj={}
				set dataObj.id=result.%Get("ID")
				set dataObj.code=result.%Get("Code")
				set dataObj.descripts=result.%Get("Descripts")
				set dataObj.type=result.%Get("Type")
				set dataObj.width=result.%Get("Width")
				set dataObj.seqNo=result.%Get("SeqNo")			
				set dataObj.display=result.%Get("Display")
				set dataObj.print=result.%Get("Print")
				set dataObj.export=result.%Get("Export")
				set dataObj.linkMethod=result.%Get("LinkMethod")
				set dataObj.linkService=result.%Get("LinkService")
				set dataObj.align=result.%Get("Align")
				set dataObj.fixed=result.%Get("Fixed")			
				set dataObj.visible=result.%Get("Visible")
				set dataObj.enDesc=result.%Get("ENDesc")
				set dataObj.doubt=result.%Get("Doubt")
				set dataObj.params=result.%Get("Params")
				set dataObj.fieldTypeID=result.%Get("FieldType_Dr")				
				do dataArr.%Push(dataObj)
				set totalWidth=totalWidth+result.%Get("Width")
			}
			set componentObj.tableData=dataArr
			set componentObj.totalWidth=totalWidth_"px"
			// form信息
			set dataArr=[]
			set tStatement = ##class(%SQL.Statement).%New(1)
			set sql="SELECT FieldType_Dr->Descripts fieldTypeDesc,FieldType_Dr->Code fieldTypeCode,Jump_Dr->Descripts jumpDesc,* FROM CB_ReactForm WHERE CBReactCom_Dr=?"
			set sql=sql_" order by +SeqNo"
			;b	;111
			do tStatement.%Prepare(sql)
			set result=tStatement.%Execute(componentID)		
			while result.%Next(.sc){
				set dataObj={}
				set dataObj.id=result.%Get("ID")
				set dataObj.code=result.%Get("Code")
				set dataObj.descripts=result.%Get("Descripts")
				set dataObj.seqNo=result.%Get("SeqNo")
				set dataObj.enDesc=result.%Get("ENDesc")
				set dataObj.placeholder=result.%Get("Placeholder")
				set dataObj.callback=result.%Get("Callback")	
				set dataObj.doubt=result.%Get("Doubt")
				set dataObj.fieldTypeID=result.%Get("FieldType_Dr")
				set dataObj.fieldTypeCode=result.%Get("fieldTypeCode")
				set dataObj.fieldTypeDesc=result.%Get("fieldTypeDesc")
				set dataObj.className=result.%Get("ClassName")
				set dataObj.methodName=result.%Get("MethodName")			
				set dataObj.col=result.%Get("Col")
				set linkValueIDStr=result.%Get("LinkValue_Dr")
				set arr=[],descStr=""
				;b	;?
				for i=1:1:$l(linkValueIDStr,"^"){
					set linkValueID=$p(linkValueIDStr,"^",i)
					continue:linkValueID=""
					set linkObj=##class(User.CBReactForm).%OpenId(linkValueID)
					continue:'$IsObject(linkObj)
					set descStr=descStr_","_linkObj.Descripts				
					do arr.%Push(linkValueID)
				}
				set dataObj.linkValueID=arr		
				set dataObj.linkValueDesc=descStr
				set dataObj.linkCode=result.%Get("LinkCode")
				set dataObj.jumpID=result.%Get("Jump_Dr")
				set dataObj.jumpDesc=result.%Get("jumpDesc")
				set dataObj.labelCol=result.%Get("LabelCol")
				set dataObj.wrapperCol=result.%Get("WrapperCol")			
				set dataObj.required=result.%Get("Required")
				set dataObj.disabled=result.%Get("Disabled")
				set dataObj.display=result.%Get("Display")
				set dataObj.valid=result.%Get("Valid")
				set dataObj.default=result.%Get("Default")
				set dataObj.params=result.%Get("Params")
				set dataObj.elementFieldID=result.%Get("ElementField_Dr")			
				do dataArr.%Push(dataObj)
			}
			set componentObj.formData=dataArr
			do componentArr.%Push(componentObj)		
		}
		set resultObj.result=componentArr
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	    b
	}
	quit resultObj
}

}
