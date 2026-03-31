/*
 * Create:      柿子
 * CreateDate:  2024/05/23
 * Describe：   角色菜单授权医院
 * */
import React, { useState, forwardRef, useImperativeHandle } from 'react';
import { Modal, message } from 'antd';
import { Util } from '@tools';
import request from '@api';
import store from '@store';
import PublicTablePagination from '@pages/common/PublicTablePagination';

const RoleMenuAuthorizationHospital = (props, ref) => {
    const { documentHeight } = store.getState();
    const [visible, setVisible] = useState(false);
    const [columns, setColumns] = useState([]);
    const [totalWidth, setTotalWidth] = useState(0);
    const [loading, setLoading] = useState(false);
    const [tableData, setTableData] = useState([]);
    const [rowID, setRowID] = useState('');
    const [selectedRowKeys, setSelectedRowKeys] = useState([]);
    const [selectedRows, setSelectedRows] = useState([]);
    const [groupMenuID, setGroupMenuID] = useState('');

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible,
        handleCancel
    }));

    // 修改弹窗状态
    const modifyVisible = (visible, params) => {
        setVisible(visible);
        if (visible) {
            if (!(columns && columns.length > 0)) {
                getColumnsData();
            }
            let pTableData = params?.tableData || []; // 如果父界面传过来了就用传过来的数据
            if (pTableData && Array.isArray(pTableData) && pTableData.length > 0) {
                setTableData(Util.addKeyValueToDataSource([...pTableData], 'id'));
            } else {
                getTableData();
            }
            setSelectedRowKeys(params?.selectedRowKeys || []);
            setGroupMenuID(params?.groupMenuID || '')
        };
    };

    // 关闭弹窗
    const handleCancel = (isClearFlag) => {
        setVisible(false);
        isClearFlag === 'Y' && handleClear();
    };

    // 获取列表表头数据
    const getColumnsData = async () => {
        try {
            const res = await request.getComponentInfo('RoleMenuAuthorizationHospital');
            setColumns(res.result?.C || []);
            setTotalWidth(res.totalWidth);
        } catch (error) {
            console.log(error);
        }
    };

    // 获取主菜单下拉
    const getTableData = async () => {
        try {
            const res = await React.$asyncPost('03020113');
            setTableData(Util.addKeyValueToDataSource(res, 'id'));
        } catch (error) {
            console.log(error);
        }
    };

    // 操作行
    const handleRowClick = (record) => {
        const { idIndex = 'id' } = props;
        let nSelectedRowKeys = [...selectedRowKeys];
        let nSelectedRows = [...selectedRows];
        return {
            // 单击行选中
            onClick: () => {
                let findFlag = false;
                let start = 0;
                let nRowID = '';
                if (nSelectedRowKeys) {
                    nSelectedRowKeys.find(function (value, key) {
                        if (value === record[idIndex]) {
                            findFlag = true;
                            start = key;
                        }
                    })
                }
                if (findFlag) {
                    //再次点击移除选中
                    nSelectedRowKeys.splice(start, 1);
                    nSelectedRows.splice(start, 1);
                } else {
                    //将点击的行添加到选中
                    nRowID = record[idIndex];
                    nSelectedRowKeys.push(record[idIndex]);
                    nSelectedRows.push(record);
                }
                setRowID(nRowID);
                setSelectedRowKeys(nSelectedRowKeys);
                setSelectedRows(nSelectedRows);
            },
        }
    };

    const handleClear = () => {
        setRowID('');
        setSelectedRowKeys([]);
        setSelectedRows([]);
    };

    // 选中行操作
    const setRowClassName = (record) => {
        return record.id === rowID ? 'common-table-select-bg' : '';
    };

    // 确认授权
    const handleOk = async () => {
        try {
            let data = {
                params: [{
                    groupMenuID,
                    groupMenuAuthArr: selectedRowKeys,
                }]
            }
            const res = await React.$asyncPost('01010059', data);
            message.success(res?.errorMessage || '保存成功');
            props && 'handleQuery' in props && props.handleQuery();
            handleCancel('Y');
        } catch (error) {
            console.log(error);
        }
    };

    return (
        <Modal
            width="1000px"
            title="授权医院"
            open={visible}
            onOk={handleOk}
            onCancel={handleCancel}
        >
            <PublicTablePagination
                param={{
                    loading,
                    columns,
                    x: totalWidth, // 表格的宽度
                    y: documentHeight - 340,
                    height: documentHeight - 300 + 'px',
                    data: tableData, // 表格数据
                    componentName: 'RoleMenuAuthorizationHospital'
                }}
                rowSelection={{
                    selectedRowKeys,
                    onChange: (selectedRowKeys, selectedRows) => {
                        setSelectedRowKeys(selectedRowKeys);
                        setSelectedRows(selectedRows);
                    },
                }}
                getColumns={getColumnsData}
                onRow={handleRowClick}
                rowClassName={setRowClassName}
            />
        </Modal>
    )
};

export default forwardRef(RoleMenuAuthorizationHospital);