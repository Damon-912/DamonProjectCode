Import SQLUSER

/// HIS服务配置管理类
/// 提供HIS服务配置的保存和读取功能
/// 
/// 接口Code规范：无（供DRGHisInvoke调用）
/// 
Class src.DRG.HISData.ConfigService Extends (%RegisteredObject, %XML.Adaptor) [ Not ProcedureBlock ]
{

/// 保存HIS服务配置
/// 注意：此接口已将配置参数硬编码在代码中，不再从前端接收参数
/// 硬编码配置：hospCode="H03", fixmedinsCode="H34010400768", fixmedinsName="合肥普瑞眼科医院", 
///           hisIP="172.16.2.160", hisPort="9001", hisURL="bdhealth/sysInternalMutiple", authorization="Basic cHJoaXA6cHJoaXBAMjAyMA=="
/// 返回：%DynamicObject，包含errorCode、errorMessage
ClassMethod SaveHisServiceConfig(jsonObj) As %Library.DynamicObject
{
	//new (resultObj,hospCode,fixmedinsCode,fixmedinsName,hisIP,hisPort,hisURL,authorization,obj,saveSC,rs,sql,stmt,sc,configID)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try
	{
	set params=jsonObj.params.%Get(0)
	set session=jsonObj.session.%Get(0)
	set hospCode=params.hospCode
	
	set fixmedinsCode=session.hospYBCode
	set fixmedinsName=session.hospDesc
	set hisIP=params.hisIP
	set hisPort=params.hisPort
	set hisURL=params.hisURL
	set authorization=params.authorization
	set userID=session.userID
	
	// 打开用户对象
	set userObj=""
	if userID'="" {
		set userObj=##class(User.HBUser).%OpenId(userID)
	}
		        
        // 2. 保存到CB_HISConnectionConfig表
        // 先查找是否已存在该医院的配置
        set configID=""
        set sql="SELECT ID FROM CB_HISConnectionConfig WHERE HospCode = ? AND Active = 'Y'"
        set stmt=##class(%SQL.Statement).%New()
        set sc=stmt.%Prepare(sql)
        if $$$ISERR(sc) {
	        set resultObj.errorCode="-1"
	        set resultObj.errorMessage="SQL准备失败："_$System.Status.GetErrorText(sc,"cn")
	        quit
        }
        set rs=stmt.%Execute(hospCode)
        if rs.%Next() {
	        set configID=rs.%Get("ID")
        }
        do rs.%Close()
        
        if configID="" {
            // 不存在，创建新配置
            set obj=##class(User.CBHISConnectionConfig).%New()
            set obj.HospCode=hospCode
            set obj.FixmedinsCode=fixmedinsCode
            set obj.FixmedinsName=fixmedinsName
            set obj.HisIP=hisIP
            set obj.HisPort=hisPort
            set obj.HisURL=hisURL
            set obj.Authorization=authorization
            set obj.Active="Y"
            set obj.CreateDate=$p($h,",",1)  // 日期部分，IRIS内部格式
            set obj.CreateTime=$p($h,",",2)  // 时间部分，IRIS内部格式
            // 设置创建用户对象（如果成功打开）
            if $IsObject(userObj) {
                set obj.CreateUserDr=userObj
            }
            set saveSC=obj.%Save()
        } else {
            // 已存在，更新配置
            set obj=##class(User.CBHISConnectionConfig).%OpenId(configID)
            if $IsObject(obj) {
                set obj.FixmedinsCode=fixmedinsCode
                set obj.FixmedinsName=fixmedinsName
                set obj.HisIP=hisIP
                set obj.HisPort=hisPort
                set obj.HisURL=hisURL
                set obj.Authorization=authorization
                set obj.UpdateDate=$p($h,",",1)  // 日期部分，IRIS内部格式
                set obj.UpdateTime=$p($h,",",2)  // 时间部分，IRIS内部格式
                // 设置更新用户对象（如果成功打开）
                if $IsObject(userObj) {
                    set obj.UpdateUserDr=userObj
                }
                set saveSC=obj.%Save()
            }
        }
        
        if $$$ISERR(saveSC) {
	        set resultObj.errorCode="-1"
	        set resultObj.errorMessage="保存失败："_$System.Status.GetErrorText(saveSC,"cn")
	        quit
        }
        
        set resultObj.result={"hospCode":(hospCode),"fixmedinsCode":(fixmedinsCode),"fixmedinsName":(fixmedinsName),"hisIP":(hisIP),"hisPort":(hisPort),"hisURL":(hisURL),"authorization":(authorization)}
        set resultObj.errorMessage="配置已保存（硬编码值）"
    } catch tException {
        set resultObj.errorCode="-1"
        set resultObj.errorMessage=$System.Status.GetErrorText(tException.AsStatus(),"cn")
    }
    quit resultObj
}

