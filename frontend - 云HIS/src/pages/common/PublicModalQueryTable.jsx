/*
 * Create:      柿子
 * CreateDate:  2024/05/15
 * Describe：   弹窗查询列表【table单击行勾选示例】
 * */
import React, { useState, useEffect, useRef, forwardRef, useImperativeHandle } from 'react';
import { Modal, Popconfirm, Button, message } from 'antd';
import request from '@api';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import PublicTablePagination from '@pages/common/PublicTablePagination';

const PublicModalQueryTable = (props, ref) => {
    let queryFormRef = useRef(null);
    const [visible, setVisible] = useState(false);
    const [propParams, setPropParams] = useState({});
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(20);
    const [columns, setColumns] = useState([]);
    const [totalWidth, setTotalWidth] = useState(0);
    const [queryFormData, setQueryFormData] = useState([]);
    const [loading, setLoading] = useState(false);
    const [tableData, setTableData] = useState([]);
    const [total, setTotal] = useState(0);
    const [rowID, setRowID] = useState('');
    const [rowData, setRowData] = useState({});
    const [selectData, setSelectData] = useState({});
    const [selectedRowKeys, setSelectedRowKeys] = useState([]);
    const [selectedRows, setSelectedRows] = useState([]);

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible,
        handleCancel
    }));

    // 修改弹窗状态
    const modifyVisible = (visible, params = {}) => {
        setVisible(visible);
        setPropParams(params);
        if (visible && !(columns && columns.length > 0) && params?.getColumnsFlag !== 'N') {
            getColumnsData();
        };
        if (visible && !(selectData && JSON.stringify(selectData) !== '{}')) {
            getSelectData();
        };
        // forceQueryFlag - 每次弹窗都查询  autoQueryFlag - 自动查询标志
        if (visible && props.autoQueryFlag !== 'N' && params?.autoQueryFlag !== 'N' && (!(tableData && tableData.length > 0) || params?.forceQueryFlag === 'Y')) {
            setTimeout(() => {
                getTableData();
            }, 300)
        };
    };

    // 关闭弹窗
    const handleCancel = (isClearFlag) => {
        setVisible(false);
        isClearFlag === 'Y' && handleClear();
    };

    const getSelectData = async () => {
        try {
            let { selectCode = '' } = props;
            if (!selectCode) return;
            const res = await React.$asyncPost(selectCode);
            setSelectData(res?.result || {});
        } catch (error) {
            console.log(error);
        };
    };

    // 获取列表表头数据
    const getColumnsData = async () => {
        try {
            const { componentName } = props;
            if (!componentName) return;
            const res = await request.getComponentInfo(componentName);
            setColumns(res.result?.C || []);
            setTotalWidth(res.totalWidth);
            let nQueryFormData = res.result?.formData || [];
            for (let i = 0; i < nQueryFormData.length; i++) {
                if (nQueryFormData[i]?.typeCode === 'Input') {
                    nQueryFormData[i].onPressEnter = handleQuery;
                }
                if (nQueryFormData[i]?.dataIndex === 'queryBtn') { // 查询
                    nQueryFormData[i].onClick = handleQuery
                }
            }
            setQueryFormData(nQueryFormData);
        } catch (error) {
            console.log(error);
        }
    };

    useEffect(() => {
        if (visible) {
            console.log('触发了查询')
            getTableData();
        }
    }, [page, pageSize]);

    const handleQuery = () => {
        setPage(oldPage => {
            if (oldPage === 1) {
                getTableData();
            };
            return 1
        });
    };

    // 请求列表数据
    const getTableData = async () => {
        try {
            const { queryCode, staticParams = {}, paginationFlag, idField = 'key' } = props;
            const { dynamicParams = {}, copyTableData } = propParams;
            let values = {};
            if (queryFormRef && queryFormRef.current) {
                values = await queryFormRef.current.handleSave();
                if (values.error) {
                    message.error('请完善必填信息');
                    return;
                }
            }
            if (!queryCode) {
                message.error('请配置查询代码');
                return;
            };
            if (queryCode === 'staticFilter') { // 静态过滤
                let staticNTableData = [];
                for (let key in values) {
                    if (staticNTableData[key] !== undefined && values[key] !== false && values[key] !== null) {
                        staticNTableData = copyTableData.filter(item => item?.staticFilter.indexOf(values[key]) > -1);
                    }
                }
                setTableData(staticNTableData)
                return;
            };
            handleAddLoading(true);
            let data = {
                params: [{
                    ...staticParams,
                    ...dynamicParams,
                    ...values,
                }]
            }
            if (paginationFlag === 'Y') {
                data.pagination = [{
                    pageSize,
                    currentPage: page
                }];
            }
            const res = await React.$asyncPost(queryCode, data);
            const nTableData = React.$processingTableRequestData(res, idField);
            setTableData(nTableData);
            setTotal(res?.result?.total || res?.result?.totalCount || res?.result?.TotalCount || nTableData.length);
            handleAddLoading(false);
            handleClear();
        } catch (error) {
            console.log('error', error);
            handleAddLoading(false);
        }
    };

    // 添加loading
    const handleAddLoading = (status) => {
        setLoading(status);
        queryFormRef && queryFormRef.current && queryFormRef.current.modifyFormItemAttr('queryBtn', status);
    }

    // 清除操作数据
    const handleClear = () => {
        setRowID('');
        setRowData({});
        setSelectedRowKeys([]);
        setSelectedRows([]);
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

    // 确认
    const handleOk = () => {
        props && 'onOk' in props && props.onOk(rowData)
    };

    const { className, title, okText, cancelText, width, isFooter, componentName, tableHeight = 460, paginationFlag, multipleFlag, size = 'small', defaultPageSize = '20',
        okBtnFlag = 'Y', onCancel, cancelPopConfirmFlag, cancelPopConfirmTitle
    } = props;

    return (
        <Modal
            open={visible}
            width={width || '800px'}
            className={[className, 'public-modal-query-table'].join(' ')}
            title={title || '查询列表'}
            footer={isFooter !== 'N' ? (
                <div>
                    {cancelPopConfirmFlag === 'Y' ? (
                        <Popconfirm
                            title={cancelPopConfirmTitle || '确认操作吗?'}
                            onConfirm={onCancel ? onCancel : handleCancel}
                        >
                            <Button>
                                {cancelText || '取消'}
                            </Button>
                        </Popconfirm>
                    ) : (
                        <Button onClick={onCancel ? onCancel : handleCancel}>
                            {cancelText || '取消'}
                        </Button>
                    )}
                    {okBtnFlag !== 'N' && <Button style={{ marginLeft: '10px' }} type="primary" onClick={handleOk}>{okText || '确认'}</Button>}
                </ div>
            ) : null}
            onCancel={handleCancel}
        >
            <div style={{ display: queryFormData && queryFormData.length > 0 ? 'block' : 'none', marginBottom: '12px' }} className="common-dynamic-component">
                <DynamicRenderingForm
                    className="common-dynamic-component-form common-dynamic-component-form-margin-bottom0"
                    ref={queryFormRef}
                    rowData={{}}
                    selectData={selectData}
                    formData={queryFormData}
                    formItemCol={{ col: 6, labelCol: 6, wrapperCol: 17 }}
                />
            </div>
            <div>
                <PublicTablePagination
                    param={{
                        size,
                        page: paginationFlag === 'Y' ? page : false,
                        total: paginationFlag === 'Y' ? total : false,
                        loading,
                        // 表头配置
                        defaultPageSize,
                        componentName,
                        columns,
                        x: totalWidth, // 表格的宽度
                        y: tableHeight,
                        height: tableHeight + 50 + 'px',
                        data: tableData, // 表格数据
                    }}
                    rowSelection={multipleFlag === 'Y' ? {
                        selectedRowKeys,
                        selectedRows,
                        onChange: (selectedRowKeys, selectedRows) => {
                            setSelectedRowKeys(selectedRowKeys);
                            setSelectedRows(selectedRows);
                        },
                    } : null}
                    compilePage={handlePaginationChange}
                    getColumns={getColumnsData}
                    onRow={handleRowClick}
                    rowClassName={setRowClassName}
                />
            </div>
        </Modal>
    )
};

export default forwardRef(PublicModalQueryTable);