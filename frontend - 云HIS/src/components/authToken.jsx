import React from 'react';
import { Navigate, useNavigate } from 'react-router-dom';
import { notification } from 'antd';
import { envConfig } from '@envConfig';

function AuthToken({ children }) {
    const navigate = useNavigate();
    const appInfo = React.$getLocalStorageData(envConfig?.['ROOT_APP_INFO'] || 'drg-info');

    // 监听本地值，一旦手动删除去登录
    window.addEventListener('storage', (event) => {
        console.log(event);
        if (event.storageArea === localStorage && event.key == envConfig?.['ROOT_APP_INFO'] || 'drg-info') {
            navigate('/login');
            notification.warning({
                message: '系统提示',
                description: '监测到用户信息已变更或删除，请重新登录',
            });
        }
    });

    if (appInfo && JSON.stringify(appInfo) !== '{}') {
        return <>{children}</>
        // 如果token存在，则返回传入的组件
    } else {
        // 否则重定向到登录组件
        return <Navigate to="/login" replace></Navigate>
    }
};

export default AuthToken;