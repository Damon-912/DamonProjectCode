## 1. 创建独立引擎类

- [x] 1.1 创建 `src/src/DRG/SpecialGroupEngine.cls`，继承 `%RegisteredObject`，全部 ClassMethod
- [x] 1.2 实现 `SplitCodes(codeStr)` 方法——分隔符 `,，;/ `（不含 `+`），拆分为 `$LIST`
- [x] 1.3 实现 `IsCodeMatch(code1, code2)` 方法——`$FIND` 双向前缀匹配，大写统一
- [x] 1.4 实现 `ParseGroupFactors(groupFactors)` 方法——`+`=AND / `或`=OR 解析

## 2. 实现 Match 公开入口

- [x] 2.1 实现 `Match(patientInfo, regionInfo, groupYear)` 方法
- [x] 2.2 地区校验：provinceDr 和 cityDr 均为空时返回 errorCode="-1"
- [x] 2.3 年份默认：groupYear 为空时取当前年份
- [x] 2.4 SQL 查询：按 Province_Dr、City_Dr、Admvs（前缀匹配）、Year 筛选，SELECT 含 Remark
- [x] 2.5 逐条遍历：ParseGroupFactors → AND/OR 匹配（规则字段均 SplitCodes）
- [x] 2.6 GroupFactors 为空时：自动按非空字段构建 AND 关系
- [x] 2.7 首次命中即返回，未命中返回 errorCode="-1"
- [x] 2.8 结果封装：`{ errorCode, errorMessage, result: { drgCode, drgDesc, matchRuleId, groupFactors, remark } }`

## 3. 替换 GroupDevice 旧实现

- [x] 3.1 备份 GroupDevice.cls 完整文件
- [x] 3.2 ~~删除 `SplitCodes` 方法~~ → **保留**：被 `CountCodeMatches` 和算法评分等其它方法引用，不可删除。引擎独立类中已复制不含 `+` 的新版本
- [x] 3.3 ~~删除 `IsCodeMatch` 方法~~ → **保留**：被 `CountCodeMatches` 引用，不可删除。引擎独立类中已复制相同逻辑
- [x] 3.4 删除 `ParseGroupFactors` 方法（原第 3013-3050 行）
- [x] 3.5 删除 `GroupSpecialMatch` 方法（原第 3064-3368 行）
- [x] 3.6 替换旧 call site：内联提取 patientInfo + 查 CB_Hospital 获取 regionInfo + 直接调用 SpecialGroupEngine.Match

## 4. 验证测试

- [ ] 4.1 用 MCP 查询到的 20 条规则逐一验证命中场景（**待 IRIS 编译后测试**）
- [x] 4.2 验证 ICD 层级匹配：IsCodeMatch 逻辑与原版一致（逐行复制），行为保持不变
- [x] 4.3 验证 SplitCodes 不拆分 ICD 复合编码：`$TRANSLATE("，;/ ", ",,,,")` 不含 `+`，`e88.906+h28.1*` 完整保留
- [ ] 4.4 验证空 GroupFactors 自动构建 AND（**待 IRIS 编译后测试**）
- [ ] 4.5 验证用户真实入参（H25.900 + 13.3x01）不命中（**待 IRIS 编译后测试**）
- [ ] 4.6 执行 GroupDevice.Device() 完整分组流程回归测试（**待 IRIS 编译后测试**）

## 5. 部署上线

- [x] 5.1 将 SpecialGroupEngine.cls 上传到 IRIS 服务器并编译成功（端口 52773，已修复 #1038 Private variable 错误）
- [x] 5.2 部署更新后的 GroupDevice.cls 到 IRIS 服务器并编译成功（0 错误）
- [ ] 5.3 清理 Debug 全局变量（^Debug("GroupSpecialMatch")）
