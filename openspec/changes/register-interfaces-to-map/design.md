## Context

DRG医保控费系统通过CB_MapInterface表进行接口路由分发。前端调用时传入接口编号(Code)，系统从CB_MapInterface表中查找对应的类名(ClassName)和方法名(MethodName)进行调用。新增的6个接口已在InterFace入口类中定义方法，但未注册到路由表中。

CB_MapInterface表关键字段：
- Code: 接口编号（唯一索引）
- Descripts: 接口描述
- ClassName: 入口类名
- MethodName: 方法名
- ServiceType: 服务类型(S=查询/A=新增/U=更新/D=删除)
- SessionFlag: 是否验证session(Y/N)
- TokenFlag: 是否验证token(Y/N)

## Goals / Non-Goals

**Goals:**
- 将6个新增接口注册到CB_MapInterface表，使前端可正常调用

**Non-Goals:**
- 不修改CB_MapInterface表结构
- 不修改现有接口注册记录
- 不涉及前端或后端业务逻辑变更

## Decisions

### 1. 数据插入方式

**决策**: 通过IRIS SQL INSERT语句直接插入CB_MapInterface表记录。

**理由**: 接口注册是基础配置数据，直接SQL插入最简洁高效，无需通过前端界面操作。

### 2. SessionFlag和TokenFlag设置

**决策**: 所有6个接口的SessionFlag=Y、TokenFlag=N。

**理由**: 与系统中其他基础数据管理接口保持一致，需要验证用户登录状态但不需要Token验证。

### 3. ServiceType分类

**决策**: 查询接口(S)、保存接口(A=新增/更新)、删除接口(D)。

**理由**: 保存接口同时支持新增和更新，统一使用A类型；与系统现有分类一致。

## Risks / Trade-offs

- **[Code唯一性]** → Code字段有唯一索引，插入前需确认6个编号未被占用，若已存在则跳过
- **[SessionFlag配置]** → 设置为Y需确保前端请求携带session信息
