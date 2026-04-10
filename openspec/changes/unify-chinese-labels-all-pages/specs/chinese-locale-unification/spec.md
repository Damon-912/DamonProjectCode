## ADDED Requirements

### Requirement: 全局中文Locale配置
系统 SHALL 在应用入口（main.tsx）使用Ant Design的ConfigProvider组件包裹根组件，并设置`locale={zhCN}`，使所有Ant Design组件（包括DatePicker、RangePicker、TimePicker、Pagination、Empty等）默认显示中文。

#### Scenario: DatePicker显示中文
- **WHEN** 用户打开任意包含DatePicker或RangePicker组件的页面
- **THEN** 日期选择器界面 SHALL 显示中文（如"一月"而非"Jan"，"确定"而非"OK"）

#### Scenario: Pagination显示中文
- **WHEN** 用户打开任意包含Table分页的页面
- **THEN** 分页组件 SHALL 自动显示中文（如"条/页"而非"items/page"），无需页面单独配置locale

### Requirement: 移除重复Pagination Locale定义
系统 SHALL 删除所有页面中pagination属性内重复定义的locale对象（`locale: { items_per_page: '/页', jump_to: '跳至', page: '页' }`），统一由全局ConfigProvider提供。

#### Scenario: 页面pagination不再需要locale属性
- **WHEN** 开发者在任意页面使用Table组件的pagination属性
- **THEN** pagination属性中 SHALL 不再包含locale字段，分页文本由全局ConfigProvider自动提供

### Requirement: 移除局部ConfigProvider包裹
系统 SHALL 移除BasicDataMaintenance.tsx中局部使用的`<ConfigProvider locale={zhCN}>`包裹及其对应的`import zhCN from 'antd/locale/zh_CN'`和`import { ConfigProvider }`，改为由全局ConfigProvider统一生效。

#### Scenario: BasicDataMaintenance不再需要局部locale
- **WHEN** 用户打开DRG基础数据维护页面
- **THEN** DatePicker和Pagination SHALL 仍然显示中文，由全局ConfigProvider提供，无需页面单独包裹

### Requirement: 纯英文标签替换为中文
系统 SHALL 将以下纯英文（无中文修饰）的界面标签替换为中文：
- Interfaces.tsx表格列`title: 'Session'` → `title: '会话验证'`
- Interfaces.tsx表格列`title: 'Token'` → `title: '令牌验证'`
- Results.tsx表格列`title: 'DRG'` → `title: 'DRG编码'`
- CustomQuery.tsx中`<Text>MDC</Text>` → `<Text>MDC编码</Text>`

#### Scenario: Interfaces页面列标题显示中文
- **WHEN** 用户打开接口服务配置页面
- **THEN** 表格列标题 SHALL 显示"会话验证"和"令牌验证"而非"Session"和"Token"

#### Scenario: Results页面列标题显示中文
- **WHEN** 用户打开分组结果查询页面
- **THEN** 表格列标题 SHALL 显示"DRG编码"而非"DRG"

#### Scenario: CustomQuery页面MDC标签显示中文
- **WHEN** 用户在自定义查询页面查看分组结果
- **THEN** MDC标签 SHALL 显示"MDC编码"而非纯"MDC"
