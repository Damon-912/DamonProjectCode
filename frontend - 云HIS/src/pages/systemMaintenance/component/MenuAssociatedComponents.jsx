/*
 * Create:      柿子
 * CreateDate:  2024/05/18
 * Describe：   关联数据选择【栗：菜单管理 - 菜单关联组件】
 * */
import React, { useState, useEffect, useRef, forwardRef, useImperativeHandle } from 'react';
import { Modal, Card, Row, Col, Input, Button, Popconfirm, message, notification } from 'antd';
import { ProductOutlined, FormOutlined, PlusOutlined, DeleteOutlined } from '@ant-design/icons';
import request from '@api';
import DynamicRenderingForm from '@pages/common/DynamicRenderingForm';
import PublicTablePagination from '@pages/common/PublicTablePagination';

const MenuAssociatedComponents = (props, ref) => {
    let queryFormRef = useRef(null);
    const [visible, setVisible] = useState(false);
    const [page, setPage] = useState(1);
    const [pageSize, setPageSize] = useState(20);
    const [columns, setColumns] = useState([]);
    const [totalWidth, setTotalWidth] = useState(0);
    const [queryFormData, setQueryFormData] = useState([]);
    const [loading, setLoading] = useState(false);
    const [tableData, setTableData] = useState([]);
    const [total, setTotal] = useState(0);
    const [rowID, setRowID] = useState('');
    const [linkData, setLinkData] = useState([]);

    // 将子组件的方法 暴露给父组件
    useImperativeHandle(ref, () => ({
        modifyVisible
    }));

    // 修改弹窗状态
    const modifyVisible = (visible, pLinkData) => {
        setVisible(visible);
        if (visible && !(columns && columns.length > 0)) {
            getColumnsData();
        };
        if (visible && pLinkData && Array.isArray(pLinkData)) {
            setLinkData(pLinkData);
        };
        if (visible && !(tableData && tableData.length > 0)) {
            setTimeout(() => {
                getTableData();
            }, 300)
        };
    };

    // 获取列表表头数据
    const getColumnsData = async () => {
        try {
            const { componentName } = props;
            if (!componentName) return;
            const res = await request.getComponentInfo(componentName);
            setColumns(res.result?.C || []);
            setTotalWidth(res?.totalWidth || 0);
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
        };
    };

    useEffect(() => {
        getTableData();
    }, [page, pageSize]);

    // 查询
    const handleQuery = () => {
        setPage(oldPage => {
            if (oldPage === 1) {
                getTableData();
            };
            return 1
        });
    };

    // 获取列表数据
    const getTableData = async () => {
        try {
            const { queryCode } = props;
            if (!queryCode) {
                notification.error({
                    message: `系统提醒 :`,
                    description: '您还未维护关联弹窗接口的查询接口，快抓紧去维护吧，不然界面没法渲染哦！',
                });
                return;
            };
            let values = {};
            if (queryFormRef && queryFormRef.current) {
                values = await queryFormRef.current.handleSave();
                if (values.error) {
                    message.error('请完善必填信息');
                    return;
                }
            }
            setLoading(true);
            let data = {
                params: [{
                    ...values
                }],
            };
            // 判断是否需要分页
            if (props?.hidePaginationFlag !== 'Y') {
                data.pagination = [{
                    pageSize: pageSize,
                    currentPage: page,
                    sortColumn: '',
                    sortOrder: ''
                }]
            }
            const res = await React.$asyncPost(queryCode, data);
            setTableData(React.$processingTableRequestData(res));
            setTotal(res.result?.total || 0);
            setLoading(false);
            // setRowID('');
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
                } else {
                    setRowID('');
                }
            }
        }
    };

    // 选中行操作
    const setRowClassName = (record) => {
        return record.key === rowID ? 'common-table-select-bg' : '';
    };

    // 修改或添加关联组件信息
    const handleLinkItemChange = (val, index) => {
        let nLinkData = [...linkData];
        nLinkData[index].dataIndex = val;
        setLinkData(nLinkData);
    };

    // 添加关联数据
    const handleAdd = (record) => {
        setLinkData(oldData => {
            // 判断是否存在
            if (oldData.some(item => item.componentID === record?.id)) {
                message.warning('您已添加该组件，请勿重复添加！');
                return oldData;
            };
            return [
                ...oldData,
                { componentCode: record?.code || '', componentDesc: record?.descripts || '', componentID: record?.id || '' }
            ]
        });
    };

    // 删除
    const handleDelete = (index) => {
        let newLinkData = [...linkData];
        newLinkData.splice(index, 1);
        setLinkData(newLinkData);
    };

    // 确认关联
    const handleOk = (closeFlag) => {
        let nLinkData = [...linkData];
        for (let i = 0; i < nLinkData.length; i++) {
            if (!(nLinkData[i]?.dataIndex) || !(nLinkData[i]?.componentID)) {
                message.warning('请完善必填信息');
                return;
            }
        };
        props && props.onOk && props.onOk(nLinkData);
        if (closeFlag !== 'N') {
            setLinkData([]);
            setVisible(false);
        }
    };

    const { tableHeight = 460, size = 'small' } = props;

    const operationObj = {
        width: 100,
        title: '操作',
        fixed: 'right',
        align: 'center',
        key: 'operation',
        render: (text, record) => (
            <span>
                <span className="common-record-span" onClick={(e) => handleAdd(record, e)}>
                    <PlusOutlined style={{ marginRight: '4px' }} />
                    添加
                </span>
            </span>
        ),
    };
    return (
        <Modal
            open={visible}
            footer={null}
            width="1400px"
            className="menu-associated-components"
            title="组件关联菜单"
            onCancel={() => setVisible(false)}
        >
            <Row>
                <Col span={17} style={{ paddingRight: '12px' }}>
                    <Card
                        size="small"
                        title={(
                            <div className="common-card-title-icon">
                                <ProductOutlined />
                                组件列表
                            </div>
                        )}
                    >
                        <div style={{ display: queryFormData && queryFormData.length > 0 ? 'block' : 'none', marginBottom: '12px' }} className="common-dynamic-component">
                            <DynamicRenderingForm
                                className="common-dynamic-component-form common-dynamic-component-form-margin-bottom0"
                                ref={queryFormRef}
                                rowData={{}}
                                formData={queryFormData}
                                formItemCol={{ col: 6, labelCol: 6, wrapperCol: 17 }}
                            />
                        </div>
                        <div>
                            <PublicTablePagination
                                param={{
                                    size,
                                    page,
                                    total,
                                    loading,
                                    // 表头配置
                                    defaultPageSize: 20,
                                    componentName: 'ComponentDataMaintenance',
                                    columns: columns && Array.isArray(columns) && columns.length > 0 ? [...columns, operationObj] : [],
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
                        </div>
                    </Card>
                </Col>
                <Col span={7}>
                    <Card
                        size="small"
                        title={(
                            <div className="common-card-title-icon">
                                <FormOutlined />
                                关联组件
                            </div>
                        )}
                    >
                        <div style={{ paddingRight: '6px', height: tableHeight + 93 + 'px', overflow: 'auto' }}>
                            {linkData && linkData.map((item, index) => {
                                return (
                                    <div key={item?.componentID || index} style={{ marginBottom: '16px' }}>
                                        <div style={{ fontWeight: 900, marginBottom: '8px' }} className="common-card-title-vertical-line">
                                            <div style={{ width: '3px' }}></div>
                                            第 {index + 1} 个关联数据
                                            <Popconfirm
                                                title="删除后不可恢复，确定要删除吗?"
                                                className="common-record-delete-span"
                                                onConfirm={() => handleDelete(index)}
                                            >
                                                <span style={{ float: 'right', fontWeight: 'normal' }}>
                                                    <DeleteOutlined style={{ marginRight: '4px' }} />
                                                    删除
                                                </span>
                                            </Popconfirm>
                                        </div>
                                        <div style={{ marginBottom: '4px', paddingLeft: '10px' }} className="common-custom-required-style">
                                            关联组件信息：
                                        </div>
                                        <Input
                                            disabled
                                            style={{ width: '100%', marginBottom: '8px' }}
                                            value={(item?.componentDesc || '') + '(' + (item?.componentCode || '') + ')'}
                                        />
                                        <div style={{ marginBottom: '4px', paddingLeft: '10px' }} className="common-custom-required-style">
                                            字段对照：
                                        </div>
                                        <Input
                                            style={{ width: '100%' }}
                                            placeholder="对应前端组件位置"
                                            value={item?.dataIndex || undefined}
                                            onChange={e => handleLinkItemChange(e.target.value, index)}
                                        />
                                    </div>
                                )
                            })}
                        </div>
                        <div style={{ textAlign: 'center', paddingTop: '12px', borderTop: '1px solid #e8e8e8' }}>
                            <Button type="primary" disabled={!(linkData && Array.isArray(linkData) && linkData.length > 0)} onClick={handleOk}>确认</Button>
                            <Button
                                style={{ marginLeft: '24px' }}
                                disabled={!(linkData && Array.isArray(linkData) && linkData.length > 0)}
                                onClick={() => setVisible(false)}
                            >
                                取消
                            </Button>
                        </div>
                    </Card>
                </Col>
            </Row>
        </Modal>
    )
};

export default forwardRef(MenuAssociatedComponents);