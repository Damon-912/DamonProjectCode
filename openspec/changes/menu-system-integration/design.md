# 菜单配置与现有系统整合 - 技术设计

## 整合架构

```
┌─────────────────────────────────────────────────────────────┐
│                     前端 (React)                             │
│  App.tsx / Login / Menus.tsx / Roles.tsx                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              src.Menu.Interface (接口路由)                    │
│  - GetMenuTree / GetUserMenus / GetRoleMenus / SaveRoleMenus │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              src.Menu.Service (业务实现)                       │
│  - 整合现有表: CBMenuDetail, CBGroupMenu, HBUserLogonLoc      │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ User.CBMenuDetail │  │ User.CBGroupMenu │  │ User.HBUserLogonLoc │
│    菜单详情      │    │   角色菜单关联   │    │   用户登录机构   │
└───────────────┘    └───────────────┘    └───────────────┘
        ▲                     ▲
        │                     │
┌───────────────┐    ┌───────────────┐
│  User.CBGroup │    │  User.HBUser  │
│     角色表      │    │    用户表      │
└───────────────┘    └───────────────┘
```

## 数据库表结构

### 现有表: User.CBMenuDetail (菜单详情)

```sql
CREATE TABLE CB_MenuDetail (
    ID INTEGER PRIMARY KEY,
    Code VARCHAR(50),           -- 菜单编码
    Descripts VARCHAR(100),     -- 菜单名称
    ENDescripts VARCHAR(100),   -- 英文名称
    LinkAddress VARCHAR(200),   -- 链接地址
    LinkPath VARCHAR(200),       -- 路径
    MenuGroup VARCHAR(1),       -- Y=菜单组,N=菜单项
    Image VARCHAR(100),         -- 图标
    SeqNo INTEGER,              -- 排序号
    PreMenuDr INTEGER,          -- 上级菜单外键
    ProductCatDr INTEGER,       -- 产品分类外键
    ProductModuleDr INTEGER,    -- 产品模块外键
    CreateDate DATE,
    CreateUserDr INTEGER,
    Deleted INTEGER DEFAULT 0
)
```

### 现有表: User.CBGroupMenu (角色菜单关联)

```sql
CREATE TABLE CB_GroupMenu (
    ID INTEGER PRIMARY KEY,
    GroupDr INTEGER,            -- 角色外键
    MenuDetailDr INTEGER,       -- 菜单外键
    MenuType VARCHAR(1),         -- 菜单类型
    StartDate DATE,
    StopDate DATE,
    CreateDate DATE,
    CreateUserDr INTEGER,
    Deleted INTEGER DEFAULT 0
)
```

### 现有表: User.HBUserLogonLoc (用户登录机构)

```sql
CREATE TABLE HB_UserLogonLoc (
    ID INTEGER PRIMARY KEY,
    User_Dr INTEGER,             -- 用户外键
    Hosp_Dr INTEGER,            -- 机构外键
    Group_Dr INTEGER,            -- 角色外键 ← 关键关联
    IsDefault VARCHAR(1),         -- 是否默认
    StartDate DATE,
    StopDate DATE,
    CreateDate DATE,
    CreateUserDr INTEGER,
    Deleted INTEGER DEFAULT 0
)
```

## 接口设计

### src.Menu.Service 方法实现

```objectscript
/// 获取用户菜单(整合版)
ClassMethod GetUserMenus(postObj) As %Library.DynamicObject
{
    // 1. 从 HBUserLogonLoc 获取用户角色(Group_Dr)
    &sql(SELECT Group_Dr INTO :groupDr 
         FROM User.HBUserLogonLoc 
         WHERE User_Dr = :userID AND Deleted = 0 AND IsDefault = 'Y')
    
    // 2. 从 CBGroupMenu 获取该角色的菜单列表
    &sql(SELECT MenuDetail_Dr INTO :menuDetailDr 
         FROM User.CBGroupMenu 
         WHERE Group_Dr = :groupDr AND Deleted = 0)
    
    // 3. 从 CBMenuDetail 获取菜单详情，构建树形结构
    // ... 构建菜单树返回
}

/// 获取角色菜单权限
ClassMethod GetRoleMenus(postObj) As %Library.DynamicObject
{
    // 从 CBGroupMenu 获取指定角色的菜单
}

/// 保存角色菜单权限
ClassMethod SaveRoleMenus(postObj) As %Library.DynamicObject
{
    // 保存到 CBGroupMenu 表
}
```

## 前端整合

### 登录流程改造

```typescript
// src/pages/Login/SelectHospRole.tsx
// 登录成功后调用获取菜单接口
const handleLoginSuccess = async (userData) => {
    // 获取用户菜单
    const menuRes = await api.post('/menu/user', { userCode: userData.userCode });
    // 保存到 MenuContext
    setUserMenus(menuRes.data);
}
```

### MenuContext 改造

```typescript
// src/context/MenuContext.tsx
// 从后端获取菜单数据，替换硬编码
const loadUserMenus = async () => {
    const res = await src.Menu.Interface.GetUserMenus({ userCode });
    setMenus(res.data);
}
```

## 数据初始化

### DRG系统菜单初始化

将App.tsx中的菜单数据初始化到现有表:

```sql
-- 插入一级菜单
INSERT INTO CB_MenuDetail (Code, Descripts, MenuGroup, Image, SeqNo, LinkAddress)
VALUES ('drg', 'DRG业务', 'Y', 'PartitionOutlined', 2, '');

-- 插入二级菜单
INSERT INTO CB_MenuDetail (Code, Descripts, MenuGroup, Image, SeqNo, LinkAddress, PreMenuDr)
VALUES ('drg-workbench', '分组工作台', 'N', '', 1, '/drg/workbench', (SELECT ID FROM CB_MenuDetail WHERE Code='drg'));
```

### 为默认角色分配菜单

```sql
-- 为Admin角色分配所有菜单
INSERT INTO CB_GroupMenu (GroupDr, MenuDetailDr)
SELECT (SELECT ID FROM CB_Group WHERE Code='Admin'), ID FROM CB_MenuDetail WHERE Deleted=0;
```
