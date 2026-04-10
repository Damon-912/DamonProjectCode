## Context

当前项目前端约25个页面存在中英文显示不一致问题：
- **DatePicker/RangePicker**：仅`BasicDataMaintenance.tsx`使用`ConfigProvider locale={zhCN}`，其余页面日期选择器均显示英文
- **Pagination locale**：每个页面单独定义`locale: { items_per_page: '/页', jump_to: '跳至', page: '页' }`，重复25处
- **纯英文标签**：`Interfaces.tsx`列标题"Session"/"Token"，`Results.tsx`列标题"DRG"，`CustomQuery.tsx`中Text"MDC"
- **中英混合标签**：医疗术语缩写（DRG/DIP/ADRG/MDC/ICD/HIS/ECMO/HIV/CMI/IRIS）在中文标签中保留，符合行业惯例

当前`main.tsx`仅用`StrictMode`包裹`<App />`，无全局locale配置。

## Goals / Non-Goals

**Goals:**
- 全局配置中文locale，所有Ant Design组件统一中文显示
- 消除25处重复的pagination locale定义
- 替换纯英文标签为中文
- 保持医疗术语缩写在中文标签中的合理使用

**Non-Goals:**
- 不做完整的国际化(i18n)架构改造
- 不改变医疗术语缩写的使用方式（DRG/DIP/ICD等保留英文）
- 不修改placeholder中合理的英文值（如ICD-10、ICD-9-CM-3作为编码标准名称保留）
- 不修改代码中的变量名、注释、console.log中的英文

## Decisions

### 1. 在main.tsx中添加全局ConfigProvider

**选择**：在`main.tsx`入口添加`<ConfigProvider locale={zhCN}>`包裹`<App />`

**替代方案**：
- A) 在App.tsx中包裹 — 可行但main.tsx是更标准的全局配置位置
- B) 每个页面单独配置 — 当前BasicDataMaintenance的做法，冗余且容易遗漏

**理由**：main.tsx是应用入口，ConfigProvider作为全局配置放在最顶层，确保所有子组件自动继承中文locale，无需每个页面单独处理。

### 2. 删除所有页面中重复的pagination locale

**选择**：逐页删除`pagination`属性中的`locale`对象

**理由**：全局ConfigProvider已提供中文pagination locale，每个页面的`locale: { items_per_page: '/页', ... }`变为冗余代码，删除可减少维护负担。

### 3. 纯英文标签中文化策略

**选择**：仅替换纯英文（无中文修饰）的标签：
- `title: 'Session'` → `title: '会话验证'`
- `title: 'Token'` → `title: '令牌验证'`
- `title: 'DRG'` → `title: 'DRG编码'`
- `<Text>MDC</Text>` → `<Text>MDC编码</Text>`

**保留不变**：已有中文修饰的标签如"DRG编码"、"ICD代码"、"HIV感染标志"等，无需修改。

**理由**：纯英文标签对非技术用户不友好。但医疗术语缩写（DRG/ICD/HIS等）是行业通用表达，在中英文混合标签中保留更专业。

## Risks / Trade-offs

- **[全局ConfigProvider可能影响未预期的组件]** → Ant Design的ConfigProvider按设计是向下传递的，影响范围可控；且所有Ant Design组件本就应支持中文
- **[删除pagination locale后若全局locale失效]** → 全局ConfigProvider是Ant Design官方推荐的locale方案，可靠性有保障；如需回退，仅需在main.tsx移除ConfigProvider
- **[医疗术语缩写保留可能引起争议]** → DRG/DIP/ICD等是国家医保规范中的标准术语，保留是合理的行业惯例
