-- ============================================================
-- DRG特异化分组方案 - 接口注册 + 数据初始化 SQL
-- 生成日期: 2026-05-26
-- ============================================================

-- ============================================================
-- 1. 注册接口到 CB_MapInterface
-- ============================================================

-- 02010064 - 查询特异化分组方案
INSERT INTO CB_MapInterface (Code, Descripts, ClassName, MethodName, ServiceType, SessionFlag, TokenFlag)
VALUES ('02010064', '查询DRG特异化分组方案', 'src.DRG.BasicData.InterFace', 'GETDRGSPECIALGROUPLIST', 'S', 'Y', 'N');

-- 02010065 - 保存特异化分组方案
INSERT INTO CB_MapInterface (Code, Descripts, ClassName, MethodName, ServiceType, SessionFlag, TokenFlag)
VALUES ('02010065', '保存DRG特异化分组方案', 'src.DRG.BasicData.InterFace', 'SAVEDRGSPECIALGROUP', 'A', 'Y', 'N');

-- 02010066 - 删除特异化分组方案
INSERT INTO CB_MapInterface (Code, Descripts, ClassName, MethodName, ServiceType, SessionFlag, TokenFlag)
VALUES ('02010066', '删除DRG特异化分组方案', 'src.DRG.BasicData.InterFace', 'DELETEDRGSPECIALGROUP', 'D', 'Y', 'N');


-- ============================================================
-- 2. 合肥市2026年特异化分组数据 (HB_DRGSpecialGroup)
-- 行政区划: Admvs=340100  Province_Dr=34  City_Dr=3401
-- ============================================================

-- ==================== CB66: 青光眼阀置入术 ====================
-- 主要诊断: h40.501 新生血管性青光眼
-- 主要手术: 12.6704 青光眼阀置入术
INSERT INTO HB_DRGSpecialGroup (
    DRGCode, DRGName,
    PrincipalDiagnosis, PrincipalDiagnosisName,
    SecondaryDiagnosis, SecondaryDiagnosisName,
    MajorProcedure, MajorProcedureName,
    SecondaryProcedure, SecondaryProcedureName,
    GroupFactors, Remark,
    Admvs, Province_Dr, City_Dr, Year,
    StartDate, StopDate
) VALUES (
    'CB66', '青光眼阀置入术',
    'h40.501', '新生血管性青光眼',
    '', '',
    '12.6704', '青光眼阀置入术',
    '', '',
    '主要诊断+主要手术', '',
    '340100', '34', '3401', '2026',
    '2026-01-01', NULL
);

-- ==================== CB26: 后入路玻璃体切割术、白内障超声乳化抽吸术 ====================
-- 备注: 1.根据国家DRG2.0分组方案：CB2分组涵盖CB4/CB5；
--      2.主要诊断四选一（例如：玻璃体浑浊不能作为主要诊断）；
--      3.主要手术二选一，另一个作为次要手术。

-- 行1: 主要诊断 H33.502 + 主要手术 14.7401
INSERT INTO HB_DRGSpecialGroup (
    DRGCode, DRGName,
    PrincipalDiagnosis, PrincipalDiagnosisName,
    SecondaryDiagnosis, SecondaryDiagnosisName,
    MajorProcedure, MajorProcedureName,
    SecondaryProcedure, SecondaryProcedureName,
    GroupFactors, Remark,
    Admvs, Province_Dr, City_Dr, Year,
    StartDate, StopDate
) VALUES (
    'CB26', '后入路玻璃体切割术、白内障超声乳化抽吸术',
    'H33.502', '陈旧性视网膜脱离',
    '', '',
    '14.7401', '后入路玻璃体切割术',
    '', '',
    '主要诊断+主要手术',
    '1.根据国家DRG2.0分组方案：CB2分组涵盖CB4/CB5；2.主要诊断四选一；3.主要手术二选一，另一个作为次要手术。',
    '340100', '34', '3401', '2026',
    '2026-01-01', NULL
);

-- 行2: 主要诊断 H35.303 + 主要手术 13.4100x001
INSERT INTO HB_DRGSpecialGroup (
    DRGCode, DRGName,
    PrincipalDiagnosis, PrincipalDiagnosisName,
    SecondaryDiagnosis, SecondaryDiagnosisName,
    MajorProcedure, MajorProcedureName,
    SecondaryProcedure, SecondaryProcedureName,
    GroupFactors, Remark,
    Admvs, Province_Dr, City_Dr, Year,
    StartDate, StopDate
) VALUES (
    'CB26', '后入路玻璃体切割术、白内障超声乳化抽吸术',
    'H35.303', '黄斑裂孔',
    '', '',
    '13.4100x001', '白内障超声乳化抽吸术',
    '', '',
    '主要诊断+主要手术',
    '1.根据国家DRG2.0分组方案：CB2分组涵盖CB4/CB5；2.主要诊断四选一；3.主要手术二选一，另一个作为次要手术。',
    '340100', '34', '3401', '2026',
    '2026-01-01', NULL
);

-- 行3: 主要诊断 H43.100（无主要手术）
INSERT INTO HB_DRGSpecialGroup (
    DRGCode, DRGName,
    PrincipalDiagnosis, PrincipalDiagnosisName,
    SecondaryDiagnosis, SecondaryDiagnosisName,
    MajorProcedure, MajorProcedureName,
    SecondaryProcedure, SecondaryProcedureName,
    GroupFactors, Remark,
    Admvs, Province_Dr, City_Dr, Year,
    StartDate, StopDate
) VALUES (
    'CB26', '后入路玻璃体切割术、白内障超声乳化抽吸术',
    'H43.100', '玻璃体积血',
    '', '',
    '', '',
    '', '',
    '主要诊断',
    '1.根据国家DRG2.0分组方案：CB2分组涵盖CB4/CB5；2.主要诊断四选一；3.主要手术二选一，另一个作为次要手术。',
    '340100', '34', '3401', '2026',
    '2026-01-01', NULL
);

