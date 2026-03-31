# 原型图分析指南

> 如何根据原型图分析并提取界面配置信息

---

## 分析流程

```
收到原型图
    ↓
Step 1: 识别界面整体结构
    - 界面标题 → 确定组件名称
    - 整体布局 → 确定开发模式
    ↓
Step 2: 提取查询条件
    - 查询字段名称
    - 输入类型
    - 是否必填
    ↓
Step 3: 提取列表信息
    - 列表列标题
    - 数据类型
    - 宽度估算
    - 操作按钮
    ↓
Step 4: 提取弹窗表单
    - 弹窗标题
    - 表单字段
    - 字段类型
    - 验证规则
    ↓
输出配置信息
```

---

## Step 1: 识别界面整体结构

### 1.1 提取界面标题

**位置：** 通常位于页面顶部

**示例：**
- 原型图显示：「医院组维护」
- 组件名称：`HospitalGroupMaintenance`
- 文件名：`HospitalGroupMaintenance.jsx`

**命名规则：**
```
中文标题          → 组件名称
医院组维护         → HospitalGroupMaintenance
用户管理          → UserManagement
订单查询          → OrderQuery
库存盘点          → InventoryCheck
```

### 1.2 判断界面类型

根据布局判断：

| 布局特征 | 界面类型 | 推荐方案 |
|----------|----------|----------|
| 查询条件+列表+分页 | 单列表操作界面 | 动态组件或自定义组件 |
| 主表在上+明细表在下 | 主从表结构 | ParentChildTableOperation |
| 左侧条件+右侧列表 | 查询导出 | LeftConditionRightList |
| 步骤条+表单 | 制单流程 | InventoryManagement |
| 审核按钮+状态列 | 审核流程 | OrderReviewComponent |
| 树形+右侧详情 | 树形维护 | 自定义组件 |

### 1.3 关键判断检查点

在判断界面类型时，**按顺序回答以下问题**：

#### 检查点1：列表区域识别（仅关注列表本身）

| 问题 | 判断依据 |
|------|----------|
| 是否有查询条件区域？ | 输入框、下拉框、日期选择等 |
| 是否有Tab页签切换？ | 状态Tab、分类Tab等 |
| 是否有数据表格？ | 表头+数据行的表格结构 |
| 是否有分页组件？ | 底部分页器 |

**判断结果**：如果以上全部为"是"，列表部分应使用 `SingleTableOperation`。

#### 检查点2：关联交互识别（不影响列表模式）

| 交互类型 | 复杂度 | 处理方式 |
|----------|--------|----------|
| 简单Modal表单 | 低 | 包装组件内置支持 |
| 复杂表单Drawer | 高 | 独立子组件 |
| 多步骤表单 | 高 | 独立子组件 |
| 三栏布局详情 | 高 | 独立子组件 |
| 特殊选择弹窗 | 高 | 独立子组件 |

**重要**：关联交互的复杂度**不影响**列表模式的选择。

#### 检查点3：特殊情况排除

| 特殊情况 | 正确处理 |
|----------|----------|
| 列表是主从表结构 | 使用 ParentChildTableOperation |
| 列表有审核流程 | 使用 OrderReviewComponent |
| 列表无新增功能 | 使用自定义组件或SimpleListTemplate |

---

## Step 2: 提取查询条件

### 2.1 识别查询区域

**典型特征：**
- 位于列表上方
- 包含输入框、下拉框等表单元素
- 通常有「查询」「重置」按钮

### 2.2 提取字段信息

对每个查询条件，提取：

| 信息项 | 示例 | 说明 |
|--------|------|------|
| 字段标签 | 「用户代码」 | 显示在输入框前的文字 |
| 字段类型 | 输入框/下拉框/日期 | 决定typeCode |
| 占位提示 | 「请输入用户代码」 | placeholder |
| 是否必填 | 必填标记 * | required: 'Y'/'N' |

### 2.3 提取示例

