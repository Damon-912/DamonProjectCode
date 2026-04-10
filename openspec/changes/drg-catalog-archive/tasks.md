## 1. 数据库表结构验证

- [ ] 1.1 确认 `User.HBDRGCataLog` 类定义完整：Code(必填,UPPER)、Descripts(必填,UPPER)、ProvinceDr(外键CB_Province,必填)、CityDr(外键CB_City,必填)、Admvs(必填)、UpdateDate/UpdateTime/UpdateUserDr(系统自动)
- [ ] 1.2 确认索引存在：Code单字段索引、DataIndex(Code,ProvinceDr,CityDr)联合索引
- [ ] 1.3 确认SQL表名为 `HB_DRGCataLog`，Storage映射正确

## 2. 后端接口服务验证

- [ ] 2.1 确认 `src.DRG.BasicData.DRGCataLog` 类包含三个方法：GetDRGCataLogList、SaveDRGCataLog、DeleteDRGCataLog
- [ ] 2.2 确认查询方法支持分页和条件筛选(code/descripts模糊匹配，provinceID/cityID精确匹配)
- [ ] 2.3 确认保存方法包含参数校验(code/descripts/provinceDr/cityDr非空)和重复性校验(同省市下code唯一)
- [ ] 2.4 确认删除方法执行物理删除并校验ID非空
- [ ] 2.5 确认 `src.DRG.BasicData.InterFace` 入口类包含02010041/02010042/02010043委托方法

## 3. 前端API接口验证

- [ ] 3.1 确认 `basicData.ts` 中定义了 HBDRGCataLogItem、QueryHBDRGCataLogParams、SaveHBDRGCataLogParams 类型
- [ ] 3.2 确认 queryHBDRGCataLog(02010041)、saveHBDRGCataLog(02010042)、deleteHBDRGCataLog(02010043) 接口函数定义正确

## 4. 前端页面验证

- [ ] 4.1 确认 `DRGCataLog.tsx` 页面包含查询条件区(省/市/DRG代码/DRG描述)和数据表格
- [ ] 4.2 确认省市二级联动：省变化时异步加载市数据(getProvinceData/getCityData)
- [ ] 4.3 确认新增/编辑弹窗：必填校验(code/descripts/provinceId/cityId)、省变化联动加载市、市选择自动获取Admvs
- [ ] 4.4 确认删除操作：Popconfirm确认后调用deleteHBDRGCataLog

## 5. 菜单配置验证

- [ ] 5.1 确认 App.tsx 中菜单配置：key=`basic-data-drg-catalog`，label=`DRGs目录信息表`，位于基础数据管理分组下
- [ ] 5.2 确认路由映射：case `basic-data-drg-catalog` 渲染 `<DRGCataLog />` 组件
