# 方法编码规范

## 1. Global获取方式

### 1.1 基本原则

- **禁止使用SQL语句提取数据，只能通过Global提取数据**。不允许使用 `&sql()`、`%SQL.Statement`、`%ResultSet` 等SQL方式查询数据
- 尽量公用 `$g()` 产生的对象，获取 global 数据时使用 `$lg()`，不使用 `$p()`
- 尽量使用 `$g()` 获取 global 数据，产生的对象用作 `$lg()` 的数据源
- 避免多次访问同一个 global 节点，应先获取到变量再处理

### 1.2 正确示例

```objectscript
// 正确：先获取整个节点数据，再用 $lg() 提取
Set tData = $g(^BSPathwayD(tID))
Set tName = $lg(tData, 3)
Set tCode = $lg(tData, 2)
Set tIsValid = $lg(tData, 5)
```

### 1.3 错误示例

```objectscript
// 错误：使用SQL语句查询数据
&sql(SELECT Name, Code INTO :tName, :tCode FROM User.BSPathway WHERE ID = :tID)

// 错误：使用 %SQL.Statement 查询数据
Set tSQL = "SELECT * FROM User.BSPathway"
Set tStatement = ##class(%SQL.Statement).%New()
Set tStatus = tStatement.%Prepare(tSQL)
Set tResultSet = tStatement.%Execute()

// 错误：使用 %ResultSet 查询数据
Set tRS = ##class(%ResultSet).%New("User.BSPathway:List")
Do tRS.Execute()

// 错误：使用 $p() 解析
Set tName = $p(^BSPathwayD(tID), "^", 3)

// 错误：多次访问同一个 global
Set tName = $lg($g(^BSPathwayD(tID)), 3)
Set tCode = $lg($g(^BSPathwayD(tID)), 2)
```

---

## 2. 查询列表规范

### 2.1 ID倒序查询

所有查询列表的代码，必须按ID倒序查询，使用 `$o()` 函数的第二个参数 `-1`：

```objectscript
// 倒序查询语法
Set tID = ""
for{
    Set tID = $o(^CBOrderDimensionD(tID), -1)
    quit:tID=""
    // 处理数据
    Set tData = $g(^CBOrderDimensionD(tID))
}
```

### 2.2 正序查询（不推荐）

```objectscript
// 正序查询语法（一般不使用）
Set tID = $o(^CBOrderDimensionD(tID))
```

### 2.3 查询模板

```objectscript
/// 查询列表方法模板
ClassMethod GetList(pInput As %DynamicObject) As %DynamicObject [ PublicList = 1 ]
{
    Set tResult = {"errorCode":"0","errorMessage":"成功","result":{"total":0,"data":[]}}
    
    Try {
        // 获取分页参数
        Set tPageSize = pInput.pagination.%Get(0).pageSize
        Set tCurrentPage = pInput.pagination.%Get(0).currentPage
        
        // 计算分页范围
        Set tStart = (tCurrentPage - 1) * tPageSize + 1
        Set tEnd = tCurrentPage * tPageSize
        Set tIndex = 0
        
        // 倒序遍历
        Set tID = ""
        
        for {
            Set tID = $o(^YourTableD(tID), -1)
            quit:tID = ""
            Set tIndex = tIndex + 1
            
            // 分页处理
            If (tIndex >= tStart) && (tIndex <= tEnd) {
                Set tData = $g(^YourTableD(tID))
                // 构建返回数据
                Do tResult.result.data.%Push(tItem)
            }
            
            If (tIndex >= tEnd) Quit
        }
        
        Set tResult.result.total = tIndex
    } Catch {
        Set tResult.errorCode = "-1"
        Set tResult.errorMessage = $ze
    }
    
    Quit tResult
}
```

---

## 3. 用户信息返回规范

### 3.1 基本要求

所有查询功能返回的结果中，如果存在用户信息（创建用户/更新用户），必须返回对应的用户名称。

### 3.2 用户名称获取

用户数据存储在 `^HBUserD` global 中，用户名称在第3个位置：

```objectscript
// 获取创建用户名称
Set tCreateUserName = ""
If (tCreateUserDr '= "") {
    Set tUserData = $g(^HBUserD(tCreateUserDr))
    Set tCreateUserName = $lg(tUserData, 3)
}

// 获取更新用户名称
Set tUpdateUserName = ""
If (tUpdateUserDr '= "") {
    Set tUserData = $g(^HBUserD(tUpdateUserDr))
    Set tUpdateUserName = $lg(tUserData, 3)
}
```

