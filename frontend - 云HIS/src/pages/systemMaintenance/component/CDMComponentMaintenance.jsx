// 组件表列按钮维护 - 组件Form表单字段
import React, { useState, useEffect, useRef } from 'react';
import { Button, message, Popconfirm, Input, Divider } from 'antd';
import { EditOutlined, DeleteOutlined, PlusOutlined, VerticalAlignTopOutlined, VerticalAlignBottomOutlined, HourglassOutlined, CopyOutlined } from '@ant-design/icons';
import { Util } from '@tools';
import store from '@store';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import PublicModalFormHooks from '@pages/common/PublicModalFormHooks';
import PublicModalQueryTable from '@pages/common/PublicModalQueryTable';
import FieldSelectionModal from './FieldSelectionModal';

const CDMComponentMaintenance = (props) => {
    const propsComponentID = props?.componentID || '';
    const propsFormData = props?.formData || [];
    const addHandler = useRef(null);
    const compileHandler = useRef(null);
    const deleteHandler = useRef(null);
    let modalFormRef = useRef(null);
    let fieldSelectRef = useRef(null);
    let modalCopyRef = useRef(null);
    let rowDataRef = useRef({});
    const { contentHeight } = store.getState();
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(20);
    const [loading, setLoading] = useState(false);
    const [tableData, setTableData] = useState([]);
    const [total, setTotal] = useState(0);
    const [rowID, setRowID] = useState('');
    const [rowData, setRowData] = useState({});
    const [formData, setFormData] = useState([]);
    const [code, setCode] = useState(undefined);
    const [descripts, setDescripts] = useState(undefined);
    const [selectedRowKeys, setSelectedRowKeys] = useState([]);
    const [selectedRows, setSelectedRows] = useState([]);

    useEffect(() => {
        getTableData();
    }, [page, pageSize, propsComponentID]);

    // 查询
    const handleQuery = () => {
        if (page === 1) {
            getTableData();
        } else {
            setPage(1);
        }
    };

    // 提供修改page和pageSize的回调函数
    // const handlePaginationChange = (page, pageSize) => {
    //     setPage(page);
    //     setPageSize(pageSize);
    // };

    // 获取列表数据
    const getTableData = async (pComponentID) => {
        try {
            if (!(props?.queryCode || '')) {
                message.error('查询接口维护异常！');
                return
            };
            let reactComID = pComponentID || propsComponentID;
            if (!reactComID) {
                setTableData([]);
                setTotal(0);
                setRowID('');
                setRowData({});
                return;
            }
            setLoading(true);
            let data = {
                params: [{
                    code,
                    descripts,
                    reactComID, // 主表ID
                }],
                pagination: [{
                    pageSize: 10000,
                    currentPage: 1,
                    // pageSize: pageSize,
                    // currentPage: page,
                    sortColumn: '',
                    sortOrder: ''
                }]
            }
            const res = await React.$asyncPost(props.queryCode, data);
            setTableData(React.$processingTableRequestData(res, '', 0));
            setTotal(res.result?.total || 0);
            setRowData({});
            setSelectedRowKeys([]);
            setSelectedRows([]);
            setLoading(false);
        } catch (error) {
            console.log(error);
            setLoading(false);
        }
    };

    // 操作行
    const handleRowClick = (record) => {
        return {
            // 单击行选中
            onClick: () => {
                if (rowID === '' || (rowID && rowID !== record.id)) {
                    setRowID(record.id);
                } else {
                    setRowID('');
                }
            }
        }
    };

    // 选中行操作
    const setRowClassName = (record) => {
        return record.id === rowID ? 'common-table-select-bg' : '';
    };
    // 添加
    const handleAdd = () => {
        if (props?.addMode === 'modalSelect') { // 添加通过列表选择
            fieldSelectRef && fieldSelectRef.current && fieldSelectRef.current.modifyVisible(true);
        } else {
            const currentRowData = rowDataRef.current;
            if (currentRowData && currentRowData.id) {
                rowDataRef.current = {}; // 清空 ref
                setRowData({});
            };
            modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(true);
        };
        getJumpSelectData();
    };

    // 编辑
    const handleCompile = (record, e) => {
        setRowData({ ...record });
        modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(true);
        getJumpSelectData();
    };

    const handleDelete = async (record) => {
        try {
            if (!(props?.deleteCode || '')) {
                message.error('删除接口维护异常！');
                return
            };
            let data = {
                params: [{
                    id: record?.id || undefined
                }]
            }
            const res = await React.$asyncPost(props.deleteCode, data);
            message.success(res?.errorMessage || '删除成功');
            getTableData();
        } catch (error) {
            console.log(error)
        };
    };

    useEffect(() => {
        addHandler.current = handleAdd;
        compileHandler.current = handleCompile;
        deleteHandler.current = handleDelete;
    }, [props]);  // 当 props 变化时重新定义 handleDelete

    // 同步状态到 ref
    useEffect(() => {
        rowDataRef.current = rowData;
    }, [rowData]);

    // 获取跳转到下拉数据
    const getJumpSelectData = async () => {
        try {
            let formData = [...propsFormData];
            let isGetData = false;
            for (var i = 0; i < formData.length; i++) { // 判断当前form是否需要获取跳转下拉数据
                if (formData[i].dataIndex === 'jumpID' || formData[i].dataIndex === 'linkValueID') {
                    isGetData = true;
                    break;
                }
            }
            if (isGetData) {
                let data = {
                    params: [{
                        componentID: propsComponentID, // 主表ID
                        fieldID: rowData?.id || '', // 当前列ID
                    }],
                }
                let res = await React.$asyncPost('01040288', data);
                for (var i = 0; i < formData.length; i++) {
                    if (formData[i].dataIndex === 'jumpID') {
                        formData[i].detailItem = res?.result?.jumpID || [];
                    }
                    if (formData[i].dataIndex === 'linkValueID') {
                        formData[i].detailItem = res?.result?.linkValueID || [];;
                    }
                }
            }
            setFormData(formData)
        } catch (error) {
            console.log(error)
        }
    }

    // 保存
    const handleSave = async (values, type) => {
        try {
            if (!(props?.saveCode || '')) {
                message.error('保存接口维护异常！');
                type !== 'modalTable' && modalFormRef && modalFormRef.current && modalFormRef.current.modifyOkLoading(false);
                return
            };
            let paramsData = {
                reactComID: propsComponentID, // 主表ID
                ...rowData,
                ...values,
            };
            const res = await React.$asyncPost(props.saveCode, {
                params: [paramsData]
            });
            message.success(res?.errorMessage || '保存成功');
            if (type === 'modalTable') {
                fieldSelectRef && fieldSelectRef.current && fieldSelectRef.current.modifyVisible(false);
            } else {
                modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(false, 'Y');
            }
            getTableData();
        } catch (error) {
            console.log(error);
            type !== 'modalTable' && modalFormRef && modalFormRef.current && modalFormRef.current.modifyOkLoading(false);
        }
    };

    // 选择保存
    const handleModalSelectSave = values => {
        if (props?.type === 'form') {
            values.required = 'N';
            values.disabled = 'N';
            values.display = 'Y';
        };
        handleSave(values, 'modalTable');
    };

    // 记录价格信息表单的值
    const handleRecordFormInput = record => {
        setRowData(oldData => {
            return {
                ...oldData,
                ...record
            };
        });
    };

    // 上移
    const handleUp = () => {
        let keys = Util.customDeepCopy(selectedRowKeys);
        let data = Util.customDeepCopy(tableData);
        if (!(keys && keys.length > 0)) return;
        let newKeys = []
        keys = keys.sort(function (m, n) {
            if (m < n) return -1;
            else if (m > n) return 1;
            else return 0;
        });
        for (let i = 0; i < keys.length; i++) {
            let currentKey = keys[i];
            let nextKey = Number(currentKey) - 1;
            if (currentKey === 0) {
                newKeys.push(currentKey);
                continue;
            }
            let curRowData = data[currentKey];
            let upRowData = data[nextKey];
            let curRowKey = curRowData?.key || 0;
            let upRowKey = upRowData?.key || 0;
            upRowData.key = curRowKey;
            curRowData.key = upRowKey;
            data[currentKey] = upRowData;
            data[nextKey] = curRowData;
            newKeys.push(String(nextKey));
        };
        setTableData([...data]);
        setSelectedRowKeys([...newKeys]);
    };

    // 下移
    const handleDown = () => {
        let keys = Util.customDeepCopy(selectedRowKeys);
        let data = Util.customDeepCopy(tableData);
        if (!(keys && keys.length > 0)) return;
        let newKeys = []
        keys = keys.sort(function (m, n) {
            if (m < n) return -1;
            else if (m > n) return 1;
            else return 0;
        });
        for (let i = keys.length - 1; i >= 0; i--) {
            let currentKey = keys[i];
            let nextKey = Number(currentKey) + 1;
            if (currentKey === data.length - 1) {
                newKeys.push(currentKey);
                continue;
            }
            let curRowData = data[currentKey];
            let upRowData = data[nextKey];
            let curRowKey = curRowData?.key || 0;
            let upRowKey = upRowData?.key || 0;
            upRowData.key = curRowKey;
            curRowData.key = upRowKey;
            data[currentKey] = upRowData;
            data[nextKey] = curRowData;
            newKeys.push(String(nextKey));
        }
        setTableData([...data]);
        setSelectedRowKeys([...newKeys]);
    };

    // 保存上下移序号
    const handleSeqNoSave = async () => {
        try {
            let sortArr = [];
            for (let i = 0; i < tableData.length; i++) {
                sortArr.push({
                    id: tableData[i].id,
                    seqNo: Number(tableData[i]?.key || 0) + 1,
                })
            }
            let data = {
                params: [{
                    reactComID: propsComponentID, // 主表ID
                    className: props?.className || '',
                    sortArr
                }]
            }
            let res = await React.$asyncPost('01010051', data);
            message.success(res.errorMessage ? res.errorMessage : '保存成功');
            getTableData();
        } catch (error) {
            console.log(error)
        }
    };

    // 复制数据
    const handleCopyData = () => {
        modalCopyRef && modalCopyRef.current && modalCopyRef.current.modifyVisible(true);
    };

    const handleConfirmCopy = async (record) => {
        try {
            let selectedRowIDs = [];
            for (let i = 0; i < selectedRows.length; i++) {
                selectedRowIDs.push(selectedRows[i].id)
            }
            let data = {
                params: [{
                    fromComponentID: propsComponentID,
                    toComponentID: record?.id || '',
                    data: selectedRowIDs,
                    type: props?.type || ''
                }]
            }
            let res = await React.$asyncPost('01010052', data);
            message.success(res?.errorMessage || '操作成功');
            modalCopyRef && modalCopyRef.current && modalCopyRef.current.modifyVisible(false);
        } catch (error) {
            console.log(error)
        }
    };

    // 列表操作
    const operationObj = {
        width: 130,
        title: '操作',
        align: 'center',
        fixed: 'right',
        key: 'operation',
        render: (text, record) => (
            <span>
                <span className="common-record-span" onClick={(e) => compileHandler && compileHandler.current && compileHandler.current(record, e)}>
                    <EditOutlined />
                    编辑
                </span>
                <Divider type="vertical" />
                <Popconfirm
                    title="删除后不可恢复，确定要删除吗?"
                    className="common-record-delete-span"
                    onConfirm={(e) => deleteHandler && deleteHandler.current && deleteHandler.current(record, e)}
                >
                    <DeleteOutlined />
                    删除
                </Popconfirm>
            </span >
        ),
    };
    return (
        <div>
            <div className="flex-between" style={{ padding: '16px 12px 6px 12px' }}>
                <div className="flex-align-items">
                    {'className' in props && props.className ? (
                        <>
                            <span
                                className={[!(selectedRowKeys && selectedRowKeys.length > 0) ? 'common-no-drop' : 'common-pointer', 'flex-align-items'].join(' ')}
                                onClick={handleUp}
                            >
                                <VerticalAlignTopOutlined className={selectedRowKeys && selectedRowKeys.length > 0 ? 'common-record-span' : 'common-no-drop'} />
                                上移
                            </span>
                            <Divider type="vertical" />
                            <span
                                className={[!(selectedRowKeys && selectedRowKeys.length > 0) ? 'common-no-drop' : 'common-pointer', 'flex-align-items'].join(' ')}
                                onClick={handleDown}
                            >
                                <VerticalAlignBottomOutlined className={selectedRowKeys && selectedRowKeys.length > 0 ? 'common-record-span' : 'common-no-drop'} />
                                下移
                            </span>
                            <Divider type="vertical" />
                            <span
                                className={[!props.componentID ? 'common-no-drop' : 'common-pointer', 'flex-align-items'].join(' ')}

                                onClick={handleSeqNoSave}
                            >
                                <HourglassOutlined className={props.componentID ? 'common-record-span' : 'common-no-drop'} />
                                保存
                            </span>
                            <Divider type="vertical" />
                            <Popconfirm
                                title="code重复则跳过不覆盖，不存在则添加，确认复制吗?"
                                disabled={!(tableData && tableData.length > 0)}
                                onConfirm={handleCopyData}
                            >
                                <span
                                    style={{ marginRight: '24px' }}
                                    className={[!(tableData && tableData.length > 0) ? 'common-no-drop' : 'common-pointer', 'flex-align-items'].join(' ')}
                                >
                                    <CopyOutlined className={(tableData && tableData.length > 0) ? 'common-record-span' : 'common-no-drop'} />
                                    复制
                                </span>
                            </Popconfirm>
                        </>
                    ) : ''}
                    代码：<Input
                        value={code}
                        title="输入内容后可回车检索"
                        placeholder="请输入( Enter )"
                        style={{ width: '150px', marginRight: '12px' }}
                        onChange={e => setCode(e.target.value)}
                        onPressEnter={handleQuery}
                    />
                    描述：<Input
                        value={descripts}
                        title="输入内容后可回车检索"
                        placeholder="请输入( Enter )"
                        style={{ width: '150px', marginRight: '12px' }}
                        onChange={e => setDescripts(e.target.value)}
                        onPressEnter={handleQuery}
                    />
                    <Button type="primary" loading={loading} onClick={handleQuery}>查询</Button>
                </div>
                <div>
                    <Button
                        style={{ marginLeft: '12px' }}
                        icon={<PlusOutlined className={propsComponentID ? 'common-record-span' : ''} />}
                        disabled={!propsComponentID}
                        onClick={() => addHandler && addHandler.current && addHandler.current()}
                    >
                        添加
                    </Button>
                </div>
            </div>
            <PublicTablePagination
                param={{
                    // page, // 当前页数
                    // total, // 数据总条数
                    loading,
                    // defaultPageSize: 20,
                    data: tableData, // 表格数据
                    y: contentHeight - 252,
                    columns: [...props?.columns || [], operationObj], // 表头配置
                    x: props?.totalWidth || 0, // 表格的宽度
                    height: contentHeight - 212 + 'px',
                }}
                rowSelection={{
                    selectedRowKeys,
                    onChange: (selectedRowKeys, selectedRows) => {
                        setSelectedRowKeys(selectedRowKeys);
                        setSelectedRows(selectedRows);
                    },
                }}
                // compilePage={handlePaginationChange}
                onRow={handleRowClick}
                rowClassName={setRowClassName}
            />

            {/* 添加/编辑 */}
            <PublicModalFormHooks
                width={props?.type !== 'form' || props?.addMode === 'modalSelect' ? 600 : 1000}
                formData={formData}
                selectData={props?.selectData || {}}
                rowData={rowData}
                formItemCol={props?.type !== 'form' || props?.addMode === 'modalSelect' ? { col: 24, labelCol: 24, wrapperCol: 24 } : { col: 12, labelCol: 6, wrapperCol: 16 }}
                ref={modalFormRef}
                recordFormInput={handleRecordFormInput}
                handleSave={handleSave}
            />

            {/* 列表选择 */}
            <FieldSelectionModal
                formData={formData}
                width={props?.modalWidth || ''}
                tableHeight={props?.modalTableHeight || ''}
                title={props?.modalTitle || ''}
                componentName={props?.modalComponentName || ''}
                queryCode={props?.modalQueryCode || ''}
                selectCode={props?.modalSelectCode || ''}
                paginationFlag={props?.modalPaginationFlag || ''}
                ref={fieldSelectRef}
                onOk={handleModalSelectSave}
            />

            {/* 复制数据 */}
            <PublicModalQueryTable
                ref={modalCopyRef}
                width="1000px"
                paginationFlag="Y"
                tableHeight={450}
                title="数据复制到"
                queryCode="01010022"
                componentName="ComponentDataMaintenance"
                onOk={handleConfirmCopy}
            />
        </div>
    )
};

export default CDMComponentMaintenance;