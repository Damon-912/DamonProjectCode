# DRG分组工作台前端设计文档

## 1. 功能概述

DRG分组工作台提供病案查询、分组操作、结果展示等功能，对接已有后端接口。

## 2. 页面布局

```
+----------------------------------------------------------+
|  DRG分组工作台                                            |
+----------------------------------------------------------+
|  筛选条件区                                                |
|  出院日期: [开始日期] ~ [结束日期]                         |
|  科室: [下拉选择]  病案号: [输入框]  患者姓名: [输入框]      |
|  分组状态: [全部/已分组/未分组]                            |
|  [查询] [重置] [批量分组] [导出]                           |
+----------------------------------------------------------+
|  统计卡片区                                                |
|  [总病例数] [已分组] [未分组] [分组成功率]                   |
+----------------------------------------------------------+
|  数据表格区                                                |
|  □ | 病案号 | 姓名 | 科室 | 主要诊断 | 主要手术 | DRG | 操作 |
|  分页: [1] [2] [3] ... [10]                                |
+----------------------------------------------------------+
```

## 3. 对接后端接口

### 3.1 查询病案列表（已有接口）

```typescript
// api/medicalRecord.ts
import request from './request';

// Code: 02010027 QueryMedicalRecord
export const queryMedicalRecord = (params: MedicalRecordQueryParams) => {
  return request({
    code: '02010027',
    params: [{
      startDate: params.startDate,
      endDate: params.endDate,
      admCaty: params.department,      // 科室
      medcasNo: params.medicalRecordNo, // 病案号
      psnName: params.patientName,     // 患者姓名
      drg: params.drgStatus,           // DRG分组状态
      admCheck: 'Out'                  // 按出院日期查询
    }],
    pagination: [{
      pageSize: params.pageSize || 50,
      currentPage: params.currentPage || 1
    }]
  });
};

// 接口返回数据类型
interface MedicalRecordResponse {
  errorCode: string;
  errorMessage: string;
  result: {
    total: number;
    rows: Array<{
      mdtrtId: string;        // 医保就诊ID
      psnName: string;        // 患者姓名
      gend: string;           // 性别
      age: number;            // 年龄
      medcasNo: string;       // 病案号
      admCaty: string;        // 科室
      admDate: string;        // 入院日期
      dscgDate: string;       // 出院日期
      iptDays: number;        // 住院天数
      diseInfo: Array<{       // 诊断信息
        diagCode: string;
        diagName: string;
        maindiagFlag: string; // 是否主要诊断
      }>;
      oprnInfo: Array<{       // 手术信息
        oprnOprtCode: string;
        oprnOprtName: string;
        mainOprnFlag: string; // 是否主要手术
      }>;
      drg: string;            // DRG分组结果
    }>;
  };
}
```

### 3.2 执行DRG分组（已有接口）

```typescript
// api/grouping.ts

// Code: 02010001 Device/DRGGroup
// 统一入参格式：DiseInfo 和 OprnInfo 为对象数组
export const performDRGGroup = (params: DRGGroupParams) => {
  return request({
    code: '02010001',
    params: [{
      MainDiagnosisCode: params.MainDiagnosisCode,
      DiseInfo: params.DiseInfo,  // 诊断信息数组 [{MainFlag, DiagSn, DiagCode, DiagName}, ...]
      MainOperationCode: params.MainOperationCode,
      OprnInfo: params.OprnInfo,  // 手术信息数组 [{MainFlag, OprnSn, OprnCode, OprnName}, ...]
      Sex: params.Sex,
      Age: params.Age,
      AgeGroupDays: params.AgeGroupDays,
      NewbornFlag: params.NewbornFlag,
      RespiratorTime: params.RespiratorTime,
      ECMOFlag: params.ECMOFlag,
      TransplantFlag: params.TransplantFlag,
      MarrowTransplantFlag: params.MarrowTransplantFlag,
      HIVFlag: params.HIVFlag,
      TraumaLevel: params.TraumaLevel,
      Department: params.Department,
      HospitalDays: params.HospitalDays,
      TotalCost: params.TotalCost
    }]
  });
};

// 类型定义
interface DRGGroupParams {
  MainDiagnosisCode: string;
  DiseInfo?: Array<{
    MainFlag: number;
    DiagSn: number;
    DiagCode: string;
    DiagName?: string;
  }>;
  MainOperationCode?: string;
  OprnInfo?: Array<{
    MainFlag: string;
    OprnSn: number;
    OprnCode: string;
    OprnName?: string;
  }>;
  Sex?: string;
  Age?: number;
  AgeGroupDays?: number;
  NewbornFlag?: string;
  RespiratorTime?: number;
  ECMOFlag?: string;
  TransplantFlag?: string;
  MarrowTransplantFlag?: string;
  HIVFlag?: string;
  TraumaLevel?: number;
  Department?: string;
  HospitalDays?: number;
  TotalCost?: number;
}

// Code: 02010035 SaveDRGGroupRecord
export const saveGroupRecord = (data: GroupRecordData) => {
  return request({
    code: '02010035',
    params: [data]
  });
};
```

