/*
 * Create:      柿子
 * CreateDate:  2024/05/21
 * Describe：   用户管理
 * */
import React from 'react';
import SingleTableOperation from '@pages/dynamicRendering/SingleTableOperation';
import PersonnelPermissionAllocation from './component/PersonnelPermissionAllocation';

const UserManagement = (props) => {

    // {
    //     key: '2',
    //     title: '分配部门小组',
    //     tabType: 'customRendering',
    //     width: '50vw',
    //     params: {
    //         queryCode: '',
    //         saveCode: '',
    //         deleteCode: '',
    //         componentName: 'UMAssignDepartmentTeams',

    //     },
    //     component: PersonnelPermissionAllocation
    // }
    return (
        <div className="user-management">
            <SingleTableOperation
                {...props}
                linkTabData={[{
                    key: '1',
                    title: '基本信息',
                    tabType: 'baseInfo',
                }, {
                    key: '3',
                    title: '登录部门权限',
                    tabType: 'customRendering',
                    width: '50vw',
                    params: {
                        idField: 'userLogonLocID',
                        queryCode: '01030111',
                        saveCode: '01030109',
                        deleteCode: '01030110',
                        componentName: 'UMLoginDepartmentPermissions',
                    },
                    component: PersonnelPermissionAllocation
                }]}
            />
        </div>
    )
};

export default UserManagement;