/*
 * Create:      柿子
 * CreateDate:  2024/05/22
 * Describe：   人员权限分配
 * */
import React, { useState, useEffect, useRef } from 'react';
import { notification, Button, Divider, Popconfirm, message } from 'antd';
import { EditOutlined, DeleteOutlined, PlusOutlined } from '@ant-design/icons';
import request from '@api';
import store from '@store';
import UseSyncCallback from '@pages/common/UseSyncCallback';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import PublicModalFormHooks from '@pages/common/PublicModalFormHooks';

const PersonnelPermissionAllocation = (props) => {
    let modalFormRef = useRef(null);
    const propsRecordData = props?.rowData || {};
    const propsTabKey = props?.tabKey || ''; // 当前tabs的key值，防止重复调用
    const propsActiveKey = props?.activeKey || '';
    const { documentHeight } = store.getState();
    const [columns, setColumns] = useState([]);
    const [totalWidth, setTotalWidth] = useState(0);
    const [modalFormData, setModalFormData] = useState([]);
    const [loading, setLoading] = useState(false);
    const [tableData, setTableData] = useState([]);
    const [rowID, setRowID] = useState('');
    const [modalRowData, setModalRowData] = useState({});

    useEffect(() => {
        getColumnsData();
    }, []);

    useEffect(() => {
        // propsTabKey === propsActiveKey 避免接口重复调用
        if (propsTabKey === propsActiveKey && propsRecordData && JSON.stringify(propsRecordData) !== '{}') {
            getTableData();
        }
    }, [propsActiveKey, propsRecordData])

    // 获取列表数据
    const getTableData = async () => {
        try {
            let queryCode = props?.queryCode || '';
            if (!queryCode) return;
            setLoading(true);
            let data = {
                params: [{
                    userID: propsRecordData?.userID || propsRecordData?.userDr || '',
                    userCode: propsRecordData?.userCode || '',
                }]
            };
            const res = await React.$asyncPost(queryCode, data);
            setTableData(React.$processingTableRequestData(res));
            setLoading(false);
            setRowID('');
        } catch (error) {
            console.log(error);
            setLoading(false);
        };
    };

    // 获取列表表头数据
    const getColumnsData = async () => {
        try {
            let componentName = props?.componentName || '';
            if (!componentName) {
                notification.error({
                    message: `系统提醒 :`,
                    description: '组件名维护异常！',
                });
                return;
            };
            const res = await request.getComponentInfo(componentName);
            setColumns(res.result?.C || []);
            setTotalWidth(res?.totalWidth || 0);
            setModalFormData(res?.result?.formData || []);
        } catch (error) {
            console.log(error);
        };
    };

    // 操作行
    const handleRowClick = (record) => {
        const idField = props?.idField || 'id';
        const nRowID = record && idField in record ? record[idField] : (record?.key || '');
        return {
            // 单击行选中
            onClick: () => {
                if (rowID === '' || (rowID && (rowID !== nRowID))) {
                    setRowID(nRowID);
                } else {
                    setRowID('');
                }
            }
        }
    };

    // 选中行操作
    const setRowClassName = (record) => {
        const idField = props?.idField || 'id';
        const nRowID = record && idField in record ? record[idField] : (record?.key || '');
        return nRowID === rowID ? 'common-table-select-bg' : '';
    };

    // 记录价格信息表单的值
    const handleRecordFormInput = record => {
        setModalRowData(oldData => {
            return {
                ...oldData,
                ...record
            };
        });
    };

    // 添加
    const handleAdd = () => {
        let idField = props?.idField || 'id';
        if (modalRowData && idField in modalRowData && modalRowData[idField]) {
            setModalRowData({});
        };
        modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(true);
    };

    // 编辑
    const handleCompile = (record, e) => {
        setModalRowData({ ...record });
        modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(true);
    };

    // 保存
    const handleSave = async (values) => {
        try {
            let saveCode = props?.saveCode || '';
            if (!saveCode) {
                notification.error({
                    message: `系统提醒 :`,
                    description: '保存接口异常，请检查是否配置接口！',
                });
                modalFormRef && modalFormRef.current && modalFormRef.current.modifyOkLoading(false);
                return;
            };
            let data = {
                params: [{
                    userID: propsRecordData?.userID || propsRecordData?.userDr || '',
                    userCode: propsRecordData?.userCode || '',
                    ...modalRowData,
                    ...values,
                }]
            };
            const res = await React.$asyncPost(saveCode, data);
            message.success(res?.errorMessage || '保存成功');
            getTableData();
            modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(false, 'Y');
        } catch (error) {
            console.log(error);
            modalFormRef && modalFormRef.current && modalFormRef.current.modifyOkLoading(false);
        };
    };

    // 删除
    const handleDelete = UseSyncCallback(async (record) => {
        try {
            if (!(props?.deleteCode || '')) {
                notification.error({
                    message: `系统提醒 :`,
                    description: '删除接口维护异常！',
                });
                return
            };
            let data = {
                params: [{
                    userLogonLocID: record?.userLogonLocID || undefined,
                }]
            }
            const res = await React.$asyncPost(props.deleteCode, data);
            message.success(res?.errorMessage || '删除成功');
            getTableData();
        } catch (error) {
            console.log(error)
        };
    });

    // 列表操作
    const operationObj = {
        width: 130,
        title: '操作',
        align: 'center',
        fixed: 'right',
        key: 'operation',
        render: (text, record) => (
            <span>
                <span className="common-record-span" onClick={(e) => handleCompile(record, e)}>
                    <EditOutlined />
                    编辑
                </span>
                <Divider type="vertical" />
                <Popconfirm
                    title="删除后不可恢复，确定要删除吗?"
                    className="common-record-delete-span"
                    onConfirm={(e) => handleDelete(record, e)}
                >
                    <DeleteOutlined />
                    删除
                </Popconfirm>
            </span >
        ),
    };

    return (
        <div>
            <div style={{ margin: '12px 0 6px 0', textAlign: 'right' }}>
                <Button
                    icon={<PlusOutlined className="common-record-span" />}
                    onClick={handleAdd}
                >
                    添加
                </Button>
            </div>
            <PublicTablePagination
                param={{
                    loading,
                    componentName: props?.componentName || '', // 表头配置
                    data: tableData, // 表格数据
                    x: totalWidth, // 表格的宽度
                    y: documentHeight - 208,
                    height: documentHeight - 168 + 'px',
                    columns: columns && Array.isArray(columns) && columns.length > 0 ? [...columns, operationObj] : [],
                }}
                getColumns={getColumnsData}
                onRow={handleRowClick}
                rowClassName={setRowClassName}
            />

            {/* 数据分组 */}
            <PublicModalFormHooks
                idField={props?.idField || 'id'}
                ref={modalFormRef}
                formData={modalFormData}
                rowData={modalRowData}
                selectData={props?.selectDat || {}}
                formItemCol={{ labelCol: 24, wrapperCol: 24, col: 24 }}
                recordFormInput={handleRecordFormInput}
                handleSave={handleSave}
            />
        </div>
    )
};

export default PersonnelPermissionAllocation;