## 4. 前端组件设计

### 4.1 工作台主组件

```typescript
// pages/DRG/Workbench/index.tsx
import React, { useState, useEffect } from 'react';
import { Card, Form, DatePicker, Select, Input, Button, Table, Tag, message } from 'antd';
import { SearchOutlined, ReloadOutlined, PlayCircleOutlined, ExportOutlined } from '@ant-design/icons';
import { queryMedicalRecord, performDRGGroup } from '@/api/medicalRecord';
import { useTable } from '@/hooks/useTable';
import type { ColumnsType } from 'antd/es/table';

const { RangePicker } = DatePicker;
const { Option } = Select;

const DRGWorkbench: React.FC = () => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);
  const [selectedRows, setSelectedRows] = useState<MedicalRecord[]>([]);
  
  const { tableProps, refresh, params } = useTable({
    api: queryMedicalRecord,
    defaultParams: { pageSize: 50, currentPage: 1 }
  });

  // 表格列定义
  const columns: ColumnsType<MedicalRecord> = [
    {
      title: '病案号',
      dataIndex: 'medcasNo',
      width: 120,
      render: (text, record) => (
        <a onClick={() => showDetail(record)}>{text}</a>
      )
    },
    {
      title: '患者姓名',
      dataIndex: 'psnName',
      width: 100
    },
    {
      title: '性别',
      dataIndex: 'gend',
      width: 60,
      render: (text) => text === '1' ? '男' : '女'
    },
    {
      title: '年龄',
      dataIndex: 'age',
      width: 60
    },
    {
      title: '科室',
      dataIndex: 'admCaty',
      width: 120
    },
    {
      title: '入院日期',
      dataIndex: 'admDate',
      width: 110
    },
    {
      title: '出院日期',
      dataIndex: 'dscgDate',
      width: 110
    },
    {
      title: '主要诊断',
      dataIndex: 'diseInfo',
      width: 200,
      render: (diseInfo) => {
        const mainDiag = diseInfo?.find((d: any) => d.maindiagFlag === '1');
        return mainDiag ? `${mainDiag.diagCode} ${mainDiag.diagName}` : '-';
      }
    },
    {
      title: '主要手术',
      dataIndex: 'oprnInfo',
      width: 200,
      render: (oprnInfo) => {
        const mainOprn = oprnInfo?.find((o: any) => o.mainOprnFlag === '1');
        return mainOprn ? `${mainOprn.oprnOprtCode} ${mainOprn.oprnOprtName}` : '-';
      }
    },
    {
      title: 'DRG分组',
      dataIndex: 'drg',
      width: 100,
      render: (drg) => drg ? <Tag color="blue">{drg}</Tag> : <Tag color="default">未分组</Tag>
    },
    {
      title: '操作',
      fixed: 'right',
      width: 120,
      render: (_, record) => (
        <Button 
          type="link" 
          size="small"
          icon={<PlayCircleOutlined />}
          onClick={() => handleGroup(record)}
          disabled={!!record.drg}
        >
          分组
        </Button>
      )
    }
  ];

  // 执行分组
  const handleGroup = async (record: MedicalRecord) => {
    try {
      setLoading(true);
      const result = await performDRGGroup(record.mdtrtId, record.medcasNo);
      if (result.errorCode === '0') {
        message.success('分组成功');
        refresh();
      } else {
        message.error(result.errorMessage || '分组失败');
      }
    } finally {
      setLoading(false);
    }
  };

  // 批量分组
  const handleBatchGroup = async () => {
    if (selectedRows.length === 0) {
      message.warning('请选择要分组的病案');
      return;
    }
    // 批量分组逻辑
  };

  return (
    <Card title="DRG分组工作台">
      {/* 筛选条件 */}
      <Form form={form} layout="inline" style={{ marginBottom: 16 }}>
        <Form.Item name="dateRange" label="出院日期">
          <RangePicker />
        </Form.Item>
        <Form.Item name="department" label="科室">
          <Select placeholder="请选择科室" style={{ width: 120 }} allowClear>
            <Option value="心内科">心内科</Option>
            <Option value="呼吸科">呼吸科</Option>
            {/* ... */}
          </Select>
        </Form.Item>
        <Form.Item name="medicalRecordNo" label="病案号">
          <Input placeholder="请输入病案号" style={{ width: 150 }} />
        </Form.Item>
        <Form.Item name="patientName" label="患者姓名">
          <Input placeholder="请输入姓名" style={{ width: 120 }} />
        </Form.Item>
        <Form.Item name="drgStatus" label="分组状态">
          <Select placeholder="全部" style={{ width: 100 }} allowClear>
            <Option value="">全部</Option>
            <Option value="grouped">已分组</Option>
            <Option value="ungrouped">未分组</Option>
          </Select>
        </Form.Item>
        <Form.Item>
          <Button type="primary" icon={<SearchOutlined />} onClick={refresh}>
            查询
          </Button>
          <Button icon={<ReloadOutlined />} onClick={() => form.resetFields()} style={{ marginLeft: 8 }}>
            重置
          </Button>
        </Form.Item>
      </Form>

      {/* 操作按钮 */}
      <div style={{ marginBottom: 16 }}>
        <Button 
          type="primary" 
          icon={<PlayCircleOutlined />}
          onClick={handleBatchGroup}
          disabled={selectedRows.length === 0}
        >
          批量分组
        </Button>
        <Button icon={<ExportOutlined />} style={{ marginLeft: 8 }}>
          导出
        </Button>
      </div>

      {/* 数据表格 */}
      <Table
        {...tableProps}
        columns={columns}
        rowSelection={{
          type: 'checkbox',
          onChange: (_, rows) => setSelectedRows(rows)
        }}
        rowKey="mdtrtId"
        scroll={{ x: 1400 }}
      />
    </Card>
  );
};

export default DRGWorkbench;
```

