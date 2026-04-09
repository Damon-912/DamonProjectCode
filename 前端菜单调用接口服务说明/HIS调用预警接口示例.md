# HIS调用预警接口示例

## 一、接口概述

### 预警服务类
- **后端类**: `src.DRG.Warning`
- **接口规范**: `020101xx`

### 接口列表

| 接口Code | 接口名称 | 用途 |
|----------|----------|------|
| 02010101 | 查询预警规则 | 获取启用的预警规则配置 |
| 02010102 | 保存预警规则 | 新增/修改预警规则 |
| 02010103 | 查询预警记录 | 查询预警记录列表 |
| 02010104 | 处理预警 | 确认或忽略预警 |
| 02010105 | 删除预警规则 | 删除预警规则 |
| 02010106 | 预警统计分析 | 获取预警统计数据 |
| 02010107 | **新增预警记录** | **HIS主动触发预警** |

---

## 二、HIS调用方式

### 通用请求格式
```json
POST /api/drg
Content-Type: application/json

{
  "code": "接口Code",
  "params": [参数列表],
  "session": {
    "userId": "用户ID"
  }
}
```

### 通用响应格式
```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": { ... },
  "total": 100
}
```

---

## 三、核心接口详解

### 3.1 新增预警记录 (02010107) - **HIS主要调用接口**

#### 功能说明
HIS系统调用此接口，传入患者就诊费用信息，系统自动匹配预警规则并生成预警记录。

#### 请求示例

**场景1：患者出院时触发预警**
```json
{
  "code": "02010107",
  "params": {
    "hisAdmId": "A20260301001",         // HIS就诊ID（必填）
    "patientName": "张三",               // 患者姓名（必填）
    "deptCode": "001",                  // 科室编码
    "deptName": "心内科",               // 科室名称
    "doctorCode": "D001",               // 医生编码
    "doctorName": "李医生",             // 医生姓名
    "totalFee": 45000.00,               // 医疗总费用（必填）
    "drgCode": "FB13",                  // DRG编码（必填）
    "drgPayStandard": 38000.00,         // DRG支付标准
    "drgName": "心脏介入治疗",           // DRG名称
    "medicalRecordDr": "",               // 病案ID
    "insuranceFee": 42000.00,           // 医保结算费用
    "fixmedinsCode": "H001",             // 医疗机构代码
    "fixmedinsName": "XX医院",          // 医疗机构名称
    "ruleType": ""                      // 指定预警类型（可选，不传则自动匹配）
  }
}
```

**场景2：实时费用累计预警（每日调用）**
```json
{
  "code": "02010107",
  "params": {
    "hisAdmId": "A20260301001",
    "patientName": "张三",
    "deptCode": "001",
    "deptName": "心内科",
    "doctorCode": "D001",
    "doctorName": "李医生",
    "totalFee": 28000.00,
    "drgCode": "FB13",
    "drgPayStandard": 38000.00,
    "drgName": "心脏介入治疗",
    "insuranceFee": 26000.00,
    "fixmedinsCode": "H001",
    "fixmedinsName": "XX医院"
  }
}
```

#### 响应示例
```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": [
    {
      "warningId": "123",
      "warningNo": "W20260328143000001",
      "ruleCode": "WR001",
      "ruleName": "费用超支预警",
      "warningLevel": 3,
      "warningMessage": "费用超支预警：患者费用总额45000.00元，DRG支付标准38000.00元，超出7000.00元（+18.42%）"
    }
  ],
  "count": 1
}
```

#### 必填入参说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| hisAdmId | String | **是** | HIS就诊ID |
| patientName | String | **是** | 患者姓名 |
| totalFee | Number | **是** | 医疗总费用 |
| drgCode | String | **是** | DRG编码 |

#### 可选入参说明

| 字段 | 类型 | 说明 |
|------|------|------|
| deptCode | String | 科室编码 |
| deptName | String | 科室名称 |
| doctorCode | String | 医生编码 |
| doctorName | String | 医生姓名 |
| drgPayStandard | Number | DRG支付标准 |
| drgName | String | DRG名称 |
| medicalRecordDr | String | 病案ID |
| insuranceFee | Number | 医保结算费用 |
| fixmedinsCode | String | 医疗机构代码 |
| fixmedinsName | String | 医疗机构名称 |
| ruleType | String | 指定预警类型（不传则自动匹配所有规则） |

---

### 3.2 查询预警规则 (02010101)

#### 功能说明
获取系统配置的预警规则列表，用于HIS端展示或前端配置。

#### 请求示例
```json
{
  "code": "02010101",
  "params": [
    "",           // ruleCode: 规则编码
    "",           // ruleName: 规则名称
    "01",         // ruleType: 规则类型
    "Y",          // isActive: 是否启用
    1,            // page: 页码
    20            // limit: 每页条数
  ]
}
```

#### 响应示例
```json
{
  "errorCode": "0",
  "errorMessage": "",
  "total": 6,
  "result": [
    {
      "id": "1",
      "ruleCode": "WR001",
      "ruleName": "费用超支预警",
      "ruleDesc": "费用超过DRG支付标准的设定比例",
      "ruleType": "01",
      "thresholdType": "percent",
      "thresholdValue": 120,
      "warningLevel": 3,
      "isActive": "Y",
      "seqNo": 1
    }
  ]
}
```

---

### 3.3 查询预警记录 (02010103)

#### 功能说明
查询预警记录列表，支持多条件筛选。

