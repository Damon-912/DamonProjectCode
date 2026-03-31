/*
 * Create:      柿子
 * CreateDate:  2026/01/21
 * Describe：   新增ICD编码映射关系
 * */
import React, { useState, useEffect, forwardRef, useImperativeHandle, useRef } from 'react';
import { Modal, Spin, Row, Col, Card, message } from 'antd';
import { ProductOutlined, ProfileOutlined } from '@ant-design/icons';
import request from '@api';
import UseSyncCallback from '@pages/common/UseSyncCallback';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import '../style/index.less';

const AddICDEncodingMapping = (props, ref) => {
    let leftQueryFormRef = useRef(null);
    let rightQueryFormRef = useRef(null);
    const [visible, setVisible] = useState(false);
    const [spinLoading, setSpinLoading] = useState(true);
    const [propParams, setPropParams] = useState({});
    const [leftPage, setLeftPage] = useState(1);
    const [leftPageSize, setLeftPageSize] = useState(20);
    const [leftColumns, setLeftColumns] = useState([]);
    const [leftTotalWidth, setLeftTotalWidth] = useState(0);
    const [leftQueryFormData, setLeftQueryFormData] = useState([]);
    const [leftLoading, setLeftLoading] = useState(false);
    const [leftTableData, setLeftTableData] = useState([]);
    const [leftTotal, setLeftTotal] = useState(0);
    const [leftRowID, setLeftRowID] = useState('');
    const [leftRowData, setLeftRowData] = useState({});

    const [rightPage, setRightPage] = useState(1);
    const [rightPageSize, setRightPageSize] = useState(20);
    const [rightColumns, setRightColumns] = useState([]);
    const [rightTotalWidth, setRightTotalWidth] = useState(0);
    const [rightQueryFormData, setRightQueryFormData] = useState([]);
    const [rightLoading, setRightLoading] = useState(false);
    const [rightTableData, setRightTableData] = useState([]);
    const [rightTotal, setRightTotal] = useState(0);
    const [rightRowID, setRightRowID] = useState('');
    const [rightRowData, setRightRowData] = useState({});

    const [okLoading, setOkLoading] = useState(false);

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible,
        modifyOkLoading: (loading) => setOkLoading(loading),
    }));

    // 修改弹窗状态
    const modifyVisible = (visible, params = {}) => {
        visible && getLeftColumnsData();
        visible && getRightColumnsData();
        setPropParams(params);
        setVisible(visible);
    };

    // 获取列表表头数据
    const getLeftColumnsData = async () => {
        try {
            const { leftComponentName } = props;
            if (!leftComponentName || (leftQueryFormData && Array.isArray(leftQueryFormData) && leftQueryFormData.length > 0)) return;
            if (!spinLoading) {
                setSpinLoading(true);
            }
            const res = await request.getComponentInfo(leftComponentName);
            setLeftColumns(res.result?.C || []);
            setLeftTotalWidth(res.totalWidth);
            let nQueryFormData = res.result?.formData || [];
            for (let i = 0; i < nQueryFormData.length; i++) {
                if (nQueryFormData[i]?.typeCode === 'Input') {
                    nQueryFormData[i].onPressEnter = handleLeftQuery;
                }
                if (nQueryFormData[i]?.dataIndex === 'queryBtn') { // 查询
                    nQueryFormData[i].type = 'primary';
                    nQueryFormData[i].onClick = handleLeftQuery
                }
            }
            setSpinLoading(false);
            setLeftQueryFormData(nQueryFormData);
        } catch (error) {
            console.log(error);
            setSpinLoading(false);
        }
    };

    useEffect(() => {
        if (visible) {
            getLeftTableData();
        }
    }, [leftPage, leftPageSize]);

    const handleLeftQuery = () => {
        setLeftPage(oldPage => {
            if (oldPage === 1) {
                getLeftTableData();
            };
            return 1
        });
    };

    // 请求列表数据
    const getLeftTableData = UseSyncCallback(async () => {
        try {
            const { leftQueryCode, leftStaticParams = {}, leftPaginationFlag, leftIdField = 'key' } = props;
            const { leftDynamicParams = {}, leftCopyTableData } = propParams;
            let values = {};
            if (leftQueryFormRef && leftQueryFormRef.current) {
                values = await leftQueryFormRef.current.handleSave();
                if (values.error) {
                    message.error('请完善必填信息');
                    return;
                }
            }
            if (!leftQueryCode) {
                message.error('请配置查询代码');
                return;
            };
            if (leftQueryCode === 'staticFilter') { // 静态过滤
                let staticNTableData = [];
                for (let key in values) {
                    if (staticNTableData[key] !== undefined && values[key] !== false && values[key] !== null) {
                        staticNTableData = leftCopyTableData.filter(item => item?.staticFilter.indexOf(values[key]) > -1);
                    }
                }
                setLeftTableData(staticNTableData)
                return;
            };
            setLeftLoading(true);
            let data = {
                params: [{
                    ...leftStaticParams,
                    ...leftDynamicParams,
                    ...values,
                }]
            }
            if (leftPaginationFlag !== 'N') {
                data.pagination = [{
                    pageSize: leftPageSize,
                    currentPage: leftPage
                }];
            }
            const res = await React.$asyncPost(leftQueryCode, data);
            const nTableData = React.$processingTableRequestData(res, leftIdField);
            setLeftTableData(nTableData);
            setLeftTotal(res?.result?.total || res?.result?.totalCount || res?.result?.TotalCount || nTableData.length);
            setLeftLoading(false);
            handleLeftClear();
        } catch (error) {
            console.log('error', error);
            setLeftLoading(false);
        }
    });

    // 提供修改page和pageSize的回调函数
    const handleLeftPaginationChange = (page, pageSize) => {
        setLeftPage(page);
        setLeftPageSize(pageSize);
    };

    // 操作行
    const handleLeftRowClick = (record) => {
        return {
            // 单击行选中
            onClick: () => {
                if (leftRowID === '' || (leftRowID && leftRowID !== record.key)) {
                    setLeftRowID(record.key);
                    setLeftRowData({
                        ...record,
                    });
                } else {
                    handleLeftClear();
                }
            }
        }
    };

    // 选中行操作
    const setLeftRowClassName = (record) => {
        return record.key === leftRowID ? 'common-table-select-bg' : '';
    };

    const handleLeftClear = () => {
        setLeftRowID('');
        setLeftRowData({});
    };

    // 获取列表表头数据
    const getRightColumnsData = async () => {
        try {
            const { rightComponentName } = props;
            if (!rightComponentName || (rightQueryFormData && Array.isArray(rightQueryFormData) && rightQueryFormData.length > 0)) return;
            const res = await request.getComponentInfo(rightComponentName);
            setRightColumns(res.result?.C || []);
            setRightTotalWidth(res.totalWidth);
            let nQueryFormData = res.result?.formData || [];
            for (let i = 0; i < nQueryFormData.length; i++) {
                if (nQueryFormData[i]?.typeCode === 'Input') {
                    nQueryFormData[i].onPressEnter = handleRightQuery;
                }
                if (nQueryFormData[i]?.dataIndex === 'queryBtn') { // 查询
                    nQueryFormData[i].type = 'primary';
                    nQueryFormData[i].onClick = handleRightQuery
                }
            }
            setRightQueryFormData(nQueryFormData);
        } catch (error) {
            console.log(error);
        }
    };

    useEffect(() => {
        if (visible) {
            getRightTableData();
        }
    }, [rightPage, rightPageSize]);

    const handleRightQuery = () => {
        setRightPage(oldPage => {
            if (oldPage === 1) {
                getRightTableData();
            };
            return 1
        });
    };

    // 请求列表数据
    const getRightTableData = UseSyncCallback(async () => {
        try {
            const { rightQueryCode, rightStaticParams = {}, rightPaginationFlag, rightIdField = 'key' } = props;
            const { rightDynamicParams = {}, rightCopyTableData } = propParams;
            let values = {};
            if (rightQueryFormRef && rightQueryFormRef.current) {
                values = await rightQueryFormRef.current.handleSave();
                if (values.error) {
                    message.error('请完善必填信息');
                    return;
                }
            }
            if (!rightQueryCode) {
                message.error('请配置查询代码');
                return;
            };
            if (rightQueryCode === 'staticFilter') { // 静态过滤
                let staticNTableData = [];
                for (let key in values) {
                    if (staticNTableData[key] !== undefined && values[key] !== false && values[key] !== null) {
                        staticNTableData = rightCopyTableData.filter(item => item?.staticFilter.indexOf(values[key]) > -1);
                    }
                }
                setRightTableData(staticNTableData)
                return;
            };
            setRightLoading(true);
            let data = {
                params: [{
                    ...rightStaticParams,
                    ...rightDynamicParams,
                    ...values,
                }]
            }
            if (rightPaginationFlag !== 'N') {
                data.pagination = [{
                    pageSize: rightPageSize,
                    currentPage: rightPage
                }];
            }
            const res = await React.$asyncPost(rightQueryCode, data);
            const nTableData = React.$processingTableRequestData(res, rightIdField);
            setRightTableData(nTableData);
            setRightTotal(res?.result?.total || res?.result?.totalCount || res?.result?.TotalCount || nTableData.length);
            setRightLoading(false);
            handleRightClear();
        } catch (error) {
            console.log('error', error);
            setRightLoading(false);
        }
    });

    // 提供修改page和pageSize的回调函数
    const handleRightPaginationChange = (page, pageSize) => {
        setRightPage(page);
        setRightPageSize(pageSize);
    };

    // 操作行
    const handleRightRowClick = (record) => {
        return {
            // 单击行选中
            onClick: () => {
                if (rightRowID === '' || (rightRowID && rightRowID !== record.key)) {
                    setRightRowID(record.key);
                    setRightRowData({
                        ...record,
                    });
                } else {
                    handleRightClear();
                }
            }
        }
    };

    // 选中行操作
    const setRightRowClassName = (record) => {
        return record.key === rightRowID ? 'common-table-select-bg' : '';
    };

    const handleRightClear = () => {
        setRightRowID('');
        setRightRowData({});
    };

    // 关闭弹窗
    const handleCancel = (isClearFlag) => {
        const { cancelResetFlag } = props;
        if (okLoading) {
            setOkLoading(false);
        }
        setVisible(false);
        if (cancelResetFlag === 'Y') {
            // 关闭弹窗需要清除相关操作数据[操作数据关联主界面版本，如果切换了版本可能存在问题]
            handleLeftClear();
            setLeftTableData([]);
            setLeftTotal(0);
            setLeftPage(1);
            handleRightClear();
            setRightTableData([]);
            setRightTotal(0);
            setRightPage(1);
        } else if (isClearFlag === 'Y') {
            handleLeftClear();
            handleRightClear();
        }
    };

    // 确认
    const handleOk = async () => {
        const { handleOk, handleQuery, saveCode } = props;
        try {
            setOkLoading(true);
            if (leftRowID === '' || rightRowID === '') {
                message.error('请选择需要对照的数据');
                setOkLoading(false);
                return;
            }
            if (handleOk && typeof (handleOk) === 'function') {
                handleOk({
                    leftInfo: leftRowData,
                    rightInfo: rightRowData,
                });
            } else {
                if (!saveCode) {
                    message.error('请配置保存接口代码');
                    setOkLoading(false);
                    return;
                }
                const { saveDynamicParams = {} } = propParams;
                let data = {
                    params: [{
                        ...saveDynamicParams,
                        leftInfo: leftRowData,
                        rightInfo: rightRowData,
                    }]
                }
                const res = await React.$asyncPost(saveCode, data);
                message.success(res?.errorMessage || '保存成功');
                setOkLoading(false);
                handleCancel('Y');
                handleQuery && typeof (handleQuery) === 'function' && handleQuery();
            }
        } catch (error) {
            console.log(error);
            setOkLoading(false);
        }
    };

    const { title, width, tableHeight = 460, selectData, leftColSpan, leftPaginationFlag, leftComponentName, leftCardTitle, rightPaginationFlag, rightComponentName,
        rightCardTitle
    } = props;
    return (
        <div>
            <Modal
                open={visible}
                width={width || '86vw'}
                title={title || '新增映射关系'}
                okButtonProps={{
                    loading: okLoading
                }}
                onOk={handleOk}
                onCancel={handleCancel}
            >
                <Spin tip="加载中..." spinning={spinLoading}>
                    <Row>
                        <Col span={leftColSpan || 12} style={{ paddingRight: '16px' }}>
                            <Card
                                size="small"
                                title={(
                                    <div className="common-card-title-icon">
                                        <ProductOutlined />
                                        {leftCardTitle || '映射关系列表'}
                                    </div>
                                )}
                            >
                                <div
                                    style={{ display: leftQueryFormData && leftQueryFormData.length > 0 ? 'block' : 'none', marginBottom: '6px' }}
                                    className="common-dynamic-component"
                                >
                                    <DynamicRenderingForm
                                        className="common-dynamic-component-form common-dynamic-component-form-margin-bottom0"
                                        ref={leftQueryFormRef}
                                        rowData={{}}
                                        selectData={selectData}
                                        formData={leftQueryFormData}
                                    />
                                </div>
                                <PublicTablePagination
                                    param={{
                                        size: 'small',
                                        page: leftPaginationFlag !== 'N' ? leftPage : false,
                                        total: leftPaginationFlag !== 'N' ? leftTotal : false,
                                        loading: leftLoading,
                                        // 表头配置
                                        defaultPageSize: 20,
                                        componentName: leftComponentName,
                                        columns: leftColumns,
                                        x: leftTotalWidth, // 表格的宽度
                                        y: tableHeight + 16,
                                        height: tableHeight + 56 + 'px',
                                        data: leftTableData, // 表格数据
                                    }}
                                    compilePage={handleLeftPaginationChange}
                                    getColumns={getLeftColumnsData}
                                    onRow={handleLeftRowClick}
                                    rowClassName={setLeftRowClassName}
                                />
                            </Card>
                        </Col>
                        <Col span={24 - (leftColSpan || 12)}>
                            <Card
                                size="small"
                                title={(
                                    <div className="common-card-title-icon">
                                        <ProfileOutlined />
                                        {rightCardTitle || '映射关系详情'}
                                    </div>
                                )}
                            >
                                <div style={{ width: '100%', paddingRight: '6px' }}>
                                    <div
                                        style={{ display: rightQueryFormData && rightQueryFormData.length > 0 ? 'block' : 'none', marginBottom: '6px' }}
                                        className="common-dynamic-component"
                                    >
                                        <DynamicRenderingForm
                                            className="common-dynamic-component-form common-dynamic-component-form-margin-bottom0"
                                            ref={rightQueryFormRef}
                                            rowData={{}}
                                            selectData={selectData}
                                            formData={rightQueryFormData}
                                        />
                                    </div>
                                    <PublicTablePagination
                                        param={{
                                            size: 'small',
                                            page: rightPaginationFlag !== 'N' ? rightPage : false,
                                            total: rightPaginationFlag !== 'N' ? rightTotal : false,
                                            loading: rightLoading,
                                            // 表头配置
                                            defaultPageSize: 20,
                                            componentName: rightComponentName,
                                            columns: rightColumns,
                                            x: rightTotalWidth, // 表格的宽度
                                            y: tableHeight + 16,
                                            height: tableHeight + 56 + 'px',
                                            data: rightTableData, // 表格数据
                                        }}
                                        compilePage={handleRightPaginationChange}
                                        getColumns={getRightColumnsData}
                                        onRow={handleRightRowClick}
                                        rowClassName={setRightRowClassName}
                                    />
                                </div>
                            </Card>
                        </Col>
                    </Row>
                </Spin>
            </Modal>
        </div>
    )
};

export default forwardRef(AddICDEncodingMapping);