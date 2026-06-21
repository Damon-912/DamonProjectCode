-- 插入HIS数据同步接口配置到 CB_MapInterface 表
-- 接口码：02010078、02010079、02010080、02010081

-- 1. 执行同步任务接口 (02010078)
INSERT INTO CB_MapInterface (Code, Descripts, ClassName, MethodName, ServiceType, SessionFlag, TokenFlag, StartDate, Status)
VALUES ('02010078', 'HIS数据同步-执行同步任务', 'src.DRG.HISData.Interface', 'ExecuteSyncTask', 'S', 'Y', 'N', GETDATE(), 'Y');

-- 2. 查询同步配置接口 (02010079)
INSERT INTO CB_MapInterface (Code, Descripts, ClassName, MethodName, ServiceType, SessionFlag, TokenFlag, StartDate, Status)
VALUES ('02010079', 'HIS数据同步-查询同步配置', 'src.DRG.HISData.Interface', 'GetSyncConfig', 'S', 'Y', 'N', GETDATE(), 'Y');

-- 3. 保存同步配置接口 (02010080)
INSERT INTO CB_MapInterface (Code, Descripts, ClassName, MethodName, ServiceType, SessionFlag, TokenFlag, StartDate, Status)
VALUES ('02010080', 'HIS数据同步-保存同步配置', 'src.DRG.HISData.Interface', 'SaveSyncConfig', 'S', 'Y', 'N', GETDATE(), 'Y');

-- 4. 查询同步状态接口 (02010081)
INSERT INTO CB_MapInterface (Code, Descripts, ClassName, MethodName, ServiceType, SessionFlag, TokenFlag, StartDate, Status)
VALUES ('02010081', 'HIS数据同步-查询同步状态', 'src.DRG.HISData.Interface', 'GetSyncStatus', 'S', 'Y', 'N', GETDATE(), 'Y');


-- 查询验证
SELECT Code, Descripts, ClassName, MethodName, ServiceType, Status
FROM CB_MapInterface
WHERE Code IN ('02010078', '02010079', '02010080', '02010081');
