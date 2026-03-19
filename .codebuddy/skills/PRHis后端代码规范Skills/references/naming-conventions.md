# 命名规范

## 1. 表命名规范

### 1.1 表名前缀

所有表名必须使用标准前缀：

| 前缀 | 含义 | 用途 | 示例 |
|------|------|------|------|
| CB | Common Base | 系统级字典表| CBHospital, CBAdmType |
| HB | Helper Base | 医院级字典表 | HBLoc, HBUser |
| BS | Business | 业务表 | BSAdm, BSOrderDetail |

### 1.2 命名格式

```
{前缀}{业务描述}
```

### 1.3 命名示例

```objectscript
// 基础表
Class User.CBHospital Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_Hospital ]

Class User.CBAdmType Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = CB_AdmType ]

// 字典表
Class User.HBLoc Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_Loc ]

Class User.HBUser Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = HB_User ]

// 业务表
Class User.BSAdm Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_Adm ]

Class User.BSOrderDetail Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_OrderDetail ]

```

### 1.4 命名规则

- 使用PascalCase（首字母大写的驼峰命名）
- 表名应清晰表达业务含义
- 避免使用缩写（除非是通用缩写）
- 表名长度建议控制在30字符以内

**正确示例**：
```objectscript
Class User.BSOrderPrescription Extends (%Persistent, %XML.Adaptor, src.util.DynamicObject.Adapter) [ ClassType = persistent, Inheritance = right, Not ProcedureBlock, SqlRowIdName = ID, SqlTableName = BS_OrderPrescription ]
```

**错误示例**：
```objectscript
Class User.bs_order_prescription Extends %Persistent {}
Class User.BSOrdPres Extends %Persistent {}  // 过度缩写
```

## 2. 字段命名规范

### 2.1 常规字段

使用PascalCase（首字母大写）：

```objectscript
Property UserName As %String;
Property UserAge As %Integer;
Property OrderDate As %Date;
```

### 2.2 外键字段

所有外键字段必须使用`Dr`后缀：

```objectscript
/// 机构外键
Property OrganizationDr As User.CBOrganization;

/// 用户外键
Property CreateUserDr As User.HBUser;

/// 部门外键
Property DepartmentDr As User.CBDpartment;

/// 订单外键
Property OrderDr As User.BSOrder;
```

### 2.3 布尔字段

使用`Is`或`Has`前缀：

```objectscript
Property IsActive As %Boolean;
Property IsDeleted As %Boolean;
Property HasPermission As %Boolean;
```

### 2.4 时间字段

使用`Time`或`Date`后缀：

```objectscript
Property CreateTime As %Time;
Property UpdateTime As %Time;
Property DeleteTime As %Time;
Property BirthDate As %Date;
```

### 2.5 金额字段

使用`Amount`后缀：

```objectscript
Property OrderAmount As %Numeric;
Property DiscountAmount As %Numeric;
Property TotalAmount As %Numeric;
```

### 2.6 系统字段

| 字段名 | 类型 | 用途 |
|--------|------|------|
| Code | %String | 主键代码 |
| Descripts | %String | 中文描述 |
| ENDescripts | %String | 英文描述 |
| StartDate | %Date | 开始日期 |
| StopDate | %Date | 结束日期 |
| CreateDate | %Date | 创建日期 |
| CreateUserDr | User.HBUser | 创建用户外键 |
| Deleted | %Integer | 逻辑删除标记（0：正常，1：已删除） |
| DeleteTime | %Time | 删除时间 |

## 3. 类命名规范

### 3.1 表类

所有表类必须保存到User包下：

```objectscript
Class User.CBOrganization Extends src.util.DynamicObject.Adapter {}
Class User.CBUser Extends src.util.DynamicObject.Adapter {}
Class User.BSOrderPresc Extends src.util.DynamicObject.Adapter {}
```

### 3.2 业务类

业务类应使用正确的业务包名：

```objectscript
Class src.Pharmacy.PharmacyManage Extends %RegisteredObject {}
Class src.Decoct.DecoctDisp.Extends %RegisteredObject {}
Class src.Inventory.InventoryManage Extends %RegisteredObject {}
```

### 3.3 47个业务包

