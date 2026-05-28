-- ============================================================
-- DRG字典管理 - 硬编码字典数据初始化脚本 (IRIS版本)
-- 适用于 InterSystems IRIS/Cache 数据库
-- 使用 INSERT INTO ... SELECT 子查询动态关联 Parent_Dr
-- 执行方法：在 IRIS SQL Shell 中执行，或通过 ##class() 调用
-- ============================================================

-- ============================================================
-- 1. 预警管理模块字典
-- ============================================================

-- 1.1 预警级别（先插入类型，再插入字典项）
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'WARNING_LEVEL', '预警级别', 'Y', 1, 'DRG预警管理-预警级别');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '低', 'Y', 1, '低级别预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_LEVEL';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '2', '中', 'Y', 2, '中级别预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_LEVEL';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '3', '高', 'Y', 3, '高级别预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_LEVEL';

-- 1.2 预警状态
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'WARNING_STATUS', '预警状态', 'Y', 2, 'DRG预警管理-预警状态');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '01', '待处理', 'Y', 1, '待处理的预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '02', '已确认', 'Y', 2, '已确认的预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '03', '已忽略', 'Y', 3, '已忽略的预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '04', '已申诉', 'Y', 4, '已申诉的预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '05', '已解决', 'Y', 5, '已解决的预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_STATUS';

-- 1.3 预警类型
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'WARNING_TYPE', '预警类型', 'Y', 3, 'DRG预警管理-预警类型');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '01', '费用超支', 'Y', 1, '费用超支预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '02', '低倍率', 'Y', 2, '低倍率预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '03', '高倍率', 'Y', 3, '高倍率预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '04', '编码异常', 'Y', 4, '编码异常预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '05', '分解住院', 'Y', 5, '分解住院预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '06', '费用过低', 'Y', 6, '费用过低预警'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'WARNING_TYPE';


-- ============================================================
-- 2. 系统管理模块字典
-- =============== =============================================

-- 2.1 性别
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'SEX', '性别', 'Y', 10, '系统管理-性别');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '男', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SEX';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '2', '女', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SEX';

-- 2.2 证件类型
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'CRED_TYPE', '证件类型', 'Y', 11, '系统管理-证件类型');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '身份证', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'CRED_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '2', '护照', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'CRED_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '3', '军官证', 'Y', 3, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'CRED_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '4', '其他', 'Y', 4, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'CRED_TYPE';

-- 2.3 安全级别
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'SAFE_CLASS', '安全级别', 'Y', 12, '系统管理-角色安全级别');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '普通', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SAFE_CLASS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '2', '重要', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SAFE_CLASS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '3', '核心', 'Y', 3, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SAFE_CLASS';

-- 2.4 菜单类型
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'MENU_TYPE', '菜单类型', 'Y', 13, '系统管理-菜单类型');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '目录', 'Y', 1, '菜单目录'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'MENU_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '2', '菜单', 'Y', 2, '菜单项'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'MENU_TYPE';

-- 2.5 医院等级
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'HOSPITAL_LEVEL', '医院等级', 'Y', 14, '系统管理-医院等级');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '一级', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_LEVEL';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '2', '二级', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_LEVEL';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '3', '三级', 'Y', 3, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_LEVEL';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '4', '省级', 'Y', 4, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_LEVEL';

-- 2.6 医院类型
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'HOSPITAL_TYPE', '医院类型', 'Y', 15, '系统管理-医院类型');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '综合医院', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '2', '中医医院', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '3', '专科医院', 'Y', 3, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '4', '社区卫生服务中心', 'Y', 4, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '5', '卫生院', 'Y', 5, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_TYPE';

-- 2.7 医院性质
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'HOSPITAL_NATURE', '医院性质', 'Y', 16, '系统管理-医院性质');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '公立医院', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_NATURE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '2', '民营医院', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_NATURE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '3', '合资医院', 'Y', 3, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'HOSPITAL_NATURE';

-- 2.8 接口操作类型
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'INTERFACE_OP_TYPE', '接口操作类型', 'Y', 17, '系统管理-接口操作类型');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'S', '查询', 'Y', 1, 'Select查询操作'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'INTERFACE_OP_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'A', '新增', 'Y', 2, 'Add新增操作'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'INTERFACE_OP_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'U', '修改', 'Y', 3, 'Update修改操作'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'INTERFACE_OP_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'D', '删除', 'Y', 4, 'Delete删除操作'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'INTERFACE_OP_TYPE';


-- ============================================================
-- 3. 基础数据模块字典
-- ============================================================

-- 3.1 是否标志
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'YES_NO_FLAG', '是否标志', 'Y', 20, '通用-是否标志');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '0', '否', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'YES_NO_FLAG';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '是', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'YES_NO_FLAG';

