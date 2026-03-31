import React, { useState, useImperativeHandle, forwardRef } from 'react';
import { Table } from 'antd';

const DepartmentList = (props, ref) => {
    const columns = [{
        title: '用户',
        key: '1',
        dataIndex: 'logonUserDesc',
        align: 'center',
    }, {
        title: '角色',
        key: '2',
        dataIndex: 'logonGroupDesc',
        align: 'center',
    }, {
        title: '所属医院',
        key: '3',
        dataIndex: 'logonHospDesc',
        align: 'center',
    }];
    const [tableData, setTableData] = useState([]);


    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        getDepartmentList
    }));

    // 获取科室列表
    const getDepartmentList = async (userCode, userID) => {
        try {
            let data = {
                params: [{
                    userID,
                    userCode,
                }]
            };
            const res = await React.$asyncPost('01010004', data);
            let tableData = React.$processingTableRequestData(res);
            for (let i = 0; i < tableData.length; i++) {
                const nUserCode = tableData[i]?.loginUserCode || tableData[i]?.logonUserCode || tableData[i]?.userCode || userCode || '';
                const nUserDesc = tableData[i]?.loginUserDesc || tableData[i]?.logonUserDesc || tableData[i]?.userName || '';
                const nUserID = tableData[i]?.loginUserID || tableData[i]?.logonUserID || tableData[i]?.userID || '';
                const nGroupDesc = tableData[i]?.loginGroupDesc || tableData[i]?.logonGroupDesc || tableData[i]?.groupDesc || '';
                const nGroupID = tableData[i]?.loginGroupID || tableData[i]?.logonGroupID || tableData[i]?.groupID || '';
                const nHospDesc = tableData[i]?.loginHospDesc || tableData[i]?.logonHospDesc || tableData[i]?.hospDesc || '';
                const nHospID = tableData[i]?.loginHospID || tableData[i]?.logonHospID || tableData[i]?.hospID || '';
                tableData[i].loginUserCode = nUserCode;
                tableData[i].loginUserDesc = nUserDesc;
                tableData[i].loginUserID = nUserID;
                tableData[i].loginGroupDesc = nGroupDesc;
                tableData[i].loginGroupID = nGroupID;
                tableData[i].loginHospDesc = nHospDesc;
                tableData[i].loginHospID = nHospID;
            }
            setTableData(tableData);
        } catch (error) {
            console.log(error);
        };
    };

    return (
        <Table
            pagination={false}
            scroll={{ y: 240 }}
            columns={columns}
            dataSource={tableData}
            onRow={(record) => {
                return {
                    onClick: () => {
                        props.setDepartmentValues(record);
                    },
                };
            }}
        />
    );
};

export default forwardRef(DepartmentList);