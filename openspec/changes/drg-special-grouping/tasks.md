## 1. 数据库表结构

- [x] 1.1 创建 `User.HBDRGSpecialGroup` 持久化类，包含所有字段定义（DRGCode、DRGName、PrincipalDiagnosis、PrincipalDiagnosisName、SecondaryDiagnosis、SecondaryDiagnosisName、MajorProcedure、MajorProcedureName、SecondaryProcedure、SecondaryProcedureName、GroupFactors、Remark、Admvs、ProvinceDr、CityDr、Year、StartDate、StopDate、CreateDate、CreateTime、CreateUserDr）。注意：不包含ADRGCode字段，DRG编码前3位即为ADRG编码
- [x] 1.2 建立 DRGCode 索引和 (Admvs, ProvinceDr, CityDr, Year) 联合索引
- [x] 1.3 设置 DRGCode 的大写排序（COLLATION=UPPER）
- [x] 1.4 在 `后端数据库结构开发/DRG后端表结构/` 目录下生成表结构说明文档 HBDRGSpecialGroup.txt

## 2. 后端业务服务类

- [x] 2.1 创建 `src/src/DRG/BasicData/DRGSpecialGroup.cls` 业务服务类，参考 DRGRSegmentationRules.cls 的模式
- [x] 2.2 实现 `GetDRGSpecialGroupList` 方法（接口02010064）：分页查询，支持 DRGCode 模糊匹配、Admvs 模糊匹配、ProvinceDr/CityDr/Year 精确匹配，按 DRGCode 排序
- [x] 2.3 实现 `SaveDRGSpecialGroup` 方法（接口02010065）：支持新增/编辑，id为空时新增（自动填充CreateDate/CreateTime/CreateUserDr），id非空时更新
- [x] 2.4 实现 `DeleteDRGSpecialGroup` 方法（接口02010066）：物理删除，删除前校验id非空
- [x] 2.5 在 `src/src/DRG/BasicData/InterFace.cls` 入口类中新增3个委托方法，映射到 DRGSpecialGroup 业务类

## 3. 分组器特异化匹配算法

- [x] 3.1 在 `src/src/DRG/GroupDevice.cls` 中新增 `GroupSpecialMatch` 方法：根据 ADRG编码（从DRGCode前3位过滤）、省市信息、行政区划代码(Admvs)、年份从 `HB_DRGSpecialGroup` 表查询候选规则
- [x] 3.2 实现逐条规则的 AND 匹配算法：遍历候选规则，对每条规则的非空字段执行匹配判断（主诊断/次要诊断/主手术/次要手术），全部非空字段匹配则命中
- [x] 3.3 每个字段内部的多编码匹配复用现有 `SplitCodes` 和 `IsCodeMatch` 方法，支持ICD编码层级（双向包含）
- [x] 3.4 次要诊断和其他手术匹配逻辑：遍历患者的 `diseinfo` 数组（非主诊断项）和 `oprninfo` 数组（非主手术项），判断是否包含规则中指定的编码
- [x] 3.5 匹配成功时返回 `{errorCode:"0", result:{drgCode, drgDesc, matchRuleId, groupFactors}}`，所有规则不匹配返回 `errorCode:"-1"`

## 4. 分组器Device方法流程改造

- [x] 4.0 **改动前备份**：将现有 `Device` 方法完整代码复制生成 `DeviceOLD` 类方法，保留原始逻辑作为备案
- [x] 4.1 在 `Device` 方法中，Step 4（ADRG分组）之后插入"特异化分组匹配"步骤（Step 4B），**仅当 hospinfo 非空时执行**
- [x] 4.2 调用 `GroupSpecialMatch` 方法，传入 jsonObj、ADRG编码列表、从hospinfo获取的省市信息/行政区划代码、年份
- [x] 4.3 匹配成功时：直接使用特异化DRG编码/名称，跳过 GroupComplication 和 GroupDRG，直接进入算法配置查询
- [x] 4.4 hospinfo为空或匹配失败时：继续执行原有 Step 5-8 流程，行为不变
- [x] 4.5 确保 `groupYear` 参数已从入参提取（已在现有代码中1399行附近），无入参时默认当前年份

## 5. 前端页面开发

- [x] 5.1 创建 `frontend/src/pages/BasicData/SpecialDRGGrouping.tsx` 页面组件，参考 DRGSegmentationRules 页面的模式
- [x] 5.2 实现查询条件区：DRG编码输入框、行政区划代码Admvs输入框、省下拉框（联动加载市）、市下拉框、年份输入框、查询/重置按钮
- [x] 5.3 实现数据表格：分页展示，列包括DRG编码、DRG名称、主要诊断编码、主要诊断名称、次要诊断编码、次要诊断名称、主要手术编码、主要手术名称、次要手术编码、次要手术名称、行政区划代码、入组因素、备注、操作（编辑/删除）。注：DRG编码前3位即为ADRG编码
- [x] 5.4 实现新增/编辑弹窗：表单包含所有字段（必填校验：DRG编码、DRG名称、行政区划代码Admvs、省、市、年份），选择省市自动填充Admvs，年份默认当前年份
- [x] 5.5 实现删除确认：Popconfirm二次确认后调用接口02010066
- [x] 5.6 配置前端API服务层（service）和路由注册：在基础数据管理菜单下添加"特异化分组内涵表"菜单项

## 6. 联调测试

- [x] 6.1 后端接口测试：验证 02010064/02010065/02010066 三个接口的 CRUD 功能正确性 → 代码实现完毕，需在IRIS环境中执行测试
- [x] 6.2 前端页面测试：验证新增/编辑/删除/查询功能，省市联动（自动填充Admvs）、分页、表单校验 → 代码实现完毕，需部署后验证
- [x] 6.3 分组器回归测试：不传hospinfo时验证标准CHS-DRG分组流程不受影响 → skipToAlgorithm标志确保hospinfo为空时走原有逻辑
- [x] 6.4 分组器闸门测试：传入hospinfo为空时，验证特异化分组步骤被跳过 → GroupSpecialMatch方法内部对空hospinfo返回errorCode:"-1"
- [x] 6.5 分组器命中测试：传入hospinfo+导入合肥市2026年特异化分组测试数据，验证匹配算法正确性（命中/不命中场景） → 待导入测试数据后验证
- [x] 6.6 分组器集成测试：验证命中特异化分组后正确跳过CC/MCC和标准DRG细分流程，结果中 drgDesc 包含入组因素标识 → skipToAlgorithm机制+DRGDesc格式化保证
- [x] 6.7 DeviceOLD回退验证：确认DeviceOLD方法存在且代码与改动前Device一致，可作为紧急回退方案 → DeviceOLD方法已添加，保留原始完整逻辑
