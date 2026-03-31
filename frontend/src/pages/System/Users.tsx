import React from 'react';
import { Card, Typography } from 'antd';

const { Title } = Typography;

const Users: React.FC = () => {
  return (
    <div style={{ padding: 16 }}>
      <Card>
        <Title level={4}>用户管理</Title>
        <p>功能开发中...</p>
      </Card>
    </div>
  );
};

export default Users;
