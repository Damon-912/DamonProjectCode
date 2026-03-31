# ICD编码导入接口配置说明

## 接口清单

| 接口编码 | 接口名称 | 类名 | 方法名 | 说明 |
|---------|---------|------|--------|------|
| 02010038 | ICD编码导入预览 | src.DRG.BasicData.ICDInfo | PreviewImportICD | 预览导入数据，校验并返回重复数据标记 |
| 02010039 | ICD编码确认导入 | src.DRG.BasicData.ICDInfo | ConfirmImportICD | 执行实际的导入操作 |
| 02010040 | 下载ICD导入模板 | src.DRG.BasicData.ICDInfo | DownloadImportTemplate | 下载CSV格式导入模板 |

## 接口详细说明

### 1. 下载导入模板 (02010040)

**功能**：提供ICD编码导入的CSV模板文件下载

**输入参数**：无

**输出结果**：
```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": {
    "fileName": "ICD编码导入模板.csv",
    "fileData": "Base64编码的文件内容",
    "contentType": "text/csv"
  }
}
```

**模板格式**：
- 表头：ICD代码,ICD描述,版本,生效日期,失效日期,备注
- 示例数据已包含在模板中

---

### 2. ICD编码导入预览 (02010038)

**功能**：校验导入文件数据，标记重复数据和错误数据

**输入参数**：
```json
{
  "params": [{
    "provinceID": "省ID",
    "cityID": "市ID",
    "fileData": "Base64编码的CSV文件内容",
    "fileName": "文件名"
  }]
}
```

**输出结果**：
```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": {
    "totalCount": 150,
    "validCount": 100,
    "invalidCount": 2,
    "duplicateCount": 48,
    "previewList": [
      {
        "rowNum": 1,
        "code": "A01.001",
        "desc": "伤寒",
        "version": "ICD-10",
        "startDate": "2024-01-01",
        "stopDate": "2099-12-31",
        "remark": "备注",
        "status": "valid/duplicate/invalid",
        "statusDesc": "正常/重复/错误",
        "errorMsg": "错误信息（如有）"
      }
    ]
  }
}
```

**状态说明**：
- `valid`：正常数据，可导入
- `duplicate`：重复数据（ICD代码+省市已存在），将执行更新
- `invalid`：异常数据（必填字段为空等），将跳过

---

### 3. ICD编码确认导入 (02010039)

**功能**：执行实际的导入操作，新增或更新ICD编码数据

**输入参数**：
```json
{
  "params": [{
    "provinceID": "省ID",
    "cityID": "市ID",
    "fileData": "Base64编码的CSV文件内容",
    "fileName": "文件名"
  }],
  "session": [{
    "userID": "当前用户ID"
  }]
}
```

**输出结果**：
```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": {
    "totalCount": 150,
    "successCount": 148,
    "failCount": 2,
    "duplicateCount": 48,
    "newCount": 100,
    "failList": [
      {
        "rowNum": 10,
        "code": "A01.010",
        "errorMsg": "必填字段为空"
      }
    ]
  }
}
```

**数据处理逻辑**：
1. 正常数据：执行新增操作
2. 重复数据（ICD代码+省市已存在）：执行更新操作
3. 异常数据：跳过，记录到failList

---

## 数据库表结构

**目标表**：`User.BSDRGICDInfo` (SQL: `SQLUser.BS_DRGICDInfo`)

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| Code | %String | 是 | ICD代码 |
| Desc | %String | 是 | ICD描述 |
| Version | %String | 否 | 版本（ICD-9/ICD-10） |
| Province_Dr | CBProvince | 是 | 省（外键） |
| City_Dr | CBCity | 是 | 市（外键） |
| StartDate | %Date | 是 | 生效日期 |
| StopDate | %Date | 否 | 失效日期 |
| CreateDate | %Date | 是 | 创建日期 |
| CreateTime | %Time | 是 | 创建时间 |
| CreateUser_Dr | HBUser | 是 | 创建用户 |
| Remark | %String | 否 | 备注 |

**唯一索引**：`DataIndex On (Code, ProvinceDr, CityDr)`

---

## 配置步骤

### 1. 接口映射配置

在IRIS系统中配置接口映射（根据实际情况选择配置方式）：

**方式一：通过界面配置**
- 进入接口管理模块
- 添加以下接口映射：
  - 02010038 → src.DRG.BasicData.ICDInfo.PreviewImportICD
  - 02010039 → src.DRG.BasicData.ICDInfo.ConfirmImportICD
  - 02010040 → src.DRG.BasicData.ICDInfo.DownloadImportTemplate

**方式二：通过代码配置**
```objectscript
// 示例：在接口配置表中添加映射
&sql(INSERT INTO CB_InterfaceMap (InterfaceCode, ClassName, MethodName) 
     VALUES ('02010038', 'src.DRG.BasicData.ICDInfo', 'PreviewImportICD'))
```

### 2. 权限配置

确保用户具有以下权限：
- 接口调用权限：02010038, 02010039, 02010040
- 数据表操作权限：SQLUser.BS_DRGICDInfo 的 SELECT、INSERT、UPDATE

### 3. 测试验证

测试命令：
```objectscript
; 测试下载模板
w ##class(src.DRG.BasicData.ICDInfo).DownloadImportTemplate({}).%ToJSON()

; 测试导入预览（需构造参数）
w ##class(src.DRG.BasicData.ICDInfo).PreviewImportICD({"params":[{"provinceID":"36","cityID":"371","fileData":"...","fileName":"test.csv"}]}).%ToJSON()
```

---

## 注意事项

1. **数据格式**：目前支持CSV格式导入，Excel文件需在前端转换为CSV或Base64后处理
2. **日期格式**：要求YYYY-MM-DD格式，导入时会转换为IRIS内部日期格式
3. **编码问题**：CSV文件建议使用UTF-8编码
4. **性能考虑**：大批量导入（>1000条）建议分批处理
5. **事务控制**：导入过程使用单条处理，失败记录不影响其他数据

---

## 前端对接说明

前端已实现完整的导入流程：
1. 点击【导入】按钮打开弹窗
2. 选择省、市（必填）
3. 上传CSV/Excel文件
4. 点击【预览】查看数据校验结果
5. 确认无误后点击【确认导入】
6. 查看导入结果报告

前端代码位置：
- 页面：`frontend/src/pages/BasicData/ICDQuery.tsx`
- API：`frontend/src/api/basicData.ts`
