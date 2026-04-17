## 1. 后端接口开发（CoreAlgorithm.cls）

- [ ] 1.1 创建PreviewImportDRGCoreAlgorithm方法：实现CSV文件Base64解码、字段解析、必填校验、数值格式校验、重复性检测
- [ ] 1.2 创建ConfirmImportDRGCoreAlgorithm方法：实现数据保存逻辑，使用operatetable方式操作HB_DRGCoreAlgorithmData表，支持新增和更新
- [ ] 1.3 创建DownloadDRGCoreAlgorithmTemplate方法：生成包含六个字段（DRGCode、DRGDesc、Points、PipValue、DGDOV、PayStandard）的CSV模板
- [ ] 1.4 实现行政区划和机构关联逻辑：Province_Dr、City_Dr、MdtrtArea、FixmedinsCode、FixmedinsName、MedinsLv字段赋值

## 2. 后端接口代理（InterFace.cls）

- [ ] 2.1 添加02010050接口方法PreviewImportDRGCoreAlgorithm，代理调用CoreAlgorithm.cls的预览方法
- [ ] 2.2 添加02010051接口方法ConfirmImportDRGCoreAlgorithm，代理调用CoreAlgorithm.cls的确认导入方法
- [ ] 2.3 添加02010052接口方法DownloadDRGCoreAlgorithmTemplate，代理调用CoreAlgorithm.cls的模板下载方法

## 3. 前端API层开发

- [ ] 3.1 在frontend/src/api/basicData.ts中添加previewDrgImport函数（调用02010050接口）
- [ ] 3.2 在frontend/src/api/basicData.ts中添加confirmDrgImport函数（调用02010051接口）
- [ ] 3.3 在frontend/src/api/basicData.ts中添加downloadDrgTemplate函数（调用02010052接口）
- [ ] 3.4 定义TypeScript类型：DrgImportPreviewItem、DrgImportResult、DrgImportParams

## 4. 前端页面开发（DRGCoreAlgorithm.tsx）

- [ ] 4.1 在页面头部增加"导入"按钮（参考ICDQuery.tsx的导入按钮位置和样式）
- [ ] 4.2 实现handleOpenImport方法：打开导入弹框，加载省下拉数据，重置导入状态
- [ ] 4.3 实现handleImportProvinceChange方法：省选择变化时加载市数据和医疗机构数据
- [ ] 4.4 实现handleDownloadTemplate方法：调用下载模板API，处理Base64文件下载
- [ ] 4.5 实现beforeUpload方法：文件上传前校验（CSV格式、大小限制），读取文件为Base64
- [ ] 4.6 实现handlePreviewImport方法：调用预览接口，传递省/市/医疗机构/文件数据，处理预览结果
- [ ] 4.7 实现handleConfirmImport方法：调用确认导入接口，处理导入结果，刷新列表
- [ ] 4.8 实现handleCloseImport方法：关闭弹框，重置所有导入状态

## 5. 前端导入弹框组件

- [ ] 5.1 创建三步导入流程UI（Steps组件：上传文件→数据预览→导入结果）
- [ ] 5.2 实现步骤1（上传文件）：省/市/医疗机构三级选择、文件上传Drag组件、模板下载按钮、导入说明Alert
- [ ] 5.3 实现步骤2（数据预览）：数据统计Alert（总/正常/重复/错误）、预览表格（行号、DRG代码、描述、状态、备注）
- [ ] 5.4 实现步骤3（导入结果）：Result组件（成功/警告）、统计卡片（总/成功/新增/更新）、失败明细列表
- [ ] 5.5 添加预览表格列定义：行号、DRGCode、DRGDesc、Points、PipValue、DGDOV、PayStandard、状态、错误信息

## 6. 前后端联调与测试

- [ ] 6.1 测试模板下载功能：验证CSV文件格式和字段正确性
- [ ] 6.2 测试省/市/医疗机构选择联动：验证数据加载和参数传递
- [ ] 6.3 测试CSV文件上传和解析：验证Base64编码解码、中文编码处理
- [ ] 6.4 测试数据校验功能：必填字段、数值格式、重复数据检测
- [ ] 6.5 测试数据保存功能：验证HB_DRGCoreAlgorithmData表数据正确性，确认关联字段（MdtrtArea、FixmedinsCode等）赋值正确
- [ ] 6.6 测试导入结果展示：验证统计信息和失败明细正确显示
- [ ] 6.7 测试边界场景：空文件、超大文件、格式错误文件、所有行都错误的情况

## 7. 代码审查与优化

- [ ] 7.1 后端代码审查：检查SQL注入防护、异常处理、日志记录
- [ ] 7.2 前端代码审查：检查类型定义、错误处理、内存泄漏
- [ ] 7.3 性能优化：大数据量导入性能测试，必要时添加分页或批量处理
- [ ] 7.4 用户体验优化：加载状态、错误提示、操作引导
