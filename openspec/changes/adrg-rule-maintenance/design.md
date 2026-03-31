# ADRG分组规则维护 - 设计文档

## 1. 页面路由

| 功能 | 路由路径 | 菜单编码 | 组件 |
|------|----------|----------|------|
| ADRG分组规则维护 | `/basic-data/adrg-rules` | MENU034 | `BasicData/ADRGRuleMaintenance.tsx` |

## 2. 页面布局

### 2.1 主页面布局

```
┌─────────────────────────────────────────────────────┐
│  查询条件区域                                         │
│  [ADRG名称] [状态▼ 全部/有效/无效]  [查询] [重置]       │
├─────────────────────────────────────────────────────┤
│  [新增规则]                              共N条记录     │
│  ┌──────┬──────────┬──────────┬──────────┬────┬────┐ │
│  │ADRG  │ADRG名称   │主要诊断   │主要手术   │联合│状态│ │
│  │代码  │          │          │          │标志│   │ │
│  ├──────┼──────────┼──────────┼──────────┼────┼────┤ │
│  │ FB1  │心脏介入  │I21.0    │36.07    │否 │有效│ │
│  │  ▼ 展开行                                          │
│  │    其他诊断: I10.0 高血压                          │
│  │    其他手术: 88.56 冠脉造影                        │
│  │    第三诊断: E11.9 糖尿病                          │
│  │    第三手术: -                                    │
│  │    入组条件: 包含以下主要手术或操作                 │
│  │    省: 上海市  市: 黄浦区                          │
│  │    生效: 2026-01-01  失效: -                      │
│  ├──────┼──────────┼──────────┼──────────┼────┼────┤ │
│  │ ES1  │呼吸系统  │J18.9    │-        │否 │有效│ │
│  └──────┴──────────┴──────────┴──────────┴────┴────┘ │
│  [< 1 2 3 ... >]                                     │
└─────────────────────────────────────────────────────┘
```

### 2.2 新增/编辑规则 - 弹窗

```
┌──────────────────────────────────────────────────────┐
│  新增ADRG分组规则                              [×]    │
├──────────────────────────────────────────────────────┤
│  ┌─── 基本信息 ────────────────────────────────────┐  │
│  │ ADRG代码: [____]  ADRG名称: [________]          │  │
│  │ 联合标志: [○否 ●是]  入组条件: [________]       │  │
│  │ 省: [310000▼]  市: [310100▼]                    │  │
│  │ 生效日期: [2026-01-01]  失效日期: [________]     │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  ┌─── 诊断信息 ────────────────────────────────────┐  │
│  │ 主要诊断编码: [________]  名称: [________]       │  │
│  │ 其他诊断编码: [________]  名称: [________]       │  │
│  │ 第三诊断编码: [________]  名称: [________]       │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  ┌─── 手术/操作信息 ───────────────────────────────┐  │
│  │ 主要手术编码: [________]  名称: [________]       │  │
│  │ 其他手术编码: [________]  名称: [________]       │  │
│  │ 第三手术编码: [________]  名称: [________]       │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│                              [取消] [确定]            │
└──────────────────────────────────────────────────────┘
```

## 3. 接口调用

### 3.1 查询规则列表 (02010017)

- **URL**: `POST /api/invoke`
- **请求体**:
```json
{
  "code": "02010017",
  "params": [{
    "adrgDesc": "",
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
        "adrg": "FB1",
        "adrgDesc": "心脏介入治疗",
        "principalDiagnosis": "I21.0",
        "principalDiagnosisName": "急性心肌梗死",
        "secondaryDiagnosis": "I10.0",
        "secondaryDiagnosisName": "高血压",
        "thirdlyDiagnosis": "E11.9",
        "thirdlyDiagnosisName": "2型糖尿病",
        "majorProcedure": "36.07",
        "majorProcedureName": "冠状动脉支架置入",
        "secondaryProcedure": "88.56",
        "secondaryProcedureName": "冠状动脉造影",
        "thirdlyProcedure": "",
        "thirdlyProcedureName": "",
        "unionFlag": "0",
        "selectionCriteria": "包含以下主要手术或操作",
        "provinceId": "310000",
        "provinceDesc": "上海市",
        "cityId": "310100",
        "cityDesc": "黄浦区",
        "startDate": "2026-01-01",
        "stopDate": "",
        "statusDesc": "有效"
      }
    ],
    "total": 500
  }
}
```

