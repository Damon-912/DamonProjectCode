# 事务处理规范

## 1. 事务基本概念

事务（Transaction）是保证数据一致性的重要机制，确保一组数据库操作要么全部成功，要么全部失败。

## 2. 标准事务模板

### 2.1 基本事务结构

```objectscript
ClassMethod SaveOrder(pOrderData As %GlobalBinaryStream) As %String
{
    Try {
        // 开始事务
        TSTART

        // 执行业务逻辑
        Set tOrderDr = ##class(src.util.operatetable).Insert("User.BSOrder", pOrderData)
        If (tOrderDr = "") {
            Throw ##class(%Exception.SystemException).%New("保存订单失败")
        }

        Set tOrderItemData = ##class(%GlobalBinaryStream).%New()
        Set tOrderItemData.OrderDr = tOrderDr
        Set tOrderItemDr = ##class(src.util.operatetable).Insert("User.BSOrderItem", tOrderItemData)
        If (tOrderItemDr = "") {
            Throw ##class(%Exception.SystemException).%New("保存订单明细失败")
        }

        // 提交事务
        TCOMMIT

        Quit tOrderDr
    } Catch {
        // 回滚事务
        TROLLBACK
        Quit ""
    }
}
```

### 2.2 事务方法签名

- **TSTART**：开始事务
- **TCOMMIT**：提交事务
- **TROLLBACK**：回滚事务

## 3. 嵌套事务处理

### 3.1 嵌套事务场景

当在一个事务中调用另一个包含事务的方法时，需要特殊处理。

### 3.2 嵌套事务正确示例

```objectscript
/// 保存订单（主方法）
ClassMethod SaveOrder(pOrderData As %GlobalBinaryStream) As %String
{
    Try {
        TSTART

        // 保存订单主表
        Set tOrderDr = ##class(src.util.operatetable).Insert("User.BSOrder", pOrderData)

        // 调用包含事务的方法（但不在子方法中开启新事务）
        Set tSC = ..SaveOrderItem(tOrderDr, pOrderData)
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.SystemException).%New("保存订单明细失败")
        }

        // 更新库存
        Set tSC = ..UpdateStock(tOrderDr)
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.SystemException).%New("更新库存失败")
        }

        TCOMMIT
        Quit tOrderDr
    } Catch {
        TROLLBACK
        Quit ""
    }
}

/// 保存订单明细（子方法，不包含事务）
ClassMethod SaveOrderItem(pOrderDr As %String, pOrderData As %GlobalBinaryStream) As %Status
{
    Try {
        Set tItemData = ##class(%GlobalBinaryStream).%New()
        Set tItemData.OrderDr = pOrderDr

        Set tItemDr = ##class(src.util.operatetable).Insert("User.BSOrderItem", tItemData)
        If (tItemDr = "") {
            Throw ##class(%Exception.SystemException).%New("保存失败")
        }

        Quit $$$OK
    } Catch {
        Return $System.Status.Error(5001, $ze)
    }
}
```

### 3.3 注意事项

- 子方法中不要开启新事务（TSTART）
- 子方法只返回成功/失败状态，不处理事务
- 所有事务由主方法统一管理

## 4. 事务超时处理

### 4.1 设置事务超时

```objectscript
ClassMethod ProcessBigData() As %Status
{
    Try {
        // 设置事务超时时间（秒）
        Set ^sys("transaction", "timeout") = 300  // 5分钟

        TSTART

        // 执行耗时操作
        For i = 1:1:10000 {
            Set tData = ##class(src.util.operatetable).Insert("User.BSRecord", tStream)
        }

        TCOMMIT

        Quit $$$OK
    } Catch {
        TROLLBACK
        Return $System.Status.Error(5001, "事务执行失败: " _ $ze)
    } Finally {
        // 清理超时设置
        Kill ^sys("transaction", "timeout")
    }
}
```

### 4.2 事务超时配置

| 超时时间 | 适用场景 |
|---------|---------|
| 30秒 | 简单CRUD操作 |
| 60秒 | 中等复杂度操作 |
| 300秒 | 批量数据导入 |
| 600秒 | 大数据量处理 |

## 5. 事务中的异常处理

### 5.1 使用Try-Catch-Throw

```objectscript
ClassMethod UpdateOrder(pOrderDr As %String, pData As %GlobalBinaryStream) As %Status
{
    Try {
        TSTART

        // 更新订单
        Set tSC = ##class(src.util.operatetable).Update("User.BSOrder", pOrderDr, pData)
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.SystemException).%New("更新订单失败")
        }

        // 更新订单状态
        Set tSC = ##class(src.util.operatetable).Update("User.BSOrderStatus", pOrderDr, tStatusData)
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.SystemException).%New("更新状态失败")
        }

        TCOMMIT
        Quit $$$OK
    } Catch Ex {
        TROLLBACK
        Return $System.Status.Error(5001, Ex.DisplayString())
    }
}
```

### 5.2 错误日志记录