-- 3.2 险种类型
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'INSU_TYPE', '险种类型', 'Y', 21, 'DRG核心算法-险种类型');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '310', '职工', 'Y', 1, '职工医保'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'INSU_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '390', '居民', 'Y', 2, '居民医保'
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'INSU_TYPE';

-- 3.3 医疗机构等级
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'MEDINS_LEVEL', '医疗机构等级', 'Y', 22, 'DIP核心算法-医疗机构等级');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '一级', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'MEDINS_LEVEL';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '2', '二级', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'MEDINS_LEVEL';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '3', '三级', 'Y', 3, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'MEDINS_LEVEL';


-- ============================================================
-- 4. HIS数据模块字典
-- ============================================================

-- 4.1 结算状态
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'SETTLEMENT_STATUS', '结算状态', 'Y', 30, 'HIS结算-结算状态');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'pending', '待提交', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SETTLEMENT_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'submitted', '已提交', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SETTLEMENT_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'settled', '已结算', 'Y', 3, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SETTLEMENT_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'cancelled', '已取消', 'Y', 4, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SETTLEMENT_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'rejected', '已驳回', 'Y', 5, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SETTLEMENT_STATUS';

-- 4.2 同步状态
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'SYNC_STATUS', '同步状态', 'Y', 31, 'HIS数据同步-同步状态');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'running', '运行中', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SYNC_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'success', '成功', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SYNC_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'failed', '失败', 'Y', 3, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SYNC_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'pending', '等待中', 'Y', 4, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SYNC_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'stopped', '已停止', 'Y', 5, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SYNC_STATUS';

-- 4.3 同步类型
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'SYNC_TYPE', '同步类型', 'Y', 32, 'HIS数据同步-同步类型');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'incremental', '增量同步', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SYNC_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'full', '全量同步', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SYNC_TYPE';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'realtime', '实时同步', 'Y', 3, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'SYNC_TYPE';

-- 4.4 分组状态
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'GROUPING_STATUS', '分组状态', 'Y', 33, 'DRG分组-分组状态');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '0', '未分组', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'GROUPING_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '已分组', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'GROUPING_STATUS';


-- ============================================================
-- 5. 通用状态字典
-- ============================================================

-- 5.1 通用状态
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'COMMON_STATUS', '通用状态', 'Y', 99, '通用-启用/停用状态');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'Y', '启用', 'Y', 1, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'COMMON_STATUS';

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'N', '停用', 'Y', 2, ''
FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'COMMON_STATUS';


-- ============================================================
-- 6. 补充发现的新字典类型（第二轮扫描）
-- ============================================================

-- 6.1 离院方式
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'DISCHARGE_TYPE', '离院方式', 'Y', 40, '病案-离院方式');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '1', '医嘱离院', 'Y', 1, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'DISCHARGE_TYPE';
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '2', '医嘱转院', 'Y', 2, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'DISCHARGE_TYPE';
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '3', '医嘱转社区卫生服务机构', 'Y', 3, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'DISCHARGE_TYPE';
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '4', '非医嘱离院', 'Y', 4, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'DISCHARGE_TYPE';
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '5', '死亡', 'Y', 5, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'DISCHARGE_TYPE';
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '9', '其他', 'Y', 6, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'DISCHARGE_TYPE';

-- 6.2 阈值类型
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'THRESHOLD_TYPE', '阈值类型', 'Y', 41, '预警规则-阈值类型');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '01', '百分比', 'Y', 1, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'THRESHOLD_TYPE';
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, '02', '固定值', 'Y', 2, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'THRESHOLD_TYPE';

-- 6.3 风险等级
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'RISK_LEVEL', '风险等级', 'Y', 42, 'DRG分组-风险等级');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'high', '高', 'Y', 1, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'RISK_LEVEL';
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'medium', '中', 'Y', 2, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'RISK_LEVEL';
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'low', '低', 'Y', 3, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'RISK_LEVEL';

-- 6.4 偏差等级
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark) 
VALUES (NULL, 'DEVIATION_LEVEL', '偏差等级', 'Y', 43, 'DIP偏差分析-偏差等级');

INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'high', '高偏差', 'Y', 1, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'DEVIATION_LEVEL';
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'medium', '中偏差', 'Y', 2, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'DEVIATION_LEVEL';
INSERT INTO CB_DRGDictTable (Parent_Dr, Code, Name, Status, SortNo, Remark)
SELECT ID, 'low', '低偏差', 'Y', 3, '' FROM CB_DRGDictTable WHERE Parent_Dr IS NULL AND Code = 'DEVIATION_LEVEL';

-- ============================================================
-- 脚本执行完毕
-- 共 22 个字典类型，90+ 个字典项
-- ============================================================
