## Context

ADRG细分规则表(HB_DRGSegmentationRules)刚刚创建完成，包含ADRG/ADRGDesc/ProvinceDr/CityDr/Admvs/UnionFlag/SegmentationFlag等字段。现需补充SelectionCriteria(入组规则)字段，用于存储每条细分规则的具体入组判定条件。

参考：现有ADRG分组规则表(HB_ADRGRule)中已包含SelectionCriteria字段，本变更为保持一致性。

## Goals / Non-Goals

**Goals:**
- 在HB_DRGSegmentationRules表中增加SelectionCriteria字段
- 同步更新后端接口的查询返回和保存参数
- 同步更新前端类型定义、表格展示和编辑弹窗

**Non-Goals:**
- 不涉及接口编号变更
- 不涉及菜单配置变更
- 不涉及SelectionCriteria的业务逻辑校验（字段为非必填）

## Decisions

### 1. 字段位置

**决策**: SelectionCriteria字段放置在SegmentationFlag之后、UpdateDate之前，SqlColumnNumber = 9，后续系统字段顺延。

**理由**: 业务字段在前、系统自动字段在后，与现有表结构风格保持一致。

### 2. 字段属性

**决策**: SelectionCriteria为%String类型，非必填(非Required)，不设大写排序(COLLATION为默认)。

**理由**: 入组规则可能包含混合大小写的条件表达式，不应强制大写；字段非必填因为部分细分规则可能不需要额外的入组条件描述。

### 3. 前端展示

**决策**: 表格中"入组规则"列放置在"细分标志"列之后，宽度200px，支持ellipsis溢出省略。编辑弹窗中"入组规则"使用Input输入框，非必填。

**理由**: 入组规则为描述性文本，表格中可能较长，使用ellipsis避免撑开列宽。

## Risks / Trade-offs

- **[已有数据兼容]** → 新增字段为非必填，已有记录该字段为空，不影响现有数据
- **[Storage映射更新]** → 需确保Storage中增加新节点后，已有数据的节点编号正确映射
