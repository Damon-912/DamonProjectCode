## ADDED Requirements

### Requirement: 接口路由注册
系统 SHALL 在CB_MapInterface表中注册6条接口路由记录，使前端可通过接口编号调用对应的后端方法。

#### Scenario: DRG目录信息接口注册
- **WHEN** 系统初始化或执行接口注册脚本
- **THEN** CB_MapInterface表中存在以下3条记录：
  - Code=02010041, Descripts=查询DRG目录信息, ClassName=SRC.DRG.BASICDATA.INTERFACE, MethodName=GETDRGCATALOGIST, ServiceType=S
  - Code=02010042, Descripts=保存DRG目录信息, ClassName=SRC.DRG.BASICDATA.INTERFACE, MethodName=SAVEDRGCATALOG, ServiceType=A
  - Code=02010043, Descripts=删除DRG目录信息, ClassName=SRC.DRG.BASICDATA.INTERFACE, MethodName=DELETEDRGCATALOG, ServiceType=D

#### Scenario: ADRG细分规则接口注册
- **WHEN** 系统初始化或执行接口注册脚本
- **THEN** CB_MapInterface表中存在以下3条记录：
  - Code=02010044, Descripts=查询ADRG细分规则, ClassName=SRC.DRG.BASICDATA.INTERFACE, MethodName=GETDRGSEGMENTATIONRULESLIST, ServiceType=S
  - Code=02010045, Descripts=保存ADRG细分规则, ClassName=SRC.DRG.BASICDATA.INTERFACE, MethodName=SAVEDRGSEGMENTATIONRULES, ServiceType=A
  - Code=02010046, Desittings=删除ADRG细分规则, ClassName=SRC.DRG.BASICDATA.INTERFACE, MethodName=DELETEDRGSEGMENTATIONRULES, ServiceType=D

### Requirement: 注册数据完整性
所有注册记录 SHALL 设置 SessionFlag=Y（验证session）、TokenFlag=N（不验证token），与系统其他基础数据管理接口保持一致。

#### Scenario: Session和Token配置
- **WHEN** 接口注册完成
- **THEN** 6条记录的SessionFlag均为Y，TokenFlag均为N，确保接口调用时验证用户登录状态但不要求Token

### Requirement: 重复注册防护
系统 SHALL 在插入接口记录前检查Code是否已存在，已存在的记录不重复插入。

#### Scenario: 重复Code跳过
- **WHEN** 执行注册脚本时CB_MapInterface表中已存在相同Code的记录
- **THEN** 跳过该条记录的插入，不报错不覆盖