### 4.2 病案详情弹窗

```typescript
// components/MedicalRecordDetail/index.tsx
import React from 'react';
import { Modal, Descriptions, Table, Tag } from 'antd';
import type { MedicalRecord } from '@/types/medicalRecord';

interface MedicalRecordDetailProps {
  visible: boolean;
  record: MedicalRecord | null;
  onClose: () => void;
}

const MedicalRecordDetail: React.FC<MedicalRecordDetailProps> = ({ 
  visible, 
  record, 
  onClose 
}) => {
  if (!record) return null;

  const diagnosisColumns = [
    { title: '诊断类型', dataIndex: 'disediagType' },
    { title: '诊断编码', dataIndex: 'diagCode' },
    { title: '诊断名称', dataIndex: 'diagName' },
    { 
      title: '是否主要', 
      dataIndex: 'maindiagFlag',
      render: (v: string) => v === '1' ? <Tag color="red">是</Tag> : '否'
    }
  ];

  return (
    <Modal
      title="病案详情"
      visible={visible}
      onCancel={onClose}
      width={1000}
      footer={null}
    >
      <Descriptions title="基本信息" bordered column={3}>
        <Descriptions.Item label="病案号">{record.medcasNo}</Descriptions.Item>
        <Descriptions.Item label="患者姓名">{record.psnName}</Descriptions.Item>
        <Descriptions.Item label="性别">{record.gend === '1' ? '男' : '女'}</Descriptions.Item>
        <Descriptions.Item label="年龄">{record.age}</Descriptions.Item>
        <Descriptions.Item label="科室">{record.admCaty}</Descriptions.Item>
        <Descriptions.Item label="住院天数">{record.iptDays}</Descriptions.Item>
      </Descriptions>

      <div style={{ marginTop: 16 }}>
        <h4>诊断信息</h4>
        <Table 
          dataSource={record.diseInfo} 
          columns={diagnosisColumns}
          rowKey="diagCode"
          pagination={false}
          size="small"
        />
      </div>

      {/* DRG分组结果 */}
      {record.drg && (
        <div style={{ marginTop: 16 }}>
          <h4>DRG分组结果</h4>
          <Tag color="blue" style={{ fontSize: 16, padding: '4px 8px' }}>
            {record.drg}
          </Tag>
        </div>
      )}
    </Modal>
  );
};

export default MedicalRecordDetail;
```

## 5. TypeScript类型定义

```typescript
// types/medicalRecord.ts

export interface MedicalRecord {
  mdtrtId: string;              // 医保就诊ID
  mdtrtSn: string;              // 就诊流水号
  psnNo: string;                // 个人编号
  psnName: string;              // 患者姓名
  gend: string;                 // 性别
  age: number;                  // 年龄
  medcasNo: string;             // 病案号
  admCaty: string;              // 科室
  admDate: string;              // 入院日期
  dscgDate: string;             // 出院日期
  iptDays: number;              // 住院天数
  diseInfo?: DiagnosisInfo[];   // 诊断信息
  oprnInfo?: OperationInfo[];   // 手术信息
  icuInfo?: ICUInfo[];          // ICU信息
  drg?: string;                 // DRG分组结果
}

export interface DiagnosisInfo {
  diagCode: string;             // 诊断编码
  diagName: string;             // 诊断名称
  disediagType: string;         // 诊断类型
  maindiagFlag: string;         // 主要诊断标志
}

export interface OperationInfo {
  oprnOprtCode: string;         // 手术编码
  oprnOprtName: string;         // 手术名称
  oprnOprtDate: string;         // 手术日期
  mainOprnFlag: string;         // 主要手术标志
}

export interface ICUInfo {
  icuCodeId: string;
  inpoolICUTime: string;
  outICUTime: string;
  nurscareDays: number;
}

export interface MedicalRecordQueryParams {
  startDate?: string;
  endDate?: string;
  department?: string;
  medicalRecordNo?: string;
  patientName?: string;
  drgStatus?: string;
  pageSize?: number;
  currentPage?: number;
}
```
