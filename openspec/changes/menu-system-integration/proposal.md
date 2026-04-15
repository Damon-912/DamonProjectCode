# 菜单配置与现有系统整合

## 变更概述

将新创建的Menu接口服务(`src.Menu.Interface`、`src.Menu.Service`)与现有系统中的用户管理、角色管理、角色权限数据关联整合，实现统一的菜单权限体系。

## 现有系统结构

### 现有数据表

| 表名 | 说明 | 路径 |
|------|------|------|
| `User.HBUser` | 用户表 | User |
| `User.CBGroup` | 角色表 | User |
| `User.HBUserLogonLoc` | 用户登录机构表(含Group_Dr) | User |
| `User.CBMenuDetail` | 菜单详情表 | User |
| `User.CBGroupMenu` | 角色菜单关联表 | User |

### 现有表结构

**User.CBGroup (角色表)**
- ID, Code, Descripts, ENDesc, MainInterface(默认首页), OperCodeTable
- CreateDate, CreateUserDr, Deleted, DeleteTime

**User.CBMenuDetail (菜单详情表)**
- ID, Code, Descripts, LinkAddress(链接地址), LinkPath(路径)
- MenuGroup(Y/N是否菜单组), Image(图标), SeqNo(排序号)
- PreMenuDr(上级菜单), ProductCatDr, ProductModuleDr
- CreateDate, CreateUserDr, Deleted

**User.CBGroupMenu (角色菜单关联表)**
- ID, GroupDr(角色外键), MenuDetailDr(菜单外键), MenuType
- StartDate, StopDate, CreateDate, CreateUserDr, Deleted

## 整合方案

### 方案选择

**采用方案A**: 将新Menu接口与现有CBMenuDetail/CBGroupMenu整合
- 保持现有表结构不变
- Menu.Service 直接操作现有表
- 提供新的API接口供前端使用

### 整合内容

1. **用户登录流程整合**
   - 登录成功后返回用户菜单列表
   - 调用 `src.Menu.Service.GetUserMenus()` 获取用户菜单
   - 菜单数据来源: `User.CBMenuDetail` + `User.CBGroupMenu`

2. **角色菜单权限配置整合**
   - 使用现有 `User.CBGroupMenu` 表
   - 提供角色菜单权限的增删改查接口

3. **菜单管理页面整合**
   - 前端调用新的 `src.Menu.Interface` 接口
   - 接口内部调用现有表结构

## API接口映射

| 新接口 | 内部调用表 | 说明 |
|--------|-----------|------|
| `src.Menu.Interface.GetMenuTree()` | User.CBMenuDetail | 获取菜单树 |
| `src.Menu.Interface.GetUserMenus()` | User.CBGroupMenu + User.HBUserLogonLoc | 获取用户菜单 |
| `src.Menu.Interface.GetRoleMenus()` | User.CBGroupMenu | 获取角色菜单 |
| `src.Menu.Interface.SaveRoleMenus()` | User.CBGroupMenu | 保存角色菜单 |

## 数据流程

```
用户登录 → HBUserLogonLoc(获取Group_Dr) → CBGroupMenu(获取MenuDetail_Dr) → CBMenuDetail(获取菜单详情)
```
