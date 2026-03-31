# Design: 新增基础数据管理模块

## 1. 菜单结构变更

### 1.1 变更前

```
导航栏
├── 监控仪表盘
├── DRG业务
├── DIP业务
├── 费用预警
├── 盈亏分析
├── 病案质控
├── 数据管理
├── 分组规则
└── 系统管理
    ├── 用户管理
    ├── 角色权限
    ├── 菜单配置
    ├── 接口服务配置  ← 待移动
    └── 接口日志      ← 待移动
```

### 1.2 变更后

```
导航栏
├── 监控仪表盘
├── DRG业务
├── DIP业务
├── 费用预警
├── 盈亏分析
├── 病案质控
├── 数据管理
├── 分组规则
├── 基础数据管理          ← 新增一级菜单
│   ├── DRG基础数据维护    ← 新增
│   ├── ICD编码映射        ← 新增
│   ├── ICD编码查询        ← 新增
│   ├── ADRG分组规则维护    ← 新增
│   ├── 接口服务配置        ← 从系统管理移入
│   └── 接口日志            ← 从系统管理移入
└── 系统管理
    ├── 用户管理
    ├── 角色权限
    └── 菜单配置
```

## 2. 技术设计

### 2.1 App.tsx 菜单配置

在 `menuItems` 数组中，在 `rules`（分组规则）之后、`system`（系统管理）之前插入：

```typescript
{
  key: 'basicData',
  icon: <ContainerOutlined />,
  label: '基础数据管理',
  children: [
    { key: 'basic-data-maintenance', label: 'DRG基础数据维护' },
    { key: 'basic-data-icd-mapping', label: 'ICD编码映射' },
    { key: 'basic-data-icd-query', label: 'ICD编码查询' },
    { key: 'basic-data-adrg-rules', label: 'ADRG分组规则维护' },
    { key: 'basic-data-api-config', label: '接口服务配置' },
    { key: 'basic-data-api-logs', label: '接口日志' },
  ],
},
```

同时从 `system` 的 `children` 中移除 `system-api` 和 `system-logs`。

### 2.2 新增页面组件

#### 2.2.1 DRG基础数据维护 (BasicDataMaintenance.tsx)

- **功能**: 维护DRG标准库基础数据（版本、地区费率等）
- **路由key**: `basic-data-maintenance`
- **主要操作**: 查询、新增、编辑、删除
- **接口**: 02010010-保存DRG基础数据

#### 2.2.2 ICD编码映射 (ICDMapping.tsx)

- **功能**: 管理ICD编码在不同版本间的映射关系
- **路由key**: `basic-data-icd-mapping`
- **主要操作**: 查询、新增、编辑、删除、导入
- **接口**: 02010022-查询ICD映射

#### 2.2.3 ICD编码查询 (ICDQuery.tsx)

- **功能**: ICD-10诊断编码和ICD-9-CM-3手术编码查询
- **路由key**: `basic-data-icd-query`
- **主要操作**: 搜索、筛选、查看详情
- **接口**: 02010037-查询ICD编码

#### 2.2.4 ADRG分组规则维护 (ADRGRuleMaintenance.tsx)

- **功能**: ADRG分组规则的配置和管理
- **路由key**: `basic-data-adrg-rules`
- **主要操作**: 查询、新增、编辑、删除、排序
- **接口**: 02010016-保存ADRG规则

#### 2.2.5 接口服务配置 & 接口日志

- **接口服务配置**: 从 `system-api` 迁移，key 改为 `basic-data-api-config`
- **接口日志**: 从 `system-logs` 迁移，key 改为 `basic-data-api-logs`
- **原有接口映射管理功能**（interface-mapping-management change 中已设计）可合并到此模块下

### 2.3 图标选择

- 使用 `ContainerOutlined`（容器图标）作为"基础数据管理"模块图标
- 需在 App.tsx 顶部 import 中新增 `ContainerOutlined`

## 3. 页面骨架设计

所有新增页面采用统一的骨架布局：

```typescript
import { Card, Table, Button, Space, Input, Form, Modal, message } from 'antd';

export default function PageName() {
  // 状态管理
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState([]);
  
  return (
    <div style={{ padding: 24 }}>
      {/* 搜索区域 */}
      <Card style={{ marginBottom: 16 }}>
        <Form layout="inline">
          {/* 搜索条件 */}
        </Form>
      </Card>
      
      {/* 数据表格 */}
      <Card title="页面标题">
        <Table columns={columns} dataSource={data} loading={loading} />
      </Card>
    </div>
  );
}
```

## 4. 数据接口设计

### 4.1 DRG基础数据维护

**查询请求参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| dataCode | String | 否 | 数据编码 |
| dataName | String | 否 | 数据名称 |
| dataType | String | 否 | 数据类型 |
| version | String | 否 | 版本号 |
| page | Number | 否 | 页码 |
| limit | Number | 否 | 每页条数 |

### 4.2 ICD编码映射

**查询请求参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| sourceCode | String | 否 | 源编码 |
| targetCode | String | 否 | 目标编码 |
| sourceVersion | String | 否 | 源版本 |
| targetVersion | String | 否 | 目标版本 |
| codeType | String | 否 | 编码类型：diagnosis/operation |
| page | Number | 否 | 页码 |
| limit | Number | 否 | 每页条数 |

### 4.3 ICD编码查询

**查询请求参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| keyword | String | 否 | 关键词（编码或名称模糊搜索） |
| codeType | String | 否 | 编码类型：icd10/icd9cm3 |
| categoryCode | String | 否 | 分类编码 |
| page | Number | 否 | 页码 |
| limit | Number | 否 | 每页条数 |

### 4.4 ADRG分组规则维护

**查询请求参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| mdcCode | String | 否 | MDC编码 |
| adrgCode | String | 否 | ADRG编码 |
| ruleType | String | 否 | 规则类型 |
| isActive | String | 否 | 是否启用 |
| page | Number | 否 | 页码 |
| limit | Number | 否 | 每页条数 |
