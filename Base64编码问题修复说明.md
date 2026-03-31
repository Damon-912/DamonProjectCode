# Base64编码问题修复说明

## 问题描述
`DownloadImportTemplate` 方法在执行时出现 `ILLEGAL VALUE` 错误：
```
{"errorCode":"04000007","errorMessage":"下载模板失败: 错误 #5002: Cache错误: <ILLEGAL VALUE>zDownloadImportTemplate+11^src.DRG.BasicData.ICDInfo.1","result":{}}
```

## 问题根源
经过分析，问题根源在于：
1. CSV 内容包含中文字符（如"伤寒"、"国家标准版"等）
2. IRIS/Caché 的 `$zcvt` 函数在直接对包含中文字符的字符串进行 Base64 编码时可能失败
3. 项目中对包含中文字符的字符串有特殊的处理要求

## 解决方案
根据项目中的 `src/src/util/Encryption.cls` 文件标准，对包含中文字符的字符串进行 Base64 编码需要以下步骤：

### 编码流程（字符串 → Base64）
```
原始字符串 → UTF-8编码 → URL编码 → Base64编码
```

### 解码流程（Base64 → 字符串）
```
Base64编码 → URL解码 → UTF-8解码 → 原始字符串
```

## 具体修改

### 1. `DownloadImportTemplate` 方法（编码）
```objectscript
// Base64编码 - 按照项目标准方法（处理中文字符）
// 参考src/src/util/Encryption.cls中的方法
// 1. 先将字符串转换为UTF-8
// 2. 然后进行URL编码
// 3. 最后进行Base64编码
set utf8Str = $zcvt(csvContent, "O", "UTF8")
set urlStr = $zcvt(utf8Str, "O", "URL")
set base64Data = $zcvt(urlStr, "O", "Base64")
```

### 2. `PreviewImportICD` 方法（解码）
```objectscript
// Base64解码 - 按照项目标准方法（处理中文字符）
// 反向操作：Base64解码 -> URL解码 -> UTF-8解码
set urlStr = $zcvt(fileData, "I", "Base64")
set utf8Str = $zcvt(urlStr, "I", "URL")
set csvContent = $zcvt(utf8Str, "I", "UTF8")
```

### 3. `ConfirmImportICD` 方法（解码）
```objectscript
// Base64解码 - 按照项目标准方法（处理中文字符）
// 反向操作：Base64解码 -> URL解码 -> UTF-8解码
set urlStr = $zcvt(fileData, "I", "Base64")
set utf8Str = $zcvt(urlStr, "I", "URL")
set csvContent = $zcvt(utf8Str, "I", "UTF8")
```

## 技术原理

### `$zcvt` 函数参数说明
- `"O"`：输出转换（Output conversion）- 用于编码
- `"I"`：输入转换（Input conversion）- 用于解码
- `"UTF8"`：UTF-8 字符编码
- `"URL"`：URL 百分号编码
- `"Base64"`：Base64 编码

### 为什么需要 URL 编码？
1. **兼容性**：URL 编码确保所有字符（包括中文字符）都转换为 ASCII 字符
2. **安全性**：防止特殊字符在传输过程中被误解
3. **项目标准**：项目中所有包含中文字符的 Base64 编码都使用此方法

## 测试步骤

### 1. 编译修改后的类
```
do $system.OBJ.Compile("src.DRG.BasicData.ICDInfo", "cuk")
```

### 2. 测试下载模板功能
```
w ##class(src.DRG.BasicData.ICDInfo).DownloadImportTemplate({}).%ToJSON()
```

### 3. 验证返回结果
预期返回格式：
```json
{
  "errorCode": "0",
  "errorMessage": "",
  "result": {
    "fileName": "ICD编码导入模板.csv",
    "fileData": "SUNE5...（Base64编码内容）",
    "contentType": "text/csv"
  }
}
```

### 4. 测试解码过程（验证编码正确性）
可以手动将返回的 Base64 字符串进行解码验证：
1. Base64 解码
2. URL 解码  
3. UTF-8 解码
4. 验证 CSV 内容正确

## 前端兼容性
前端 API 调用无需修改，Base64 数据传递方式不变：
- `downloadIcdTemplate()` - 调用 02010040 接口
- `previewIcdImport()` - 调用 02010038 接口
- `confirmIcdImport()` - 调用 02010039 接口

## 注意事项
1. **一致性**：所有三个方法使用相同的编码/解码逻辑
2. **错误处理**：已添加 try-catch 块捕获异常
3. **日志记录**：错误信息会记录到系统日志中

## 验证方法
1. 下载的模板文件应能正确打开，显示中文字符
2. 导入预览功能应能正确解析上传的 CSV 文件
3. 确认导入功能应能正确处理重复数据和新增数据

## 相关文件
- `src/src/DRG/BasicData/ICDInfo.cls` - 主要业务逻辑
- `src/src/util/Encryption.cls` - 项目加密标准参考
- `frontend/src/api/basicData.ts` - 前端 API 调用
- `frontend/src/pages/BasicData/ICDQuery.tsx` - 前端导入界面