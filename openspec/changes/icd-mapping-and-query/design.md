# ICD编码映射与ICD编码查询 - 设计文档

## 1. 页面路由

| 功能 | 路由路径 | 菜单编码 | 组件 |
|------|----------|----------|------|
| ICD编码映射 | `/basic-data/icd-mapping` | MENU032 | `BasicData/ICDMapping.tsx` |
| ICD编码查询 | `/basic-data/icd-query` | MENU033 | `BasicData/ICDQuery.tsx` |

## 2. ICD编码映射页面设计

### 2.1 布局结构

```
┌─────────────────────────────────────────────────┐
│  查询条件区域                                      │
│  [版本号▼] [省▼] [市▼] [地方ICD代码] [地方ICD描述]    │
│  [医保ICD代码] [医保ICD描述]  [查询] [重置]          │
├─────────────────────────────────────────────────┤
│  [新增映射] [批量删除]                    共N条记录    │
│  ┌───┬──────┬────────┬──────┬────────┬───┬───┐   │
│  │ ☐ │地方ICD│地方ICD  │医保ICD│医保ICD  │操作│   │
│  │   │ 代码  │  描述   │ 代码  │  描述   │   │   │
│  ├───┼──────┼────────┼──────┼────────┼───┼───┤   │
│  │ ☐ │A01.1 │xxx疾病  │A01.0 │xxx疾病  │编辑│   │
│  │ ☐ │B02.3 │xxx疾病  │B02.1 │xxx疾病  │删除│   │
│  └───┴──────┴────────┴──────┴────────┴───┴───┘   │
│  [< 1 2 3 ... >]                                  │
└─────────────────────────────────────────────────┘
```

### 2.2 新增/编辑映射 - 弹窗

```
┌──────────────────────────────────────────┐
│  新增ICD编码映射                    [×]   │
├──────────────────────────────────────────┤
│  ICD版本号：  [ICD-9 ▼] / [ICD-10 ▼]     │
│  省：         [上海市▼]                    │
│  市：         [全市▼]                      │
│                                          │
│  ┌─── 地方ICD编码 ──────┐ ┌─── 医保ICD编码 ────┐ │
│  │ 代码：[________]      │ │ 代码：[________]    │ │
│  │ 描述：[________]      │ │ 描述：[________]    │ │
│  │ [从ICD库选择...]      │ │ [从医保库选择...]    │ │
│  └──────────────────────┘ └─────────────────────┘ │
│                                          │
│  备注：[________________]                │
│                          [取消] [确定]    │
└──────────────────────────────────────────┘
```

### 2.3 接口调用

#### 查询映射关系 (02010023 - Query)
- **URL**: `POST /drg/interface`
- **请求体**:
```json
{
  "interfaceCode": "02010023",
  "params": [{
    "versionNo": "ICD-10",
    "provinceId": "310000",
    "cityId": "310100",
    "code": "",
    "descripts": "",
    "icd": "",
    "icdDesc": ""
  }],
  "pagination": [{
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
        "code": "A01.1",
        "descripts": "伤寒",
        "icd": "A01.0",
        "icdDesc": "伤寒性发热",
        "provinceId": "310000",
        "provinceDesc": "上海市",
        "cityId": "310100",
        "cityDesc": "黄浦区",
        "versionNo": "ICD-10",
        "updateDate": "2026-03-20",
        "updateTime": "14:30:00",
        "updateUserDr": "1",
        "updateUserDesc": "管理员",
        "identification": "",
        "remark": ""
      }
    ],
    "total": 100
  }
}
```

