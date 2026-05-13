# Query定义规范

## 1. Query基本结构

Query使用ClassMethod定义，用于返回数据集。所有Query必须遵循Execute/Fetch/Close方法模式。

## 2. Query声明

### 2.1 基本格式

```objectscript
Query QueryName(Parameters) As %Query(ROWSPEC = "ColumnName1:DataType1,ColumnName2:DataType2")
{
}
```

### 2.2 ROWSPEC定义

ROWSPEC定义返回结果的列名和数据类型，使用逗号分隔：

```objectscript
Query GetUserInfo(UserId As %String) As %Query(ROWSPEC = "UserName:%String,UserAge:%Integer,CreateTime:%TimeStamp")
```

### 2.3 常用数据类型

| 数据类型 | 说明 | 示例 |
|---------|------|------|
| %String | 字符串 | UserName:%String |
| %Integer | 整数 | UserAge:%Integer |
| %Numeric | 数字 | Amount:%Numeric |
| %Date | 日期 | BirthDate:%Date |
| %TimeStamp | 日期时间 | CreateTime:%TimeStamp |

## 3. Query方法实现

### 3.1 方法清单

每个Query必须实现三个方法：

1. **Execute方法** - 初始化Query，准备数据
2. **Fetch方法** - 获取下一行数据
3. **Close方法** - 关闭Query，释放资源

### 3.2 Execute方法

```objectscript
/// 执行Query
/// p...: Query参数
/// qHandle: Query句柄
ClassMethod QueryNameExecute(ByRef qHandle As %Binary, p...) As %Status
{
    // 初始化返回数据结构
    Set tSC = $$$OK
    Set qHandle = $$$NULLOREF

    // 准备数据
    Set tData = ##class(%ArrayOfDataTypes).%New()

    // 执行业务逻辑，填充数据
    // ...

    Set qHandle = tData
    Quit tSC
}
```

### 3.3 Fetch方法

```objectscript
/// 获取下一行数据
/// qHandle: Query句柄
/// Row: 返回的数据行
/// AtEnd: 是否到达末尾
/// p...: Query参数
ClassMethod QueryNameFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer, p...) As %Status
{
    Set tSC = $$$OK
    Set AtEnd = 1  // 默认已结束

    Try {
        If $IsObject(qHandle) {
            // 获取数据
            // ...

            // 构建返回行
            Set Row = $ListBuild(Value1, Value2, Value3)
            Set AtEnd = 0  // 还有数据
        }
    } Catch {
        Set tSC = $System.Status.Error(5001, "Fetch数据失败: " _ $ze)
    }

    Quit tSC
}
```

### 3.4 Close方法

```objectscript
/// 关闭Query
/// qHandle: Query句柄
ClassMethod QueryNameClose(ByRef qHandle As %Binary, p...) As %Status
{
    // 释放资源
    If $IsObject(qHandle) {
        Kill qHandle
    }

    Quit $$$OK
}
```

## 4. 参数处理

### 4.1 参数传递

Query声明中的参数会传递给Execute、Fetch、Close三个方法：

```objectscript
Query GetOrderInfo(OrderDr As %String, StartDate As %Date) As %Query(ROWSPEC = "OrderNo:%String,Amount:%Numeric")
{
}

// 所有方法都接收OrderDr和StartDate参数
ClassMethod GetOrderInfoExecute(ByRef qHandle As %Binary, OrderDr As %String, StartDate As %Date) As %Status
ClassMethod GetOrderInfoFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer, OrderDr As %String, StartDate As %Date) As %Status
ClassMethod GetOrderInfoClose(ByRef qHandle As %Binary, OrderDr As %String, StartDate As %Date) As %Status
```

### 4.2 参数验证

在Execute方法中验证参数：

```objectscript
ClassMethod GetOrderInfoExecute(ByRef qHandle As %Binary, OrderDr As %String, StartDate As %Date) As %Status
{
    // 参数验证
    If (OrderDr = "") {
        Quit $System.Status.Error(5001, "订单ID不能为空")
    }

    If (StartDate = "") {
        Set StartDate = $zdateh($horolog, 5)  // 默认为当前日期
    }

    // 继续业务逻辑
    // ...
}
```

## 5. 数据准备方式

### 5.1 使用SQL查询

```objectscript
ClassMethod GetUserInfoExecute(ByRef qHandle As %Binary, UserId As %String) As %Status
{
    Set tSC = $$$OK

    // 准备SQL
    Set tSQL = "SELECT UserName, UserAge, CreateTime FROM User.CBUser WHERE Code = ?"

    // 执行SQL
    Set tRS = ##class(%ResultSet).%New("%DynamicQuery:SQL")
    Set tSC = tRS.Prepare(tSQL)
    If $$$ISERR(tSC) Quit tSC

    Set tSC = tRS.Execute(UserId)
    If $$$ISERR(tSC) {
        Kill tRS
        Quit tSC
    }

    Set qHandle = tRS
    Quit tSC
}

ClassMethod GetUserInfoFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer, UserId As %String) As %Status
{
    Set tSC = $$$OK
    Set AtEnd = 1

    Try {
        If $IsObject(qHandle) {
            If qHandle.Next() {
                Set tUserName = qHandle.GetData(1)
                Set tUserAge = qHandle.GetData(2)
                Set tCreateTime = qHandle.GetData(3)

                Set Row = $ListBuild(tUserName, tUserAge, tCreateTime)
                Set AtEnd = 0
            } Else {
                Do qHandle.Close()
                Kill qHandle
            }
        }
    } Catch {
        Set tSC = $System.Status.Error(5001, "Fetch数据失败")
    }

    Quit tSC
}
```

### 5.2 使用对象查询

