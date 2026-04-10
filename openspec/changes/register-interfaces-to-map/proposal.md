## Why

新增的DRG目录信息接口(02010041/02010042/02010043)和ADRG细分规则接口(02010044/02010045/02010046)已在InterFace入口类中定义，但尚未注册到CB_MapInterface接口路由表中。系统通过CB_MapInterface表进行接口路由分发和权限校验，未注册的接口无法被前端正常调用。

## What Changes

- 在CB_MapInterface表中插入6条接口注册记录：
  - 02010041: 查询DRG目录信息 (src.DRG.BasicData.InterFace → GetDRGCataLogList, ServiceType=S)
  - 02010042: 保存DRG目录信息 (src.DRG.BasicData.InterFace → SaveDRGCataLog, ServiceType=A)
  - 02010043: 删除DRG目录信息 (src.DRG.BasicData.InterFace → DeleteDRGCataLog, ServiceType=D)
  - 02010044: 查询ADRG细分规则 (src.DRG.BasicData.InterFace → GetDRGSegmentationRulesList, ServiceType=S)
  - 02010045: 保存ADRG细分规则 (src.DRG.BasicData.InterFace → SaveDRGSegmentationRules, ServiceType=A)
  - 02010046: 删除ADRG细分规则 (src.DRG.BasicData.InterFace → DeleteDRGSegmentationRules, ServiceType=D)

## Capabilities

### New Capabilities
- `interface-registration`: 将新增接口注册到CB_MapInterface路由表，使接口可被系统正常调用

### Modified Capabilities

## Impact

- **数据库**: CB_MapInterface表新增6条记录
- **接口路由**: 6个新接口(02010041-02010046)可通过系统路由机制调用
