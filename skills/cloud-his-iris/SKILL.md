---
name: cloud-his-iris
description: 此技能应用于开发普瑞HIS系统的InterSystems IRIS/Cache ObjectScript代码时。它提供全面的代码规范和指导，包括表结构定义、类定义、方法编写、Query定义、事务处理和命名规范。在处理ObjectScript类(.cls文件)、表结构或PRHIS系统的业务逻辑时，使用此技能以确保代码质量符合团队标准。
allowed-tools: 
disable: false
---

# IRIS代码规范 Skill

## Skill概述

本Skill为普瑞HIS系统提供InterSystems IRIS/Cache ObjectScript代码开发规范指导，确保代码质量和团队协作效率。

## 适用范围

- InterSystems IRIS/Cache ObjectScript开发
- 普瑞云HIS后端系统
- 表结构定义和业务逻辑开发

## 核心内容

### 1. 表结构定义规范
- 保存位置：User包下
- 表名前缀：CB(系统级字典表)、HB(医院级字典表)、BS(业务表) 
- CB(系统级字典表)和HB(医院级字典表)2个类型的表区分是通过是否存在字段指向CBHospital表
- 必填字段规范
- 外键命名规范（Dr后缀）

### 2. 类定义规范
- 47个业务包结构
- 类关键字规范
- 继承关系规范

### 3. 方法编写规范
- 注释规范
- 参数规范
- 错误处理（try-catch）
- 调试语句规范
- **后置条件语法规范（Quit:/Continue:/Set:/If 比较运算符不能有空格）**
- **New 命令语法规范**
- **禁止使用SQL语句提取数据，只能通过Global提取数据**

### 4. Query定义规范
- ROWSPEC定义
- 参数处理
- Execute/Fetch/Close方法实现

### 5. 事务处理规范
- 标准事务模板
- 嵌套事务处理
- 超时处理

### 6. 命名规范
- 表命名
- 字段命名
- 类命名
- 方法命名
- Query命名
- 变量命名

## 使用方法

### 开发新表时
1. 参考 `assets/table-template.cls` 模板
2. 遵循 `references/table-standards.md` 中的表定义规范
3. 使用 `scripts/check-iris-code.py` 进行代码检查

### 开发业务类时
1. 确定所属业务包（47个包之一）
2. 参考 `assets/method-template.cls` 编写方法
3. 遵循 `references/query-standards.md` 编写Query
4. 确保使用 try-catch 处理异常

### 代码检查
运行Python脚本进行自动化检查：
```bash
python scripts/check-iris-code.py
```

## 规范文档结构

```
SKILL.md                 # 本文件，Skill主文档
references/              # 规范参考文档
  ├── table-standards.md        # 表结构定义规范
  ├── query-standards.md        # Query定义规范
  ├── transaction-standards.md  # 事务处理规范
  ├── method-rule.md            # 方法规范
  └── naming-conventions.md     # 命名规范
assets/                  # 代码模板
  ├── table-template.cls        # 表定义模板
  ├── method-template.cls       # 方法定义模板
  └── query-template.cls        # Query定义模板
scripts/                 # 自动化脚本
  └── check-iris-code.py        # 代码规范检查脚本
```

## 注意事项

1. 所有表类必须保存到User包下
2. 表名必须使用正确的前缀（CB/HB/BS）
3. CB表必须包含所有必填字段
4. 业务类必须使用正确的包名
5. 所有数据操作方法必须使用try-catch
6. 事务必须正确处理（TSTART/TCOMMIT/TROLLBACK）
7. 禁止在代码中硬编码调试语句（w "xxx"）
8. **后置条件语法中比较运算符不能有空格**（如 `Quit:tID=""` 正确，`Quit:tID = ""` 错误）
9. **数据新增和修改应调用公共方法**：
   - 新增：`Set rtn=##class(src.util.operatetable).Insert(.insObj)`
   - 修改：`Set rtn=##class(src.util.operatetable).Update(.insObj)`
10. **禁止使用SQL语句提取数据**，只能通过Global（`$g()`、`$o()`、`$lg()`等）提取数据，不允许使用 `&sql()`、`%SQL.Statement`、`%ResultSet` 等SQL方式查询数据

## 相关资源

- InterSystems IRIS官方文档：https://docs.intersystems.com/irisforhealth20191/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS
- 普瑞HIS系统架构文档
- 团队编码规范v2.0
