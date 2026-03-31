/*
 * Create:      柿子
 * CreateDate:  2024/05/17
 * Describe：   动态渲染界面 - 单表查询/单表增删改查
 * */
import React, { useState, useEffect, useRef, forwardRef, useImperativeHandle } from 'react';
import { Tabs, Row, Col, Button, notification, Popconfirm, Divider, message, Spin, Popover, Select, Input } from 'antd';
import { EditOutlined, DeleteOutlined, PlusOutlined, SyncOutlined, FilterOutlined, CloudDownloadOutlined, CloseOutlined } from '@ant-design/icons';
import { Util } from '@tools';
import { excelJS } from '@tools/excel';
import { useLocation } from 'react-router-dom';
import request from '@api';
import store from '@store';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import PublicDrawerFormHook from '@pages/common/PublicDrawerFormHook';
import PublicModalFormHooks from '@pages/common/PublicModalFormHooks';
import './style/index.less';

const SingleTableOperation = (props, ref) => {
    let queryFormRef = useRef(null);
    let queryDivRef = useRef(null);
    let publicDrawerRef = useRef(null);
    let dataGroupFormRef = useRef(null);
    let location = useLocation();
    const dataGroupModalForm = [{
        title: '分组名称',
        dataIndex: 'groupName',
        typeCode: 'Input',
        required: 'Y',
    }];
    const userData = React.$getUserData();
    const { contentHeight } = store.getState();
    // 界面key值
    const [interfaceKey, setInterfaceKey] = useState(props?.componentName || Util.uuid());
    const [categoryData, setCategoryData] = useState({});
    const [tabItems, setTabItems] = useState([]);
    const [pullLoading, setPullLoading] = useState(false);
    const [activeTabKey, setActiveTabKey] = useState('all');
    const [spinLoading, setSpinLoading] = useState(false);
    const [queryDivHeight, setQueryDivHeight] = useState(44);
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(20);
    const [componentName, setComponentName] = useState(''); // 组件名
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
    const [modalComponentInfo, setModalComponentInfo] = useState({}); // 弹窗组件信息
    const [dataGroupRowData, setDataGroupRowData] = useState({}); // 数据分组
    const [dataGroupQueryParams, setDataGroupQueryParams] = useState({}); // 数据分组当前查询条件数据
    const [advancedVisible, setAdvancedVisible] = useState(false);
    const [autoAddAdvancedFlag, setAutoAddAdvancedFlag] = useState(true); // 首次进界面自动添加高级筛选标志
    const [advancedFilteringCriteria, setAdvancedFilteringCriteria] = useState([]);
    const [importLoading, setImportLoading] = useState(false);

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        handleQuery,
        getQueryParams,
    }));

    useEffect(() => {
        if (props?.previewMode !== 'Y') {
            setSpinLoading(true);
            let newCategory;
            if ('paras' in props && props.paras && props.paras.params) { // 侧菜单获取类别参数
                newCategory = props?.paras?.params || '';
            } else {
                if (location && location.state && location.state.params) { // 头菜单获取类别参数、
                    newCategory = location?.state?.params || '';
                    React.$setSessionData('SingleTableOperation', newCategory, false);
                } else { // 头菜单刷新界面时获取类别
                    newCategory = React.$getSessionData('SingleTableOperation', false);
                }
            };
            let nCategoryData = Util.getObjByUrlStr(newCategory);
            console.log('SingleTableOperation', nCategoryData);
            setCategoryData(nCategoryData);
            // 头菜单直接切换时会有问题，需清空一下
            setTabItems([]);
            setActiveTabKey('all');
            setSelectData({});
            setComponentName('');
            setColumns([]);
            setTotalWidth(0);
            setQueryFormData([]);
            setTableData([]);
            setTotal(0);
            setPage(1);
            setPageSize(20);
            setRowID('');
            setRowData({});
            setSelectedRowKeys([]);
            setSelectedRows([]);
            setModalComponentInfo({});
            setDataGroupRowData({});
            setDataGroupQueryParams({});
            setAdvancedVisible(false);
            setAutoAddAdvancedFlag(true);
            setAdvancedFilteringCriteria([]);
        }
    }, [location.state]);

    useEffect(() => {
        // 界面预览模式
        if (props?.previewMode === 'Y') {
            setCategoryData(props?.categoryData || {});
        }
    }, [props.categoryData])

    useEffect(() => {
        // 界面预览模式
        if (props?.previewMode === 'Y') {
            let nColumns = [...props?.columns || []].map(item => {
                return {
                    ...item,
                    filterDropdown: null,
                    filterIcon: null
                }
            });
            setColumns(nColumns);
            setTotalWidth(props?.totalWidth || 0);
        }
    }, [props.columns, props.totalWidth])

    useEffect(() => {
        // 界面预览模式
        if (props?.previewMode === 'Y') {
            // 表单信息
            let nQueryFormData = props?.queryFormData || [];
            for (let i = 0; i < nQueryFormData.length; i++) {
                if (nQueryFormData[i]?.typeCode === 'Input' || nQueryFormData[i]?.fieldTypeCode === 'Input') {
                    nQueryFormData[i].onPressEnter = handleQuery;
                }
                if (nQueryFormData[i]?.code === 'queryBtn' || nQueryFormData[i]?.dataIndex === 'queryBtn') { // 查询
                    nQueryFormData[i].onClick = handleQuery;
                }
                if (nQueryFormData[i]?.dataIndex === 'importBtn') { // 导入
                    nQueryFormData[i].ghost = true;
                    nQueryFormData[i].type = 'primary';
                    nQueryFormData[i].style = { textAlign: 'center' };
                    nQueryFormData[i].btnType = 'upload'; // 按钮类型
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
            };
            setQueryFormData(nQueryFormData);
        }
    }, [props.queryFormData])

    useEffect(() => {
        // 界面预览模式
        if (props?.previewMode === 'Y') {
            setModalComponentInfo({
                formData: props?.modalFormData || []
            });
        }
    }, [props.modalFormData])

    useEffect(() => {
        if (categoryData && JSON.stringify(categoryData) !== '{}') {
            if (props?.previewMode !== 'Y') {
                getSelectData();
                getMenuColumnsData();
                getTabItems();
            } else {
                getTableData();
            }
            setInterfaceKey(categoryData?.componentName || Util.uuid())
        }
    }, [categoryData]);

    const getTabItems = async () => {
        try {
            // dataGroupQueryCode数据分组接口【注：可将数据按查询条件分组】
            let dataGroupQueryCode = categoryData?.dataGroupQueryCode || '';
            if (!dataGroupQueryCode) return;
            if (dataGroupQueryCode === '123') {
                // 测试用
                const nTabItems = [{
                    key: 'all',
                    label: '全部',
                }, {
                    key: '2',
                    label: '用户',
                }, {
                    key: '3',
                    label: '医生',
                }];
                setTabItems(nTabItems);
                return;
            }
            const res = await React.$asyncPost(dataGroupQueryCode, {
                params: [{
                    menuDetailCode: categoryData?.interfaceMenuCode || '',
                }]
            });
            let nTabItems = React.$processingTableRequestData(res);
            if (nTabItems && nTabItems.length > 0) {
                let allObj = {
                    key: 'all',
                    label: '全部',
                };
                setTabItems([allObj, ...nTabItems]);
            }
        } catch (error) {
            console.log(error);
        }
    };

    // 切换医嘱查询页签
    const handleTabChange = key => {
        setActiveTabKey(key);
    };

    // 组件渲染必传字段提醒
    const handleNotificationError = (name) => {
        notification.error({
            message: `系统提醒 :`,
            description: '您还未维护 ' + name + '，快抓紧去维护吧，不然界面没法渲染哦！',
        });
    };

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
                    }
                }
                setSpinLoading(false);
            } else {
                getColumnsData();
            }
        } catch (error) {
            console.log(error);
            getColumnsData();
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
            // 表头信息
            setColumns(componentInfo?.C || []);
            setComponentName(componentName);
            setTotalWidth(componentInfo?.totalWidth || 0);
            // 表单信息
            let nQueryFormData = componentInfo?.formData || [];
            for (let i = 0; i < nQueryFormData.length; i++) {
                if (nQueryFormData[i]?.typeCode === 'Input') {
                    nQueryFormData[i].onPressEnter = handleQuery;
                };
                if (nQueryFormData[i]?.dataIndex === 'queryBtn') { // 查询
                    nQueryFormData[i].type = 'primary';
                    nQueryFormData[i].onClick = handleQuery;
                };
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
        if (queryFormData && Array.isArray(queryFormData) && queryFormData.length > 0 && queryDivRef.current) {
            setTimeout(() => {
                const height = queryDivRef?.current?.offsetHeight || 44;
                setQueryDivHeight(height);
            }, 300)
        }
    }, [queryFormData]);

    // 查询
    const handleQuery = () => {
        setPage(oldPage => {
            if (oldPage === 1) {
                getTableData();
            };
            return 1
        });
    };

    useEffect(() => {
        if (queryFormData && Array.isArray(queryFormData) && queryFormData.length > 0) {
            getTableData();
        }
    }, [page, pageSize]);

    // 提供修改page和pageSize的回调函数
    const handlePaginationChange = (page, pageSize) => {
        setPage(page);
        setPageSize(pageSize);
    };

    const getQueryParams = (dataIndex) => {
        let values = {};
        if (queryFormRef && queryFormRef.current) {
            if (dataIndex) {
                values[dataIndex] = queryFormRef.current.getFieldValue(dataIndex);
            } else {
                values = queryFormRef.current.getFieldsValue();
            }
        }
        return values;
    };

    // 获取列表数据
    const getTableData = async () => {
        try {
            let queryCode = categoryData?.queryCode || '';
            if (!queryCode) {
                handleNotificationError('查询接口');
                return;
            };
            let values = {};
            if (queryFormRef && queryFormRef.current) {
                values = await queryFormRef.current.handleSave('Y');
                if (values.error) {
                    return;
                }
            }
            setLoading(true);
            let data = {
                params: [{
                    ...values
                }]
            };
            // 判断是否需要分页
            if (categoryData?.hidePaginationFlag !== 'Y') {
                data.pagination = [{
                    pageSize: pageSize,
                    currentPage: page,
                    sortColumn: '',
                    sortOrder: ''
                }]
            }
            const res = await React.$asyncPost(queryCode, data);
            setTableData(React.$processingTableRequestData(res));
            setTotal(res.result?.total || 1);
            setLoading(false);
            setRowID('');
            setRowData({});
            if (!!(categoryData?.dataGroupSaveCode)) {
                setDataGroupQueryParams(JSON.parse(JSON.stringify({ ...values })))
            }
        } catch (error) {
            console.log(error);
            setLoading(false);
        };
    };

    // 操作行
    const handleRowClick = (record) => {
        const idField = categoryData?.idField || 'id';
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
        const idField = categoryData?.idField || 'id';
        const nRowID = record && idField in record ? record[idField] : (record?.key || '');
        return nRowID === rowID ? 'common-table-select-bg' : '';
    };

    // 保存
    const handleDrawerSave = async (values) => {
        try {
            let idField = categoryData?.idField || 'id';
            let saveCode = rowData && idField in rowData && rowData[idField] && categoryData && 'editCode' in categoryData && categoryData.editCode ? (
                categoryData?.editCode || '' // 编辑接口
            ) : (
                categoryData?.saveCode || '' // 新增接口
            );
            if (!saveCode) {
                message.error('保存接口维护异常！');
                publicDrawerRef && publicDrawerRef.current && publicDrawerRef.current.modifyOkLoading(false);
                return
            };
            let paramsData = {
                ...rowData,
                UpdateUserDr: userData?.userID || '',
                userID: userData?.userID || '',
                interfaceFlag: categoryData?.interfaceFlag || undefined, // 界面标识
                ...values
            };
            const res = await React.$asyncPost(saveCode, {
                params: [paramsData]
            });
            message.success(res?.errorMessage || '保存成功');
            publicDrawerRef && publicDrawerRef.current && publicDrawerRef.current.modifyVisible(false, 'Y');
            getTableData();
        } catch (error) {
            console.log(error);
            publicDrawerRef && publicDrawerRef.current && publicDrawerRef.current.modifyOkLoading(false);
        }
    };

    // 添加
    const handleAdd = () => {
        let idField = categoryData?.idField || 'id';
        if (rowData && idField in rowData && rowData[idField]) {
            setRowData({});
        };
        handleShowDrawer('add');
    };

    // 编辑
    const handleCompile = (record) => {
        setRowData(record);
        handleShowDrawer('modify');
    };

    // 打开操作弹窗
    const handleShowDrawer = (type) => {
        const { addLinkFlag, linkTabData = [] } = props;
        let nLinkTabData = [...linkTabData];
        if (type === 'add' && addLinkFlag !== 'N') { // 如果是新增的时候不显示关联tab
            nLinkTabData = [];
        }
        publicDrawerRef && publicDrawerRef.current && publicDrawerRef.current.modifyVisible(true, 'N', nLinkTabData, {
            clearDrawerWidthFlag: type === 'add' && linkTabData && Array.isArray(linkTabData) && linkTabData.length > 0 ? 'Y' : 'N', // 清除切换tab选择的宽度
        });
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

    // 高级筛选
    const handleAdvancedFiltering = (newOpen) => {
        if (newOpen && autoAddAdvancedFlag && !(advancedFilteringCriteria && Array.isArray(advancedFilteringCriteria) && advancedFilteringCriteria.length > 0)) {
            setAutoAddAdvancedFlag(false);
            handleAddAdvancedFilter();
        }
        setAdvancedVisible(newOpen);
    };

    // 拉取数据
    const handlePullingData = async () => {
        try {
            if (!(categoryData?.pullCode || '')) {
                message.error('拉取数据接口维护异常！');
                return
            };
            setPullLoading(true);
            let data = {
                params: [{

                }]
            };
            const res = await React.$asyncPost(categoryData.pullCode, data);
            message.success(res?.errorMessage || '数据拉取成功');
            getTableData();
            setPullLoading(false);
        } catch (error) {
            console.log(error);
            setPullLoading(false);
        };
    };

    // 添加到数据分组
    const handleAddGroup = () => {
        dataGroupFormRef && dataGroupFormRef.current && dataGroupFormRef.current.modifyVisible(true);
    };

    // 记录价格信息表单的值
    const handleRecordFormInput = record => {
        setDataGroupRowData(oldData => {
            return {
                ...oldData,
                ...record
            }
        });
    };

    // 保存分组
    const handleDataGroupSave = async (values) => {
        try {
            if (!(categoryData?.dataGroupSaveCode || '')) {
                message.error('保存分组接口维护异常！');
                dataGroupFormRef && dataGroupFormRef.current && dataGroupFormRef.current.modifyOkLoading(false);
                return
            };
            const res = await React.$asyncPost(categoryData?.dataGroupSaveCode || '', {
                params: [{
                    ...values,
                    queryParams: dataGroupQueryParams,
                    advancedFilter: advancedFilteringCriteria
                }]
            });
            message.success(res?.errorMessage || '保存成功');
            dataGroupFormRef && dataGroupFormRef.current && dataGroupFormRef.current.modifyVisible(false, 'Y');
            getTabItems();
        } catch (error) {
            console.log(error);
            dataGroupFormRef && dataGroupFormRef.current && dataGroupFormRef.current.modifyOkLoading(false);
        }
    };

    // 高级筛选change
    const handleAdvancedFilterItemChange = (e, index, dataIndex) => {
        setAdvancedFilteringCriteria(prevState => prevState.map((item, idx) =>
            idx === index ? { ...item, [dataIndex]: e } : item));
    };

    // 添加条件
    const handleAddAdvancedFilter = () => {
        let nAdvancedFilteringCriteria = [...advancedFilteringCriteria];
        nAdvancedFilteringCriteria.push({
            componentID: columns && Array.isArray(columns) && columns.length > 0 ? (columns[0]?.id || undefined) : undefined,
        });
        setAdvancedFilteringCriteria([...nAdvancedFilteringCriteria]);
    };

    // 删除条件 
    const handleDeleteAdvancedFilter = (index) => {
        let nAdvancedFilteringCriteria = [...advancedFilteringCriteria];
        nAdvancedFilteringCriteria.splice(index, 1);
        setAdvancedFilteringCriteria(nAdvancedFilteringCriteria);
    };

    // 高级筛选弹窗内容
    const advancedContent = (
        <div>
            <div style={{ marginTop: '10px' }}>
                {advancedFilteringCriteria && advancedFilteringCriteria.map((item, index) => {
                    return (
                        <div key={index} style={{ marginBottom: '10px' }}>
                            <Select
                                placeholder="请选择"
                                style={{ width: '150px', marginRight: '12px' }}
                                value={item?.componentID || undefined}
                                onChange={e => handleAdvancedFilterItemChange(e, index, 'componentID')}
                            >
                                {React.$SelectOptions(columns)}
                            </Select>
                            <Select
                                placeholder="请选择"
                                style={{ width: '100px', marginRight: '6px' }}
                                value={item?.typeID || undefined}
                                onChange={e => handleAdvancedFilterItemChange(e, index, 'typeID')}
                            >
                                {React.$SelectOptions(selectData?.type || [])}
                            </Select>
                            <Input
                                placeholder="请输入"
                                style={{ width: '200px' }}
                                value={item?.filterVal || undefined}
                                onChange={e => handleAdvancedFilterItemChange(e.target.value, index, 'filterVal')}
                            />
                            <CloseOutlined style={{ marginLeft: '12px' }} className="common-pointer" onClick={() => handleDeleteAdvancedFilter(index)} />
                        </div>
                    );
                })}
            </div>
            <div>
                <span className="common-pointer" onClick={handleAddAdvancedFilter}>
                    <PlusOutlined style={{ marginRight: '6px' }} className="common-record-span" />
                    添加条件
                </span>
            </div>
        </div>
    );

    const operationBtnDom = () => {
        const { addCallback } = props;
        return (
            <>
                {/* 刷新界面 - 重新查询 */}
                {categoryData?.hideRefreshIconFlag !== 'Y' && (
                    <Button icon={<SyncOutlined className="common-record-span" />} onClick={getTableData}></Button>
                )}
                {categoryData?.advancedFilteringFlag === 'Y' && (
                    <Popover
                        title="设置筛选条件"
                        trigger="click"
                        placement="bottomLeft"
                        open={advancedVisible}
                        content={advancedContent}
                        onOpenChange={handleAdvancedFiltering}
                    >
                        <Button
                            icon={<FilterOutlined className="common-record-span" />}
                            style={{ marginLeft: '12px' }}
                        >
                            高级筛选
                        </Button>
                    </Popover>
                )}
                {(!!(categoryData?.saveCode) || addCallback) && (
                    <Button
                        icon={<PlusOutlined className="common-record-span" />}
                        style={{ marginLeft: '12px' }}
                        onClick={addCallback || handleAdd}
                    >

                        {categoryData?.addBtnTitle || '添加'}
                    </Button>
                )}
                {!!(categoryData?.pullCode) && (
                    <Button
                        loading={pullLoading}
                        icon={<CloudDownloadOutlined style={{ color: '#fff' }} />}
                        style={{ marginLeft: '12px' }}
                        type="primary"
                        onClick={handlePullingData}
                    >
                        {categoryData?.pullBtnTitle || '拉取数据'}
                    </Button>
                )}
                {!!(categoryData?.dataGroupSaveCode) && (
                    <Button
                        ghost
                        type="primary"
                        loading={pullLoading}
                        style={{ marginLeft: '12px', float: 'right' }}
                        disabled={!(tableData && Array.isArray(tableData) && tableData.length > 0)}
                        onClick={handleAddGroup}
                    >
                        {categoryData?.dataGroupBtnTitle || '另存为Tab菜单'}
                    </Button>
                )}
            </>
        )
    };

    // 导入
    const handleImport = (file, fileList) => {
        if (importLoading) return;
        excelJS.importExcel(file, 'keyVal')
            .then(async (jsonData) => {
                importSplitArr = Util.cutArray(jsonData, categoryData?.importSplitCount || 200);
                queryFormRef.current && queryFormRef.current.modifyFormItemAttr('importBtn', true);
                setImportLoading(true);
                handleImportProcessQueue();
            })
            .catch((error) => {
                console.error(error); // 处理错误
                setImportLoading(false);
                queryFormRef.current && queryFormRef.current.modifyFormItemAttr('importBtn', false);
            });
        return false;
    };

    let importSplitArr = [];
    let isImportProcessing = false;

    const handleImportProcessQueue = async () => {
        if (isImportProcessing || importSplitArr.length === 0) {
            setImportLoading(false);
            queryFormRef.current && queryFormRef.current.modifyFormItemAttr('importBtn', false);
            return;
        };
        // 设置标志位，表示开始处理数据
        isImportProcessing = true;
        const firstImportArr = importSplitArr.shift(); // 获取第一项
        try {
            await handleBatchImport(firstImportArr);
        } catch (error) {
            console.log(`导入错误数据： ${JSON.stringify(firstImportArr)}:`,);
        }
        // 完成这项工作后，重置标志位，并尝试开始下一项工作。
        isImportProcessing = false;
        handleImportProcessQueue();
    };

    // 批量导入
    const handleBatchImport = async (jsonData) => {
        return new Promise(async (resolve, reject) => {
            try {
                if (jsonData && Array.isArray(jsonData) && jsonData.length === 0) {
                    setImportLoading(false);
                    setLoading(false);
                    setRowID('');
                    setRowData({});
                    queryFormRef.current && queryFormRef.current.modifyFormItemAttr('importBtn', false);
                    message.success('导入完成！');
                    resolve();
                    return;
                };
                let data = {
                    params: [{
                        importArr: jsonData,
                        componentName: componentName || categoryData?.componentName || undefined, // 组件名
                        groupType: categoryData?.groupType || undefined,
                    }]
                }
                let res = await React.$asyncPost(categoryData?.importCode || '', data);
                let rTableData = React.$processingTableRequestData(res, 'uuid');
                let nTotal = res?.result?.total || res?.result?.totalCount || res?.result?.TotalCount || res?.total || res?.totalCount || res?.TotalCount || tableData?.length || 0;
                setTableData([...tableData, ...rTableData]);
                setTotal(total + nTotal);
                resolve();
            } catch (error) {
                console.log(error);
                reject(error);
            }
        });
    };

    const { customOperationObj = {} } = props;
    const operationWidth = (((categoryData?.saveCode && categoryData?.notEditableFlag !== 'Y') || categoryData?.editCode) && categoryData?.deleteCode) ? 130 : 86
    const operationObj = {
        width: operationWidth,
        title: '操作',
        fixed: categoryData?.operationFixed === 'left' ? 'left' : (categoryData && 'operationFixed' in categoryData && categoryData.operationFixed ? 'right' : null),
        align: 'center',
        key: 'operation',
        render: (text, record) => (
            <span>
                {((categoryData?.saveCode && categoryData?.notEditableFlag !== 'Y') || categoryData?.editCode) && (
                    <span className="common-record-span" onClick={(e) => handleCompile(record, e)}>
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
        ),
    };

    // operationButtonBlockFlag - 操作按钮是否单独一行
    // queryFormCol 查询表单占位
    // paginationSize 分页大小 small | large
    // hidePaginationFlag 隐藏分页标志
    // defaultPageSize 默认每页的条数
    // componentName 组件名
    // fixedHeightFlag 表格高度是否固定，不需要固定则传入N
    // multipleFlag 表格多选标志

    const dataGroupFlag = !!(tabItems && Array.isArray(tabItems) && tabItems.length > 0);
    return (
        <Spin tip={importLoading ? '正在导入...' : '资源加载中...'} spinning={spinLoading || importLoading} key={interfaceKey}>
            <div className="single-table-operation">
                <div className="flex">
                    {dataGroupFlag && (
                        <div className="sto-data-group-col">
                            <Tabs
                                tabPosition="left"
                                items={tabItems}
                                activeKey={activeTabKey}
                                onChange={handleTabChange}
                            />
                        </div>
                    )}
                    <div style={{ width: dataGroupFlag ? 'calc(100% - 86px)' : '100%' }}>
                        <div style={{ paddingLeft: dataGroupFlag ? '6px' : '0', position: 'relative' }}>
                            <div ref={queryDivRef}>
                                <Row style={{ padding: '6px 12px 0 6px' }}>
                                    <Col span={categoryData?.operationButtonBlockFlag === 'Y' ? 24 : (categoryData && categoryData.queryFormCol ? categoryData?.queryFormCol : 18)}>
                                        <div style={{ display: queryFormData && queryFormData.length > 0 ? 'block' : 'none' }} className="common-dynamic-component">
                                            <DynamicRenderingForm
                                                className="common-dynamic-component-form common-dynamic-component-form-margin-bottom6"
                                                ref={queryFormRef}
                                                rowData={{}}
                                                selectData={selectData}
                                                formData={queryFormData}
                                                formItemCol={{ col: 6, labelCol: 6, wrapperCol: 17 }}
                                            />
                                        </div>
                                    </Col>
                                    {categoryData?.operationButtonBlockFlag !== 'Y' && (
                                        <Col span={categoryData && categoryData.queryFormCol ? (24 - categoryData && categoryData.queryFormCol) : 6} style={{ textAlign: 'right' }}>
                                            {operationBtnDom()}
                                        </Col>
                                    )}
                                </Row>
                            </div>
                            {queryFormData && queryFormData.length > 0 ? <div className="common-query-split-line"></div> : ''}
                            <div className="sto-body">
                                {categoryData?.operationButtonBlockFlag === 'Y' && (
                                    <div style={{ marginBottom: '6px', paddingLeft: '2px' }}>
                                        {operationBtnDom()}
                                    </div>
                                )}
                                <PublicTablePagination
                                    param={{
                                        loading,
                                        componentName, // 表头配置
                                        data: tableData, // 表格数据
                                        size: categoryData?.paginationSize || 'small',
                                        page: categoryData?.hidePaginationFlag !== 'Y' ? page : false,
                                        total: categoryData?.hidePaginationFlag !== 'Y' ? total : false,
                                        defaultPageSize: categoryData?.defaultPageSize || '20',
                                        columns: columns && Array.isArray(columns) && columns.length > 0 ? ((
                                            (categoryData?.saveCode && categoryData?.notEditableFlag !== 'Y') || categoryData?.editCode || categoryData?.deleteCode
                                        ) ? [...columns, operationObj] : (
                                            // 扩展操作 - 由父组件自定义
                                            customOperationObj && JSON.stringify(customOperationObj) !== '{}' ? [...columns, customOperationObj] : columns
                                        )) : [],
                                        x: totalWidth, // 表格的宽度
                                        y: categoryData?.fixedHeightFlag !== 'N' ? (contentHeight - (categoryData?.operationButtonBlockFlag === 'Y' ? 144 : 105) - (props?.additionalHeight || 0) - queryDivHeight) : '',
                                        height: categoryData?.fixedHeightFlag !== 'N' ? (contentHeight - (categoryData?.operationButtonBlockFlag === 'Y' ? 108 : 65) - (props?.additionalHeight || 0) - queryDivHeight + 'px') : '',
                                    }}
                                    rowSelection={categoryData?.multipleFlag === 'Y' ? {
                                        selectedRowKeys,
                                        selectedRows,
                                        onChange: (selectedRowKeys, selectedRows) => {
                                            setSelectedRowKeys(selectedRowKeys);
                                            setSelectedRows(selectedRows);
                                        },
                                    } : null}
                                    compilePage={categoryData?.hidePaginationFlag !== 'Y' ? handlePaginationChange : null}
                                    getColumns={getColumnsData}
                                    onRow={handleRowClick}
                                    rowClassName={setRowClassName}
                                />
                            </div>
                            {dataGroupFlag && <div className="common-card-left-split-line"></div>}
                        </div>
                    </div>
                </div>

                {/* 新增/编辑 */}
                <PublicDrawerFormHook
                    modalKey={'PublicDrawerFormHook-' + interfaceKey}
                    width={categoryData?.drawerWidth || props?.drawerWidth || ''}
                    componentName={categoryData?.modalComponentName || (categoryData && 'componentName' in categoryData && categoryData.componentName ? (categoryData.componentName + 'Form') : '')}
                    componentInfo={modalComponentInfo} // 组件信息，如果父组件已经拿到弹窗组件相关信息就不用再次获取直接用
                    idField={categoryData?.idField || 'id'}
                    rowData={rowData}
                    linkDataFiled={categoryData?.linkDataFiled || 'componentArr'}
                    linkFormLabel={categoryData?.linkFormLabel || '菜单组件'}
                    selectData={selectData}
                    componentsSelectFlag={categoryData?.componentsSelectFlag || ''} // 菜单关联组件标志
                    ref={publicDrawerRef}
                    handleSave={handleDrawerSave}
                />

                {/* 数据分组 */}
                <PublicModalFormHooks
                    width={520}
                    title="另存为"
                    modalKey={'PublicModalFormHooks-' + interfaceKey}
                    ref={dataGroupFormRef}
                    formData={dataGroupModalForm}
                    rowData={dataGroupRowData}
                    selectData={selectData}
                    formItemCol={{ labelCol: 24, wrapperCol: 24, col: 24 }}
                    recordFormInput={handleRecordFormInput}
                    handleSave={handleDataGroupSave}
                />
            </div>
        </Spin>
    );
};

export default forwardRef(SingleTableOperation);

/**
 * 菜单管理：params=interfaceType:singleTable&componentName:MenuDetailMaintenance&selectCode:01010005&queryCode:01040104&saveCode:01040101&idField:menuDetailID&operationFixed:right&componentsSelectFlag:Y
 * 接口服务配置：params=interfaceType:singleTable&componentName:InterfaceServiceConfig&selectCode:01010018&queryCode:01010017&saveCode:01010016&operationFixed:right
*/