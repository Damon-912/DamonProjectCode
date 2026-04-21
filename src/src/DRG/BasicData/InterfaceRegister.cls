/// 接口注册脚本 - 注册DRG目录信息和ADRG细分规则接口到CB_MapInterface
/// 执行方式: 在IRIS终端中运行 do ##class(src.DRG.BasicData.InterfaceRegister).RegisterAll()
/// 或者: 在IRIS终端中运行 do ##class(src.DRG.BasicData.InterfaceRegister).RegisterDRGCataLogInterfaces()
///       do ##class(src.DRG.BasicData.InterfaceRegister).RegisterDRGSegmentationRulesInterfaces()
Class src.DRG.BasicData.InterfaceRegister Extends %RegisteredObject [ Not ProcedureBlock ]
{

/// 注册所有新增接口
ClassMethod RegisterAll() As %String
{
	do ..RegisterDRGCataLogInterfaces()
	do ..RegisterDRGSegmentationRulesInterfaces()
	do ..RegisterDIPCoreAlgorithmImportInterfaces()
	quit "所有接口注册完成"
}

/// 注册DRG目录信息接口 (02010041/02010042/02010043)
ClassMethod RegisterDRGCataLogInterfaces() As %String
{
	set className="SRC.DRG.BASICDATA.INTERFACE"
	set sessionFlag="Y"
	set tokenFlag="N"
	
	// 02010041 - 查询DRG目录信息
	if '##this().CheckExists("02010041") {
		&sql(INSERT INTO CB_MapInterface (Code,Descripts,ClassName,MethodName,ServiceType,SessionFlag,TokenFlag) VALUES ('02010041','查询DRG目录信息',:className,'GETDRGCATALOGIST','S',:sessionFlag,:tokenFlag))
		w "02010041 注册成功",!
	} else {
		w "02010041 已存在，跳过",!
	}
	
	// 02010042 - 保存DRG目录信息
	if '##this().CheckExists("02010042") {
		&sql(INSERT INTO CB_MapInterface (Code,Descripts,ClassName,MethodName,ServiceType,SessionFlag,TokenFlag) VALUES ('02010042','保存DRG目录信息',:className,'SAVEDRGCATALOG','A',:sessionFlag,:tokenFlag))
		w "02010042 注册成功",!
	} else {
		w "02010042 已存在，跳过",!
	}
	
	// 02010043 - 删除DRG目录信息
	if '##this().CheckExists("02010043") {
		&sql(INSERT INTO CB_MapInterface (Code,Descripts,ClassName,MethodName,ServiceType,SessionFlag,TokenFlag) VALUES ('02010043','删除DRG目录信息',:className,'DELETEDRGCATALOG','D',:sessionFlag,:tokenFlag))
		w "02010043 注册成功",!
	} else {
		w "02010043 已存在，跳过",!
	}
	
	quit "DRG目录信息接口注册完成"
}

/// 注册ADRG细分规则接口 (02010044/02010045/02010046)
ClassMethod RegisterDRGSegmentationRulesInterfaces() As %String
{
	set className="SRC.DRG.BASICDATA.INTERFACE"
	set sessionFlag="Y"
	set tokenFlag="N"
	
	// 02010044 - 查询ADRG细分规则
	if '##this().CheckExists("02010044") {
		&sql(INSERT INTO CB_MapInterface (Code,Descripts,ClassName,MethodName,ServiceType,SessionFlag,TokenFlag) VALUES ('02010044','查询ADRG细分规则',:className,'GETDRGSEGMENTATIONRULESLIST','S',:sessionFlag,:tokenFlag))
		w "02010044 注册成功",!
	} else {
		w "02010044 已存在，跳过",!
	}
	
	// 02010045 - 保存ADRG细分规则
	if '##this().CheckExists("02010045") {
		&sql(INSERT INTO CB_MapInterface (Code,Descripts,ClassName,MethodName,ServiceType,SessionFlag,TokenFlag) VALUES ('02010045','保存ADRG细分规则',:className,'SAVEDRGSEGMENTATIONRULES','A',:sessionFlag,:tokenFlag))
		w "02010045 注册成功",!
	} else {
		w "02010045 已存在，跳过",!
	}
	
	// 02010046 - 删除ADRG细分规则
	if '##this().CheckExists("02010046") {
		&sql(INSERT INTO CB_MapInterface (Code,Descripts,ClassName,MethodName,ServiceType,SessionFlag,TokenFlag) VALUES ('02010046','删除ADRG细分规则',:className,'DELETEDRGSEGMENTATIONRULES','D',:sessionFlag,:tokenFlag))
		w "02010046 注册成功",!
	} else {
		w "02010046 已存在，跳过",!
	}
	
	quit "ADRG细分规则接口注册完成"
}

/// 检查接口编号是否已存在
ClassMethod CheckExists(code As %String) As %Boolean
{
	new (code)
	set exists=0
	&sql(SELECT ID INTO :exists FROM CB_MapInterface WHERE Code=:code)
	quit (SQLCODE=0)
}

/// 注册DIP核心算法配置导入接口 (02010056/02010057/02010058)
ClassMethod RegisterDIPCoreAlgorithmImportInterfaces() As %String
{
	set className="SRC.DRG.BASICDATA.INTERFACE"
	set sessionFlag="Y"
	set tokenFlag="N"
	
	// 02010056 - 下载DIP核心算法配置导入模板
	if '##this().CheckExists("02010056") {
		&sql(INSERT INTO CB_MapInterface (Code,Descripts,ClassName,MethodName,ServiceType,SessionFlag,TokenFlag) VALUES ('02010056','下载DIP核心算法配置导入模板',:className,'DOWNLOADDIPCOREALGORITHMTEMPLATE','S',:sessionFlag,:tokenFlag))
		w "02010056 注册成功",!
	} else {
		w "02010056 已存在，跳过",!
	}
	
	// 02010057 - DIP核心算法配置导入预览
	if '##this().CheckExists("02010057") {
		&sql(INSERT INTO CB_MapInterface (Code,Descripts,ClassName,MethodName,ServiceType,SessionFlag,TokenFlag) VALUES ('02010057','DIP核心算法配置导入预览',:className,'PREVIEWIMPORTDIPCOREALGORITHM','S',:sessionFlag,:tokenFlag))
		w "02010057 注册成功",!
	} else {
		w "02010057 已存在，跳过",!
	}
	
	// 02010058 - 确认导入DIP核心算法配置
	if '##this().CheckExists("02010058") {
		&sql(INSERT INTO CB_MapInterface (Code,Descripts,ClassName,MethodName,ServiceType,SessionFlag,TokenFlag) VALUES ('02010058','确认导入DIP核心算法配置',:className,'CONFIRMIMPORTDIPCOREALGORITHM','A',:sessionFlag,:tokenFlag))
		w "02010058 注册成功",!
	} else {
		w "02010058 已存在，跳过",!
	}
	
	quit "DIP核心算法配置导入接口注册完成"
}

}
