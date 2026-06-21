import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Input, Space, Tag, message, Descriptions, Modal, DatePicker, Tabs
} from 'antd';
import zhCN from 'antd/es/date-picker/locale/zh_CN';
import { SearchOutlined, ReloadOutlined, EyeOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import CustomPagination from '../../components/CustomPagination';
import { querySyncedPatients, queryPatientDetail } from '../../api/hisData';
import dayjs from 'dayjs';
import 'dayjs/locale/zh-cn';
dayjs.locale('zh-cn');

interface SyncedPatient {
  admissionNo: string;
  medicalRecordNo: string;
  patientName: string;
  sex: string;
  age: number;
  department: string;
  doctor: string;
  mainDiagnosisCode: string;
  mainDiagnosisName: string;
  mainProcedureCode: string;
  mainProcedureName: string;
  totalCost: number;
  admissionDate: string;
  dischargeDate: string;
}

const SyncedPatients: React.FC = () => {
  const [data, setData] = useState<SyncedPatient[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  const [patientName, setPatientName] = useState('');
  const [medicalRecordNo, setMedicalRecordNo] = useState('');
  const [admDateStart, setAdmDateStart] = useState('');
  const [admDateEnd, setAdmDateEnd] = useState('');
  const [detailVisible, setDetailVisible] = useState(false);
  const [detailLoading, setDetailLoading] = useState(false);
  const [patientDetail, setPatientDetail] = useState<any>(null);

  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await querySyncedPatients({
        patientName: patientName || undefined,
        medicalRecordNo: medicalRecordNo || undefined,
        admDateStart: admDateStart || undefined,
        admDateEnd: admDateEnd || undefined,
      }, { pageSize: size, currentPage: page });
      if (res.errorCode === '0' && res.result) {
        setData(res.result.rows || []);
        setTotal(res.result.total || 0);
      } else {
        message.error(res.errorMessage || '查询失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setLoading(false);
    }
  }, [patientName, medicalRecordNo, admDateStart, admDateEnd, currentPage, pageSize]);

  useEffect(() => {
    fetchData(1);
  }, []);

  const handleSearch = () => {
    setCurrentPage(1);
    fetchData(1);
  };

  const handleReset = () => {
    setPatientName('');
    setMedicalRecordNo('');
    setAdmDateStart('');
    setAdmDateEnd('');
    setCurrentPage(1);
    fetchData(1);
  };

  const handleViewDetail = async (record: SyncedPatient) => {
    setDetailVisible(true);
    setDetailLoading(true);
    try {
      const res = await queryPatientDetail({ admID: record.admissionNo });
      if (res.errorCode === '0' && res.result) {
        setPatientDetail(res.result);
      } else {
        message.error(res.errorMessage || '获取详情失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setDetailLoading(false);
    }
  };

  const columns: ColumnsType<SyncedPatient> = [
    {
      title: '就诊号',
      dataIndex: 'admissionNo',
      key: 'admissionNo',
      width: 120,
      fixed: 'left',
    },
    {
      title: '病案号',
      dataIndex: 'medicalRecordNo',
      key: 'medicalRecordNo',
      width: 120,
    },
    {
      title: '患者姓名',
      dataIndex: 'patientName',
      key: 'patientName',
      width: 100,
    },
    {
      title: '性别',
      dataIndex: 'sex',
      key: 'sex',
      width: 60,
      render: (sex: string) => sex === '1' ? '男' : '女',
    },
    {
      title: '年龄',
      dataIndex: 'age',
      key: 'age',
      width: 60,
    },
    {
      title: '科室',
      dataIndex: 'department',
      key: 'department',
      width: 100,
    },
    {
      title: '主管医生',
      dataIndex: 'doctor',
      key: 'doctor',
      width: 100,
    },
    {
      title: '主诊断编码',
      dataIndex: 'mainDiagnosisCode',
      key: 'mainDiagnosisCode',
      width: 120,
    },
    {
      title: '主诊断名称',
      dataIndex: 'mainDiagnosisName',
      key: 'mainDiagnosisName',
      width: 200,
      ellipsis: true,
    },
    {
      title: '主手术编码',
      dataIndex: 'mainProcedureCode',
      key: 'mainProcedureCode',
      width: 120,
    },
    {
      title: '主手术名称',
      dataIndex: 'mainProcedureName',
      key: 'mainProcedureName',
      width: 150,
      ellipsis: true,
    },
    {
      title: '总费用',
      dataIndex: 'SumAmt',
      key: 'SumAmt',
      width: 100,
    },
    {
      title: '入院日期',
      dataIndex: 'admissionDate',
      key: 'admissionDate',
      width: 100,
      render: (date: string) => date ? dayjs(date).format('YYYY年MM月DD日') : '-',
    },
    {
      title: '操作',
      key: 'action',
      width: 80,
      fixed: 'right',
      render: (_, record) => (
        <Button type="link" size="small" icon={<EyeOutlined />} onClick={() => handleViewDetail(record)}>
          详情
        </Button>
      ),
    },
  ];

  return (
    <div style={{ padding: 16 }}>
      <Card size="small" style={{ marginBottom: 16 }}>
        <Space wrap>
          <Input
            placeholder="患者姓名"
            value={patientName}
            onChange={e => setPatientName(e.target.value)}
            style={{ width: 120 }}
            allowClear
          />
          <Input
            placeholder="病案号"
            value={medicalRecordNo}
            onChange={e => setMedicalRecordNo(e.target.value)}
            style={{ width: 120 }}
            allowClear
          />
          <DatePicker
            placeholder="入院日期起"
            value={admDateStart ? dayjs(admDateStart, 'YYYY-MM-DD') : null}
            onChange={(_, dateString) => setAdmDateStart(dateString)}
            style={{ width: 120 }}
            locale={zhCN}
            format="YYYY年MM月DD日"
          />
          <DatePicker
            placeholder="入院日期止"
            value={admDateEnd ? dayjs(admDateEnd, 'YYYY-MM-DD') : null}
            onChange={(_, dateString) => setAdmDateEnd(dateString)}
            style={{ width: 120 }}
            locale={zhCN}
            format="YYYY年MM月DD日"
          />
          <Button type="primary" icon={<SearchOutlined />} onClick={handleSearch}>
            查询
          </Button>
          <Button icon={<ReloadOutlined />} onClick={handleReset}>
            重置
          </Button>
        </Space>
      </Card>

      <Card size="small">
        <Table
          columns={columns}
          dataSource={data}
          rowKey="admissionNo"
          loading={loading}
          scroll={{ x: 1500 }}
          size="small"
          pagination={false}
        />
        <div style={{ marginTop: 12, display: 'flex', justifyContent: 'flex-end' }}>
          <CustomPagination
            current={currentPage}
            pageSize={pageSize}
            total={total}
            onChange={(page, size) => {
              setCurrentPage(page);
              setPageSize(size);
              fetchData(page, size);
            }}
          />
        </div>
      </Card>

      <Modal
        title="患者详情"
        open={detailVisible}
        onCancel={() => setDetailVisible(false)}
        footer={null}
        width={800}
        style={{ top: 20 }}
      >
        {detailLoading ? (
          <div style={{ textAlign: 'center', padding: '50px' }}>加载中...</div>
        ) : patientDetail ? (
          <Tabs defaultActiveKey="admInfo">
            <Tabs.TabPane tab="就诊信息" key="admInfo">
              <Descriptions bordered column={2} size="small">
                <Descriptions.Item label="就诊号">{patientDetail.admInfo.admissionNo}</Descriptions.Item>
                <Descriptions.Item label="病案号">{patientDetail.admInfo.medicalRecordNo}</Descriptions.Item>
                <Descriptions.Item label="患者姓名">{patientDetail.admInfo.patientName}</Descriptions.Item>
                <Descriptions.Item label="性别">{patientDetail.admInfo.sexCode === '1' ? '男' : '女'}</Descriptions.Item>
                <Descriptions.Item label="住院号">{patientDetail.admInfo.patNo}</Descriptions.Item>
                <Descriptions.Item label="科室">{patientDetail.admInfo.inLocDesc}</Descriptions.Item>
                <Descriptions.Item label="病区">{patientDetail.admInfo.inWardDesc}</Descriptions.Item>
                <Descriptions.Item label="主管医生">{patientDetail.admInfo.admDocDesc}</Descriptions.Item>
                <Descriptions.Item label="责任护士">{patientDetail.admInfo.admNurDesc}</Descriptions.Item>
                <Descriptions.Item label="入院时间">{patientDetail.admInfo.admDateTime ? dayjs(patientDetail.admInfo.admDateTime).format('YYYY年MM月DD日 HH:mm') : '-'}</Descriptions.Item>
                <Descriptions.Item label="入院天数">{patientDetail.admInfo.admInDays}</Descriptions.Item>
                <Descriptions.Item label="入院诊断">{patientDetail.admInfo.admDiag}</Descriptions.Item>
              </Descriptions>
            </Tabs.TabPane>
            <Tabs.TabPane tab="诊断信息" key="diseInfo">
              <Table
                dataSource={patientDetail.diseList || []}
                rowKey="diseSn"
                size="small"
                pagination={false}
                columns={[
                  { title: '序号', dataIndex: 'diseSn', width: 60 },
                  { title: '主诊断', dataIndex: 'mainFlag', width: 80, render: (val: string) => val === 'Y' ? <Tag color="red">主诊断</Tag> : '' },
                  { title: '诊断编码', dataIndex: 'diseCode', width: 120 },
                  { title: '诊断名称', dataIndex: 'diseName', width: 200, ellipsis: true },
                  { title: '诊断类型', dataIndex: 'diseType', width: 120 },
                ]}
              />
            </Tabs.TabPane>
            <Tabs.TabPane tab="手术信息" key="oprnInfo">
              <Table
                dataSource={patientDetail.oprnList || []}
                rowKey="oprnSn"
                size="small"
                pagination={false}
                columns={[
                  { title: '序号', dataIndex: 'oprnSn', width: 60 },
                  { title: '主手术', dataIndex: 'mainFlag', width: 80, render: (val: string) => val === 'Y' ? <Tag color="blue">主手术</Tag> : '' },
                  { title: '手术编码', dataIndex: 'oprnCode', width: 120 },
                  { title: '手术名称', dataIndex: 'oprnName', width: 200, ellipsis: true },
                  { title: '手术日期', dataIndex: 'oprnDate', width: 120 },
                ]}
              />
            </Tabs.TabPane>
          </Tabs>
        ) : (
          <div style={{ textAlign: 'center', padding: '50px' }}>暂无数据</div>
        )}
      </Modal>
    </div>
  );
};

export default SyncedPatients;
