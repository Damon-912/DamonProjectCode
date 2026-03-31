/*
 * Create:      柿子
 * CreateDate:  2025/01/09
 * Describe：   父子表操作 - 父子表增删改查公共组件
 * */
import React, { useRef, useState, useEffect } from 'react';
import { Spin, Card, Row, Col, message, notification, Divider, Popconfirm } from 'antd';
import { EditOutlined, ProductOutlined, FormOutlined, DeleteOutlined } from '@ant-design/icons';
import { Util } from '@tools';
import { useLocation } from 'react-router-dom';
import { excelJS } from '@tools/excel';
import request from '@api';
import store from '@store';
import UseSyncCallback from '@pages/common/UseSyncCallback';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import PublicModalFormHooks from '@pages/common/PublicModalFormHooks';
import './style/index.less';

const ParentChildTableOperation = (props) => {
    let location = useLocation();
    let modalFormRef = useRef(null);
    let queryFormRef = useRef(null);
    let detailModalFormRef = useRef(null);
    let detailQueryFormRef = useRef(null);
    // 界面key值
    const [spinLoading, setSpinLoading] = useState(false);
    const [interfaceKey, setInterfaceKey] = useState(props?.componentName || Util.uuid());
    const [categoryData, setCategoryData] = useState({});
    const { contentHeight } = store.getState();
    const [selectData, setSelectData] = useState({});
    const [componentName, setComponentName] = useState(''); // 组件名
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
    const [modalComponentInfo, setModalComponentInfo] = useState({}); // 弹窗组件信息
    const [importLoading, setImportLoading] = useState(false);

    const [detailPage, setDetailPage] = useState(1);
    const [detailPageSize, setDetailPageSize] = useState(20);
    const [detailComponentName, setDetailComponentName] = useState(''); // 明细组件名
    const [detailColumns, setDetailColumns] = useState([]);
    const [detailTotalWidth, setDetailTotalWidth] = useState(0);
    const [detailQueryFormData, setDetailQueryFormData] = useState([]);
    const [detailLoading, setDetailLoading] = useState(false);
    const [detailTableData, setDetailTableData] = useState([]);
    const [detailTotal, setDetailTotal] = useState(0);
    const [detailRowID, setDetailRowID] = useState('');
    const [detailRowData, setDetailRowData] = useState({});
    const [detailModalComponentInfo, setDetailModalComponentInfo] = useState({}); // 明细弹窗组件信息

    useEffect(() => {
        if (props?.previewMode !== 'Y') {
            setSpinLoading(true);
            let newCategory;
            if ('paras' in props && props.paras && props.paras.params) { // 侧菜单获取类别参数
                newCategory = props?.paras?.params || '';
            } else {
                if (location && location.state && location.state.params) { // 头菜单获取类别参数、
                    newCategory = location?.state?.params || '';
                    React.$setSessionData('ParentChildTableOperation', newCategory, false);
                } else { // 头菜单刷新界面时获取类别
                    newCategory = React.$getSessionData('ParentChildTableOperation', false);
                }
            };
            let nCategoryData = Util.getObjByUrlStr(newCategory);
            console.log('ParentChildTableOperation', nCategoryData);
            setCategoryData(nCategoryData);
        }
    }, [location.state]);

    useEffect(() => {
        console.log('categoryData', categoryData)
        if (categoryData && JSON.stringify(categoryData) !== '{}') {
            getSelectData();
            getMenuColumnsData();
            setInterfaceKey(categoryData?.componentName || Util.uuid())
        }
    }, [categoryData]);

    const getSelectData = async () => {
        try {
            let selectCode = categoryData?.selectCode || '';
            if (!selectCode) return;
            // 获取字段类型下拉数据
            const res = await React.$asyncPost(selectCode);
            setSelectData(res && 'result' in res && res.result ? res.result : res);
        } catch (error) {
            console.log('error', error);
        }
    };

    // 根据菜单代码获取组件数据
    const getMenuColumnsData = async () => {
        try {
            let interfaceMenuCode = categoryData?.interfaceMenuCode || '';
            if (!interfaceMenuCode) {
                setSpinLoading(false);
                getColumnsData();
                getDetailColumns();
                return;
            };
            const res = await request.getMenuComponentInfo(interfaceMenuCode);
            let columnsArr = React.$processingTableRequestData(res);
            if (columnsArr && Array.isArray(columnsArr) && columnsArr.length > 0) {
                for (let i = 0; i < columnsArr.length; i++) {
                    if (columnsArr[i]?.dataIndex === 'componentName') { // 主列表数据
                        getColumnsData(columnsArr[i]);
                    } else if (columnsArr[i]?.dataIndex === 'modalComponentName') { // 弹窗组件信息
                        setModalComponentInfo(columnsArr[i]);
                    } else if (columnsArr[i]?.dataIndex === 'detailComponentName') { // 子列表组件数据
                        getDetailColumns(columnsArr[i]);
                    } else if (columnsArr[i]?.dataIndex === 'detailModalComponentName') { // 子列表弹窗组件数据
                        setDetailModalComponentInfo(columnsArr[i]);
                    }
                }
                setSpinLoading(false);
            } else {
                getColumnsData();
                getDetailColumns();
            }
        } catch (error) {
            console.log(error);
            getColumnsData();
            getDetailColumns();
        };
    };

    // 获取列表表头数据
    const getColumnsData = async (pComponentInfo = {}) => {
        try {
            let componentInfo = pComponentInfo;
            let componentName = componentInfo?.componentCode || '';
            // 如果通过菜单代码没有获取到对应的组件信息则单单独调接口获取
            if (!componentName) {
                componentName = categoryData?.componentName || '';
                if (!componentName) { // 如果参数也没配置就报错提醒
                    handleNotificationError('组件信息');
                    setSpinLoading(false);
                    return;
                };
                const res = await request.getComponentInfo(componentName);
                componentInfo = { ...(res?.result), totalWidth: res?.totalWidth || 0 };
            }
            let nColumns = componentInfo?.C || [];
            for (let i = 0; i < nColumns.length; i++) {
                if (nColumns[i]?.dataIndex === 'operation') {
                    nColumns[i].render = (text, record) => {
                        return (
                            <span>
                                {((categoryData?.saveCode && categoryData?.notEditableFlag !== 'Y') || categoryData?.editCode) && (
                                    <span className="common-record-span" onClick={(e) => handleCompile(record, 'main', e)}>
                                        <EditOutlined />
                                        编辑
                                    </span>
                                )}
                                {((categoryData?.saveCode && categoryData?.notEditableFlag !== 'Y') || categoryData?.editCode) && categoryData?.deleteCode ? <Divider type="vertical" /> : ''}
                                {categoryData?.deleteCode ? (
                                    <Popconfirm
                                        title="删除后不可恢复，确定要删除吗?"
                                        className="common-record-delete-span"
                                        onConfirm={(e) => handleDelete(record, e)}
                                    >
                                        <DeleteOutlined />
                                        删除
                                    </Popconfirm>
                                ) : ''}
                            </span>
                        )
                    }
                }
            }
            // 表头信息
            setColumns(nColumns);
            setComponentName(componentName);
            setTotalWidth(componentInfo?.totalWidth || 0);
            // 表单信息
            let nQueryFormData = componentInfo?.formData || [];
            for (let i = 0; i < nQueryFormData.length; i++) {
                if (nQueryFormData[i]?.typeCode === 'Input') {
                    nQueryFormData[i].onPressEnter = handleQuery;
                }
                if (nQueryFormData[i]?.dataIndex === 'queryBtn') { // 查询
                    nQueryFormData[i].type = 'primary';
                    nQueryFormData[i].onClick = handleQuery;
                }
                if (nQueryFormData[i]?.dataIndex === 'importBtn') { // 查询
                    nQueryFormData[i].ghost = true;
                    nQueryFormData[i].type = 'primary';
                    nQueryFormData[i].btnType = 'upload'; // 按钮类型
                    nQueryFormData[i].style = { textAlign: 'center' };
                    nQueryFormData[i].uploadParams = {
                        accept: '.xls,.xlsx',
                        name: 'file',
                        headers: {
                            authorization: 'authorization-text',
                        },
                        showUploadList: false,
                        beforeUpload: handleImport
                    };
                }
                if (nQueryFormData[i]?.dataIndex === 'addBtn') { // 新增
                    nQueryFormData[i].style = { textAlign: 'right' };
                    nQueryFormData[i].icon = 'PlusOutlined';
                    nQueryFormData[i].iconColor = '#1890ff';
                    nQueryFormData[i].onClick = handleAdd;
                }
            };
            setQueryFormData(nQueryFormData);
            setSpinLoading(false);
            setTimeout(() => {
                getTableData();
            }, 300)
        } catch (error) {
            console.log(error);
            setSpinLoading(false);
        };
    };

    useEffect(() => {
        if (queryFormData && Array.isArray(queryFormData) && queryFormData.length > 0) {
            getTableData();
        }
    }, [page, pageSize]);

    // 查询
    const handleQuery = () => {
        if (page === 1) {
            getTableData();
        } else {
            setPage(1);
        }
    };

    // 获取列表数据
    const getTableData = async () => {
        try {
            let queryCode = categoryData?.queryCode || '';
            if (!queryCode) {
                handleNotificationError('查询接口');
                return;
            };
            if (loading) return;
            setLoading(true);
            let values = {};
            if (queryFormRef && queryFormRef.current) {
                values = await queryFormRef.current.handleSave();
            };
            let data = {
                params: [{
                    ...values
                }],
                pagination: [{
                    pageSize: pageSize,
                    currentPage: page,
                    sortColumn: '',
                    sortOrder: ''
                }]
            };
            const res = await React.$asyncPost(queryCode, data);
            setTableData(React.$processingTableRequestData(res));
            setTotal(res?.result?.total || res?.total || 0);
            setLoading(false);
            setRowID('');
            setRowData({});
        } catch (error) {
            console.log(error);
            setLoading(false);
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
                    setDetailPage(1);
                    setDetailTableData([]);
                    setDetailTotal(0);
                    setDetailRowID('');
                    setDetailRowData({});
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

    // 添加
    const handleAdd = UseSyncCallback(() => {
        let idField = categoryData?.idField || 'id';
        if (!!(rowData?.[idField])) {
            setRowData({});
        }
        modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(true);
    });

    // 记录价格信息表单的值
    const handleRecordFormInput = record => {
        setRowData(oldData => {
            return {
                ...oldData,
                ...record
            }
        });
    };

    // 编辑
    const handleCompile = (record, type, e) => {
        React.$stopPropagation(e);
        if (type === 'detail') {
            setDetailRowData(record);
            detailModalFormRef && detailModalFormRef.current && detailModalFormRef.current.modifyVisible(true);
        } else {
            setRowData(record);
            modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(true);
        }
    };

    // 删除
    const handleDelete = async (record) => {
        try {
            if (!(categoryData?.deleteCode || '')) {
                message.error('删除接口维护异常！');
                return
            };
            let idField = categoryData?.idField || 'id';
            let data = {
                params: [{
                    [idField]: record && idField in record && record[idField] ? record[idField] : undefined
                }]
            }
            const res = await React.$asyncPost(categoryData.deleteCode, data);
            message.success(res?.errorMessage || '删除成功');
            getTableData();
        } catch (error) {
            console.log(error)
        };
    };


    // 保存
    const handleSave = async (values) => {
        try {
            let saveCode = categoryData?.saveCode || '';
            if (!saveCode) {
                handleNotificationError('保存接口');
                modalFormRef && modalFormRef.current && modalFormRef.current.modifyOkLoading(false);
                return;
            };
            let idField = categoryData?.idField || 'id';
            const res = await React.$asyncPost(saveCode, {
                params: [{
                    [idField]: rowData?.[idField] || undefined,
                    ...values,
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

    useEffect(() => {
        if (rowID) {
            handleDetailQuery();
        } else {
            handleClearDetailData();
        }
    }, [rowID]);

    // 清除明细操作数据
    const handleClearDetailData = () => {
        setDetailTableData([]);
        setDetailTotal(0);
        setDetailRowID('');
        setDetailRowData({});
    };

    // 获取明细列表表头静态数据
    const getDetailColumns = async (pComponentInfo = {}) => {
        try {
            let detailComponentInfo = pComponentInfo;
            let detailComponentName = detailComponentInfo?.componentCode || '';
            // 如果通过菜单代码没有获取到对应的组件信息则单单独调接口获取
            if (!detailComponentName) {
                detailComponentName = categoryData?.detailComponentName || '';
                if (!detailComponentName) { // 如果参数也没配置就报错提醒
                    handleNotificationError('明细组件信息');
                    return;
                };
                const res = await request.getComponentInfo(detailComponentName);
                detailComponentInfo = { ...(res?.result), totalWidth: res?.totalWidth || 0 };
            }
            let nDetailColumns = detailComponentInfo?.C || [];
            for (let i = 0; i < nDetailColumns.length; i++) {
                if (nDetailColumns[i]?.dataIndex === 'operation') {
                    nDetailColumns[i].render = (text, record) => {
                        return (
                            <span>
                                {((categoryData?.detailSaveCode && categoryData?.detailNotEditableFlag !== 'Y') || categoryData?.detailEditCode) && (
                                    <span className="common-record-span" onClick={(e) => handleCompile(record, 'detail', e)}>
                                        <EditOutlined />
                                        编辑
                                    </span>
                                )}
                                {((categoryData?.detailSaveCode && categoryData?.detailNotEditableFlag !== 'Y') || categoryData?.detailEditCode) && categoryData?.detailDeleteCode ? <Divider type="vertical" /> : ''}
                                {categoryData?.detailDeleteCode ? (
                                    <Popconfirm
                                        title="删除后不可恢复，确定要删除吗?"
                                        className="common-record-delete-span"
                                        onConfirm={(e) => handleDetailDelete(record, e)}
                                    >
                                        <DeleteOutlined />
                                        删除
                                    </Popconfirm>
                                ) : ''}
                            </span>
                        )
                    }
                }
            }
            // 表单信息
            let nDetailQueryFormData = detailComponentInfo?.formData || [];
            for (let i = 0; i < nDetailQueryFormData.length; i++) {
                if (nDetailQueryFormData[i]?.typeCode === 'Input') {
                    nDetailQueryFormData[i].onPressEnter = handleDetailQuery;
                }
                if (nDetailQueryFormData[i].dataIndex === 'queryBtn') {
                    nDetailQueryFormData[i].type = 'primary';
                    nDetailQueryFormData[i].onClick = handleDetailQuery;
                }
                if (nDetailQueryFormData[i]?.dataIndex === 'importBtn') { // 查询
                    nDetailQueryFormData[i].ghost = true;
                    nDetailQueryFormData[i].type = 'primary';
                    nDetailQueryFormData[i].btnType = 'upload'; // 按钮类型
                    nDetailQueryFormData[i].style = { textAlign: 'center' };
                    nDetailQueryFormData[i].uploadParams = {
                        accept: '.xls,.xlsx',
                        name: 'file',
                        headers: {
                            authorization: 'authorization-text',
                        },
                        showUploadList: false,
                        beforeUpload: handleDetailImport
                    };
                }
                if (nDetailQueryFormData[i]?.dataIndex === 'addBtn') { // 新增
                    nDetailQueryFormData[i].style = { textAlign: 'right' };
                    nDetailQueryFormData[i].icon = 'PlusOutlined';
                    nDetailQueryFormData[i].iconColor = '#1890ff';
                    nDetailQueryFormData[i].onClick = handleDetailAdd;
                }
            }
            // 表头信息
            setDetailColumns(nDetailColumns);
            setDetailTotalWidth(detailComponentInfo?.totalWidth || 0);
            setDetailComponentName(detailComponentName);
            setDetailQueryFormData(nDetailQueryFormData);
        } catch (error) {
            console.log(error);
        };
    };

    // 取不到实施的明细分页，需要用UseSyncCallback包裹一下
    const handleDetailQuery = UseSyncCallback(() => {
        if (detailPage === 1) {
            getDetailTableData();
        } else {
            setDetailPage(1);
        }
    });

    useEffect(() => {
        rowID && getDetailTableData();
    }, [detailPage, detailPageSize]);

    // 获取明细表头数据
    const getDetailTableData = async () => {
        try {
            let detailQueryCode = categoryData?.detailQueryCode || '';
            if (!detailQueryCode) {
                handleNotificationError('明细查询接口');
                return;
            };
            if (detailLoading) return;
            setDetailLoading(true);
            let values = {};
            if (detailQueryFormRef && detailQueryFormRef.current) {
                values = await detailQueryFormRef.current.handleSave();
            };
            let idField = categoryData?.idField || 'id';
            let data = {
                params: [{
                    [idField]: rowData?.[idField] || '',
                    ...values,
                }],
                pagination: [{
                    pageSize: detailPageSize,
                    currentPage: detailPage,
                    sortColumn: '',
                    sortOrder: ''
                }]
            };
            const res = await React.$asyncPost(detailQueryCode, data);
            setDetailTableData(React.$processingTableRequestData(res));
            setDetailTotal(res?.result?.total || res?.total || 0);
            setDetailLoading(false);
            setDetailRowID('');
            setDetailRowData({});
        } catch (error) {
            console.log(error);
            setDetailLoading(false);
        };
    };

    // 删除
    const handleDetailDelete = async (record) => {
        try {
            if (!(categoryData?.detailDeleteCode || '')) {
                message.error('明细删除接口维护异常！');
                return
            };
            let detailIdField = categoryData?.detailIdField || 'id';
            let data = {
                params: [{
                    [detailIdField]: record && detailIdField in record && record[detailIdField] ? record[detailIdField] : undefined
                }]
            }
            const res = await React.$asyncPost(categoryData.detailDeleteCode, data);
            message.success(res?.errorMessage || '删除成功');
            getDetailTableData();
        } catch (error) {
            console.log(error)
        };
    };

    const handleDetailRowClick = (record) => {
        return {
            // 单击行选中
            onClick: () => {
                if (detailRowID === '' || (detailRowID && detailRowID !== record.key)) {
                    setDetailRowID(record.key);
                } else {
                    setDetailRowID('');
                }
            }
        }
    };

    // 提供修改page和pageSize的回调函数
    const handleDetailPaginationChange = (page, pageSize) => {
        setDetailPage(page);
        setDetailPageSize(pageSize);
    };

    // 选中行操作
    const setDetailRowClassName = (record) => {
        return record.key === detailRowID ? 'common-table-select-bg' : '';
    };

    // 添加
    const handleDetailAdd = UseSyncCallback(() => {
        let detailIdField = categoryData?.detailIdField || 'id';
        if (!!(detailRowData?.[detailIdField])) {
            setDetailRowData({});
        }
        detailModalFormRef && detailModalFormRef.current && detailModalFormRef.current.modifyVisible(true);
    });

    // 记录价格信息表单的值
    const handleRecordDetailFormInput = record => {
        setDetailRowData(oldData => {
            return {
                ...oldData,
                ...record
            }
        });
    };

    const handleDetailSave = async (values) => {
        try {
            let detailSaveCode = categoryData?.detailSaveCode || '';
            if (!detailSaveCode) {
                handleNotificationError('明细查询接口');
                detailModalFormRef && detailModalFormRef.current && detailModalFormRef.current.modifyOkLoading(false);
                return;
            };
            let idField = categoryData?.idField || 'id';
            let detailIdField = categoryData?.detailIdField || 'id';
            const res = await React.$asyncPost(detailSaveCode, {
                params: [{
                    [idField]: rowData?.[idField] || '',
                    [detailIdField]: detailRowData?.[detailIdField] || '',
                    ...values
                }]
            });
            message.success(res?.errorMessage || '保存成功');
            detailModalFormRef && detailModalFormRef.current && detailModalFormRef.current.modifyVisible(false, 'Y');
            getDetailTableData();
        } catch (error) {
            console.log(error);
            detailModalFormRef && detailModalFormRef.current && detailModalFormRef.current.modifyOkLoading(false);
        };
    };

    // 组件渲染必传字段提醒
    const handleNotificationError = (name) => {
        notification.error({
            message: `系统提醒 :`,
            description: '您还未维护 ' + name + '，快抓紧去维护吧！',
        });
    };

    // 导入
    const handleImport = (file, fileList) => {
        const importCode = categoryData?.importCode || '';
        if (!importCode) {
            handleNotificationError('导入接口');
            return;
        }
        handleCommonImport(file, queryFormRef, importCode, 'main')
        return false;
    };

    const handleDetailImport = (file, fileList) => {
        const importCode = categoryData?.detailImportCode || '';
        if (!importCode) {
            handleNotificationError('明细导入接口');
            return;
        }
        if (!rowID) {
            message.error('请先选择主列表数据！');
            return;
        }
        handleCommonImport(file, detailQueryFormRef, importCode, 'detail')
        return false;
    };

    const handleCommonImport = (file, formRef, importCode, type) => {
        if (importLoading) return;
        excelJS.importExcel(file, 'keyVal')
            .then(async (jsonData) => {
                importSplitArr = Util.cutArray(jsonData, categoryData?.importSplitCount || 200);
                formRef && formRef.current && formRef.current.modifyFormItemAttr('importBtn', true);
                setImportLoading(true);
                handleImportProcessQueue(formRef, importCode, type);
            })
            .catch((error) => {
                console.error(error); // 处理错误
                setImportLoading(false);
                formRef && formRef.current && formRef.current.modifyFormItemAttr('importBtn', false);
            });
    };

    let importSplitArr = [];
    let isImportProcessing = false;

    const handleImportProcessQueue = async (formRef, importCode, type) => {
        if (isImportProcessing || importSplitArr.length === 0) {
            setImportLoading(false);
            formRef && formRef.current && formRef.current.modifyFormItemAttr('importBtn', false);
            return;
        };
        // 设置标志位，表示开始处理数据
        isImportProcessing = true;
        const firstImportArr = importSplitArr.shift(); // 获取第一项
        try {
            await handleBatchImport(firstImportArr, formRef, importCode, type);
        } catch (error) {
            console.log(`导入错误数据： ${JSON.stringify(firstImportArr)}:`,);
        }
        // 完成这项工作后，重置标志位，并尝试开始下一项工作。
        isImportProcessing = false;
        handleImportProcessQueue(formRef, importCode, type);
    };

    // 批量导入
    const handleBatchImport = async (jsonData, formRef, importCode, type) => {
        return new Promise(async (resolve, reject) => {
            try {
                if (jsonData && Array.isArray(jsonData) && jsonData.length === 0) {
                    setImportLoading(false);
                    if (type === 'main') {
                        setLoading(false);
                        setRowID('');
                        setRowData({});
                    } else {
                        setDetailLoading(false);
                        setDetailRowID('');
                        setDetailRowData({});
                    }
                    formRef.current && formRef.current.modifyFormItemAttr('importBtn', false);
                    message.success('导入完成！');
                    resolve();
                    return;
                };
                let importExtendAttrs = {};
                if (type === 'main') {
                    importExtendAttrs.componentName = componentName || categoryData?.componentName || undefined; // 组件名
                    importExtendAttrs.groupType = categoryData?.groupType || undefined;
                } else {
                    // 导入明细需传入主列表ID
                    let idField = categoryData?.idField || 'id';
                    importExtendAttrs[idField] = rowData[idField] || undefined;
                }
                let data = {
                    params: [{
                        importArr: jsonData,
                        ...importExtendAttrs
                    }]
                }
                let res = await React.$asyncPost(importCode, data);
                let rTableData = React.$processingTableRequestData(res, 'uuid');
                let nTotal = res?.result?.total || res?.result?.totalCount || res?.result?.TotalCount || res?.total || res?.totalCount || res?.TotalCount || tableData?.length || 0;
                if (type === 'main') {
                    setTableData([...tableData, ...rTableData]);
                    setTotal(total + nTotal);
                } else {
                    setDetailTableData([...detailTableData, ...rTableData]);
                    setDetailTotal(detailTotal + nTotal);
                }
                resolve();
            } catch (error) {
                console.log(error);
                reject(error);
            }
        });
    };

    return (
        <Spin tip={importLoading ? '正在导入...' : '资源加载中...'} spinning={spinLoading || importLoading} key={interfaceKey}>
            <div className="parent-child-table-operation">
                <Row>
                    <Col span={parseInt(categoryData?.leftCardCol || 12)}>
                        <div style={{ paddingRight: '6px', position: 'relative' }}>
                            <Card
                                size="small"
                                bordered={false}
                                title={(
                                    <div className="common-card-title-icon">
                                        <ProductOutlined />
                                        {categoryData?.cardTitle || '主列表'}
                                    </div>
                                )}
                            >
                                <div style={{ marginBottom: '12px' }} className="common-dynamic-component">
                                    <DynamicRenderingForm
                                        className="common-dynamic-component-form common-dynamic-component-form-margin-bottom0"
                                        ref={queryFormRef}
                                        rowData={{}}
                                        formData={[...queryFormData]}
                                        selectData={selectData}
                                        formItemCol={{ col: 6, labelCol: 6, wrapperCol: 17 }}
                                    />
                                </div>
                                <PublicTablePagination
                                    param={{
                                        page, // 当前页数
                                        total, // 数据总条数
                                        loading,
                                        componentName,
                                        defaultPageSize: categoryData?.defaultPageSize || '20',
                                        columns,
                                        data: tableData, // 表格数据
                                        x: totalWidth, // 表格的宽度
                                        y: categoryData?.fixedHeightFlag !== 'N' ? (contentHeight - 182 - (props?.additionalHeight || 0)) : '',
                                        height: categoryData?.fixedHeightFlag !== 'N' ? (contentHeight - 142 - (props?.additionalHeight || 0) + 'px') : '',
                                    }}
                                    compilePage={handlePaginationChange}
                                    getColumns={getColumnsData}
                                    onRow={handleRowClick}
                                    rowClassName={setRowClassName}
                                />
                            </Card>
                            <div className="common-card-right-split-line"></div>
                        </div>
                    </Col>
                    <Col span={24 - parseInt(categoryData?.leftCardCol || 12)}>
                        <Card
                            size="small"
                            bordered={false}
                            title={(
                                <div className="common-card-title-icon">
                                    <FormOutlined />
                                    {categoryData?.detailCardTitle || '明细维护'}
                                </div>
                            )}
                        >
                            <div>
                                <div style={{ marginBottom: '12px' }} className="common-dynamic-component">
                                    <DynamicRenderingForm
                                        className="common-dynamic-component-form common-dynamic-component-form-margin-bottom0"
                                        ref={detailQueryFormRef}
                                        rowData={{}}
                                        formData={detailQueryFormData}
                                        selectData={selectData}
                                        formItemCol={{ col: 6, labelCol: 6, wrapperCol: 17 }}
                                    />
                                </div>
                                <PublicTablePagination
                                    param={{
                                        page: detailPage, // 当前页数
                                        total: detailTotal, // 数据总条数
                                        loading: detailLoading,
                                        componentName: detailComponentName,
                                        defaultPageSize: categoryData?.detailDefaultPageSize || '20',
                                        // 表头配置
                                        columns: detailColumns,
                                        data: detailTableData, // 表格数据
                                        x: detailTotalWidth, // 表格的宽度
                                        y: categoryData?.fixedHeightFlag !== 'N' ? (contentHeight - 182 - (props?.additionalHeight || 0)) : '',
                                        height: categoryData?.fixedHeightFlag !== 'N' ? (contentHeight - 142 - (props?.additionalHeight || 0) + 'px') : '',
                                    }}
                                    compilePage={handleDetailPaginationChange}
                                    getColumns={getDetailColumns}
                                    onRow={handleDetailRowClick}
                                    rowClassName={setDetailRowClassName}
                                />
                            </div>
                        </Card>
                    </Col>
                </Row>

                {/* 添加主表 */}
                <PublicModalFormHooks
                    modalKey={'parent-child-main-modal-form-' + interfaceKey}
                    width={categoryData?.modalWidth || props?.modalWidth || '520px'}
                    idField={categoryData?.idField || ''}
                    componentName={categoryData?.modalComponentName || (categoryData && 'componentName' in categoryData && categoryData.componentName ? (categoryData.componentName + 'Form') : '')}
                    componentInfo={modalComponentInfo}
                    rowData={rowData}
                    selectData={selectData}
                    formItemCol={{ labelCol: 24, wrapperCol: 24, col: 24 }}
                    ref={modalFormRef}
                    recordFormInput={handleRecordFormInput}
                    handleSave={handleSave}
                />

                {/* 添加明细 */}
                <PublicModalFormHooks
                    modalKey={'parent-child-detail-modal-form-' + interfaceKey}
                    width={categoryData?.detailModalWidth || props?.detailModalWidth || '520px'}
                    idField={categoryData?.detailIdField || ''}
                    componentName={categoryData?.detailModalComponentName || (categoryData && 'detailComponentName' in categoryData && categoryData.detailComponentName ? (categoryData.detailComponentName + 'Form') : '')}
                    componentInfo={detailModalComponentInfo}
                    rowData={detailRowData}
                    selectData={selectData}
                    formItemCol={{ labelCol: 24, wrapperCol: 24, col: 24 }}
                    ref={detailModalFormRef}
                    recordFormInput={handleRecordDetailFormInput}
                    handleSave={handleDetailSave}
                />
            </div>
        </Spin>
    )
};

export default ParentChildTableOperation;