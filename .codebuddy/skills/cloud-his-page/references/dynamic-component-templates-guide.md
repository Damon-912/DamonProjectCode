# 动态组件使用指南

> 适用于单列表操作界面，主从表结构，查询导出，报表展示，订单审核，采购制单等类似界面，通过配置驱动开发

---

## 目录

1. [概述](#概述)
2. [模板类型清单](#模板类型清单)
3. [单表操作模板](#单表操作模板)
4. [父子表操作模板](#父子表操作模板)
5. [查询导出模板](#查询导出模板)
6. [订单审核模板](#订单审核模板)
7. [左右结构报表模板](#左右结构报表模板)
8. [采购制单模板](#采购制单模板)
9. [入库制单模板](#入库制单模板)
10. [表单扩展维护模板](#表单扩展维护模板)
11. [富文本模板维护](#富文本模板维护)
12. [配置参数说明](#配置参数说明)

---

## 概述

### 什么是动态组件模板

动态组件模板是CloudHIS-PR项目中的一种**配置驱动开发**模式。通过菜单参数配置即可生成完整的界面，无需编写组件代码，只需要配置对应的组件数据。

### 核心优势

| 优势 | 说明 |
|------|------|
| 零代码开发 | 通过配置参数生成界面 |
| 快速部署 | 配置即生效，无需编译构建 |
| 统一维护 | 配置数据存储在数据库中 |
| 减少重复 | 避免重复编写相似界面 |

### 适用场景

| 场景 | 是否适用 | 推荐模板 |
|------|----------|----------|
| 单表增删改查 | ✅ 强烈推荐 | SingleTableOperation |
| 主从表维护 | ✅ 强烈推荐 | ParentChildTableOperation |
| 数据查询导出 | ✅ 强烈推荐 | LeftConditionRightList |
| 报表展示（左条件+右报表） | ✅ 推荐 | LeftConditionRightReports |
| 订单审核流程 | ✅ 推荐 | OrderReviewComponent |
| 采购制单/入库质检/转移出库等 | ✅ 推荐 | InventoryManagement |
| 入库制单/转移制单/退货制单 | ✅ 推荐 | NewVoucherPreparation |
| 表单数据扩展维护 | ✅ 推荐 | FormDataExtensionMaintenance |
| 富文本模板维护 | ✅ 推荐 | WangEditorTemplateMaintenance |
| 复杂自定义交互 | ❌ 不适用 | 需开发自定义组件 |

### 自定义组件注意事项

当动态组件模板不满足需求、需要开发自定义组件时，**必须遵守以下导入路径规范**：

```jsx
// ✅ 正确：公共组件使用相对路径
import DynamicRenderingForm from '../common/DynamicRenderingForm';
import PubilcTablePagination from '../common/PubilcTablePagination';
import PublicModalFormHooks from '../common/PublicModalFormHooks';

// ❌ 错误：禁止使用 @/ 路径
import Xxx from '@/containers/components/Xxx';
import Xxx from '@/pages/common/Xxx';
```

**提示：** 公共组件统一位于 `src/pages/common/` 目录下，导入时必须使用 `../common/` 相对路径。

---

## 模板类型清单

| 模板名称 | 界面类型 | 适用场景 | 复杂度 |
|----------|----------|----------|--------|
| SingleTableOperation | singleTable | 单列表操作界面 | ⭐ |
| ParentChildTableOperation | parentChildTable | 主从表结构 | ⭐⭐ |
| LeftConditionRightList | leftConditionRightList | 查询导出 | ⭐⭐ |
| LeftConditionRightReports | leftConditionRightReports | 报表展示 | ⭐⭐ |
| OrderReviewComponent | orderReview | 订单审核 | ⭐⭐ |
| InventoryManagement | inventoryManagement | 采购制单 | ⭐⭐⭐ |
| NewVoucherPreparation | newVoucherPreparation | 入库制单 | ⭐⭐⭐ |
| FormDataExtensionMaintenance | formDataExtensionMaintenance | 表单扩展 | ⭐⭐ |
| WangEditorTemplateMaintenance | wangEditorTemplate | 富文本模板 | ⭐ |

---

## 单表操作模板

### 模板信息

| 项目 | 说明 |
|------|------|
| **模板名称** | SingleTableOperation |
| **组件路径** | `src/pages/dynamicComponent/SingleTableOperation.jsx` |
| **界面类型** | `singleTable` |
| **适用场景** | 单列表操作界面、增删改查等 |

### 功能特性

- ✅ 查询条件动态配置
- ✅ 列表信息动态配置
- ✅ 新增/编辑/删除功能
- ✅ 支持导入导出
- ✅ 支持批量删除
- ✅ 支持Tab切换
- ✅ 支持行点击选中

### 菜单参数配置

```javascript
params=interfaceType:singleTable
  &componentName:HospitalGroupMaintenance
  &selectCode:01040252      // 下拉数据接口（可选）
  &queryCode:01040253       // 查询接口（必填）
  &addCode:01040254         // 新增接口（可选）
  &editCode:01040255        // 编辑接口（可选）
  &deleteCode:01040256      // 删除接口（可选）
  &idIndex:hospGroupID      // 主键字段名（必填）
  &isRowClick:Y             // 启用行点击
  &groupType:H              // 数据范围 H-医院 G-集团
```

### 01040073配置数据

**列表表头配置（type='C'）：**

```javascript
{
  params: [{
    type: 'C',
    compontName: 'HospitalGroupMaintenance',
    reactCode: ['HospitalGroupMaintenance']
  }]
}
// 返回：columns + formData(查询表单)
```

**弹窗表单配置（type='F'）：**

```javascript
{
  params: [{
    type: 'C',
    compontName: 'HospitalGroupMaintenanceForm',  // 注意Form后缀
    reactCode: ['HospitalGroupMaintenanceForm']
  }]
}
// 返回：formData(弹窗表单)
```

---

## 父子表操作模板

### 模板信息

| 项目 | 说明 |
|------|------|
| **模板名称** | ParentChildTableOperation |
| **组件路径** | `src/pages/dynamicComponent/ParentChildTableOperation.jsx` |
| **界面类型** | `parentChildTable` |
| **适用场景** | 主从表结构、一对多关系 |

### 功能特性

- ✅ 主表查询、分页、增删改
- ✅ 明细表联动查询
- ✅ 明细表增删改
- ✅ 主从数据联动

### 菜单参数配置

```javascript
params=interfaceType:parentChildTable
  &selectCode:01040260
  &componentName:PurchaseOrderMaintenance
  &queryCode:01040261           // 主表查询
  &childQueryCode:01040262      // 明细表查询（必填）
  &recordID:orderID             // 主表主键（必填）
  &childRecordID:detailID       // 明细表主键（必填）
  &childComponentName:OrderDetail  // 明细组件名
  &childComponentNameForm:OrderDetailForm
  &addCode:01040263
  &childAddCode:01040264        // 明细新增
  &cardDesc:订单列表            // 主表标题
  &childCardDesc:订单明细       // 明细表标题（注意拼写为 childCardDesc）
```

---

## 查询导出模板

### 模板信息

| 项目 | 说明 |
|------|------|
| **模板名称** | LeftConditionRightList |
| **组件路径** | `src/pages/dynamicComponent/LeftConditionRightList.jsx` |
| **界面类型** | `leftConditionRightList` |
| **适用场景** | 数据查询导出、报表查询 |

### 功能特性

- ✅ 左侧查询条件面板
- ✅ 右侧列表展示
- ✅ 导出Excel
- ✅ 合计统计
- ✅ 患者信息联动

### 菜单参数配置

```javascript
params=interfaceType:leftConditionRightList
  &componentName:SalesReportQuery
  &selectCode:01040300
  &queryCode:01040301
  &exportCode:01040302          // 导出接口（可选）
  &summaryCode:01040303         // 合计接口（可选）
  &leftWidth:320                // 左侧面板宽度
  &showSummaryFlag:Y            // 显示合计行
  &patientLinkFlag:N            // 患者信息联动
```

---

## 订单审核模板

### 模板信息

| 项目 | 说明 |
|------|------|
| **模板名称** | OrderReviewComponent |
| **组件路径** | `src/pages/dynamicComponent/OrderReviewComponent.jsx` |
| **界面类型** | `orderReview` |
| **适用场景** | 订单审核、退货审核等审批流程 |

### 功能特性

- ✅ 上下父子列表结构
- ✅ 审核/反审核按钮
- ✅ 批量审核
- ✅ 审核状态过滤

### 菜单参数配置

```javascript
params=interfaceType:orderReview
  &componentName:PurchaseOrderReview
  &selectCode:01040310
  &queryCode:01040311           // 主表查询
  &queryDetailCode:01040316     // 明细表查询（必填）
  &idIndex:orderID              // 主表主键（必填）
  &detailIDIndex:detailID       // 明细表主键（必填）
  &examineCode:01040312         // 审核接口（必填）
  &cancelCode:01040313          // 反审核/取消接口
  &cardTitle:退货单列表
  &groupType:H
  &isShowDetailTable:Y
  &detailPaginationFlag:Y
```

---

## 左右结构报表模板

### 模板信息

| 项目 | 说明 |
|------|------|
| **模板名称** | LeftConditionRightReports |
| **组件路径** | `src/pages/dynamicComponent/LeftConditionRightReports.jsx` |
| **界面类型** | `leftConditionRightReports` |
| **适用场景** | 报表展示、左侧条件+右侧嵌入式报表 |

### 功能特性

- ✅ 左侧查询条件面板（01040073 type='C' 返回 formData）
- ✅ 右侧嵌入式报表（RAQ 等）
- ✅ 患者信息联动（可选）
- ✅ 报表类型通过查询条件选择

### 菜单参数配置

```javascript
params=interfaceType:leftConditionRightReports
  &componentName:SalesReport
  &selectCode:01040320      // 下拉/初始化（可选）
  &groupType:H
  &raqName:xxx              // 默认报表类型（可选）
  &cardTitle:搜索条件
  &rightCardTitle:报表展示
  &queryPatInfoFlag:Y       // 左侧展示患者信息
```

**01040073 配置：** 列表 type='C' 请求返回的 `formData` 作为左侧查询表单（需包含报表类型等字段）。详见下方「左右结构报表」专属参数。

---

## 采购制单模板

### 模板信息

| 项目 | 说明 |
|------|------|
| **模板名称** | InventoryManagement |
| **组件路径** | `src/pages/dynamicComponent/InventoryManagement.jsx` |
| **界面类型** | `inventoryManagement` |
| **适用场景** | 采购计划、采购收货、入库质检、转移出库、退货申请、科室退库等制单流程 |

### 功能特性

- ✅ 主列表 + 明细列表（可多级）
- ✅ 步骤条/状态切换
- ✅ 行内编辑、辅助制单、扫码
- ✅ 批量打印、导出、GSP 等

### 菜单参数配置

```javascript
params=interfaceType:inventoryManagement
  &componentName:IMWarehousingInspect
  &selectCode:01040270
  &queryCode:01040271
  &queryDetailCode:01040272
  &saveCode:01040273
  &recordSaveCode:01040274
  &idIndex:orderID
  &detailIDIndex:detailID
  &groupType:H
  &assistComponentName:OrderOfGlassesModal
  &assistModalTitle:从订单选择
  &stateSpreadingFlag:Y
  &detailInlineEditingFlag:Y
```

详见下方「采购制单模板」专属参数。

---

## 入库制单模板

### 模板信息

| 项目 | 说明 |
|------|------|
| **模板名称** | NewVoucherPreparation |
| **组件路径** | `src/pages/dynamicComponent/NewVoucherPreparation.jsx` |
| **界面类型** | `newVoucherPreparation` |
| **适用场景** | 入库制单、转移制单、退货制单、调价单录入等 |

### 功能特性

- ✅ 主列表 + 基本信息 + 明细表
- ✅ 辅助制单、扫码、导入 Excel
- ✅ 暂存/提交审核/撤回/打印

### 菜单参数配置

```javascript
params=interfaceType:newVoucherPreparation
  &componentName:NVPReceiptVP
  &selectCode:01040280
  &queryCode:01040281
  &queryDetailCode:01040282
  &saveCode:01040283
  &revokeCode:01040284
  &printCode:01040285
  &scanningCode:17030034
  &idIndex:receiptID
  &detailIDIndex:detailID
  &groupType:H
  &assistComponentName:ReviewedReceiptVPModal
  &cardTitle:入库
  &auxiliaryBtnFlag:Y
```

详见下方「入库制单模板」专属参数。

---

## 表单扩展维护模板

### 模板信息

| 项目 | 说明 |
|------|------|
| **模板名称** | FormDataExtensionMaintenance |
| **组件路径** | `src/pages/dynamicComponent/FormDataExtensionMaintenance.jsx` |
| **界面类型** | `formDataExtensionMaintenance` |
| **适用场景** | 表单数据扩展配置、左列表右明细维护 |

### 功能特性

- ✅ 左侧主列表 + 右侧明细/扩展表单
- ✅ 可选关联组件数据（01040272）
- ✅ 支持列表选择式新增

### 菜单参数配置

```javascript
params=interfaceType:formDataExtensionMaintenance
  &componentName:FormExtMaintenance
  &selectCode:01040290
  &queryCode:01040291
  &addCode:01040292
  &editCode:01040293
  &deleteCode:01040294
  &idIndex:id
  &groupType:H
  &leftCardCol:10
  &getLinkComponentDataFlag:Y
  &associatedComponentPrefix:FDEP_
```

详见下方「表单扩展维护」专属参数。

---

## 富文本模板维护

### 模板信息

| 项目 | 说明 |
|------|------|
| **模板名称** | WangEditorTemplateMaintenance |
| **组件路径** | `src/pages/dynamicComponent/WangEditorTemplateMaintenance.jsx` |
| **界面类型** | `wangEditorTemplate` |
| **适用场景** | 富文本模板维护（如线上商品补充信息、销售信息等） |

### 功能特性

- ✅ 左侧模板列表 + 右侧富文本编辑
- ✅ 支持集团/医院不同展示（productDetails / supplementInfo）
- ✅ 弹窗选择、详情保存

### 菜单参数配置

```javascript
params=interfaceType:wangEditorTemplate
  &componentName:WETMOnlineProductSupplementaryInfo
  &selectCode:01040300
  &queryCode:01040301
  &addCode:01040302
  &editCode:01040303
  &deleteCode:01040304
  &saveDetailCode:01040305
  &idIndex:id
  &groupType:H
  &leftCardCol:8
  &leftCardDesc:模板列表
  &rightCardDesc:模板内容维护
  &editorHeight:0
```

详见下方「富文本模板维护」专属参数。

---

## 配置参数说明

### 通用参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| interfaceType | string | 是 | 界面类型标识 |
| componentName | string | 是 | 组件名称（01040073查询key） |
| selectCode | string | 否 | 下拉数据接口代码 |
| queryCode | string | 是/否 | 查询接口代码 |
| addCode | string | 否 | 新增接口代码 |
| editCode | string | 否 | 编辑接口代码 |
| deleteCode | string | 否 | 删除接口代码 |
| idIndex | string | 否 | 主键字段名，默认id |
| groupType | string | 否 | 数据范围 H/G，默认H |

### 功能开关参数

| 参数名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| isRowClick | string | N | 启用行点击选中 Y/N |
| exportBtnFlag | string | N | 显示导出按钮 Y/N |
| importBtnFlag | string | N | 显示导入按钮 Y/N |
| batchDeleteFlag | string | N | 启用批量删除 Y/N |
| doNotAutoQueryFlag | string | N | 禁止自动查询 Y/N |
| hidePaginationFlag | string | N | 隐藏分页 Y/N |

### 分页参数

| 参数名 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| defaultPageSize | number | 10 | 默认每页条数 |
| paginationSize | string | small | 分页器大小 small/default/large |
| detailPaginationSize | string | - | 明细分页器大小（父子表/审核等） |
| defaultDetailPageSize | number | - | 明细默认每页条数 |

---

### 单表操作模板（SingleTableOperation）专属参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| saveCode / recordSaveCode | string | 否 | - | 行保存接口（行内编辑时，缺省用 editCode） |
| doNotAutoQueryMainListFlag | string | 否 | N | 禁止进入时自动查询主列表 Y/N |
| virtualFlag | string | 否 | N | 虚拟列表 Y 时主键用 uuid |
| tabMenuFlag | string | 否 | N | Tab 菜单（如医生站左侧）Y/N |
| tabPosition | string | 否 | - | tab 位置，table 表示在表格上方 |
| addDataListSelectionFlag | string | 否 | N | 新增为「列表选择」样式 Y/N |
| addFollowQueryFlag | string | 否 | N | 新增后自动触发查询 Y/N |
| addFlag | string | 否 | - | N 则隐藏新增按钮 |
| addBtnTitle | string | 否 | 新增 | 新增按钮文案 |
| batchDeleteCode | string | 否 | - | 批量删除接口（缺省用 deleteCode） |
| batchPrintCode | string | 否 | - | 批量打印接口 |
| inlineEditingFlag | string | 否 | N | 行内编辑 Y/N |
| addInlineEditingFlag | string | 否 | N | 行内编辑时显示「新增」Y/N |
| recordAllSaveFlag | string | 否 | N | 行数据全部保存 Y / N 逐条保存 |
| subMaintainComponentName | string | 否 | - | 子表维护 01040073 组件名 |
| subMaintainQueryCode / subMaintainSaveCode | string | 否 | - | 子表查询/保存接口 |
| subMaintainIDIndex | string | 否 | id | 子表主键 |
| notEditableFlag | string | 否 | N | 不显示编辑 Y/N |
| operationFixedFlag | string | 否 | N | 操作列固定右侧 Y/N（virtualFlag=Y 时不固定） |
| operationViewDetailsFlag / viewDetailsBtnTitle | string | 否 | N | 操作列「查看详情」及文案 |
| relatedMedicalOrdersFlag / relatedMedBtnTitle | string | 否 | N | 操作列「关联医嘱」及文案 |
| operationViewOptoSheetFlag / viewOptoSheetBtnTitle | string | 否 | N | 操作列「查看单据」及文案 |
| operationDayReminderFlag | string | 否 | N | 手术日提醒 Y/N |
| hideQueryBtnFlag | string | 否 | N | 隐藏查询按钮 Y/N |
| componentNameForm | string | 否 | componentName+Form | 弹窗表单 01040073 组件名 |
| modalQueryCode / modalListComponentName | string | 否 | - | 弹窗内列表查询接口、组件名 |
| modalTitle / modalWidth / formModalWidth | string | 否 | - | 弹窗标题、宽度 |
| modalTableAutoSelectFlag | string | 否 | N | 弹窗表格自动选中 Y/N |
| fileType / uploadUrl / downloadUrl | string | 否 | - | 上传目录、上传/下载地址 |
| tableDisabledDataIndex | string | 否 | - | 该字段为空时表格行禁用 |
| multipleSelectFlag | string | 否 | N | 多选 Y/N |
| cancelAddOperationFlag | string | 否 | N | 不显示「新增」操作列 Y/N |
| printCode / loadTemplateFlag / fastReportPrintNotFlag | string | 否 | - | 打印、按模板打印、快报打印 |
| importCode / importSplitCount | string/number | 否 | 200 | 导入接口、分批条数 |
| reactExportERPFlag / exportFileName / exportType / exportSheetName | string | 否 | - | 前端 ERP 导出及导出配置 |

---

### 父子表操作模板（ParentChildTableOperation）专属参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| recordID | string | 是 | id | 主表主键字段 |
| childRecordID | string | 是 | id | 明细表主键字段 |
| childQueryCode | string | 是 | - | 明细表查询接口 |
| childAddCode / childEditCode / childDeleteCode | string | 否 | - | 明细增/改/删接口 |
| childComponentName | string | 否 | componentName+Detail | 明细表 01040073 组件名 |
| childComponentNameForm | string | 否 | - | 明细弹窗表单组件名 |
| cardDesc | string | 否 | 主列表 | 主表卡片标题 |
| childCardDesc | string | 否 | 明细列表 | 明细卡片标题（注意拼写） |
| leftCardCol / rightCardCol | number | 否 | 12 | 左/右卡片栅格占比 |
| doNotAutoQueryMainListFlag | string | 否 | N | 禁止自动查主表 Y/N |
| paginationHideFlag | string | 否 | N | 主表隐藏分页 Y/N |
| detailPaginationHideFlag | string | 否 | N | 明细隐藏分页 Y/N |
| hideQueryBtn / hideDetailQueryBtn | string | 否 | N | 隐藏主表/明细查询按钮 Y/N |
| childRowClick | string | 否 | N | 明细行点击高亮 Y/N |
| detailDisplayQueryCriteriaFlag | string | 否 | N | 明细弹窗展示查询条件 Y/N |
| detailNotVerifiedRequiredFlag | string | 否 | N | 明细查询不校验必填 Y/N |
| contrastCode / cancelComparisonCode | string | 否 | - | 对比/取消对比接口 |
| mainInputTableComponentName / detailInputTableComponentName | string | 否 | - | 主表/明细录入表格组件名 |

---

### 查询导出模板（LeftConditionRightList）专属参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| exportCode | string | 否 | - | 导出接口 |
| leftWidth | number | 否 | - | 左侧条件区宽度（如 320） |
| showSummaryFlag | string | 否 | - | 显示合计行 Y/N |
| totalStatistics | string | 否 | - | 合计数据在 result 中的 key |
| patientLinkFlag / queryPatInfoFlag | string | 否 | N | 患者信息联动、左侧展示患者信息 Y/N |
| cardTitle | string | 否 | 搜索条件 | 左侧卡片标题 |
| rightCardTitle | string | 否 | 查询列表 | 右侧卡片标题 |
| exportBtnTitle | string | 否 | 导出 | 导出按钮文案 |
| statisticsValueColor | string | 否 | #007AFF | 合计数值颜色 |
| rowDataColor | string | 否 | - | 行背景色规则（逗号分隔） |
| rowDataTitle | string | 否 | - | 行标题字段（逗号分隔） |
| operationViewDetailsFlag / operationViewOptoSheetFlag / operationViewEMRFlag | string | 否 | N | 操作列「查看详情/查看单据/查看病历」Y/N |
| viewDetailsBtnTitle / viewOptoSheetBtnTitle / viewEMRBtnTitle | string | 否 | - | 对应按钮文案 |
| operationFixedFlag | string | 否 | N | 操作列固定右侧 Y/N |
| reactExportFlag | string | 否 | N | 前端导出 Y/N |

---

### 左右结构报表（LeftConditionRightReports）专属参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| componentName | string | 是 | - | 组件名（01040073 表头 type='C'，返回 formData 作为查询条件） |
| selectCode | string | 否 | - | 下拉/初始化接口 |
| groupType | string | 否 | - | H/G，报表标识 |
| raqName | string | 否 | - | 默认报表类型（可从查询条件 reportType 取） |
| cardTitle | string | 否 | 搜索条件 | 左侧卡片标题 |
| rightCardTitle | string | 否 | 查询列表 | 右侧标题；none 不显示 |
| queryPatInfoFlag | string | 否 | N | 左侧展示患者信息 Y/N |

---

### 订单审核模板（OrderReviewComponent）专属参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| detailComponentName | string | 否 | componentName+Detail | 明细表组件名 |
| queryDetailCode | string | 是 | - | 明细查询接口 |
| idIndex | string | 是 | id | 主表主键 |
| detailIDIndex | string | 是 | key | 明细主键 |
| examineCode | string | 是 | - | 审核接口 |
| cancelCode | string | 否 | - | 反审/取消接口 |
| recordSaveCode | string | 否 | - | 行保存接口（none/N 表示不保存） |
| uploadCode / signatureCode / uploadRecordCode | string | 否 | - | 上传/签章/上传记录接口 |
| batchAuditBtnFlag / batchIsChecked | string | 否 | N | 批量审核/勾选 Y/N |
| allQueryDetailFlag | string | 否 | N | 进入时同时拉主表+明细 Y/N |
| isShowDetailTable / isShowRightTable | string | 否 | Y | 显示明细/右侧表 Y/N |
| detailPaginationFlag | string | 否 | N | 明细分页 Y/N |
| hideMainPaginationFlag | string | 否 | N | 主表隐藏分页 Y/N |
| virtualFlag / detailVirtualFlag | string | 否 | N | 主表/明细虚拟列表 Y/N |
| inRowAllDataFlag | string | 否 | N | 批量操作传当前页全部行 Y/N |
| cancelReasonFlag | string | 否 | N | 取消需填原因 Y/N |
| postAuditStatusCode / postCancelStatus | string | 否 | - | 审核/取消后状态码 |
| exportCode / exportFollowQueryFlag / mainListERPExportCode | string | 否 | - | 导出、导出跟随查询区、主表 ERP 导出 |
| batchPrintCode / printCode / batchDownloadCode / downloadCode | string | 否 | - | 打印、下载相关接口 |
| loadTemplateFlag | string | 否 | N | 按模板加载打印 Y/N |
| orderQueryModalCode | string | 否 | - | 订单查询弹窗接口 |
| scanCodesComponentName | string | 否 | - | 扫码组件名 |
| isTabMenuFlag | string | 否 | N | Tab 菜单 Y/N |
| currentAuditStatus | string | 否 | - | 默认审核状态过滤（如 40） |

---

### 采购制单模板（InventoryManagement）专属参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| queryDetailCode | string | 否 | - | 明细查询（制单类常用） |
| saveCode / recordSaveCode | string | 否 | - | 保存/行保存接口 |
| detailIDIndex | string | 否 | id | 明细主键 |
| orderModalType | string | 否 | - | 订单弹窗类型 |
| assistModalTitle | string | 否 | 从订单选择 | 辅助制单弹窗标题 |
| assistComponentName | string | 否 | - | 辅助制单组件名 |
| assistModalDoNotDefaultHosp | string | 否 | N | 辅助制单不默认本院 Y/N |
| stateSpreadingFlag | string | 否 | N | 单据状态铺开展示 Y/N |
| stateSpreadingIndex | string | 否 | status | 状态字段 dataIndex |
| virtualFlag / detailVirtualFlag | string | 否 | N | 主表/明细虚拟列表 Y/N |
| detailInlineEditingFlag | string | 否 | N | 明细行内编辑 Y/N |
| preAuditStatusCode | string | 否 | 10 | 待审核状态码 |
| resubmitStatusCode | string | 否 | 40 | 可重新提交状态码 |
| operationType | string | 否 | - | 如 audit 表示审核态 |
| childMainComponentName / childDetailComponentName | string | 否 | - | 明细主子列表组件名（多级列表） |
| mainBatchPrintFlag / mainListExportCode / mainListERPExportCode / mainListGSPExportCode | string | 否 | - | 主表批量打印、导出、ERP、GSP |
| spCountDataIndex / rpCountDataIndex / qtyCountDataIndex | string | 否 | sp/rp/qty | 售价/进价/数量字段 |
| detailRecordRpAmt / detailRecordSpAmt | string | 否 | rpAmt/spAmt | 明细进价/售价金额字段 |
| hideViewDetails | string | 否 | N | 隐藏「查看申请进度」Y/N |

---

### 入库制单模板（NewVoucherPreparation）专属参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| baseComponentName | string | 否 | componentName+Base | 基本信息 01040073 组件名 |
| detailComponentName | string | 否 | componentName+Detail | 明细 01040073 组件名 |
| modalTableName | string | 否 | componentName+ModalTable | 弹窗表格组件名 |
| queryDetailCode | string | 否 | - | 明细查询 |
| saveCode | string | 是 | - | 保存接口 |
| detailDeleteCode | string | 否 | - | 明细删除 |
| revokeCode | string | 否 | - | 撤回/取消审核接口 |
| printCode | string | 否 | - | 打印接口 |
| scanningCode | string | 否 | 17030034 | 扫码接口 |
| stateSpreadingFlag | string | 否 | N | 单据状态铺开 Y/N |
| orderModalType | string | 否 | - | 订单弹窗类型 |
| auxiliaryFlag | string | 否 | - | 辅助制单类型（如 reviewed） |
| assistComponentName | string | 否 | - | 辅助制单组件名 |
| auxiliaryLocIDIndex | string | 否 | frLocID | 供给科室字段 |
| cardTitle / detailCardTitle | string | 否 | 主/明细 | 主列表、明细区标题 |
| addBtnFlag / printBtnFlag / entrySequenceBtnFlag | string | 否 | N | 显示新增/打印/录入顺序 Y/N |
| auxiliaryBtnFlag / auxiliaryBtnTitle | string | 否 | N | 辅助录单按钮及文案 |
| detailImportExcelBtnFlag / detailImportExcelCode | string | 否 | N | 明细导入按钮及接口 |
| totalAmountFlag / rpSumDesc / spSumDesc | string | 否 | - | 进销价总金额及文案 |
| auditBtnTitle / revokeBtnTitle / printBtnTitle | string | 否 | - | 提交审核/撤回/打印按钮文案 |
| scanningPlaceholder | string | 否 | 扫码添加 | 扫码输入框占位符 |
| operationFixedFlag | string | 否 | N | 操作列固定 Y/N |
| auxiliaryModalCode / auxiliaryModalWidth | string | 否 | - | 辅助制单查询码、宽度 |
| assistMainComponentName / assistChildComponentName | string | 否 | - | 辅助制单主/子组件名 |
| viewDetailsCode / viewDetailsComponentName / viewDetailsDetailComponentName | string | 否 | - | 查看详情接口与组件名 |

---

### 表单扩展维护（FormDataExtensionMaintenance）专属参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| getLinkComponentDataFlag | string | 否 | Y | 是否拉取关联组件数据 01040272，N 不拉 |
| associatedComponentPrefix | string | 否 | - | 关联组件别名前缀（01040272 alias） |
| addDataListSelectionFlag | string | 否 | N | 新增为列表选择样式 Y/N |
| leftCardCol | number | 否 | 10 | 左侧列表栅格 |
| leftCardDesc / rightCardDesc | string | 否 | 主列表/明细列表 | 左/右卡片标题 |
| componentNameForm | string | 否 | componentName+Form | 弹窗表单组件名 |
| modalWidth | string | 否 | 1000 | 弹窗宽度 |
| modalQueryCode / modalListComponentName | string | 否 | - | 弹窗查询接口、列表组件名 |
| modalDoNotAutoQueryFlag | string | 否 | N | 弹窗不自动查询 Y/N |
| modalListPaginationFlag / modalListMultipleFlag / modalListIDIndex | string | 否 | - | 弹窗分页/多选/主键 |
| editCode 为 none | - | - | - | 表示无编辑能力 |
| deleteCode 为 addDeleteFlag | - | - | - | 表示逻辑删除 |

---

### 富文本模板维护（WangEditorTemplateMaintenance）专属参数

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| saveDetailCode | string | 否 | - | 明细/详情保存接口（缺省用 editCode/addCode） |
| detailComponentName | string | 否 | - | 详情区 01040073 组件名 |
| addDataListSelectionFlag | string | 否 | N | 新增为列表选择 Y/N |
| leftCardCol | number | 否 | 8 | 左侧列表栅格 |
| leftCardDesc / rightCardDesc | string | 否 | 模板列表/模板内容维护 | 左/右卡片标题 |
| editorHeight | number | 否 | - | 富文本区域高度偏移（px） |
| componentNameForm | string | 否 | componentName+Form | 弹窗表单组件名 |
| modalWidth | string | 否 | 1000 | 弹窗宽度 |
| modalQueryCode / modalListComponentName | string | 否 | - | 弹窗查询、列表组件名 |
| modalDoNotAutoQueryFlag | string | 否 | N | 弹窗不自动查询 Y/N |
| groupType | string | 否 | H | H/G；Hosp/Group 用于展示 productDetails/supplementInfo |

---

## 模板选择决策树

```
开始选择模板
  │
  ├─ 是否需要主从表（父子关系）？
  │   ├─ 是 → ParentChildTableOperation
  │   └─ 否 →
  │
  ├─ 是否需要审核流程？
  │   ├─ 是 → OrderReviewComponent
  │   └─ 否 →
  │
  ├─ 是否需要制单（步骤条）？
  │   ├─ 是 → InventoryManagement / NewVoucherPreparation
  │   └─ 否 →
  │
  ├─ 是否需要左侧条件面板？
  │   ├─ 是 → LeftConditionRightList（列表）
  │   │         LeftConditionRightReports（报表）
  │   └─ 否 →
  │
  ├─ 是否需要表单扩展维护？
  │   ├─ 是 → FormDataExtensionMaintenance
  │   └─ 否 →
  │
  ├─ 是否需要富文本模板维护？
  │   ├─ 是 → WangEditorTemplateMaintenance
  │   └─ 否 →
  │
  └─ 默认 → SingleTableOperation
```

---

## 快速检查清单

配置动态组件前确认：

- [ ] 已确定合适的模板类型（参考上方模板选择决策树）
- [ ] 已准备后端查询接口（queryCode）及该模板所需的其他接口
- [ ] 已准备后端增删改等接口（按模板要求配置 addCode/editCode/deleteCode 等）
- [ ] 已在 01040073 配置列表表头数据（type='C'）；报表类配置 formData 作为查询条件
- [ ] 已在 01040073 配置弹窗表单数据（type='F'，componentName+Form 后缀，按需）
- [ ] 已按本文「配置参数说明」中对应模板的专属参数配置菜单 params
- [ ] 已配置菜单参数（params），注意主键、明细主键等必填项（如 idIndex、recordID、childRecordID、detailIDIndex 等）
- [ ] 已分配菜单权限和接口权限
