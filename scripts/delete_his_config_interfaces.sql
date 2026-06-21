-- 删除 02010063 和 02010064 接口配置
-- 请先在 IRIS 中执行查询确认：
-- SELECT * FROM CB_InterfaceService WHERE Code IN ('02010063', '02010064');

-- 删除接口配置记录
DELETE FROM CB_InterfaceService WHERE Code='02010063';
DELETE FROM CB_InterfaceService WHERE Code='02010064';

-- 提交事务
COMMIT;
