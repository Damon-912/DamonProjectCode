# DRG核心算法配置维护 - 设计文档

## 1. 页面路由

| 功能 | 路由路径 | 菜单编码 | 组件 |
|------|----------|----------|------|
| DRG核心算法配置维护 | `/basic-data/core-algorithm` | MENU035 | `BasicData/CoreAlgorithmConfig.tsx` |

## 2. 页面布局

### 2.1 主页面布局

```
┌──────────────────────────────────────────────────────────────┐
│  查询条件区域                                                   │
│  [DRG编码] [医疗机构名称] [省▼] [市▼] [状态▼ 全部/有效/无效]      │
│  [查询] [重置]                                                  │
├──────────────────────────────────────────────────────────────┤
│  [新增配置]                                      共N条记录       │
│  ┌──────┬────────┬──────┬──────┬──────┬──────┬──────┬────┐  │
│  │DRG   │DRG名称  │基准   │预估   │差异   │支付   │医疗  │状态│  │
│  │编码  │       │点数  │点值  │系数  │标准  │机构  │   │  │
│  ├──────┼────────┼──────┼──────┼──────┼──────┼──────┼────┤  │
│  │FB23  │心脏介入│2.56  │10500│1.15  │26880 │上海  │有效│  │
│  │ES23  │呼吸肿瘤│1.86  │10500│1.08  │19518 │上海  │有效│  │
│  └──────┴────────┴──────┴──────┴──────┴──────┴──────┴────┘  │
│  [< 1 2 3 ... >]                                               │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 新增/编辑弹窗

```
┌──────────────────────────────────────────────────────┐
│  新增DRG核心算法配置                            [×]    │
├──────────────────────────────────────────────────────┤
│  ┌─── DRG信息 ─────────────────────────────────────┐  │
│  │ DRG编码: [____]  DRG描述: [________]            │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  ┌─── 算法参数 ─────────────────────────────────────┐  │
│  │ 基准点数(Points): [________]                     │  │
│  │ 预估点值(PipValue): [________]                   │  │
│  │ 病组差异系数(DGDOV): [________]                  │  │
│  │ 支付标准(PayStandard): [________]                │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  ┌─── 机构与地区 ───────────────────────────────────┐  │
│  │ 省: [310000▼]  市: [310100▼]                    │  │
│  │ 险种: [________]  就医地区划代码: [________]      │  │
│  │ 医疗机构等级: [________]                         │  │
│  │ 医疗机构代码: [________]  名称: [________]        │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  ┌─── 有效期 ───────────────────────────────────────┐  │
│  │ 生效日期: [2026-01-01]  失效日期: [________]     │  │
│  │ 标识码: [________]  备注: [________]             │  │
│  └────────────────────────────────────────────────┘  │
│                              [取消] [确定]            │
└──────────────────────────────────────────────────────┘
```

## 3. 接口调用

### 3.1 查询配置列表 (02010033)

- **请求体**:
```json
{
  "code": "02010033",
  "params": [{
    "drg": "",
    "fixmedinsName": "",
    "fixmedinsCode": "",
    "cityID": "",
    "provinceID": "",
    "status": ""
  }, {
    "pageSize": 20,
    "currentPage": 1
  }]
}
```
- **响应体**:
```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": {
    "rows": [
      {
        "id": "1",
        "drg": "FB23",
        "drgDesc": "经皮冠状动脉介入治疗",
        "points": "2.56",
        "pipValue": "10500",
        "dgdov": "1.15",
        "payStandard": "26880",
        "insuType": "城镇职工",
        "mdtrtArea": "310100",
        "medinsLv": "三级",
        "provinceId": "310000",
        "provinceDesc": "上海市",
        "cityId": "310100",
        "cityDesc": "黄浦区",
        "startDate": "2026-01-01",
        "stopDate": "",
        "fixmedinsCode": "H0001",
        "fixmedinsName": "上海XX医院",
        "identification": "",
        "remark": "",
        "statusDesc": "有效"
      }
    ],
    "total": 500
  }
}
```

### 3.2 保存配置 (02010032)

- **请求体**:
```json
{
  "code": "02010032",
  "params": [{
    "id": "",
    "drg": "FB23",
    "drgDesc": "经皮冠状动脉介入治疗",
    "points": "2.56",
    "dgdov": "1.15",
    "payStandard": "26880",
    "insuType": "城镇职工",
    "mdtrtArea": "310100",
    "medinsLv": "三级",
    "fixmedinsCode": "H0001",
    "fixmedinsName": "上海XX医院",
    "provinceDr": "310000",
    "cityID": "310100",
    "startDate": "2026-01-01",
    "stopDate": "",
    "identification": "",
    "remark": ""
  }]
}
```
- **响应体**:
```json
{
  "errorCode": "0",
  "errorMessage": ""
}
```

### 3.3 删除配置 (02010034)

- **请求体**:
```json
{
  "code": "02010034",
  "params": [{ "id": "1" }]
}
```

## 4. 前端文件结构

```
frontend/src/
├── api/
│   └── basicData.ts               # 已存在，追加核心算法API
└── pages/
    └── BasicData/
        └── CoreAlgorithmConfig.tsx # 新增：DRG核心算法配置维护页面
```

## 5. API函数定义（追加到 basicData.ts）

```typescript
// ========== DRG核心算法配置 ==========

export interface CoreAlgorithmItem {
  id: string;
  drg: string;
  drgDesc: string;
  points: string;
  pipValue: string;
  dgdov: string;
  payStandard: string;
  insuType: string;
  mdtrtArea: string;
  medinsLv: string;
  provinceId: string;
  provinceDesc: string;
  cityId: string;
  cityDesc: string;
  startDate: string;
  stopDate: string;
  fixmedinsCode: string;
  fixmedinsName: string;
  identification: string;
  remark: string;
  statusDesc: string;
}

export interface SaveCoreAlgorithmParams {
  id?: string;
  drg: string;
  drgDesc: string;
  points: string;
  dgdov: string;
  payStandard: string;
  insuType: string;
  mdtrtArea: string;
  medinsLv: string;
  fixmedinsCode: string;
  fixmedinsName: string;
  provinceDr: string;
  cityID: string;
  startDate: string;
  stopDate: string;
  identification: string;
  remark: string;
}

export const queryCoreAlgorithm = (params, pagination): Promise<...>;  // 02010033
export const saveCoreAlgorithm = (params): Promise<...>;                // 02010032
export const deleteCoreAlgorithm = (id): Promise<...>;                  // 02010034
```

## 6. 字段映射（小驼峰）

| 数据库字段 | 前端字段 | 类型 |
|------------|----------|------|
| ID | id | string |
| DRG | drg | string |
| DRGDESC | drgDesc | string |
| Points | points | string |
| PipValue | pipValue | string |
| DGDOV | dgdov | string |
| PayStandard | payStandard | string |
| InsuType | insuType | string |
| MdtrtArea | mdtrtArea | string |
| MedinsLv | medinsLv | string |
| Province_Dr | provinceId | string |
| Province_Dr->Descripts | provinceDesc | string |
| City_Dr | cityId | string |
| City_Dr->Descripts | cityDesc | string |
| StartDate | startDate | string |
| StopDate | stopDate | string |
| FixmedinsCode | fixmedinsCode | string |
| FixmedinsName | fixmedinsName | string |
| CreateUser_Dr | createUserDr | string |
| CreateDate | createDate | string |
| CreateTime | createTime | string |
| Identification | identification | string |
| Remark | remark | string |
| (计算) | statusDesc | string |
