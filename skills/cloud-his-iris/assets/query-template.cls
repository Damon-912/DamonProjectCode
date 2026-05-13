/// Query定义模板
/// 请根据实际业务需求修改以下内容：
/// 1. Query名称：遵循{动词}{名词}格式
/// 2. ROWSPEC：定义返回结果的列名和数据类型
/// 3. 参数：使用p前缀
/// 4. 必须实现Execute、Fetch、Close三个方法
/// 5. 数据准备方式：选择SQL查询、对象查询或游标
Class src.SamplePackage.SampleQuery Extends %RegisteredObject
{

/// 获取订单详细信息
/// 
/// @param pOrderDr 订单ID
/// @returns ROWSPEC: OrderNo:%String,OrderDate:%Date,Amount:%Numeric,Status:%String
Query GetOrderDetail(pOrderDr As %String) As %Query(ROWSPEC = "OrderNo:%String,OrderDate:%Date,Amount:%Numeric,Status:%String")
{
}

/// 执行Query
/// 
/// @param qHandle Query句柄
/// @param pOrderDr 订单ID
/// @return 操作状态
ClassMethod GetOrderDetailExecute(ByRef qHandle As %Binary, pOrderDr As %String) As %Status
{
        Set tSC = $$$OK

        // 参数验证
        If (pOrderDr = "") {
            Quit $System.Status.Error(5001, "订单ID不能为空")
        }

        // 获取订单对象
        Set tOrder = ##class(User.BSOrderDetail).%OpenId(pOrderDr)
        If '$IsObject(tOrder) {
            Quit $System.Status.Error(5002, "订单不存在")
        }

        // 准备数据
        Set tData = ##class(%ArrayOfDataTypes).%New()
        Set tData.OrderNo = tOrder.OrderNo
        Set tData.OrderDate = tOrder.OrderDate
        Set tData.Amount = tOrder.Amount
        Set tData.Status = tOrder.Status

        // 关闭对象
        Do tOrder.%Close()

        // 设置句柄
        Set qHandle = tData
        Quit tSC
}

/// 获取下一行数据
/// 
/// @param qHandle Query句柄
/// @param Row 返回的数据行
/// @param AtEnd 是否到达末尾
/// @param pOrderDr 订单ID
/// @return 操作状态
ClassMethod GetOrderDetailFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer, pOrderDr As %String) As %Status
{
        Set tSC = $$$OK
        Set AtEnd = 1  // 默认已结束

        Try {
            If $IsObject(qHandle) {
                // 构建返回行（注意：顺序必须与ROWSPEC一致）
                Set Row = $ListBuild(
                    qHandle.OrderNo,
                    qHandle.OrderDate,
                    qHandle.Amount,
                    qHandle.Status
                )
                Set AtEnd = 0  // 还有数据

                // 释放句柄
                Kill qHandle
            }
        } Catch {
            Set tSC = $System.Status.Error(5001, "Fetch数据失败: " _ $ze)
        }

        Quit tSC
}

/// 关闭Query
/// 
/// @param qHandle Query句柄
/// @param pOrderDr 订单ID
/// @return 操作状态
ClassMethod GetOrderDetailClose(ByRef qHandle As %Binary, pOrderDr As %String) As %Status
{
        // 释放资源
        If $IsObject(qHandle) {
            Kill qHandle
        }

        Quit $$$OK
}

/// 获取用户列表（使用SQL查询）
/// 
/// @param pOrganizationDr 机构ID
/// @returns ROWSPEC: UserName:%String,UserCode:%String,Department:%String
Query GetUserList(pOrganizationDr As %String) As %Query(ROWSPEC = "UserName:%String,UserCode:%String,Department:%String")
{
}

/// 执行Query（SQL查询方式）
ClassMethod GetUserListExecute(ByRef qHandle As %Binary, pOrganizationDr As %String) As %Status
{
        Set tSC = $$$OK

        // 参数验证
        If (pOrganizationDr = "") {
            Quit $System.Status.Error(5001, "机构ID不能为空")
        }

        // 准备SQL
        Set tSQL = "SELECT u.Descripts, u.Code, d.Descripts FROM User.CBUser u "
        Set tSQL = tSQL _ " LEFT JOIN User.CBDepartment d ON u.DepartmentDr = d.Code "
        Set tSQL = tSQL _ " WHERE u.OrganizationDr = ? AND u.Deleted = 0"

        // 执行SQL
        Set tRS = ##class(%ResultSet).%New("%DynamicQuery:SQL")
        Set tSC = tRS.Prepare(tSQL)
        If $$$ISERR(tSC) Quit tSC

        Set tSC = tRS.Execute(pOrganizationDr)
        If $$$ISERR(tSC) {
            Kill tRS
            Quit tSC
        }

        // 设置句柄
        Set qHandle = tRS
        Quit tSC
}