/// 获取HIS服务配置
/// pJsonObj: {"hospCode":""}
/// 返回：%DynamicObject，包含errorCode、errorMessage、result对象
ClassMethod GetHisServiceConfig(pJsonObj) As %Library.DynamicObject
{
	//new (resultObj,hospCode,sql,stmt,sc,rs,found)
	set resultObj={"errorCode":"0","errorMessage":"","result":{}}
	try
	{
        // 1. 获取参数
        set params=pJsonObj.params.%Get(0)
        if '$IsObject(params) {
	        set resultObj.errorCode="05100127"
	        set resultObj.errorMessage="参数不能为空"
	        quit
        }
        
        set hospCode=$get(params.hospCode,"")
        if hospCode="" {
	        set resultObj.errorCode="05100128"
	        set resultObj.errorMessage="HIS医院Code不能为空"
	        quit
        }
        
        // 2. 从CB_HISConnectionConfig表读取配置
        set found=0
        set sql="SELECT * FROM CB_HISConnectionConfig WHERE HospCode = ? AND Active = 'Y'"
        set stmt=##class(%SQL.Statement).%New()
        set sc=stmt.%Prepare(sql)
        if $$$ISERR(sc) {
	        set resultObj.errorCode="-1"
	        set resultObj.errorMessage="SQL准备失败："_$System.Status.GetErrorText(sc,"cn")
	        quit
        }
        set rs=stmt.%Execute(hospCode)
        if rs.%Next() {
	        set found=1
            set resultObj.result.hospCode=rs.%Get("HospCode")
            set resultObj.result.fixmedinsCode=rs.%Get("FixmedinsCode")
            set resultObj.result.fixmedinsName=rs.%Get("FixmedinsName")
            set resultObj.result.hisIP=rs.%Get("HisIP")
            set resultObj.result.hisPort=rs.%Get("HisPort")
            set resultObj.result.hisURL=rs.%Get("HisURL")
            set resultObj.result.authorization=rs.%Get("Authorization")
	    }
        do rs.%Close()
        
        // 3. 如果数据库中未找到配置，返回硬编码的默认值（兼容旧逻辑）
        if 'found {
            if (hospCode="H03") {
                set resultObj.result.hospCode="H03"
                set resultObj.result.fixmedinsCode="H34010400768"
                set resultObj.result.fixmedinsName="合肥普瑞眼科医院"  
                set resultObj.result.hisIP="172.16.2.160"
                set resultObj.result.hisPort="9001"
                set resultObj.result.hisURL="bdhealth/sysInternalMutiple"
                set resultObj.result.authorization="Basic cHJoaXA6cHJoaXBAMjAyMA=="
                set resultObj.errorMessage="使用默认配置（数据库中未找到配置）"
            } else {
	            set resultObj.errorCode="05100130"
	            set resultObj.errorMessage="未找到医院Code的配置："_hospCode
	            quit
            }
        }
        
    } 
    catch tException 
    {
        set resultObj.errorCode="-1"
        set resultObj.errorMessage=$System.Status.GetErrorText(tException.AsStatus(),"cn")
    }
    quit resultObj
}

}
