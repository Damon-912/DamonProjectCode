import React from 'react';
import { Button, Select, Space } from 'antd';

const { Option } = Select;

interface CustomPaginationProps {
  current: number;
  pageSize: number;
  total: number;
  onChange: (page: number, pageSize: number) => void;
  size?: 'small' | 'middle' | 'large';
  showTotal?: boolean;
}

/**
 * 自定义分页组件
 * 风格：首页 | 上一页 | 第 1/2 页 | 下一页 | 末页 | 15条/页 | 共 XX 条
 */
const CustomPagination: React.FC<CustomPaginationProps> = ({
  current,
  pageSize,
  total,
  onChange,
  size = 'small',
  showTotal = true
}) => {
  const totalPages = Math.ceil(total / pageSize) || 1;

  const handlePageChange = (newPage: number) => {
    onChange(newPage, pageSize);
  };

  const handlePageSizeChange = (newPageSize: number) => {
    onChange(1, newPageSize);
  };

  return (
    <Space size={4} align="center">
      <Button
        size={size}
        disabled={current === 1}
        onClick={() => handlePageChange(1)}
      >
        首页
      </Button>
      <Button
        size={size}
        disabled={current === 1}
        onClick={() => handlePageChange(current - 1)}
      >
        上一页
      </Button>
      <span style={{ fontSize: size === 'small' ? 12 : 14, padding: '0 8px' }}>
        第 {current} / {totalPages} 页
      </span>
      <Button
        size={size}
        disabled={current >= totalPages}
        onClick={() => handlePageChange(current + 1)}
      >
        下一页
      </Button>
      <Button
        size={size}
        disabled={current >= totalPages}
        onClick={() => handlePageChange(totalPages)}
      >
        末页
      </Button>
      <Select
        size={size}
        value={pageSize}
        style={{ width: 90 }}
        onChange={handlePageSizeChange}
      >
        <Option value={15}>15条/页</Option>
        <Option value={20}>20条/页</Option>
        <Option value={50}>50条/页</Option>
        <Option value={100}>100条/页</Option>
      </Select>
      {showTotal && (
        <span style={{ fontSize: size === 'small' ? 12 : 14, padding: '0 8px', color: '#666' }}>
          共 {total} 条
        </span>
      )}
    </Space>
  );
};

export default CustomPagination;
