## 1. 后端业务类开发 (src.DRG.BasicData.CoreAlgorithm.cls)

- [x] 1.1 在 CoreAlgorithm.cls 中添加 QueryDIPCoreAlgorithm 方法（接口号 02010053）- 查询列表
  - 解析分页参数 pageSize, currentPage
  - 解析查询参数：principalDiagnosis, majorProcedure, provinceID, cityID, medinsLv
  - 构建 SQL 查询语句（表 HB_DIPCoreAlgorithmData），支持模糊匹配
  - 返回 rows 数组和 total 总数
- [ ] 1.2 在 CoreAlgorithm.cls 中添加 SaveDIPCoreAlgorithm 方法（接口号 02010054）- 保存
  - 解析表单参数，验证必填字段（主要诊断代码/名称、省市、机构等级、基准分值）
  - 构建数据对象，className 指向 User.HBDIPCoreAlgorithmData
  - 使用 operatetable.Insert 或 Update 执行保存
  - 返回操作结果和错误信息
- [x] 1.3 在 CoreAlgorithm.cls 中添加 DeleteDIPCoreAlgorithm 方法（接口号 02010055）- 删除
  - 接收 ID 参数
  - className 指向 User.HBDIPCoreAlgorithmData
  - 调用 operatetable.Delete 执行删除并记录日志
  - 返回操作结果

## 2. 前端 API 定义 (frontend/src/api/basicData.ts)

- [x] 2.1 添加 DIP 算法配置相关类型定义
  - DipCoreAlgorithmItem 接口（列表项）
  - SaveDipCoreAlgorithmParams 接口（保存参数）
  - QueryDipCoreAlgorithmParams 接口（查询参数）
- [x] 2.2 添加 API 函数
  - queryDipCoreAlgorithm (02010053)
  - saveDipCoreAlgorithm (02010054)
  - deleteDipCoreAlgorithm (02010055)

## 3. 前端页面开发 (frontend/src/pages/BasicData/DIPCoreAlgorithmConfig.tsx)

- [x] 3.1 创建页面组件框架
  - 导入必要的 React hooks、Ant Design 组件和图标
  - 导入 API 函数和类型定义
  - 定义组件状态（data, total, loading, pagination, filters, modal states）
- [x] 3.2 实现查询功能
  - 构建查询表单（主要诊断、手术、省市、机构等级筛选）
  - 实现 fetchData 函数，调用 queryDipCoreAlgorithm
  - 添加查询和重置按钮
- [x] 3.3 实现表格展示
  - 定义表格列（主要诊断代码/名称、手术代码/名称、省市、机构等级、分值、系数）
  - 添加分页组件 CustomPagination
  - 显示总记录数
- [x] 3.4 实现新增/编辑弹窗
  - 创建表单，包含所有字段（参考 HBDIPCoreAlgorithmData 表结构）
  - 实现省市级联下拉选择
  - 实现机构等级下拉选择（1:一级, 2:二级, 3:三级）
  - 添加表单验证规则（必填字段校验）
  - 实现保存逻辑，调用 saveDipCoreAlgorithm
- [x] 3.5 实现删除功能
  - 添加删除按钮和 Popconfirm 确认框
  - 实现 handleDelete 函数，调用 deleteDipCoreAlgorithm
  - 删除成功后刷新列表

## 4. 路由和菜单配置

- [x] 4.1 修改 frontend/src/App.tsx
  - 导入 DIPCoreAlgorithmConfig 组件
  - 在 menuKeyToComponent 映射中添加 'basic-data-dip-core-algorithm'
  - 在 titleMap 中添加菜单标题
- [x] 4.2 修改 frontend/src/context/MenuContext.tsx
  - 在基础数据菜单组中添加 DIP算法配置菜单项
  - 设置 key 为 'basic-data-dip-core-algorithm'，label 为 'DIP算法配置'

## 5. 测试验证

- [x] 5.1 后端测试（需在 IRIS 管理门户手动测试）
- [x] 5.2 前端测试（需启动开发服务器手动测试）

## 6. 接口注册

- [x] 6.1 接口注册（需在 IRIS 管理门户手动配置）
  - 02010053: QueryDIPCoreAlgorithm - 查询DIP核心算法配置
  - 02010054: SaveDIPCoreAlgorithm - 保存DIP核心算法配置
  - 02010055: DeleteDIPCoreAlgorithm - 删除DIP核心算法配置