-- 行4: 主要诊断 H25.100（无主要手术）
INSERT INTO HB_DRGSpecialGroup (
    DRGCode, DRGName,
    PrincipalDiagnosis, PrincipalDiagnosisName,
    SecondaryDiagnosis, SecondaryDiagnosisName,
    MajorProcedure, MajorProcedureName,
    SecondaryProcedure, SecondaryProcedureName,
    GroupFactors, Remark,
    Admvs, Province_Dr, City_Dr, Year,
    StartDate, StopDate
) VALUES (
    'CB26', '后入路玻璃体切割术、白内障超声乳化抽吸术',
    'H25.100', '老年核性白内障',
    '', '',
    '', '',
    '', '',
    '主要诊断',
    '1.根据国家DRG2.0分组方案：CB2分组涵盖CB4/CB5；2.主要诊断四选一；3.主要手术二选一，另一个作为次要手术。',
    '340100', '34', '3401', '2026',
    '2026-01-01', NULL
);

-- ==================== CB46: 玻璃体切割、硅油取出术、巩膜环扎术 ====================
-- 主要手术9选1（合并为一行，编码逗号分隔）
INSERT INTO HB_DRGSpecialGroup (
    DRGCode, DRGName,
    PrincipalDiagnosis, PrincipalDiagnosisName,
    SecondaryDiagnosis, SecondaryDiagnosisName,
    MajorProcedure, MajorProcedureName,
    SecondaryProcedure, SecondaryProcedureName,
    GroupFactors, Remark,
    Admvs, Province_Dr, City_Dr, Year,
    StartDate, StopDate
) VALUES (
    'CB46', '玻璃体切割、硅油取出术、巩膜环扎术',
    '', '',
    '', '',
    '14.4100,14.4900x001,14.4901,14.4902,14.4903,14.7100x001,14.7300x001,14.7401,14.6x02',
    '巩膜环扎术伴有植入物,巩膜环扎术,巩膜环扎术伴空气填塞,巩膜环扎术伴巩膜切除术,巩膜环扎术伴玻璃体切除术,前入路玻璃体切除术,前入路玻璃体切割术,后入路玻璃体切割术,玻璃体硅油取出术',
    '', '',
    '主要手术', '主要手术9选1',
    '340100', '34', '3401', '2026',
    '2026-01-01', NULL
);

-- ==================== CB56: 飞秒激光白内障超声乳化抽吸术 ====================
-- 主要诊断3选1（合并为一行），主要手术唯一
INSERT INTO HB_DRGSpecialGroup (
    DRGCode, DRGName,
    PrincipalDiagnosis, PrincipalDiagnosisName,
    SecondaryDiagnosis, SecondaryDiagnosisName,
    MajorProcedure, MajorProcedureName,
    SecondaryProcedure, SecondaryProcedureName,
    GroupFactors, Remark,
    Admvs, Province_Dr, City_Dr, Year,
    StartDate, StopDate
) VALUES (
    'CB56', '飞秒激光白内障超声乳化抽吸术',
    'h25.900,e88.906+h28.1*,h26.200',
    '老年性白内障,代谢性白内障,并发性白内障',
    '', '',
    '13.4101', '飞秒激光白内障超声乳化抽吸术',
    '', '',
    '主要诊断+主要手术', '主要诊断3选1，主要手术唯一',
    '340100', '34', '3401', '2026',
    '2026-01-01', NULL
);

-- ==================== CB54: 老年性白内障的白内障超声乳化抽吸术伴晶状体囊袋张力环植入术 ====================
-- 主要诊断唯一 + 主要手术唯一 + 次要手术唯一
INSERT INTO HB_DRGSpecialGroup (
    DRGCode, DRGName,
    PrincipalDiagnosis, PrincipalDiagnosisName,
    SecondaryDiagnosis, SecondaryDiagnosisName,
    MajorProcedure, MajorProcedureName,
    SecondaryProcedure, SecondaryProcedureName,
    GroupFactors, Remark,
    Admvs, Province_Dr, City_Dr, Year,
    StartDate, StopDate
) VALUES (
    'CB54', '老年性白内障的白内障超声乳化抽吸术伴晶状体囊袋张力环植入术',
    'H25.900', '老年性白内障',
    '', '',
    '13.4100x001', '白内障超声乳化抽吸术',
    '13.9003', '晶状体囊袋张力环植入术',
    '主要诊断+主要手术+次要手术', '主要诊断、主要手术和次要手术均唯一',
    '340100', '34', '3401', '2026',
    '2026-01-01', NULL
);

-- ==================== CB58: 置入人工晶状体伴白内障超声乳化抽吸术 ====================
-- 主要手术唯一 + 次要手术唯一
INSERT INTO HB_DRGSpecialGroup (
    DRGCode, DRGName,
    PrincipalDiagnosis, PrincipalDiagnosisName,
    SecondaryDiagnosis, SecondaryDiagnosisName,
    MajorProcedure, MajorProcedureName,
    SecondaryProcedure, SecondaryProcedureName,
    GroupFactors, Remark,
    Admvs, Province_Dr, City_Dr, Year,
    StartDate, StopDate
) VALUES (
    'CB58', '置入人工晶状体伴白内障超声乳化抽吸术',
    '', '',
    '', '',
    '13.7000', '置入人工晶状体',
    '13.4100x001', '白内障超声乳化抽吸术',
    '主要手术+次要手术', '主要手术和次要手术均唯一',
    '340100', '34', '3401', '2026',
    '2026-01-01', NULL
);
