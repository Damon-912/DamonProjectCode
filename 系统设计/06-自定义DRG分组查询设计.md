# 自定义DRG分组查询设计文档

## 1. 功能概述

自定义DRG分组查询功能允许用户手动输入患者就诊信息（诊断、手术、年龄等），模拟DRG分组计算过程，实时获取分组结果。用于病案预分组、分组规则测试、教学演示等场景。

## 2. 菜单配置

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

## 3. 后端接口设计

### 3.1 自定义DRG分组接口（Code: 02010010）

```objectscript
ClassMethod CustomDRGGroup(jsonObj) As %Library.DynamicObject
{
    new (jsonObj)
    set resultObj = {"errorCode":"0","errorMessage":"","result":{}}
    
    try {
        set params = jsonObj.params.%Get(0)
        
        // 构建病案对象
        set medicalRecord = {}
        set medicalRecord.age = params.age                    // 年龄
        set medicalRecord.gender = params.gender              // 性别
        set medicalRecord.newbornDays = params.newbornDays    // 新生儿天数
        set medicalRecord.admissionDate = params.admissionDate // 入院日期
        set medicalRecord.dischargeDate = params.dischargeDate // 出院日期
        set medicalRecord.hospitalDays = params.hospitalDays  // 住院天数
        set medicalRecord.totalCost = params.totalCost        // 总费用
        set medicalRecord.department = params.department      // 科室
        
        // 主要诊断
        set medicalRecord.principalDiagnosis = params.principalDiagnosis
        
        // 次要诊断数组
        set medicalRecord.secondaryDiagnoses = params.secondaryDiagnoses
        
        // 合并症/并发症
        set medicalRecord.complications = params.complications
        
        // 主要手术
        set medicalRecord.principalProcedure = params.principalProcedure
        
        // 次要手术数组
        set medicalRecord.secondaryProcedures = params.secondaryProcedures
        
        // 调用分组引擎
        set groupResult = ##class(src.DRG.GroupDevice).DeviceByCustomInput(medicalRecord)
        
        set resultObj.result = groupResult
    }
    catch(e) {
        set resultObj.errorCode = "02010010"
        set resultObj.errorMessage = "分组计算失败："_e.DisplayString()
    }
    
    quit resultObj
}
```

### 3.2 接口返回数据结构

```json
{
    "errorCode": "0",
    "errorMessage": "",
    "result": {
        "drgCode": "FB19",
        "drgName": "急性心肌梗死，不伴合并症与伴随病",
        "mdcCode": "F",
        "mdcName": "循环系统疾病",
        "adrgCode": "FB1",
        "adrgName": "急性心肌梗死",
        "weight": 1.234,
        "benchmarkCost": 24680.00,
        "ccFlag": false,
        "mccFlag": false,
        "riskLevel": "低",
        "groupingPath": "MDCF → FB1 → FB19",
        "groupingTime": "2024-01-22T14:30:00"
    }
}
```

## 4. CB_MapInterface注册

| Code | Descripts | ClassName | MethodName | ServiceType |
|------|-----------|-----------|------------|-------------|
| 02010010 | 自定义DRG分组查询 | src.DRG.GroupDevice | CustomDRGGroup | S |

## 5. 前端页面设计

### 5.1 页面布局

