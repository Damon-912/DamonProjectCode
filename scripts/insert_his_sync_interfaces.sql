-- 插入HIS数据同步接口配置到 CB_MapInterface 表
-- 接口码：02010078、02010079、02010080、02010081

-- 1. 执行同步任务接口 (02010078)
SET obj=##class(User.CBMapInterface).%New()
SET obj.Code="02010078"
SET obj.Descripts="HIS数据同步-执行同步任务"
SET obj.ClassName="src.DRG.HISData.Interface"
SET obj.MethodName="ExecuteSyncTask"
SET obj.ServiceType="S"
SET obj.SessionFlag="Y"
SET obj.TokenFlag="N"
SET obj.StartDate=$zd($h,5)
SET obj.Status="Y"
SET sc=obj.%Save()
IF $$$ISERR(sc) { WRITE "保存接口02010078失败："_$System.Status.GetErrorText(sc,"cn"),! }
ELSE { WRITE "接口02010078已添加",! }

-- 2. 查询同步配置接口 (02010079)
SET obj=##class(User.CBMapInterface).%New()
SET obj.Code="02010079"
SET obj.Descripts="HIS数据同步-查询同步配置"
SET obj.ClassName="src.DRG.HISData.Interface"
SET obj.MethodName="GetSyncConfig"
SET obj.ServiceType="S"
SET obj.SessionFlag="Y"
SET obj.TokenFlag="N"
SET obj.StartDate=$zd($h,5)
SET obj.Status="Y"
SET sc=obj.%Save()
IF $$$ISERR(sc) { WRITE "保存接口02010079失败："_$System.Status.GetErrorText(sc,"cn"),! }
ELSE { WRITE "接口02010079已添加",! }

-- 3. 保存同步配置接口 (02010080)
SET obj=##class(User.CBMapInterface).%New()
SET obj.Code="02010080"
SET obj.Descripts="HIS数据同步-保存同步配置"
SET obj.ClassName="src.DRG.HISData.Interface"
SET obj.MethodName="SaveSyncConfig"
SET obj.ServiceType="S"
SET obj.SessionFlag="Y"
SET obj.TokenFlag="N"
SET obj.StartDate=$zd($h,5)
SET obj.Status="Y"
SET sc=obj.%Save()
IF $$$ISERR(sc) { WRITE "保存接口02010080失败："_$System.Status.GetErrorText(sc,"cn"),! }
ELSE { WRITE "接口02010080已添加",! }

-- 4. 查询同步状态接口 (02010081)
SET obj=##class(User.CBMapInterface).%New()
SET obj.Code="02010081"
SET obj.Descripts="HIS数据同步-查询同步状态"
SET obj.ClassName="src.DRG.HISData.Interface"
SET obj.MethodName="GetSyncStatus"
SET obj.ServiceType="S"
SET obj.SessionFlag="Y"
SET obj.TokenFlag="N"
SET obj.StartDate=$zd($h,5)
SET obj.Status="Y"
SET sc=obj.%Save()
IF $$$ISERR(sc) { WRITE "保存接口02010081失败："_$System.Status.GetErrorText(sc,"cn"),! }
ELSE { WRITE "接口02010081已添加",! }

-- 查询验证
WRITE "=== 已添加的HIS同步接口 ===",!
SET rset=##class(%SQL.Statement).%New()
DO rset.%Prepare("SELECT Code,Descripts,ClassName,MethodName,ServiceType,Status FROM CB_MapInterface WHERE Code IN ('02010078','02010079','02010080','02010081')")
SET rslt=rs.%Execute()
WHILE rslt.%Next() {
    WRITE rslt.%GetData(1)_" - "_rslt.%GetData(2)_" ["_rslt.%GetData(4)_"]",!
}
