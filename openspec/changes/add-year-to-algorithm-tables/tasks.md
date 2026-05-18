## 1. 数据库表结构变更

- [x] 1.1 HB_DRGCoreAlgorithmData 增加 Year 字段（%String, MAXLEN=4），SqlColumnNumber 22，并更新 Storage Default 定义
- [x] 1.2 HB_DRGCoreAlgorithmData 增加唯一索引，将 Year 加入 Index 索引 `(DRG, ProvinceDr, CityDr, FixmedinsCode, Year)`
- [x] 1.3 HB_DIPCoreAlgorithmData 增加 Year 字段（%String, MAXLEN=4），SqlColumnNumber 21，并更新 Storage Default 定义
- [x] 1.4 HB_DIPCoreAlgorithmData 增加唯一索引，将 Year 加入 Index 索引 `(PrincipalDiagnosis, MajorProcedure, ProvinceDr, CityDr, MedinsLv, Year)`
- [ ] 1.5 执行类编译，确认表结构变更生效（需在 IRIS 服务端执行）

## 2. 后端 DRG 分组查询 - 年份回退逻辑

- [x] 2.1 修改 `GroupDevice.cls` 中 `Device()` 方法的 DRG 算法查询部分（约第1557-1581行）：在查询 HB_DRGCoreAlgorithmData 的 SQL 中增加 Year 过滤条件，先查当前年份，count=0 时回退查上一年
- [x] 2.2 修改 `GetDIPGroupScore()` 方法（02010003，约第1948行）：在动态 SQL 中增加 Year 过滤，先查当前年份，count=0 时回退查上一年
- [x] 2.3 修改 `SaveMedRecInfo()` 方法中 DRG 指向查询（约第2298行）：增加 Year 过滤条件
- [x] 2.4 当当前年份无数据但具体分组不存在时，返回明确的错误信息（含年份）

## 3. 后端算法配置接口 - 支持 Year 参数

- [x] 3.1 DRG 算法配置查询接口增加 Year 入参支持（可选参数，不传时不过滤年份）
- [x] 3.2 DRG 算法配置保存接口增加 Year 参数（必填），保存时将 Year 写入 HB_DRGCoreAlgorithmData 表
- [x] 3.3 DRG 算法配置导入接口增加 Year 参数（必填），导入的批量数据统一写入指定年份
- [x] 3.4 DIP 算法配置查询接口增加 Year 入参支持
- [x] 3.5 DIP 算法配置保存接口增加 Year 参数
- [x] 3.6 DIP 算法配置导入接口增加 Year 参数

## 4. 前端 DRG 算法配置页面 - 年份功能

- [x] 4.1 DRGCoreAlgorithmConfig.tsx 查询条件区域增加年份下拉（Select 组件，动态生成近5年选项 + "全部"），绑定到查询参数
- [x] 4.2 表格 columns 增加"年份"列（dataIndex: year，宽度80，位于 DRG 名称之后）
- [x] 4.3 新增/编辑弹窗表单增加年份字段（Form.Item name="year"，必填，默认值 dayjs().year().toString()）
- [x] 4.4 导入弹窗增加年份必选下拉（importForm 增加 importYear 字段，必填校验）
- [x] 4.5 导入参数传递时携带 year 字段到后端

## 5. 前端 DIP 算法配置页面 - 年份功能

- [x] 5.1 DIPCoreAlgorithmConfig.tsx 查询条件区域增加年份下拉（Select 组件，动态生成近5年选项 + "全部"），绑定到查询参数
- [x] 5.2 表格 columns 增加"年份"列（dataIndex: year，宽度80）
- [x] 5.3 新增/编辑弹窗表单增加年份字段（Form.Item name="year"，必填，默认值 dayjs().year().toString()）
- [x] 5.4 导入弹窗增加年份必选下拉（importForm 增加 importYear 字段，必填校验）
- [x] 5.5 导入参数传递时携带 year 字段到后端

## 6. 测试与验证（需 IRIS 服务端运行）

- [ ] 6.1 测试当前年份有完整 DRG 算法配置时的分组查询结果
- [ ] 6.2 测试当前年份无数据时自动回退到上一年份
- [ ] 6.3 测试当前年份有数据但具体分组不存在时的错误提示
- [ ] 6.4 测试 DIP 分组查询的年份回退和错误提示
- [ ] 6.5 测试前端 DRG/DIP 页面年份筛选、新增、编辑、导入功能
- [ ] 6.6 测试存量数据（Year 为空）的兼容性

## 6. 测试与验证

- [ ] 6.1 测试当前年份有完整 DRG 算法配置时的分组查询结果
- [ ] 6.2 测试当前年份无数据时自动回退到上一年份
- [ ] 6.3 测试当前年份有数据但具体分组不存在时的错误提示
- [ ] 6.4 测试 DIP 分组查询的年份回退和错误提示
- [ ] 6.5 测试前端 DRG/DIP 页面年份筛选、新增、编辑、导入功能
- [ ] 6.6 测试存量数据（Year 为空）的兼容性
