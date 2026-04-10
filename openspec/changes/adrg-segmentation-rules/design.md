## Context

DRG分组算法中，病例首先被分入ADRG组，然后根据细分规则进一步细分到DRG组。细分规则的核心参数是联合标志(UnionFlag)和细分标志(SegmentationFlag)，不同省市可能有不同的配置。当前系统缺少独立的细分规则管理功能，需要参考DRG目录信息表(HB_DRGCataLog)的架构模式，新增ADRG细分规则表及完整的CRUD功能。

现有参考实现：
- 表结构: `User.HBDRGCataLog` → SQL表 `HB_DRGCataLog`
- 业务类: `src.DRG.BasicData.DRGCataLog` (查询/保存/删除)
- 接口入口: `src.DRG.BasicData.InterFace` (02010041/02010042/02010043)
- 前端页面: `DRGCataLog.tsx` + `basicData.ts` API定义

## Goals / Non-Goals

**Goals:**
- 新增HB_DRGSegmentationRules表，支持按省市维度管理ADRG细分规则
- 提供完整的增删改查接口和前端操作页面
- 与DRG目录信息表保持一致的架构风格和交互模式

**Non-Goals:**
- 不涉及DRG分组算法逻辑本身
- 不涉及与现有ADRG分组规则维护(02010016/02010017/02010018)的合并
- 不涉及数据迁移或历史数据导入

## Decisions

### 1. 表结构设计

**决策**: HB_DRGSegmentationRules 表采用与HB_DRGCataLog相同的省市外键+Admvs冗余字段模式。字段包括 ADRG(Code)、ADRGDesc(Descripts)、ProvinceDr、CityDr、Admvs、UnionFlag、SegmentationFlag，以及UpdateUserDr/UpdateDate/UpdateTime系统字段。

**理由**: 与DRG目录信息表保持一致的表结构风格，便于维护和理解。Admvs冗余存储避免联表查询，符合医保接口规范要求。

### 2. 唯一性约束

**决策**: 通过联合索引 `DataIndex(ADRG, ProvinceDr, CityDr)` 确保同一省市下ADRG代码不重复。

**理由**: 不同省市可以存在相同的ADRG代码（地方配置差异），唯一性范围是省市+ADRG代码组合，与DRG目录信息表的约束逻辑一致。

### 3. 接口编号分配

**决策**: 分配接口编号 02010044(查询)、02010045(保存)、02010046(删除)。

**理由**: 遵循系统接口编号规范，当前基础数据模块已分配至02010043，新接口紧接分配02010044-02010046。

### 4. 前端交互设计

**决策**: 前端页面参考DRGCataLog.tsx的交互模式，查询条件包含省、市、ADRG代码、ADRG描述，编辑弹窗包含ADRG代码、ADRG描述、省、市、联合标志、细分标志字段。联合标志和细分标志使用下拉选择（1-是/0-否）。

**理由**: 与系统其他基础数据维护页面保持一致的用户体验，UnionFlag和SegmentationFlag为枚举值(0/1)，使用下拉选择避免输入错误。

### 5. 业务类命名

**决策**: 后端业务类命名为 `src.DRG.BasicData.DRGRSegmentationRules`，对应文件 `DRGRSegmentationRules.cls`。

**理由**: 遵循项目命名惯例：DRG模块基础数据类放在 `src.DRG.BasicData` 包下，类名以DRGR开头表示DRG细分规则（Segmentation Rules缩写SR）。

## Risks / Trade-offs

- **[ADRG与ADRG分组规则表关系]** → HB_DRGSegmentationRules的ADRG字段与现有ADRG分组规则表(HB_ADRGRule)存在逻辑关联，但当前不做外键约束，避免耦合过紧
- **[UnionFlag/SegmentationFlag值域]** → 当前设计为0/1枚举，若后续需要更多细分类型需扩展字段长度或改用字典表
- **[物理删除]** → 与DRG目录信息表一致采用物理删除，若需要审计追溯需改造为逻辑删除
