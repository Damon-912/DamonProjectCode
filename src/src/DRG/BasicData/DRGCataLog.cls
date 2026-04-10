Import SQLUSER

/// DRG目录信息服务类
/// 提供各地方DRG目录的增改查删功能
Class src.DRG.BasicData.DRGCataLog Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 查询DRG目录信息
/// Table:       HB_DRGCataLog (User.HBDRGCataLog)
/// Input:       jsonObj - 包含params和pagination
/// Output:      分页查询结果
/// Debug:       w ##class(src.DRG.BasicData.DRGCataLog).GetDRGCataLogList({}).%ToJSON()
ClassMethod GetDRGCataLogList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try
	{
		if (jsonObj.%IsDefined("pagination")'=0) 
		{
			set pagationObj=jsonObj.pagination.%Get(0)
			set pageSize=pagationObj.pageSize
			set currentPage=pagationObj.currentPage
		}
		set params=jsonObj.params.%Get(0)
		set code=params.code
		set descripts=params.descripts
		set provinceID=params.provinceID
		set cityID=params.cityID
		
		set sql=" SELECT ID,Code,Descripts,Admvs,"
		       _" Province_Dr as provinceID,Province_Dr->Descripts as provinceDesc,"
		       _" City_Dr as cityID,City_Dr->Descripts as cityDesc "
		       _" FROM HB_DRGCataLog where 1=1"
		
		if code'=""
		{
			set sql=sql_" and Code like '%"_code_"%'" 
		}
		if descripts'=""
		{
			set sql=sql_" and Descripts like '%"_descripts_"%'" 
		}
		if provinceID'=""
		{
			set sql=sql_" and Province_Dr = '"_provinceID_"'" 
		}
		if cityID'=""
		{
			set sql=sql_" and City_Dr = '"_cityID_"'" 
		}
		
		set sql=sql_" Order by Code"
		
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)	
		{
			set id=result.ID
			set code=result.Code
			set descripts=result.Descripts	
			set admvs=result.Admvs
			set provinceID=result.provinceID
			set provinceDesc=result.provinceDesc
			set cityID=result.cityID
			set cityDesc=result.cityDesc
			
			set dataObj={}
			set dataObj.id=id
			set dataObj.code=code
			set dataObj.descripts=descripts
			set dataObj.admvs=admvs
			set dataObj.provinceID=provinceID
			set dataObj.provinceDesc=provinceDesc
			set dataObj.cityID=cityID
			set dataObj.cityDesc=cityDesc
			
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count
				
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询DRG目录信息出现问题:w ##class("_$ClassName()_").GetDRGCataLogList("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 保存/更新DRG目录信息
/// Table:       HB_DRGCataLog (User.HBDRGCataLog)
/// Input:       jsonObj - 包含params
/// Output:      保存结果
/// Debug:       w ##class(src.DRG.BasicData.DRGCataLog).SaveDRGCataLog({}).%ToJSON()
ClassMethod SaveDRGCataLog(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={}
	set resultObj.errorCode="0"
	set resultObj.errorMessage="保存成功"
	set resultObj.result={}
	try
	{
		set params=jsonObj.params.%Get(0)
		set session=jsonObj.session.%Get(0)
		set userID=session.userID
		
		set ID=params.id
		set code=params.code
		set descripts=params.descripts
		set provinceDr=params.provinceDr
		set cityDr=params.cityDr
		set admvs=params.admvs
		
		// 参数校验
		if code="" {
			set resultObj.errorCode="02041001"
			set resultObj.errorMessage="DRG代码不能为空"
			quit
		}
		if descripts="" {
			set resultObj.errorCode="02041002"
			set resultObj.errorMessage="DRG描述不能为空"
			quit
		}
		if provinceDr="" {
			set resultObj.errorCode="01000007"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000007")
			quit
		}
		if cityDr="" {
			set resultObj.errorCode="01000008"
			set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("01000008")
			quit
		}
		
		// 判断是新增还是更新
		if ID="" {
			// 检查是否已存在相同记录
			&sql(SELECT ID INTO :existID FROM HB_DRGCataLog WHERE Code=:code AND Province_Dr=:provinceDr AND City_Dr=:cityDr)
			if SQLCODE=0 {
				set resultObj.errorCode="02041003"
				set resultObj.errorMessage="该DRG目录已存在（同一省市下代码不能重复）"
				quit
			}
		}
		
		// 使用operatetable工具类保存数据
		set data=[]
		set dataObj={}
		set dataObj.ID=ID
		set dataObj.Code=code
		set dataObj.Descripts=descripts
		set dataObj.ProvinceDr=provinceDr
		set dataObj.CityDr=cityDr
		set dataObj.Admvs=admvs
		set dataObj.UpdateUserDr=userID
		set dataObj.UpdateDate=$zd($h,3)
		set dataObj.UpdateTime=$zt($p($h,",",2),1)
		
		set insObj={}
		set insObj.className="User.HBDRGCataLog"
		set insObj.updateUserID=userID
		set rtn=""
		do data.%Push(dataObj)
		set insObj.data=data
		
		if ID="" {
			set rtn=##class(src.util.operatetable).Insert(.insObj)
		} else {
			set rtn=##class(src.util.operatetable).Update(.insObj)
		}
		
		set errorCode=rtn.errorCode
		set errorMessage=rtn.errorMessage
		if errorCode'=0 {
			set resultObj.errorCode=errorCode
			set resultObj.errorMessage=errorMessage
		}
		
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="保存DRG目录信息出现问题:w ##class("_$ClassName()_").SaveDRGCataLog("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 删除DRG目录信息
/// Table:       HB_DRGCataLog (User.HBDRGCataLog)
/// Input:       jsonObj - 包含params.id
/// Output:      删除结果
/// Debug:       w ##class(src.DRG.BasicData.DRGCataLog).DeleteDRGCataLog({}).%ToJSON()
ClassMethod DeleteDRGCataLog(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"删除成功","result":{}}
	try
	{
		set params=jsonObj.params.%Get(0)
		set ID=params.id
		
		if ID="" {
			set resultObj.errorCode="04000006"
			set resultObj.errorMessage="删除ID不能为空"
			quit
		}
		
		&sql(DELETE FROM HB_DRGCataLog WHERE ID=:ID)
		
		if SQLCODE'=0 {
			set resultObj.errorCode="04000009"
			set resultObj.errorMessage="删除失败，SQL错误码："_SQLCODE
			quit
		}
		
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="删除DRG目录信息出现问题:w ##class("_$ClassName()_").DeleteDRGCataLog("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

}
