import React from 'react';
import { Space, Spin } from 'antd';
import './index.less';

const Loading = () => {
    return (
        <div className="loading">
            <Space>
                <Spin size="large" />
            </Space>
        </div>
    )
};

export default Loading;