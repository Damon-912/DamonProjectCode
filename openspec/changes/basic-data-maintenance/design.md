# Design: DRG基础数据维护

## 1. 后端接口设计

### 服务类: src.BasicData.BasicData

```objectscript
Class src.BasicData.BasicData Extends %RegisteredObject
{
    /// 保存DRG基础数据 - Code: 02010010
    ClassMethod SaveBasicData(postObj As %Library.DynamicObject) As %Library.DynamicObject

    /// 查询DRG基础数据 - Code: 02010011
    ClassMethod QueryBasicData(postObj As %Library.DynamicObject) As %Library.DynamicObject

    /// 删除DRG基础数据 - Code: 02010012
    ClassMethod DeleteBasicData(postObj As %Library.DynamicObject) As %Library.DynamicObject

    /// 保存DRG基础数据明细 - Code: 02010013
    ClassMethod SaveBasicDataSub(postObj As %Library.DynamicObject) As %Library.DynamicObject

    /// 查询DRG基础数据明细 - Code: 02010014
    ClassMethod QueryBasicDataSub(postObj As %Library.DynamicObject) As %Library.DynamicObject

    /// 删除DRG基础数据明细 - Code: 02010015
    ClassMethod DeleteBasicDataSub(postObj As %Library.DynamicObject) As %Library.DynamicObject
}
```

---

## 2. 接口详细设计

### 2.1 保存DRG基础数据 (02010010)

**入参:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | 否 | 主表ID（为空=新增，非空=修改） |
| insuCode | String | **是** | 代码 |
| insuDesc | String | **是** | 描述 |
| provinceDr | String | **是** | 省ID |
| cityDr | String | **是** | 市ID |
| areaDr | String | 否 | 区ID |
| startDate | String | **是** | 生效日期(YYYY-MM-DD) |
| stopDate | String | 否 | 失效日期(YYYY-MM-DD) |
| identification | String | 否 | 标识码 |
| remark | String | 否 | 备注 |

**出参:**

```json
{
  "errorCode": "0",
  "errorMessage": "保存成功",
  "result": { "id": 1001 }
}
```

**请求示例:**

```json
{
  "code": "02010010",
  "params": [{
    "id": "",
    "insuCode": "DRG_VERSION_2024",
    "insuDesc": "CHS-DRG 2.0版本",
    "provinceDr": "1",
    "cityDr": "1",
    "areaDr": "1",
    "startDate": "2024-01-01",
    "identification": "DRG_VERSION",
    "remark": "国家医保版CHS-DRG 2.0分组方案"
  }]
}
```

---

### 2.2 查询DRG基础数据 (02010011)

**入参:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| insuCode | String | 否 | 代码（模糊搜索） |
| insuDesc | String | 否 | 描述（模糊搜索） |
| provinceDr | String | 否 | 省ID |
| cityDr | String | 否 | 市ID |
| identification | String | 否 | 标识码 |
| isActive | String | 否 | 有效状态(Y=有效) |
| page | Number | 否 | 页码，默认1 |
| limit | Number | 否 | 每页条数，默认20 |

**出参:**

```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": {
    "total": 50,
    "rows": [
      {
        "id": "1001",
        "insuCode": "DRG_VERSION_2024",
        "insuDesc": "CHS-DRG 2.0版本",
        "provinceDr": "1",
        "provinceName": "北京市",
        "cityDr": "1",
        "cityName": "北京市",
        "areaDr": "1",
        "areaName": "东城区",
        "startDate": "2024-01-01",
        "stopDate": "",
        "createDate": "2024-01-01",
        "createTime": "10:00:00",
        "identification": "DRG_VERSION",
        "remark": "国家医保版CHS-DRG 2.0分组方案"
      }
    ]
  }
}
```

---

### 2.3 删除DRG基础数据 (02010012)

**入参:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | **是** | 主表ID |

**出参:**

```json
{
  "errorCode": "0",
  "errorMessage": "删除成功",
  "result": {}
}
```

**说明:** 级联删除HB_DRGBasicDataSub中对应的明细记录。

---

### 2.4 保存DRG基础数据明细 (02010013)

**入参:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | 否 | 明细ID（为空=新增，非空=修改） |
| hbDictionariesDr | String | **是** | 所属主表ID |
| code | String | **是** | 代码 |
| descripts | String | **是** | 描述 |
| identification | String | 否 | 标识码 |
| startDate | String | **是** | 生效日期(YYYY-MM-DD) |
| stopDate | String | 否 | 失效日期(YYYY-MM-DD) |
| remark | String | 否 | 备注 |

**出参:**

```json
{
  "errorCode": "0",
  "errorMessage": "保存成功",
  "result": { "id": 2001 }
}
```

