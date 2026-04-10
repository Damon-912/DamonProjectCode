## 1. 数据库表结构创建

- [x] 1.1 创建 `User.HBDRGSegmentationRules` 持久化类（SQL表名: HB_DRGSegmentationRules），包含字段：ADRG(必填,UPPER)、ADRGDesc(必填,UPPER)、ProvinceDr(外键CB_Province,必填)、CityDr(外键CB_City,必填)、Admvs(必填)、UnionFlag(必填)、SegmentationFlag(必填)、UpdateDate(系统自动)、UpdateTime(系统自动)、UpdateUserDr(外键HB_User,系统自动)
- [x] 1.2 创建ADRG单字段索引和DataIndex(ADRG,ProvinceDr,CityDr)联合索引
- [x] 1.3 配置Storage映射（参照HBDRGCataLog的Storage结构）

## 2. 后端接口服务开发

- [x] 2.1 创建 `src.DRG.BasicData.DRGRSegmentationRules` 业务类，实现GetDRGSegmentationRulesList方法（分页查询，支持adrg/adrgDesc模糊匹配，provinceID/cityID精确匹配）
- [x] 2.2 实现SaveDRGSegmentationRules方法（参数校验：adrg/adrgDesc/provinceDr/cityDr/unionFlag/segmentationFlag非空；重复性校验：同省市下adrg唯一；自动填充Admvs/UpdateDate/UpdateTime/UpdateUserDr）
- [x] 2.3 实现DeleteDRGSegmentationRules方法（物理删除，校验ID非空）
- [x] 2.4 在 `src.DRG.BasicData.InterFace` 入口类中新增三个委托方法：GetDRGSegmentationRulesList(02010044)、SaveDRGSegmentationRules(02010045)、DeleteDRGSegmentationRules(02010046)

## 3. 前端API接口定义

- [x] 3.1 在 `basicData.ts` 中定义TypeScript类型：HBDRGSegmentationRulesItem（id/adrg/adrgDesc/admvs/unionFlag/segmentationFlag/provinceID/provinceDesc/cityID/cityDesc）、QueryHBDRGSegmentationRulesParams（adrg/adrgDesc/provinceID/cityID）、SaveHBDRGSegmentationRulesParams（id/adrg/adrgDesc/provinceDr/cityDr/admvs/unionFlag/segmentationFlag）
- [x] 3.2 定义接口函数：queryHBDRGSegmentationRules(02010044)、saveHBDRGSegmentationRules(02010045)、deleteHBDRGSegmentationRules(02010046)

## 4. 前端页面开发

- [x] 4.1 创建 `DRGSegmentationRules.tsx` 页面组件，包含查询条件区（省/市/ADRG代码/ADRG描述）和数据表格（ADRG代码/ADRG描述/行政区划/省市/联合标志/细分标志/操作列）
- [x] 4.2 实现省市二级联动查询：省变化时异步加载市数据（复用getProvinceData/getCityData）
- [x] 4.3 实现新增/编辑弹窗：ADRG代码、ADRG描述、省（联动加载市）、市（选择后自动获取Admvs）、联合标志（下拉0-否/1-是）、细分标志（下拉0-否/1-是），必填校验
- [x] 4.4 实现删除操作：Popconfirm确认后调用deleteHBDRGSegmentationRules

## 5. 前端菜单配置

- [x] 5.1 在 `App.tsx` 中注册菜单项：key=`basic-data-segmentation-rules`，label=`ADRG细分规则表`，位于基础数据管理分组下
- [x] 5.2 在 `App.tsx` 中添加路由映射：case `basic-data-segmentation-rules` 渲染 `<DRGSegmentationRules />` 组件
- [x] 5.3 在 `App.tsx` 中导入DRGSegmentationRules组件
