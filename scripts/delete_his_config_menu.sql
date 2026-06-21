-- 删除 data-config 菜单项
-- 请先在 IRIS 中执行查询确认：
-- SELECT * FROM CB_Menu WHERE Code='data-config' OR RoutePath LIKE '%data-config%';

-- 删除菜单项
DELETE FROM CB_Menu WHERE Code='data-config';

-- 如果该菜单有子菜单，也一并删除（如果有 parentCode 关联）
-- DELETE FROM CB_Menu WHERE ParentCode='data-config';

-- 提交事务
COMMIT;
