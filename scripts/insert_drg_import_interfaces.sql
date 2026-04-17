-- DRG核心算法配置导入接口配置插入脚本
-- 执行前请确认接口不存在
-- 目标数据库：远程云服务器(111.229.137.113:51773) DRG命名空间

-- 02010050 - DRG核心算法配置导入预览
INSERT INTO CB_MapInterface (Code, Descripts, ClassName, MethodName, ServiceType, SessionFlag, TokenFlag, StartDate) 
VALUES ('02010050', 'DRG核心算法配置导入预览', 'src.DRG.BasicData.InterFace', 'PreviewImportDRGCoreAlgorithm', 'S', 'Y', 'N', CURRENT_DATE);

-- 02010051 - DRG核心算法配置确认导入
INSERT INTO CB_MapInterface (Code, Descripts, ClassName, MethodName, ServiceType, SessionFlag, TokenFlag, StartDate) 
VALUES ('02010051', 'DRG核心算法配置确认导入', 'src.DRG.BasicData.InterFace', 'ConfirmImportDRGCoreAlgorithm', 'A', 'Y', 'N', CURRENT_DATE);

-- 02010052 - 下载DRG核心算法配置导入模板
INSERT INTO CB_MapInterface (Code, Descripts, ClassName, MethodName, ServiceType, SessionFlag, TokenFlag, StartDate) 
VALUES ('02010052', '下载DRG核心算法配置导入模板', 'src.DRG.BasicData.InterFace', 'DownloadDRGCoreAlgorithmTemplate', 'S', 'Y', 'N', CURRENT_DATE);

-- 验证插入结果
SELECT ID, Code, Descripts, ClassName, MethodName, ServiceType FROM CB_MapInterface 
WHERE Code IN ('02010050', '02010051', '02010052') ORDER BY Code;