| 包名 | 业务领域 |
|------|---------|
| AccM | 病人账户管理 |
| Antibact | 抗菌药物管理 |
| BasicData | 基数数据管理 |
| Cashier | 收费管理 |
| DocCure | 治疗工作站管理 |
| Doctor | 医生工作站管理 |
| Nurse | 护士工作站管理 |
| Pharmacy | 药房库存管理 |
| DRGs | 疾病诊断相关分类管理 |
| EMR | 电子病历管理 |
| EMRQC | 病历质控管理 |
| FaceRecognition | 人脸识别管理 |
| INSU | 医保管理 |
| Lis | 检验管理 |
| Lodop | lodop打印插件管理 |
| Logon | 用户登录管理 |
| Material | 物资耗材管理 |
| PACS | 医学影像管理 |
| PatAdm | 病人就诊管理 |
| Patient | 病人管理 |
| ulit | 工具管理 |
| Decoct | 煎药室管理 |
| EmergEncycenter | 急救中心管理 |
| Group | 角色管理 |
| Invoice | 发票管理 |
| InternetHospital | 互联网医院管理 |
| CA | 证书管理 |
| Sunplatform | 阳光平台管理 |
| Supervision | 监管平台管理 |
| SystemConfig | 系统主题配置管理 |
| TencentCloud | 腾讯云管理 |
| Wechat | 微信管理 |
| Tracing | 追溯码管理 |
| SMS | 短信管理 |
| Secret | 病人密级管理 |
| RaqSoft | 润乾工具管理 |
| OutPatient | 门诊管理 |
| Optometry | 视光管理 |
| MobileNuse | 移动护理管理 |
| Inpatient | 住院病人管理 |
| HealthCard | 健康卡管理 |
| ExternalInterface | 外部接口管理 |
| Interface | 内部接口管理 |
| Equip | 设备管理 |
| Report | 报表管理 |
| Kingdee | 金蝶业务管理 |
| AdverseEvent | 不良事件上报管理 |

### 3.4 类命名规则

- 使用PascalCase
- 类名应清晰表达功能
- 避免使用缩写
- 避免与系统类重名

**正确示例**：
```objectscript
Class src.Pharmacy.PharmacyManage Extends %RegisteredObject {}
Class src.Pharmacy.OutPha.Extends %RegisteredObject {}
```

**错误示例**：
```objectscript
Class src.pharmacy_manage Extends %RegisteredObject {}
Class src.Pharmacy.PM Extends %RegisteredObject {}  // 过度缩写
```

## 4. 方法命名规范

### 4.1 方法命名格式

```
{动词}{名词}
```

### 4.2 常用动词

| 动词 | 含义 | 示例 |
|------|------|------|
| Get | 获取 | GetUserInfo, GetOrderList |
| Save | 保存 | SaveOrder, SaveUser |
| Update | 更新 | UpdateOrder, UpdateUser |
| Delete | 删除 | DeleteOrder, DeleteUser |
| Create | 创建 | CreateUser, CreateOrder |
| Validate | 验证 | ValidateOrder, ValidateUser |
| Process | 处理 | ProcessOrder, ProcessPayment |
| Calculate | 计算 | CalculateAmount, CalculateTotal |
| Query | 查询 | QueryUserList, QueryOrderInfo |
| Check | 检查 | CheckPermission, CheckStatus |

### 4.3 方法命名示例

```objectscript
/// 获取用户信息
ClassMethod GetUserInfo(pUserId As %String) As %String {}

/// 保存订单
ClassMethod SaveOrder(pOrderData As %GlobalBinaryStream) As %String {}

/// 更新用户
ClassMethod UpdateUser(pUserId As %String, pUserData As %GlobalBinaryStream) As %Status {}

/// 删除订单
ClassMethod DeleteOrder(pOrderId As %String) As %Status {}

/// 验证订单
ClassMethod ValidateOrder(pOrderId As %String) As %Boolean {}

/// 处理支付
ClassMethod ProcessPayment(pPaymentData As %GlobalBinaryStream) As %Status {}

/// 计算总金额
ClassMethod CalculateTotal(pOrderDr As %String) As %Numeric {}
```

### 4.4 Query方法命名

Query相关方法必须遵循命名约定：

```objectscript
Query GetOrderList(pOrgDr As %String) As %Query(...) {}

ClassMethod GetOrderListExecute(ByRef qHandle As %Binary, pOrgDr As %String) As %Status {}
ClassMethod GetOrderListFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer, pOrgDr As %String) As %Status {}
ClassMethod GetOrderListClose(ByRef qHandle As %Binary, pOrgDr As %String) As %Status {}
```