### 3.3 字段命名规范

| 原字段 | 新增字段 | 说明 |
|--------|----------|------|
| createUserID / createUserDr | createUserName | 创建用户名称 |
| updateUserID / updateUserDr | updateUserName | 更新用户名称 |

### 3.4 完整示例

```objectscript
// 从global获取数据
Set tData = $g(^BSOrderWhiteConfigD(tID))
Set tCreateUserDr = $lg(tData, 10)
Set tUpdateUserDr = $lg(tData, 13)

// 获取用户名称
Set tCreateUserName = ""
If (tCreateUserDr '= "") {
    Set tUserData = $g(^HBUserD(tCreateUserDr))
    Set tCreateUserName = $lg(tUserData, 3)
}

Set tUpdateUserName = ""
If (tUpdateUserDr '= "") {
    Set tUserData = $g(^HBUserD(tUpdateUserDr))
    Set tUpdateUserName = $lg(tUserData, 3)
}

// 构建返回对象
Set tItem = {}
Set tItem.ID = tID
Set tItem.createUserDr = tCreateUserDr
Set tItem.createUserName = tCreateUserName
Set tItem.updateUserDr = tUpdateUserDr
Set tItem.updateUserName = tUpdateUserName
```

---

## 4. 统一接口API契约规范

### 4.1 接口代码规则

#### 4.1.1 代码格式

接口代码为 8位数字

格式：MMIINNNN
    MM：模块前缀（2位），如 09
    II：模块内编号（2位），如 01
    NNNN：接口序号（4位），从 0001 开始递增

### 4.1 入参规范

#### 4.1.1 入参格式

入参为 JSON 格式，不是 global，标准格式如下：

```json
{
  "code": "",
  "params": [{}],
  "pagination": [{"pageSize": 20, "currentPage": 1}],
  "session": [{}]
}
```

#### 4.1.2 参数说明

| 参数名 | 类型 | 说明 |
|--------|------|------|
| params | Array | 业务参数数组，包含查询条件 |
| pagination | Array | 分页参数数组 |
| pagination.pageSize | Integer | 每页记录数，默认20 |
| pagination.currentPage | Integer | 当前页码，默认1 |
| code | String | 业务编码 |
| session | Array | 会话信息，包含当前用户等 |

#### 4.1.3 参数获取示例

```objectscript
// 获取业务参数
Set tParams = pInput.params.%Get(0)
Set tCode = tParams.code
Set tDescripts = tParams.descripts
Set tIsValid = tParams.isValid

// 获取分页参数
Set tPagination = pInput.pagination.%Get(0)
Set tPageSize = tPagination.pageSize
Set tCurrentPage = tPagination.currentPage

// 获取会话信息
Set tSession = pInput.session.%Get(0)
Set tUserID = tSession.userID
```

---

### 4.2 出参规范

#### 4.2.1 列表返回格式

```json
{
  "errorCode": "0",
  "errorMessage": "成功",
  "result": {
    "total": 100,
    "data": []
  }
}
```

#### 4.2.2 详情返回格式

```json
{
  "errorCode": "0",
  "errorMessage": "成功",
  "result": {}
}
```

---

## 5. 后置条件语法规范

### 5.1 基本原则

在 ObjectScript 中，使用后置条件（post-conditional）语法时，**条件表达式中的比较运算符周围不能有空格**。

后置条件语法适用于：`Quit:`, `Continue:`, `Set:`, `If` 等命令。

### 5.2 正确示例

```objectscript
// For 循环中的 Quit 和 Continue
For {
    Set tID = $o(^HBLocD(tID), -1)
    Quit:tID=""
    
    Set tData = $g(^HBLocD(tID))
    Continue:tData=""
    
    // 检查是否删除
    Set tDeleted = $lg(tData, 20)
    Continue:tDeleted=1
    
    // If 条件中的比较
    Set tHospDr = $lg(tData, 5)
    If tHospID'="",tHospDr'=tHospID Continue
    
    // 日期有效性检查
    Set tStartDate = $lg(tData, 16)
    Set tStopDate = $lg(tData, 17)
    If tStartDate'="",tStartDate>$Horolog Continue
    If tStopDate'="",tStopDate<$Horolog Continue
}

// Set 后置条件
Set:tColor'="" tObj.Color = tColor
Set:tLevelDesc'="" tObj.LevelDesc = tLevelDesc
Set:tSeqNo'="" tObj.SeqNo = tSeqNo
```

