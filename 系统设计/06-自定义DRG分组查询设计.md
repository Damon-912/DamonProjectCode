# 自定义DRG分组查询设计文档

> 最后更新: 2026-03-19
> 关联接口: 02010001 (DRG分组器 - 统一接口)
> API文件: frontend/src/api/drgGrouping.ts

## 1. 功能概述

自定义DRG分组查询功能允许用户手动输入患者就诊信息（诊断、手术、年龄等），调用统一的 **02010001 DRG分组器** 接口，实时获取分组结果。用于病案预分组、分组规则测试、教学演示等场景。

---

## 2. 统一分组接口规范

### 2.1 接口基本信息

| 属性 | 值 |
|------|------|
| 接口Code | **02010001** |
| 接口名称 | DRG分组器（统一接口） |
| 服务类 | src.DRG.Interface |
| 方法名 | Device |
| 实际调用 | src.DRG.GroupDevice.Device() |

### 2.2 统一入参规范

```typescript
// 统一入参类型定义 (frontend/src/api/drgGrouping.ts)

// 诊断信息（对象数组格式）
interface DiagnosisInfo {
  MainFlag: number;      // 主诊断标志：1=主诊断，0=其他诊断
  DiagSn: number;        // 诊断序号
  DiagCode: string;      // 诊断代码（ICD-10）
  DiagName?: string;     // 诊断名称
}

// 手术信息（对象数组格式）
interface OperationInfo {
  MainFlag: string;      // 主手术标志：'1'=主手术，'0'=其他手术
  OprnSn: number;        // 手术序号
  OprnCode: string;      // 手术代码（ICD-9-CM-3）
  OprnName?: string;     // 手术名称
}

interface DRGGroupParams {
  // ========== 核心必填参数 ==========
  MainDiagnosisCode: string;      // 主诊断ICD-10编码（必填）

  // ========== 诊断信息 ==========
  DiseInfo?: DiagnosisInfo[];     // 诊断信息数组（每个包含MainFlag/DiagSn/DiagCode/DiagName）
  MainOperationCode?: string;     // 主手术ICD-9-CM-3编码
  OprnInfo?: OperationInfo[];     // 手术信息数组（每个包含MainFlag/OprnSn/OprnCode/OprnName）
  
  // ========== 患者基本信息 ==========
  Sex?: string;                   // 性别：1=男, 2=女
  Age?: number;                   // 年龄（岁）
  AgeGroupDays?: number;          // 新生儿出生天数（0-28）
  NewbornFlag?: string;           // 新生儿标志：1=是, 0=否
  
  // ========== 特殊情况标志（影响先期分组） ==========
  RespiratorTime?: number;        // 呼吸机时长（≥96h入MDCA）
  ECMOFlag?: string;              // ECMO标志：1=是, 0=否
  TransplantFlag?: string;        // 器官移植标志：1=是, 0=否
  MarrowTransplantFlag?: string;  // 骨髓移植标志：1=是, 0=否
  HIVFlag?: string;               // HIV标志：1=是, 0=否
  TraumaLevel?: number;           // 多发创伤等级（≥2入MDCZ）
  
  // ========== 其他信息 ==========
  Department?: string;            // 科室
  HospitalDays?: number;          // 住院天数
  TotalCost?: number;             // 总费用
}
```

### 2.3 先期分组规则

以下参数会影响先期分组（Pre-MDC）结果：

| 参数条件 | 先期分组 | 说明 |
|----------|----------|------|
| TransplantFlag=1 | **MDCA** | 器官移植病例 |
| MarrowTransplantFlag=1 | **MDCA** | 骨髓移植病例 |
| ECMOFlag=1 | **MDCA** | ECMO治疗病例 |
| RespiratorTime ≥ 96 | **MDCA** | 呼吸机≥96小时 |
| AgeGroupDays 1-28 | **MDCP** | 新生儿疾病 |
| HIVFlag=1 | **MDCY** | HIV感染病例 |
| TraumaLevel ≥ 2 | **MDCZ** | 多发严重创伤 |

### 2.4 返回结果结构