```objectscript
ClassMethod ProcessOrder(pOrderDr As %String) As %Status
{
    Try {
        TSTART

        Set tSC = ##class(src.util.operatetable).Insert("User.BSOrder", tData)
        If $$$ISERR(tSC) {
            Throw ##class(%Exception.SystemException).%New("操作失败: " _ $System.Status.GetOneErrorText(tSC))
        }

        TCOMMIT
        Quit $$$OK
    } Catch Ex {
        TROLLBACK

        // 记录错误日志
        Set tErrorLog = ##class(%GlobalBinaryStream).%New()
        Set tErrorLog.MethodName = "ProcessOrder"
        Set tErrorLog.ErrorText = Ex.DisplayString()
        Set tErrorLog.ErrorTime = $zdatetime($horolog, 3)

        Do ##class(src.util.operatetable).Insert("src.Pharmacy.ErrorLog", tErrorLog)

        Return $System.Status.Error(5001, Ex.DisplayString())
    }
}
```

## 6. 事务最佳实践

### 6.1 保持事务简短

```objectscript
ClassMethod SaveOrder(pOrderData As %GlobalBinaryStream) As %String
{
    // ❌ 错误：在事务外做大量数据处理
    Set tProcessedData = ..ProcessLargeData(pOrderData)

    Try {
        TSTART

        // ✅ 正确：事务只包含数据库操作
        Set tOrderDr = ##class(src.util.operatetable).Insert("User.BSOrder", tProcessedData)
        Set tItemDr = ##class(src.util.operatetable).Insert("User.BSOrderItem", tItemData)

        TCOMMIT
        Quit tOrderDr
    } Catch {
        TROLLBACK
        Quit ""
    }
}
```

### 6.2 事务中的查询操作

```objectscript
ClassMethod TransferStock(pFromDr As %String, pToDr As %String, pQty As %Numeric) As %Status
{
    Try {
        TSTART

        // 查询库存（需要在事务中查询以保证数据一致性）
        Set tFromStock = ##class(src.util.operatetable).GetRow("User.CBStock", pFromDr)
        If (tFromStock.Qty < pQty) {
            Throw ##class(%Exception.SystemException).%New("库存不足")
        }

        // 扣减库存
        Set tFromStock.Qty = tFromStock.Qty - pQty
        Do ##class(src.util.operatetable).Update("User.CBStock", pFromDr, tFromStock)

        // 增加库存
        Set tToStock = ##class(src.util.operatetable).GetRow("User.CBStock", pToDr)
        Set tToStock.Qty = tToStock.Qty + pQty
        Do ##class(src.util.operatetable).Update("User.CBStock", pToDr, tToStock)

        TCOMMIT
        Quit $$$OK
    } Catch {
        TROLLBACK
        Return $System.Status.Error(5001, "库存转移失败: " _ $ze)
    }
}
```

### 6.3 只在必要时使用事务

```objectscript
/// ✅ 需要：多个表关联操作
ClassMethod SaveOrderWithItems(pOrderData, pItemsData) As %Status
{
    Try {
        TSTART
        // 保存订单
        // 保存订单明细
        // 更新库存
        TCOMMIT
    } Catch { TROLLBACK }
}

/// ✅ 需要：复杂业务逻辑
ClassMethod ProcessRefund(pOrderDr As %String) As %Status
{
    Try {
        TSTART
        // 更新订单状态
        // 退款
        // 恢复库存
        TCOMMIT
    } Catch { TROLLBACK }
}

/// ❌ 不需要：简单查询
ClassMethod GetOrderInfo(pOrderDr As %String) As %String
{
    // 不需要事务
    Quit ##class(src.util.operatetable).GetRow("User.BSOrder", pOrderDr)
}

/// ❌ 不需要：单表插入
ClassMethod AddLog(pLogData) As %Status
{
    // 不需要事务
    Quit ##class(src.util.operatetable).Insert("User.BSLog", pLogData)
}
```

## 7. 事务检查清单

开发包含事务的方法时，请检查：

- [ ] 是否需要事务？
- [ ] 事务是否使用TSTART开始？
- [ ] 事务是否使用TCOMMIT提交？
- [ ] 异常情况是否使用TROLLBACK回滚？
- [ ] 是否嵌套了不必要的事务？
- [ ] 是否设置合理的超时时间？
- [ ] 事务中的操作是否足够简短？
- [ ] 是否记录了错误日志？

## 8. 常见错误

❌ **错误1**：缺少异常处理
```objectscript
TSTART
Do ##class(src.util.operatetable).Insert("User.BSOrder", tData)
Do ##class(src.util.operatetable).Insert("User.BSOrderItem", tItemData)
TCOMMIT
// 如果Insert失败，事务无法正确回滚
```

❌ **错误2**：嵌套事务
```objectscript
ClassMethod Main()
{
    TSTART
    Do ..SubMethod()  // SubMethod中也包含TSTART
    TCOMMIT
}

ClassMethod SubMethod()
{
    TSTART  // ❌ 不要在子方法中开启新事务
    Do ...
    TCOMMIT
}
```

❌ **错误3**：事务中耗时操作
```objectscript
TSTART
For i = 1:1:100000 {
    Set tResult = ##class(some.calculater).ComplexCalculation(i)  // ❌ 耗时操作
}
Do ##class(src.util.operatetable).Insert("User.BSRecord", tResult)
TCOMMIT
```

❌ **错误4**：忘记TCOMMIT
```objectscript
TSTART
Do ##class(src.util.operatetable).Insert("User.BSOrder", tData)
// ❌ 缺少TCOMMIT
```