**请求示例:**

```json
{
  "code": "02010013",
  "params": [{
    "hbDictionariesDr": "1001",
    "code": "MDCA",
    "descripts": "先期分组-器官移植、骨髓移植、ECMO等",
    "identification": "MDC_TYPE",
    "startDate": "2024-01-01",
    "remark": "MDCA先期分组分类"
  }]
}
```

---

### 2.5 查询DRG基础数据明细 (02010014)

**入参:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| hbDictionariesDr | String | **是** | 所属主表ID |
| code | String | 否 | 代码（模糊搜索） |
| identification | String | 否 | 标识码 |
| isActive | String | 否 | 有效状态(Y=有效) |
| page | Number | 否 | 页码，默认1 |
| limit | Number | 否 | 每页条数，默认20 |

**出参:**

```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": {
    "total": 38,
    "rows": [
      {
        "id": "2001",
        "hbDictionariesDr": "1001",
        "code": "MDCA",
        "descripts": "先期分组-器官移植、骨髓移植、ECMO等",
        "identification": "MDC_TYPE",
        "startDate": "2024-01-01",
        "stopDate": "",
        "createDate": "2024-01-01",
        "createTime": "10:00:00",
        "remark": "MDCA先期分组分类"
      }
    ]
  }
}
```

---

### 2.6 删除DRG基础数据明细 (02010015)

**入参:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | **是** | 明细ID |

**出参:**

```json
{
  "errorCode": "0",
  "errorMessage": "删除成功",
  "result": {}
}
```

---

## 3. 前端页面设计

### 3.1 页面布局

采用 **主从表(Master-Detail)** 布局：

```
┌─────────────────────────────────────────────────────────┐
│ 搜索条件: [代码] [描述] [标识码] [省份▼] [城市▼] [查询] [重置] │
├─────────────────────────────────────────────────────────┤
│ DRG基础数据列表                                    [新增] │
│ ┌──────┬──────────────┬──────┬──────┬──────┬─────────────┐│
│ │ 代码 │ 描述         │ 省   │ 市   │ 状态 │ 操作        ││
│ ├──────┼──────────────┼──────┼──────┼──────┼─────────────┤│
│ │ V001 │ CHS-DRG 2.0 │ 北京 │ 北京 │ 有效 │ 编辑 | 删除 ││
│ │ V002 │ ...          │ ...  │ ...  │ 失效 │ 编辑 | 删除 ││
│ └──────┴──────────────┴──────┴──────┴──────┴─────────────┘│
│                                                    共X条│
├─────────────────────────────────────────────────────────┤
│ 明细数据 (选中: CHS-DRG 2.0)                    [新增明细] │
│ ┌──────┬──────────────────────┬──────────┬─────────────┐│
│ │ 代码 │ 描述               │ 标识码   │ 操作        ││
│ ├──────┼──────────────────────┼──────────┼─────────────┤│
│ │ MDCA │ 先期分组-器官移植   │ MDC_TYPE │ 编辑 | 删除 ││
│ │ MDCP │ 围产期新生儿疾病   │ MDC_TYPE │ 编辑 | 删除 ││
│ └──────┴──────────────────────┴──────────┴─────────────┘│
│                                                    共X条│
└─────────────────────────────────────────────────────────┘
```

### 3.2 交互流程

1. 页面加载 → 自动查询主表列表
2. 点击主表行 → 加载该行对应的明细列表
3. 新增主表 → 弹出表单对话框 → 填写保存 → 刷新列表
4. 编辑主表 → 弹出预填表单对话框 → 修改保存 → 刷新列表
5. 删除主表 → 二次确认 → 删除(级联明细) → 刷新列表
6. 新增明细 → 弹出表单对话框 → 填写保存 → 刷新明细列表
7. 编辑明细 → 弹出预填表单对话框 → 修改保存 → 刷新明细列表
8. 删除明细 → 二次确认 → 删除 → 刷新明细列表

### 3.3 API封装 (frontend/src/api/basicData.ts)

```typescript
import { invoke } from './request';

// 保存DRG基础数据
export const saveBasicData = (params: any) => invoke('02010010', [params]);

// 查询DRG基础数据
export const queryBasicData = (params: any) => invoke('02010011', [params]);

// 删除DRG基础数据
export const deleteBasicData = (params: any) => invoke('02010012', [params]);

// 保存DRG基础数据明细
export const saveBasicDataSub = (params: any) => invoke('02010013', [params]);

// 查询DRG基础数据明细
export const queryBasicDataSub = (params: any) => invoke('02010014', [params]);

// 删除DRG基础数据明细
export const deleteBasicDataSub = (params: any) => invoke('02010015', [params]);
```