```typescript
interface DRGGroupResult {
  errorCode: string;        // 0=成功
  errorMessage: string;
  result: {
    Code: string;           // DRG编码
    Desc: string;           // DRG名称
    MDC: string;            // MDC代码
    MDCDesc: string;        // MDC描述
    ADRG: string;           // ADRG代码
    ADRGDesc: string;       // ADRG描述
    DRG: string;            // DRG代码
    DRGDesc: string;        // DRG描述
    Weight: number;         // 权重
    BenchmarkCost: number;  // 基准费用
    CCFlag: boolean;        // 是否合并症
    MCCFlag: boolean;       // 是否严重合并症
    RiskLevel: string;      // 风险等级
    CheckTime: string;      // 分组时间
  };
}
```

---

## 3. 前端API封装

### 3.1 API文件位置

```
frontend/src/api/drgGrouping.ts
```

### 3.2 统一分组方法

```typescript
// 统一分组接口
import { drgGroup, DRGGroupParams, DRGGroupResult } from '@/api/drgGrouping';

// 调用示例（使用正确的入参格式）
const params: DRGGroupParams = {
  MainDiagnosisCode: 'I21.0',
  DiseInfo: [
    { MainFlag: 1, DiagSn: 1, DiagCode: 'I21.0', DiagName: '急性心肌梗死' },
    { MainFlag: 0, DiagSn: 2, DiagCode: 'I10', DiagName: '高血压' },
    { MainFlag: 0, DiagSn: 3, DiagCode: 'E11.9', DiagName: '2型糖尿病' }
  ],
  MainOperationCode: '51.23',
  OprnInfo: [
    { MainFlag: '1', OprnSn: 1, OprnCode: '51.23', OprnName: '冠状动脉造影术' }
  ],
  Sex: '1',
  Age: 45,
  AgeGroupDays: 0,
  NewbornFlag: '0',
  RespiratorTime: 0,
  ECMOFlag: '0',
  TransplantFlag: '0',
  MarrowTransplantFlag: '0',
  HIVFlag: '0',
  TraumaLevel: 0,
  Department: '心内科',
  HospitalDays: 10,
  TotalCost: 24680.0
};

const result: DRGGroupResult = await drgGroup(params);
```

### 3.3 数据转换工具函数

```typescript
// 病案数据转换为分组参数
import { convertMedicalRecordToParams } from '@/api/drgGrouping';

const medicalRecord = await queryMedicalRecord({ admissionNo: '12345' });
const params = convertMedicalRecordToParams(medicalRecord);
const result = await drgGroup(params);

// 结算清单数据转换为分组参数
import { convertSettlementToParams } from '@/api/drgGrouping';

const settlement = await querySettlementInfo({ admissionNo: '12345' });
const params = convertSettlementToParams(settlement);
const result = await drgGroup(params);
```

---

## 4. 菜单配置

```typescript
// 在路由配置中添加
{
  path: 'drg',
  meta: { title: 'DRG业务', icon: 'PartitionOutlined' },
  children: [
    // 已有菜单...
    {
      path: 'custom-query',
      element: <DRGCustomQuery />,
      meta: { title: '自定义DRG分组查询', code: 'MENU030', icon: 'SearchOutlined' }
    }
  ]
}
```

---

## 5. 前端页面设计

### 5.1 页面路径

**页面路径**: `/drg/custom-query`

**组件位置**: `pages/DRG/CustomQuery/index.tsx`

### 5.2 页面代码实现

