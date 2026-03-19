# 表结构定义规范

## 1. 保存位置

系统所有的表结构统一保存到User包下。

**正确示例**：
```objectscript
Class User.CBSample Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_Sample ]
```

**错误示例**：
```objectscript
Class src.CBSample Extends %Persistent
Class User.Sample Extends %Persistent
```

## 2. 表名前缀规范

表名必须使用标准前缀，用于标识表的类型：

| 前缀 | 用途 | 示例 |
|------|------|------|
| CB   | 系统级字典表 | CBOrganization, CBSex |
| HB   | 医院级字典表 | HBDrugDictionary, HBLoc |
| BS   | 业务表 | BSOrderPresc, BSDecoctDispRecord |

## 3. 类定义规范

### 3.1 基本结构

```objectscript
Class User.CBSample Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_Sample ]
{

    /// 逻辑删除标记
    /// 0: 正常
    /// 1: 已删除
    Property Deleted As %Integer [ Required, InitialExpression = 0 ];

    /// 删除日期
    Property DeleteDate As %Date;

    /// 删除时间
    Property DeleteTime As %Time;
}
```

### 3.2 必填关键字

- `ClassType = persistent` - 标识为持久化类
- `SqlTableName = 表名` - 指定SQL表名
- 继承 `src.util.DynamicObject.Adapter`

## 4. CB表必填字段

所有CB前缀的基础表必须包含以下字段：

### 4.1 字段清单

```objectscript
/// 代码（主键，字符串类型）
Property Code As %String(MAXLEN = 100) [ Required ];

/// 描述
Property Descripts As %String(MAXLEN = 255) [ Required ];

/// 英文描述
Property ENDescripts As %String(MAXLEN = 255);

/// 开始日期
Property StartDate As %Date [ InitialExpression = {$zdateh($horolog, 5)} ];

/// 结束日期
Property StopDate As %Date;

/// 创建日期
Property CreateDate As %Date [ InitialExpression = {$zdateh($horolog, 5)} ];

/// 创建用户（外键）
Property CreateUserDr As User.HBUser [ SqlColumnNumber = 9 ];
```

### 4.2 字段说明

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Code | %String | 是 | 主键，建议MAXLEN = 100 |
| Descripts | %String | 是 | 中文描述，建议MAXLEN = 255 |
| ENDescripts | %String | 否 | 英文描述，建议MAXLEN = 255 |
| StartDate | %Date | 是 | 开始日期，默认当前日期 |
| StopDate | %Date | 否 | 结束日期 |
| CreateDate | %Date | 是 | 创建日期，默认当前日期 |
| CreateUserDr | User.HBUser | 是 | 创建用户，外键指向User.User表 |

## 5. 外键命名规范

所有外键字段必须使用`Dr`后缀。

### 5.1 命名格式

```
{关联表}Dr
```

### 5.2 示例

```objectscript
/// 机构外键
Property OrganizationDr as User.CBOrganization;

/// 用户外键
Property CreateUserDr as User.HBUser;

/// 部门外键
Property DepartmentDr as User.CBDpartment;

/// 订单外键
Property OrderDr as User.BSOrder;
```

### 5.3 注意事项

- 外键字段名必须以`Dr`结尾
- 外键类型应该引用对应的表类
- 使用明确的表名前缀（CB/HB/BS）
- 日期事件字段必须拆开两个字段，Date和Time

## 6. 字段类型选择

### 6.1 常用类型

| ObjectScript类型 | SQL类型 | 用途 |
|------------------|---------|------|
| %String | VARCHAR | 字符串 |
| %Integer | INTEGER | 整数 |
| %Numeric | NUMERIC | 数字 |
| %Date | DATE | 日期 |
| %Time | TIMESTAMP | 时间 |
| %Boolean | BIT | 布尔值 |

### 6.2 类型选择建议

- 主键：使用`%String`类型
- 外键：引用表类类型
- 金额：使用`%Numeric`类型
- 计数：使用`%Integer`类型
- 日期：使用`%Date`类型
- 时间：使用`%Time`类型

## 7. 索引定义

### 7.1 主键索引

```objectscript
Index CodeIndex On Code As Exact [ PrimaryKey ];
```

### 7.2 外键索引

```objectscript
Index OrganizationDrIndex On OrganizationDr As Exact;
```

### 7.3 业务索引

```objectscript
Index StartDateIndex On StartDate As Exact;
Index DeletedIndex On Deleted As Exact;
```

## 8. 完整示例

```objectscript
Class User.CBOrganization Extends src.util.DynamicObject.Adapter
{
    ClassType = persistent;
    SqlTableName = CBOrganization;

    /// 代码（主键）
    Property Code As %String(MAXLEN = 50) [ Required ];

    /// 描述
    Property Descripts As %String(MAXLEN = 255) [ Required ];

    /// 英文描述
    Property ENDescripts As %String(MAXLEN = 255);

    /// 开始日期
    Property StartDate As %Date [ InitialExpression = {$zdateh($horolog, 5)} ];

    /// 结束日期
    Property StopDate As %Date;

    /// 创建日期
    Property CreateDate As %Date [ InitialExpression = {$zdateh($horolog, 5)} ];

    /// 创建用户
    Property CreateUserDr As User.HBUser [ SqlColumnNumber = 9 ];

    /// 删除标记
    Property Deleted As %Integer [ Required, InitialExpression = 0 ];

    /// 删除日期
    Property DeleteDate As %Date;

    /// 删除时间
    Property DeleteTime As %Time;

    /// 上级机构外键
    Property ParentDr As CBOrganization;

    Index CodeIndex On Code [ PrimaryKey ] As Exact;
    Index CreateUserDrIndex On CreateUserDr As Exact;
    Index DeletedIndex On Deleted As Exact;
}
```

## 9. 常见错误

❌ **错误1**：表未保存到User包
```objectscript
Class src.CBOrganization Extends src.util.DynamicObject.Adapter
```
✅ **正确**：
```objectscript
Class User.CBOrganization Extends src.util.DynamicObject.Adapter
```

❌ **错误2**：缺少必填字段
```objectscript
Class User.CBSample Extends src.util.DynamicObject.Adapter
{
    Property Code As %String [ Required ];
    Property Descripts As %String [ Required ];
}
```
✅ **正确**：包含所有CB必填字段

❌ **错误3**：外键未使用Dr后缀
```objectscript
Property Organization As User.CBOrganization;
```
✅ **正确**：
```objectscript
Property OrganizationDr As User.CBOrganization;
```

❌ **错误4**：日期事件字段未拆分
```objectscript
Property CreateTime As %TimeStamp;
```
✅ **正确**：
```objectscript
Property CreateDate As %Date;
Property CreateTime As %Time;
```

