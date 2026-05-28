Import SQLUSER

/// DRG特异化分组服务类
/// 提供各地区DRG特异化分组方案的增改查删功能
Class src.DRG.BasicData.DRGSpecialGroup Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     系统
/// CreatDate:   2026-05-26
/// Description: 查询DRG特异化分组方案（接口02010064）
/// Table:       HB_DRGSpecialGroup (User.HBDRGSpecialGroup)
/// Input:       jsonObj - 包含params（drgCode/admvs/provinceID/cityID/year）和pagination
/// Output:      分页查询结果
/// Debug:       w ##class(src.DRG.BasicData.DRGSpecialGroup).GetDRGSpecialGroupList({}).%ToJSON()
ClassMethod GetDRGSpecialGroupList(jsonObj) As %Library.DynamicObject
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
		set drgCode=params.drgCode
		set admvs=params.admvs
		set provinceID=params.provinceID
		set cityID=params.cityID
		set year=params.year
		
		set sql=" SELECT ID,DRGCode,DRGName,PrincipalDiagnosis,PrincipalDiagnosisName,"
		       _" SecondaryDiagnosis,SecondaryDiagnosisName,MajorProcedure,MajorProcedureName,"
		       _" SecondaryProcedure,SecondaryProcedureName,GroupFactors,Remark,Admvs,"
		       _" Province_Dr as provinceID,Province_Dr->Descripts as provinceDesc,"
		       _" City_Dr as cityID,City_Dr->Descripts as cityDesc,Year,"
		       _" StartDate,StopDate,CreateDate,CreateTime "
		       _" FROM HB_DRGSpecialGroup where 1=1"
		
		if drgCode'=""
		{
			set sql=sql_" and DRGCode like '%"_drgCode_"%'" 
		}
		if admvs'=""
		{
			set sql=sql_" and Admvs like '%"_admvs_"%'" 
		}
		if provinceID'=""
		{
			set sql=sql_" and Province_Dr = '"_provinceID_"'" 
		}
		if cityID'=""
		{
			set sql=sql_" and City_Dr = '"_cityID_"'" 
		}
		if year'=""
		{
			set sql=sql_" and Year = '"_year_"'" 
		}
		
		set sql=sql_" Order by DRGCode"
		
		set sqlObj=##class(%SQL.Statement).%New(1)
		set sc=sqlObj.%Prepare(sql)
		set result=sqlObj.%Execute()
		while result.%Next(sc)	
		{
			set id=result.ID
			set drgCodeVal=result.DRGCode
			set drgName=result.DRGName	
			set principalDiagnosis=result.PrincipalDiagnosis
			set principalDiagnosisName=result.PrincipalDiagnosisName
			set secondaryDiagnosis=result.SecondaryDiagnosis
			set secondaryDiagnosisName=result.SecondaryDiagnosisName
			set majorProcedure=result.MajorProcedure
			set majorProcedureName=result.MajorProcedureName
			set secondaryProcedure=result.SecondaryProcedure
			set secondaryProcedureName=result.SecondaryProcedureName
			set groupFactors=result.GroupFactors
			set remark=result.Remark
			set admvsVal=result.Admvs
			set provinceIDVal=result.provinceID
			set provinceDesc=result.provinceDesc
			set cityIDVal=result.cityID
			set cityDesc=result.cityDesc
			set yearVal=result.Year
			set startDate=result.StartDate
			set stopDate=result.StopDate
			set createDate=result.CreateDate
			set createTime=result.CreateTime
			
			set dataObj={}
			set dataObj.id=id
			set dataObj.drgCode=drgCodeVal
			set dataObj.drgName=drgName
			set dataObj.principalDiagnosis=principalDiagnosis
			set dataObj.principalDiagnosisName=principalDiagnosisName
			set dataObj.secondaryDiagnosis=secondaryDiagnosis
			set dataObj.secondaryDiagnosisName=secondaryDiagnosisName
			set dataObj.majorProcedure=majorProcedure
			set dataObj.majorProcedureName=majorProcedureName
			set dataObj.secondaryProcedure=secondaryProcedure
			set dataObj.secondaryProcedureName=secondaryProcedureName
			set dataObj.groupFactors=groupFactors
			set dataObj.remark=remark
			set dataObj.admvs=admvsVal
			set dataObj.provinceID=provinceIDVal
			set dataObj.provinceDesc=provinceDesc
			set dataObj.cityID=cityIDVal
			set dataObj.cityDesc=cityDesc
			set dataObj.year=yearVal
			set dataObj.startDate=startDate
			set dataObj.stopDate=stopDate
			set dataObj.createDate=createDate
			set dataObj.createTime=createTime
			
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>((currentPage)*pageSize))
			do dataArr.%Push(dataObj)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=count
				
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="查询DRG特异化分组方案出现问题:w ##class("_$ClassName()_").GetDRGSpecialGroupList("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-05-26
/// Description: 保存/更新DRG特异化分组方案（接口02010065）
/// Table:       HB_DRGSpecialGroup (User.HBDRGSpecialGroup)
/// Input:       jsonObj - 包含params和session
/// Output:      保存结果
/// Debug:       w ##class(src.DRG.BasicData.DRGSpecialGroup).SaveDRGSpecialGroup({}).%ToJSON()
ClassMethod SaveDRGSpecialGroup(jsonObj) As %Library.DynamicObject
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
		set drgCode=params.drgCode
		set drgName=params.drgName
		set principalDiagnosis=params.principalDiagnosis
		set principalDiagnosisName=params.principalDiagnosisName
		set secondaryDiagnosis=params.secondaryDiagnosis
		set secondaryDiagnosisName=params.secondaryDiagnosisName
		set majorProcedure=params.majorProcedure
		set majorProcedureName=params.majorProcedureName
		set secondaryProcedure=params.secondaryProcedure
		set secondaryProcedureName=params.secondaryProcedureName
		set groupFactors=params.groupFactors
		set remark=params.remark
		set admvs=params.admvs
		set provinceDr=params.provinceDr
		set cityDr=params.cityDr
		set year=params.year
		set startDate=params.startDate
		set stopDate=params.stopDate
		
		// 参数校验
		if drgCode="" {
			set resultObj.errorCode="02042004"
			set resultObj.errorMessage="DRG编码不能为空"
			quit
		}
		if drgName="" {
			set resultObj.errorCode="02042005"
			set resultObj.errorMessage="DRG名称不能为空"
			quit
		}
		if admvs="" {
			set resultObj.errorCode="02042006"
			set resultObj.errorMessage="行政区划代码不能为空"
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
		if year="" {
			set resultObj.errorCode="02042007"
			set resultObj.errorMessage="年份不能为空"
			quit
		}
		
		// 使用operatetable工具类保存数据
		set dataArr=[]
		set dataObj={}
		set dataObj.ID=ID
		set dataObj.DRGCode=drgCode
		set dataObj.DRGName=drgName
		set dataObj.PrincipalDiagnosis=principalDiagnosis
		set dataObj.PrincipalDiagnosisName=principalDiagnosisName
		set dataObj.SecondaryDiagnosis=secondaryDiagnosis
		set dataObj.SecondaryDiagnosisName=secondaryDiagnosisName
		set dataObj.MajorProcedure=majorProcedure
		set dataObj.MajorProcedureName=majorProcedureName
		set dataObj.SecondaryProcedure=secondaryProcedure
		set dataObj.SecondaryProcedureName=secondaryProcedureName
		set dataObj.GroupFactors=groupFactors
		set dataObj.Remark=remark
		set dataObj.Admvs=admvs
		set dataObj.ProvinceDr=provinceDr
		set dataObj.CityDr=cityDr
		set dataObj.Year=year
		set dataObj.StartDate=startDate
		set dataObj.StopDate=stopDate
		
		// 新增时自动填充创建信息
		if ID="" {
			set dataObj.CreateDate=$zd($h,3)
			set dataObj.CreateTime=$zt($p($h,",",2),1)
			set dataObj.CreateUserDr=userID
		}
		
		do dataArr.%Push(dataObj)
		
		set insObj={}
		set insObj.className="User.HBDRGSpecialGroup"
		set insObj.updateUserID=userID
		set insObj.data=dataArr
		
		set rtn=""
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
		set errorInfo="保存DRG特异化分组方案出现问题:w ##class("_$ClassName()_").SaveDRGSpecialGroup("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-05-26
/// Description: 删除DRG特异化分组方案（接口02010066）
/// Table:       HB_DRGSpecialGroup (User.HBDRGSpecialGroup)
/// Input:       jsonObj - 包含params.id
/// Output:      删除结果
/// Debug:       w ##class(src.DRG.BasicData.DRGSpecialGroup).DeleteDRGSpecialGroup({}).%ToJSON()
ClassMethod DeleteDRGSpecialGroup(jsonObj) As %Library.DynamicObject
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
		
		&sql(DELETE FROM HB_DRGSpecialGroup WHERE ID=:ID)
		
		if SQLCODE'=0 {
			set resultObj.errorCode="04000009"
			set resultObj.errorMessage="删除失败，SQL错误码："_SQLCODE
			quit
		}
		
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="删除DRG特异化分组方案出现问题:w ##class("_$ClassName()_").DeleteDRGSpecialGroup("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

}