```typescript
// pages/DRG/CustomQuery/index.tsx
import React, { useState } from 'react';
import { 
  Card, Form, Input, Select, DatePicker, InputNumber, 
  Button, Space, Divider, Alert, Tag, Descriptions,
  Row, Col, Tooltip
} from 'antd';
import { 
  SearchOutlined, ReloadOutlined, PlusOutlined, 
  MinusCircleOutlined, InfoCircleOutlined 
} from '@ant-design/icons';
import { 
  drgGroup, 
  DRGGroupParams, 
  DRGGroupResult,
  buildGroupingPath,
  getPreMDCDescription
} from '@/api/drgGrouping';

const { Option } = Select;

const DRGCustomQuery: React.FC = () => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<DRGGroupResult['result'] | null>(null);

  // 执行分组查询
  const handleSubmit = async (values: any) => {
    setLoading(true);
    setResult(null);
    
    try {
      // 构建统一入参
      const params: DRGGroupParams = {
        // 诊断信息
        MainDiagnosisCode: values.mainDiagnosisCode,
        DiseInfo: values.secondaryDiagnoses?.filter((d: string) => d) || [],
        MainOperationCode: values.mainOperationCode || '',
        OprnInfo: values.secondaryProcedures?.filter((p: string) => p) || [],
        
        // 患者基本信息
        Sex: values.gender,
        Age: values.age || 0,
        AgeGroupDays: values.newbornDays || 0,
        NewbornFlag: (values.newbornDays || 0) > 0 ? '1' : '0',
        
        // 特殊情况标志
        RespiratorTime: values.respiratorTime || 0,
        ECMOFlag: values.ecmoFlag ? '1' : '0',
        TransplantFlag: values.transplantFlag ? '1' : '0',
        MarrowTransplantFlag: values.marrowTransplantFlag ? '1' : '0',
        HIVFlag: values.hivFlag ? '1' : '0',
        TraumaLevel: values.traumaLevel || 0,
        
        // 其他信息
        Department: values.department || ''
      };

      // 调用统一分组接口
      const res = await drgGroup(params);
      
      if (res.errorCode === '0' && res.result) {
        setResult(res.result);
      } else {
        // 显示错误信息
        setResult({
          error: true,
          message: res.errorMessage || '分组失败'
        } as any);
      }
    } catch (error) {
      setResult({
        error: true,
        message: '接口调用异常，请重试'
      } as any);
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    form.resetFields();
    setResult(null);
  };

  return (
    <Card 
      title={
        <Space>
          <SearchOutlined />
          <span>自定义DRG分组查询</span>
          <Tooltip title="调用02010001 DRG分组器统一接口">
            <InfoCircleOutlined style={{ color: '#1890ff' }} />
          </Tooltip>
        </Space>
      }
    >
      <Alert
        message="使用说明"
        description={
          <ul style={{ margin: 0, paddingLeft: 16 }}>
            <li>请确保输入的诊断编码为ICD-10标准编码，手术编码为ICD-9-CM-3标准编码</li>
            <li>主诊断为必填项，其他信息根据实际情况填写</li>
            <li>新生儿病例请填写出生天数（1-28天），系统会自动进入MDCP分组</li>
            <li>特殊情况（移植、ECMO等）请勾选相应标志，会影响先期分组结果</li>
          </ul>
        }
        type="info"
        showIcon
        style={{ marginBottom: 24 }}
      />

      <Form
        form={form}
        layout="vertical"
        onFinish={handleSubmit}
        initialValues={{
          gender: '1',
          age: 45
        }}
      >
        {/* 患者基本信息 */}
        <Card title="患者基本信息" size="small" style={{ marginBottom: 16 }}>
          <Row gutter={16}>
            <Col span={6}>
              <Form.Item 
                name="age" 
                label="年龄" 
                rules={[{ required: true, message: '请输入年龄' }]}
              >
                <InputNumber 
                  style={{ width: '100%' }} 
                  min={0} 
                  max={150} 
                  placeholder="如：45"
                />
              </Form.Item>
            </Col>
            <Col span={6}>
              <Form.Item 
                name="gender" 
                label="性别" 
                rules={[{ required: true, message: '请选择性别' }]}
              >
                <Select placeholder="请选择">
                  <Option value="1">男</Option>
                  <Option value="2">女</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={6}>
              <Form.Item name="newbornDays" label="新生儿天数">
                <InputNumber 
                  style={{ width: '100%' }} 
                  min={0} 
                  max={28}
                  placeholder="0-28天"
                />
              </Form.Item>
            </Col>
            <Col span={6}>
              <Form.Item name="respiratorTime" label="呼吸机时长(小时)">
                <InputNumber 
                  style={{ width: '100%' }} 
                  min={0}
                  placeholder="≥96h入MDCA"
                />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={24}>
              <Form.Item label="特殊情况标志">
                <Space>
                  <Form.Item name="ecmoFlag" valuePropName="checked" noStyle>
                    <Select style={{ width: 120 }} placeholder="ECMO">
                      <Option value={false}>无ECMO</Option>
                      <Option value={true}>有ECMO</Option>
                    </Select>
                  </Form.Item>
                  <Form.Item name="transplantFlag" valuePropName="checked" noStyle>
                    <Select style={{ width: 120 }} placeholder="器官移植">
                      <Option value={false}>无移植</Option>
                      <Option value={true}>器官移植</Option>
                    </Select>
                  </Form.Item>
                  <Form.Item name="marrowTransplantFlag" valuePropName="checked" noStyle>
                    <Select style={{ width: 120 }} placeholder="骨髓移植">
                      <Option value={false}>无移植</Option>
                      <Option value={true}>骨髓移植</Option>
                    </Select>
                  </Form.Item>
                  <Form.Item name="hivFlag" valuePropName="checked" noStyle>
                    <Select style={{ width: 120 }} placeholder="HIV">
                      <Option value={false}>无HIV</Option>
                      <Option value={true}>HIV感染</Option>
                    </Select>
                  </Form.Item>
                  <Form.Item name="traumaLevel" noStyle>
                    <InputNumber 
                      style={{ width: 120 }} 
                      min={0} 
                      max={5}
                      placeholder="创伤等级"
                    />
                  </Form.Item>
                </Space>
              </Form.Item>
            </Col>
          </Row>
        </Card>

        {/* 诊断信息 */}
        <Card title="诊断信息" size="small" style={{ marginBottom: 16 }}>
          <Form.Item 
            name="mainDiagnosisCode" 
            label={
              <Space>
                主要诊断编码
                <span style={{ color: '#ff4d4f' }}>*</span>
                <Tooltip title="ICD-10编码，如：I21.0">
                  <InfoCircleOutlined style={{ color: '#1890ff' }} />
                </Tooltip>
              </Space>
            }
            rules={[{ required: true, message: '请输入主要诊断编码' }]}
          >
            <Input placeholder="如：I21.0 急性前壁心肌梗死" />
          </Form.Item>

          <Form.List name="secondaryDiagnoses">
            {(fields, { add, remove }) => (
              <>
                {fields.map((field, index) => (
                  <Form.Item
                    key={field.key}
                    label={index === 0 ? '其他诊断' : ''}
                    required={false}
                  >
                    <Space align="baseline">
                      <Form.Item {...field} noStyle>
                        <Input 
                          placeholder={`其他诊断编码 ${index + 1}`} 
                          style={{ width: 300 }}
                        />
                      </Form.Item>
                      <MinusCircleOutlined 
                        onClick={() => remove(field.name)} 
                        style={{ color: '#999' }}
                      />
                    </Space>
                  </Form.Item>
                ))}
                <Form.Item>
                  <Button 
                    type="dashed" 
                    onClick={() => add()} 
                    icon={<PlusOutlined />}
                    style={{ width: 300 }}
                  >
                    添加其他诊断
                  </Button>
                </Form.Item>
              </>
            )}
          </Form.List>
        </Card>

        {/* 手术操作信息 */}
        <Card title="手术操作信息" size="small" style={{ marginBottom: 16 }}>
          <Form.Item 
            name="mainOperationCode" 
            label={
              <Space>
                主要手术/操作编码
                <Tooltip title="ICD-9-CM-3编码，如：51.23">
                  <InfoCircleOutlined style={{ color: '#1890ff' }} />
                </Tooltip>
              </Space>
            }
          >
            <Input placeholder="如：51.23 腹腔镜胆囊切除术" />
          </Form.Item>

          <Form.List name="secondaryProcedures">
            {(fields, { add, remove }) => (
              <>
                {fields.map((field, index) => (
                  <Form.Item
                    key={field.key}
                    label={index === 0 ? '其他手术/操作' : ''}
                    required={false}
                  >
                    <Space align="baseline">
                      <Form.Item {...field} noStyle>
                        <Input 
                          placeholder={`其他手术编码 ${index + 1}`} 
                          style={{ width: 300 }}
                        />
                      </Form.Item>
                      <MinusCircleOutlined 
                        onClick={() => remove(field.name)} 
                        style={{ color: '#999' }}
                      />
                    </Space>
                  </Form.Item>
                ))}
                <Form.Item>
                  <Button 
                    type="dashed" 
                    onClick={() => add()} 
                    icon={<PlusOutlined />}
                    style={{ width: 300 }}
                  >
                    添加其他手术
                  </Button>
                </Form.Item>
              </>
            )}
          </Form.List>
        </Card>

        {/* 科室信息 */}
        <Card title="其他信息" size="small" style={{ marginBottom: 24 }}>
          <Form.Item name="department" label="科室">
            <Input placeholder="请输入科室名称或编码" />
          </Form.Item>
        </Card>

        {/* 操作按钮 */}
        <Form.Item style={{ marginBottom: 0 }}>
          <Space size="middle">
            <Button 
              type="primary" 
              htmlType="submit" 
              icon={<SearchOutlined />}
              loading={loading}
              size="large"
            >
              执行分组查询
            </Button>
            <Button 
              icon={<ReloadOutlined />}
              onClick={handleReset}
              size="large"
            >
              重置
            </Button>
          </Space>
        </Form.Item>
      </Form>

      {/* 分组结果 */}
      {result && !(result as any).error && (
        <Card 
          title="分组结果" 
          style={{ marginTop: 24 }}
          extra={
            <Tag color="blue" style={{ fontSize: 16, padding: '4px 12px' }}>
              {result.DRG}
            </Tag>
          }
        >
          <Descriptions bordered column={2}>
            <Descriptions.Item label="DRG名称" span={2}>
              {result.DRGDesc}
            </Descriptions.Item>
            <Descriptions.Item label="MDC">
              {result.MDCDesc} ({result.MDC})
            </Descriptions.Item>
            <Descriptions.Item label="ADRG">
              {result.ADRGDesc} ({result.ADRG})
            </Descriptions.Item>
            <Descriptions.Item label="权重">
              {result.Weight}
            </Descriptions.Item>
            <Descriptions.Item label="基准费用">
              ¥{(result.BenchmarkCost || 0).toFixed(2)}
            </Descriptions.Item>
            <Descriptions.Item label="风险等级">
              {result.RiskLevel}
            </Descriptions.Item>
            <Descriptions.Item label="分组路径" span={2}>
              {buildGroupingPath(result)}
            </Descriptions.Item>
            <Descriptions.Item label="先期分组说明" span={2}>
              {getPreMDCDescription({
                TransplantFlag: '0',
                MarrowTransplantFlag: '0',
                ECMOFlag: '0',
                NewbornFlag: '0',
                HIVFlag: '0',
                ...result
              } as any)}
            </Descriptions.Item>
          </Descriptions>
        </Card>
      )}

      {/* 错误提示 */}
      {result && (result as any).error && (
        <Alert
          message="分组失败"
          description={(result as any).message}
          type="error"
          showIcon
          style={{ marginTop: 24 }}
        />
      )}
    </Card>
  );
};

export default DRGCustomQuery;
```

