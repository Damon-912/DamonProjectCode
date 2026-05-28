import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Select, Space, Row, Col,
  Tag, message, DatePicker, Input, Modal, Descriptions, Tabs,
  Divider, List
} from 'antd';
import {
  SearchOutlined, ReloadOutlined, FileExcelOutlined,
  EyeOutlined, UserOutlined, MedicineBoxOutlined,
  PartitionOutlined, DollarOutlined
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import type { Dayjs } from 'dayjs';
import dayjs from 'dayjs';
import {
  queryMedicalRecords, queryMedicalRecordDetail,
  type MedicalRecordItem, type QueryMedicalRecordParams
} from '../../api/hisData';
import CustomPagination from '../../components/CustomPagination';
import { useDict } from '../../hooks/useDict';
import { getDictLabel } from '../../utils/dict';

const { Option } = Select;
const { RangePicker } = DatePicker;
const { TabPane } = Tabs;

// 分组状态颜色映射
const GROUP_STATUS_COLORS: Record<string, string> = { '1': '#52c41a', '0': '#999' };

const MedicalRecords: React.FC = () => {
  // 字典数据
  const { map: groupStatusMap, options: groupStatusOptions } = useDict('GROUPING_STATUS');

  // 列表状态
  const [data, setData] = useState<MedicalRecordItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  
  // 查询条件
  const [queryParams, setQueryParams] = useState<QueryMedicalRecordParams>({});
  
  // 详情弹窗
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [detailRecord, setDetailRecord] = useState<any>(null);

  // 查询列表
  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await queryMedicalRecords({
        admissionNo: queryParams.admissionNo,
        medicalRecordNo: queryParams.medicalRecordNo,
        patientName: queryParams.patientName,
        idCard: queryParams.idCard,
        department: queryParams.department,
        doctor: queryParams.doctor,
        mainDiagnosisCode: queryParams.mainDiagnosisCode,
        drgCode: queryParams.drgCode,
        dipCode: queryParams.dipCode,
        groupStatus: queryParams.groupStatus,
        startDate: queryParams.startDate,
        endDate: queryParams.endDate,
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
  }, [queryParams, currentPage, pageSize]);

  useEffect(() => {
    fetchData(1);
  }, [queryParams]);

  // 查看详情
  const handleViewDetail = async (record: MedicalRecordItem) => {
    try {
      const res = await queryMedicalRecordDetail(record.admissionNo);
      if (res.errorCode === '0' && res.result) {
        setDetailRecord(res.result);
        setDetailModalOpen(true);
      } else {
        message.error(res.errorMessage || '查询详情失败');
      }
    } catch {
      message.error('网络异常');
    }
  };

  // 导出功能
  const handleExport = () => {
    message.info('导出功能开发中...');
  };

  // 表格列定义
  const columns: ColumnsType<MedicalRecordItem> = [
    {
      title: '病案号',
      dataIndex: 'medicalRecordNo',
      width: 120,
      fixed: 'left',
    },
    {
      title: '就诊号',
      dataIndex: 'admissionNo',
      width: 120,
      fixed: 'left',
    },
    {
      title: '患者姓名',
      dataIndex: 'patientName',
      width: 100,
    },
    {
      title: '性别',
      dataIndex: 'sex',
      width: 60,
      render: (v: string) => v === '1' ? '男' : '女',
    },
    {
      title: '年龄',
      dataIndex: 'age',
      width: 60,
    },
    {
      title: '科室',
      dataIndex: 'department',
      width: 100,
    },
    {
      title: '医生',
      dataIndex: 'doctor',
      width: 100,
    },
    {
      title: '主要诊断编码',
      dataIndex: 'mainDiagnosisCode',
      width: 120,
    },
    {
      title: '主要诊断名称',
      dataIndex: 'mainDiagnosisName',
      width: 200,
      ellipsis: true,
    },
    {
      title: '主要手术编码',
      dataIndex: 'mainProcedureCode',
      width: 120,
    },
    {
      title: '主要手术名称',
      dataIndex: 'mainProcedureName',
      width: 150,
      ellipsis: true,
    },
    {
      title: '总费用',
      dataIndex: 'totalCost',
      width: 120,
      align: 'right',
      render: (v: number) => `¥${(v || 0).toFixed(2)}`,
    },
    {
      title: 'DRG编码',
      dataIndex: 'drgCode',
      width: 100,
      render: (v: string, record) => v || record.dipCode || '-',
    },
    {
      title: 'DRG/DIP名称',
      dataIndex: 'drgName',
      width: 200,
      ellipsis: true,
      render: (v, record) => v || record.dipName || '-',
    },
    {
      title: '分组状态',
      dataIndex: 'groupStatus',
      width: 100,
      render: (v: string) => {
        return <Tag color={GROUP_STATUS_COLORS[v] || 'default'}>
          {getDictLabel(groupStatusMap, v, '-')}
        </Tag>;
      },
    },
    {
      title: '入院日期',
      dataIndex: 'admissionDate',
      width: 100,
    },
    {
      title: '出院日期',
      dataIndex: 'dischargeDate',
      width: 100,
    },
    {
      title: '操作',
      key: 'action',
      width: 100,
      fixed: 'right',
      render: (_, record) => (
        <Button type="link" size="small" icon={<EyeOutlined />} onClick={() => handleViewDetail(record)}>
          查看
        </Button>
      ),
    },
  ];

  return (
    <div style={{ padding: 16 }}>
      {/* 查询条件 */}
      <Card size="small" style={{ marginBottom: 16 }}>
        <Row gutter={16} align="middle">
          <Col>
            <Input
              placeholder="病案号"
              value={queryParams.medicalRecordNo}
              onChange={e => setQueryParams({ ...queryParams, medicalRecordNo: e.target.value })}
              style={{ width: 140 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="就诊号"
              value={queryParams.admissionNo}
              onChange={e => setQueryParams({ ...queryParams, admissionNo: e.target.value })}
              style={{ width: 120 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="患者姓名"
              value={queryParams.patientName}
              onChange={e => setQueryParams({ ...queryParams, patientName: e.target.value })}
              style={{ width: 100 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="身份证号"
              value={queryParams.idCard}
              onChange={e => setQueryParams({ ...queryParams, idCard: e.target.value })}
              style={{ width: 180 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="科室"
              value={queryParams.department}
              onChange={e => setQueryParams({ ...queryParams, department: e.target.value })}
              style={{ width: 120 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="医生"
              value={queryParams.doctor}
              onChange={e => setQueryParams({ ...queryParams, doctor: e.target.value })}
              style={{ width: 100 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="主要诊断编码"
              value={queryParams.mainDiagnosisCode}
              onChange={e => setQueryParams({ ...queryParams, mainDiagnosisCode: e.target.value })}
              style={{ width: 120 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="DRG编码"
              value={queryParams.drgCode}
              onChange={e => setQueryParams({ ...queryParams, drgCode: e.target.value })}
              style={{ width: 100 }}
              allowClear
            />
          </Col>
          <Col>
            <Input
              placeholder="DIP编码"
              value={queryParams.dipCode}
              onChange={e => setQueryParams({ ...queryParams, dipCode: e.target.value })}
              style={{ width: 100 }}
              allowClear
            />
          </Col>
          <Col>
            <Select
              placeholder="分组状态"
              value={queryParams.groupStatus}
              onChange={v => setQueryParams({ ...queryParams, groupStatus: v })}
              style={{ width: 100 }}
              allowClear
              options={groupStatusOptions}
            />
          </Col>
          <Col>
            <RangePicker
              placeholder={['开始日期', '结束日期']}
              onChange={(dates: [Dayjs | null, Dayjs | null] | null) => {
                if (dates) {
                  setQueryParams({
                    ...queryParams,
                    startDate: dates[0]?.format('YYYY-MM-DD'),
                    endDate: dates[1]?.format('YYYY-MM-DD'),
                  });
                } else {
                  setQueryParams({ ...queryParams, startDate: undefined, endDate: undefined });
                }
              }}
            />
          </Col>
          <Col>
            <Space>
              <Button type="primary" icon={<SearchOutlined />} onClick={() => { setCurrentPage(1); fetchData(1); }}>
                查询
              </Button>
              <Button icon={<ReloadOutlined />} onClick={() => { 
                setQueryParams({});
                setCurrentPage(1);
              }}>
                重置
              </Button>
              <Button icon={<FileExcelOutlined />} onClick={handleExport}>
                导出
              </Button>
            </Space>
          </Col>
        </Row>
      </Card>

      {/* 数据表格 */}
      <Card size="small">
        <div style={{ marginBottom: 12 }}>
          <Space>
            <span style={{ color: '#999' }}>共 {total} 条记录</span>
          </Space>
        </div>
        <Table
          columns={columns}
          dataSource={data}
          rowKey="admissionNo"
          loading={loading}
          scroll={{ x: 2000 }}
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

      {/* 详情弹窗 */}
      <Modal
        title="病案详情"
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        width={900}
      >
        {detailRecord && (
          <Tabs defaultActiveKey="basic">
            <TabPane tab={<span><UserOutlined />基本信息</span>} key="basic">
              <Descriptions bordered column={2} size="small">
                <Descriptions.Item label="病案号" span={2}>{detailRecord.medicalRecordNo}</Descriptions.Item>
                <Descriptions.Item label="就诊号">{detailRecord.admissionNo}</Descriptions.Item>
                <Descriptions.Item label="患者姓名">{detailRecord.patientName}</Descriptions.Item>
                <Descriptions.Item label="性别">{detailRecord.sex === '1' ? '男' : '女'}</Descriptions.Item>
                <Descriptions.Item label="年龄">{detailRecord.age}</Descriptions.Item>
                <Descriptions.Item label="身份证号">{detailRecord.idCard}</Descriptions.Item>
                <Descriptions.Item label="出生日期">{detailRecord.birthDate}</Descriptions.Item>
                <Descriptions.Item label="民族">{detailRecord.nationality || '-'}</Descriptions.Item>
                <Descriptions.Item label="籍贯">{detailRecord.nativePlace || '-'}</Descriptions.Item>
                <Descriptions.Item label="职业">{detailRecord.occupation || '-'}</Descriptions.Item>
                <Descriptions.Item label="婚姻状况">{detailRecord.maritalStatus || '-'}</Descriptions.Item>
              </Descriptions>
              <Divider />
              <Descriptions bordered column={2} size="small">
                <Descriptions.Item label="入院日期">{detailRecord.admissionDate}</Descriptions.Item>
                <Descriptions.Item label="出院日期">{detailRecord.dischargeDate}</Descriptions.Item>
                <Descriptions.Item label="住院天数">{detailRecord.hospitalDays}天</Descriptions.Item>
                <Descriptions.Item label="入院类型">{detailRecord.admissionType || '-'}</Descriptions.Item>
                <Descriptions.Item label="入院情况">{detailRecord.admissionCondition || '-'}</Descriptions.Item>
                <Descriptions.Item label="出院类型">{detailRecord.dischargeType || '-'}</Descriptions.Item>
                <Descriptions.Item label="出院情况">{detailRecord.dischargeCondition || '-'}</Descriptions.Item>
                <Descriptions.Item label="科室">{detailRecord.department || '-'}</Descriptions.Item>
                <Descriptions.Item label="医生">{detailRecord.doctorName || '-'}</Descriptions.Item>
              </Descriptions>
            </TabPane>
            <TabPane tab={<span><MedicineBoxOutlined />诊断手术</span>} key="diagnosis">
              <Descriptions bordered column={1} size="small">
                <Descriptions.Item label="主要诊断编码">{detailRecord.mainDiagnosisCode}</Descriptions.Item>
                <Descriptions.Item label="主要诊断名称">{detailRecord.mainDiagnosisName}</Descriptions.Item>
                <Descriptions.Item label="其他诊断">{detailRecord.otherDiagnoses || '-'}</Descriptions.Item>
                <Descriptions.Item label="主要手术编码">{detailRecord.mainProcedureCode || '-'}</Descriptions.Item>
                <Descriptions.Item label="主要手术名称">{detailRecord.mainProcedureName || '-'}</Descriptions.Item>
                <Descriptions.Item label="其他手术">{detailRecord.otherProcedures || '-'}</Descriptions.Item>
              </Descriptions>
            </TabPane>
            <TabPane tab={<span><DollarOutlined />费用信息</span>} key="cost">
              <Descriptions bordered column={2} size="small">
                <Descriptions.Item label="总费用" span={2}>¥{detailRecord.totalCost.toFixed(2)}</Descriptions.Item>
                <Descriptions.Item label="药品费用">¥{detailRecord.drugCost.toFixed(2)}</Descriptions.Item>
                <Descriptions.Item label="材料费用">¥{detailRecord.materialCost.toFixed(2)}</Descriptions.Item>
                <Descriptions.Item label="服务费用">¥{detailRecord.serviceCost.toFixed(2)}</Descriptions.Item>
                <Descriptions.Item label="检查费用">¥{detailRecord.examCost.toFixed(2)}</Descriptions.Item>
                <Descriptions.Item label="其他费用">¥{detailRecord.otherCost.toFixed(2)}</Descriptions.Item>
              </Descriptions>
              {detailRecord.costDetail && (
                <Divider />
              )}
              {detailRecord.costDetail?.drug && (
                <div style={{ marginTop: 16 }}>
                  <strong>药品明细：</strong>
                  <List
                    size="small"
                    dataSource={detailRecord.costDetail.drug as { name: string; amount: number }[]}
                    renderItem={(item) => (
                      <List.Item>
                        <span>{(item as { name: string; amount: number }).name}: ¥{(item as { name: string; amount: number }).amount.toFixed(2)}</span>
                      </List.Item>
                    )}
                  />
                </div>
              )}
            </TabPane>
            <TabPane tab={<span><PartitionOutlined />分组信息</span>} key="group">
              <Descriptions bordered column={2} size="small">
                <Descriptions.Item label="DRG编码">{detailRecord.drgCode || '-'}</Descriptions.Item>
                <Descriptions.Item label="DRG名称">{detailRecord.drgName || '-'}</Descriptions.Item>
                <Descriptions.Item label="DIP编码">{detailRecord.dipCode || '-'}</Descriptions.Item>
                <Descriptions.Item label="DIP名称">{detailRecord.dipName || '-'}</Descriptions.Item>
                <Descriptions.Item label="分组状态">
                  <Tag color={detailRecord.groupStatus === '1' ? 'success' : 'default'}>
                    {detailRecord.groupStatusDesc || '-'}
                  </Tag>
                </Descriptions.Item>
                <Descriptions.Item label="分组时间">{detailRecord.groupTime || '-'}</Descriptions.Item>
              </Descriptions>
            </TabPane>
          </Tabs>
        )}
      </Modal>
    </div>
  );
};

export default MedicalRecords;
