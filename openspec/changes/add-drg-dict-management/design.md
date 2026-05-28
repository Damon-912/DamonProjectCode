## Context

当前 DRG 系统中已有两套字典相关表体系：平台通用字典（`CB_BasicDictionary`/`CB_BasicDictionarySub`）和平台业务字典（`HB_Dictionaries`/`HB_DictionariesDateDetail`），这些表都绑定了行政区划（省/市/区）维度。DRG 系统中存在大量不依赖于行政区划的业务字典型数据（如费用类型、预警等级、科室分类、药品类别、操作类型等），需要一个独立于区划维度的纯 DRG 字典管理模块。

本设计采用**单表自引用**结构：通过 `ParentDr` 字段为空或不为空来区分"字典类型"和"字典项"，简化表结构，降低维护成本。

## Goals / Non-Goals

**Goals:**
- 新建 `CB_DRGDictTable` 单表，通过 `ParentDr` 自引用区分字典类型（ParentDr=NULL）和字典项（ParentDr=类型ID）
- 提供字典类型的查询接口（02010059）
- 提供字典项的查询/新增/修改接口（02010060-02010062）
- 提供前端"字典管理"菜单页面，采用左侧字典类型树/列表 + 右侧字典项表格的经典布局
- 支持字典类型和字典项的启用/停用操作（使用 Switch 开关组件）

**Non-Goals:**
- 不涉及数据权限（省/市/区）控制，字典数据全局共享
- 不修改已有的 `HB_Dictionaries` 等表结构
- 不提供删除功能（停用即逻辑删除）
- 不提供字典数据的批量导入导出（后续迭代）

## Decisions

### 1. 数据库表结构设计（单表自引用）

**CB_DRGDictTable（字典表，同时存储类型和项，持久化类: `User.CBDRGDictTable`）:**

| 字段 | 类型 | 说明 |
|------|------|------|
| ID | Integer (PK) | 主键 |
| ParentDr | FK→CB_DRGDictTable | 自引用外键：NULL=字典类型，非NULL=所属类型的ID |
| Code | %String(50) | 编码 |
| Name | %String(100) | 名称（显示名称） |
| Status | %String(1) | 状态：Y=启用，N=停用 |
| SortNo | %Integer | 排序号 |
| Remark | %String(MAX) | 说明/备注 |
| CreateDate | %Date | 创建日期 |
| CreateTime | %Time | 创建时间 |
| CreateUserDr | FK→HB_User | 创建人 |

**索引设计：**
- `IdxCode` on `(ParentDr, Code)` — 同一类型下编码唯一（ParentDr=NULL 时类型编码全局唯一）
- `IdxName` on `(ParentDr, Name)` — 同一类型下名称唯一
- `IdxParent` on `ParentDr` — 快速查询某类型下的所有字典项

**设计理由：**
- 单表设计减少表的数量，查询/维护更简单
- 自引用模式（ParentDr）是在 IRIS 数据库中的常见做法（如菜单树、组织架构）
- `Code` 在同一 `ParentDr` 下唯一：类型编码全局唯一，项编码在同类型下唯一
- SortNo 供前端下拉选项按序展示
- `Status` 显式控制启用/停用，比日期范围判断更直观

### 2. 后端接口编号分配

复用现有的 `src.util.operatetable` 公共 Insert/Update/Delete 方法和 `src.DRG.BasicData.InterFace` 接口路由模式。

| 接口编号 | 方法 | 说明 | 查询条件 |
|----------|------|------|----------|
| 02010059 | GetDRGDictTypeList | 查询所有字典类型（不分页，ParentDr IS NULL） | ParentDr IS NULL |
| 02010060 | GetDRGDictItemList | 查询字典项列表（按类型筛选，分页） | ParentDr = 指定类型ID |
| 02010061 | SaveDRGDictItem | 新增/修改字典项（含启用/停用） | ParentDr = 指定类型ID |
| 02010062 | SaveDRGDictType | 新增/修改字典类型（含启用/停用） | ParentDr 置空 |

启用/停用复用 Save 方法，前端传入 Status 值（Y/N）即可。

### 3. 前端页面架构

参考提供的 UI 设计，采用**左侧字典类型树/列表 + 右侧字典项表格**布局：

**左侧栏（字典类型）：**
- 树形或列表形式展示所有 `ParentDr IS NULL` 的字典类型
- 显示类型名称（如"险种类型"、"结算状态"等）
- 支持点击选中，选中后高亮显示
- 类型本身不提供增删改入口（如需维护类型，需单独处理或通过其他入口）
- **暂定**：字典类型通过其他方式维护（如初始化脚本或单独维护页面），本页面主要维护字典项

**右侧内容区（字典项管理）：**
- **标题栏**：显示"当前类型名称 — 字典项管理"，右侧放置"新增字典项"按钮
- **表格列**：编码、显示名称（Name）、排序（SortNo）、状态（Switch开关）、说明（Remark）、操作（编辑）
- **状态列**：使用 Ant Design `Switch` 组件，checked=Y（启用），unchecked=N（停用），蓝色=启用，灰色=停用
- **操作列**：仅编辑按钮（铅笔图标），无删除按钮（遵循不提供删除功能的设计）
- **分页**：表格底部右侧显示分页器

**弹窗（新增/编辑字典项）：**
- 表单字段：编码（Code）、显示名称（Name）、排序号（SortNo）、说明（Remark）
- 编码在新增时可编辑，编辑时只读
- 保存时自动携带当前选中的字典类型 ParentDr

### 4. 数据权限与约束

- 字典类型本身不提供增删改（本页面内），通过其他方式维护
- 字典项编码在同类型下唯一
- 停用字典项不影响已使用该字典的历史业务数据

## Risks / Trade-offs

- **[风险] 编码重复** → 唯一索引 `(ParentDr, Code)` 保证数据库层面不重复
- **[权衡] 单表 vs 双表** → 单表查询更简单，无需 JOIN；缺点是自引用关系查询递归时需注意深度（目前仅支持两级，无多层嵌套）
- **[决策] 不提供删除** → 停用即等同于逻辑删除，避免误删导致历史数据引用断裂
- **[决策] 字典类型不在页面内维护** → 简化页面复杂度，类型相对稳定，可通过初始化脚本维护

## Migration Plan

1. 部署 `User.CBDRGDictTable.cls` 持久化类，编译后自动建表
2. 部署 `src.DRG.BasicData.DictManage.cls` 业务逻辑类
3. 在 `InterFace.cls` 中注册新接口映射
4. 部署前端页面和菜单配置
5. **无需数据迁移**：全新模块
6. 回滚：删除新增类文件重新编译即可

## Open Questions

- 是否需要支持批量导入导出？（后续迭代）
- 是否需要多级嵌套（字典类型 > 大类 > 小类 > 项）？（当前仅两级，后续可扩展但需评估性能）
- 字典类型的维护方式：初始化脚本 vs 页面内维护？
