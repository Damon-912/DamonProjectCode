## Why

项目前端约25个页面存在大量不一致的中英文混用问题：DatePicker/RangePicker组件未配置中文locale（仅BasicDataMaintenance.tsx使用了ConfigProvider+zhCN），导致日期选择器显示英文界面；分页组件locale在每个页面重复定义；部分表格列标题和表单label使用纯英文（如"Session"、"Token"、"DRG"）；Card/Descriptions标题含英文缩写（如"DRG信息"、"DIP分组详情"）。需统一风格，全站采用中文显示，提升用户体验一致性。

## What Changes

- **在`main.tsx`全局添加`ConfigProvider locale={zhCN}`**，统一DatePicker/RangePicker/TimePicker/Pagination等组件的中文locale，消除每个页面重复定义pagination locale的冗余代码
- **移除`BasicDataMaintenance.tsx`中局部`ConfigProvider+zhCN`包裹**，改为全局生效
- **删除所有25个页面中重复的pagination locale定义**（`locale: { items_per_page: '/页', jump_to: '跳至', page: '页' }`），统一由全局ConfigProvider提供
- **替换纯英文label/title为中文**：
  - `"Session"` → `"会话验证"`（Interfaces.tsx 列标题）
  - `"Token"` → `"令牌验证"`（Interfaces.tsx 列标题）
  - `"DRG"` → `"DRG编码"`（Results.tsx 列标题）
  - `"MDC"` → `"MDC编码"`（CustomQuery.tsx Text标签）
- **保留医疗领域专业术语缩写**：DRG、DIP、ADRG、MDC、ICD、HIS、ECMO、HIV、CMI、IRIS等作为专有名词在中英文混合标签中保留（如"DRG编码"、"ICD代码"、"HIV感染标志"），这是医疗信息系统的行业惯例

## Capabilities

### New Capabilities
- `chinese-locale-unification`: 全站中文locale统一配置，包括全局ConfigProvider、删除重复pagination locale、统一DatePicker中文显示、纯英文label替换为中文

### Modified Capabilities

## Impact

- **前端核心入口**：`main.tsx` 新增ConfigProvider包裹
- **约25个页面文件**：删除重复pagination locale定义，替换纯英文标签
- **BasicDataMaintenance.tsx**：移除局部ConfigProvider包裹
- **无后端变更**：纯前端UI文本调整
- **无破坏性变更**：仅影响显示文本和locale配置，不影响功能和API