#### 保存映射关系 (02010023 - Save)
- **请求体**:
```json
{
  "interfaceCode": "02010023",
  "params": [{
    "id": "",
    "versionNo": "ICD-10",
    "leftInfo": {
      "code": "A01.1",
      "desc": "伤寒",
      "provinceId": "310000",
      "cityId": "310100"
    },
    "rightInfo": {
      "code": "A01.0",
      "desc": "伤寒性发热"
    }
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

#### 删除映射关系 (02010023 - Delete)
- **请求体**:
```json
{
  "interfaceCode": "02010023",
  "params": [{
    "id": "1"
  }]
}
```

#### 查询医保ICD编码 (02010022) - 用于映射弹窗右侧选择
- **请求体**:
```json
{
  "interfaceCode": "02010022",
  "params": [{
    "versionNo": "ICD-10",
    "provinceId": "310000",
    "cityId": "310100",
    "code": "",
    "desc": "",
    "status": "Y"
  }],
  "pagination": [{
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
        "dictId": "10",
        "code": "A01.0",
        "desc": "伤寒性发热",
        "startDate": "2026-01-01",
        "stopDate": "",
        "provinceId": "310000",
        "provinceDesc": "上海市",
        "cityId": "310100",
        "cityDesc": "黄浦区",
        "identification": "",
        "statusDesc": "有效"
      }
    ],
    "total": 500
  }
}
```

## 3. ICD编码查询页面设计

### 3.1 布局结构

```
┌─────────────────────────────────────────────────┐
│  查询条件区域                                      │
│  [版本▼ ICD-9/ICD-10] [省▼] [市▼]                  │
│  [ICD代码] [ICD描述] [状态▼ 全部/有效/无效]           │
│  [查询] [重置]                                     │
├─────────────────────────────────────────────────┤
│  [导出]                              共N条记录      │
│  ┌──────┬────────┬──────┬──────┬──────┬────┬──┐  │
│  │ICD代码│ICD描述  │版本号  │省市   │生效日期│状态│  │
│  ├──────┼────────┼──────┼──────┼──────┼────┼──┤  │
│  │A01.0 │伤寒发热 │ICD-10│上海  │01-01 │有效│  │
│  │B02.1 │带状疱疹 │ICD-10│上海  │01-01 │有效│  │
│  └──────┴────────┴──────┴──────┴──────┴────┴──┘  │
│  [< 1 2 3 ... >]                                  │
└─────────────────────────────────────────────────┘
```

### 3.2 接口调用

#### 查询ICD编码信息 (02010037)
- **URL**: `POST /drg/interface`
- **请求体**:
```json
{
  "interfaceCode": "02010037",
  "params": [{
    "version": "ICD-10",
    "provinceId": "310000",
    "cityId": "310100",
    "code": "",
    "desc": "",
    "status": "Y"
  }],
  "pagination": [{
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
        "code": "A01.0",
        "desc": "伤寒性发热",
        "version": "ICD-10",
        "startDate": "2026-01-01",
        "stopDate": "",
        "provinceId": "310000",
        "provinceDesc": "上海市",
        "cityId": "310100",
        "cityDesc": "黄浦区",
        "statusDesc": "有效"
      }
    ],
    "total": 2000
  }
}
```

## 4. 前端文件结构

```
frontend/src/
├── api/
│   └── basicData.ts          # 基础数据管理API（新增ICD相关接口）
├── pages/
│   └── BasicData/
│       ├── ICDMapping.tsx     # ICD编码映射页面
│       └── ICDQuery.tsx       # ICD编码查询页面
└── App.tsx                    # 路由注册（已在add-basic-data-management中添加）
```

## 5. API函数定义

```typescript
// frontend/src/api/basicData.ts

// ========== ICD编码映射 ==========

/** 查询ICD编码映射关系 */
export function queryIcdMapping(params: {
  versionNo?: string;
  provinceId?: string;
  cityId?: string;
  code?: string;
  descripts?: string;
  icd?: string;
  icdDesc?: string;
}, pagination: { pageSize: number; currentPage: number }): Promise<ApiResult>;

/** 保存ICD编码映射关系 */
export function saveIcdMapping(params: {
  id?: string;
  versionNo: string;
  leftInfo: { code: string; desc: string; provinceId: string; cityId: string };
  rightInfo: { code: string; desc: string };
}): Promise<ApiResult>;

/** 删除ICD编码映射关系 */
export function deleteIcdMapping(id: string): Promise<ApiResult>;

/** 查询医保ICD编码信息（映射选择用） */
export function queryMedInsuIcdInfo(params: {
  versionNo: string;
  provinceId: string;
  cityId: string;
  code?: string;
  desc?: string;
  status?: string;
}, pagination: { pageSize: number; currentPage: number }): Promise<ApiResult>;

// ========== ICD编码查询 ==========

/** 查询各地方版本ICD编码信息 */
export function queryIcdInfo(params: {
  version: string;
  provinceId: string;
  cityId: string;
  code?: string;
  desc?: string;
  status?: string;
}, pagination: { pageSize: number; currentPage: number }): Promise<ApiResult>;
```

## 6. 字段映射（小驼峰）

### HB_DRGICDVersionMapping 表字段映射

| 数据库字段 | 前端字段（小驼峰） | 类型 |
|------------|-------------------|------|
| ID | id | string |
| Code | code | string |
| Descripts | descripts | string |
| ICD | icd | string |
| ICDDesc | icdDesc | string |
| VersionNo | versionNo | string |
| Province_Dr | provinceId | string |
| Province_Dr->Descripts | provinceDesc | string |
| City_Dr | cityId | string |
| City_Dr->Descripts | cityDesc | string |
| UpdateDate | updateDate | string |
| UpdateTime | updateTime | string |
| UpdateUser_Dr | updateUserDr | string |
| UpdateUser_Dr->Descripts | updateUserDesc | string |
| Identification | identification | string |
| Remark | remark | string |

### BS_DRGICDInfo 表字段映射

| 数据库字段 | 前端字段（小驼峰） | 类型 |
|------------|-------------------|------|
| ID | id | string |
| Code | code | string |
| Desc | desc | string |
| Version | version | string |
| Province_Dr | provinceId | string |
| Province_Dr->Descripts | provinceDesc | string |
| City_Dr | cityId | string |
| City_Dr->Descripts | cityDesc | string |
| StartDate | startDate | string |
| StopDate | stopDate | string |
| CreateDate | createDate | string |
| CreateTime | createTime | string |
| CreateUser_Dr | createUserDr | string |
| CreateUser_Dr->Descripts | createUserDesc | string |
| Remark | remark | string |
| (计算) | statusDesc | string |
