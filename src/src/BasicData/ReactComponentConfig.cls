/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 组件配置相关
Class src.BasicData.ReactComponentConfig Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     TC
/// CreatDate:   2022-07-01
/// Description: 保存组件主表配置
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).SaveReactComponentConfig()
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).GetReactComponentConfig({"params":[{"hospID":"6","code":"hh","descripts":"xixi"}]})
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).SaveReactComTableConfig()
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).GetReactComponentConfig({"params":[{"hospID":"6","code":"hh","descripts":"xixi"}]})
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).SaveReactComFieldConfig()
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).GetReactComFieldConfig({"params":[{"hospID":"6","code":"hh","descripts":"xixi"}]})
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).SaveReactComFormConfig(a).%ToJSON()
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).GetReactComFieldConfig({"params":[{"hospID":"6","code":"hh","descripts":"xixi"}]})
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
		set sql="SELECT FieldType_Dr->Descripts fieldTypeDesc,Jump_Dr->Descripts jumpDesc,* FROM CB_ReactForm WHERE CBReactCom_Dr=?"		
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).SaveReactComBtnConfig(a).%ToJSON()
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).GetReactComBtnConfig({"params":[{"hospID":"6","code":"hh","descripts":"xixi"}]})
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).DeleteReactComTableConfig()
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).DeleteReactComFieldConfig()
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).DeleteReactFormConfig()
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
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).DeleteReactComBtnConfig()
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

