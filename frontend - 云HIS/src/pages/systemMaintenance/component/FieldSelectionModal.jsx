/*
 * Create:      柿子
 * CreateDate:  2024/05/15
 * Describe：   弹窗查询列表【table单击行勾选示例】
 * */
import React, { useState, useEffect, useRef, forwardRef, useImperativeHandle } from 'react';
import { Modal, Card, Row, Col, Button, message } from 'antd';
import { ProductOutlined, FormOutlined, PlusOutlined } from '@ant-design/icons';
import { Util } from '@tools';
import { addNewFieldFormData } from '../js/staticData.js';
import request from '@api';
import SelectFieldType from './SelectFieldType';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import PublicModalFormHooks from '@pages/common/PublicModalFormHooks';

const PublicModalQueryTable = (props, ref) => {
    let formRef = useRef(null);
    let modalFormRef = useRef(null);
    let fieldTypeRef = useRef(null);
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
    const [modalFormData, setModalFormData] = useState([]);
    const [recordModalRowData, setRecordModalRowData] = useState({});

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
                    setRowData({
                        ...record,
                        col: 24,
                        labelCol: 24,
                        wrapperCol: 24,
                        display: 'Y'
                    });
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
        formRef && formRef.current && formRef.current.handleSave()
            .then(result => {
                if (!(result?.error)) {
                    props && 'onOk' in props && props.onOk({ ...rowData, ...result });
                }
            })
    };

    // 新建字段
    const handleAdd = () => {
        fieldTypeRef && fieldTypeRef.current && fieldTypeRef.current.setVisible(true);
    };

    // 确认选择字段类型
    const handleConfirmFieldType = (values) => {
        let currentFieldTypeID = Util.returnDataCccordingToAttributes(selectData?.configFieldType || [], values?.typeCode || 'Input', 'code')?.id || '';
        console.log('currentFieldTypeID', currentFieldTypeID, values?.typeCode, selectData?.configFieldType || [])
        if (!(modalFormData && Array.isArray(modalFormData) && modalFormData.length > 0)) {
            getModalFormData();
        };
        setRecordModalRowData(oldData => {
            return {
                ...oldData,
                fieldTypeID: currentFieldTypeID
            }
        });
        modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(true);
    };

    const getModalFormData = () => {
        setModalFormData(addNewFieldFormData);
    };

    // 记录价格信息表单的值
    const handleRecordModalFormInput = record => {
        setRecordModalRowData(oldData => {
            return {
                ...oldData,
                ...record
            }
        });
    };

    // 创建字段
    const handleModalSave = (values) => {
        handleSave({
            ...recordModalRowData,
            ...values,
        }, 'Y');
    };

    // 保存
    const handleSave = async (values, closeModalFlag) => {
        try {
            let data = {
                params: [{
                    ...values,
                }]
            };
            const res = await React.$asyncPost('01010043', data);
            message.success(res?.errorMessage || '保存成功');
            getTableData(closeModalFlag === 'Y' ? 'Y' : 'N');
            if (closeModalFlag === 'Y') {
                modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(false, 'Y');
            } else {
                modalFormRef && modalFormRef.current && modalFormRef.current.modifyOkLoading(false);
            }
        } catch (error) {
            console.log(error);
            closeModalFlag !== 'Y' && modalFormRef && modalFormRef.current && modalFormRef.current.modifyOkLoading(false);
        };
    };

    const { title, componentName, tableHeight = 460, paginationFlag } = props;

    return (
        <div>
            <Modal
                open={visible}
                footer={null}
                width="1400px"
                title={title || '字段选择'}
                onCancel={handleCancel}
            >
                <Row>
                    <Col span={17} style={{ paddingRight: '16px' }}>
                        <Card
                            size="small"
                            title={(
                                <div className="common-card-title-icon">
                                    <ProductOutlined />
                                    字段列表
                                </div>
                            )}
                            extra={(
                                <span style={{ cursor: 'pointer' }} onClick={handleAdd}>
                                    <PlusOutlined style={{ marginRight: '4px' }} className="common-record-span" />
                                    添加新字段
                                </span>
                            )}
                        >
                            <div style={{ display: queryFormData && queryFormData.length > 0 ? 'block' : 'none', marginBottom: '6px' }} className="common-dynamic-component">
                                <DynamicRenderingForm
                                    className="common-dynamic-component-form common-dynamic-component-form-margin-bottom0"
                                    ref={queryFormRef}
                                    rowData={{}}
                                    selectData={selectData}
                                    formData={queryFormData}
                                    formItemCol={{ col: 6, labelCol: 6, wrapperCol: 17 }}
                                />
                            </div>
                            <PublicTablePagination
                                param={{
                                    size: 'small',
                                    page: paginationFlag === 'Y' ? page : false,
                                    total: paginationFlag === 'Y' ? total : false,
                                    loading,
                                    // 表头配置
                                    defaultPageSize: 20,
                                    componentName,
                                    columns,
                                    x: totalWidth, // 表格的宽度
                                    y: tableHeight + 16,
                                    height: tableHeight + 56 + 'px',
                                    data: tableData, // 表格数据
                                }}
                                compilePage={handlePaginationChange}
                                getColumns={getColumnsData}
                                onRow={handleRowClick}
                                rowClassName={setRowClassName}
                            />
                        </Card>
                    </Col>
                    <Col span={7}>
                        <Card
                            size="small"
                            className="fm-field-detail-card"
                            title={(
                                <div className="common-card-title-icon">
                                    <FormOutlined />
                                    字段明细
                                </div>
                            )}
                        >
                            <div style={{ paddingRight: '6px', height: tableHeight + 87 + 'px', overflow: 'auto' }}>
                                <DynamicRenderingForm
                                    selectData={selectData}
                                    rowData={rowData}
                                    formData={props?.formData || []}
                                    formItemCol={{ labelCol: 24, wrapperCol: 24, col: 24 }}
                                    ref={formRef}
                                />
                            </div>
                            <div style={{ textAlign: 'center', paddingTop: '12px', borderTop: '1px solid #e8e8e8' }}>
                                <Button type="primary" disabled={!rowID} onClick={handleOk}>添加</Button>
                                <Button style={{ marginLeft: '24px' }} disabled={!rowID} onClick={handleCancel}>取消</Button>
                            </div>
                        </Card>
                    </Col>
                </Row>
            </Modal>

            {/* 选择添加的字段类型 */}
            <SelectFieldType ref={fieldTypeRef} handleOk={handleConfirmFieldType} />

            {/* 新建字段 */}
            <PublicModalFormHooks
                width={600}
                title="添加字段"
                okText="创建"
                selectData={selectData}
                formData={modalFormData}
                rowData={recordModalRowData}
                formItemCol={{ labelCol: 24, wrapperCol: 24, col: 24 }}
                ref={modalFormRef}
                recordFormInput={handleRecordModalFormInput}
                handleSave={handleModalSave}
            />
        </div>
    )
};

export default forwardRef(PublicModalQueryTable);