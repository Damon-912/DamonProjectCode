# 02 - DRG分组服务

> 服务类: src.DRG.Interface / src.DRG.GroupDevice

---

## 2.1 DRG分组器 (02010001)

> 接口Code: `02010001`
> 接口名称: DRG分组器
> 服务类: src.DRG.Interface
> 方法名: Device

### 入参

| 字段 | 类型 | 必填 | 说明 | 示例 |
|------|------|------|------|------|
| mainDiagnosisCode | String | **是** | 主诊断ICD-10编码 | "I21.0" |
| diseInfo | Array | 否 | 诊断信息数组 | 见下方 |
| mainOperationCode | String | 否 | 主手术ICD-9-CM-3编码 | "51.23" |
| oprnInfo | Array | 否 | 手术信息数组 | 见下方 |
| sex | String | 否 | 性别：1=男, 2=女 | "1" |
| age | Number | 否 | 年龄（岁） | 58 |
| ageGroupDays | Number | 否 | 新生儿出生天数（0-28） | 0 |
| newbornFlag | String | 否 | 新生儿标志：1=是, 0=否 | "0" |
| respiratorTime | Number | 否 | 呼吸机时长（小时），≥96h入MDCA | 0 |
| ecmoFlag | String | 否 | ECMO标志：1=是, 0=否 | "0" |
| transplantFlag | String | 否 | 器官移植标志：1=是, 0=否 | "0" |
| marrowTransplantFlag | String | 否 | 骨髓移植标志：1=是, 0=否 | "0" |
| hivFlag | String | 否 | HIV标志：1=是, 0=否 | "0" |
| traumaLevel | Number | 否 | 创伤等级（0-5），≥2入MDCZ | 0 |
| department | String | 否 | 科室 | "心内科" |
| dischargeType | String | 否 | 离院方式 | "" |
| hospitalDays | Number | 否 | 住院天数 | 10 |
| totalCost | Number | 否 | 总费用 | 24680.00 |
| weight | Number | 否 | 体重（新生儿用，克） | "" |
| medicalRecordId | String | 否 | 病案ID | "" |
| admissionNo | String | 否 | 住院号 | "" |

#### diseInfo 诊断信息数组

| 字段 | 类型 | 必填 | 说明 | 示例 |
|------|------|------|------|------|
| mainFlag | Number | 是 | 主诊断标志：1=主诊断, 0=其他 | 1 |
| diagSn | Number | 是 | 诊断序号 | 1 |
| diagCode | String | 是 | 诊断代码（ICD-10） | "I21.0" |
| diagName | String | 否 | 诊断名称 | "急性前壁心肌梗死" |

#### oprnInfo 手术信息数组

| 字段 | 类型 | 必填 | 说明 | 示例 |
|------|------|------|------|------|
| mainFlag | String | 是 | 主手术标志："1"=主手术 | "1" |
| oprnSn | Number | 是 | 手术序号 | 1 |
| oprnCode | String | 是 | 手术代码（ICD-9-CM-3） | "51.2300x001" |
| oprnName | String | 否 | 手术名称 | "腹腔镜胆囊切除术" |

### 出参

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| errorCode | String | 错误码 | "0" |
| errorMessage | String | 错误信息 | "" |
| result.code | String | DRG分组编码 | "FB13" |
| result.desc | String | DRG分组描述 | "急性心肌梗死，伴一般合并症与伴随病" |
| result.mdc | String | MDC编码 | "F" |
| result.mdcDesc | String | MDC描述 | "循环系统疾病" |
| result.adrg | String | ADRG编码 | "FB1" |
| result.adrgDesc | String | ADRG描述 | "急性心肌梗死" |
| result.drg | String | DRG编码 | "FB13" |
| result.drgDesc | String | DRG描述 | "急性心肌梗死，伴一般合并症与伴随病" |
| result.weight | Number | 权重 | 1.562 |
| result.benchmarkCost | Number | 基准费用 | 31240.00 |
| result.ccFlag | Boolean | 是否合并症 | true |
| result.mccFlag | Boolean | 是否严重合并症 | false |
| result.riskLevel | String | 风险等级 | "中" |
| result.checkTime | String | 分组时间 | "2026-03-19T14:30:25" |

### 请求示例

```json
{
  "code": "02010001",
  "params": [
    {
      "mainDiagnosisCode": "I21.0",
      "diseInfo": [
        { "mainFlag": 1, "diagSn": 1, "diagCode": "I21.0", "diagName": "急性前壁心肌梗死" },
        { "mainFlag": 0, "diagSn": 2, "diagCode": "I10", "diagName": "高血压病" },
        { "mainFlag": 0, "diagSn": 3, "diagCode": "E11.900x001", "diagName": "2型糖尿病" }
      ],
      "mainOperationCode": "51.23",
      "oprnInfo": [],
      "sex": "1",
      "age": 58,
      "ageGroupDays": 0,
      "newbornFlag": "0",
      "respiratorTime": 0,
      "ecmoFlag": "0",
      "transplantFlag": "0",
      "marrowTransplantFlag": "0",
      "hivFlag": "0",
      "traumaLevel": 0,
      "department": "心内科",
      "hospitalDays": 10,
      "totalCost": 24680.00
    }
  ],
  "session": [{ "userId": "158", "locId": 1, "groupId": "1", "hospId": "8" }]
}
```

