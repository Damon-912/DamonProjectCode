-- 编译HIS数据模块相关的类
-- 在IRIS终端中执行此脚本，或使用Do $System.OBJ.Compile命令

-- 方法1：在IRIS终端中执行
-- Do $System.OBJ.Compile("src.DRG.HISData.HisDataService","ck")
-- Do $System.OBJ.Compile("src.DRG.HISData.Interface","ck")

-- 方法2：使用SQL脚本（需要适当权限）
-- 此脚本用于记录需要编译的类

SELECT '需要编译以下类：
1. src.DRG.HISData.HisDataService.cls - 添加了查询方法
   - QuerySyncedPatients (02010075)
   - QueryPatientDetail (02010076)
   - QuerySyncLogs (02010077)
2. src.DRG.HISData.Interface.cls - 添加了接口方法
   - GetSyncedPatients (02010075)
   - GetPatientDetail (02010076)
   - GetSyncLogs (02010077)

编译命令（在IRIS终端执行）：
Do $System.OBJ.Compile("src.DRG.HISData.HisDataService,src.DRG.HISData.Interface","ck")

或分别编译：
Do $System.OBJ.Compile("src.DRG.HISData.HisDataService","ck")
Do $System.OBJ.Compile("src.DRG.HISData.Interface","ck")
' AS Note;
