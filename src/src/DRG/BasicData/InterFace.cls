Class src.DRG.BasicData.InterFace Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存DRG基础数据
/// code: 02010010
ClassMethod SaveDRGBasicData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.BasicData.DictionaryData).SaveDRGBasicData(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询DRG基础数据
/// 02010011
ClassMethod GetDRGBasicData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.BasicData.DictionaryData).GetDRGBasicData(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除DRG基础数据
/// 02010012
ClassMethod DeleteDRGBasicData(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.BasicData.DictionaryData).DeleteDRGBasicData(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存DRG基础数据明细
/// 02010013
ClassMethod SaveDRGBasicDataSub(postObj) As %Library.DynamicObject
{
	new (postObj)
	quit ##class(src.DRG.BasicData.DictionaryData).SaveDRGBasicDataSub(postObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询DRG基础数据明细
/// 02010014
ClassMethod GetDRGBasicDataSub(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).GetDRGBasicDataSub(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除DRG基础数据明细
/// 02010015
ClassMethod DeleteDRGBasicDataSub(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).DeleteDRGBasicDataSub(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存(ADRG)核心疾病诊断相关分组规则列表
/// 02010016
ClassMethod SaveDRGCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).SaveDRGCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询(ADRG)核心疾病诊断相关分组规则列表
/// 02010017
ClassMethod GetDRGCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).GetDRGCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除(ADRG)核心疾病诊断相关分组规则列表
/// 02010018
ClassMethod DeleteDRGCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).DeleteDRGCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存按病种分值(DIP)付费病种库(2.0版)核心病种
/// 02010019
ClassMethod SaveDIPCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).SaveDIPCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询按病种分值(DIP)付费病种库(2.0版)核心病种
/// 02010020
ClassMethod GetDIPCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).GetDIPCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除按病种分值(DIP)付费病种库(2.0版)核心病种
/// 02010021
ClassMethod DeleteDIPCoreGroupsList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictionaryData).DeleteDIPCoreGroupsList(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询医保ICD编码信息
/// 02010022
ClassMethod GetMedInsuICDInfo(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).GetMedInsuICDInfo(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询各地方版本ICD编码信息
/// 02010037
ClassMethod GetICDInfo(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).GetICDInfo(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: ICD编码导入预览（校验数据并返回预览结果）
/// 02010038
ClassMethod PreviewImportICD(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).PreviewImportICD(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 确认导入ICD编码信息
/// 02010039
ClassMethod ConfirmImportICD(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).ConfirmImportICD(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 下载ICD编码导入模板
/// 02010040
ClassMethod DownloadImportTemplate(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).DownloadImportTemplate(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存医保ICD编码映射关系
/// 02010023
ClassMethod UpdateICDMappingInfo(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.ICDInfo).UpdateMappingInfo(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除医保ICD编码映射关系
/// 02010024
ClassMethod DeleteICDMappingInfo(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.ICDInfo).DeleteMappingInfo(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询医保ICD编码映射关系
/// 02010025
ClassMethod GetICDMappingInfo(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.ICDInfo).QueryMappingInfo(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 保存DRG核心算法配置
/// 02010032
ClassMethod UpdateDRGCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.CoreAlgorithm).UpdateDRGCoreAlgorithm(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 查询DRG核心算法配置
/// 02010033
ClassMethod GetDRGCoreAlgorithm(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.CoreAlgorithm).GetDRGCoreAlgorithm(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 删除DRG核心算法配置
/// 02010034
ClassMethod DeleteDRGCoreAlgorithm(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.CoreAlgorithm).DeleteDRGCoreAlgorithm(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 查询DRG目录信息
/// 02010041
ClassMethod GetDRGCataLogList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGCataLog).GetDRGCataLogList(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 保存/更新DRG目录信息
/// 02010042
ClassMethod SaveDRGCataLog(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGCataLog).SaveDRGCataLog(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 删除DRG目录信息
/// 02010043
ClassMethod DeleteDRGCataLog(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGCataLog).DeleteDRGCataLog(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 查询ADRG细分规则
/// 02010044
ClassMethod GetDRGSegmentationRulesList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGRSegmentationRules).GetDRGSegmentationRulesList(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 保存/更新ADRG细分规则
/// 02010045
ClassMethod SaveDRGSegmentationRules(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGRSegmentationRules).SaveDRGSegmentationRules(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-04-09
/// Description: 删除ADRG细分规则
/// 02010046
ClassMethod DeleteDRGSegmentationRules(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGRSegmentationRules).DeleteDRGSegmentationRules(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: DRGs编码导入预览（校验数据并返回预览结果）
/// 02010047
ClassMethod PreviewImportDRGs(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGCataLog).PreviewImportDRGs(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 确认导入DRGs编码信息
/// 02010048
ClassMethod ConfirmImportDRGs(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGCataLog).ConfirmImportDRGs(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-01-01
/// Description: 下载DRGs编码导入模板
/// 02010049
ClassMethod DownloadDRGsTemplate(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGCataLog).DownloadDRGsTemplate(jsonObj)
}

/// Creator:     System
/// CreatDate:   2026-04-17
/// Description: DRG核心算法配置导入预览
/// 02010050
ClassMethod PreviewImportDRGCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.CoreAlgorithm).PreviewImportDRGCoreAlgorithm(jsonObj)
}

/// Creator:     System
/// CreatDate:   2026-04-17
/// Description: 确认导入DRG核心算法配置
/// 02010051
ClassMethod ConfirmImportDRGCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.CoreAlgorithm).ConfirmImportDRGCoreAlgorithm(jsonObj)
}

/// Creator:     System
/// CreatDate:   2026-04-17
/// Description: 下载DRG核心算法配置导入模板
/// 02010052
ClassMethod DownloadDRGCoreAlgorithmTemplate(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.CoreAlgorithm).DownloadDRGCoreAlgorithmTemplate(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-04-21
/// Description: 查询DIP核心算法配置
/// 02010053
ClassMethod QueryDIPCoreAlgorithm(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.CoreAlgorithm).QueryDIPCoreAlgorithm(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-04-21
/// Description: 保存DIP核心算法配置
/// 02010054
ClassMethod SaveDIPCoreAlgorithm(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.CoreAlgorithm).SaveDIPCoreAlgorithm(jsonObj)
}

/// Creator:     CM
/// CreatDate:   2026-04-21
/// Description: 删除DIP核心算法配置
/// 02010055
ClassMethod DeleteDIPCoreAlgorithm(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.CoreAlgorithm).DeleteDIPCoreAlgorithm(jsonObj)
}

/// Creator:     System
/// CreatDate:   2026-04-22
/// Description: 下载DIP核心算法配置导入模板
/// 02010056
ClassMethod DownloadDIPCoreAlgorithmTemplate(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.CoreAlgorithm).DownloadDIPCoreAlgorithmTemplate(jsonObj)
}

/// Creator:     System
/// CreatDate:   2026-04-22
/// Description: DIP核心算法配置导入预览
/// 02010057
ClassMethod PreviewImportDIPCoreAlgorithm(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.CoreAlgorithm).PreviewImportDIPCoreAlgorithm(jsonObj)
}

/// Creator:     System
/// CreatDate:   2026-04-22
/// Description: 确认导入DIP核心算法配置
/// 02010058
ClassMethod ConfirmImportDIPCoreAlgorithm(jsonObj) As %Library.DynamicAbstractObject
{
	Quit ##class(src.DRG.BasicData.CoreAlgorithm).ConfirmImportDIPCoreAlgorithm(jsonObj)
}

/// Creator:     AI
/// CreatDate:   2026-05-22
/// Description: 查询DRG字典类型列表
/// 02010059
ClassMethod GetDRGDictTypeList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set dataArr=[]
	try{
		set params=jsonObj.params.%Get(0)
		set code=params.code
		set name=params.name
		set sql="SELECT ID,Code,Name,Status,SortNo,Remark,CreateDate FROM CB_DRGDictTable WHERE Parent_Dr IS NULL"
		if code'="" set sql=sql_" AND Code LIKE '%"_code_"%'"
		if name'="" set sql=sql_" AND Name LIKE '%"_name_"%'"
		set sql=sql_" ORDER BY SortNo ASC, ID ASC"
		set sqlObj=##class(%SQL.Statement).%New(1)
		do sqlObj.%Prepare(sql)
		set rs=sqlObj.%Execute()
		while rs.%Next()
		{
			set row={}
			set row.id=rs.%Get("ID")
			set row.code=rs.%Get("Code")
			set row.name=rs.%Get("Name")
			set row.status=rs.%Get("Status")
			set row.sortNo=rs.%Get("SortNo")
			set row.remark=rs.%Get("Remark")
			set row.createDate=rs.%Get("CreateDate")
			set row.statusDesc=$select(row.status="Y":"启用",1:"停用")
			set row.statusFlag=row.status
			do dataArr.%Push(row)
		}
		set resultObj.result.rows=dataArr
		set resultObj.result.total=dataArr.%Size()
	}
	catch(e){ set resultObj.errorCode="04000007",resultObj.errorMessage="查询字典类型失败:"_e.Name }
	quit resultObj
}

/// Creator:     AI
/// CreatDate:   2026-05-22
/// Description: 查询DRG字典项列表
/// 02010060
ClassMethod GetDRGDictItemList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	set pageSize="",currentPage=1,count=0,dataArr=[]
	try{
		if jsonObj.%IsDefined("pagination")'=0{
			set pg=jsonObj.pagination.%Get(0)
			set pageSize=pg.pageSize,currentPage=pg.currentPage
		}
		set params=jsonObj.params.%Get(0)
		set parentDr=params.parentDr,code=params.code,name=params.name,status=params.status
		if parentDr="" { set resultObj.errorCode="01000010",resultObj.errorMessage="请选择字典类型" quit }
		set sql="SELECT ID,Code,Name,Status,SortNo,Remark,CreateDate FROM CB_DRGDictTable WHERE Parent_Dr="_parentDr
		if code'="" set sql=sql_" AND Code LIKE '%"_code_"%'"
		if name'="" set sql=sql_" AND Name LIKE '%"_name_"%'"
		set sql=sql_" ORDER BY SortNo ASC, ID ASC"
		set sqlObj=##class(%SQL.Statement).%New(1)
		do sqlObj.%Prepare(sql)
		set rs=sqlObj.%Execute()
		while rs.%Next()
		{
			set st=rs.%Get("Status")
			if status="Y",st'="Y" continue
			if status="N",st'="N" continue
			set count=count+1
			if pageSize'="" continue:(count<((currentPage-1)*pageSize+1))||(count>(currentPage*pageSize))
			set row={}
			set row.id=rs.%Get("ID"),row.code=rs.%Get("Code"),row.name=rs.%Get("Name")
			set row.status=st,row.sortNo=rs.%Get("SortNo"),row.remark=rs.%Get("Remark")
			set row.createDate=rs.%Get("CreateDate"),row.parentDr=parentDr
			set row.statusDesc=$select(st="Y":"启用",1:"停用"),row.statusFlag=st
			do dataArr.%Push(row)
		}
		set resultObj.result.rows=dataArr,resultObj.result.total=count
	}
	catch(e){ set resultObj.errorCode="04000007",resultObj.errorMessage="查询字典项失败:"_e.Name }
	quit resultObj
}

/// Creator:     AI
/// CreatDate:   2026-05-22
/// Description: 保存DRG字典项
/// 02010061
ClassMethod SaveDRGDictItem(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultObj={"errorCode":"0","errorMessage":"保存成功","result":{}}
	try{
		set params=postObj.params.%Get(0),session=postObj.session.%Get(0),userID=session.userID
		set id=params.id,parentDr=params.parentDr,code=params.code,name=params.name
		set status=$select(params.status="":"Y",1:params.status)
		set sortNo=params.sortNo,remark=params.remark
		if parentDr="" { set resultObj.errorCode="01000010",resultObj.errorMessage="请选择字典类型" quit }
		if code="" { set resultObj.errorCode="01000011",resultObj.errorMessage="编码不能为空" quit }
		if name="" { set resultObj.errorCode="01000012",resultObj.errorMessage="名称不能为空" quit }
		; 新增时自动取最大SortNo+1
		if (id="")&&(sortNo="") {
			set tmpSql="SELECT MAX(SortNo) as maxNo FROM CB_DRGDictTable WHERE Parent_Dr="_parentDr
			set tmpStmt=##class(%SQL.Statement).%New(1)
			do tmpStmt.%Prepare(tmpSql)
			set tmpRs=tmpStmt.%Execute()
			if tmpRs.%Next() { set sortNo=tmpRs.%Get("maxNo") }
			if sortNo="" set sortNo=0
			set sortNo=sortNo+1
		}
		set data=[],row={}
		set row.ID=id,row.ParentDr=parentDr,row.Code=code,row.Name=name
		set row.Status=status,row.SortNo=sortNo,row.Remark=remark
		set row.CreateUserDr=userID
		set row.CreateDate=$zd($h,3),row.CreateTime=$zt($p($h,",",2),1)
		do data.%Push(row)
		set insObj={}
		set insObj.className="User.CBDRGDictTable"
		set insObj.updateUserID=userID
		set insObj.data=data
		set rtn=""
		if id="" { set rtn=##class(src.util.operatetable).Insert(.insObj) }
		else { set rtn=##class(src.util.operatetable).Update(.insObj) }
		if rtn.errorCode'=0 { set resultObj.errorCode=rtn.errorCode,resultObj.errorMessage=rtn.errorMessage }
	}
	catch(e){ set resultObj.errorCode="04000007",resultObj.errorMessage="保存字典项失败:"_e.Name }
	quit resultObj
}

/// Creator:     AI
/// CreatDate:   2026-05-22
/// Description: 保存DRG字典类型
/// 02010062
ClassMethod SaveDRGDictType(postObj) As %Library.DynamicObject
{
	new (postObj)
	set resultObj={"errorCode":"0","errorMessage":"保存成功","result":{}}
	try{
		set params=postObj.params.%Get(0),session=postObj.session.%Get(0),userID=session.userID
		set id=params.id,code=params.code,name=params.name
		set status=$select(params.status="":"Y",1:params.status),remark=params.remark
		if code="" { set resultObj.errorCode="01000011",resultObj.errorMessage="编码不能为空" quit }
		if name="" { set resultObj.errorCode="01000012",resultObj.errorMessage="名称不能为空" quit }
		set data=[],row={}
		set row.ID=id,row.ParentDr="",row.Code=code,row.Name=name
		set row.Status=status,row.Remark=remark
		set row.CreateUserDr=userID
		set row.CreateDate=$zd($h,3),row.CreateTime=$zt($p($h,",",2),1)
		do data.%Push(row)
		set insObj={}
		set insObj.className="User.CBDRGDictTable"
		set insObj.updateUserID=userID
		set insObj.data=data
		set rtn=""
		if id="" { set rtn=##class(src.util.operatetable).Insert(.insObj) }
		else { set rtn=##class(src.util.operatetable).Update(.insObj) }
		if rtn.errorCode'=0 { set resultObj.errorCode=rtn.errorCode,resultObj.errorMessage=rtn.errorMessage }
	}
	catch(e){ set resultObj.errorCode="04000007",resultObj.errorMessage="保存字典类型失败:"_e.Name }
	quit resultObj
}

/// Creator:     AI
/// CreatDate:   2026-05-23
/// Description: 根据字典类型编码查询字典项列表（用于前端下拉选择）
/// 02010063
ClassMethod GetDRGDictItemByTypeCode(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DictManage).GetDRGDictItemByTypeCode(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-05-26
/// Description: 查询DRG特异化分组方案
/// 02010064
ClassMethod GetDRGSpecialGroupList(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGSpecialGroup).GetDRGSpecialGroupList(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-05-26
/// Description: 保存/更新DRG特异化分组方案
/// 02010065
ClassMethod SaveDRGSpecialGroup(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGSpecialGroup).SaveDRGSpecialGroup(jsonObj)
}

/// Creator:     系统
/// CreatDate:   2026-05-26
/// Description: 删除DRG特异化分组方案
/// 02010066
ClassMethod DeleteDRGSpecialGroup(jsonObj) As %Library.DynamicObject
{
	new (jsonObj)
	quit ##class(src.DRG.BasicData.DRGSpecialGroup).DeleteDRGSpecialGroup(jsonObj)
}

}
