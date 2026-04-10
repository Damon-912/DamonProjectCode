# 统一弹框风格与组件标签

## Why

当前项目前端代码中，弹框（Modal）和表单组件的样式风格不统一，各页面自行定义弹框尺寸、按钮布局、标题格式等。同时，部分组件的 label 使用英文或不一致的中文表述，影响用户体验和系统一致性。

通过统一这些 UI 规范，可以提升系统的整体专业度和用户体验，降低后续维护成本。

## What Changes

- **新增弹框风格规范**：制定统一的 Modal 弹框标准，包括尺寸规格、按钮布局（底部居右）、标题样式、关闭按钮等
- **统一 Form.Item 标签规范**：确保所有表单字段的 label 使用中文，统一命名规则
- **创建可复用弹框组件**：基于 Ant Design Modal 封装统一的业务弹框组件
- **统一按钮文字规范**：确定确定/取消等按钮的标准中文文案

## Capabilities

### New Capabilities

- `modal-style-guide`: 弹框样式规范文档，定义 Modal 的尺寸、布局、动画等标准
- `form-label-standard`: 表单标签命名规范，统一各业务模块的中文 label 标准
- `common-modal-components`: 通用弹框组件库，提供 ConfirmModal、FormModal、DrawerModal 等标准化组件

### Modified Capabilities

- 无

## Impact

- **前端代码**：影响 `frontend/src/pages/` 下所有使用 Modal 的页面
- **受影响模块**：
  - BasicData（基础数据管理）
  - DRG（DRG分组查询）
  - DIP（DIP疾病管理）
  - System（系统管理）
  - HIS（数据同步）
  - Warning（预警中心）
  - Profit（效益分析）
