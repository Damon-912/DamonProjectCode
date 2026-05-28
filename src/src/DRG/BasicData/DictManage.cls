Import SQLUSER

Class src.DRG.BasicData.DictManage Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     AI
/// CreatDate:   2026-05-22
/// Description: 查询DRG字典类型列表
/// Table:       CB_DRGDictTable
/// Interface:   02010059
/// Input:       params:{Code:"",Name:""}, pagination:{pageSize,currentPage}
/// Output:      result:{rows, total}
/// Debug:       w ##class(src.DRG.BasicData.DictManage).GetDRGDictTypeList({"params":[{"code":"","name":""}],"code":"02010059","session":[{"userID":"2","locID":1,"groupID":"1","hospID":"2"}]}).%ToJSON()
ClassMethod GetDRGDictTypeList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set dataArr=[]
	try{
		set params=jsonObj.params.%Get(0)
		set code=params.code
		set name=params.name
		
		set sql =" SELECT ID,Code,Name,Status,SortNo,Remark,CreateDate "
			    _" FROM CB_DRGDictTable where Parent_Dr IS NULL "
		
		if code'=""
		{
			set sql=sql_" and Code like '%"_code_"%'" 
		}
		if name'=""
		{
			set sql=sql_" and Name like '%"_name_"%'" 
		}
		set sql=sql_" ORDER BY SortNo ASC, ID ASC"
		
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)
		{
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.name=result.%Get("Name")
			set dataObj.status=result.%Get("Status")
			set dataObj.sortNo=result.%Get("SortNo")
			set dataObj.remark=result.%Get("Remark")
			set dataObj.createDate=result.%Get("CreateDate")
			
			if dataObj.status="Y"
			{
				set dataObj.statusDesc="启用"
				set dataObj.statusFlag="Y"
			}
			else
			{
				set dataObj.statusDesc="停用"
				set dataObj.statusFlag="N"
			}
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=dataArr.%Size()
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询DRG字典类型出现问题:w ##class("_$ClassName()_").GetDRGDictTypeList("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     AI
/// CreatDate:   2026-05-22
/// Description: 保存DRG字典类型（新增/修改/启用停用）
/// Table:       CB_DRGDictTable
/// Interface:   02010062
/// Input:       params:{id,code,name,status,remark}
/// Debug:       w ##class(src.DRG.BasicData.DictManage).SaveDRGDictType({"params":[{"id":"","code":"test","name":"测试类型","status":"Y","remark":""}],"code":"02010062","session":[{"userID":"2","hospID":"2"}]}).%ToJSON()
ClassMethod SaveDRGDictType(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="保存成功"
	set resultObj.result={}
	try{
		set params=postObj.params.%Get(0)
		set session=postObj.session.%Get(0)
		set userID=session.userID
		
		set id=params.id
		set code=params.code
		set name=params.name
		set status=params.status
		set remark=params.remark
		
		if code=""
		{
			set resultObj.errorCode="01000011"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000011")
			quit
		}
		if name=""
		{
			set resultObj.errorCode="01000012"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000012")
			quit
		}
		if status="" set status="Y"
		
		set data=[]
		set dataObj={}
		set dataObj.ID=id
		set dataObj.ParentDr=""
		set dataObj.Code=code
		set dataObj.Name=name
		set dataObj.Status=status
		set dataObj.Remark=remark
		set dataObj.CreateUserDr=userID
		set dataObj.CreateDate=$zd($h,3)
		set dataObj.CreateTime=$zt($p($h,",",2),1)
		
		set insObj={}
		set insObj.className="User.CBDRGDictTable"
		set insObj.updateUserID=userID
		set rtn=""
		do data.%Push(dataObj)
		set insObj.data=data
		
		if id=""
		{
			set rtn=##class(src.util.operatetable).Insert(.insObj)
		}
		else
		{
			set rtn=##class(src.util.operatetable).Update(.insObj)
		}
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		if errorCode'=0
		{
			set resultObj.errorCode=errorCode
			set resultObj.errorMessage=errorMessage
		}
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存DRG字典类型出现问题:w ##class("_$ClassName()_").SaveDRGDictType("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     AI
/// CreatDate:   2026-05-22
/// Description: 查询DRG字典项列表（按字典类型筛选，分页）
/// Table:       CB_DRGDictTable
/// Interface:   02010060
/// Input:       params:{parentDr,code,name,status}, pagination:{pageSize,currentPage}
/// Output:      result:{rows, total}
/// Debug:       w ##class(src.DRG.BasicData.DictManage).GetDRGDictItemList({"params":[{"parentDr":"1","code":"","name":"","status":""}],"pagination":[{"pageSize":20,"currentPage":1}],"code":"02010060","session":[{"userID":"2","hospID":"2"}]}).%ToJSON()
ClassMethod GetDRGDictItemList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try{
		if (jsonObj.%IsDefined("pagination")'=0)
		{
			set pagationObj=jsonObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
			set currentPage=pagationObj.currentPage
		}
		set params=jsonObj.params.%Get(0)
		set parentDr=params.parentDr
		set code=params.code
		set name=params.name
		set status=params.status
		
		if parentDr=""
		{
			set resultObj.errorCode="01000010"
			set resultObj.errorMessage="请选择字典类型"
			quit
		}
		
		set sql =" SELECT ID,Code,Name,Status,SortNo,Remark,CreateDate "
			    _" FROM CB_DRGDictTable where Parent_Dr = "_parentDr
		
		if code'=""
		{
			set sql=sql_" and Code like '%"_code_"%'" 
		}
		if name'=""
		{
			set sql=sql_" and Name like '%"_name_"%'" 
		}
		
		set sql=sql_" ORDER BY SortNo ASC, ID ASC"
		
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)
		{
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.name=result.%Get("Name")
			set dataObj.status=result.%Get("Status")
			set dataObj.sortNo=result.%Get("SortNo")
			set dataObj.remark=result.%Get("Remark")
			set dataObj.createDate=result.%Get("CreateDate")
			set dataObj.parentDr=parentDr
			
			if dataObj.status="Y"
			{
				set dataObj.statusDesc="启用"
				set dataObj.statusFlag="Y"
			}
			else
			{
				set dataObj.statusDesc="停用"
				set dataObj.statusFlag="N"
			}
			
			if status="Y"
			{
				continue:dataObj.statusFlag="N"
			}
			elseif status="N"
			{
				continue:dataObj.statusFlag="Y"
			}
			
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询DRG字典项出现问题:w ##class("_$ClassName()_").GetDRGDictItemList("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     AI
/// CreatDate:   2026-05-22
/// Description: 保存DRG字典项（新增/修改/启用停用）
/// Table:       CB_DRGDictTable
/// Interface:   02010061
/// Input:       params:{id,parentDr,code,name,status,sortNo,remark}
/// Debug:       w ##class(src.DRG.BasicData.DictManage).SaveDRGDictItem({"params":[{"id":"","parentDr":"1","code":"01","name":"测试项","status":"Y","sortNo":1,"remark":""}],"code":"02010061","session":[{"userID":"2","hospID":"2"}]}).%ToJSON()
ClassMethod SaveDRGDictItem(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="保存成功"
	set resultObj.result={}
	try{
		set params=postObj.params.%Get(0)
		set session=postObj.session.%Get(0)
		set userID=session.userID
		
		set id=params.id
		set parentDr=params.parentDr
		set code=params.code
		set name=params.name
		set status=params.status
		set sortNo=params.sortNo
		set remark=params.remark
		
		if parentDr=""
		{
			set resultObj.errorCode="01000010"
			set resultObj.errorMessage="请选择字典类型"
			quit
		}
		if code=""
		{
			set resultObj.errorCode="01000011"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000011")
			quit
		}
		if name=""
		{
			set resultObj.errorCode="01000012"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000012")
			quit
		}
		if status="" set status="Y"
		
		; 新增时自动取最大SortNo+1
		if (id="")&&(sortNo="")
		{
			&sql(SELECT MAX(SortNo) INTO :sortNo FROM CB_DRGDictTable WHERE Parent_Dr = :parentDr)
			if SQLCODE=100 set sortNo=0
			set sortNo=sortNo+1
		}
		
		set data=[]
		set dataObj={}
		set dataObj.ID=id
		set dataObj.ParentDr=parentDr
		set dataObj.Code=code
		set dataObj.Name=name
		set dataObj.Status=status
		set dataObj.SortNo=sortNo
		set dataObj.Remark=remark
		set dataObj.CreateUserDr=userID
		set dataObj.CreateDate=$zd($h,3)
		set dataObj.CreateTime=$zt($p($h,",",2),1)
		
		set insObj={}
		set insObj.className="User.CBDRGDictTable"
		set insObj.updateUserID=userID
		set rtn=""
		do data.%Push(dataObj)
		set insObj.data=data
		
		if id=""
		{
			set rtn=##class(src.util.operatetable).Insert(.insObj)
		}
		else
		{
			set rtn=##class(src.util.operatetable).Update(.insObj)
		}
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		if errorCode'=0
		{
			set resultObj.errorCode=errorCode
			set resultObj.errorMessage=errorMessage
		}
	}
	catch(e)
	{
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存DRG字典项出现问题:w ##class("_$ClassName()_").SaveDRGDictItem("_postObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     AI
/// CreatDate:   2026-05-23
/// Description: 根据字典类型编码查询字典项列表（用于前端下拉选择）
/// Table:       CB_DRGDictTable
/// Interface:   02010063
/// Input:       params:{typeCode:""}, 可选 status:"Y" 仅查启用
/// Output:      result:{rows:[{code,name,status,sortNo}]}
/// Debug:       w ##class(src.DRG.BasicData.DictManage).GetDRGDictItemByTypeCode({"params":[{"typeCode":"WARNING_LEVEL","status":"Y"}],"code":"02010063","session":[{"userID":"2","hospID":"2"}]}).%ToJSON()
ClassMethod GetDRGDictItemByTypeCode(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set dataArr=[]
	try{
		set params=jsonObj.params.%Get(0)
		set typeCode=params.typeCode
		; 使用 %IsDefined 检查属性是否存在，避免 <PROPERTY DOES NOT EXIST>
		if params.%IsDefined("status")
		{
			set filterStatus=params.status
			if filterStatus="" set filterStatus="Y"
		}
		else
		{
			set filterStatus="Y"
		}
		
		if typeCode=""
		{
			set resultObj.errorCode="01000010"
			set resultObj.errorMessage="字典类型编码不能为空"
			quit
		}
		
		; 通过类型编码关联查询字典项
		set sql="SELECT b.ID,b.Code,b.Name,b.Status,b.SortNo,b.Remark "
		        _"FROM CB_DRGDictTable a "
		        _"INNER JOIN CB_DRGDictTable b ON a.ID=b.Parent_Dr "
		        _"WHERE a.Parent_Dr IS NULL AND a.Code='"_typeCode_"' "
		        _"AND a.Status='Y' "
		
		if filterStatus="Y"
		{
			set sql=sql_"AND b.Status='Y' "
		}
		set sql=sql_"ORDER BY b.SortNo ASC, b.ID ASC"
		
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)
		{
			set dataObj={}
			set dataObj.id=result.%Get("ID")
			set dataObj.code=result.%Get("Code")
			set dataObj.name=result.%Get("Name")
			set dataObj.status=result.%Get("Status")
			set dataObj.sortNo=result.%Get("SortNo")
			set dataObj.remark=result.%Get("Remark")
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=dataArr.%Size()
	}
	catch(e)
	{
		set excStatus=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(excStatus,"cn"),"^"," ")
		set errorInfo="根据类型编码查询字典项出现问题:w ##class("_$ClassName()_").GetDRGDictItemByTypeCode("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

}
