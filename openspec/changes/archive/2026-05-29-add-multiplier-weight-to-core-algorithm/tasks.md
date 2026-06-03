## 1. 数据库表结构变更

- [x] 1.1 在 `src/User/HBDRGCoreAlgorithmData.cls` 新增 HighMultiplier 属性（SqlColumnNumber=23，%String，可选）
- [x] 1.2 在 `src/User/HBDRGCoreAlgorithmData.cls` 新增 LowMultiplier 属性（SqlColumnNumber=24，%String，可选）
- [x] 1.3 在 `src/User/HBDRGCoreAlgorithmData.cls` 新增 Weight 属性（SqlColumnNumber=25，%String，可选）
- [x] 1.4 更新 Storage Default Data 块，添加三个新 Value 节点（Value name 23/24/25）

## 2. 后端查询接口更新

- [x] 2.1 修改 `GetDRGCoreAlgorithm` SQL SELECT 语句，增加 HighMultiplier、LowMultiplier、Weight 字段
- [x] 2.2 修改 `GetDRGCoreAlgorithm` 结果映射，将新字段写入返回的 JSON 对象

## 3. 后端保存接口更新

- [x] 3.1 修改 `UpdateDRGCoreAlgorithm` 参数解析，读取 highMultiplier、lowMultiplier、weight
- [x] 3.2 修改 `UpdateDRGCoreAlgorithm` 数据对象构建，将新字段写入 dataObj

## 4. 后端导入导出功能更新

- [x] 4.1 修改 `DownloadDRGCoreAlgorithmTemplate` CSV 表头，添加 HighMultiplier,LowMultiplier,Weight 列
- [x] 4.2 修改 `DownloadDRGCoreAlgorithmTemplate` 示例数据行，新字段填 NULL
- [x] 4.3 修改 `PreviewImportDRGCoreAlgorithm` CSV 解析逻辑，解析第7-9列
- [x] 4.4 修改 `PreviewImportDRGCoreAlgorithm` 预览对象和表格，包含新字段
- [x] 4.5 修改 `ConfirmImportDRGCoreAlgorithm` CSV 解析逻辑，解析第7-9列
- [x] 4.6 修改 `ConfirmImportDRGCoreAlgorithm` 数据对象构建，写入新字段

## 5. 前端类型定义更新

- [x] 5.1 修改 `CoreAlgorithmItem` 接口，增加 highMultiplier、lowMultiplier、weight 字段
- [x] 5.2 修改 `SaveCoreAlgorithmParams` 接口，增加 highMultiplier、lowMultiplier、weight 字段
- [x] 5.3 修改 `DrgCoreAlgorithmImportPreviewItem` 接口，增加 highMultiplier、lowMultiplier、weight 字段

## 6. 前端页面更新

- [x] 6.1 在表格列定义中增加"高倍率"、"低倍率"、"权重"三列（在"预估支付标准"后，右对齐显示）
- [x] 6.2 在新增/编辑表单的"算法参数"Card 中增加三个 Form.Item（highMultiplier、lowMultiplier、weight）
- [x] 6.3 修改 `handleEdit` 方法中 `setFieldsValue`，包含新字段的回填
- [x] 6.4 修改 `handleSave` 方法，确保新字段值被提交
- [x] 6.5 在导入预览表格列定义中增加三列

## 7. 验证测试

- [ ] 7.1 验证后端编译：编译 `User.HBDRGCoreAlgorithmData` 和 `src.DRG.BasicData.CoreAlgorithm` 类无报错
- [ ] 7.2 验证新增配置：前端新增一条DRG配置并填写高倍率/低倍率/权重，确认保存成功
- [ ] 7.3 验证编辑配置：编辑已有配置，修改新字段值，确认保存成功
- [ ] 7.4 验证查询显示：列表中正确显示高倍率/低倍率/权重三列
- [ ] 7.5 验证导入导出：下载模板包含新字段，上传预览和确认导入正确处理新字段
- [ ] 7.6 验证兼容性：不填写新字段时新增/编辑正常，已有数据查询正常