### 5.3 错误示例

```objectscript
// 错误：比较运算符周围有空格
Quit:tID = ""
Continue:tData = ""
Continue:tDeleted = 1
If tHospID '= "", tHospDr '= tHospID Continue
If tStartDate '= "", tStartDate > $Horolog Continue
Set:tColor '= "" tObj.Color = tColor
Set:tSeqNo '= "" tObj.SeqNo = tSeqNo
```

### 5.4 常见语法模式对照表

| 命令 | 错误语法 | 正确语法 |
|------|----------|----------|
| `Quit:` | `Quit:tID = ""` | `Quit:tID=""` |
| `Continue:` | `Continue:tData = ""` | `Continue:tData=""` |
| `Continue:` | `Continue:tDeleted = 1` | `Continue:tDeleted=1` |
| `If` | `If var '= ""` | `If var'=""` |
| `If` | `If var1 '= "", var2 '= value` | `If var1'="",var2'=value` |
| `Set:` | `Set:var '= ""` | `Set:var'=""` |

### 5.5 注意事项

1. **编译错误**：后置条件中有空格会导致编译失败
2. **一致性**：所有比较运算符（`=`, `'=`, `>`, `<`, `>=`, `<=`）都必须遵循此规范
3. **多个条件**：多个条件之间用逗号分隔，逗号后不加空格

---

## 6. New 命令语法规范

### 6.1 基本原则

`New` 命令用于创建局部变量的新环境，支持带括号和不带括号两种语法。

### 6.2 语法说明

```objectscript
// 创建新环境，不保留任何变量
New

// 创建新环境，保留指定变量（带括号）
New (pInput)

// 创建新环境，保留多个变量
New (pInput, pOtherVar)

// 创建新环境，只保留特定变量（不带括号）
New pInput
```

### 6.3 使用示例

```objectscript
ClassMethod Example(pInput As %DynamicObject) As %DynamicObject
{
    // 保留 pInput 变量，创建新的局部变量环境
    New (pInput)
    
    // 现在可以安全地修改局部变量，不影响外部
    Set tTemp = "local value"
    
    Quit tResult
}
```

### 6.4 注意事项

1. 带括号的 `New (var)` 表示保留该变量
2. 不带括号的 `New var` 也表示保留该变量
3. 不带参数的 `New` 表示不保留任何变量，创建全新的局部环境

---

## 7. 数据新增和修改规范

### 7.1 公共方法调用

数据的新增和修改操作应调用公共方法，而不是直接操作对象。

### 7.2 入参结构说明

```objectscript
// 1. 构建数据对象
Set dataObj = {}
Set dataArr = []

// 2. 设置字段值
Set dataObj.LocDr = $case(saveType, "C":"", :locID)
Set dataObj.Code = tCode
Set dataObj.Descripts = tName
Set dataObj.IsValid = "Y"
Set dataObj.Notes = tNotes
Set dataObj.SeqNo = tSeqNo

// 3. 根据新增/修改设置不同字段
If tID = "" {
    // 新增：不设置ID，设置创建信息
    Set dataObj.CreateDate = +$h
    Set dataObj.CreateTime = $p($h, ",", 2)
    Set dataObj.CreateUserDr = tUserID
} Else {
    // 修改：设置ID标识要修改的记录
    Set dataObj.ID = tID
}

// 4. 将数据对象加入数组
Do dataArr.%Push(dataObj)

// 5. 构建入参对象
Set insObj = {}
Set insObj.data = dataArr
Set insObj.updateUserID = tUserID
Set insObj.className = "User.HBWardDisplayConfig"

// 6. 调用公共方法
If tID = "" {
    Set rtn = ##class(src.util.operatetable).Insert(.insObj)
} Else {
    Set rtn = ##class(src.util.operatetable).Update(.insObj)
}
```

### 7.3 完整示例