## 5. Query命名规范

### 5.1 Query命名格式

```
{动词}{名词列表}
```

### 5.2 Query命名示例

```objectscript
/// 获取用户信息
Query GetUserInfo(pUserId As %String) As %Query(...) {}

/// 获取订单列表
Query GetOrderList(pOrgDr As %String) As %Query(...) {}

/// 查询处方明细
Query QueryPrescDetail(pPrescDr As %String) As %Query(...) {}

/// 获取药品库存
Query GetDrugStock(pDrugDr As %String) As %Query(...) {}
```

### 5.3 ROWSPEC命名

ROWSPEC中的列名应使用PascalCase：

```objectscript
Query GetUserInfo(pUserId As %String) As %Query(
    ROWSPEC = "UserName:%String,UserAge:%Integer,Department:%String"
) {}
```

## 6. 变量命名规范

变量命名应该使用“名词”或者“形容词＋名词”。有时为了更醒目地表示变量之间的相关性，也可以采用“名词＋形容词”的命名方式；
变量命名应该直观且可以拼读，可望文知义，采用英文单词或组合，便于记忆和阅读，切忌使用汉语拼音来命名，程序中的英文单词一般不会太复杂，用词应当准确；
不可出现仅靠大小写区分的相似的标识符，如x，X；
不可出现单个字母的命名，如a，b，c等；
应该避免名字中出现数字编号a1，a2等；
对于计数的循环变量应该使用i,j,k,l,m,n； 
### 6.1 参数命名

参数使用`p`前缀：

```objectscript
ClassMethod SaveOrder(pOrderData As %GlobalBinaryStream, pUserId As %String) As %String {}
```

### 6.2 局部变量命名

局部变量使用`t`前缀：

```objectscript
ClassMethod SaveOrder(pOrderData As %GlobalBinaryStream) As %String
{
    Set tOrderDr = ""
    Set tSC = $$$OK
    Set tData = ##class(%GlobalBinaryStream).%New()
    // ...
}
```

### 6.3 Query句柄命名

Query句柄使用`qHandle`：

```objectscript
ClassMethod GetOrderListExecute(ByRef qHandle As %Binary, pOrgDr As %String) As %Status {}
```

### 6.4 其他特殊变量

| 变量类型 | 命名规范 | 示例 |
|---------|---------|------|
| 状态码 | tSC | Set tSC = $$$OK |
| SQL语句 | tSQL | Set tSQL = "SELECT ..." |
| ResultSet | tRS | Set tRS = ##class(%ResultSet).%New() |
| 循环变量 | i, j, k | For i = 1:1:100 |
| 临时变量 | tTemp | Set tTemp = "" |

## 7. 命名检查清单

开发时请检查：

- [ ] 表名是否使用正确的CB/HB/BS前缀？
- [ ] 表名是否使用PascalCase？
- [ ] 外键字段是否以Dr结尾？
- [ ] 字段名是否使用PascalCase？
- [ ] 方法名是否使用{动词}{名词}格式？
- [ ] 参数是否使用p前缀？
- [ ] 局部变量是否使用t前缀？
- [ ] Query方法名是否遵循命名约定？
- [ ] 布尔字段是否使用Is/Has前缀？
- [ ] 时间字段是否使用Time/Date后缀？



## 8. 常见错误

❌ **错误1**：表名未使用前缀
```objectscript
Class User.Organization Extends %Persistent {}
```
✅ **正确**：
```objectscript
Class User.CBOrganization Extends %Persistent {}
```

❌ **错误2**：外键未使用Dr后缀
```objectscript
Property Organization As CBOrganization;
```
✅ **正确**：
```objectscript
Property OrganizationDr As CBOrganization;
```

❌ **错误3**：方法命名不清晰
```objectscript
ClassMethod DoSomething(pData) {}
```
✅ **正确**：
```objectscript
ClassMethod SaveOrder(pOrderData) {}
```

❌ **错误4**：参数未使用p前缀
```objectscript
ClassMethod SaveOrder(OrderData As %GlobalBinaryStream) {}
```
✅ **正确**：
```objectscript
ClassMethod SaveOrder(pOrderData As %GlobalBinaryStream) {}
```