```objectscript
ClassMethod GetOrderInfoExecute(ByRef qHandle As %Binary, OrderDr As %String) As %Status
{
    Set tSC = $$$OK

    // 获取订单对象
    Set tOrder = ##class(User.BSOrder).%OpenId(OrderDr)
    If '$IsObject(tOrder) {
        Quit $System.Status.Error(5001, "订单不存在")
    }

    // 准备数据
    Set tData = ##class(%ArrayOfDataTypes).%New()
    Set tData.OrderNo = tOrder.OrderNo
    Set tData.Amount = tOrder.Amount

    Do tOrder.%Close()

    Set qHandle = tData
    Quit tSC
}

ClassMethod GetOrderInfoFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer, OrderDr As %String) As %Status
{
    Set tSC = $$$OK
    Set AtEnd = 1

    Try {
        If $IsObject(qHandle) {
            Set Row = $ListBuild(qHandle.OrderNo, qHandle.Amount)
            Set AtEnd = 0
            Kill qHandle
        }
    } Catch {
        Set tSC = $System.Status.Error(5001, "Fetch数据失败")
    }

    Quit tSC
}
```

### 5.3 使用游标

```objectscript
ClassMethod GetAllUsersExecute(ByRef qHandle As %Binary) As %Status
{
    Set tSC = $$$OK

    // 准备游标数据
    Set qHandle("index") = 0
    Set qHandle("data") = ##class(%ArrayOfDataTypes).%New()

    // 执行SQL获取所有用户
    Set tRS = ##class(%ResultSet).%New("%DynamicQuery:SQL")
    Do tRS.Prepare("SELECT Code, Descripts FROM User.CBUser WHERE Deleted = 0")
    Do tRS.Execute()

    // 将数据存入数组
    While tRS.Next() {
        Set tCode = tRS.GetData(1)
        Set tDesc = tRS.GetData(2)
        Set qHandle("data", tCode) = tDesc
    }

    Do tRS.Close()

    Quit tSC
}

ClassMethod GetAllUsersFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer) As %Status
{
    Set tSC = $$$OK
    Set AtEnd = 1

    Try {
        If $Data(qHandle) {
            Set tIndex = qHandle("index") + 1
            Set tCode = $Order(qHandle("data", "", tIndex))

            If (tCode '= "") {
                Set tDesc = qHandle("data", tCode)
                Set Row = $ListBuild(tCode, tDesc)
                Set AtEnd = 0
                Set qHandle("index") = tIndex
            } Else {
                Kill qHandle
            }
        }
    } Catch {
        Set tSC = $System.Status.Error(5001, "Fetch数据失败")
    }

    Quit tSC
}
```

## 6. 完整示例

```objectscript
/// 获取订单详细信息
/// OrderDr: 订单ID
Query GetOrderDetail(OrderDr As %String) As %Query(ROWSPEC = "OrderNo:%String,OrderDate:%Date,Amount:%Numeric,Status:%String")
{
}

ClassMethod GetOrderDetailExecute(ByRef qHandle As %Binary, OrderDr As %String) As %Status
{
    Set tSC = $$$OK

    // 参数验证
    If (OrderDr = "") {
        Quit $System.Status.Error(5001, "订单ID不能为空")
    }

    // 获取订单信息
    Set tOrder = ##class(User.BSOrder).%OpenId(OrderDr)
    If '$IsObject(tOrder) {
        Quit $System.Status.Error(5002, "订单不存在")
    }

    // 准备数据
    Set tData = ##class(%ArrayOfDataTypes).%New()
    Set tData.OrderNo = tOrder.OrderNo
    Set tData.OrderDate = tOrder.OrderDate
    Set tData.Amount = tOrder.Amount
    Set tData.Status = tOrder.Status

    Do tOrder.%Close()

    Set qHandle = tData
    Quit tSC
}

ClassMethod GetOrderDetailFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer, OrderDr As %String) As %Status
{
    Set tSC = $$$OK
    Set AtEnd = 1

    Try {
        If $IsObject(qHandle) {
            Set Row = $ListBuild(
                qHandle.OrderNo,
                qHandle.OrderDate,
                qHandle.Amount,
                qHandle.Status
            )
            Set AtEnd = 0
            Kill qHandle
        }
    } Catch {
        Set tSC = $System.Status.Error(5001, "Fetch数据失败: " _ $ze)
    }

    Quit tSC
}

ClassMethod GetOrderDetailClose(ByRef qHandle As %Binary, OrderDr As %String) As %Status
{
    If $IsObject(qHandle) {
        Kill qHandle
    }
    Quit $$$OK
}
```

## 7. 注意事项

1. **完整性**：必须实现Execute、Fetch、Close三个方法
2. **一致性**：ROWSPEC中的列顺序必须与Fetch方法中$ListBuild的顺序一致
3. **资源释放**：Close方法必须释放所有资源
4. **错误处理**：Execute和Fetch方法应处理异常
5. **参数传递**：确保参数在三个方法间正确传递

## 8. 常见错误

❌ **错误1**：缺少Close方法
```objectscript
Query GetOrderInfo(...) As %Query(...) {}

ClassMethod GetOrderInfoExecute(...) { ... }
ClassMethod GetOrderInfoFetch(...) { ... }
// 缺少Close方法
```

❌ **错误2**：ROWSPEC与返回数据不一致
```objectscript
Query GetUserInfo(...) As %Query(ROWSPEC = "UserName:%String,UserAge:%Integer")

ClassMethod GetUserInfoFetch(..., ByRef Row As %List, ...) {
    Set Row = $ListBuild(UserAge, UserName)  // 顺序错误
}
```

❌ **错误3**：未释放资源
```objectscript
ClassMethod GetUserInfoClose(ByRef qHandle As %Binary, ...) As %Status
{
    // 缺少释放资源的代码
    Quit $$$OK
}
```
