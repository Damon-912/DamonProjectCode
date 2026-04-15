# 菜单配置与现有系统整合 - 实施任务

## 后端任务

### 1. 修改Menu.Service整合现有表 ✅ 已完成
- [x] 重构 `src.Menu.Service.GetUserMenus()` 使用 `User.HBUserLogonLoc` + `User.CBGroupMenu`
- [x] 重构 `src.Menu.Service.GetRoleMenus()` 使用 `User.CBGroupMenu`
- [x] 重构 `src.Menu.Service.SaveRoleMenus()` 保存到 `User.CBGroupMenu`
- [x] 实现 `GetMenuTree()` 从 `User.CBMenuDetail` 获取菜单树
- [x] 新增 `GetUserMenusByGroup()` 方法
- [x] 新增 `GetMenuTreeFromDetail()` 方法
- [x] 新增 `SaveRoleMenusByGroup()` 方法

### 2. 扩展现有登录接口 ✅ 已完成
- [x] 修改 `src.Logon.Logon` 登录成功后返回用户菜单
- [x] 调用 `src.Menu.Service.GetUserMenusByGroup()` 获取菜单数据
- [x] 确保登录返回数据包含菜单列表

### 3. 创建菜单初始化方法 ✅ 已完成
- [x] 已有 `InitDefaultMenus()` 方法从 App.tsx 导入初始菜单

## 前端任务

### 4. 创建MenuContext ✅ 已完成
- [x] 创建 `src/context/MenuContext.tsx`
- [x] 实现从后端获取用户菜单逻辑
- [x] 提供菜单状态管理
- [x] 提供默认菜单配置(备用)

### 5. 改造登录流程 ✅ 已完成
- [x] 修改 `SelectHospRole.tsx` 登录成功后获取菜单
- [x] 存储菜单到 MenuContext
- [x] 传递菜单到App组件

### 6. 改造App.tsx ✅ 已完成
- [x] 使用 MenuProvider 包裹主组件
- [x] 从 MenuContext 获取菜单数据
- [x] 动态渲染导航栏(优先使用动态菜单，无则使用默认菜单)

### 7. 创建菜单API接口 ✅ 已完成
- [x] 创建 `src/api/menu.ts`
- [x] 定义菜单相关接口类型
- [x] 实现菜单相关API函数

### 8. 优化菜单管理页面
- [ ] 修改 `src/pages/System/Menus.tsx`
- [ ] 调用 `src.Menu.Interface.GetMenuTree()` 获取菜单列表
- [ ] 实现菜单增删改功能

### 9. 扩展角色权限页面
- [ ] 修改 `src/pages/System/Roles.tsx`
- [ ] 调用 `src.Menu.Interface.GetRoleMenus()` 获取角色菜单
- [ ] 实现角色菜单配置保存

## 数据初始化任务

### 9. 初始化DRG菜单数据
- [ ] 在 `User.CBMenuDetail` 表中创建DRG系统菜单
- [ ] 创建一级菜单(监控仪表盘、DRG业务、DIP业务等)
- [ ] 创建二级菜单(分组工作台、病种分值查询等)

### 10. 为默认角色分配菜单
- [ ] 查询现有角色(Admin等)
- [ ] 为Admin角色分配所有菜单权限到 `User.CBGroupMenu`

## 测试验证

- [ ] 验证管理员登录后显示所有菜单
- [ ] 验证普通用户登录后显示授权菜单
- [ ] 验证角色权限配置保存后生效
- [ ] 验证菜单增删改功能正常
