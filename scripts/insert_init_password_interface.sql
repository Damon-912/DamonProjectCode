-- 01040091 - 初始化登录密码接口（无需原密码验证）
-- 先检查是否已存在
-- SELECT ID, Code, Descripts, ClassName, MethodName FROM CB_MapInterface WHERE Code = '01040091';

INSERT INTO CB_MapInterface (Code, Descripts, ClassName, MethodName, ServiceType, SessionFlag, TokenFlag, StartDate) 
VALUES ('01040091', '初始化登录密码', 'src.Encryption.HBUser', 'InitUserPassword', 'A', 'Y', 'N', CURRENT_DATE);

-- 验证插入结果
SELECT ID, Code, Descripts, ClassName, MethodName, ServiceType FROM CB_MapInterface WHERE Code = '01040091';
