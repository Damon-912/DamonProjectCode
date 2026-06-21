#Import SQLUSER

/// 字典数据初始化工具类
/// 提供字典数据批量插入功能
Class src.DRG.BasicData.DictDataInit Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 初始化HIS数据同步相关字典数据
/// 包括：同步类型、同步状态、HIS配置类型
ClassMethod InitHisSyncDict() As %Status
{
	new (tSC, tDictTypeID, tID)
	set $zt="Error"
	set tSC=$$$OK
	
	try {
		// 1. 插入字典类型（Parent_Dr = NULL）
		// 同步类型 (SYNC_TYPE)
		set tDictTypeID=..InsertDictType("SYNC_TYPE", "同步类型", "HIS数据同步类型")
		if tDictTypeID="" {
			set tSC=$$$ERROR($$$GeneralError, "插入SYNC_TYPE类型失败")
			quit
		}
		
		// 同步状态 (SYNC_STATUS)
		set tID=..InsertDictType("SYNC_STATUS", "同步状态", "HIS数据同步状态")
		if tID="" {
			set tSC=$$$ERROR($$$GeneralError, "插入SYNC_STATUS类型失败")
			quit
		}
		
		// HIS配置类型 (HIS_CONFIG)
		set tID=..InsertDictType("HIS_CONFIG", "HIS配置类型", "HIS服务配置类型")
		if tID="" {
			set tSC=$$$ERROR($$$GeneralError, "插入HIS_CONFIG类型失败")
			quit
		}
		
		// 2. 插入字典项（Parent_Dr = 类型ID）
		// 同步类型字典项
		do ..InsertDictItem(tDictTypeID, "incremental", "增量同步", 1, "按上次同步时间增量同步")
		do ..InsertDictItem(tDictTypeID, "full", "全量同步", 2, "按日期范围全量同步")
		
		// 同步状态字典项
		do ..InsertDictItem(tID, "running", "同步中", 1, "同步任务正在执行")
		do ..InsertDictItem(tID, "success", "成功", 2, "同步任务执行成功")
		do ..InsertDictItem(tID, "failed", "失败", 3, "同步任务执行失败")
		do ..InsertDictItem(tID, "pending", "等待中", 4, "同步任务等待执行")
		do ..InsertDictItem(tID, "stopped", "已停止", 5, "同步任务已停止")
		
		// HIS配置类型字典项
		do ..InsertDictItem(tID, "HisIP", "HIS服务器IP", 1, "HIS服务器IP地址")
		do ..InsertDictItem(tID, "HisPort", "HIS服务器端口", 2, "HIS服务器端口号")
		do ..InsertDictItem(tID, "HisURL", "HIS服务URL", 3, "HIS服务URL路径")
		do ..InsertDictItem(tID, "Authorization", "认证信息", 4, "HIS接口认证信息")
		
	} catch tException {
		set tSC=tException.AsStatus()
	}
	
	quit tSC

Error:
	set $zt=""
	quit $$$ERROR($$$GeneralError, $ZE)
}

/// 插入字典类型（Parent_Dr = NULL）
/// pCode: 字典类型编码
/// pName: 字典类型名称
/// pRemark: 备注
/// 返回：插入的记录ID（失败返回空字符串）
ClassMethod InsertDictType(pCode As %String, pName As %String, pRemark As %String) As %String
{
	new (tObj, tID)
	set $zt="Error"
	set tID=""
	
	try {
		// 检查是否已存在
		set tID=$o(^CBDRGDictTableI("Code", pCode, 0))
		if tID'="" {
			quit
		}
		
		set tObj=##class(User.CBDRGDictTable).%New()
		set tObj.Code=pCode
		set tObj.Name=pName
		set tObj.Status="Y"
		set tObj.SortNo=0
		set tObj.Remark=pRemark
		set tObj.CreateDate=$zd($h,5)
		set tObj.CreateTime=$zt($p($h,",",2))
		// CreateUserDr 暂时留空，实际应从session获取
		
		set tSC=tObj.%Save()
		if $$$ISERR(tSC) {
			set tID=""
			quit
		}
		set tID=tObj.%Id()
		
	} catch {
		set tID=""
	}
	
	quit tID

Error:
	set $zt=""
	quit ""
}

/// 插入字典项（Parent_Dr = 类型ID）
/// pParentID: 父级类型ID
/// pCode: 字典项编码
/// pName: 字典项名称
/// pSortNo: 排序号
/// pRemark: 备注
ClassMethod InsertDictItem(pParentID As %String, pCode As %String, pName As %String, pSortNo As %Integer, pRemark As %String) As %Status
{
	new (tObj, tSC)
	set $zt="Error"
	set tSC=$$$OK
	
	try {
		// 检查是否已存在
		set tID=$o(^CBDRGDictTableI("Code", pParentID, pCode, 0))
		if tID'="" {
			quit
		}
		
		set tObj=##class(User.CBDRGDictTable).%New()
		set tObj.ParentDr=##class(User.CBDRGDictTable).%OpenId(pParentID)
		set tObj.Code=pCode
		set tObj.Name=pName
		set tObj.Status="Y"
		set tObj.SortNo=pSortNo
		set tObj.Remark=pRemark
		set tObj.CreateDate=$zd($h,5)
		set tObj.CreateTime=$zt($p($h,",",2))
		// CreateUserDr 暂时留空，实际应从session获取
		
		set tSaveSC=tObj.%Save()
		if $$$ISERR(tSaveSC) {
			set tSC=tSaveSC
			quit
		}
		
	} catch tException {
		set tSC=tException.AsStatus()
	}
	
	quit tSC

Error:
	set $zt=""
	quit $$$ERROR($$$GeneralError, $ZE)
}

}