**原型图：**
```
[用户代码  ] [用户名称  ] [状态 ▼]
[查询] [重置]                        [+ 新增]
```

**提取结果：**
```javascript
queryFormData = [
    {
        dataIndex: 'userCode',      // 字段名（驼峰命名）
        title: '用户代码',           // 标签文字
        typeCode: 'Input',          // 输入框类型
        required: 'N',              // 非必填
        col: 8                      // 一行3个，各占8
    },
    {
        dataIndex: 'userName',
        title: '用户名称',
        typeCode: 'Input',
        required: 'N',
        col: 8
    },
    {
        dataIndex: 'status',
        title: '状态',
        typeCode: 'Select',
        required: 'N',
        col: 8,
        selectField: 'statusList'     // 下拉数据源
    }
];
```

---

## Step 3: 提取列表信息

### 3.1 识别列表区域

**典型特征：**
- 表格形式展示数据
- 有表头行
- 可能有分页器
- 可能有操作列

### 3.2 提取列信息

对每列提取：

| 信息项 | 示例 | 说明 |
|--------|------|------|
| 列标题 | 「用户代码」 | 表头文字 |
| 数据字段 | userCode | 对应数据字段名 |
| 数据类型 | 文本/数字/日期 | 决定render方式 |
| 宽度 | 估算像素值 | width属性 |
| 对齐 | 左对齐/居中/右对齐 | align属性 |
| 固定 | 固定左/右 | fixed属性 |

### 3.3 提取操作列

识别操作按钮：
- 编辑按钮
- 删除按钮
- 查看按钮
- 其他自定义操作

### 3.4 提取示例

**原型图：**
```
| 用户代码 | 用户名称 | 手机号    | 状态 | 创建时间         | 操作     |
|----------|----------|-----------|------|------------------|----------|
| U001     | 张三     | 138001... | 启用 | 2026-01-01 10:00 | 编辑 删除|
```

**提取结果：**
```javascript
columns = [
    {
        title: '用户代码',
        dataIndex: 'userCode',
        key: 'userCode',
        width: 120,
        ellipsis: true
    },
    {
        title: '用户名称',
        dataIndex: 'userName',
        key: 'userName',
        width: 150,
        ellipsis: true
    },
    {
        title: '手机号',
        dataIndex: 'phone',
        key: 'phone',
        width: 120,
        ellipsis: true
    },
    {
        title: '状态',
        dataIndex: 'status',
        key: 'status',
        width: 80,
        render: (text) => text === '1' ? '启用' : '停用'
    },
    {
        title: '创建时间',
        dataIndex: 'createTime',
        key: 'createTime',
        width: 160,
        render: (text) => text ? moment(text).format('YYYY-MM-DD HH:mm') : ''
    },
    {
        title: '操作',
        dataIndex: 'operation',
        key: 'operation',
        width: 150,
        fixed: 'right', // 根据实际场景添加，如果表格列很多时出现x轴滚动条则使用
        render: (text, record) => (
            <>
                <span onClick={(e) => this.handleEdit(record, e)}>
                    <Icon type="edit" /> 编辑
                </span>
                <Popconfirm
                    title="删除不可恢复，你确定要删除吗?"
                    onConfirm={(e) => this.handleDelete(record, e)}
                >
                    <span><Icon type="delete" /> 删除</span>
                </Popconfirm>
            </>
        )
    }
];
```

---

## Step 4: 提取弹窗表单

### 4.1 识别弹窗

**触发方式：**
- 点击「新增」按钮弹出
- 点击「编辑」按钮弹出
- 其他操作触发

### 4.2 提取弹窗信息

| 信息项 | 示例 | 说明 |
|--------|------|------|
| 弹窗标题 | 新增用户/编辑用户 | 根据操作类型变化 |
| 弹窗宽度 | 估算像素或默认640 | modalWidth |
| 表单字段 | 各输入项 | 与查询条件可能不同 |

### 4.3 提取表单字段

