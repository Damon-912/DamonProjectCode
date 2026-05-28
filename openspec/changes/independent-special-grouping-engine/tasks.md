## 1. 创建独立引擎类

- [ ] 1.1 创建 `src/src/DRG/SpecialGroupEngine.cls`，继承 `%RegisteredObject`
- [ ] 1.2 实现 `SplitCodes(codeStr)` 方法——将逗号分隔的编码字符串拆分为 `$LIST`
- [ ] 1.3 实现 `IsCodeMatch(code1, code2)` 方法——ICD 双向前缀匹配
- [ ] 1.4 实现 `ParseGroupFactors(groupFactors)` 方法——解析 `+`（AND）/`或`（OR）结构化语法

## 2. 实现核心匹配引擎

- [ ] 2.1 实现 `Match(patientInfo, regionInfo, groupYear)` 公开入口方法
- [ ] 2.2 实现地区信息校验：regionInfo 为空时返回 `errorCode="-1"`
- [ ] 2.3 实现 SQL 查询逻辑：按 Province_Dr、City_Dr、Admvs（前缀匹配）、Year 筛选 HB_DRGSpecialGroup
- [ ] 2.4 实现逐条规则遍历匹配：按 DRGCode 排序，首次命中即返回
- [ ] 2.5 实现字段匹配逻辑——根据 ParseGroupFactors 解析结果执行 AND/OR 组合判断
- [ ] 2.6 实现结果封装：返回 `{ errorCode, errorMessage, result: { drgCode, drgDesc, matchRuleId, groupFactors } }`

## 3. 适配 GroupDevice 委托

- [ ] 3.1 修改 `GroupDevice.GroupSpecialMatch()` 方法：从 jsonObj 和 hospinfo 中提取 patientInfo 和 regionInfo
- [ ] 3.2 委托调用 `##class(src.DRG.SpecialGroupEngine).Match(patientInfo, regionInfo, groupYear)`
- [ ] 3.3 保留 hospinfo 为空时的早期返回逻辑（不调用新引擎）
- [ ] 3.4 保留异常捕获和错误日志记录逻辑

## 4. 验证与测试

- [ ] 4.1 用合肥市 2026 年 9 条规则逐一验证匹配正确性：
  - CB66：h40.501 + 12.6704 → 命中
  - CB26：H33.502 + 14.7401 → 命中
  - CB26：H35.303 + 13.4100x001 → 命中
  - CB26：H43.100（仅诊断）→ 命中
  - CB26：H25.100（仅诊断）→ 命中
  - CB46：14.7401（仅手术）→ 命中
  - CB56：h25.900 + 13.4101 → 命中
  - CB54：H25.900 + 13.4100x001 + 13.9003 → 命中
  - CB58：13.7000 + 13.4100x001（次要手术）→ 命中
- [ ] 4.2 验证 ICD 层级匹配：H25.900 匹配 H25.9、H25 匹配 H25.900
- [ ] 4.3 验证不命中场景：无匹配诊断/手术组合时返回 `errorCode="-1"`
- [ ] 4.4 验证 GroupDevice.Device() 完整分组流程结果与改造前一致

## 5. 部署上线

- [ ] 5.1 将 SpecialGroupEngine.cls 部署到 IRIS 服务器 `src/DRG/` 命名空间
- [ ] 5.2 部署更新后的 GroupDevice.cls
- [ ] 5.3 执行生产环境回归测试（至少 5 个真实病案场景）
- [ ] 5.4 清理 Debug 全局变量（^Debug("GroupSpecialMatch")）
