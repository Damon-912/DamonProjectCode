/*
 * Create:      柿子
 * CreateDate:  2024/05/13
 * Describe：   基础表数据维护
 * */
import React, { useRef, useState, useEffect } from 'react';
import { Card, Row, Col, Input, Button, message, Empty, Divider } from 'antd';
import { PlusOutlined, EditOutlined, ProductOutlined, FormOutlined, MergeOutlined } from '@ant-design/icons';
import request from '@api';
import store from '@store';
import UseSyncCallback from '@pages/common/UseSyncCallback';
import PublicTablePagination from '@pages/common/PublicTablePagination';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import PublicModalFormHooks from '@pages/common/PublicModalFormHooks';
import SubTableDataMaintenance from './component/SubTableDataMaintenance';
import './style/index.less';

const BasicTableDataMaintenance = () => {
    let modalFormRef = useRef(null);
    let subTableRef = useRef(null);
    let detailModalFormRef = useRef(null);
    let detailQueryFormRef = useRef(null);
    const userData = React.$getUserData();
    const { contentHeight } = store.getState();
    const [selectData, setSelectData] = useState({});
    const [code, setCode] = useState(undefined);
    const [descripts, setDescripts] = useState(undefined);
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(20);
    const [columns, setColumns] = useState([]);
    const [totalWidth, setTotalWidth] = useState(0);
    const [formData, setFormData] = useState([]);
    const [loading, setLoading] = useState(false);
    const [tableData, setTableData] = useState([]);
    const [total, setTotal] = useState(0);
    const [rowID, setRowID] = useState('');
    const [rowData, setRowData] = useState({});

    // 明细列表
    const dataAvailList = [{
        id: '',
        descripts: '全部',
    }, {
        id: '1',
        descripts: '可用',
    }, {
        id: '0',
        descripts: '不可用',
    }]
    const [detailPage, setDetailPage] = useState(1);
    const [detailPageSize, setDetailPageSize] = useState(20);
    const [detailSelectData, setDetailSelectData] = useState({});
    const [detailColumns, setDetailColumns] = useState([]);
    const [detailTotalWidth, setDetailTotalWidth] = useState(0);
    const [detailQueryFormData, setDetailQueryFormData] = useState([]);
    const [detailFormData, setDetailFormData] = useState([]);
    const [detailLoading, setDetailLoading] = useState(false);
    const [detailTableData, setDetailTableData] = useState([]);
    const [detailTotal, setDetailTotal] = useState(0);
    const [detailRowID, setDetailRowID] = useState('');
    const [detailRowData, setDetailRowData] = useState({});
    const [linkTableData, setLinkTableData] = useState([]);

    useEffect(() => {
        console.log(location);
        getColumnsData();
        getSelectData();
    }, []);

    const getSelectData = async () => {
        try {
            const res = await React.$asyncPost('4025');
            setSelectData(res);
        } catch (error) {
            console.log(error);
        };
    };

    // 获取列表表头数据
    const getColumnsData = async () => {
        try {
            const res = await request.getComponentInfo('BasicTableDataMaintenance');
            setColumns(res.result?.C || []);
            setTotalWidth(res?.totalWidth || 0);
            let resFormData = res?.result?.formData || []
            let nFormData = resFormData && Array.isArray(resFormData) && resFormData.map(item => {
                return {
                    ...item,
                    valueFieldName: item?.dataIndex === 'Code' ? 'ID' : '', // dataIndex:Code - 表名
                    labelFieldName: item?.dataIndex === 'Code' ? 'Desc' : '',
                }
            });
            setFormData(nFormData);
        } catch (error) {
            console.log(error);
        };
    };

    useEffect(() => {
        getTableData();
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
            setLoading(true);
            let data = {
                params: [{
                    Descripts: descripts,
                    Code: code,
                    Group: userData?.groupID || '',
                    Hospital: userData?.hospID || '',
                    User: userData?.userID || '',
                }],
                pagination: [{
                    pageSize: pageSize,
                    currentPage: page,
                    sortColumn: '',
                    sortOrder: ''
                }]
            };
            const res = await React.$asyncPost('4010', data);
            setTableData(React.$processingTableRequestData(res));
            setTotal(res.result?.TotalCount || 0);
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
    const handleAdd = () => {
        if (rowData && rowData.ID) {
            setRowData({});
        }
        modalFormRef && modalFormRef.current && modalFormRef.current.modifyVisible(true);
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

    // 保存
    const handleSave = async (values) => {
        try {
            const res = await React.$asyncPost('4011', {
                params: [{
                    ID: rowData?.ID || undefined,
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

    const getOperationObj = (type) => {
        // 列表操作
        const operationObj = {
            width: linkTableData && linkTableData.length > 0 && type === 'detail' ? 180 : 80,
            title: '操作',
            align: 'center',
            fixed: 'right',
            key: 'operation',
            render: (text, record) => (
                <span>
                    <span className="common-record-span" onClick={(e) => handleCompile(record, type, e)}>
                        <EditOutlined />
                        编辑
                    </span>
                    {linkTableData && linkTableData.length > 0 && type === 'detail' ? (
                        <>
                            <Divider type="vertical" />
                            <span className="common-record-span" onClick={(e) => handleDataMaintenance(record, e)}>
                                <MergeOutlined />
                                数据维护
                            </span>
                        </>
                    ) : ''}
                </span>
            ),
        };
        return operationObj;
    };

    useEffect(() => {
        if (rowID) {
            if (!(rowData?.ParentName || '')) {
                getDetailData();
            } else {
                message.warning('这个表是子表，不可以直接维护数据哦！');
            };
        } else {
            handleClearDetailData();
        }
    }, [rowID]);

    // 判断当前表是否可以维护数据
    const getDetailData = () => {
        getDetailColumns();
        getDetailQueryFormData();
        getDetailFormData();
        getDetailSelectData();
        getLinkTableData();
    };

    // 清除明细操作数据
    const handleClearDetailData = () => {
        setDetailColumns([]);
        setDetailTotalWidth(0);
        setDetailQueryFormData([]);
        setDetailTableData([]);
        setDetailTotal(0);
        setDetailRowID('');
        setDetailRowData({});
        setLinkTableData([]);
    };

    // 获取明细表单下拉数据
    const getDetailSelectData = async () => {
        try {
            const { Code = '' } = rowData;
            if (!Code) return;
            const res = await React.$asyncPost('4007', {
                params: [{
                    ClassName: Code,
                    groupId: userData?.groupID || '',
                    hospitalId: userData?.hospID || '',
                }]
            });
            let nDetailSelectData = res?.result || {};
            setDetailSelectData(nDetailSelectData);
        } catch (error) {
            console.log(error);
        };
    };

    // 获取明细表头数据
    const getDetailColumns = async () => {
        try {
            const { Code = '' } = rowData;
            if (!Code) return;
            const res = await React.$asyncPost('4002', {
                params: [{
                    ClassName: Code
                }]
            });
            let nDetailColumns = res?.result?.Data || [];
            let nDetailTotalWidth = 0; // res?.result?.totalWidth || 0
            for (let i = 0; i < nDetailColumns.length; i++) {
                nDetailColumns[i].width = '150px';
                nDetailTotalWidth += 150
            }
            setDetailColumns(nDetailColumns);
            setDetailTotalWidth(nDetailTotalWidth);
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
            const { Code = '' } = rowData;
            if (!Code) return;
            setDetailLoading(true);
            let values = {};
            if (detailQueryFormRef && detailQueryFormRef.current) {
                values = await detailQueryFormRef.current.handleSave();
            };
            let data = {
                params: [{
                    ClassName: Code,
                    FindFieldVal: values,
                    groupId: userData?.groupID || '',
                    hospitalId: userData?.hospID || '',
                }],
                pagination: [{
                    pageSize: detailPageSize,
                    currentPage: detailPage,
                    sortColumn: '',
                    sortOrder: ''
                }]
            };
            const res = await React.$asyncPost('4003', data);
            setDetailTableData(React.$processingTableRequestData(res));
            setDetailTotal(res.result?.TotalCount || 0);
            setDetailLoading(false);
            setDetailRowID('');
            setDetailRowData({});
        } catch (error) {
            console.log(error);
            setDetailLoading(false);
        };
    };

    const getDetailQueryFormData = async () => {
        try {
            const { Code = '' } = rowData;
            if (!Code) return;
            const res = await React.$asyncPost('4001', {
                params: [{
                    ClassName: Code
                }]
            });
            let nDetailQueryFormData = (res?.result?.Data || []).map(item => {
                return {
                    dataIndex: item?.Code || '',
                    title: item.Code === 'DataAvail' ? '状态' : (item?.Desc || ''),
                    typeCode: item.Code === 'DataAvail' ? 'Select' : (item?.Type || ''), // item.Code === 'DataAvail'为状态
                    detailItem: item.Code === 'DataAvail' ? dataAvailList : [],
                    defaultValue: item.Code === 'DataAvail' ? '' : undefined
                }
            });
            nDetailQueryFormData.push({
                dataIndex: 'queryBtn',
                title: '查询',
                typeCode: 'Button',
                col: 2,
                type: 'primary',
                onClick: handleDetailQuery
            })
            setDetailQueryFormData(nDetailQueryFormData);
        } catch (error) {
            console.log(error);
        };
    };

    const getDetailFormData = async () => {
        try {
            const { Code = '' } = rowData;
            if (!Code) return;
            const res = await React.$asyncPost('4004', {
                params: [{
                    ClassName: Code,
                    groupId: userData?.groupID || '',
                    hospitalId: userData?.hospID || '',
                }]
            });
            let resData = res?.result?.Data || [];
            let nDetailFormData = resData && Array.isArray(resData) && resData.map(item => {
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
            setDetailFormData(nDetailFormData);
            setTimeout(() => {
                getDetailTableData();
            }, 300)
        } catch (error) {
            console.log(error);
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
    const handleDetailAdd = () => {
        if (detailRowData && detailRowData.ID) {
            setDetailRowData({});
        }
        detailModalFormRef && detailModalFormRef.current && detailModalFormRef.current.modifyVisible(true);
    };

    // 记录价格信息表单的值
    const handleRecordDetailFormInput = record => {
        console.log('record', record)
        setDetailRowData(oldData => {
            return {
                ...oldData,
                ...record
            }
        });
    };

    const handleDetailSave = async (values) => {
        try {
            const { Code = '' } = rowData;
            if (!Code) {
                // message.warning('表名(ClassName)不能为空！');
                detailModalFormRef && detailModalFormRef.current && detailModalFormRef.current.modifyOkLoading(false);
                return;
            };
            const res = await React.$asyncPost('4005', {
                params: [{
                    ClassName: Code,
                    userID: userData?.userID || '',
                    Item: { ...values, ID: detailRowData?.ID || undefined },
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

    // 获取关联表数据
    const getLinkTableData = async () => {
        try {
            const { Code = '' } = rowData;
            if (!Code) return;
            const res = await React.$asyncPost('4014', {
                params: [{
                    ClassName: Code,
                }]
            });
            let nLinkTableData = (res?.result || []).map((item, index) => {
                return {
                    ...item,
                    key: item?.ID || String(index + 1),
                    id: item?.ID || '',
                    label: item?.Desc || '',
                };
            });
            setLinkTableData(nLinkTableData);
        } catch (error) {
            console.log(error);
        };
    };

    // 子表数据维护
    const handleDataMaintenance = (record, e) => {
        React.$stopPropagation(e);
        subTableRef && subTableRef.current && subTableRef.current?.modifyVisible(true, linkTableData, record);
    };

    return (
        <div className="basic-table-data-maintenance">
            <Row>
                <Col span={10}>
                    <div style={{ paddingRight: '6px', position: 'relative' }}>
                        <Card
                            size="small"
                            bordered={false}
                            title={(
                                <div className="common-card-title-icon">
                                    <ProductOutlined />
                                    基础表
                                </div>
                            )}
                        >
                            <div style={{ marginBottom: '12px', padding: '0 4px' }}>
                                表名：<Input
                                    value={code}
                                    className="common-query-input"
                                    title="输入内容后可回车检索"
                                    placeholder="请输入( Enter )"
                                    onChange={e => setCode(e.target.value)}
                                    onPressEnter={handleQuery}
                                />
                                描述：<Input
                                    value={descripts}
                                    className="common-query-input"
                                    title="输入内容后可回车检索"
                                    placeholder="请输入( Enter )"
                                    onChange={e => setDescripts(e.target.value)}
                                    onPressEnter={handleQuery}
                                />
                                <Button type="primary" loading={loading} onClick={handleQuery}>查询</Button>
                                <Button
                                    style={{ float: 'right' }}
                                    icon={<PlusOutlined className="common-record-span" />}
                                    onClick={handleAdd}
                                >
                                    添加
                                </Button>
                            </div>
                            <PublicTablePagination
                                param={{
                                    page, // 当前页数
                                    total, // 数据总条数
                                    loading,
                                    // 表头配置
                                    columns: [...columns, getOperationObj('main')],
                                    defaultPageSize: 20,
                                    x: totalWidth, // 表格的宽度
                                    y: contentHeight - 183,
                                    height: contentHeight - 143 + 'px',
                                    data: tableData, // 表格数据
                                    componentName: 'BasicTableDataMaintenance',
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
                <Col span={14} style={{ padding: '0 12px' }}>
                    <Card
                        size="small"
                        bordered={false}
                        title={(
                            <div className="common-card-title-icon">
                                <FormOutlined />
                                数据维护
                            </div>
                        )}
                        className="btdm-right-card"
                    >
                        {rowID && !(rowData?.ParentName || '') ? (
                            <div>
                                <Row>
                                    <Col style={{ marginBottom: '12px' }} span={20} className="common-dynamic-component">
                                        <DynamicRenderingForm
                                            className="common-dynamic-component-form common-dynamic-component-form-margin-bottom0"
                                            ref={detailQueryFormRef}
                                            rowData={{}}
                                            formData={detailQueryFormData}
                                            selectData={{}}
                                            formItemCol={{ col: 6, labelCol: 6, wrapperCol: 17 }}
                                        />
                                    </Col>
                                    <Col span={4} style={{ textAlign: 'right' }}>
                                        <Button
                                            icon={<PlusOutlined className="common-record-span" />}
                                            onClick={handleDetailAdd}
                                        >
                                            添加
                                        </Button>
                                    </Col>
                                </Row>
                                <PublicTablePagination
                                    param={{
                                        page: detailPage, // 当前页数
                                        total: detailTotal, // 数据总条数
                                        loading: detailLoading,
                                        // 表头配置
                                        columns: [...detailColumns, getOperationObj('detail')],
                                        defaultPageSize: 20,
                                        x: detailTotalWidth, // 表格的宽度
                                        y: contentHeight - 183,
                                        height: contentHeight - 143 + 'px',
                                        data: detailTableData, // 表格数据
                                    }}
                                    compilePage={handleDetailPaginationChange}
                                    getColumns={getColumnsData}
                                    onRow={handleDetailRowClick}
                                    rowClassName={setDetailRowClassName}
                                />
                            </div>
                        ) : <Empty style={{ marginTop: '68px' }} description="选中左侧表进行维护数据" image={Empty.PRESENTED_IMAGE_SIMPLE} />}
                    </Card>
                </Col>
            </Row>

            {/* 添加主表 */}
            <PublicModalFormHooks
                width={600}
                ref={modalFormRef}
                formData={formData}
                rowData={rowData}
                selectData={selectData}
                formItemCol={{ labelCol: 6, wrapperCol: 17, col: 12 }}
                recordFormInput={handleRecordFormInput}
                handleSave={handleSave}
            />

            {/* 添加明细 */}
            <PublicModalFormHooks
                width={600}
                ref={detailModalFormRef}
                formData={detailFormData}
                rowData={detailRowData}
                selectData={detailSelectData}
                formItemCol={{ labelCol: 24, wrapperCol: 24, col: 24 }}
                recordFormInput={handleRecordDetailFormInput}
                handleSave={handleDetailSave}
            />

            {/* 子表数据维护 */}
            <SubTableDataMaintenance ref={subTableRef} />
        </div>
    )
};

export default BasicTableDataMaintenance;