```objectscript
ClassMethod SaveConfig(pInput As %Library.DynamicObject) As %Library.DynamicObject
{
    New (pInput)
    Set tResult = {"errorCode":"0","errorMessage":"成功","result":{}}
    
    Try {
        // 获取参数
        Set tParams = pInput.params.%Get(0)
        Set tSession = pInput.session.%Get(0)
        Set tUserID = tSession.userID
        
        Set tID = tParams.id
        Set tCode = tParams.code
        Set tName = tParams.name
        Set tNotes = tParams.notes
        Set tSeqNo = tParams.seqNo
        
        // 构建数据对象
        Set dataObj = {}
        Set dataArr = []
        
        Set dataObj.Code = tCode
        Set dataObj.Descripts = tName
        Set dataObj.IsValid = "Y"
        Set dataObj.Notes = tNotes
        Set dataObj.SeqNo = tSeqNo
        
        If tID = "" {
            // 新增
            Set dataObj.CreateDate = +$h
            Set dataObj.CreateTime = $p($h, ",", 2)
            Set dataObj.CreateUserDr = tUserID
        } Else {
            // 修改
            Set dataObj.ID = tID
        }
        
        Do dataArr.%Push(dataObj)
        
        Set insObj = {}
        Set insObj.data = dataArr
        Set insObj.updateUserID = tUserID
        Set insObj.className = "User.HBWardDisplayConfig"
        
        // 调用公共方法
        If tID = "" {
            Set rtn = ##class(src.util.operatetable).Insert(.insObj)
        } Else {
            Set rtn = ##class(src.util.operatetable).Update(.insObj)
        }
        
        // 解析返回值：errorCode^errorMessage!rowID
        Set tErrorCode = $p($p(rtn, "!", 1), "^", 1)
        Set tErrorMsg = $p($p(rtn, "!", 1), "^", 2)
        Set tRowID = $p($p(rtn, "!", 2), "^", 1)
        
        // 检查结果
        If tErrorCode '= "0" {
            Set tResult.errorCode = tErrorCode
            Set tResult.errorMessage = tErrorMsg
            Quit
        }
        
        Set tResult.result.id = tRowID
        
    } Catch e {
        Set tStatus = e.AsStatus()
        Set tResult.errorCode = "-1"
        Set tResult.errorMessage = $Replace(##class(%SYSTEM.Status).GetErrorText(tStatus,"cn"),"^"," ")
    }
    
    Quit tResult
}
```

### 7.4 参数说明

| 参数层级 | 参数名 | 类型 | 说明 |
|----------|--------|------|------|
| insObj | data | Array | 数据数组 |
| insObj | updateUserID | String | 当前操作用户ID |
| insObj | className | String | 表对应的类名，格式为 `包名.表类名` |
| data[] | dataObj | Object | 数据对象 |
| dataObj | ID | String | 记录ID（修改时必填） |
| dataObj | 其他字段 | Various | 表字段值 |
| dataObj | CreateDate | Date | 创建日期（新增时设置，值为 `+$h`） |
| dataObj | CreateTime | Time | 创建时间（新增时设置，值为 `$p($h,",",2)`） |
| dataObj | CreateUserDr | String | 创建用户（新增时设置） |

### 7.5 返回值说明

返回值为字符串格式：`errorCode^errorMessage!rowID`

```objectscript
// 成功返回
"0^成功!123"

// 失败返回
"-1^操作失败!"
```

### 7.6 返回值解析

```objectscript
// 调用公共方法
Set rtn = ##class(src.util.operatetable).Insert(.insObj)

// 解析返回值：errorCode^errorMessage!rowID
Set tErrorCode = $p($p(rtn, "!", 1), "^", 1)
Set tErrorMsg = $p($p(rtn, "!", 1), "^", 2)
Set tRowID = $p($p(rtn, "!", 2), "^", 1)

// 检查结果
If tErrorCode '= "0" {
    Set tResult.errorCode = tErrorCode
    Set tResult.errorMessage = tErrorMsg
    Quit
}

Set tResult.result.id = tRowID
```

### 7.7 注意事项

1. **入参结构**：必须使用 `insObj.data = dataArr` 结构，dataArr 是数组
2. **必填字段**：insObj 必须设置 `updateUserID`（当前操作用户）和 `className`（表类名）
3. **新增判断**：通过 `tID = ""` 判断是新增还是修改
4. **新增时**：不设置 ID 字段，设置 CreateDate、CreateTime、CreateUserDr
5. **修改时**：必须设置 ID 字段标识要修改的记录
6. **日期格式**：CreateDate 使用 `+$h`，CreateTime 使用 `$p($h,",",2)`
7. **类名格式**：className 格式为 `包名.表类名`，如 `User.HBWardDisplayConfig`