对每个字段提取：

| 信息项 | 示例 | 说明 |
|--------|------|------|
| 字段标签 | 「用户代码」 | 表单label |
| 字段类型 | 输入框/下拉框 | typeCode |
| 是否必填 | 必填标记 * | required: 'Y' |
| 提示信息 | 问号图标旁的说明 | doubt |
| 占列数 | 一行1个/2个 | col: 12/24 |

### 4.4 提取示例

**原型图：**
```
┌─────────────────────────────────┐
│ 新增用户                    [X] │
├─────────────────────────────────┤
│  * 用户代码  [              ]   │
│  * 用户名称  [              ]   │
│   邮箱       [              ]   │
│  * 手机号    [              ]   │
│  * 状态      [启用 ▼]           │
│                                 │
│        [取消]  [保存]           │
└─────────────────────────────────┘
```

**提取结果：**
```javascript
modalFormData = [
    {
        dataIndex: 'userCode',
        title: '用户代码',
        typeCode: 'Input',
        required: 'Y',
        disabled: 'N',
        doubt: '请输入唯一的用户代码',
        col: 24          // 一行一个
    },
    {
        dataIndex: 'userName',
        title: '用户名称',
        typeCode: 'Input',
        required: 'Y',
        disabled: 'N',
        col: 24
    },
    {
        dataIndex: 'email',
        title: '邮箱',
        typeCode: 'Input',
        required: 'N',
        disabled: 'N',
        col: 24
    },
    {
        dataIndex: 'phone',
        title: '手机号',
        typeCode: 'Input',
        required: 'Y',
        disabled: 'N',
        col: 24
    },
    {
        dataIndex: 'status',
        title: '状态',
        typeCode: 'Select',
        required: 'Y',
        disabled: 'N',
        col: 24,
        selectField: 'statusList'
    }
];
```

---

## 输出格式

分析完成后，输出标准化格式：

```yaml
界面分析结果:
  界面名称: "用户维护"
  组件名称: "UserMaintenance"
  文件路径: "src/pages/basicdata/UserManagement.jsx"
  界面类型: "单列表操作界面"
  
  查询条件:
    - 字段名: "userCode"
      标题: "用户代码"
      类型: "Input"
      必填: false
      占位符: "请输入用户代码"
    - 字段名: "userName"
      标题: "用户名称"
      类型: "Input"
      必填: false
    - 字段名: "status"
      标题: "状态"
      类型: "Select"
      必填: false
      选项: ["启用", "停用"]
      
  列表列:
    - 字段名: "userCode"
      标题: "用户代码"
      宽度: 120
      类型: "文本"
    - 字段名: "userName"
      标题: "用户名称"
      宽度: 150
      类型: "文本"
    - 字段名: "phone"
      标题: "手机号"
      宽度: 120
      类型: "文本"
    - 字段名: "status"
      标题: "状态"
      宽度: 80
      类型: "状态(0=停用,1=启用)"
    - 字段名: "createTime"
      标题: "创建时间"
      宽度: 160
      类型: "日期时间"
    - 字段名: "operation"
      标题: "操作"
      宽度: 150
      操作: ["编辑", "删除"]
      
  弹窗表单:
    - 字段名: "userCode"
      标题: "用户代码"
      类型: "Input"
      必填: true
      提示: "请输入唯一的用户代码"
    - 字段名: "userName"
      标题: "用户名称"
      类型: "Input"
      必填: true
    - 字段名: "email"
      标题: "邮箱"
      类型: "Input"
      必填: false
    - 字段名: "phone"
      标题: "手机号"
      类型: "Input"
      必填: true
    - 字段名: "status"
      标题: "状态"
      类型: "Select"
      必填: true
      选项: ["启用", "停用"]
      
  功能列表:
    - 查询: true
    - 重置: true
    - 新增: true
    - 编辑: true
    - 删除: true
    - 分页: true
    - 导出: false
    - 导入: false
```