### 3.2 保存规则 (02010016)

- **请求体**:
```json
{
  "code": "02010016",
  "params": [{
    "id": "",
    "adrg": "FB1",
    "adrgDesc": "心脏介入治疗",
    "principalDiagnosis": "I21.0",
    "principalDiagnosisName": "急性心肌梗死",
    "secondaryDiagnosis": "I10.0",
    "secondaryDiagnosisName": "高血压",
    "thirdlyDiagnosis": "",
    "thirdlyDiagnosisName": "",
    "majorProcedure": "36.07",
    "majorProcedureName": "冠状动脉支架置入",
    "secondaryProcedure": "88.56",
    "secondaryProcedureName": "冠状动脉造影",
    "thirdlyProcedure": "",
    "thirdlyProcedureName": "",
    "unionFlag": "0",
    "selectionCriteria": "包含以下主要手术或操作",
    "provinceId": "310000",
    "cityId": "310100",
    "startDate": "2026-01-01",
    "stopDate": ""
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

### 3.3 删除规则 (02010018)

- **请求体**:
```json
{
  "code": "02010018",
  "params": [{
    "id": "1"
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

## 4. 前端文件结构

```
frontend/src/
├── api/
│   └── basicData.ts              # 已存在，新增ADRG规则API函数
└── pages/
    └── BasicData/
        └── ADRGRuleMaintenance.tsx # ADRG分组规则维护页面
```

## 5. API函数定义（追加到 basicData.ts）

```typescript
// ========== ADRG分组规则维护 ==========

/** ADRG规则记录 */
export interface AdrgRuleItem {
  id: string;
  adrg: string;
  adrgDesc: string;
  principalDiagnosis: string;
  principalDiagnosisName: string;
  secondaryDiagnosis: string;
  secondaryDiagnosisName: string;
  thirdlyDiagnosis: string;
  thirdlyDiagnosisName: string;
  majorProcedure: string;
  majorProcedureName: string;
  secondaryProcedure: string;
  secondaryProcedureName: string;
  thirdlyProcedure: string;
  thirdlyProcedureName: string;
  unionFlag: string;
  selectionCriteria: string;
  provinceId: string;
  provinceDesc: string;
  cityId: string;
  cityDesc: string;
  startDate: string;
  stopDate: string;
  statusDesc: string;
}

/** 查询ADRG规则列表 (02010017) */
export const queryAdrgRules = (
  params: { adrgDesc?: string; status?: string },
  pagination: Pagination
): Promise<ApiResponse<PageResult<AdrgRuleItem>>>;

/** 保存ADRG规则 (02010016) */
export const saveAdrgRule = (params: SaveAdrgRuleParams): Promise<ApiResponse>;

/** 删除ADRG规则 (02010018) */
export const deleteAdrgRule = (id: string): Promise<ApiResponse>;
```

## 6. 字段映射（小驼峰）

### CB_DRGCoreGroupsList 表字段映射

| 数据库字段 | 前端字段（小驼峰） | 类型 |
|------------|-------------------|------|
| ID | id | string |
| ADRG | adrg | string |
| ADRGDesc | adrgDesc | string |
| PrincipalDiagnosis | principalDiagnosis | string |
| PrincipalDiagnosisName | principalDiagnosisName | string |
| SecondaryDiagnosis | secondaryDiagnosis | string |
| SecondaryDiagnosisName | secondaryDiagnosisName | string |
| ThirdlyDiagnosis | thirdlyDiagnosis | string |
| ThirdlyDiagnosisName | thirdlyDiagnosisName | string |
| MajorProcedure | majorProcedure | string |
| MajorProcedureName | majorProcedureName | string |
| SecondaryProcedure | secondaryProcedure | string |
| SecondaryProcedureName | secondaryProcedureName | string |
| ThirdlyProcedure | thirdlyProcedure | string |
| ThirdlyProcedureName | thirdlyProcedureName | string |
| SelectionCriteria | selectionCriteria | string |
| UnionFlag | unionFlag | string |
| Province_Dr | provinceId | string |
| Province_Dr->Descripts | provinceDesc | string |
| City_Dr | cityId | string |
| City_Dr->Descripts | cityDesc | string |
| StartDate | startDate | string |
| StopDate | stopDate | string |
| CreateDate | createDate | string |
| CreateTime | createTime | string |
| CreateUser_Dr | createUserDr | string |
| (计算) | statusDesc | string |
