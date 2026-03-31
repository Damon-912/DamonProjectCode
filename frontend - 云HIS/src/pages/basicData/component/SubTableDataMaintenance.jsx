/*
 * Create:      柿子
 * CreateDate:  2024/05/16
 * Describe：   基础表数据维护 - 子表数据维护
 * */
import React, { useState, useEffect, forwardRef, useImperativeHandle, useRef } from 'react';
import { Drawer, Tabs, message, Button } from 'antd';
import { PlusOutlined, EditOutlined, DeleteOutlined } from '@ant-design/icons';
import store from '@store';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import PublicModalFormHooks from '@pages/common/PublicModalFormHooks';
import '../style/index.less';

const SubTableDataMaintenance = (props, ref) => {
    let modalFormRef = useRef(null);
    const userData = React.$getUserData();
    const { contentHeight } = store.getState();
    const [visible, setVisible] = useState(false);
    const [activeKey, setActiveKey] = useState(false);
    const [activeRecord, setActiveRecord] = useState(false);
    const [parentRecordData, setParentRecordData] = useState({});
    const [linkTableData, setLinkTableData] = useState({});
    const [selectData, setSelectData] = useState({});
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(20);
    const [columns, setColumns] = useState([]);
    const [formData, setFormData] = useState([]);
    const [totalWidth, setTotalWidth] = useState(0);
    const [loading, setLoading] = useState(false);
    const [tableData, setTableData] = useState([]);
    const [total, setTotal] = useState(0);
    const [rowID, setRowID] = useState('');
    const [rowData, setRowData] = useState({});

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible,
    }));

    // 修改弹窗状态
    const modifyVisible = (visible, pLinkTableData = [], pParentRecordData = {}) => {
        setVisible(visible);
        if (visible && pLinkTableData && Array.isArray(pLinkTableData) && pLinkTableData.length > 0) { // 设置选中
            setActiveKey(pLinkTableData[0]?.id || pLinkTableData[0]?.key || '');
            setActiveRecord(pLinkTableData[0]);
        };
        setLinkTableData(pLinkTableData);
        setParentRecordData({ ...pParentRecordData });
    };

    // 选中tab
    const handleTabChange = (key) => {
        setActiveKey(key);
    };

    useEffect(() => {
        if (visible) {
            getColumnsData();
            getSelectData();
            getFormData();
            getTableData();
        };
    }, [activeKey])

    useEffect(() => {
        if (visible && activeKey && !(parentRecordData && JSON.stringify(parentRecordData) === '{}')) {
            getTableData();
        };
    }, [page, pageSize, parentRecordData]);

    // 请求列表数据
    const getTableData = async () => {
        try {
            const { Code = '' } = activeRecord;
            const { ID = '' } = parentRecordData;
            if (!(ID && Code)) return;
            setLoading(true);
            let data = {
                params: [{
                    ClassName: Code,
                    RefId: ID
                }],
                pagination: [{
                    pageSize,
                    currentPage: page
                }]
            };
            const res = await React.$asyncPost('4016', data);
            const nTableData = React.$processingTableRequestData(res);
            setTableData(nTableData);
            setTotal(res?.result?.total || res?.result?.totalCount || res?.result?.TotalCount || nTableData.length);
            setLoading(false);
            setRowID('');
            setRowData({});
        } catch (error) {
            console.log('error', error);
            setLoading(false);
        }
    };

    // 获取列表表头数据
    const getColumnsData = async () => {
        try {
            const { Code = '' } = activeRecord;
            if (!Code) return;
            const res = await React.$asyncPost('4002', {
                params: [{
                    ClassName: Code
                }]
            });
            let nColumns = res?.result?.Data || [];
            let nTotalWidth = 0; // res?.result?.totalWidth || 0
            for (let i = 0; i < nColumns.length; i++) {
                nColumns[i].width = '150px';
                nTotalWidth += 150
            }
            setColumns(nColumns);
            setTotalWidth(nTotalWidth);
        } catch (error) {
            console.log(error);
        };
    };

    // 获取明细表单下拉数据
    const getSelectData = async () => {
        try {
            const { Code = '' } = activeRecord;
            if (!Code) return;
            const res = await React.$asyncPost('4007', {
                params: [{
                    ClassName: Code,
                }]
            });
            let nSelectData = res?.result || {};
            setSelectData(nSelectData);
        } catch (error) {
            console.log(error);
        };
    };

    const getFormData = async () => {
        try {
            const { Code = '' } = activeRecord;
            if (!Code) return;
            const res = await React.$asyncPost('4004', {
                params: [{
                    ClassName: Code,
                }]
            });
            let resData = res?.result?.Data || [];
            let nFormData = resData && Array.isArray(resData) && resData.map(item => {
                let typeCode = item?.Type || '';
                let rules = item?.rules || '';
                return {
                    dataIndex: item?.Code || '',
                    title: item?.Desc || '',
                    typeCode: typeCode === 'Radio' ? 'Switch' : (typeCode === 'DR' ? 'Select' : typeCode),
                    className: (typeCode === 'DR' || typeCode === 'Select') ? (item?.Code || '') : '',
                    valueFieldName: 'ID',
                    labelFieldName: 'Desc',
                    required: rules && Array.isArray(rules) && rules.length > 0 ? (rules[0]?.required === 'true' ? 'Y' : 'N') : 'N',
                }
            });
            setFormData(nFormData);
        } catch (error) {
            console.log(error);
        };
    };

    // 提供修改page和pageSize的回调函数
    const handlePaginationChange = (page, pageSize) => {
        setPage(page);
        setPageSize(pageSize);
    };

    // 操作行
    const handleRowClick = (record) => {
        return {
            // 单击行选中
            onClick: () => {
                if (rowID === '' || (rowID && rowID !== record.key)) {
                    setRowID(record.key);
                    setRowData(record);
                } else {
                    setRowID('');
                    setRowData({});
                }
            }
        }
    };

    // 选中行操作
    const setRowClassName = (record) => {
        return record.key === rowID ? 'common-table-select-bg' : '';
    };

    // 记录价格信息表单的值
    const handleRecordFormInput = record => {
        setRowData(oldData => {
            return {
                ...oldData,
                ...record
            }
        });
    };

    // 保存
    const handleSave = async (values) => {
        try {
            const { Code = '' } = activeRecord;
            const res = await React.$asyncPost('4015', {
                params: [{
                    ClassName: Code,
                    UserDr: userData?.userID || '',
                    Item: { ...values, ID: rowData?.ID || undefined, RefId: parentRecordData?.ID || '' },
                }]
            });
            message.success(res?.errorMessage || '保存成功');
            modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(false, 'Y');
            getTableData();
        } catch (error) {
            console.log(error);
            modalFormRef && modalFormRef.current && modalFormRef.current.modifyOkLoading(false);
        }
    };

    // 添加
    const handleAdd = () => {
        if (rowID) {
            setRowID('');
            setRowData({});
        };
        modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(true);
    };

    // 编辑
    const handleCompile = () => {
        modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(true);
    };

    const handleDelete = async () => {
        try {
            const { Code = '' } = activeRecord;
            const res = await React.$asyncPost('4018', {
                params: [{
                    ClassName: Code,
                    UserDr: userData?.userID || '',
                    ID: rowData?.ID || ''
                }]
            });
            message.success(res?.errorMessage || '删除成功');
            getTableData();
        } catch (error) {
            console.log(error);
        }
    };

    return (
        <div>
            <Drawer
                title="子表数据维护"
                width="800px"
                className={linkTableData && linkTableData.length > 1 ? 'sub-table-data-maintenance' : ''}
                open={visible}
                onClose={() => setVisible(false)}
            >
                <div>
                    {linkTableData && linkTableData.length > 1 && (
                        <Tabs
                            items={linkTableData}
                            activeKey={activeKey}
                            onChange={handleTabChange}
                        />
                    )}
                    <div>
                        <div style={{ marginBottom: '6px' }}>
                            <Button icon={<PlusOutlined className="common-record-span" />} onClick={handleAdd}>添加</Button>
                            <Button
                                style={{ margin: '0 12px' }}
                                disabled={!rowID}
                                icon={<EditOutlined className={rowID ? 'common-record-span' : ''} />}
                                onClick={handleCompile}
                            >
                                修改
                            </Button>
                            <Button
                                disabled={!rowID}
                                icon={<DeleteOutlined className={rowID ? 'common-record-delete-span' : ''} />}
                                onClick={handleDelete}
                            >
                                删除
                            </Button>
                        </div>
                        <PublicTablePagination
                            param={{
                                page,
                                total,
                                loading,
                                // 表头配置
                                defaultPageSize: 20,
                                columns,
                                x: totalWidth, // 表格的宽度
                                y: contentHeight - (linkTableData && linkTableData.length > 1 ? 120 : 90),
                                height: contentHeight - (linkTableData && linkTableData.length > 1 ? 90 : 50) + 'px',
                                data: tableData, // 表格数据
                            }}
                            compilePage={handlePaginationChange}
                            onRow={handleRowClick}
                            rowClassName={setRowClassName}
                        />
                    </div>
                </div>
            </Drawer>

            {/* 编辑修改字表数据 */}
            <PublicModalFormHooks
                width={600}
                ref={modalFormRef}
                formData={formData}
                rowData={rowData}
                selectData={selectData}
                formItemCol={{ labelCol: 24, wrapperCol: 24, col: 24 }}
                recordFormInput={handleRecordFormInput}
                handleSave={handleSave}
            />
        </div>
    )
};

export default forwardRef(SubTableDataMaintenance);