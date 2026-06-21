import React, { useState, useEffect, useCallback } from 'react';
import {
  Card, Table, Button, Input, Select, Space, Tag, message, DatePicker
} from 'antd';
import zhCN from 'antd/es/date-picker/locale/zh_CN';
const { RangePicker } = DatePicker;
import { SearchOutlined, ReloadOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import CustomPagination from '../../components/CustomPagination';
import { querySyncLogs, SyncLogItem } from '../../api/hisData';
import dayjs from 'dayjs';
import 'dayjs/locale/zh-cn';
dayjs.locale('zh-cn');

const SyncLog: React.FC = () => {
  const [data, setData] = useState<SyncLogItem[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);
  const [syncType, setSyncType] = useState('');
  const [statusCode, setStatusCode] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');

  const fetchData = useCallback(async (page = currentPage, size = pageSize) => {
    setLoading(true);
    try {
      const res = await querySyncLogs({
        syncType: syncType || undefined,
        statusCode: statusCode || undefined,
        startDate: startDate || undefined,
        endDate: endDate || undefined,
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
  }, [syncType, statusCode, startDate, endDate, currentPage, pageSize]);

  useEffect(() => {
    fetchData(1);
  }, []);

  const handleSearch = () => {
    setCurrentPage(1);
    fetchData(1);
  };

  const handleReset = () => {
    setSyncType('');
    setStatusCode('');
    setStartDate('');
    setEndDate('');
    setCurrentPage(1);
    fetchData(1);
  };

  const getStatusTag = (status: string) => {
    switch (status) {
      case 'success':
        return <Tag color="green">成功</Tag>;
      case 'failed':
        return <Tag color="red">失败</Tag>;
      case 'partial':
        return <Tag color="orange">部分成功</Tag>;
      default:
        return <Tag>{status}</Tag>;
    }
  };

  const columns: ColumnsType<SyncLogItem> = [
    {
      title: '任务名称',
      dataIndex: 'taskName',
      key: 'taskName',
      width: 200,
    },
    {
      title: '同步类型',
      dataIndex: 'syncType',
      key: 'syncType',
      width: 100,
      render: (type: string) => {
        switch (type) {
          case 'incremental':
            return '增量同步';
          case 'full':
            return '全量同步';
          case 'manual':
            return '手动同步';
          default:
            return type;
        }
      },
    },
    {
      title: '状态',
      dataIndex: 'statusCode',
      key: 'statusCode',
      width: 100,
      render: (status: string) => getStatusTag(status),
    },
    {
      title: '开始时间',
      dataIndex: 'startTime',
      key: 'startTime',
      width: 160,
      render: (time: string) => time ? dayjs(time).format('YYYY年MM月DD日 HH:mm:ss') : '-',
    },
    {
      title: '结束时间',
      dataIndex: 'endTime',
      key: 'endTime',
      width: 160,
      render: (time: string) => time ? dayjs(time).format('YYYY年MM月DD日 HH:mm:ss') : '-',
    },
    {
      title: '总数',
      dataIndex: 'totalCount',
      key: 'totalCount',
      width: 80,
    },
    {
      title: '成功',
      dataIndex: 'successCount',
      key: 'successCount',
      width: 80,
      render: (count: number) => <span style={{ color: 'green' }}>{count}</span>,
    },
    {
      title: '失败',
      dataIndex: 'failedCount',
      key: 'failedCount',
      width: 80,
      render: (count: number) => count > 0 ? <span style={{ color: 'red' }}>{count}</span> : count,
    },
    {
      title: '错误信息',
      dataIndex: 'errorMessage',
      key: 'errorMessage',
      width: 200,
      ellipsis: true,
    },
  ];

  return (
    <div style={{ padding: 16 }}>
      <Card size="small" style={{ marginBottom: 16 }}>
        <Space wrap>
          <Select
            placeholder="同步类型"
            value={syncType || undefined}
            onChange={val => setSyncType(val)}
            style={{ width: 120 }}
            allowClear
          >
            <Select.Option value="incremental">增量同步</Select.Option>
            <Select.Option value="full">全量同步</Select.Option>
            <Select.Option value="manual">手动同步</Select.Option>
          </Select>
          <Select
            placeholder="状态"
            value={statusCode || undefined}
            onChange={val => setStatusCode(val)}
            style={{ width: 120 }}
            allowClear
          >
            <Select.Option value="success">成功</Select.Option>
            <Select.Option value="failed">失败</Select.Option>
            <Select.Option value="partial">部分成功</Select.Option>
          </Select>
          <RangePicker
            onChange={(_dates, dateStrings) => {
              setStartDate(dateStrings[0] || '');
              setEndDate(dateStrings[1] || '');
            }}
            style={{ width: 280 }}
            locale={zhCN}
            format="YYYY-MM-DD"
            placeholder={['开始日期', '结束日期']}
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
          rowKey="id"
          loading={loading}
          scroll={{ x: 1200 }}
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
    </div>
  );
};

export default SyncLog;