#### 请求示例
```json
{
  "code": "02010103",
  "params": [
    "",                    // warningNo: 预警流水号
    "",                    // ruleCode: 规则编码
    "",                    // warningType: 预警类型
    "pending",            // warningStatus: 待处理
    "2026-03-01",         // startDate: 开始日期
    "2026-03-31",         // endDate: 结束日期
    "",                    // deptCode: 科室编码
    "",                    // doctorCode: 医生编码
    "",                    // patientName: 患者姓名
    "",                    // hisAdmId: 就诊ID
    1,                     // page: 页码
    20                     // limit: 每页条数
  ]
}
```

#### 响应示例
```json
{
  "errorCode": "0",
  "errorMessage": "",
  "total": 23,
  "result": [
    {
      "id": "1",
      "warningNo": "W20260328143000001",
      "ruleCode": "WR001",
      "ruleName": "费用超支预警",
      "warningType": "01",
      "warningLevel": 3,
      "hisAdmId": "A20260301001",
      "patientName": "张三",
      "deptCode": "001",
      "deptName": "心内科",
      "doctorCode": "D001",
      "doctorName": "李医生",
      "drgCode": "FB13",
      "drgName": "心脏介入治疗",
      "totalFee": 45000.00,
      "drgPayStandard": 38000.00,
      "diffAmount": 7000.00,
      "diffRate": 18.42,
      "warningStatus": "待处理",
      "warningDate": "2026-03-28",
      "warningTime": "14:30:00"
    }
  ]
}
```

---

### 3.4 处理预警 (02010104)

#### 功能说明
医生确认或忽略预警记录。

#### 请求示例
```json
{
  "code": "02010104",
  "params": [
    "123",              // warningId: 预警记录ID
    "processed",        // processStatus: processed-已处理, ignored-已忽略
    "已与主治医生沟通，费用合理偏高"  // processRemark: 处理备注
  ]
}
```

#### 响应示例
```json
{
  "errorCode": "0",
  "errorMessage": "处理成功"
}
```

---

### 3.5 预警统计分析 (02010106)

#### 功能说明
获取预警统计数据。

#### 请求示例
```json
{
  "code": "02010106",
  "params": [
    "2026-03-01",       // startDate: 开始日期
    "2026-03-31"        // endDate: 结束日期
  ]
}
```

#### 响应示例
```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": {
    "totalCount": 234,
    "pendingCount": 56,
    "processedCount": 178,
    "typeStats": {
      "01": 120,
      "02": 68,
      "03": 46
    },
    "levelStats": {
      "high": 45,
      "medium": 130,
      "low": 59
    },
    "totalDiff": -45600,
    "totalFee": 1250000
  }
}
```

---

## 四、预警规则类型说明

| 规则类型 | 代码 | 说明 | 自动触发 |
|----------|------|------|----------|
| 费用超支 | 01 | 费用超过DRG支付标准的设定比例 | **支持** |
| 低倍率 | 02 | 费用低于DRG支付标准的设定比例 | **支持** |
| 高倍率 | 03 | 费用高于DRG支付标准的设定比例 | **支持** |
| 编码异常 | 04 | 诊断/手术编码存在逻辑异常 | 需额外判断 |
| 分解住院 | 05 | 疑似分解住院行为 | 需额外判断 |

---

## 五、HIS集成建议

### 5.1 集成时机

| 场景 | 调用时机 | 调用接口 |
|------|----------|----------|
| 患者出院结算 | 办理出院时 | 02010107 |
| 费用累计监控 | 每日费用更新时 | 02010107 |
| 医生工作站 | 登录时查询本科室预警 | 02010103 |

### 5.2 前端调用示例 (JavaScript)

```javascript
// 调用新增预警记录接口
async function callAddWarning() {
  const response = await fetch('/api/drg', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      code: '02010107',
      params: {
        hisAdmId: 'A20260301001',           // HIS就诊ID（必填）
        patientName: '张三',                 // 患者姓名（必填）
        deptCode: '001',                    // 科室编码
        deptName: '心内科',                  // 科室名称
        doctorCode: 'D001',                  // 医生编码
        doctorName: '李医生',                // 医生姓名
        totalFee: 45000.00,                  // 医疗总费用（必填）
        drgCode: 'FB13',                     // DRG编码（必填）
        drgPayStandard: 38000.00,            // DRG支付标准
        drgName: '心脏介入治疗',             // DRG名称
        medicalRecordDr: '',                 // 病案ID
        insuranceFee: 42000.00,              // 医保结算费用
        fixmedinsCode: 'H001',                // 医疗机构代码
        fixmedinsName: 'XX医院',             // 医疗机构名称
        ruleType: ''                         // 指定预警类型
      }
    })
  });
  
  const result = await response.json();
  
  if (result.errorCode === '0') {
    // 预警创建成功
    console.log('触发预警数量:', result.count);
    console.log('预警列表:', result.result);
    
    // 可选：向医生推送预警通知
    if (result.result && result.result.length > 0) {
      result.result.forEach(warning => {
        console.log(`预警: ${warning.ruleName}, 级别: ${warning.warningLevel}`);
      });
    }
  }
}
```

### 5.3 错误码说明

| 错误码 | 说明 | 处理建议 |
|--------|------|----------|
| 0 | 成功 | - |
| 1001 | 必填参数缺失 | 检查入参 |
| 1002 | 编码已存在 | 更换编码 |
| 1003 | 存在关联数据 | 先删除关联 |
| 2001 | 记录不存在 | 检查ID |
| 3001 | 操作失败 | 查看错误信息 |

---

## 六、注意事项

1. **hisAdmId** 必须唯一标识一次就诊，不可重复
2. **totalFee** 和 **drgPayStandard** 建议传入精确到分的金额
3. **ruleType** 为空时会自动匹配所有启用的规则
4. 返回的 **warningLevel**: 1=提示, 2=警告, 3=严重
5. 建议HIS端对严重预警(level=3)进行特殊提醒
