/// 方法定义模板
/// 请根据实际业务需求修改以下内容：
/// 1. 类名：使用正确的业务包名
/// 2. 方法名：遵循{动词}{名词}格式
/// 3. 参数：使用p前缀
/// 4. 变量：使用t前缀
/// 5. 必须包含try-catch错误处理
/// 6. 数据操作使用src.util.operatetable
Class src.SamplePackage.SampleClass Extends %RegisteredObject [ Not ProcedureBlock ]
{

/// 方法描述（简要说明方法功能）
/// 
/// @param pParameter1 参数1说明
/// @param pParameter2 参数2说明
/// @return 返回值说明
ClassMethod SampleMethod(pParameter1 As %String, pParameter2 As %Integer) As %String
{
        new (pParameter1,pParameter2)
        Try {
            // 初始化返回值
            Set tResult = ""
            Set tSC = $$$OK

            // 参数验证
            If (pParameter1 = "") {
                return $System.Status.Error(5001, "参数1不能为空")
            }

            // 准备数据
            Set tData = ##class(%GlobalBinaryStream).%New()
            Set tData.Field1 = pParameter1
            Set tData.Field2 = pParameter2

            // 数据操作（示例：插入）
            Set tResult = ##class(src.util.operatetable).Insert("User.BSSample", tData)
            If (tResult = "") {
                Throw ##class(%Exception.SystemException).%New("插入数据失败")
            }

            // 返回成功结果
            return tResult
        } Catch {
            // 错误处理
            Return $System.Status.Error(5001, "方法执行失败: " _ $ze)
        }
}

/// 带事务的方法模板
/// 
/// @param pOrderData 订单数据
/// @return 订单ID
ClassMethod SaveOrderWithTransaction(pOrderData As %GlobalBinaryStream) As %String
{
        new (pOrderData)
        Try {
            // 开始事务
            TSTART

            // 插入订单主表
            Set tOrderDr = ##class(src.util.operatetable).Insert("User.BSOrder", pOrderData)
            If (tOrderDr = "") {
                Throw ##class(%Exception.SystemException).%New("保存订单失败")
            }

            // 插入订单明细
            Set tItemData = ##class(%GlobalBinaryStream).%New()
            Set tItemData.OrderDr = tOrderDr
            Set tItemDr = ##class(src.util.operatetable).Insert("User.BSOrderItem", tItemData)
            If (tItemDr = "") {
                Throw ##class(%Exception.SystemException).%New("保存订单明细失败")
            }

            // 提交事务
            TCOMMIT

            // 返回订单ID
            return tOrderDr
        } Catch {
            // 回滚事务
            TROLLBACK
            Return ""
        }
}

/// 查询方法模板
/// 
/// @param pOrderId 订单ID
/// @return 订单数据
ClassMethod GetOrderInfo(pOrderId As %String) As %String
{
        new (pOrderId)
        Try {
            Set tOrderInfo = ""

            // 参数验证
            If (pOrderId = "") {
                return $System.Status.Error(5001, "订单ID不能为空")
            }

            // 查询数据
            Set tOrderInfo = ##class(src.util.operatetable).GetRow("User.BSOrder", pOrderId)
            If (tOrderInfo = "") {
                return $System.Status.Error(5002, "订单不存在")
            }

            // 返回数据
            return tOrderInfo
        } Catch {
            Return $System.Status.Error(5001, "查询失败: " _ $ze)
        }
}

/// 更新方法模板
/// 
/// @param pOrderId 订单ID
/// @param pOrderData 订单数据
/// @return 操作状态
ClassMethod UpdateOrder(pOrderId As %String, pOrderData As %GlobalBinaryStream) As %Status
{
        new (pOrderId, pOrderData)
        Try {
            // 参数验证
            If (pOrderId = "") {
                return $System.Status.Error(5001, "订单ID不能为空")
            }

            // 更新数据
            Set tSC = ##class(src.util.operatetable).Update("User.BSOrder", pOrderId, pOrderData)
            If $$$ISERR(tSC) {
                Throw ##class(%Exception.SystemException).%New("更新失败")
            }

            // 返回成功状态
            return $$$OK
        } Catch {
            Return $System.Status.Error(5001, "更新失败: " _ $ze)
        }
}

/// 删除方法模板（逻辑删除）
/// 
/// @param pOrderId 订单ID
/// @return 操作状态
ClassMethod DeleteOrder(pOrderId As %String) As %Status
{
        new (pOrderId)
        Try {
            // 参数验证
            If (pOrderId = "") {
                return $System.Status.Error(5001, "订单ID不能为空")
            }

            // 获取订单数据
            Set tOrder = ##class(src.util.operatetable).GetRow("User.BSOrder", pOrderId)
            If (tOrder = "") {
                return $System.Status.Error(5002, "订单不存在")
            }

            // 设置删除标记
            Set tOrder.Deleted = 1
            Set tOrder.DeleteTime = $zdatetime($horolog, 3)

            // 更新数据
            Set tSC = ##class(src.util.operatetable).Update("User.BSOrder", pOrderId, tOrder)
            If $$$ISERR(tSC) {
                Throw ##class(%Exception.SystemException).%New("删除失败")
            }

            // 返回成功状态
            return $$$OK
        } Catch {
            Return $System.Status.Error(5001, "删除失败: " _ $ze)
        }
}

/// 批量操作方法模板
/// 
/// @param pDataList 数据列表
/// @return 成功数量
ClassMethod BatchSave(pDataList As %List) As %Integer
{
        new (pDataList)
        Try {
            Set tSuccessCount = 0

            // 参数验证
            If ($ListLength(pDataList) = 0) {
                return 0
            }

            // 开始事务
            TSTART

            // 遍历数据列表
            For i = 1:1:$ListLength(pDataList) {
                Set tData = $ListGet(pDataList, i)

                Set tDr = ##class(src.util.operatetable).Insert("User.BSSample", tData)
                If (tDr '= "") {
                    Set tSuccessCount = tSuccessCount + 1
                }
            }

            // 提交事务
            TCOMMIT

            // 返回成功数量
            return tSuccessCount
        } Catch {
            // 回滚事务
            TROLLBACK
            Return 0
        }
}

}