### 响应示例（成功）

```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": {
    "code": "FB13",
    "desc": "急性心肌梗死，伴一般合并症与伴随病",
    "mdc": "F",
    "mdcDesc": "循环系统疾病",
    "adrg": "FB1",
    "adrgDesc": "急性心肌梗死",
    "drg": "FB13",
    "drgDesc": "急性心肌梗死，伴一般合并症与伴随病",
    "weight": 1.562,
    "benchmarkCost": 31240.00,
    "ccFlag": true,
    "mccFlag": false,
    "riskLevel": "中",
    "checkTime": "2026-03-19T14:30:25"
  }
}
```

### 响应示例（失败-无法入组）

```json
{
  "errorCode": "-1",
  "errorMessage": "进入分组流程前CheckRules校验失败：主诊断[Z76.5]存在CHS-DRG不作为分组规则的疾病诊断列表中，无法分组，请检查！",
  "result": {
    "code": "",
    "desc": "",
    "checkTime": "2026-03-19T14:34:00"
  }
}
```

### 先期分组规则

| 参数条件 | 先期分组 | 说明 |
|----------|----------|------|
| transplantFlag=1 | MDCA | 器官移植 |
| marrowTransplantFlag=1 | MDCA | 骨髓移植 |
| ecmoFlag=1 | MDCA | ECMO治疗 |
| respiratorTime ≥ 96 | MDCA | 呼吸机≥96小时 |
| ageGroupDays 1-28 | MDCP | 新生儿疾病 |
| hivFlag=1 | MDCY | HIV感染 |
| traumaLevel ≥ 2 | MDCZ | 多发严重创伤 |

---

## 2.2 保存分组记录 (02010035)

> 接口Code: `02010035`
> 接口名称: 保存DRG分组记录
> 方法名: SaveDRGGroupRecord

### 入参

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| medicalRecordId | String | 是 | 病案ID |
| drgCode | String | 是 | DRG编码 |
| drgName | String | 否 | DRG名称 |
| mdcCode | String | 否 | MDC编码 |
| adrgCode | String | 否 | ADRG编码 |
| weight | Number | 否 | 权重 |
| benchmarkCost | Number | 否 | 基准费用 |
| groupTime | String | 否 | 分组时间 |

### 出参

| 字段 | 类型 | 说明 |
|------|------|------|
| errorCode | String | 错误码 |
| errorMessage | String | 错误信息 |
| result.id | Number | 记录ID |

### 请求示例

```json
{
  "code": "02010035",
  "params": [{
    "medicalRecordId": "12345",
    "drgCode": "FB13",
    "drgName": "急性心肌梗死，伴一般合并症与伴随病",
    "mdcCode": "F",
    "adrgCode": "FB1",
    "weight": 1.562,
    "benchmarkCost": 31240.00,
    "groupTime": "2026-03-19T14:30:25"
  }]
}
```

### 响应示例

```json
{
  "errorCode": "0",
  "errorMessage": "保存成功",
  "result": { "id": 1001 }
}
```

---

## 2.3 查询分组记录 (02010036)

> 接口Code: `02010036`
> 接口名称: 查询DRG分组记录
> 方法名: QueryDRGGroupRecord

### 入参

| 字段 | 类型 | 必填 | 说明 | 示例 |
|------|------|------|------|------|
| medicalRecordId | String | 否 | 病案ID | "12345" |
| drgCode | String | 否 | DRG编码 | "FB13" |
| mdcCode | String | 否 | MDC编码 | "F" |
| startDate | String | 否 | 开始日期 | "2026-01-01" |
| endDate | String | 否 | 结束日期 | "2026-03-31" |
| page | Number | 否 | 页码，默认1 | 1 |
| limit | Number | 否 | 每页条数，默认20 | 20 |

### 出参

| 字段 | 类型 | 说明 |
|------|------|------|
| errorCode | String | 错误码 |
| errorMessage | String | 错误信息 |
| result.total | Number | 总记录数 |
| result.rows | Array | 记录列表 |

#### result.rows 每项字段

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Number | 记录ID |
| medicalRecordDr | String | 病案ID |
| hisAdmID | String | HIS就诊号 |
| drgCode | String | DRG编码 |
| drgName | String | DRG名称 |
| mdcCode | String | MDC编码 |
| adrgCode | String | ADRG编码 |
| weight | Number | 权重 |
| benchmarkCost | Number | 基准费用 |
| groupTime | String | 分组时间 |

### 请求示例

```json
{
  "code": "02010036",
  "params": [{
    "drgCode": "FB13",
    "startDate": "2026-01-01",
    "endDate": "2026-03-31",
    "page": 1,
    "limit": 20
  }]
}
```

### 响应示例

```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": {
    "total": 56,
    "rows": [
      {
        "id": 1001,
        "medicalRecordDr": "12345",
        "hisAdmID": "A20260301001",
        "drgCode": "FB13",
        "drgName": "急性心肌梗死，伴一般合并症与伴随病",
        "mdcCode": "F",
        "adrgCode": "FB1",
        "weight": 1.562,
        "benchmarkCost": 31240.00,
        "groupTime": "2026-03-19T14:30:25"
      }
    ]
  }
}
```
