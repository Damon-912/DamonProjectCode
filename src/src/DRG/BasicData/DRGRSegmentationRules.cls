Import SQLUSER

/// ADRG细分规则服务类
/// 提供各地方ADRG细分规则的增改查删功能
Class src.DRG.BasicData.DRGRSegmentationRules Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 查询ADRG细分规则
/// Table:       HB_DRGSegmentationRules (User.HBDRGSegmentationRules)
/// Input:       jsonObj - 包含params和pagination
/// Output:      分页查询结果
/// Debug:       w ##class(src.DRG.BasicData.DRGRSegmentationRules).GetDRGSegmentationRulesList({}).%ToJSON()
ClassMethod GetDRGSegmentationRulesList(jsonObj) As %Library.DynamicObject
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
		set adrg=params.adrg
		set adrgDesc=params.adrgDesc
		set provinceID=params.provinceID
		set cityID=params.cityID
		
		set sql=" SELECT ID,ADRG,ADRGDesc,Admvs,UnionFlag,SegmentationFlag,SelectionCriteria,"
		       _" Province_Dr as provinceID,Province_Dr->Descripts as provinceDesc,"
		       _" City_Dr as cityID,City_Dr->Descripts as cityDesc "
		       _" FROM HB_DRGSegmentationRules where 1=1"
		
		if adrg'=""
		{
			set sql=sql_" and ADRG like '%"_adrg_"%'" 
		}
		if adrgDesc'=""
		{
			set sql=sql_" and ADRGDesc like '%"_adrgDesc_"%'" 
		}
		if provinceID'=""
		{
			set sql=sql_" and Province_Dr = '"_provinceID_"'" 
		}
		if cityID'=""
		{
			set sql=sql_" and City_Dr = '"_cityID_"'" 
		}
		
		set sql=sql_" Order by ADRG"
		
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)	
		{
			set id=result.ID
			set adrg=result.ADRG
			set adrgDesc=result.ADRGDesc	
			set admvs=result.Admvs
			set unionFlag=result.UnionFlag
			set segmentationFlag=result.SegmentationFlag
			set selectionCriteria=result.SelectionCriteria
			set provinceID=result.provinceID
			set provinceDesc=result.provinceDesc
			set cityID=result.cityID
			set cityDesc=result.cityDesc
			
			set dataObj={}
			set dataObj.id=id
			set dataObj.adrg=adrg
			set dataObj.adrgDesc=adrgDesc
			set dataObj.admvs=admvs
			set dataObj.unionFlag=unionFlag
			set dataObj.segmentationFlag=segmentationFlag
			set dataObj.selectionCriteria=selectionCriteria
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
		set errorInfo="查询ADRG细分规则出现问题:w ##class("_$ClassName()_").GetDRGSegmentationRulesList("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 保存/更新ADRG细分规则
/// Table:       HB_DRGSegmentationRules (User.HBDRGSegmentationRules)
/// Input:       jsonObj - 包含params
/// Output:      保存结果
/// Debug:       w ##class(src.DRG.BasicData.DRGRSegmentationRules).SaveDRGSegmentationRules({}).%ToJSON()
ClassMethod SaveDRGSegmentationRules(jsonObj) As %Library.DynamicObject
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
		set adrg=params.adrg
		set adrgDesc=params.adrgDesc
		set provinceDr=params.provinceDr
		set cityDr=params.cityDr
		set admvs=params.admvs
		set unionFlag=params.unionFlag
		set segmentationFlag=params.segmentationFlag
		set selectionCriteria=params.selectionCriteria
		
		// 参数校验
		if adrg="" {
			set resultObj.errorCode="02041004"
			set resultObj.errorMessage="ADRG代码不能为空"
			quit
		}
		if adrgDesc="" {
			set resultObj.errorCode="02041005"
			set resultObj.errorMessage="ADRG描述不能为空"
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
		if unionFlag="" {
			set resultObj.errorCode="02041006"
			set resultObj.errorMessage="联合标志不能为空"
			quit
		}
		if segmentationFlag="" {
			set resultObj.errorCode="02041007"
			set resultObj.errorMessage="细分标志不能为空"
			quit
		}
		
		// 判断是新增还是更新
		if ID="" {
			// 检查是否已存在相同记录
			&sql(SELECT ID INTO :existID FROM HB_DRGSegmentationRules WHERE ADRG=:adrg AND Province_Dr=:provinceDr AND City_Dr=:cityDr)
			if SQLCODE=0 {
				set resultObj.errorCode="02041008"
				set resultObj.errorMessage="该ADRG细分规则已存在（同一省市下ADRG代码不能重复）"
				quit
			}
		}
		
		// 使用operatetable工具类保存数据
		set data=[]
		set dataObj={}
		set dataObj.ID=ID
		set dataObj.ADRG=adrg
		set dataObj.ADRGDesc=adrgDesc
		set dataObj.ProvinceDr=provinceDr
		set dataObj.CityDr=cityDr
		set dataObj.Admvs=admvs
		set dataObj.UnionFlag=unionFlag
		set dataObj.SegmentationFlag=segmentationFlag
		set dataObj.SelectionCriteria=selectionCriteria
		set dataObj.UpdateUserDr=userID
		set dataObj.UpdateDate=$zd($h,3)
		set dataObj.UpdateTime=$zt($p($h,",",2),1)
		
		set insObj={}
		set insObj.className="User.HBDRGSegmentationRules"
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
		set errorInfo="保存ADRG细分规则出现问题:w ##class("_$ClassName()_").SaveDRGSegmentationRules("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 删除ADRG细分规则
/// Table:       HB_DRGSegmentationRules (User.HBDRGSegmentationRules)
/// Input:       jsonObj - 包含params.id
/// Output:      删除结果
/// Debug:       w ##class(src.DRG.BasicData.DRGRSegmentationRules).DeleteDRGSegmentationRules({}).%ToJSON()
ClassMethod DeleteDRGSegmentationRules(jsonObj) As %Library.DynamicObject
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
		
		&sql(DELETE FROM HB_DRGSegmentationRules WHERE ID=:ID)
		
		if SQLCODE'=0 {
			set resultObj.errorCode="04000009"
			set resultObj.errorMessage="删除失败，SQL错误码："_SQLCODE
			quit
		}
		
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="删除ADRG细分规则出现问题:w ##class("_$ClassName()_").DeleteDRGSegmentationRules("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

}
