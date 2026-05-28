## 1. 后端持久化类（数据表定义）

- [x] 1.1 创建 `User.CBDRGDictTable.cls`：单表持久化类，包含 ParentDr（自引用 FK，NULL=类型，非NULL=项）、Code、Name、Status（Y/N）、SortNo、Remark、CreateDate、CreateTime、CreateUserDr，SqlTableName=`CB_DRGDictTable`，唯一索引 `(ParentDr, Code)`

## 2. 后端业务逻辑类

- [x] 2.1 创建 `src.DRG.BasicData.DictManage.cls`：字典管理业务逻辑类
- [x] 2.2 实现 `GetDRGDictTypeList` 方法（接口 02010059）：查询所有 ParentDr IS NULL 的记录（字典类型列表），支持 Code/Name 模糊搜索，不分页返回全部
- [x] 2.3 实现 `SaveDRGDictType` 方法（接口 02010062）：新增/修改字典类型，ParentDr 强制置空，Code 唯一性校验，支持启用/停用
- [x] 2.4 实现 `GetDRGDictItemList` 方法（接口 02010060）：查询 ParentDr = 指定类型ID 的记录（字典项分页列表），支持 Code/Name 模糊搜索，按 SortNo 升序
- [x] 2.5 实现 `SaveDRGDictItem` 方法（接口 02010061）：新增/修改字典项，ParentDr = 所属类型ID，(ParentDr, Code) 唯一性校验，支持启用/停用（Status Y/N），新增时 SortNo 自动取 MAX+1

## 3. 后端接口路由注册

- [x] 3.1 在 `src.DRG.BasicData.InterFace.cls` 中注册新接口映射（02010059→GetDRGDictTypeList, 02010060→GetDRGDictItemList, 02010061→SaveDRGDictItem, 02010062→SaveDRGDictType）

## 4. 前端 API 层

- [x] 4.1 在 `frontend/src/api/basicData.ts` 中新增类型定义：`DictItem`、`DictTypeItem`、`QueryDictItemParams`、`SaveDictItemParams`、`SaveDictTypeParams`
- [x] 4.2 新增 API 函数：`getDictTypeList`、`saveDictType`、`queryDictItemList`、`saveDictItem`

## 5. 前端页面组件（左侧类型列表 + 右侧字典项表格布局）

- [x] 5.1 创建 `frontend/src/pages/BasicData/DRGDictManagement.tsx`：字典管理主页面组件
- [x] 5.2 实现左侧字典类型列表区：树形或列表组件展示所有类型，点击选中高亮，联动刷新右侧字典项
- [x] 5.3 实现右侧字典项管理区：标题栏"当前类型 — 字典项管理" + 蓝色"新增字典项"按钮 + 搜索栏（编码/名称搜索框）
- [x] 5.4 实现字典项表格：列含编码、显示名称、排序、状态（Switch 开关，蓝色=启用，灰色=停用）、说明、操作（编辑按钮，无删除），底部右侧分页器
- [x] 5.5 实现字典项新增弹窗：Modal 含编码（输入框）、显示名称（输入框）、排序号（数字框）、说明（文本域），标题"新增字典项"
- [x] 5.6 实现字典项编辑弹窗：Modal 回显编码（只读）、显示名称、排序号、说明，标题"编辑字典项"
- [x] 5.7 实现 Switch 开关启用/停用：点击开关直接调用 saveDictItem 传 ID + Status，成功后更新表格行状态

## 6. 前端菜单注册

- [x] 6.1 在 `App.tsx` 的 `menuItems` 中"数据管理"下新增 `{ key: 'basic-data-drg-dict', label: '字典管理' }`
- [x] 6.2 在 `menuTitleMap` 中添加 `'basic-data-drg-dict': '字典管理'`
- [x] 6.3 在 `renderContent` 中添加路由映射并 import `DRGDictManagement` 组件