/// 获取下一行数据（SQL查询方式）
ClassMethod GetUserListFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer, pOrganizationDr As %String) As %Status
{
        Set tSC = $$$OK
        Set AtEnd = 1

        Try {
            If $IsObject(qHandle) {
                If qHandle.Next() {
                    Set tUserName = qHandle.GetData(1)
                    Set tUserCode = qHandle.GetData(2)
                    Set tDepartment = qHandle.GetData(3)

                    // 构建返回行
                    Set Row = $ListBuild(tUserName, tUserCode, tDepartment)
                    Set AtEnd = 0
                } Else {
                    // 关闭ResultSet
                    Do qHandle.Close()
                    Kill qHandle
                }
            }
        } Catch {
            Set tSC = $System.Status.Error(5001, "Fetch数据失败")
        }

        Quit tSC
}

/// 关闭Query（SQL查询方式）
ClassMethod GetUserListClose(ByRef qHandle As %Binary, pOrganizationDr As %String) As %Status
{
        If $IsObject(qHandle) {
            Do qHandle.Close()
            Kill qHandle
        }
        Quit $$$OK
}

/// 获取所有产品（使用游标方式）
/// 
/// @param pCategoryDr 产品分类ID
/// @returns ROWSPEC: ProductCode:%String,ProductName:%String,Price:%Numeric
Query GetAllProducts(pCategoryDr As %String) As %Query(ROWSPEC = "ProductCode:%String,ProductName:%String,Price:%Numeric")
{
}

/// 执行Query（游标方式）
ClassMethod GetAllProductsExecute(ByRef qHandle As %Binary, pCategoryDr As %String) As %Status
{
        Set tSC = $$$OK

        // 初始化游标数据
        Set qHandle("index") = 0
        Set qHandle("data") = ##class(%ArrayOfDataTypes).%New()

        // 执行SQL获取所有产品
        Set tRS = ##class(%ResultSet).%New("%DynamicQuery:SQL")
        Set tSQL = "SELECT Code, Descripts, Price FROM User.CBProduct WHERE CategoryDr = ? AND Deleted = 0"
        Do tRS.Prepare(tSQL)
        Do tRS.Execute(pCategoryDr)

        // 将数据存入数组
        Set tIndex = 0
        While tRS.Next() {
            Set tIndex = tIndex + 1
            Set tCode = tRS.GetData(1)
            Set tName = tRS.GetData(2)
            Set tPrice = tRS.GetData(3)

            Set qHandle("data", tIndex, "Code") = tCode
            Set qHandle("data", tIndex, "Name") = tName
            Set qHandle("data", tIndex, "Price") = tPrice
        }

        Do tRS.Close()

        // 保存数据条数
        Set qHandle("count") = tIndex

        Quit tSC
}

/// 获取下一行数据（游标方式）
ClassMethod GetAllProductsFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer, pCategoryDr As %String) As %Status
{
        Set tSC = $$$OK
        Set AtEnd = 1

        Try {
            If $Data(qHandle) {
                Set tIndex = qHandle("index") + 1

                If (tIndex <= qHandle("count")) {
                    Set tCode = qHandle("data", tIndex, "Code")
                    Set tName = qHandle("data", tIndex, "Name")
                    Set tPrice = qHandle("data", tIndex, "Price")

                    // 构建返回行
                    Set Row = $ListBuild(tCode, tName, tPrice)
                    Set AtEnd = 0

                    // 更新索引
                    Set qHandle("index") = tIndex
                } Else {
                    // 数据已读完
                    Kill qHandle
                }
            }
        } Catch {
            Set tSC = $System.Status.Error(5001, "Fetch数据失败")
        }

        Quit tSC
}

/// 关闭Query（游标方式）
ClassMethod GetAllProductsClose(ByRef qHandle As %Binary, pCategoryDr As %String) As %Status
{
        If $Data(qHandle) {
            Kill qHandle
        }
        Quit $$$OK
}

}
