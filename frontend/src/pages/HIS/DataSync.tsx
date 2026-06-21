import React, { useState } from 'react';
import {
  Table,
  Card,
  Button,
  Space,
  Modal,
  Descriptions,
  message,
  DatePicker,
} from 'antd';
import zhCN from 'antd/es/date-picker/locale/zh_CN';
import 'dayjs/locale/zh-cn';
import dayjs from 'dayjs';
import { ReloadOutlined, EyeOutlined } from '@ant-design/icons';
import { getHisInpatientList, querySyncedPatients, queryPatientDetail } from '../../api/hisData';

dayjs.locale('zh-cn');

const { RangePicker } = DatePicker;

const DataSync: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [queryParams, setQueryParams] = useState<{ stDate: string; endDate: string }>({
    stDate: '',
    endDate: '',
  });
  const [patientData, setPatientData] = useState<any[]>([]);
  const [admInfoModalVisible, setAdmInfoModalVisible] = useState(false);
  const [admInfo, setAdmInfo] = useState<any>(null);

  /** 刷新按钮：先调用02010067获取HIS住院患者列表，再调用02010075查询已同步患者 */
  const handleRefresh = async () => {
    if (!queryParams.stDate || !queryParams.endDate) {
      message.warning('请选择开始日期和结束日期');
      return;
    }
    setLoading(true);
    try {
      // 1. 先调用02010067获取HIS住院患者数据（会自动保存到本地）
      message.loading('正在从HIS获取患者数据...', 0);
      const syncRes = await getHisInpatientList(queryParams);
      message.destroy();
      
      if (syncRes.errorCode === '0') {
        message.success('HIS数据获取成功，正在查询已同步患者...');
        
        // 2. 再调用02010075查询已同步患者列表
        const queryParamsForSynced = {
          admDateStart: queryParams.stDate,
          admDateEnd: queryParams.endDate,
        };
        const pagination = { pageSize: 100, currentPage: 1 };
        
        const queryRes = await querySyncedPatients(queryParamsForSynced, pagination);
        
        if (queryRes.errorCode === '0' && queryRes.result) {
          const rows = queryRes.result.rows.map((item: any) => ({
            ...item,
            key: item.admissionNo || item.admID,
          }));
          setPatientData(rows);
          message.success(`成功获取${rows.length}条已同步患者数据`);
        } else {
          message.error(queryRes.errorMessage || '查询已同步患者失败');
        }
      } else {
        message.error(syncRes.errorMessage || '获取HIS患者数据失败');
      }
    } catch {
      message.error('网络异常');
    } finally {
      setLoading(false);
    }
  };

  /** 查看就诊详情：调用02010076接口 */
  const handleViewAdmInfo = async (record: any) => {
    try {
      message.loading('获取就诊详情...', 0);
      // 使用admissionNo作为admID参数
      const admID = record.admissionNo || record.admID;
      const res = await queryPatientDetail({ admID });
      message.destroy();
      if (res.errorCode === '0' && res.result) {
        setAdmInfo(res.result);
        setAdmInfoModalVisible(true);
      } else {
        message.error(res.errorMessage || '获取就诊详情失败');
      }
    } catch {
      message.destroy();
      message.error('网络异常');
    }
  };

  const columns = [
    {
      title: '就诊号',
      dataIndex: 'admissionNo',
      key: 'admissionNo',
      width: 120,
      fixed: 'left' as const,
    },
    {
      title: '患者姓名',
      dataIndex: 'patientName',
      key: 'patientName',
      width: 120,
    },
    {
      title: '病案号',
      dataIndex: 'medicalRecordNo',
      key: 'medicalRecordNo',
      width: 120,
    },
    {
      title: '性别',
      dataIndex: 'sexDesc',
      key: 'sexDesc',
      width: 80,
    },
    {
      title: '入院时间',
      dataIndex: 'admissionDate',
      key: 'admissionDate',
      width: 160,
    },
    {
      title: '在院科室',
      dataIndex: 'department',
      key: 'department',
      width: 120,
    },
    {
      title: '主管医生',
      dataIndex: 'doctor',
      key: 'doctor',
      width: 120,
    },
    {
      title: '主诊断',
      dataIndex: 'mainDiagnosis',
      key: 'mainDiagnosis',
      width: 250,
      ellipsis: true,
    },
    {
      title: '主诊断编码',
      dataIndex: 'mainDiagnosisCode',
      key: 'mainDiagnosisCode',
      width: 120,
    },
    {
      title: '主手术编码',
      dataIndex: 'mainProcedureCode',
      key: 'mainProcedureCode',
      width: 120,
    },
    {
      title: '总费用',
      dataIndex: 'SumAmt',
      key: 'SumAmt',
      width: 100,
    },
    {
      title: '住院天数',
      dataIndex: 'admInDays',
      key: 'admInDays',
      width: 100,
    },
    {
      title: '操作',
      key: 'action',
      width: 120,
      fixed: 'right' as const,
      render: (_: any, record: any) => (
        <Space size="small">
          <Button
            type="link"
            size="small"
            icon={<EyeOutlined />}
            onClick={() => handleViewAdmInfo(record)}
          >
            详情
          </Button>
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: 24, background: '#f0f2f5', minHeight: '100%' }}>
      <Card>
        <div style={{ marginBottom: 16 }}>
          <Space size="middle">
            <RangePicker
              onChange={(_dates, dateStrings) => {
                setQueryParams({ stDate: dateStrings[0], endDate: dateStrings[1] || '' });
              }}
              style={{ width: 400 }}
              placeholder={['开始日期', '结束日期']}
              locale={zhCN}
              format="YYYY-MM-DD"
            />
            <Button
              type="primary"
              icon={<ReloadOutlined />}
              onClick={handleRefresh}
              loading={loading}
            >
              刷新
            </Button>
          </Space>
        </div>

        <Table
          columns={columns}
          dataSource={patientData}
          loading={loading}
          scroll={{ x: 1400 }}
          pagination={false}
        />
      </Card>

      {/* 就诊信息弹窗 */}
      <Modal
        title="患者就诊详情"
        open={admInfoModalVisible}
        onCancel={() => setAdmInfoModalVisible(false)}
        footer={null}
        width={1000}
      >
        {admInfo && admInfo.admInfo && (
          <>
            <Descriptions title="就诊信息" bordered column={2} size="small" style={{ marginBottom: 16 }}>
              <Descriptions.Item label="就诊号">{admInfo.admInfo.admissionNo}</Descriptions.Item>
              <Descriptions.Item label="患者姓名">{admInfo.admInfo.patientName}</Descriptions.Item>
              <Descriptions.Item label="病案号">{admInfo.admInfo.medicalRecordNo}</Descriptions.Item>
              <Descriptions.Item label="性别">{admInfo.admInfo.sexDesc}</Descriptions.Item>
              <Descriptions.Item label="入院时间">{admInfo.admInfo.admDateTime}</Descriptions.Item>
              <Descriptions.Item label="在院科室">{admInfo.admInfo.inLocDesc}</Descriptions.Item>
              <Descriptions.Item label="主管医生">{admInfo.admInfo.admDocDesc}</Descriptions.Item>
              <Descriptions.Item label="住院天数">{admInfo.admInfo.admInDays}</Descriptions.Item>
            </Descriptions>
            
            <Descriptions title="诊断列表" bordered column={1} size="small" style={{ marginBottom: 16 }}>
              {admInfo.diseList && admInfo.diseList.map((dise: any, index: number) => (
                <Descriptions.Item key={index} label={dise.mainFlag === 'Y' ? '主诊断' : `其他诊断${index + 1}`}>
                  {dise.diseCode} - {dise.diseName}
                </Descriptions.Item>
              ))}
            </Descriptions>
            
            <Descriptions title="手术列表" bordered column={1} size="small">
              {admInfo.oprnList && admInfo.oprnList.map((oprn: any, index: number) => (
                <Descriptions.Item key={index} label={oprn.mainFlag === 'Y' ? '主手术' : `其他手术${index + 1}`}>
                  {oprn.oprnCode} - {oprn.oprnName} ({oprn.oprnDate})
                </Descriptions.Item>
              ))}
            </Descriptions>
          </>
        )}
      </Modal>
    </div>
  );
};

export default DataSync;
