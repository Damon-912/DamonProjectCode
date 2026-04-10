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

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 下载DRG目录导入模板 (02010049)
/// Table:       HB_DRGCataLog (User.HBDRGCataLog)
/// Input:       jsonObj
/// Output:      CSV模板文件(Base64编码)
/// Debug:       w ##class(src.DRG.BasicData.DRGCataLog).DownloadDrgTemplate({}).%ToJSON()
ClassMethod DownloadDRGsTemplate(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"下载成功","result":{}}
	try
	{
		// 创建模板内容
		set templateContent="DRG代码,DRG描述,行政区划"_$c(10)
		set templateContent=templateContent_"ES23,呼吸系统肿瘤,110"_$c(10)
		set templateContent=templateContent_"FB23,心脏介入治疗,110"_$c(10)
		set templateContent=templateContent_"IC13,关节置换,110"_$c(10)
		
		// 将内容转换为UTF-8编码
		set utf8Content=$zcvt(templateContent,"O","UTF8")
		
		// Base64编码
		set base64Data=$zcvt(utf8Content,"O","BASE64")
		
		set resultObj.result.fileName="DRG目录导入模板.csv"
		set resultObj.result.fileData=base64Data
		set resultObj.result.contentType="text/csv; charset=utf-8"
		
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="下载DRG目录导入模板出现问题:w ##class("_$ClassName()_").DownloadDrgTemplate("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: DRG目录导入预览 (02010047)
/// Table:       HB_DRGCataLog (User.HBDRGCataLog)
/// Input:       jsonObj - 包含params(provinceID, cityID, fileData)
/// Output:      预览数据列表
/// Debug:       w ##class(src.DRG.BasicData.DRGCataLog).PreviewImportDrg({}).%ToJSON()
ClassMethod PreviewImportDRGs(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"预览成功","result":{"totalCount":0,"validCount":0,"invalidCount":0,"duplicateCount":0,"previewList":[]}}
	
	set (totalCount,validCount,invalidCount,duplicateCount)=0
	set previewList=[]
	
	try
	{
		set params=jsonObj.params.%Get(0)
		
		// 检查必需参数
		if '$isobject(params) {
			set resultObj.errorCode="02010001"
			set resultObj.errorMessage="参数错误：缺少params参数"
			quit
		}
		
		set fileData=params.fileData
		set provinceID=params.provinceID
		set cityID=params.cityID
		
		if (provinceID="")||(cityID="")
		{
			set resultObj.errorCode="-1"
			set resultObj.errorMessage="接口入参省、市代码不能为空！"
			quit	
		}
		
		if fileData=""
		{
			set resultObj.errorCode="02010003"
			set resultObj.errorMessage="文件数据不能为空"
			quit
		}
		
		// Base64解码
		set csvContent=""
		try {
			set csvContent=$zcvt(fileData,"I","BASE64")
		} catch e1 {
			// 尝试其他解码方式
			try {
				set binaryData=##class(%SYSTEM.Encryption).Base64Decode(fileData)
				set csvContent=$zcvt(binaryData,"I","UTF8")
				if csvContent["?" {
					set csvContent=$zcvt(binaryData,"I","GB18030")
				}
			} catch e2 {
				set csvContent=binaryData
			}
		}
		
		if csvContent=""
		{
			set resultObj.errorCode="02010003"
			set resultObj.errorMessage="文件解码失败，请提供有效的CSV文件"
			quit
		}
		
		// 解析CSV行
		set lineNum=0
		set ptr=1
		for
		{
			set line=$piece(csvContent,$c(10),ptr)
			quit:line=""
			set ptr=ptr+1
			set lineNum=lineNum+1
			continue:lineNum=1  // 跳过表头
			
			set line=$replace(line,$c(13),"")
			continue:line=""
			
			set totalCount=totalCount+1
			set rowNum=lineNum-1
			
			// 解析CSV列
			set code=$piece(line,",",1)
			set descripts=$piece(line,",",2)
			set admvs=$piece(line,",",3)
			
			set previewObj={}
			set previewObj.rowNum=rowNum
			set previewObj.code=code
			set previewObj.descripts=descripts
			set previewObj.admvs=admvs
			
			// 数据校验
			if code=""
			{
				set previewObj.status="invalid"
				set previewObj.errorMsg="DRG代码不能为空"
				set invalidCount=invalidCount+1
				do previewList.%Push(previewObj)
				continue
			}
			
			if descripts=""
			{
				set previewObj.status="invalid"
				set previewObj.errorMsg="DRG描述不能为空"
				set invalidCount=invalidCount+1
				do previewList.%Push(previewObj)
				continue
			}
			
			if admvs=""
			{
				set previewObj.status="invalid"
				set previewObj.errorMsg="行政区划不能为空"
				set invalidCount=invalidCount+1
				do previewList.%Push(previewObj)
				continue
			}
			
			// 检查是否已存在
			set existingID=""
			&sql(SELECT ID INTO :existingID FROM SQLUser.HB_DRGCataLog 
			     WHERE Code=:code AND Province_Dr=:provinceID AND City_Dr=:cityID)
			
			if existingID'=""
			{
				set previewObj.status="duplicate"
				set previewObj.errorMsg="该DRG代码已存在，导入将执行更新操作"
				set duplicateCount=duplicateCount+1
			}
			else
			{
				set previewObj.status="valid"
				set previewObj.errorMsg=""
				set validCount=validCount+1
			}
			
			do previewList.%Push(previewObj)
		}
		
		set resultObj.result.totalCount=totalCount
		set resultObj.result.validCount=validCount
		set resultObj.result.invalidCount=invalidCount
		set resultObj.result.duplicateCount=duplicateCount
		set resultObj.result.previewList=previewList
		
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="DRG目录导入预览出现问题:w ##class("_$ClassName()_").PreviewImportDrg("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: DRG目录确认导入 (02010048)
/// Table:       HB_DRGCataLog (User.HBDRGCataLog)
/// Input:       jsonObj - 包含params(provinceID, cityID, fileData)
/// Output:      详细导入结果报告
/// Debug:       w ##class(src.DRG.BasicData.DRGRSegmentationRules).ConfirmImportDrg({}).%ToJSON()
ClassMethod ConfirmImportDRGs(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"导入完成","result":{"totalCount":0,"successCount":0,"failCount":0,"duplicateCount":0,"newCount":0,"failList":[]}}
	
	set (totalCount,successCount,failCount,duplicateCount,newCount)=0
	set failList=[]
	
	try
	{
		set params=jsonObj.params.%Get(0)
		
		// 检查必需参数
		if '$isobject(params) {
			set resultObj.errorCode="02010001"
			set resultObj.errorMessage="参数错误：缺少params参数"
			quit
		}
		
		set fileData=params.fileData
		set provinceID=params.provinceID
		set cityID=params.cityID
		
		if (provinceID="")||(cityID="")
		{
			set resultObj.errorCode="-1"
			set resultObj.errorMessage="接口入参省、市代码不能为空！"
			quit	
		}
		
		// 获取用户ID
		set createUserDr=""
		if $isobject(jsonObj.session) 
		{
			set session=jsonObj.session.%Get(0)
			set:session'="" createUserDr=session.userID
		}
		set:createUserDr="" createUserDr="158"
		
		// Base64解码
		set csvContent=""
		try {
			set csvContent=$zcvt(fileData,"I","BASE64")
		} catch e1 {
			try {
				set binaryData=##class(%SYSTEM.Encryption).Base64Decode(fileData)
				set csvContent=$zcvt(binaryData,"I","UTF8")
				if csvContent["?" {
					set csvContent=$zcvt(binaryData,"I","GB18030")
				}
			} catch e2 {
				set csvContent=binaryData
			}
		}
		
		if csvContent=""
		{
			set resultObj.errorCode="02010003"
			set resultObj.errorMessage="文件解码失败，请提供有效的CSV文件"
			quit
		}
		
		// 解析CSV并执行导入
		set lineNum=0
		set ptr=1
		for
		{
			set line=$piece(csvContent,$c(10),ptr)
			quit:line=""
			set ptr=ptr+1
			set lineNum=lineNum+1
			continue:lineNum=1  // 跳过表头
			
			set line=$replace(line,$c(13),"")
			continue:line=""
			
			set totalCount=totalCount+1
			set rowNum=lineNum-1
			
			// 解析CSV列
			set code=$piece(line,",",1)
			set descripts=$piece(line,",",2)
			set admvs=$piece(line,",",3)
			
			// 必填校验
			if (code="")||(descripts="")||(admvs="")
			{
				set failCount=failCount+1
				set failObj={}
				set failObj.rowNum=rowNum
				set failObj.code=code
				set errorDetail="必填字段为空: "
				if code="" set errorDetail=errorDetail_"DRG代码 "
				if descripts="" set errorDetail=errorDetail_"DRG描述 "
				if admvs="" set errorDetail=errorDetail_"行政区划 "
				set failObj.errorMsg=errorDetail
				do failList.%Push(failObj)
				continue
			}
			
			// 检查是否已存在
			set existingID=""
			&sql(SELECT ID INTO :existingID FROM SQLUser.HB_DRGCataLog 
			     WHERE Code=:code AND Province_Dr=:provinceID AND City_Dr=:cityID)
			
			// 构建数据对象
			set dataObj={}
			set dataObj.Code=code
			set dataObj.Descripts=descripts
			set dataObj.Admvs=admvs
			set dataObj.ProvinceDr=provinceID
			set dataObj.CityDr=cityID
			set dataObj.UpdateUserDr=createUserDr
			set dataObj.UpdateDate=$zd($h,3)
			set dataObj.UpdateTime=$zt($p($h,",",2),1)
			
			set insObj={},data=[]
			set insObj.className="User.HBDRGCataLog"
			set insObj.updateUserID=createUserDr
			do data.%Push(dataObj)
			set insObj.data=data
			
			if existingID'=""
			{
				// 更新
				set dataObj.ID=existingID
				set rtn=##class(src.util.operatetable).Update(.insObj)
				set duplicateCount=duplicateCount+1
			}
			else
			{
				// 新增
				set dataObj.CreateDate=$zd($h,3)
				set dataObj.CreateTime=$zt($p($h,",",2),1)
				set dataObj.CreateUserDr=createUserDr
				set rtn=##class(src.util.operatetable).Insert(.insObj)
				set newCount=newCount+1
			}
			
			if rtn.errorCode'=0
			{
				set failCount=failCount+1
				set failObj={}
				set failObj.rowNum=rowNum
				set failObj.code=code
				set failObj.errorMsg=rtn.errorMessage
				do failList.%Push(failObj)
			}
			else
			{
				set successCount=successCount+1
			}
		}
		
		set resultObj.result.totalCount=totalCount
		set resultObj.result.successCount=successCount
		set resultObj.result.failCount=failCount
		set resultObj.result.duplicateCount=duplicateCount
		set resultObj.result.newCount=newCount
		set resultObj.result.failList=failList
		
		if failCount>0
		{
			set resultObj.errorCode="02010002"
			set resultObj.errorMessage="导入完成，部分数据导入失败，请查看失败列表"
		}
		
	}catch(e){
		set status=e.AsStatus()
		set errorMessage=$replace(##class(%SYSTEM.Status).GetErrorText(status,"cn"),"^"," ")
		set errorInfo="DRG目录确认导入出现问题:w ##class("_$ClassName()_").ConfirmImportDrg("_jsonObj.%ToJSON()_")"
		set errorLogID=##class(src.Interface.Message).InsErrRecord("04000007",errorInfo,errorMessage)
		set resultObj={}
		set resultObj.errorCode="04000007"
		set resultObj.errorMessage=##class(src.Interface.Message).GetErrorMessage("04000007")_errorLogID_",错误提示："_errorMessage
	}
	quit resultObj
}

}
