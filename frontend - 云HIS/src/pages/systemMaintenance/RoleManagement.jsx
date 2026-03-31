/*
 * Create:      柿子
 * CreateDate:  2024/05/20
 * Describe：   角色管理
 * */
import React from 'react';
import SingleTableOperation from '@pages/dynamicRendering/SingleTableOperation';
import MenuPermissionSettings from './component/MenuPermissionSettings';

const RoleManagement = (props) => {
    return (
        <div>
            <SingleTableOperation
                {...props}
                linkTabData={[{
                    key: '1',
                    title: '基本信息',
                    tabType: 'baseInfo',
                }, {
                    key: '2',
                    title: '菜单授权',
                    tabType: 'customRendering',
                    width: '60vw',
                    component: MenuPermissionSettings
                }]}
            />
        </div>
    )
};

export default RoleManagement;