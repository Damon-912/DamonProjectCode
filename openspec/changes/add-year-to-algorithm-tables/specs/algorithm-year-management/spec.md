## ADDED Requirements

### Requirement: 算法配置表支持年份字段

HB_DRGCoreAlgorithmData 和 HB_DIPCoreAlgorithmData 两张表 SHALL 增加 `Year` 字段（`%String(MAXLEN=4)`），存储4位数字年份。Year 字段 SHALL 纳入唯一索引，确保同一年份内相同的业务键（DRG编码+省+市+医疗机构 或 主要诊断+主要手术+省+市+机构等级）不重复。

#### Scenario: DRG表新增Year字段
- **WHEN** 在 HB_DRGCoreAlgorithmData 表中新增或编辑记录
- **THEN** Year 字段为必填，格式为4位数字（如 "2026"）
- **AND** 同一年份内 DRG + ProvinceDr + CityDr + FixmedinsCode 组合唯一

#### Scenario: DIP表新增Year字段
- **WHEN** 在 HB_DIPCoreAlgorithmData 表中新增或编辑记录
- **THEN** Year 字段为必填，格式为4位数字
- **AND** 同一年份内 PrincipalDiagnosis + MajorProcedure + ProvinceDr + CityDr + MedinsLv 组合唯一

#### Scenario: 存量数据兼容
- **WHEN** 查询算法配置表时 Year 字段为 NULL 或空
- **THEN** 该记录不参与年份过滤（兼容模式），视为跨年度通用数据

---

### Requirement: DRG分组查询按年份匹配算法配置

DRG 分组查询接口（02010001，即 GroupDevice.Device() 方法）在查询 HB_DRGCoreAlgorithmData 获取算法参数时，SHALL 按年份维度进行查询：

1. 先查询当前年份的数据
2. 当前年份完全无数据时，自动回退查询上一年份的数据
3. 当前年份有数据但具体 DRG 分组无结果时，返回错误提示"未维护当年 DRG 分组数据"

#### Scenario: 当前年份有完整数据
- **WHEN** 执行 DRG 分组查询，当前年份（如 2026）的 HB_DRGCoreAlgorithmData 中存在对应 DRG 编码的算法配置
- **THEN** 返回当前年份的 Points、PipValue、DGDOV、PayStandard 等参数

#### Scenario: 当前年份无数据回退到上一年
- **WHEN** 执行 DRG 分组查询，当前年份的表中完全无数据（count=0）
- **THEN** 自动回退查询上一年份（如 2025）的算法配置
- **AND** 返回上一年份的算法参数

#### Scenario: 当前年份有数据但具体分组不存在
- **WHEN** 执行 DRG 分组查询，当前年份的表中有数据，但对应 DRG + FixmedinsCode + MdtrtArea 的组合无匹配
- **THEN** 返回错误提示 "未维护当前年份 [年份] 的 DRG 分组数据"

---

### Requirement: DIP分组查询按年份匹配算法配置

DIP 分组查询接口（02010003，即 GroupDevice.GetDIPGroupScore() 方法）在查询 HB_DIPCoreAlgorithmData 时，SHALL 按年份维度进行查询，逻辑与 DRG 分组查询一致：

1. 先查询当前年份的数据
2. 当前年份完全无数据时，自动回退查询上一年份的数据
3. 当前年份有数据但具体分组无结果时，返回提示"未维护当年 DIP 分组数据"

#### Scenario: 当前年份有匹配数据
- **WHEN** 执行 DIP 分组查询，当前年份的 HB_DIPCoreAlgorithmData 中存在匹配的诊断+手术组合
- **THEN** 返回当前年份的 ScoreValue、AdjustCoefficient 等参数

#### Scenario: 当前年份无数据回退
- **WHEN** 执行 DIP 分组查询，当前年份的数据完全为空
- **THEN** 自动查询上一年份数据并返回结果

#### Scenario: 分组不存在提示
- **WHEN** 执行 DIP 分组查询，当前年份有数据但无法匹配
- **THEN** 返回提示 "未维护当前年份 [年份] 的 DIP 分组数据"

---

### Requirement: 前端DRG算法配置页面支持年份筛选与操作

DRG 核心算法配置页面（DRGCoreAlgorithmConfig.tsx）SHALL 增加年份维度的完整支持：

- 查询条件区域增加年份下拉筛选（动态生成近5年选项 + "全部"）
- 表格增加"年份"列
- 新增/编辑弹窗增加年份字段（必填，默认当前年份）
- 导入弹窗增加年份必选下拉

#### Scenario: 年份筛选
- **WHEN** 用户在查询条件中选择某一年份（如 "2026"）并点击查询
- **THEN** 表格只显示该年份的算法配置数据
- **AND** 选择"全部"时不传年份参数，显示所有数据

#### Scenario: 新增时默认年份
- **WHEN** 用户点击"新增配置"打开弹窗
- **THEN** 年份字段默认填充当前年份（如 2026）
- **AND** 年份为必填项，不可为空

#### Scenario: 导入时选择年份
- **WHEN** 用户打开导入弹窗
- **THEN** 弹窗中增加年份选择下拉（必填）
- **AND** 导入的所有数据归属到选定的年份

---

### Requirement: 前端DIP算法配置页面支持年份筛选与操作

DIP 核心算法配置页面（DIPCoreAlgorithmConfig.tsx）SHALL 增加年份维度的完整支持，功能与 DRG 页面一致：

- 查询条件区域增加年份下拉筛选
- 表格增加"年份"列
- 新增/编辑弹窗增加年份字段（必填，默认当前年份）
- 导入弹窗增加年份必选下拉

#### Scenario: DIP页面年份筛选
- **WHEN** 用户在 DIP 算法配置页面选择年份筛选条件
- **THEN** 表格数据按选定年份过滤

#### Scenario: DIP导入时指定年份
- **WHEN** 用户在 DIP 导入弹窗中选择年份
- **THEN** 导入的所有 DIP 配置数据归属到选定年份
