## 1. 后端接口服务开发

- [ ] 1.1 创建DRG算法导入查询接口服务（Query），参考ICD编码导入查询接口
- [ ] 1.2 创建DRG算法导入验证接口服务（Validate），实现必填字段、数据格式、重复性校验
- [ ] 1.3 创建DRG算法导入保存接口服务（Save），使用operatetable方式操作HB_DRGCoreAlgorithmData表
- [ ] 1.4 实现行政区划和医疗机构关联字段处理（MdtrtArea、FixmedinsCode、FixmedinsName、MedinsLv）
- [ ] 1.5 后端接口联调测试

## 2. 前端导入功能开发

- [ ] 2.1 在DRG算法配置页面增加"导入"按钮
- [ ] 2.2 创建导入弹框组件，包含省、市、医疗机构三级联动选择
- [ ] 2.3 实现市接口调用，获取Code作为MdtrtArea参数
- [ ] 2.4 实现医疗机构接口调用，获取OrganizationCode、Descripts、HospGrade_Dr作为FixmedinsCode、FixmedinsName、MedinsLv参数
- [ ] 2.5 实现导入模板下载功能（包含DRGCode、DRGDesc、Points、PipValue、DGDOV、PayStandard字段）
- [ ] 2.6 实现Excel文件上传和解析功能
- [ ] 2.7 实现数据预览和校验结果展示界面
- [ ] 2.8 集成后端查询、验证、保存三个接口
- [ ] 2.9 前端联调测试

## 3. 功能测试与验收

- [ ] 3.1 测试导入模板下载功能
- [ ] 3.2 测试省、市、医疗机构选择及必填校验
- [ ] 3.3 测试Excel解析和数据预览功能
- [ ] 3.4 测试数据校验功能（必填字段、数值格式、重复性）
- [ ] 3.5 测试数据保存及数据库关联字段正确性
- [ ] 3.6 测试大批量数据导入性能
- [ ] 3.7 整体功能验收