```typescript
// pages/DRG/CustomQuery/index.tsx
import React, { useState } from 'react';
import { 
  Card, Form, Input, Select, DatePicker, InputNumber, 
  Button, Space, Divider, Alert, Tag, Descriptions,
  Row, Col
} from 'antd';
import { SearchOutlined, ReloadOutlined, PlusOutlined, MinusCircleOutlined } from '@ant-design/icons';
import { customDRGGroup } from '@/api/grouping';
import dayjs from 'dayjs';

const { Option } = Select;
const { TextArea } = Input;

const DRGCustomQuery: React.FC = () => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);

  // 执行分组查询
  const handleSubmit = async (values: any) => {
    setLoading(true);
    try {
      const params = {
        age: values.age,
        gender: values.gender,
        newbornDays: values.newbornDays,
        admissionDate: values.admissionDate?.format('YYYY-MM-DD'),
        dischargeDate: values.dischargeDate?.format('YYYY-MM-DD'),
        hospitalDays: values.hospitalDays,
        totalCost: values.totalCost,
        department: values.department,
        principalDiagnosis: values.principalDiagnosis,
        secondaryDiagnoses: values.secondaryDiagnoses?.filter((d: string) => d) || [],
        complications: values.complications,
        principalProcedure: values.principalProcedure,
        secondaryProcedures: values.secondaryProcedures?.filter((p: string) => p) || []
      };

      const res = await customDRGGroup(params);
      if (res.errorCode === '0') {
        setResult(res.result);
      }
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
        </Space>
      }
    >
      <Alert
        message="提示"
        description="请确保输入的诊断和手术编码符合CHS-DRG分组标准。建议使用标准的ICD-10和ICD-9-CM-3编码。"
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
          complications: '无'
        }}
      >
        {/* 患者基本信息 */}
        <Card title="患者基本信息" size="small" style={{ marginBottom: 16 }}>
          <Row gutter={16}>
            <Col span={8}>
              <Form.Item 
                name="age" 
                label="年龄" 
                rules={[{ required: true, message: '请输入年龄' }]}
              >
                <InputNumber style={{ width: '100%' }} min={0} max={150} placeholder="如：45" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item 
                name="gender" 
                label="性别" 
                rules={[{ required: true }]}
              >
                <Select placeholder="请选择性别">
                  <Option value="1">男</Option>
                  <Option value="2">女</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="newbornDays" label="新生儿天数">
                <InputNumber style={{ width: '100%' }} min={0} placeholder="新生儿请填写" />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="admissionDate" label="入院日期">
                <DatePicker style={{ width: '100%' }} placeholder="请选择入院日期" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="dischargeDate" label="出院日期">
                <DatePicker style={{ width: '100%' }} placeholder="请选择出院日期" />
              </Form.Item>
            </Col>
          </Row>
        </Card>

        {/* 诊断信息 */}
        <Card title="诊断信息" size="small" style={{ marginBottom: 16 }}>
          <Form.Item 
            name="principalDiagnosis" 
            label={
              <Space>
                主要诊断
                <span style={{ color: '#ff4d4f' }}>*</span>
              </Space>
            }
            rules={[{ required: true, message: '请输入主要诊断编码' }]}
          >
            <Input placeholder="请输入主要诊断编码或名称，如：I21.0 急性前壁心肌梗死" />
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
                      <Form.Item
                        {...field}
                        noStyle
                      >
                        <Input 
                          placeholder={`其他诊断 ${index + 1}`} 
                          style={{ width: 400 }}
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
                    style={{ width: 400 }}
                  >
                    添加其他诊断
                  </Button>
                </Form.Item>
              </>
            )}
          </Form.List>

          <Form.Item name="complications" label="合并症/并发症">
            <Select placeholder="请选择">
              <Option value="无">无</Option>
              <Option value="CC">合并症(CC)</Option>
              <Option value="MCC">严重合并症(MCC)</Option>
            </Select>
          </Form.Item>
        </Card>

        {/* 手术操作信息 */}
        <Card title="手术操作信息" size="small" style={{ marginBottom: 16 }}>
          <Form.Item 
            name="principalProcedure" 
            label={
              <Space>
                主要手术/操作
              </Space>
            }
          >
            <Input placeholder="请输入主要手术编码或名称，如：51.23 腹腔镜胆囊切除术" />
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
                          placeholder={`其他手术 ${index + 1}`} 
                          style={{ width: 400 }}
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
                    style={{ width: 400 }}
                  >
                    添加其他手术/操作
                  </Button>
                </Form.Item>
              </>
            )}
          </Form.List>
        </Card>

        {/* 住院信息 */}
        <Card title="住院信息" size="small" style={{ marginBottom: 24 }}>
          <Row gutter={16}>
            <Col span={8}>
              <Form.Item name="hospitalDays" label="住院天数">
                <InputNumber style={{ width: '100%' }} min={0} placeholder="请输入住院天数" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="totalCost" label="总费用">
                <InputNumber 
                  style={{ width: '100%' }} 
                  min={0} 
                  precision={2}
                  prefix="¥"
                  placeholder="请输入总费用"
                />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="department" label="科室">
                <Input placeholder="请输入科室名称" />
              </Form.Item>
            </Col>
          </Row>
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
      {result && (
        <Card 
          title="分组结果" 
          style={{ marginTop: 24 }}
          extra={
            <Tag color="blue" style={{ fontSize: 16, padding: '4px 12px' }}>
              {result.drgCode}
            </Tag>
          }
        >
          <Descriptions bordered column={2}>
            <Descriptions.Item label="DRG名称">{result.drgName}</Descriptions.Item>
            <Descriptions.Item label="MDC">{result.mdcName} ({result.mdcCode})</Descriptions.Item>
            <Descriptions.Item label="ADRG">{result.adrgName} ({result.adrgCode})</Descriptions.Item>
            <Descriptions.Item label="权重">{result.weight}</Descriptions.Item>
            <Descriptions.Item label="基准费用">¥{result.benchmarkCost?.toFixed(2)}</Descriptions.Item>
            <Descriptions.Item label="风险等级">{result.riskLevel}</Descriptions.Item>
            <Descriptions.Item label="分组路径" span={2}>{result.groupingPath}</Descriptions.Item>
          </Descriptions>
        </Card>
      )}
    </Card>
  );
};

export default DRGCustomQuery;
```

## 6. API封装

```typescript
// api/grouping.ts

// 自定义DRG分组查询 (Code: 02010010)
export const customDRGGroup = (params: CustomGroupParams) => {
  return request({
    code: '02010010',
    params: [params]
  });
};

interface CustomGroupParams {
  age: number;
  gender: string;
  newbornDays?: number;
  admissionDate?: string;
  dischargeDate?: string;
  hospitalDays?: number;
  totalCost?: number;
  department?: string;
  principalDiagnosis: string;
  secondaryDiagnoses?: string[];
  complications?: string;
  principalProcedure?: string;
  secondaryProcedures?: string[];
}
```

## 7. 界面特点说明

| 区域 | 组件 | 说明 |
|------|------|------|
| 患者基本信息 | InputNumber + Select + DatePicker | 年龄、性别、新生儿天数、日期选择 |
| 诊断信息 | Input + Form.List | 主要诊断必填，其他诊断可动态添加/删除 |
| 合并症 | Select | 下拉选择：无/CC/MCC |
| 手术信息 | Input + Form.List | 主要手术和其他手术可动态添加 |
| 住院信息 | InputNumber | 住院天数、总费用（带¥前缀） |
| 提示信息 | Alert | 蓝色info提示，说明编码规范 |
| 结果展示 | Card + Descriptions | 分组成功后展示DRG详情 |

## 8. 菜单配置建议

将此功能添加到"DRG业务"菜单下，与其他分组功能并列：

```
DRG业务
├── DRG分组工作台
├── 分组结果查询
├── 批量分组任务
└── 自定义DRG分组查询  ← 新增
```