---

## 6. 界面功能说明

| 区域 | 组件 | 说明 |
|------|------|------|
| 患者基本信息 | InputNumber + Select | 年龄、性别、新生儿天数、呼吸机时长 |
| 特殊情况标志 | Select组合 | ECMO、移植、HIV、创伤等级（影响先期分组） |
| 诊断信息 | Input + Form.List | 主诊断必填（ICD-10），其他诊断可动态添加 |
| 手术信息 | Input + Form.List | 主手术（ICD-9-CM-3），其他手术可动态添加 |
| 其他信息 | Input | 科室等辅助信息 |
| 提示信息 | Alert | 使用说明和编码规范提示 |
| 结果展示 | Card + Descriptions | 分组成功后展示MDC/ADRG/DRG详情及分组路径 |
| 错误提示 | Alert | 分组失败时显示错误信息 |

---

## 7. 菜单配置建议

将此功能添加到"DRG业务"菜单下：

```
DRG业务
├── DRG分组工作台        (调用02010001，病案数据转换)
├── 分组结果查询
├── 批量分组任务          (调用02010001，批量转换)
└── 自定义DRG分组查询     ← 新增 (直接调用02010001)
```

**所有分组功能统一调用 02010001 接口，仅入参来源不同：**
- 病案分组：`病案数据 → convertMedicalRecordToParams() → 02010001`
- 结算清单分组：`结算清单数据 → convertSettlementToParams() → 02010001`
- 自定义分组：`用户输入 → 直接构建DRGGroupParams → 02010001`

---

## 8. CB_MapInterface注册

| Code | Descripts | ClassName | MethodName | ServiceType |
|------|-----------|-----------|------------|-------------|
| 02010001 | DRG分组器（统一接口） | src.DRG.Interface | Device | S |

---

## 9. 注意事项

1. **统一接口**: 所有分组功能必须使用 `drgGroup()` 统一方法调用 02010001 接口
2. **入参规范**: 严格遵循 `DRGGroupParams` 类型定义，参数名区分大小写
3. **主诊断必填**: `MainDiagnosisCode` 不能为空，否则分组失败
4. **编码规范**: 
   - 诊断编码使用 ICD-10 标准
   - 手术编码使用 ICD-9-CM-3 标准
5. **先期分组**: 移植、ECMO、新生儿等特殊情况会影响 MDC 分组结果
6. **数据转换**: 病案/结算清单分组时，必须使用提供的转换函数 `convertMedicalRecordToParams()` / `convertSettlementToParams()`