/*
/// ----------------------------------使用公共接口
/// Output:      组件的信息,table列或者按钮
/// w ##class(src.BasicData.ReactComponentConfig).GetComponetTableData({"params":[{"reactCode":["MenuDetailMaintenance"],"componentName":"MenuDetailMaintenance","type":"C"}],"code":"01040073","session":[{"userID":"1","groupID":"4","hospID":"2","language":"CN"}]}).%ToJSON()
ClassMethod GetComponetTableData(jsonObj)
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{"language":{}}}
	set buttonArr=[],columnArr=[],totalWidth=0
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
		set componentName=params.componentName
		set reactCode=params.reactCode
		if reactCode'=""{
			set reactCode=reactCode.%Get(0)
		}
		set type=params.type	
		if componentName'=""{
			
			set searchType=params.type
			set compontId=$o(^CBReactComponentI("Code",$ZCVT(componentName,"U"),0)) 
			if compontId=""{
				set resultObj.errorCode="01040102"
				set resultObj.errorMessage="未维护组件信息"
				quit 
			}  
			set typeStr="U^G^H" //用户,角色,医院
			set saveType="-1",saveTypeId="-1"
			i hospID'=""{
				for len=1:1:$L(typeStr,"^")
				{
					set saveType=$P(typeStr,"^",len)
					set saveTypeId=$case(saveType,"U":userID,"G":groupID,"H":hospID,:"")
					set id=$O(^HBTableAuthI("Type",$ZCVT(saveType,"U"),saveTypeId,compontId,0))
					if id'="" quit 
				}
			}
			set sub="" 
			set result=[]
			set sequence=0
			set nullSeqNo=99999 //未维护列顺序,从99999开始
			set colId=""
			b	;qwq1
			if $o(^HBTableAuthI("Type",$ZCVT(saveType,"U"),saveTypeId,compontId,0))=""
			{
				//没有维护安全组配置
				set tStatement = ##class(%SQL.Statement).%New(1)   
				set sql="SELECT * FROM CB_ReactComTable where CBReactCom_Dr->Code ='"_componentName_"'"
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
				b ; 3333333
			}
			else
			{
				//维护配置
				set tStatement = ##class(%SQL.Statement).%New(1)   
				set sql="SELECT * FROM CB_ReactComTable where CBReactCom_Dr->Code ='"_componentName_"'"
				set sql=sql_" order by Type,SeqNo"
				b ;; sql
				set sc=tStatement.%Prepare(sql)
				set result=tStatement.%Execute()		
				while result.%Next(.sc){
					set id=result.%Get("ID")
					set compontId=result.%Get("CBReactCom_Dr")
					set seqNo=result.%Get("SeqNo")
					set type=result.%Get("Type")
					continue:type'=searchType&(searchType'="") 
					set authId=$o(^HBTableAuthI("Type",$ZCVT(saveType,"U"),saveTypeId,compontId,id,0))
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
				b ; 4444444
			}
			b ;; sortData
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
					if dataID["||"{
						//未维护权限
						set data=$g(^CBReactComTableD($P(dataID,"||",2)))
						set id=$P(dataID,"||",2)
						set descripts=$lg(data,4)
						set width=$lg(data,6)
						set align=$lg(data,13)
						set enDescripts=""
						set exportFlag=$lg(data,10)
						set diaplayFlag=$lg(data,8)
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
						set exportFlag=$lg(data,10)
						set diaplayFlag=$lg(authData,7)
					}
					continue:diaplayFlag="N" 
					set sequence=sequence+1
					set dataObj={}
					set dataObj.id=id
					set dataObj.code=$lg(data,3)
					set dataObj.descripts=descripts
					set dataObj.dataIndex=$lg(data,3)
					set dataObj.display=diaplayFlag
					set dataObj.enDescripts=""	
					set dataObj.exportFlag=exportFlag
					set dataObj.fixed=$case($lg(data,14)'="","1":$lg(data,14),:"") 
					set dataObj.label=descripts
					set dataObj.seqNo=sequence
					set dataObj.title=descripts
					set dataObj.value=id
					set dataObj.visible=$lg(data,15)
					set dataObj.width=width
					set dataObj.align=align
					set totalWidth=totalWidth+width
					b	;qwq1
					if (type="C"){
						do columnArr.%Push(dataObj)
					}
					if (type="B"){
						do buttonArr.%Push(dataObj)
					}
				}
			}  
			b ;; form
			// Field部分
			set CN={}
			set tStatement = ##class(%SQL.Statement).%New(1)   
			set sql="SELECT * FROM CB_ReactFormField where CBReactCom_Dr->Code ='"_componentName_"'"
			b ;; sql
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
			set typeStr="U^G^H" //用户,角色,医院
			set saveType="-1",saveTypeId="-1"
			i hospID'=""{
				for len=1:1:$L(typeStr,"^")
				{
					set saveType=$P(typeStr,"^",len)
					set saveTypeId=$case(saveType,"U":userID,"D":locID,"G":groupID,"H":hospID,:"")
					set id=$O(^HBFormAuthI("Type",$ZCVT(saveType,"U"),saveTypeId,compontId,0))
					if id'="" quit 
				}
			}
			kill sortData
			set sub="" 
			set formData=[]
			set sequence=0
			set nullSeqNo=99999 //未维护列顺序,从99999开始
			if $o(^HBFormAuthI("Type",$ZCVT(saveType,"U"),saveTypeId,compontId,0))=""
			{
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
				;b ; 3333333
			}else{
				//维护配置
				set tStatement = ##class(%SQL.Statement).%New(1)   
				set sql="SELECT * FROM CB_ReactForm where CBReactCom_Dr->Code ='"_componentName_"'"
				set sql=sql_" order by Type,SeqNo"
				b ;; sql
				set sc=tStatement.%Prepare(sql)
				set result=tStatement.%Execute()		
				while result.%Next(.sc){
					set id=result.%Get("ID")
					set compontId=result.%Get("CBReactCom_Dr")
					set seqNo=result.%Get("SeqNo")
					set type=result.%Get("Type")
					continue:type'=searchType&(searchType'="") 
					set authId=$o(^HBFormAuthI("Type",$ZCVT(saveType,"U"),saveTypeId,compontId,id,0))					
					if authId=""
					{
						//维护配置后新添加的列
						set seqNo=nullSeqNo,nullSeqNo=+nullSeqNo+1
						set sortData("FormData",seqNo,compontId_"||"_id)=""
					}
					else
					{
						//维护配置的数据
						set data=$g(^HBFormAuthD(authId))
						set displayFlag=$lg(data,7)
						continue:displayFlag="N"
						set seqNo=$lg(data,6)
						set sortData("FormData",seqNo,authId)=""
					}
				}
				b ; 4444444
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
						set col=$lg(data,13)
						set jumpID=$lg(data,14) 					
						set labelCol=$lg(data,15)
						set wrapperCol=$lg(data,16)
					}else{
						set authData=$g(^HBFormAuthD(id))
						set formID=$lg(authData,5)
						set data=$g(^CBReactFormD(formID))
						set col=$lg(authData,7)
						set jumpID=$lg(authData,8) 					
						set labelCol=$lg(authData,9)
						set wrapperCol=$lg(authData,10)
					}
					set itemData.id=formID
					set itemData.value=formID
					set itemData.code=$lg(data,2)
					set itemData.dataIndex=$lg(data,2)
					set itemData.descripts=$lg(data,3)
					set itemData.title=$lg(data,3)
					set itemData.placeholder=$lg(data,6)
					if (session.language="EN")&&(enDescripts'=""){
						set itemData.descripts=$lg(data,5)
					}
					set sequence=sequence+1
					set itemData.seqNo=sequence
					set fieldTypeID=$lg(data,7)
					set itemData.typeCode=""
					set:fieldTypeID'="" itemData.typeCode=##class(User.CBConfigFieldType).%OpenId(fieldTypeID).Code
					set itemData.callback=$lg(data,8)
					set itemData.doubt=$lg(data,9)
					set itemData.className=$lg(data,10)
					set itemData.methodName=$lg(data,11)
					set linkValueIDStr=$lg(data,12)				
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
					set itemData.enDescripts=$lg(data,5)
					set itemData.linkCode=$lg(data,23)
					set itemData.col=col
					set jumpCode=""
					set:jumpID'="" jumpCode=##class(User.CBReactForm).%OpenId(jumpID).Code
					set itemData.jumpID=jumpID 
					set itemData.jumpCode=jumpCode
					set itemData.labelCol=labelCol	
					set itemData.wrapperCol=wrapperCol
					set itemData.required=$lg(data,17)	
					set itemData.disabled=$lg(data,18)
					set itemData.display=$lg(data,19)
					set itemData.default=$lg(data,24)	
					set itemData.params=$lg(data,25)	
					do formData.%Push(itemData)
					;b ;itemData
				} 
			}
			set compontData.formData=formData
			// 新button
			set buttonData=[]
			set tStatement = ##class(%SQL.Statement).%New(1)
			set sql="SELECT Type_Dr->Descripts typeDesc,Size_Dr->Descripts sizeDesc,Shape_Dr->Descripts shapeDesc,* FROM CB_ReactButton WHERE CBRB_ParRef=?"
			;b	;111
			do tStatement.%Prepare(sql)
			set result=tStatement.%Execute(compontId)		
			while result.%Next(.sc){
				set dataObj={}
				set dataObj.id=result.%Get("ID")
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
			set compontData.buttonData=buttonData
		}		
		set resultObj.result.language.CN=CN	
		set resultObj.result.B=buttonArr
		set resultObj.result.C=columnArr
		set resultObj.result.compontData=compontData
		set resultObj.totalWidth=totalWidth_"px"		
	}catch(e){
		set status=e.AsStatus()
		set resultObj.errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set resultObj.errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
	}
	quit resultObj
}
*/
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
ClassMethod SaveComponetAuthConfig(jsonObj)
{
	new (jsonObj)
	try{
		set resultJson={"errorCode":"0","errorMessage":"成功","result":{}}
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
			set authId=""
			while subIter.%GetNext(.code,.colData) {
			  set cellValue=rowData.%Get(code)
			  continue:code="TotalCount" 
			  if (code="ID")
			  {
				set authId=$o(^HBTableAuthI("Type",$ZCVT(type,"U"),typeId,compontId,cellValue,0)) 
				if (authId'=""){set dataobj.ID=authId}
				set dataobj.ComTableDr=cellValue
		      }
		      if (code="displayFlag") set dataobj.Display=colData
			  if (code="pringFlag") set dataobj.Print=colData
			  if (code="exportFlag") set dataobj.Export=colData
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
			b ;111
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
			b ;9090
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
	    set errorCode=$piece(##class(%SYSTEM.Status).GetErrorCodes(status),",")
	    set errorMessage=##class(%SYSTEM.Status).GetErrorText(status,"cn")	
	}
	quit resultJson
}

/// Creator:     TC
/// CreatDate:   2024-06-01
/// Description: 查询组件(维护界面用)
/// code:		 
/// Input:		{"params":[{"":""}]}
/// Debug：		 w ##class(src.BasicData.ReactComponentConfig).GetReactComponentInteger({"params":[{"menuDetailCode":"01010001"}]}).%ToJSON()
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
			set sql="SELECT FieldType_Dr->Descripts fieldTypeDesc,Jump_Dr->Descripts jumpDesc,* FROM CB_ReactForm WHERE CBReactCom_Dr=?"
			set sql=sql_" order by +SeqNo"
			b	;111
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
